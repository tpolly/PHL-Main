class ThankYou < GtkWindowWithBuilder
  def initialize()
    super()
    
    @builder.get_object('ok_button').signal_connect 'clicked' do
      Main.next_state
      @window.close
    end
  end
end
