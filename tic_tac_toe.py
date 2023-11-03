# tic_tac_toe.py

class TicTacToe:
    # [TicTacToe init start]
    def __init__(self):
        self.board = [[' ' for _ in range(3)] for _ in range(3)]
        self.current_turn = 'X'
    # [TicTacToe init end]

    def print_board(self):
        for row in self.board:
            print('|'.join(row))
            print('-'*5)

    def is_valid_move(self, row, col):
        return self.board[row][col] == ' '

    def place_mark(self, row, col):
        if not self.is_valid_move(row, col):
            return False
        self.board[row][col] = self.current_turn
        return True

    def switch_player(self):
        self.current_turn = 'O' if self.current_turn == 'X' else 'X'

    def check_winner(self):
        # Check rows, columns and diagonals
        for i in range(3):
            if self.board[i][0] == self.board[i][1] == self.board[i][2] != ' ':
                return self.board[i][0]
            if self.board[0][i] == self.board[1][i] == self.board[2][i] != ' ':
                return self.board[0][i]
        if self.board[0][0] == self.board[1][1] == self.board[2][2] != ' ':
            return self.board[0][0]
        if self.board[0][2] == self.board[1][1] == self.board[2][0] != ' ':
            return self.board[0][2]
        return None

    def is_board_full(self):
        return all(self.board[row][col] != ' ' for row in range(3) for col in range(3))

    def play_game(self):
        while True:
            self.print_board()

            # Try to place a mark, if the move is invalid, retry.
            try:
                row = int(input(f"Player {self.current_turn}, enter your move row (0-2): "))
                col = int(input(f"Player {self.current_turn}, enter your move column (0-2): "))
            except ValueError:
                print("Please enter numbers between 0 and 2.")
                continue

            if row < 0 or row > 2 or col < 0 or col > 2:
                print("Invalid move. Try again.")
                continue

            if not self.place_mark(row, col):
                print("This spot is taken. Try another spot.")
                continue

            winner = self.check_winner()
            if winner:
                self.print_board()
                print(f"Player {winner} wins!")
                break
            elif self.is_board_full():
                self.print_board()
                print("It's a tie!")
                break

            self.switch_player()

# Main game execution
if __name__ == "__main__":
    game = TicTacToe()
    game.play_game()
