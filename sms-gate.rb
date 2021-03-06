require_relative 'eventHandler'
require_relative 'gateAPI'
require_relative 'message'
require_relative 'parser'
require_relative 'smsManager'
require 'thread'

# New parser
parser = Parser.new
# Place and synchronization for incoming sms
incomingMessages = []
incomingMessages_m = Mutex.new
incomingMessages_c = ConditionVariable.new
# Place and synchronization for outgoing sms
outgoingMessages = []
outgoingMessages_m = Mutex.new
outgoingMessages_c = ConditionVariable.new

$stderr.puts "Starting receiver"
# Message recieving thread
messageReceiver = Thread.new do
	SMSManager.getSMS incomingMessages, incomingMessages_m, incomingMessages_c
end

$stderr.puts "Starting sender"
# Message sending Thread
messageSender = Thread.new do
	SMSManager.sendSMS outgoingMessages, outgoingMessages_m, outgoingMessages_c
end

$stderr.puts "Starting parser"
# Message processing thread
messageProcessor = Thread.new do
	$stderr.puts "Started parser"
	loop do
		message = nil
		incomingMessages_m.synchronize do
			incomingMessages_c.wait incomingMessages_m if incomingMessages.empty?
			message = incomingMessages.shift
		end
		reply = parser.parse message

		# Send the reply
		if reply
			# Ensure the message is really a message
			unless reply.is_a? Message
				$stderr.puts "Parser recieved a message that was not infact a message!"
				$stderr.puts message.inspect
				next
			end
			# Put the message in the outgoing array
			outgoingMessages_m.synchronize do
				outgoingMessages << reply
				outgoingMessages_c.signal
			end
		end
	end
end

$stderr.puts "Starting event handling"
EventHandler.setEventHandler outgoingMessages, outgoingMessages_m, outgoingMessages_c

# Sinatra captured ^c, this feels hacky but I haven't investigated better solutions yet
GateAPI.instance.join
$stderr.puts "Joined API"
messageReceiver.kill
messageReceiver.join
$stderr.puts "Joined receiver"
messageProcessor.kill
messageProcessor.join
$stderr.puts "Joined processor"
messageSender.kill
messageSender.join
$stderr.puts "Joined sender"
