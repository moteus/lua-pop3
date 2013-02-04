package = "pop3"
version = "0.1.0-1"
source = {
  url = "https://github.com/moteus/lua-pop3/archive/v0.1.0.zip",
  dir = "lua-pop3-0.1.0",
}

description = {
  summary = "Simple pop3 library",
  detailed = [[
  ]],
  homepage = "https://github.com/moteus/lua-pop3",
  -- license = ""
}

dependencies = {
  "lua >= 5.1",
  "luasocket >= 2.0",
  -- "lua-iconv >= 7.0",  -- optional
  -- "lua-crypto >= 0.2", -- optional
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



