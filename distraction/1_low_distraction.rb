class LowDistraction < Distraction
	GWELED_EXECUTABLE = "#{PATH}/../Distraction-Tasks/Gweled-bin/bin/gweled"

	def initialize
		super

		if Main.test_results['distraction'].nil?		
			Main.test_results['distraction'] = {'gweled_score' => {}}
		end
	end

	def do_dry_run?
		true
	end

	def explain_study
		<<~EOF
			Super, dann ist alles bereit!

			Ihre Aufgabe in dieser Studie ist es, im Spiel Gweled das beste Spielergebnis aller Teilnehmer zu erlangen. Während Sie spielen wird ihnen durch Ansage einer Zahl und Anzeige eines Musters versucht, ein Code ähnlich wie Morsecode beizubringen. Lassen Sie sich davon nicht ablenken! Sie sollen sich einzig und allein auf das Spiel fokussieren.
			
			Die Muster werden alle 5 Minuten abgefragt, es gibt auch Durchgänge ohne Zahl/Musteranzeige. Lassen Sie sich von der Abfrage nicht unter Druck setzen! Überlegen Sie bei der Abfrage nicht lang, sondern geben Sie einfach an, welche Muster Sie in dem Moment erkennen/wiedergeben können. Es ist absolut in Ordnung wenn Sie nichts oder nur wenig bei der Abfrage angeben.
			
			Um Sie dazu zusätzlich zu motivieren, gibt es ein kleines Gewinnspiel: Der Teilnehmer mit dem besten Spielergebnis gewinnt einen 10€ Amazon-Gutschein! Falls Sie daran teilnehmen wollen, geben Sie im folgenden Fenster Ihre Emailadresse ein.
		EOF
	end

	def explain_dry_run
		<<~EOF
			Im Spiel müssen Sie Reihen von 3 oder mehr gleichen Symbolen bilden, indem Sie mit der Maus zwei Symbole vertauschen. Sie werden gleich sehen wie das aussieht.
		
			Wir spielen eine kurze Testrunde! Falls es Probleme gibt können Sie sich jederzeit bei der Aufsicht melden.
		EOF
	end

	def explain_phl
		<<~EOF
			Ab jetzt startet das Training des Musters.
			
			Nicht vergessen: Ihr Ziel ist ausschließlich, das beste Spielergebnis zu bekommen. Sie können und sollen die Zahlen/Muster ignorieren.
		EOF
	end

	def enable_distraction
		@read, @write = IO.pipe
		@pid = spawn(GWELED_EXECUTABLE, out: @write)
	end

	def disable_distraction(subset:)
		return if @pid.nil?
		Process.kill('HUP', @pid)
		Process.wait(@pid)
		@write.close
		Main.test_results['distraction']['gweled_score'][subset] = @read.read.split("\n").select { |str| /Gems removed/ =~ str }.map{ |str| str.split(" ").last.to_i }.reduce(&:+).to_i # .to_i catches the edge case of empty array -> 0 instead of null
		@read.close
	end

	def survey_post_questions
		common_questions + common_distraction_questions
	end
end
