class NoDistraction < Distraction
	def explain_study
		<<~EOF
			Super, dann ist alles bereit!
		
			Ihre Aufgabe bei dieser Studie ist es, Kombinationen von Ziffern 0 bis 9 und Vibrationsmustern aktiv zu lernen. Dazu wird Ihnen jeweils alle 5 Sekunden ein Zahlwort gesagt und das Vibrationsmuster am Armband angezeigt. Alle 5 Minuten werden die Kombinationen abgefragt. Es werden #{Main::SETS * Main::SUBSETS} Durchgänge durchgeführt mit jeweils Training und darauffolgender Abfrage, ein Durchgang dauert 5 Minuten. 
			
			Um Sie zusätzlich zu motivieren, gibt es ein kleines Gewinnspiel: Der Teilnehmer mit dem besten Lernergebnis gewinnt einen 10€ Amazon-Gutschein! Falls Sie daran teilnehmen wollen, geben Sie im folgenden Fenster Ihre Emailadresse ein.
		EOF
	end

	def explain_phl
		<<~EOF
			Jetzt geht es los. Falls Sie Fragen haben können Sie sich jederzeit an die Aufsicht widmen.
		EOF
	end

	def survey_post_questions
		common_questions + ['Die Muster folgten zu schnell aufeinander.', 'Die Muster folgten zu langsam aufeinander.', 'Ich konnte mir die Muster leicht merken.', 'Ich habe Eselsbrücken verwendet.']
	end
end
