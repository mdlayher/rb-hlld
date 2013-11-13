rb-hlld
=======

Ruby class for interacting with a hlld server (https://github.com/armon/hlld).  MIT Licensed.

Example
-------

All commands accepted by hlld are implemented in rb-hlld.  Here is a basic example script.

```ruby
# rb-hlld - Example basic usage script
require_relative 'rb-hlld.rb'

# Establish a connection to a local hlld with client
hlld = HlldClient.new("localhost", 4553)
unless hlld.connect()
	puts "example: failed to connect"
	exit
end

# Create a HyperLogLog set
unless hlld.create("ruby")
	puts "example: failed to create HLL set"
	exit
end

# Add some numbers into set
(1..1_000).each do |n|
	hlld.set("ruby", n.to_s())
end

# Bulk add an array of values into set
hlld.bulk("ruby", ["foo", "bar", "baz"])

# Check the approximate cardinality of set
printf("ruby: ~%d\n", hlld.count("ruby"))

# Drop set, disconnect
hlld.drop("ruby")
hlld.disconnect()
```
