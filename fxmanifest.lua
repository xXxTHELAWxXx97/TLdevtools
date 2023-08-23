fx_version 'cerulean'
game 'gta5'

name "TLdevtools"
description "A general devtools resource"
author "xXxTHE_LAWxXx97, BigDaddy"
version "1.0.0"
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
	'config/server.lua',
	--'server/autoupdater.js'
}

exports {
	'NewLog',
}

server_exports {
	'NewLog',
	'AceCheck',
}

files { -- Credits to https://github.com/LVRP-BEN/bl_coords for clipboard copy method
    'ui/html/index.html',
    'ui/html/index.js'
}

dependency 'ScaleformUI_Lua'

escrow_ignore 'config/*.lua'