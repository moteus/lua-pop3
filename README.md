lua-pop3
============
##Build status##
[![Build Status](https://travis-ci.org/moteus/lua-pop3.png?branch=master)](https://travis-ci.org/moteus/lua-pop3)
[![Coverage Status](https://coveralls.io/repos/moteus/lua-pop3/badge.png)](https://coveralls.io/r/moteus/lua-pop3)

POP3 client library for Lua 5.1 / 5.2

##Dependences##
* [LuaSocket](http://www.impa.br/~diego/software/luasocket)

###Decode text headers/content###
* [iconv](http://ittner.github.com/lua-iconv)

###Parse from/to/reply headers###
* [lpeg](http://www.inf.puc-rio.br/~roberto/lpeg)

###MD5 modules###
* [lmd5](http://www.tecgraf.puc-rio.br/~lhf/ftp/lua/#lmd5)
* or [md5](http://www.keplerproject.org/md5/index.html)

###APOP auth###
* [lua-crypto](http://luacrypto.luaforge.net)
* or one of MD5 modules.

###CRAM MD5 auth###
* [lua-crypto](http://luacrypto.luaforge.net)
* or one of MD5 modules and bit library.

###Detect current codepage on Windows###
* [alien](http://mascarenhas.github.io/alien)
* or [FFI](https://github.com/jmckaskill/luaffi)

## Usage ##

```lua
local pop3 = require "pop3"

local some_mail = {
  host     = os.getenv("LUA_MAIL_HOST") or '127.0.0.1';
  username = os.getenv("LUA_MAIL_USER") or 'me@host.local';
  password = os.getenv("LUA_MAIL_PASS") or 'mypassword';
}

local function print_msg(msg, indent)
  indent = indent or ''
  print(indent .. "----------------------------------------------")
  print(indent .. "ID:         ", msg:id())
  print(indent .. "subject:    ", msg:subject())
  print(indent .. "to:         ", msg:to())
  print(indent .. "from:       ", msg:from())
  print(indent .. "from addr:  ", msg:from_address())
  print(indent .. "reply:      ", msg:reply_to())
  print(indent .. "reply addr: ", msg:reply_address())
  print(indent .. "trunc:      ", msg:is_truncated())
  for i,v in ipairs(msg:full_content()) do
    if v.text        then  print(indent .. "  ", i , "TEXT  : ", v.type, #v.text)
    elseif v.data    then  print(indent .. "  ", i , "FILE  : ", v.type, v.disposition, v.file_name or v.name, #v.data)
    elseif v.message then  print(indent .. "  ", i , "RFC822: ", v.type, v.disposition, v.file_name or v.name)
      print_msg(v.message, indent .. '\t\t\t')
    end
  end
end

local mbox = pop3.new()

mbox:open(some_mail.host, some_mail.port or '110')
print('open   :', mbox:is_open())

mbox:auth(some_mail.username, some_mail.password)
print('auth   :', mbox:is_auth())

for k, msg in mbox:messages() do
  print(string.format("   *** MESSAGE NO %d ***", k))
  print_msg(msg)
end
```

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/moteus/lua-pop3/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

