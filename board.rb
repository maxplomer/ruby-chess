class Board

  DIM = 8

  attr_reader :grid

  def initialize
    generate_board
  end

  def dup
    board_dup = Board.new

    grid.each_with_index do |row, irow|
       row.each_with_index do |piece, icol|
        pos = [irow, icol]
        board_dup[pos] = (piece.nil? ? nil :  piece.dup(board_dup))
      end
    end

    board_dup
  end

  def []=(key, value)
    self.grid[key[0]][key[1]] = value
  end

  def [](key)
    self.grid[key[0]][key[1]]
  end

  def self.off_board?(pos)
    row, col = pos
    !(row.between?(0, Board::DIM - 1) && col.between?(0, Board::DIM - 1))
  end

  def checkmate?(color)
    return false if !in_check?(color)  #the player must be in check!

    #checkmate if none of the player's pieces have any valid moves
    players_pieces = grid.flatten.compact.select{|piece| piece.color == color}

    players_pieces.map(&:valid_moves).flatten.empty?
  end

  def in_check?(color) #returns whether player 'color' is in check
    #find position of 'color' king
    king_pos = grid.flatten.select do |piece|
      piece.is_a?(King) && piece.color == color
    end[0].pos

    #see if any of the opposing pieces can move to that position
    in_check = false
    grid.flatten.compact.each do |piece|
      if piece.color != color
        in_check = true if piece.moves.include?(king_pos)
      end
    end

    in_check
  end

  def move(start, end_pos)
    piece = self[start]
    if piece.valid_moves.include?(end_pos)
      move!(start, end_pos)
    else
      raise 'this move would leave you in check!'
    end

    nil
  end

  def move!(start, end_pos)
    if self[start].nil?
      raise 'there is no piece at start'
    elsif !self[start].moves.include?(end_pos)
      raise 'the piece cannot move to end_pos'
    end

    self[start], self[end_pos] = nil, self[start]
    self[end_pos].pos = end_pos

    nil
  end

  private

  def generate_board
    @grid = Array.new(DIM) {Array.new(DIM)}

    #pawns
    DIM.times do |col|
      pos = [1, col]
      self[pos] = Pawn.new(pos, self, :black)
      pos = [6, col]
      self[pos] = Pawn.new(pos, self, :white)
    end

    #rooks
    [0,7].each do |col|
      pos = [0, col]
      self[pos] = Rook.new(pos, self, :black)
      pos = [7, col]
      self[pos] = Rook.new(pos, self, :white)
    end

    #knights
    [1,6].each do |col|
      pos = [0, col]
      self[pos] = Knight.new(pos, self, :black)
      pos = [7, col]
      self[pos] = Knight.new(pos, self, :white)
    end

    #bishops
    [2,5].each do |col|
      pos = [0, col]
      self[pos] = Bishop.new(pos, self, :black)
      pos = [7, col]
      self[pos] = Bishop.new(pos, self, :white)
    end

    #kings
    pos = [0, 4]
    self[pos] = King.new(pos, self, :black)
    pos = [7, 4]
    self[pos] = King.new(pos, self, :white)

    #queens
    pos = [0, 3]
    self[pos] = Queen.new(pos, self, :black)
    pos = [7, 3]
    self[pos] = Queen.new(pos, self, :white)
  end

end