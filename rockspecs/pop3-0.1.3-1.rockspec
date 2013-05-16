package = "pop3"
version = "0.1.3-1"
source = {
  url = "https://github.com/moteus/lua-pop3/archive/v0.1.3.zip",
  dir = "lua-pop3-0.1.3",
}

description = {
  summary = "Simple POP3 client library for Lua 5.1/5.2",
  homepage = "https://github.com/moteus/lua-pop3",
  license  = "MIT/X11",
}

dependencies = {
  "lua >= 5.1",
  "luasocket >= 2.0",
  -- "lua-iconv >= 7.0",  -- optional
  -- "lua-crypto >= 0.2", -- optional
  -- "lpeg >= 0.9",       -- optional
  -- "alien >= 0.7.0",    -- optional on windows
}

build = {
  type = "builtin",
  copy_directories = {"test", "examples"},

  platforms = {
    windows = {
      modules = {
        ["pop3.win.cp"]  = "lua/pop3/win/cp.lua",
      }
    }
  },

  modules = {
    ["pop3" ]        = "lua/pop3.lua",
    ["pop3.charset"] = "lua/pop3/charset.lua",
    ["pop3.message"] = "lua/pop3/message.lua",
  }
}



