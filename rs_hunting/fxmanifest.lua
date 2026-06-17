fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

shared_script "config.lua"

client_scripts {
    '@vorp_core/client/dataview.lua',
    'client.lua',
}

server_script 'server.lua'