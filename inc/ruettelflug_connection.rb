require 'serialport'
require 'thread'
require 'timeout'

class RuettelflugConnection
	LONGPULSE = 100 # 500 milliseconds
	SHORTPULSE = 40 # 200 milliseconds
	PAUSE = 60 # 300 milliseconds
	# whatever we send must be values smaller than 255, so to enlarge the value range,
	# the receiver waits 5 * [what we send] in ms
	@mock = false

	def initialize(serial_dev)
		if serial_dev == "/dev/mock"
			@mock = true
		else
			begin
				retries ||= 0
				@serial_port = File.exists?(serial_dev) ? SerialPort.new(serial_dev, 9600) : raise("serial port device #{serial_dev} not found")
			rescue Exception => e
				sleep 1
				if (retries += 1) < 3
					retry
				else
					raise "Konnte nicht mit dem seriellen Gerät #{serial_dev} verbinden"
				end
			end
		end
	end

	def initialized?
		return !@serial_port.nil?
	end

	def send(sequence)
		gapsequence = sequence.map {|step| [step == 0 ? SHORTPULSE : LONGPULSE, PAUSE]}.flatten
		gapsequence.pop # remove pause at the end
	  if @mock
	  	puts "mock serial: " + gapsequence.to_s
	  	return 0
	  end
		gapsequence.each {|ms| @serial_port.putc ms}
		@serial_port.putc 0
		response = nil
		begin
			Timeout::timeout(1) do
				response = @serial_port.gets
				response&.strip!
			end
		rescue
			Main.error("BLE connection timeout")
			raise "BLE connection timeout"
		end
		if response != "OK"
			Main.error("no BLE connection")
			raise "no BLE connection"
		end
		return gapsequence.reduce(&:+)
  end

  def send_synchronous(sequence)
	  delay = send(sequence) / 200.0 + 0.5 # 1 -> 5ms waiting. 500ms for sending
	  sleep(delay)
  end
end



