class TestPatternConstruct < GtkWindowWithBuilder
	def initialize(keys:, subset:, pattern:, length:, id:)
		super()

		@pattern = pattern
		@length = length
		@keys = keys
		@max = length * @keys.length
		
		@window.title = "Abfragetest (#{subset})"

		@entry = @builder.get_object('entry')
		@progress_label = @builder.get_object('progress_label')
		@progress_bar = @builder.get_object('progress_bar')

		@progress_bar.max_value = @max

		@digits = length.times.map {@keys.shuffle}.flatten
		@results = nil
		@repetitions = 0
		
		@ok_disabled = false # prevent enter key from firing twice

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
			Speaker.speak(@digits[@progress])
			@time_sent = Time.now

			# connect GUI events
			@builder.get_object('dash').signal_connect('clicked') { write_dash }
			@builder.get_object('dot').signal_connect('clicked') { write_dot }
			@builder.get_object('delete').signal_connect('clicked') { delete_char }
			@builder.get_object('ok').signal_connect('clicked') { next_pattern }
			@builder.get_object('repeat').signal_connect('clicked') { repeat_number }

			@window.signal_connect('key_press_event') do |window, event|
				case event.keyval
				when 46
					write_dot
				when 45
					write_dash
				when 119
					repeat_number
				when 65293
					next_pattern
				when 65288
					delete_char
				end
			end

		end
	end

	def repeat_number
		Speaker.speak(@digits[@progress])
		@repetitions += 1
	end

	def write_dot
		@entry.text += DOT + " "
	end

	def write_dash
		@entry.text += DASH + " "
	end

	def delete_char
		@entry.text = @entry.text[0..-3]
	end

	def delete_all
		@entry.text = ''
	end

	def next_pattern
		return if @progress == @max
		return if @ok_disabled

		time_elapsed = Time.now - @time_sent
		user_answer = @entry.text.split(' ').map(&{DOT => 0, DASH => 1}.to_proc)
		correct_answer = @pattern.get(@digits[@progress])
		correct = user_answer == correct_answer
		distance = levenshtein_distance(user_answer, correct_answer)

		@results[@progress] = {
			digit: @digits[@progress], 
			correct_answer: correct_answer, 
			user_answer: user_answer, 
			correct: correct, 
			distance: distance, 
			time_elapsed: time_elapsed, 
			repetitions: @repetitions
		}

		increment_progress
		@progress_label.label = "Nächstes Muster in 1 Sekunde"
		@repetitions = 0

		if @progress == @max
			Thread.new do
				sleep 0.3 # this is just so that the user sees the full progress bar when done
				Main.next_state
				@window.close
				end
		else
			delete_all
			@ok_disabled = true
			Thread.new do
				sleep 1
				Speaker.speak(@digits[@progress])
				@progress_label.label = "#{@progress} von #{@max}"
				@time_sent = Time.now
				@ok_disabled = false
			end
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
