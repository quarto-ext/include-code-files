local str = pandoc.utils.stringify

-- remove the nth line 
local function dedent (line, n)
  return line:sub(1,n):gsub(" ","") .. line:sub(n+1)
end

-- function for reading the content of included file and including the 
-- content
local function source_include(filepath, startLine, endLine, dedentLine, lang, filename, 
  line_number)
  local add_source = {
    CodeBlock = function(cb)
      local content = ""
      local fh = io.open(filepath)
      if not fh then
        io.stderr:write("Cannot open file " .. filepath .. " | Skipping includes\n")
      else
        local number = 1
        local start = 1
        if startLine then
          cb.attributes.startFrom = startLine
          start = tonumber(startLine)
        end
        for line in fh:lines ("L") do
          if dedentLine then
            line = dedent(line, dedentLine)
          end
          if number >= start then
            if not endLine or number <= tonumber(endLine) then
              content = content .. line
            end
          end
          number = number + 1
        end 
        fh:close()
        if lang then
          cb.classes = {lang, "cell-code"}
        else
          cb.classes:insert('cell-code')
        end
        if filename then
          cb.attributes.filename = filename
        end
        if line_number then
          cb.classes:insert('number-lines')
        end
      end     
      return pandoc.CodeBlock(content, cb.attr)
    end
  }
  return add_source
end

-- gets the necessary chunk option and apply the source_include function with
-- these.
function Div(el)
  if el.attributes['add-code-from'] then
    local filepath = str(el.attributes['add-code-from'])
    local startLine = el.attributes['start-line']
    local endLine = el.attributes['end-line']
    local dedent_line = el.attributes.dedent
    local lang = el.attributes['source-lang']
    local filename = el.attributes['filename']
    local line_number = el.attributes['code-line-numbers']
    local div = el:walk(source_include(filepath, startLine, endLine, 
      dedent_line, lang, filename, line_number))
    return div
  end
end