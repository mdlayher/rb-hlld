class HllSet
	attr_reader name

	def initialize(name, client)
		@name = name
		@client = client
	end

	def name()
		@name
	end

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
