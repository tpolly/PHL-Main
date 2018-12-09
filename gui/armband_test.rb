class ArmbandTest < GtkWindowWithBuilder
  def initialize
    super()
    
    @builder.get_object('test_armband').signal_connect 'clicked' do
    	Main.ruettel.send_synchronous([0, 1, 0, 1])
    end
    
    @builder.get_object('test_earplugs').signal_connect 'clicked' do
    	Speaker.speak_synchronous(Random.rand(10))
    end
    
    @builder.get_object('ok_button').signal_connect 'clicked' do
      Main.next_state
      @window.close
    end
  end
end
