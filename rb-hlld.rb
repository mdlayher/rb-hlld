require 'socket'

class HlldClient
	# Initializer, set host and port
	def initialize(host, port = 4553)
		@host = host
		@port = port
	end

	# Initiate a connection to hlld server
	def connect()
		if @connected
			return false
		end

		# Create a TCP socket connection
		begin
			@socket = TCPSocket.open(@host, @port)
		rescue
			return false
		end

		@connected = true
	end

	# Close a connection to hlld server
	def disconnect()
		# Verify socket is actually open
		if @connected
			@socket.close()

			@connect = false
			return true
		end

		return false
	end
end
