class ComputerPlayer

  attr_reader :color

  def initialize(color)
    @color = color
  end

  def play_turn
    letters = ('a'..'h').to_a
    numbers = (1..8).to_a.map(&:to_s)
    start = letters[rand(8)] + numbers[rand(8)]
    end_pos = letters[rand(8)] + numbers[rand(8)]
    [start, end_pos]
  end

end