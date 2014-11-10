class Piece

  COLORS = [:white, :black]

  DELTAS_DIAGONAL = [
    [ 1,  1],
    [-1,  1],
    [ 1, -1],
    [-1, -1]
  ]

  DELTAS_ORTHOGONAL = [
    [ 1,  0],
    [-1,  0],
    [ 0, -1],
    [ 0,  1]
  ]

  attr_accessor :pos
  attr_reader :board, :color

  def initialize(pos, board, color)
    @pos, @board, @color = pos, board, color
  end

  def dup(new_board = nil)
    self.class.new(self.pos.dup, new_board, self.color)
  end

  def valid_moves
    moves.select do |move|
      board_copy = self.board.dup
      board_copy.move!(self.pos, move)
      !board_copy.in_check?(self.color)
    end
  end

  def is_teammate?(piece)
    !piece.nil? && piece.color == self.color
  end

  def is_enemy?(piece)
    !piece.nil? && piece.color != self.color
  end

end

class SlidingPiece < Piece

  def moves
    search_all_dirs(deltas)
  end

  private

  def search_all_dirs(deltas)
    new_array = []

    deltas.each do |delta|
      pos_new = [self.pos[0] + delta[0], self.pos[1] + delta[1]]

      next if Board::off_board?(pos_new)

      new_array.concat(search_one_dir(delta, pos_new))
    end

    new_array
  end

  def search_one_dir(delta, pos_new)
    return [] if is_teammate?(self.board[pos_new]) #return: empty if teammate
    return [pos_new] if is_enemy?(self.board[pos_new]) #position if enemy

    result = [pos_new]
    pos_new = [pos_new[0] + delta[0], pos_new[1] + delta[1]]

    if Board::off_board?(pos_new)
      result
    else
      result.concat(search_one_dir(delta, pos_new))
    end
  end

end

class Bishop < SlidingPiece

  private

  def deltas
    Piece::DELTAS_DIAGONAL
  end

end

class Rook < SlidingPiece

  private

  def deltas
    Piece::DELTAS_ORTHOGONAL
  end

end

class Queen < SlidingPiece

  private

  def deltas
    Piece::DELTAS_DIAGONAL + Piece::DELTAS_ORTHOGONAL
  end

end

class SteppingPiece < Piece

  def moves
    new_array = []

    deltas.each do |delta|
      pos_new = [self.pos[0] + delta[0], self.pos[1] + delta[1]]

      next if Board::off_board?(pos_new) || is_teammate?(self.board[pos_new])

      new_array << pos_new
    end

    new_array
  end

end

class Knight < SteppingPiece

  DELTAS_KNIGHT = [
    [ 2,  1],
    [ 1,  2],
    [-1,  2],
    [-2,  1],
    [-2, -1],
    [-1, -2],
    [ 1, -2],
    [ 2, -1]
  ]

  private

  def deltas
    DELTAS_KNIGHT
  end

end

class King < SteppingPiece

  private

  def deltas
    DELTAS_DIAGONAL + DELTAS_ORTHOGONAL
  end

end

class Pawn < Piece

  def moves
    dir = (self.color == :black ? 1 : -1)

    deltas = [[dir, 0]]

    first_row = (self.color == :black ? 1 : 6) #black starts on top
    deltas << [2 * dir, 0] if self.pos[0] == first_row #move 2 on first move

    #convert deltas to the new positions
    deltas.map! {|delta| [self.pos[0] + delta[0], self.pos[1] + delta[1]] }

    #select those positions that are on board and have no pieces
    deltas.select! {|pos| !Board::off_board?(pos) && self.board[pos].nil?}

    #the pawn may capture enemy on forward-diagonal
    diagonals = [[dir, -1], [dir, 1]]

    #convert diagonal deltas to the new positions
    diagonals.map! {|delta| [self.pos[0] + delta[0], self.pos[1] + delta[1]] }

    #select those positions that are on board and have enemy pieces
    diagonals.select!{|pos| !Board::off_board?(pos) && is_enemy?(self.board[pos])}

    deltas + diagonals
  end

end