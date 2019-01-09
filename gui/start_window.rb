class StartWindow < GtkWindowWithBuilder
	def initialize(filepath:)
		super(loop_on_destroy: false)

		@builder.get_object('new_participant_a').signal_connect('clicked') { Main.new_study("LowDistraction"); @window.close }
		@builder.get_object('new_participant_b').signal_connect('clicked') { Main.new_study("HighDistraction"); @window.close }
		@builder.get_object('new_participant_c').signal_connect('clicked') { Main.new_study("NoDistraction"); @window.close }
		@builder.get_object('new_participant_a_feedback').signal_connect('clicked') { Main.new_study("LowDistractionWithFeedback"); @window.close }
		@builder.get_object('new_participant_b_feedback').signal_connect('clicked') { Main.new_study("HighDistractionWithFeedback"); @window.close }

		@builder.get_object('continue').signal_connect 'clicked' do
			dialog = Gtk::FileChooserDialog.new(title: "Datei wählen", parent: @window, action: :open, buttons: [[Gtk::Stock::OPEN, :accept], [Gtk::Stock::CANCEL, :cancel]])
			dialog.set_current_folder(filepath)

			if dialog.run == :accept
				@window.close
				Main.continue_file(dialog.filename)
			end
			dialog.destroy
		end
		
		@builder.get_object('retest').signal_connect 'clicked' do
			dialog = Gtk::FileChooserDialog.new(title: "Datei wählen", parent: @window, action: :open, buttons: [[Gtk::Stock::OPEN, :accept], [Gtk::Stock::CANCEL, :cancel]])
			dialog.set_current_folder(filepath)

			if dialog.run == :accept
				@window.close
				Main.retest(dialog.filename)
			end
			dialog.destroy
		end

		@builder.get_object('close').signal_connect 'clicked' do
			Gtk.main_quit
		end
	end
end
