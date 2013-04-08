local pop3 = require "pop3"

local some_mail = {
  host     = os.getenv("LUA_MAIL_HOST") or '127.0.0.1';
  username = os.getenv("LUA_MAIL_USER") or 'me@host.local';
  password = os.getenv("LUA_MAIL_PASS") or 'mypassword';
}

local mbox = pop3.new()

mbox:open(some_mail.host, some_mail.port or '110')
print('open   :', mbox:is_open())

mbox:auth(some_mail.username, some_mail.password)
print('auth   :', mbox:is_auth())

for k, msg in mbox:messages() do
  print"----------------------------------------------"
  print("NO:         ", k)
  print("ID:         ", msg:id())
  print("subject:    ", msg:subject())
  print("to:         ", msg:to())
  print("from:       ", msg:from())
  print("from addr:  ", msg:from_address())
  print("reply:      ", msg:reply_to())
  print("reply addr: ", msg:reply_address())
  print("trunc:      ", msg:is_truncated())
  for i,v in ipairs(msg:full_content()) do
    if v.text then  print("  ", i , "TEXT: ", v.type, #v.text)
    else print("  ", i , "FILE: ", v.type, v.file_name or v.name, #v.data) end
  end
end

