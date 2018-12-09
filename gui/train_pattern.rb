class TrainPattern < GtkWindowWithBuilder
	def initialize(keys:, pattern:, length:, delay:)
		super()

		@pattern = pattern
		@length = length
		@delay = delay
		@keys = keys.length == RandomMorsePattern::PATTERN_LENGTH ? keys.shuffle : keys.shuffle * (RandomMorsePattern::PATTERN_LENGTH / keys.length) # pad length, multiply array if not fit

		@max = length * @keys.length
		@progress_label = @builder.get_object('progress_label')
		set_progress(0)

		Thread.new do
			sleep @delay
			@length.times do |i|
				@keys.each_with_index do |num, index|
#					puts "debug: speak #{num.to_s}" if DEBUG
					Speaker.speak(num)
#					puts "debug: send #{@pattern.get(num).to_s}" if DEBUG
					Main.ruettel.send(@pattern.get(num))
					sleep @delay
					set_progress(i * @keys.length + index + 1)
				end
			end
			Main.next_state
			@window.close
		end
	end

	def set_progress(i)
		@progress_label.label = "Muster #{i + 1} von #{@max}"
	end
end
