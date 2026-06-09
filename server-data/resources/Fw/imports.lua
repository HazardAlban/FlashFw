-- Fw/imports.lua
if GetCurrentResourceName() == 'Fw' then return end

_Fw = {}

-- Métatable pour rediriger automatiquement vers les exports du Core
setmetatable(_Fw, {
    __index = function(self, key)
        return exports['Fw'][key]()
    end
})

-- On injecte directement la suite Ox pour un accès ultra-rapide partout
_Fw.Lib = exports.ox_lib
_Fw.Inventory = exports.ox_inventory
_Fw.MySQL = exports.oxmysql