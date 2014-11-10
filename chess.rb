require 'colorize'    #install with $ gem install colorize
require_relative 'piece'
require_relative 'board'
require_relative 'human_player'
require_relative 'computer_player'

class Game

  attr_accessor :player
  attr_reader :board, :players

  def initialize(players)
    @board = Board.new
    @players = players
    @player = players.first
  end

  def play
    until board.checkmate?(self.player.color)
      display_board

      begin
        start, end_pos = self.player.play_turn.map {|i| userinput_to_pos(i) }
        raise NotYourPieceError if board[start].color != self.player.color
        board.move(start, end_pos)
      rescue NotYourPieceError
        puts "That is not your piece!!"
        retry
      rescue
        puts "Your move is not allowed!!"
        retry
      end

      self.player = next_player
    end

    #if get here means checkmate
    display_board
    puts "Checkmate, " + next_player.color.to_s.capitalize + " won!!!!"
  end

  private

  def next_player
    (self.player == self.players[0]) ? self.players[1] : self.players[0]
  end

  def userinput_to_pos(square)
    len = Board::DIM
    letter = square[0]
    row = len - square[1].to_i
    col = ('a'..'h').to_a.index(letter)
    [row, col]
  end

  def display_board
    system("clear")
    puts "   a b c d e f g h\n\n"
    self.board.grid.each_with_index do |row, irow|
      print (Board::DIM - irow).to_s + "  "

      row.each do |piece|
        if piece.nil?
          print "* "
        elsif piece.is_a?(Rook)
          print "♖ ".colorize(piece.color)
        elsif piece.is_a?(Knight)
          print "♘ ".colorize(piece.color)
        elsif piece.is_a?(Bishop)
          print "♗ ".colorize(piece.color)
        elsif piece.is_a?(King)
          print "♔ ".colorize(piece.color)
        elsif piece.is_a?(Queen)
          print "♕ ".colorize(piece.color)
        else
          print "♙ ".colorize(piece.color)
        end
      end

      puts " " + (Board::DIM - irow).to_s
    end
    puts "\n   a b c d e f g h\n\n"
  end

end

class NotYourPieceError < StandardError
end

if $PROGRAM_NAME == __FILE__
  # running as script

  case ARGV.shift
  when nil
    #start normal human vs human game
    players = [
      HumanPlayer.new(Piece::COLORS[0]),
      HumanPlayer.new(Piece::COLORS[1])
    ]
    Game.new(players).play
  when "computer"
    #start human vs computer game
    players = [
      HumanPlayer.new(Piece::COLORS[0]),
      ComputerPlayer.new(Piece::COLORS[1])
    ]
    Game.new(players).play
  end

end







