rb-hlld
=======

Ruby class for interacting with a hlld server (https://github.com/armon/hlld).  MIT Licensed.

Example
-------

All commands accepted by hlld are implemented in rb-hlld.  Here is a basic example script.

```ruby
# rb-hlld - Example basic usage script
require_relative 'lib/HlldClient.rb'

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

# Create a set object to use more concise, object-oriented interface
set = hlld.get("ruby")

# Add some numbers into set
(1..500).each do |n|
	hlld.set("ruby", n.to_s())
end

# Add some numbers into set using HllSet interface
# Either method may be used for all functions which accept a set name as first parameter
(501..1000).each do |n|
	set.set(n.to_s())
end

# Bulk add an array of values into set
set.bulk(["foo", "bar", "baz"])

# Check the approximate cardinality of set
printf("%s: ~%d\n", set.name(), set.count())

# Drop set, disconnect
set.drop()
hlld.disconnect()
```
