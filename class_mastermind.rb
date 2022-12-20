# Class declaration for mastermind game
class Mastermind

  @player = nil
  @code = nil
  @code_guess = nil
  @turns = nil
  @max_turns = nil
  @slots = nil
  @colors = nil
  @possible_guesses = nil
  
  def initialize(player)
    @player = player
    @turns = 1
    @max_turns = 8
    @slots = 5
    @colors = ['R', 'B', 'G', 'P', 'Y', 'M']
    @evaluation = ''
    puts "Welcome #{@player.name}... Prepare yourself for battle"
    puts
  end

  # Runs game until code is cracked or turns expire
  def play_game
    print_rules
    player_choose_role
    set_code

    until game_over?
      make_guess
      evaluate_guess
      @turns += 1
    end

    game_end
  end

  # Prints the game rules to the console
  def print_rules
    puts '1. Whoever is Code Breaker gets 6 chances to break the code'
    puts
    puts '2. Each guess will be evaluated: if a slot guess is correct in color and position it will be marked with a bang (!); if a slot guess is correct in color but incorrect in position it will be marked with a question (?); otherwise, the guess will be marked with an x (X)'
    puts
    puts '3. We have 5 colors to choose from ...'
    puts 'Red (R), Green (G), Blue (B), Pink (P), and Yellow (Y)'
    puts
    puts "4. The code must contain exactly #{@slots} of these colors. Repeats ARE allowed but blanks are NOT"
    puts
    puts 'ex. for 4 slots, "GYRB", "PPPP", and "BYBY" are all valid codes while "  PY" and "    " are not'
    puts
    puts 'Good luck!'
    puts
  end
  
  private

  # Check if game has ended
  def game_over?
    player_victory? || player_defeat?
  end

  # Check if player has won
  def player_victory?
    if @player.role == 'Code Maker'
      @turns > @max_turns
    else
      @evaluation.match?('!' * @slots)
    end
  end

  # Check if player has lost
  def player_defeat?
    if @player.role == 'Code Maker'
      @evaluation.match?('!' * @slots)
    else
      @turns > @max_turns
    end
  end

  # Define end of game scenarios of win/loss
  def game_end
    if @player.role == 'Code Maker' && player_victory?
      puts "You won! The computer couldn't crack the code!"
    elsif @player.role == 'Code Breaker' && player_victory?
      puts "You won! You cracked the computer's code!"
    elsif @player.role == 'Code Maker' && player_defeat?
      puts "You lost! The computer cracked your code!"
    elsif @player.role == 'Code Breaker' && player_defeat?
      puts "You lost! You didn't crack the computer's code!"
    end
  end
    
  # Set the Mastermind code, either player or computer depending on role
  def set_code
    if @player.role == 'Code Maker'
      make_player_code
    else
      make_computer_code
    end
  end

  # Make a single guess for the code
  def make_guess
    if @player.role == 'Code Maker'
      computer_guess
    else
      player_guess
    end
  end
  
  # Player inputs guess for computer generated code
  def player_guess
    begin
      puts
      puts "Please enter your #{@slots} digit guess now (turn ##{@turns})>>"
      rgx_inp = Regexp.new("^[#{@colors.join}]{#{@slots}}$", Regexp::IGNORECASE)
      user_choice = gets.chomp.match(rgx_inp)[0]
    rescue
      puts 'Invalid input! Try again...'
      retry
    else
      @code_guess = user_choice.upcase
    end
  end

  # Computer guesses based on the evaluation returned by the game
  def computer_guess
    if @turns == 1
      @code_guess = @colors.sample(@slots).join('')
      puts "The computer guesses (turn ##{@turns})>> #{@code_guess}"
      @possible_guesses = (0...@slots).each_with_object({}) { |n, h| h[n] = @colors.dup }
    else
      prev_guess = @code_guess.split('')
      colors_on_trial = prev_guess.uniq
      evaluation = @evaluation.split('')

      @possible_guesses.each_key do |slot|
        if evaluation[slot] == '!'
          @possible_guesses[slot] = [prev_guess[slot]]
        elsif evaluation[slot] == '?' || evaluation[slot] == 'X'
          @possible_guesses[slot].delete(prev_guess[slot])
        end
      end
      puts @possible_guesses
      new_guess = []
      @possible_guesses.each_key do |slot|
        new_guess[slot] = @possible_guesses[slot].sample(1)
      end
      @code_guess = new_guess.join('')
      puts "The computer guesses (turn ##{@turns})>> #{@code_guess}"
    end
  end

  # Evaluate @code_guess for exact, partial, and no matches
  def evaluate_guess
    # Hash to count occurrences of each possible color in @code
    color_counts = @colors.each_with_object({}) { |color, hash| hash[color] = @code.scan(color).count }

    # First evaluate @code_guess for exact matches
    evaluation = @code_guess.split('').map.with_index do |guess, idx|
      if guess == @code[idx]
        color_counts[guess] -= 1
        '!'
      else
        '#'
      end
    end

    # Now evaluate @code_guess for partial or no matches
    @code_guess.split('').each_with_index do |guess, idx|
      if evaluation[idx].match?('!')
        next
      elsif color_counts[guess].positive?
        color_counts[guess] -= 1
        evaluation[idx] = '?'
      else
        evaluation[idx] = 'X'
      end
    end

    @evaluation = evaluation.join('')
    print_guess_evaluation
  end

  # Print the @code_guess evaluation to the command line
  def print_guess_evaluation
    puts
    puts 'Guess evaluation:'
    puts @evaluation.split('').join('  |  ')
    puts
    puts @code_guess.split('').join('  |  ')
    puts
  end
  # Let computer randomly choose a code
  def make_computer_code
    @code = @colors.sample(@slots).join('')

    puts "Okay, #{@player.name}, the computer has set its code! Now let's see if you can crack it :)"
    puts
  end

  # Let the player set their code
  def make_player_code
    puts "Okay, time to set your code, Code Maker #{@player.name}!"
    begin
      puts
      puts "Please enter your #{@slots} digit code now >>"
      rgx_inp = Regexp.new("^[#{@colors.join}]{#{@slots}}$", Regexp::IGNORECASE)
      user_choice = gets.chomp.match(rgx_inp)[0]
    rescue
      puts 'Invalid input! Try again...'
      retry
    else
      @code = user_choice.upcase
      puts "Okay, #{@player.name}, your code is secure! Now let's see if the computer can crack it :)"
      puts
    end
  end

  # Let the player choose their role as either code maker or code breaker
  def player_choose_role
    begin
      puts
      puts 'Choose your role: Code Maker (M) or Code Breaker (B)? >>'
      user_choice = gets.chomp.match(/^[MB]{1}$/i)[0]
    rescue
      puts 'Erroneous input! Try again...'
      retry
    else
      @player.role = user_choice.upcase.match?('M') ? 'Code Maker' : 'Code Breaker'

      puts "Okay, #{@player.name} is #{@player.role} playing vs the Computer!"
      puts
    end
  end
end
