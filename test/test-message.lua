local HAS_RUNNER = not not lunit

print("------------------------------------")
print("Lua version: " .. (_G.jit and _G.jit.version or _G._VERSION))
print("------------------------------------")
print("")

POP3_SELF_TEST = true
local lunit = require "lunit"
local pop3  = require "pop3"
local charset = require "pop3.charset"

local IS_LUA52 = (_VERSION >= 'Lua 5.2')

local skip      = lunit.skip or function (msg) return function() lunit.fail("#SKIP: " .. msg) end end
local TEST_CASE = function (name)
  if not IS_LUA52 then
    module(name, package.seeall, lunit.testcase)
    setfenv(2, _M)
  else
    return lunit.module(name, 'seeall')
  end
end

require "utils"

local _ENV = TEST_CASE"pop3 internal test"

function test_pop3_charset()
  if charset.pass_thrue_only() then
    return skip("you must install iconv library to support charset encoding")
  end

  local str_1251 = "ïðèâåò"
  local str_866  = "¯à¨¢¥â"
  assert_true(charset.supported('cp1251','cp866'))
  assert_equal(str_1251, charset.cp1251.cp866(str_866))
  assert_equal(str_1251, charset['cp1251']['cp866'](str_866))
  assert_equal(str_1251, charset('cp1251','cp866')(str_866))
  assert_equal(charset('cp1251','cp866'), charset.cp1251.cp866)
end

function test_pop3_message()
  local msg = pop3.message{}
  if not msg.from_list then
    return skip("you must install lpeg.re library to support parsing from/to/reply headers")
  end

  test_pop3_messege_get_address_list()
end

local _ENV = TEST_CASE"pop3"

function test_interface()
  local mbox = assert(pop3.new())
  assert_function(mbox.set_connect_fn)
  assert_function(mbox.open)
  assert_function(mbox.open_with)
  assert_function(mbox.close)
  assert_function(mbox.is_open)
  assert_function(mbox.is_auth)
  assert_function(mbox.has_apop)
  assert_function(mbox.auth)
  assert_function(mbox.stat)
  assert_function(mbox.noop)
  assert_function(mbox.dele)
  assert_function(mbox.rset)
  assert_function(mbox.list)
  assert_function(mbox.uidl)
  assert_function(mbox.retr)
  assert_function(mbox.top)
  assert_function(mbox.capa)
  assert_function(mbox.retrs)
  assert_function(mbox.tops)

  -- assert_function(mbox.auth_apop)
  -- assert_function(mbox.auth_plain)
  -- assert_function(mbox.auth_login)
  -- assert_function(mbox.auth_cmd5)

  assert_function(mbox.message)
  assert_function(mbox.messages)
end

local _ENV = TEST_CASE"Test message convert"

function test_interface()
  local file_dir = path_join('tests','test1')
  local msg = load_msg_file(path_join(file_dir, 'test.eml'))
  assert_function(msg.type)
  assert_function(msg.type)
  assert_function(msg.set_cp)
  assert_function(msg.set_eol)
  assert_function(msg.cp)
  assert_function(msg.eol)
  assert_function(msg.hvalue)
  assert_function(msg.hparam)
  assert_function(msg.header)
  assert_function(msg.subject)
  assert_function(msg.from)
  assert_function(msg.to)
  assert_function(msg.reply_to)
  assert_function(msg.as_string)
  assert_function(msg.as_table)
  assert_function(msg.id)
  assert_function(msg.date)
  assert_function(msg.encoding)
  assert_function(msg.charset)
  assert_function(msg.content_name)
  assert_function(msg.file_name)
  assert_function(msg.disposition)
  assert_function(msg.is_application)
  assert_function(msg.is_text)
  assert_function(msg.is_truncated)
  assert_function(msg.is_multi)
  assert_function(msg.is_data)
  assert_function(msg.is_binary)
  assert_function(msg.is_attachment)
  assert_function(msg.for_each)
  assert_function(msg.decode_content)
  assert_function(msg.full_content)
  assert_function(msg.attachments)
  assert_function(msg.objects)
  assert_function(msg.text)

  -- assert_function(msg.from_list)
  -- assert_function(msg.to_list)
  -- assert_function(msg.reply_list)
  -- assert_function(msg.from_address)
  -- assert_function(msg.to_address)
  -- assert_function(msg.reply_address)
end

