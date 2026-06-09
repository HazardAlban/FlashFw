-- Fw/imports.lua
if GetCurrentResourceName() == 'Fw' then return end

_Fw = exports['Fw']:GetCoreObject()

-- ========================================================
-- 🛡️ SÉCURITÉ RESTART : Redéfinition locale avec Format Fw
-- ========================================================
_Fw.onReceive = function(eventName, cb)
    RegisterNetEvent(_Fw.format(eventName), cb)
end

_Fw.toServer = function(eventName, ...)
    TriggerServerEvent(_Fw.format(eventName), ...)
end

_Fw.toClient = function(eventName, target, ...)
    TriggerClientEvent(_Fw.format(eventName), target, ...)
end

_Fw.toInternal = function(eventName, ...)
    TriggerEvent(_Fw.format(eventName), ...)
end

-- ========================================================
-- 🚀 INJECTION OX
-- ========================================================
_Fw.Inventory = exports.ox_inventory
_Fw.MySQL = exports.oxmysql
_Fw.Lib = exports.ox_lib