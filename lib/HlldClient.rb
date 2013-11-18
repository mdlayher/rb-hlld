require 'socket'
require 'digest/sha1'

require_relative 'HllSet.rb'

class HlldClient
	# Constants for string responses from hlld
	HLLD_DONE = "Done"
	HLLD_LIST_START = "START"
	HLLD_LIST_END = "END"
	HLLD_SET_NO_EXIST = "Set does not exist"

	# Initializer, set host and port
	def initialize(host, port = 4553)
		@host = host
		@port = port
	end

	# Initiate a connection to hlld server
	def connect
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
	def disconnect
		# Verify socket is actually open
		if @connected
			@socket.close

			@connected = false
			return true
		end

		return false
	end

	# Retrieve an object representing the named set
	def get(name)
		HllSet.new(name, self)
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
		send_msg(buffer) == HLLD_DONE
	end

	# Close an in-memory HLL set on server
	def close(name)
		send_msg("close " + name) == HLLD_DONE
	end

	# Clear an in-memory HLL set on server
	# NOTE: Should only be called after filter is closed
	def clear(name)
		send_msg("clear " + name) == HLLD_DONE
	end

	# Drop a HLL set on server
	def drop(name)
		send_msg("drop " + name) == HLLD_DONE
	end

	# Flush data to disk from a HLL set on server
	def flush(name)
		send_msg("flush " + name) == HLLD_DONE
	end

	# Retrieve a list of HLL sets and their status by matching name, or all filters if none provided
	def list(name = nil)
		if name.nil?
			res = send_msg "list"
		else
			res = send_msg("list " + name)
		end

		# Build response array
		list = []

		# Parse through multi line response
		res.split("\n").each do |line|
			# Convert status into hash by combining arrays
			keys = [:name, :variance, :precision, :size, :items]
			list << Hash[keys.zip(line.split(' '))]
		end

		# Return list
		list
	end

	# Retrieve detailed information about HLL set with specified name
	def info(name)
		# Build response hash
		hash = {}

		# Iterate multi-line response
		send_msg("info " + name).split("\n").each do |line|
			# Split into key/value pairs
			pair = line.split(' ', 2)
			hash[pair[0].to_sym] = pair[1]
		end

		# Return hash
		hash
	end

	# Set an item in a specified HLL set
	# NOTE: value is hashed in order to make long keys a uniform length
	def set(name, value)
		send_msg(sprintf("set %s %s", name, Digest::SHA1.hexdigest(value.to_s))) == HLLD_DONE
	end

	# Set multiple items in HLL set on server
	def bulk(name, items)
		raise "Argument Error: items must be an array" unless items.kind_of? Array
		send_msg(sprintf("bulk %s %s", name, items.map { |i| Digest::SHA1.hexdigest(i.to_s) }.join(' '))) == HLLD_DONE
	end

	# Retrieve the approximate count of items in a given HLL set
	def count(name)
		info(name)[:size]
	end

	private

	# Send a message to server on socket
	def send_msg(input)
		if !@connected || @socket.nil?
			raise "Error: client is not connected to hlld server!"
		end

		# Write message, read reply
		@socket.puts(input + "\n")
		res = @socket.gets.chomp

		# If reply indicates invalid set, return empty string
		if res == HLLD_SET_NO_EXIST
			return ""
		end

		# If reply indicates start of a list, fetch the rest
		if res == HLLD_LIST_START
			res = ""
			while (line = @socket.gets.chomp) != HLLD_LIST_END
				res += line + "\n"
			end
		end

		# Return reply
		res
	end
end
