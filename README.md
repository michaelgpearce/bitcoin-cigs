# Bitcoin Cigs - Smokin' Hot Bitcoin Signatures

## Installation

    gem install bitcoin-cigs

## Examples

Verify a message signature:
```ruby
require 'rubygems'
require 'bitcoin-cigs'

address = "13C5HZKutjMDeuc7f5mPj6XGpJCZu7xKh2"
signature = "H55JIuwEi4YXzINOzx2oU6VsfBcTOScpFtp10pP/M4EWV336ClH65SObwPXnRf/fMXDu8hs8nweB42CtpWgngeM="
message = "aaa"

if BitcoinCigs.verify_message(address, signature, message)
  puts "It looks like you own address #{address}!"
end
```

# Credits

Thanks to jackjack for pointing me to Armory's implementation of message signatures:
https://github.com/jackjack-jj/jasvet/blob/master/jasvet.py

[Bitcoin Cigs](https://github.com/michaelgpearce/bitcoin-cigs) is maintained by [Michael Pearce](https://github.com/michaelgpearce).

# Copyright

Copyright (c) 2013 Michael Pearce. See LICENSE.txt for further details.

