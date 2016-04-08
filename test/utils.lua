local pop3 = require "pop3"
local lunit = require "lunit"
local mime = require "mime"

local assert_equal, assert_not_equal = lunit.assert_equal, lunit.assert_not_equal

DIRSEP = package.config:sub(1,1)

function new_message(...)
  local msg = pop3.message(...)
  msg:set_eol('\r\n')
  msg:set_cp('windows-1251')
  return msg
end

function load_msg_table(t)
  return new_message(t)
end

function load_msg_file(f)
  local m = {}
  local data = assert(read_file(f))
  for str in data:gmatch("(.-)\r?\n") do
    table.insert(m,str)
  end
  return load_msg_table(m)
end

local cmp_t
local function cmp_v(v1,v2)
  local flag = true
  if type(v1) == 'table' then
    flag = (type(v2) == 'table') and cmp_t(v1, v2)
  else
    flag = (v1 == v2)
  end
  return flag
end

function cmp_t(t1,t2)
  for k in pairs(t2)do
    if t1[k] == nil then
      return false
    end
  end
  for k,v in pairs(t1)do
    if not cmp_v(t2[k],v) then 
      return false 
    end
  end
  return true
end

is_equal = cmp_v

function path_join(...)
  local t = {...}
  local result = t[1]
  for i = 2, #t do result = result .. DIRSEP .. t[i] end
  return result
end

function read_file(path)
  local f = assert(io.open(path, 'rb'))
  local str = f:read('*all')
  f:close()
  return str
end

function assert_str_file(str, fname, msg)
  assert_equal(mime.b64(read_file(fname)), mime.b64(str), msg)
end

function assert_not_str_file(str, fname, msg)
  assert_not_equal(str, read_file(fname), msg)
end

function str_line_iter(str, nl)
  return coroutine.wrap(function()
    for line in str:gmatch("(.-)"..nl)do
      coroutine.yield(line)
    end
  end)
end

function file_line_iter(path, nl)
  return str_line_iter(read_file(path),nl)
end

function cmp_lines(it1, it2)
  while true do 
    local line = it1()
    if line ~= it2() then return false end
    if line == nil then return true end
  end
end

local test_server = {
  -- out_buf = {}; -- что нужно послать
  -- in_buf  = {}; -- что должны получить
};

function test_server:receive()
  return table.remove(self.out_buf,1)
end

function test_server:send(stuff)
  local v = table.remove(self.in_buf,1)
  
  if type(v) == 'table' then 
    local i = v[2]
    if type(i) == 'string' then i = {i} end
    for k = #i, 1, -1 do 
      table.insert(self.out_buf,1,i[k])
    end
    v = v[1]
  end
  assert_equal(v, stuff)
  return true
end

function test_server:close() end

function test_server:settimeout() end

function new_test_server(t) 
  return function(host, port)
    return setmetatable({
      out_buf = t.o;
      in_buf  = t.i;
    }, {__index=test_server})
  end
end
