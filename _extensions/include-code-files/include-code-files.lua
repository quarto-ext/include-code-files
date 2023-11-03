--- include-code-files.lua – filter to include code from source files
---
--- Copyright: © 2020 Bruno BEAUFILS
--- License:   MIT – see LICENSE file for details

--- Dedent a line
local function dedent (line, n)
  return line:sub(1,n):gsub(" ","") .. line:sub(n+1)
end

--- Filter function for code blocks
local function transclude (cb)
  local content = ""

  if cb.attributes.include then
    local fh = io.open(cb.attributes.include)
    if not fh then
      io.stderr:write("Cannot open file " .. cb.attributes.include .. " | Skipping includes\n")
      goto cleanup
    end

    -- change hyphenated attributes to PascalCase
    for i,pascal in pairs({"startLine", "endLine", "startAfter", "endBefore"})
    do
        local hyphen = pascal:gsub("%u", "-%0"):lower()
        if cb.attributes[hyphen] then
          cb.attributes[pascal] = cb.attributes[hyphen]
          cb.attributes[hyphen] = nil
        end
    end

    if cb.attributes.startLine and cb.attributes.startAfter then
      io.stderr:write("Cannot specify both startLine and startAfter | Skipping includes\n")
      goto cleanup
    end

    if cb.attributes.endLine and cb.attributes.endBefore then
      io.stderr:write("Cannot specify both endLine and endBefore | Skipping includes\n")
      goto cleanup
    end

    local number = 0
    local start = nil
    local finish = nil
    local skipFirst = false
    local skipLast = false

    -- set start and skipFirst based on start params
    if cb.attributes.startLine then
      start = tonumber(cb.attributes.startLine)
      if not start then
        start = cb.attributes.startLine
      end
    elseif cb.attributes.startAfter then
      start = tonumber(cb.attributes.startAfter)
      if not start then
        start = cb.attributes.startAfter
      end
      skipFirst = true
    else
      -- if no start specified, start at the first line
      start = 1
    end

    -- set finish and skipLast based on end params
    if cb.attributes.endLine then
      finish = tonumber(cb.attributes.endLine)
      if not finish then
        finish = cb.attributes.endLine
      end
    elseif cb.attributes.endBefore then
      finish = tonumber(cb.attributes.endBefore)
      if not finish then
        finish = cb.attributes.endBefore
      end
      skipLast = true
    else
      -- if no end specified, end at the last line
    end

    for line in fh:lines ("L")
    do
      number = number + 1
      -- if start or finish is a string, check if it exists on the current line
      if type(start) == "string" and string.find(line, start, 1, true) then
        start = number
      elseif type(finish) == "string" and string.find(line, finish, 1 , true) then
        finish = number
      end

      -- if haven't found start yet, then continue
      if start and type(start) == "number" then
        if number < start or (number == start and skipFirst) then
          goto continue
        end
      elseif start then
        -- else if start is still a string, then continue
        goto continue
      end

      -- if found finish, then end
      if finish and type(finish) == "number" then
        if number > finish or (number == finish and skipLast) then
          break
        end
      end

      if cb.attributes.dedent then
        line = dedent(line, cb.attributes.dedent)
      end

      content = content .. line
      ::continue::
    end
    fh:close()
  end
  ::cleanup::
  -- remove key-value pair for used keys
  cb.attributes.include = nil
  cb.attributes.startLine = nil
  cb.attributes.startAfter = nil
  cb.attributes.endLine = nil
  cb.attributes.endBefore = nil
  cb.attributes.dedent = nil
  -- return final code block
  return pandoc.CodeBlock(content, cb.attr)
end

return {
  { CodeBlock = transclude }
}
