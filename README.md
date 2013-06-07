# oscreplayer - <em>utility to replay OSC messages</em>
originally by {Tom Lieber}[https://github.com/alltom] with modifications by {Mark Cerqueira}[https://github.com/markcerqueira], {Spencer Salazar}[https://github.com/spencersalazar]

## HOW TO
### SETUP
Run *bundle* *install* to get the required gems. We developed this on Ruby version 1.9.3 so you should use at least that. Run <b>ruby --version</b> to check your version of ruby. 

====RECORDING MESSAGES
Recording OSC messages with *oscrecorder* requires specifying the port (--port, -p) to listen for OSC messages on and optionally, specifying a filename (--filename, -f) to write YAML-encoded message data to. If no filename is specified, data is written to stdout. Optionally, if the forward flag (--forward, -o) is defined, messages received will be forwarded to the address of the recorded message and the port + 2 (because you cannot bind two Ruby OSC clients to the same port). Message data is cached and flushed to the file/stdout every 2 seconds and when an interrupt (i.e. SystemExit, Interrupt) is received. Be careful to only send one interrupt (crtl+c only once) because you may interrupt the last flushing of data if you send multiple interrupts.
 
   # grabs OSC messages received on port 4420, writing data to the osc_data.yml file
   $ oscrecorder --port 4420 --filename osc_data.yml

   # grabs OSC messages received on port 6600, writing data to stdout; here we pipe that data into 
   # a hypothetical script, osc_processor, that does real-time processing
   $ oscrecorder -p 6600 > osc_processor

   # grabs OSC messages received on port 6600, writing data to stdout
   # with --forward / -o, messages will be forwarded to the message's original destination,
   # on port 6602 (i.e. 6600 + 2)
   $ oscrecorder -p 6600 --forward

====PLAYING BACK MESSAGES
Playing back OSC messages with *oscplayer* requires specifying the address (--address, -a) and port (--port, -p) to send OSC messages to and optionally:
* A flag (--wait, -w) to specify whether the padding for the initial message - the time from when recording began to when the first message was received - should be respected. If the flag is not passed, the initial time padding is ignored and the first message is sent immediately.
* A string specifying a filename (--filename, -f) to read data from. If no filename is specified, oscrecorder will attempt to load data from stdin.
* A float value (--skip, -s) to skip all messages recorded before the time passed. If the flag/value is not passed, all messages will be sent. Note that the -s and -w can work together - if you skip messages and still want to "wait" the last message ignored will be treated as time 0.

   # parses messages from osc_data.yml, sending them to 127.0.0.1:5200 and respects the initial padding
   # on the first message
   $ oscplayer --address 127.0.0.1 --port 5200 --filename osc_data.yml --wait 
   #
   # or in abbreviated form
   $ oscplayer -a 127.0.0.1 -p 5200 -f osc_data.yml -w 
  
   # parses messages from osc_data.yml (read via stdin), sending them to 127.0.0.1:5400 and ignores the 
   # initial padding on the first message (i.e. starts sending messages immediately)
   $ osc_data.yml | oscplayer -a 127.0.0.1 -p 5400 

   # skips all messages sent before time 60
   # since -w is not passed, the first message sent after time 60 is sent immediately
   $ oscplayer -a 127.0.0.1 -p 5200 -f osc_data.yml -s 60

   # skips all messages sent before time 60
   # since -w is passed, the last packet skipped will be treated as time 0 and the time delta between the
   # last skipped message and the first message to be sent will be respected
   $ oscplayer -a 127.0.0.1 -p 5200 -f osc_data.yml -w -s 60

===MY DESIRES
1. Unit tests!
2. Utility to display data of an encoded file.
3. Utility to decode/re-encode files to allow modifications.
4. GUI a la {Charles Proxy}[http://www.charlesproxy.com/] that allows for real-time recording and playing back with data modifications.

===FAQ
- Help! When I run *oscrecorder* I get this error every time a message is received:
    network_packet.rb:4:in `initialize': undefined method `force_encoding' for #<String:0x10ee199e8> (NoMethodError)

Check your version of ruby. force_encoding is not implemented in Ruby 1.8.

- I set the --forward flag on my oscrecorder, but the messages are not getting forwarded!

Ensure you the listener for forwarded messages is listening on the port the recorder is running on + 2. If your recorder is listening on port 4410, anyone who wants the forwarded messages should listen on 4412. Getting osc-ruby to support the SO_REUSEADDR flag for UDP sockets would let us get around this little dance!

===LICENSE
Tom originally developed this code and goes to MIT so oscreplayer is released under the {MIT License}[http://opensource.org/licenses/MIT]. 
