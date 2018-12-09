class Solution < GtkWindowWithBuilder
	def initialize(pattern:)
		super()

		@grid = @builder.get_object('grid')

		pattern.as_hash.each do |digit, pattern|
			digit_label = Gtk::Label.new
			digit_label.text = digit.to_s
			@grid.attach(digit_label, digit + 1, 0, 1, 1)
			
			pattern_label = Gtk::Label.new
			pattern_label.text = pattern.map(&{0=>DOT, 1=>DASH}.to_proc).join(' ')
			@grid.attach(pattern_label, digit + 1, 1, 1, 1)
			
			morse_label = Gtk::Label.new
			morse_label.text = RandomMorsePattern::MORSE_CODE.key(pattern).to_s
			@grid.attach(morse_label, digit + 1, 2, 1, 1)
		end

		@builder.get_object('confirm_button').signal_connect 'clicked' do
			Main.next_state
			@window.close
		end
	end
end
