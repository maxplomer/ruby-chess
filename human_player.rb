class HumanPlayer

  attr_reader :color

  def initialize(color)
    @color = color
  end

  def play_turn
    print self.color.to_s.capitalize + " turn, "
    puts "please enter your start and end positions\n(ex: a2, a4)"
    input = gets.chomp.split(",")
    input.map!(&:strip)
  end

end