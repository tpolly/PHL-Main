class HighDistraction < Distraction
	OPEN_HEXAGON_DIR = "#{PATH}/../Distraction-Tasks/OpenHexagon-bin/"
	OPEN_HEXAGON_EXECUTABLE = OPEN_HEXAGON_DIR + 'SSVOpenHexagon'

	def initialize
		super

		if Main.test_results['distraction'].nil?		
			Main.test_results['distraction'] = {'open_hexagon_score' => {}}
		end
	end

	def do_dry_run
		true
	end

	def explain_study
		<<~EOF
			Super, dann ist alles bereit!

			Ihre Aufgabe in dieser Studie ist es, im Spiel Open Hexagon das beste Spielergebnis aller Teilnehmer zu erlangen. Während Sie spielen wird ihnen durch Ansage einer Zahl und Anzeige eines Musters versucht, ein Code ähnlich wie Morsecode beizubringen. Lassen Sie sich davon nicht ablenken! Sie sollen sich einzig und allein auf das Spiel fokussieren.
			
			Die Muster werden alle 5 Minuten abgefragt, es gibt auch Durchgänge ohne Zahl/Musteranzeige. Lassen Sie sich von der Abfrage nicht unter Druck setzen! Überlegen Sie bei der Abfrage nicht lang, sondern geben Sie einfach an, welche Muster Sie in dem Moment erkennen/wiedergeben können. Es ist absolut in Ordnung wenn Sie nichts oder nur wenig bei der Abfrage angeben.
			
			Um Sie dazu zusätzlich zu motivieren, gibt es ein kleines Gewinnspiel: Der Teilnehmer mit dem besten Spielergebnis gewinnt einen 10€ Amazon-Gutschein! Falls Sie daran teilnehmen wollen, geben Sie im folgenden Fenster Ihre Emailadresse ein.
		EOF
	end

	def explain_dry_run
		<<~EOF
			Im Spiel steuern sie ein Dreieck und müssen mit den Pfeiltasten Wänden ausweichen. Sie werden gleich sehen wie das aussieht.
		
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
		@pid = spawn(OPEN_HEXAGON_EXECUTABLE, out: @write, chdir: OPEN_HEXAGON_DIR)
	end

	def disable_distraction(subset:)
		return if @pid.nil?
		Process.kill('HUP', @pid)
		Process.wait(@pid)
		@write.close
		$r = @read
		Main.test_results['distraction']['open_hexagon_score'][subset] = -@read.read.split("\n").select { |str| /#wall crushed#/ =~ str }.count # negative score for deaths
	end

	def survey_post_questions
		common_questions + common_distraction_questions
	end
end
