require 'socket'

class HlldClient
	# Constants for string responses from hlld
	HLLD_DONE = "Done"

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

	# Create a HLL set on server
	# TODO: named parameters to specify either precision OR epsilon.  For now, just precision.
	def create(name, precision = nil, in_memory = nil)
		# Begin building command to send to server
		buffer = "create " + name + " "

		# If specified, send precision
		if precision.nil? and precision.is_a? Float
			buffer += "precision= " + precision + " "
		end

		# If specified, choose if set should reside in memory
		if in_memory.nil? and !!in_memory == in_memory
			buffer += "in_memory=" + in_memory ? 1 : 0
		end

		# Send create set request to server, verify done
		send(buffer) == HLLD_DONE
	end

	# Close an in-memory HLL set on server
	def close(name)
		send("close " + name) == HLLD_DONE
	end

	# Clear an in-memory HLL set on server
	# NOTE: Should only be called after filter is closed
	def clear(name)
		send("clear " + name) == HLLD_DONE
	end

	# Drop a HLL set on server
	def drop(name)
		send("drop " + name) == HLLD_DONE
	end

	# Flush data from a HLL set on server
	def flush(name)
		send("flush " + name) == HLLD_DONE
	end

	# DANGER: Flush data from ALL HLL sets on server
	def flush_all()
		send("flush") == HLLD_DONE
	end

	private

	# Send a message to server on socket
	def send(input)
		if !@connected || @socket.nil?
			raise "Error: client is not connected to hlld server!"
		end

		# Write message, read reply
		@socket.puts(input + "\n")
		response = @socket.gets.chomp()
	end
end
