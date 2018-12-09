class SerialChooser < GtkWindowWithBuilder
  def initialize(ttys)
    super()

    button_box = @builder.get_object("button_box")

    ttys.each do |tty|
      button = Gtk::Button.new(label: tty)
      button.signal_connect 'clicked' do
      	begin
	      	Main.ruettel = RuettelflugConnection.new(tty)
		      Main.next_state
		      @window.close
				rescue RuntimeError => e
					Main.error(e.message)
				end
      end
      button_box.add(button)
    end
  end
end
