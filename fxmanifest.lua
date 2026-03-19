fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dei'
description 'Tienda de Vehiculos - Dei Ecosystem'
-- Requiere: es_extended o qb-core, oxmysql o mysql-async (si aplica)
version '1.0'

provide 'esx_vehicleshop'

client_scripts {
    'config.lua',
    'client/framework.lua',
    'client/nui.lua',
    'client/main.lua',
}

server_scripts {
    'config.lua',
    'server/framework.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/assets/js/app.js',
    'html/assets/css/themes.css',
    'html/assets/css/styles.css',
    'html/assets/fonts/*.otf',
}

exports {
    'OpenShop',
    'GetVehiclePrice',
}
