class MessageBox < GtkWindowWithBuilder
  def initialize(title:, text:)
    super()
    
    @window.set_title(title)
    
    @builder.get_object('text').label = text.split("\n").map(&:add_linebreaks).join("\n")
    
    @builder.get_object('ok_button').signal_connect 'clicked' do
      Main.next_state
      @window.close
    end
  end
end
