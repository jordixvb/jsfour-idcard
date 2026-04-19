fx_version 'cerulean'
game 'gta5'

author 'JSFOUR (Refactored by TempestaRP)'
description 'Modern Identity Card System'
version '2.0.0'

ui_page 'html/index.html'

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
    'html/assets/fonts/**/*.woff',
    'html/assets/fonts/**/*.woff2',
    'html/assets/images/*.png'
}

dependencies {
    'es_extended',
    'esx_license'
}