class TestPatternRecognize < GtkWindowWithBuilder
	def initialize(keys:, subset:, pattern:, length:, id:)
		super()

		@pattern = pattern
		@length = length
		@keys = keys

		@window.title = "Abfragetest (#{subset})"

		@max = @keys.length * 2 # keys plus same amount of nonsense questions

		@progress_label = @builder.get_object('progress_label')
		@progress_bar = @builder.get_object('progress_bar')

		@progress_bar.max_value = @max
		@repetitions = 0

		@digits = length.times.map {(@keys + ([nil] * @keys.length)).shuffle}.flatten
		@patterns = @digits.map {|digit| digit.nil? ? @pattern.get_random_invalid : @pattern.get(digit)}

		if Main.test_results[id].nil?		
			Main.test_results[id] = {}
		end
		if Main.test_results[id][subset].nil?
			Main.test_results[id][subset] = {}
		end
		@results = Main.test_results[id][subset]

		Thread.new do
			5.downto(1).each do |i|
				@progress_label.label = "Test startet in #{i} Sekunde#{i == 1 ? '' : 'n'}"
				sleep 1
			end
			set_progress(0)
			Main.ruettel.send(@patterns[@progress])
			@time_sent = Time.now

			# connect GUI events
			@pattern.keys.each do |i|
				@builder.get_object("button-#{i}").signal_connect('clicked') { user_input(i) }
			end

			@window.signal_connect("key_press_event") do |window, event|
				case event.keyval
				when 117
					user_input(nil)
				when 119
					repeat_pattern
				when (48..57)
					num = event.keyval - 48
					if (num >= 0 && num <= 9)
						user_input(num)
					end
				end
			end

			@builder.get_object('repeat_button').signal_connect('clicked') do
				repeat_pattern
			end

			@builder.get_object('invalid').signal_connect('clicked') do
				user_input(nil)
			end
		end
	end

	def repeat_pattern
		Main.ruettel.send(@patterns[@progress])
		@repetitions += 1	
	end

	def user_input(i) # nil means invalid
		return if @progress == @max

		time_elapsed = Time.now - @time_sent
		correct = i == @digits[@progress] # also works for nil
		pattern_distance = i.nil? ? nil : levenshtein_distance(@patterns[@progress], @pattern.get(i)) # how closely the pattern for the user's input and the actual pattern are related

		@results[@progress] = {
			digit: @digits[@progress],
			displayed_pattern: @patterns[@progress], # saved because of nonsense questions
			user_answer: i,
			correct: correct,
			pattern_distance: pattern_distance,
			time_elapsed: time_elapsed,
			repetitions: @repetitions
		} 

		increment_progress
		@repetitions = 0

		if @progress == @max
			Thread.new do # can't sleep on main GUI thread
				sleep 0.3 # just so that the user sees the progress bar completed
				Main.next_state
				@window.close
			end
		else
#			puts "debug: send #{@digits[@progress].to_s}"
			Main.ruettel.send(@patterns[@progress])
			@time_sent = Time.now
		end
	end

	def set_progress(i)
		@progress = i
		@progress_bar.value = @progress
		@progress_label.label = "#{@progress} von #{@max}"
	end

	def increment_progress
		set_progress(@progress + 1)
	end
end
