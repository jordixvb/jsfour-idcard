fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'jsfour-idcard'
author 'JSFOUR / maintained fork'
description 'Fork of jsfour-idcard updated for ESX Legacy, oxmysql, configurable license labels and optional MugShotBase64.'
version '1.1.0-fork'

ui_page 'html/index.html'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

client_scripts {
    'client.lua'
}

files {
    'html/index.html',
    'html/assets/css/*.css',
    'html/assets/js/*.js',
    'html/assets/fonts/roboto/*.woff',
    'html/assets/fonts/roboto/*.woff2',
    'html/assets/fonts/justsignature/JustSignature.woff',
    'html/assets/images/*.png'
}

dependencies {
    'es_extended',
    'oxmysql'
}
