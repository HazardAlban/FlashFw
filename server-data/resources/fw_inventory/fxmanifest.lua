fx_version 'cerulean'
game 'gta5'

name        'fw_inventory'
description 'Standalone inventory system for FiveM - No framework required'
version     '1.0.0'
author      'fw_dev'

shared_scripts {
    'shared/items.lua',
    'shared/config.lua',
}

client_scripts {
    'client/main.lua',
    'client/ped_preview.lua',
    'client/camera.lua',
    'client/controls.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/inventory.lua',
    'server/items.lua',
    'server/weapons.lua',
    'server/database.lua',
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/css/inventory.css',
    'ui/css/global.css',
    'ui/js/app.js',
    'ui/js/dragdrop.js',
    'ui/js/hotbar.js',
    'ui/js/utils.js',
    'ui/img/*.png',
    'ui/img/*.svg',
}

lua54 'yes'
