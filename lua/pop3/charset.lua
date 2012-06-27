local function pass_thrue(str) return str end
local setmeta = setmetatable
local assert = assert

local function make_iconv(to,from) end

local meta = {__index = function(self, to)
  to = to:lower()
  self[to] = setmeta({},{__index = function(self,from)
    from = from:lower()
    if from == to then
      self[from] = pass_thrue
    else
      self[from] = make_iconv(to,from) or pass_thrue
    end
    return self[from];
  end})
  return self[to]
end;
__call = function(self, to, from)
  return self[to][from]
end;
}

local ok, iconv = pcall( require, "iconv" ) 
if ok then
  make_iconv = function (to,from)
    local c = iconv.new(to,from)
    return c and function(str)
      return c:iconv(str)
    end
  end
end

local function self_test(_M)
  if lunatest and iconv then -- test
    local str_1251 = "ïðèâåò"
    local str_866  = "¯à¨¢¥â"
    function test_pop3_charset()
      assert_true(_M.supported('cp1251','cp866'))
      assert_equal(str_1251, _M.cp1251.cp866(str_866))
      assert_equal(str_1251, _M['cp1251']['cp866'](str_866))
      assert_equal(str_1251, _M('cp1251','cp866')(str_866))
      assert_equal(_M('cp1251','cp866'), _M.cp1251.cp866)
    end
  end
end

module('CP')

function supported(to, from)
  return _M[to][from] ~= pass_thrue
end

function convert(to, from, str)
  return _M[to][from](str)
end

setmeta(_M, meta)

self_test(_M)

return _M
