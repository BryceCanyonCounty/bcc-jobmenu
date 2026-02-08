fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game 'rdr3'
lua54 'yes'
author 'SavSin'
description 'Simple Job Menu'

client_scripts {
    'client/client_init.lua',
    'client/menu.lua',
    'client/main.lua'
}

shared_scripts {
    'configs/*.lua',
    'locale.lua',
    'languages/*.lua'
}

server_scripts {
    'server/server_init.lua',
    'server/main.lua'
}

dependencies {
    'vorp_core',
    'feather-menu'
}

version '2.1.0'