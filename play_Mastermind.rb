require_relative 'class_mastermind'
require_relative 'class_Player'

sid = Player.new('Sid')

game = Mastermind.new(sid)

game.play_game