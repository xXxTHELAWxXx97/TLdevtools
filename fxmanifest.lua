fx_version 'cerulean'
game 'gta5'

name "TLdevtools"
description "A general devtools resource"
author "xXxTHE_LAWxXx97, BigDaddy"
version "0.0.1"
lua54 'yes'

shared_scripts {
	'config/main.lua',
	'shared/*.lua'
}

client_scripts {
	'@ScaleformUI_Lua/ScaleformUI.lua',
	'client/*.lua',
}

server_scripts {
	'server/*.lua',
	'config/serverconfig.lua'
}

exports {
	'NewLog',
}

server_exports {
	'NewLog',
	'AceCheck',
}

dependency 'ScaleformUI_Lua'

escrow_ignore 'config/*.lua'