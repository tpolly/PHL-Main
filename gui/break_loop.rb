class BreakLoop < GtkWindowWithBuilder
	def initialize()
		super(loop_on_destroy: false)

		@button_box = @builder.get_object('button_box')

		Main.states.each_with_index do |state, index|
			button = Gtk::Button.new(label: state.to_s)
			button.signal_connect 'clicked' do
				Main.state = index
				@window.close
				Main.gui_loop
			end
			@button_box.add(button)
		end

		@builder.get_object('back_to_start').signal_connect 'clicked' do
			@window.close
			Main.gui_loop
		end
	end
end
