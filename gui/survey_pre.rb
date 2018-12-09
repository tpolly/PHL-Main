class SurveyPre < GtkWindowWithBuilder
  def initialize
    super()
    
    id = 'survey_pre_results'
    Main.results[id] = {}
    
    @builder.get_object('confirm_button').signal_connect 'clicked' do
      Main.results[id]['birth_year'] = get_birth_year
      Main.results[id]['gender'] = get_gender
      Main.next_state
      @window.close
    end
    
    @gender_options = @builder.get_object('option_male').group
    @birth_year = @builder.get_object('birth_year')
  end
  
  def get_birth_year
    return @birth_year.value.to_i
  end
  
  def get_gender
    @gender_options.select(&:active?).first.label
  end
end
