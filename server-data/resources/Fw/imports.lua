-- Fw/imports.lua
if GetCurrentResourceName() == 'Fw' then return end

_Fw = exports['Fw']:GetCoreObject()

-- Injection de la suite Ox
_Fw.Inventory = exports.ox_inventory
_Fw.MySQL = exports.oxmysql
_Fw.Lib = exports.ox_lib