class Player
  attr_accessor :role
  attr_reader :name

  @@player_count = 0
  def initialize(name)
    @name = name
    @@player_count += 1
  end

end