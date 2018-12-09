module Speaker
	def self.play(filename)
		if PLATFORM == :linux
			system("aplay -q " + filename)	
		else # :macos
			system("afplay " + filename)
		end
	end

	# speak digit
	def self.speak(i)
		Thread.new do # don't block calling thread
			self.speak_synchronous(i)
		end
	end

	def self.speak_synchronous(i)
		if i >= 0 && i <= 9
			self.play("#{PATH}/audio/#{i}.wav")
		end
	end
end

