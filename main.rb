#!/usr/bin/env ruby

require 'gtk3'
require 'json'

case RbConfig::CONFIG['host_os']
when /darwin|mac os/
	PLATFORM = :macos
when /linux/
	PLATFORM = :linux
else
	raise "unknown os"
end

PATH = File.expand_path(File.dirname(__FILE__))

Dir.glob("#{PATH}/inc/*.rb").each(&method(:require))
Dir.glob("#{PATH}/gui/*.rb").each(&method(:require))
Dir.glob("#{PATH}/distraction/*.rb").sort.each(&method(:require))

ARGV.each do |arg|
	case arg
	when '--mock-serial', '-m'
		MOCK = true
	when '--debug', '-d'
		DEBUG = true
	else
		puts "unknown option: #{arg}"
			exit 1
	end
end

MOCK = false unless defined? MOCK
DEBUG = false unless defined? DEBUG

module Main
	TRAIN_LENGTH = 6 # how many times should each contingiency be shown
	TRAIN_DELAY = 5  # how much time between a contingiency
	TEST_LENGTH = 1  # how many times should each contingiency be tested

	TRAIN_TIME_FOR_ONE_SUBSET = TRAIN_LENGTH * RandomMorsePattern::PATTERN_LENGTH * TRAIN_DELAY
	DRY_RUN_TIME = TRAIN_TIME_FOR_ONE_SUBSET
	LEARN_TIME = 30 # seconds

	SETS = 3 # 1 SET = SUBSETS times { training + testing } + a dry run
	SUBSETS = 4

	FILE_PATH = PATH + '/results/'

	# Define application flow
	@states = [
		[:init_serial], 
		[:start], 
		[:survey_pre], 
		[:prepare], 
		[:armband_test_recognize, 0], 
		[:explain_study],
		[:email_adress_box],
		[:explain_dry_run], 
		[:dry_run, -1], 
		[:explain_phl]
	] + (0.upto(SETS - 1)).map do |set|
		(set * SUBSETS).upto((set * SUBSETS) + (SUBSETS - 1)).map do |subset|
			[:train, :test_recognize, :test_construct].map {|method| [method, subset]}
		end.reduce(&:+) + [[:dry_run, set + 100]] # save dry runs as 100, 101, ...
	end.reduce(&:+) + [
		[:survey_post],
		[:goodbye],
		[:quit]
		]

		# Local storage
		@state = 0
		@ruettel = nil
		@distraction = nil
		@pattern = nil
		@filename = nil
		@results = {
			'test_results' => {}
		}

		class << self
			# chunk learning: first 4 subsets is first 5 chars, then next 5 chars, then everything
			def keys_for_subset(subset)
				case subset
				when 0..3
					return [*0..4]
				when 4..7
					return [*5..9]
				else # 8..11
					return [*0..9]
				end
			end

			# proceed to next GUI state
			def next_state
				@state+= 1
			end

			# continue study at certain point, open file from before
			def continue_file(filename)
				@filename = filename
				json = JSON.parse(File.read(@filename))
				@pattern = RandomMorsePattern.new(json['pattern'].each_with_object({}) {|(k,v), new| new[k.to_i] = v}) # fix keys from string to integer (JSON allows only string keys for objects)
				@distraction = instantiate_distraction(json['distraction'], @pattern)
				@results = json
				continue
			end

			# continue study at certain point
			def continue
				BreakLoop.new.show
			end

			# perform retest, open file from before
			def retest(filename)
				@filename = filename
				json = JSON.parse(File.read(@filename))
				@pattern = RandomMorsePattern.new(json['pattern'].each_with_object({}) {|(k,v), new| new[k.to_i] = v}) # fix keys from string to integer
				@distraction = instantiate_distraction(json['distraction'], @pattern)
				@results = json
				@state = 0
				@states = [[:prepare], [:armband_test_recognize, 1], [:test_recognize, SETS * SUBSETS + 1], [:test_construct, SETS * SUBSETS + 1], [:solution], [:survey_post_retest], [:goodbye], [:quit]];
				gui_loop
			end

			# start new study, write new file
			def new_study(distraction)
				@filename = Main::FILE_PATH + Time.now.strftime("%y-%m-%d_%H-%M-%S") + '.json'
				@pattern = RandomMorsePattern.new
				@distraction = instantiate_distraction(distraction, @pattern)
				@results['distraction'] = @distraction.class
				@results['pattern'] = @pattern.as_hash
				next_state
				gui_loop
			end

			# helper method to instantiate distraction object
			def instantiate_distraction(distraction_class_string, pattern)
				@distraction = Object.const_get(distraction_class_string).new
			end

			# "Main loop", being called asynchronously when windows are closed. Acts on what comes next from @states
			def gui_loop
				save_progress

				puts "gui loop: #{@state.to_s}: #{@states[@state].to_s}" if DEBUG

					if @states[@state].length == 2
						method(@states[@state][0]).call(@states[@state][1])
				else
					method(@states[@state][0]).call()
				end
			end	

			# GUI methods, these open windows
			def init_serial
				# initialize serial connection
				if MOCK
					ttys = ["/dev/mock"]
				else
					ttys = PLATFORM == :linux ? Dir.glob("/dev/ttyACM*") : Dir.glob("/dev/tty.usbmodem*")
				end

				if ttys.length == 1
					@ruettel = RuettelflugConnection.new(ttys.first)
					next_state
					gui_loop
				elsif ttys.length == 0
					raise "no serial device found!"
				else
					chooser = SerialChooser.new(ttys)
					chooser.show
				end
			end

			def start
				if @ruettel.nil?
					self.error(message: "Es konnte keine Verbindung zum Armband aufgebaut werden.\nBitte prüfen Sie, ob der Sender korrekt initialisiert ist.")
				else
					StartWindow.new(filepath: FILE_PATH).show
				end
			end

			def survey_pre
				SurveyPre.new.show
			end

			def prepare
				ArmbandTest.new.show
			end

			def armband_test_recognize(id)
				ArmbandTestRecognize.new(length: 5, id: id).show
			end

			def explain_study
				MessageBox.new(title: "Beginn Studie", text: @distraction.explain_study).show
			end

			def email_adress_box
				EmailAdressBox.new.show	
			end

			def explain_dry_run
				if @distraction.do_dry_run?
					MessageBox.new(title: "Beginn Studie", text: @distraction.explain_dry_run).show
				else
					next_state
					gui_loop
				end
			end

			def dry_run(subset)
				if @distraction.do_dry_run?
					@distraction.enable_distraction
					Thread.new do
						if subset == -1
							sleep LEARN_TIME
						else
							sleep DRY_RUN_TIME					
						end
						@distraction.disable_distraction(subset: subset) # save as 100, 101, 102 etc.
							next_state
						gui_loop
					end
				else # skip this if there's no distraction task
					next_state
					gui_loop
				end
			end

			def explain_phl
				MessageBox.new(title: "Beginn Studie", text: @distraction.explain_phl).show
			end

			def train(subset)
				@distraction.enable_distraction
				TrainPattern.new(keys: keys_for_subset(subset), pattern: @pattern, length: TRAIN_LENGTH, delay: TRAIN_DELAY).show
			end

			def test_recognize(subset)
				@distraction&.disable_distraction(subset: subset)
				TestPatternRecognize.new(keys: [*0..9], subset: subset, pattern: @pattern, length: TEST_LENGTH, id: 'recognize').show
			end

			def test_construct(subset)
				TestPatternConstruct.new(keys: [*0..9], subset: subset, pattern: @pattern, length: TEST_LENGTH, id: 'construct', feedback_enabled: @distraction.provide_feedback?).show
			end

			def solution
				Solution.new(pattern: @pattern).show
			end

			def survey_post_retest
				@distraction.survey_post_retest
			end

			def survey_post
				@distraction.survey_post
			end

			def goodbye
				ThankYou.new.show
			end

			def quit
				Gtk.main_quit
			end

			# save current results
			def save_progress
				File.write(@filename, @results.to_json) unless @filename.nil?
			end

			# getters and setters
			attr_reader :ruettel, :states, :state, :results
			attr_writer :ruettel, :state

			def test_results
				return @results['test_results']
			end

			# show error message
			def error(message = "Unbekannter Fehler")
				MessageBox.new(title: 'Kritischer Fehler', text: message).show
				@state = -1
				@states = [[:quit]]
			end 
			end
end

# start app
begin
	Main.gui_loop
rescue RuntimeError => e
	puts "RuntimeError: #{e.message}"
		Main.error(e.message)
end
Gtk.main
