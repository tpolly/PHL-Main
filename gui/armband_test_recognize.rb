class ArmbandTestRecognize < GtkWindowWithBuilder
	def initialize(length:, id:)
		super()

		@max = length
		@id = id

		@entry = @builder.get_object('entry')
		@progress_label = @builder.get_object('progress_label')
		@progress_bar = @builder.get_object('progress_bar')

		@progress_bar.max_value = @max

		@wrongs = 0

		@progress_label.label = "#{@progress} von #{@max}"
		Thread.new do
			10.downto(1).each do |i|
				@progress_label.label = "Test startet in #{i} Sekunde#{i == 1 ? '' : 'n'}"
				sleep 1
			end
			new_pattern
			set_progress(0)
			
			# connect GUI events
			@builder.get_object('dash').signal_connect('clicked') { write_dash }
			@builder.get_object('dot').signal_connect('clicked') { write_dot }
			@builder.get_object('delete').signal_connect('clicked') { delete_char }
			@builder.get_object('ok').signal_connect('clicked') { next_pattern }
			@builder.get_object('repeat_button').signal_connect('clicked') { repeat_pattern }

			@window.signal_connect('key_press_event') do |window, event|
				case event.keyval
				when 46
					write_dot
				when 45
					write_dash
				when 119
					repeat_pattern
				when 65293
					next_pattern
				when 65288
					delete_char
				end
			end
		end
	end

	def repeat_pattern
		Main.ruettel.send(@pattern)
	end

	def new_pattern
		@pattern = Array.new(Random.rand(2..4)) { |i| Random.rand(0..16)[i] }
		Main.ruettel.send(@pattern)
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

		user_answer = @entry.text.split(' ').map(&{DOT => 0, DASH => 1}.to_proc)
		if user_answer == @pattern
			increment_progress
			Thread.new do
				@progress_label.label = "Richtig!"
				sleep 1
				@progress_label.label = "#{@progress} von #{@max}"
			end

			if @progress == @max
				Main.test_results['armband_test_wrongs_' + @id.to_s] = @wrongs
				Thread.new do
					sleep 0.3 # this is just so that the user sees the full progress bar when done
					Main.next_state
					@window.close
					end
			else
				delete_all
				new_pattern
			end
		else
			Thread.new do
				@progress_label.label = "Leider falsch, probieren Sie es noch einmal."
				@wrongs += 1
				delete_all
				repeat_pattern
				sleep 1
				@progress_label.label = "#{@progress} von #{@max}"
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

