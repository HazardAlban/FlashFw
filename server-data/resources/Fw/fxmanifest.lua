-- Generated automaticly by RB Generator.
fx_version('cerulean')
games({ 'gta5' })

shared_script({
    -- Config
    "config/global.lua",
    -- Imports
    "imports.lua",
    -- Enum
    "src/class/enum/*.lua",
    -- Objects
    "src/class/type/shared/*.lua",
    -- Init
    "src/core/shared/utils/*.lua",
    "src/core/shared/main.lua",
    -- Modules
    "src/components/**/shared/*.lua",
});

server_scripts({
    -- Server
    "@oxmysql/lib/MySQL.lua",
    -- Config
    "config/server.lua",
    -- Objects
    "src/class/type/server/*.lua",
    -- Init
    "src/core/server/utils/*.lua",
    "src/core/server/main.lua",
    -- Modules
    "src/components/**/server/*.lua",
});

client_scripts({
    -- Config
    "config/client.lua",
    -- Objects
    "src/class/type/client/*.lua",
    -- Init
    "src/core/client/utils/*.lua",
    "src/core/client/main.lua",
    -- Modules
    "src/components/**/client/*.lua",
});