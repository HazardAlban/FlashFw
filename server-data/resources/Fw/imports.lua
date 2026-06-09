-- Fw/imports.lua
if GetCurrentResourceName() == 'Fw' then return end

-- On récupère les données du Core
_Fw = exports['Fw']:GetCoreObject()

-- ========================================================
-- 🛡️ SÉCURITÉ RESTART : Redéfinition locale des Events
-- ========================================================
-- Cela force FiveM à attribuer l'event à la ressource locale (Fw_UI) 
-- et non au Core. Fini les crashs de "function reference" !

_Fw.onReceive = function(eventName, cb)
    RegisterNetEvent(eventName, cb)
end

_Fw.onReceiveWithoutNet = function(eventName, cb)
    RegisterNetEvent(eventName, cb)
end

_Fw.toServer = function(event, ...)
    TriggerServerEvent(_Fw.format(event), ...)
    _Fw.log(("Envoie d'un event au serveur ^6>^1 %s"):format(event))
end

_Fw.toServerExposed = function(event, ...)
    TriggerServerEvent(event, ...)
    _Fw.log(("Envoie d'un event (^1Exposé^7) au serveur ^6>^1 %s"):format(event))
end

_Fw.toClient = function(event, targetSrc, ...)
    TriggerClientEvent(_Fw.format(event), targetSrc, ...)
    _Fw.log(("Envoie d'un event au client (^3%i^7) ^6>^1 %s"):format(targetSrc, event))
end

_Fw.toClients = function(event, ...)
    TriggerClientEvent(_Fw.format(event), -1, ...)
    _Fw.log(("Envoie d'un event aux clients ^6>^1 %s"):format(event))
end

_Fw.serverResponded = function(target)
    _Fw.toClient("serverResponded", target, true)
end

_Fw.toClientExposed = function(event, targetSrc, ...)
    TriggerClientEvent(event, targetSrc, ...)
    _Fw.log(("Envoie d'un event (^1Exposé^7) au client (^3%s^7) ^6>^1 %s"):format(targetSrc, event))
end

_Fw.toInternal = function(eventName, ...)
    TriggerEvent(eventName, ...)
end

-- ========================================================
-- 🚀 INJECTION OX
-- ========================================================
_Fw.Inventory = exports.ox_inventory
_Fw.MySQL = exports.oxmysql
_Fw.Lib = exports.ox_lib