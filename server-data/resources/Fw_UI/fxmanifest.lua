-- Generated automaticly by RB Generator.
fx_version('cerulean')
games({ 'gta5' })

shared_script({
    "@Fw/imports.lua",
    "config/global.lua",
});

server_scripts({
    "addons/**/server/*.lua",
});

client_scripts({
    "addons/**/client/*.lua",
});

-- UI resources
ui_page("ui/index.html")
files({
    "ui/web/index.html",
    "ui/css/global.css",
    "ui/js/global.js",

    "ui/css/**/*.css",
    "ui/js/**/*.js",
})