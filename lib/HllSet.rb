class HllSet
	attr_reader name

	# Initialize with name and an instance of HlldClient
	def initialize(name, client)
		@name = name
		@client = client
	end

	# Allow name to be accessed read-only
	def name()
		@name
	end

	# Delegate undefined methods to HlldClient, passing name as first parameter
	def self.delegate(method)
		define_method(method) do |*args|
			@client.send(method, @name, *args)
		end
	end

	delegate :create
	delegate :close
	delegate :clear
	delegate :drop
	delegate :flush
	delegate :list
	delegate :info
	delegate :set
	delegate :bulk
	delegate :count
end