function test_message_1()
  local file_dir = path_join('tests','test1')
  local msg = load_msg_file(path_join(file_dir, 'test.eml'))

  -- quoted-printable text
  -- base64 objects
  -- eol
  
  assert_equal(msg:charset(), 'windows-1251')
  assert_equal(msg:subject(), 'Äëÿ ñëóæáû ïåðñîíàëà (Êîíôåðåíöèÿ)')
  assert_equal(msg:from(), '"HR Capital" <dimitry@hr-capital.ru>')
  assert_equal(msg:to(), '"info" <info@some.mail.domain.ru>')

  assert_equal(#msg:text(), 2)
  assert_str_file( msg:text()[1].text, path_join(file_dir, 'text.txt') , 'quoted-printable decoding text/plain')
  assert_str_file( msg:text()[2].text, path_join(file_dir, 'text.html'), 'quoted-printable decoding text/html')

  assert_equal(#msg:objects(), 4, 'number of binary objects')
  assert_equal(#msg:attachments(), 1, 'number of attachment files')

  for _, attach in ipairs( msg:objects() ) do
    assert_str_file(attach.data, path_join(file_dir, attach.file_name), 'base64 binary :' .. attach.file_name )
  end

  -- set the end-of-line marker to UNIX
  msg:set_eol('\n')
  assert_equal(msg:eol(), '\n')
  -- now text does not equal ...
  assert_not_str_file( msg:text()[1].text, path_join(file_dir, 'text.txt') , 'quoted-printable decoding text/plain with different eol')
  assert_not_str_file( msg:text()[2].text, path_join(file_dir, 'text.html'), 'quoted-printable decoding text/html with different eol')

  assert_true(cmp_lines(
    str_line_iter(msg:text()[1].text, msg:eol()),
    file_line_iter(path_join(file_dir, 'text.txt'), '\r\n')
  ))
  assert_true(cmp_lines(
    str_line_iter(msg:text()[2].text, msg:eol()),
    file_line_iter(path_join(file_dir, 'text.html'), '\r\n')
  ))
  -- but binary still equal
  for _, attach in ipairs( msg:objects() ) do
    assert_str_file(attach.data, path_join(file_dir, attach.file_name), 'base64 binary :' .. attach.file_name )
  end


end

function test_message_1_charset_encode()
  local file_dir = path_join('tests','test1')
  local msg = load_msg_file(path_join(file_dir, 'test.eml'))

  if charset.pass_thrue_only() then
    return skip("you must install iconv library to support charset encoding")
  end

  -- change output code page
  msg:set_cp("866")
  assert_equal(msg:subject(), '„«ï á«ã¦¡ë ¯¥àá®­ «  (Š®­ä¥à¥­æ¨ï)', 'work only with iconv')
end

function test_message_1_parse_lists()
  local file_dir = path_join('tests','test1')
  local msg = load_msg_file(path_join(file_dir, 'test.eml'))

  if not msg.from_list then
    return skip("you must install lpeg.re library to support parsing from/to/reply headers")
  end

  assert_true(is_equal(msg:from_list(), 
    {{name='"HR Capital"';addr='dimitry@hr-capital.ru'}}
  ), 'from list' )
  assert_true(is_equal(msg:to_list(), 
    {{name='"info"';addr='info@some.mail.domain.ru'}}
  ), 'to list' )
  assert_nil(msg:reply_list())
  assert_true(is_equal({msg:from_address()}, {msg:reply_address()}), 'if replay nil then replay - from')
end

function test_message_2()
  local file_dir = path_join('tests','test2')
  local msg = load_msg_file(path_join(file_dir, 'test.eml'))
  -- plain text
  -- plain html
  -- multiple headers
  -- header vlues and params

  assert_equal( msg:charset(), msg:cp())
  assert_true ( msg.content.is_multi)
  assert_equal( msg.content:parts(), 2)
  if IS_LUA52 then assert_equal ( #msg.content, 2) end
  assert_equal( msg.content[1]:charset(), "utf-8")
  assert_equal( msg.content[2]:charset(), "utf-8")
  assert_equal( msg.content[1]:type(), "text/plain")
  assert_equal( msg.content[2]:type(), "text/html")
  msg:set_cp("utf-8")

  assert_equal( #msg:text(), 2 )
  assert_str_file( msg:text()[1].text,  path_join(file_dir, 'text.txt') , 'plain text/plain')
  assert_str_file( msg:text()[2].text,  path_join(file_dir, 'text.html'), 'plain text/html')
  assert_equal( #msg.headers:headers('received'), 7)
  assert_nil( msg.headers:value('SOME_HEADER_THAT_DOES_NOT_EXISTS'))
  assert_equal( msg.headers:value('x-spam-flag2999'), 'NO', 'get header value')
  assert_equal( msg.headers:value('x-spam-flag2999'), msg.headers:value('X-SPAM-FLAG2999'), 'header name case sensyvity')
  assert_equal( msg.headers:param('content-type', 'boundary'), "b1_aea1838717659e8f3203cc99e1406622", 'get header param via headers')
  assert_equal( msg.headers:header('content-type'):param('boundary'), "b1_aea1838717659e8f3203cc99e1406622", 'get header param via header')
  assert_equal( msg.headers:header('content-type'), msg:header('content-type'), 'get header via mime')
end

local _ENV = TEST_CASE"Test pop3 protocol"

function test_pop3_cmd()
  local test_session = {
    o = {"+OK POP"};
    i = {
      {"CMD 1\r\n";"+OK"};
      {"CMD 2\r\n";"+"};
      {"CMD 3\r\n";"-ERR"};
      {"CMD 4\r\n";"-"};
      {"CMD 5\r\n";"ERR"};
      {"CMD 6\r\n";"OK"};
      {"QUIT\r\n";"+OK"};
    };
  }

  local mbox = pop3.new(new_test_server(test_session))
  mbox:open('127.0.0.1', '110')
  assert_true (mbox:cmd("CMD 1"))
  assert_true (mbox:cmd("CMD 2"))
  assert_false(mbox:cmd("CMD 3"))
  assert_false(mbox:cmd("CMD 4"))
  assert_nil  (mbox:cmd("CMD 5"))
  assert_nil  (mbox:cmd("CMD 6"))
  assert_error(function() mbox:stat() end)
  assert_true (mbox:close())
end

function test_pop3_auth()
  local test_session = {
    o = {"+OK POP"};
    i = {
      {"USER username\r\n";"+OK password, please."};
      {"PASS password\r\n";"+OK 10 51511"};
      {"QUIT\r\n";"+OK"};
    };
  }

  local mbox = pop3.new(new_test_server(test_session))
  assert_error( function () mbox:auth('username','password') end )
  assert_true ( mbox:open())
  assert_error( function () mbox:stat() end )
  assert_true ( mbox:auth('username','password') )
  assert_true ( mbox:is_auth() )
  assert_error( function () mbox:auth('username','password') end )

end

function test_pop3_auth_apop()
  local test_session = {
    o = {"+OK POP3 server ready <1896.697170952@dbc.mtview.ca.us>"};
    i = {
      {"APOP mrose c4c9334bac560ecc979e58001b3e22fb\r\n";
      "+OK maildrop has 1 message (369 octets)"};
    };
  }

  local mbox = pop3.new(new_test_server(test_session))
  if not mbox.auth_apop then
    return skip("you must install one of this libraries to support auth_apop: LuaCrypto, lmd5 or md5")
  end

  assert_true ( mbox:open())
  assert_true ( mbox:auth_apop('mrose','tanstaaf') )

end

function test_pop3_auth_cmd5()
  -- RFC 2195
  local test_session = {
    o = {"+OK POP3 server ready <1896.697170952@dbc.mtview.ca.us>"};
    i = {
      {"AUTH CRAM-MD5\r\n"; "+ PDE4OTYuNjk3MTcwOTUyQHBvc3RvZmZpY2UucmVzdG9uLm1jaS5uZXQ+"};
      {"dGltIGI5MTNhNjAyYzdlZGE3YTQ5NWI0ZTZlNzMzNGQzODkw\r\n"; "+OK 16 messages (26210 bytes)"};
    };
  }

  local mbox = pop3.new(new_test_server(test_session))
  if not mbox.auth_cmd5 then
    return skip(
      "you must install this libraries to support auth_cmd5: \n"
      .. "    - socket.mime or base64 to support base64 encoding\n"
      .. "    - LuaCrypto, lmd5 or md5 to support md5 encoding\n"
      .. "    - LuaCrypto, bit or bit32 to support md5 hmac encoding"
    )
  end
  assert_true ( mbox:open())
  assert_true ( mbox:auth_cmd5('tim','tanstaaftanstaaf') )
end

function test_pop3_capa()
  local test_session = {
    o = {"+OK POP Ya! v1.0.0na@2 <IbeYKj57Sa61>"};
    i = {
      {"CAPA\r\n";{"+OK Capability list follows";
        "SASL LOGIN PLAIN CRAM-MD5 DIGEST-MD5 GSSAPI MSN NTLM";
        "STLS";
        "TOP";
        "USER";
        "LOGIN-DELAY 60";
        "PIPELINING";
        "EXPIRE NEVER";
        "UIDL";
        "RESP-CODE";
        "AUTH-RESP-CODE";
        "IMPLEMENTATION Yandex";
        "STLS";
        ".";
      }};
      {"QUIT\r\n";"+OK shutting down.";}
    };
  }

  local mbox = pop3.new(new_test_server(test_session))
  mbox:open('127.0.0.1', '110')
  assert_true(mbox:is_open(), 'connect to server')
  assert_true(mbox:has_apop(), 'server support apop')
  assert_false(mbox:is_auth())
  local capa_list = mbox:capa()
  assert_true(is_equal(capa_list, {
    EXPIRE = "NEVER", APOP = true, USER = true,
    UIDL = true, TOP = true, STLS = true, PIPELINING = true, 
    ["RESP-CODE"] = true, ["AUTH-RESP-CODE"] = true,
    IMPLEMENTATION = "Yandex", ["LOGIN-DELAY"] = "60",
    SASL = {
      LOGIN = true; PLAIN = true;  MSN = true; GSSAPI = true; 
      ["DIGEST-MD5"] = true; ["CRAM-MD5"] = true; NTLM = true;
    }
  }),'capa list')
  assert_true(mbox:close())

  local test_session = {
    o = {"+OK POP Ya! v1.0.0na@2 IbeYKj57Sa61"};
    i = {
      {"CAPA\r\n";"-ERR Invalid command in current state."};
    }
  }

  local mbox = pop3.new(new_test_server(test_session))
  assert_true( mbox:open('127.0.0.1', '110') )
  assert_false( mbox:has_apop() )
  local ok, err = mbox:capa()
  assert_nil( ok )
  assert_equal(' Invalid command in current state.', err)
end

if not HAS_RUNNER then lunit.run() end
