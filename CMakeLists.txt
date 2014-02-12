cmake_minimum_required ( VERSION 2.8 )

project ( pop3 NONE )
include ( cmake/dist.cmake )
include ( lua )

install_lua_module ( pop3.win.cp  lua/pop3/win/cp.lua  )
install_lua_module ( pop3         lua/pop3.lua         )
install_lua_module ( pop3.charset lua/pop3/charset.lua )
install_lua_module ( pop3.message lua/pop3/message.lua )

install_data ( README.md LICENCE.txt )
install_test ( test/ )
install_example( examples/ )