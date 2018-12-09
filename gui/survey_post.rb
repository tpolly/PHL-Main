class SurveyPost < GtkWindowWithBuilder
	def initialize(questions:, label_text:, id:)
		super()

		@grid = @builder.get_object('grid')
		@label = @builder.get_object('label')
		@label.text = label_text
		@comment = @builder.get_object('comment')
		
		Main.results[id] = {}
		@buttons = {}

		questions.each_with_index do |question, index|
			row = index + 1 # skip title row

			label = Gtk::Label.new
			label.text = question
			label.halign = :end
			@grid.attach(label, 0, row, 1, 1)

			@buttons[question] = []

			(1..5).each do |column|
				radio_button = Gtk::RadioButton.new
				radio_button.halign = :center
				@grid.attach(radio_button, column, row, 1, 1)
				@buttons[question][column-1] = radio_button
			end

			(1..5).each do |column|
				@buttons[question][column-1].group = @buttons[question] - [@buttons[question][column-1]] # set button group to all buttons except itself
			end

			@buttons[question][2].active = true # pre-activate center
		end
		
		@builder.get_object('confirm_button').signal_connect 'clicked' do
      questions.each do |question|
		  	Main.results[id][question] = @buttons[question].index(@buttons[question].select{|button| button.active?}.first) + 1 # self-explanatory
      end
      Main.results[id]['comment'] = @comment.text
      Main.next_state
      @window.close
    end
	end
end
