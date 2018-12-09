class EmailAdressBox < GtkWindowWithBuilder
  def initialize
    super()
    
    id = 'emailadress'
    Main.results[id] = {}
    
    @builder.get_object('confirm_button').signal_connect 'clicked' do
      Main.results[id] = @builder.get_object('emailadress').text
      Main.next_state
      @window.close
    end
  end
end
