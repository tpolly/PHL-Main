class GtkWindowWithBuilder
	def initialize(loop_on_destroy: true, glade_file: "#{PATH}/gui/#{self.class.name.to_snake}.glade")
		if self.class.name == "GtkWindowWithBuilder"
			raise "abstract class, you're not supposed to instantiate this"
		end

		@builder =  Gtk::Builder.new file: glade_file
		@window = @builder.get_object 'window'
		
		@state_on_start = Main.states[Main.state]
		
		if loop_on_destroy
			@window.signal_connect('destroy') do
				if Main.states[Main.state] == @state_on_start
					Main.continue
				else
					Main.gui_loop
				end
			end
		end
	end

	public
	def show
		@window.show_all
	end
end

