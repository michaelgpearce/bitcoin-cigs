# Bitcoin Cigs - Smokin' Hot Bitcoin Signatures

## Installation

    gem install bitcoin-cigs

## Examples

Sign a message:
```ruby
require 'rubygems'
require 'bitcoin-cigs'

# Support for Wallet Import Format, Compressed WIF, Mini Format, Hex and Base64 wallets
wallet_key = "5JFZuDkLgbEXK4CUEiXyyz4fUqzAsQ5QUqufdJy8MoLA9S1RdNX"
message = "this is a message"

puts "The signature is: #{BitcoinCigs.sign_message!(wallet_key, message)}"
```

Verify a message signature:
```ruby
require 'rubygems'
require 'bitcoin-cigs'

address = "11o51X3ciSjoLWFN3sbg3yzCM8RSuD2q9"
signature = "HIBYi2g3yFimzD/YSD9j+PYwtsdCuHR2xwIQ6n0AN6RPUVDGttgOmlnsiwx90ZSjmaWrH1/HwrINJbaP7eMA6V4="
message = "this is a message"

if BitcoinCigs.verify_message(address, signature, message)
  puts "It looks like you own address #{address}!"
end
```

A command line client is also included:
```sh
~ $ bitcoin-cigs 
Usage: bitcoin-cigs command [arguments ...] [options ...]

Commands
     verify bitcoin-address signature [message-file]
     sign private-key [message-file]

Options
    -m, --message MESSAGE            Message can also be read from STDIN
    -S, --no-strip                   Do not strip leading and trailing whitespace from message (stripped by default)
```

# Credits

Thanks to jackjack for pointing me to Armory's implementation of message signatures:
https://github.com/jackjack-jj/jasvet

[Bitcoin Cigs](https://github.com/michaelgpearce/bitcoin-cigs) is maintained by [Michael Pearce](https://github.com/michaelgpearce).

# Copyright

Copyright (c) 2013 Michael Pearce. See LICENSE.txt for further details.

