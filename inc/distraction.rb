class Distraction
	def initialize
		if self.class.name == 'Distraction'
			raise 'abstract class, you\'re not supposed to instantiate this'
		end
	end

	# whether this distraction task requires a dry run to test game performance without PHL
	def do_dry_run
		false
	end

	# can overwrite this if a distraction task is used
	def enable_distraction
	end

	# can overwrite this if a distraction task is used. will also save the distraction score
	def disable_distraction(subset:)
	end

	def survey_post_questions
		raise 'instance_questions not overwritten yet'
	end
	
	def survey_post_retest_questions
		[
			'Ich konnte mich gut an die Muster erinnern.',
			'Die Auflösung war für mich wenig überraschend.',
		]
	end

	def common_questions
		[
			'Die Vibration war zu stark.',
			'Die Vibration war zu schwach.',
			'Die Vibration war störend/unangenehm.',
			'Lange und kurze Vibrationen waren gut zu unterscheiden.',
			'Ich konnte das Summen der Vibrationsmotoren hören.',
			'Das Summen der Motoren zu Hören hat mir bei der Wahrnehmung der Muster geholfen.',
			'Ich war motiviert, die Muster bestmöglichst zu lernen.',
			'Ich konnte im Test die Muster gut erkennen.',
			'Ich konnte im Test die Muster gut wiedergeben.',
		]
	end

	def common_distraction_questions
		[
			'Ich kannte das Spiel bereits gut',
			'Ich habe mich während des Spiels auf die Vibrationsmuster konzentriert.',
			'Ich habe mich auf das Spiel konzentriert.',
			'Die Vibration hat vom Spiel abgelenkt.',
			'Die Zahlwörter haben vom Spiel abgelenkt.',
			'Das Spiel hat meine volle Aufmerksamkeit erfordert.',
			'Das Spiel hat mir Spaß gemacht.',
			'Ich war motiviert, das Spiel bestmöglichst zu spielen.',
		]
	end

	def survey_post
		SurveyPost.new(questions: survey_post_questions, label_text: "Sie haben es fast geschafft!\n\nWir haben noch ein paar Fragen, wie Sie die Studie wahrgenommen haben.\nBitte geben Sie dazu an, in wieweit die folgenden Aussagen zutreffen:", id: 'survey_post_results').show
	end

	def survey_post_retest
		SurveyPost.new(questions: survey_post_retest_questions, label_text: "Fast fertig, ein paar Fragen zur Ihrer Einschätzung noch:", id: 'survey_post_retest_results').show
	end
end
