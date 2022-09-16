fx_version "adamant"

description "EyesStore"
author "Raider#0101"
version '1.0.0'
repository 'https://discord.com/invite/EkwWvFS'

game "gta5"

client_script { 
"main/client.lua"
}

server_script {
'@mysql-async/lib/MySQL.lua',
"main/server.lua",
} 

shared_script "main/shared.lua"


ui_page "index.html"

files {
    'index.html',
    'vue.js',
    'assets/**/*.*',
    'assets/font/*.otf',  
	'assets/font/Mark_Simonson_Proxima_Nova_Extra_Condensed_Light_Italic_TheFontsMaster.com.otf',
    'assets/font/Mark_Simonson_Proxima_Nova_Condensed_Light_Italic_TheFontsMaster.com.otf',  
    'assets/font/Mark_Simonson_Proxima_Nova_Condensed_Thin_TheFontsMaster.com.otf',
}

escrow_ignore { 'main/shared.lua' }

lua54 'yes'
-- dependency '/assetpacks'