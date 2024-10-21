-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

author 'ZeRwYX Script\'s'
description 'Gestion des coffres avec ox_inventory et MySQL-async'
version '1.0.1'

resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua' 
}

client_scripts {
    'client/client.lua',
    'config.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua', 
    'server/server.lua',
    'config.lua'
}

dependencies {
    'es_extended',    
    'mysql-async',      
    'ox_inventory',     
    'ox_target'    
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

shared_script '@es_extended/imports.lua'