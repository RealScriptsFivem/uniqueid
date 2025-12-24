fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Madechester'
description 'SSN System'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'utils.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

client_scripts {
    'client.lua',
}
