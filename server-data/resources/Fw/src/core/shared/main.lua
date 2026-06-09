

---@type table<string, boolean>
local registredEvents = {}

---registerEvent
---@param event string
---@return nil
---@public
local function registerEvent(event)
    RegisterNetEvent(event)
    table.insert(registredEvents, event)
end

---isEventRegistred
---@param event string
---@return boolean
---@public
local isEventRegistred = function(event)
    for _, eventName in pairs(registredEvents) do
        if (eventName == event) then
            return true
        end
    end
    return false
end

_Fw.toInternal = function(event, ...)
    _Fw.log(("Envoie d'un event interne ^6>^3 %s^7"):format(event))
    TriggerEvent(_Fw.format(event), ...)
end

_Fw.toInternalExposed = function(event, ...)
    _Fw.log(("Envoie d'un event interne ^6>^3 %s^7"):format(event))
    TriggerEvent(event, ...)
end

_Fw.onReceive = function(event, handler)
    local baseEvent = event
    event = _Fw.format(event)
    if (not (isEventRegistred(event))) then
        registerEvent(event)
    end
    --AddEventHandler(event, handler)
    AddEventHandler(event, function(...)
        local _src, isServer = source, (GetGameName() == "fxserver")
        _Fw.log(isServer and ("Réception d'un event client (^3%s^7) ^6>^2 %s"):format(_src, baseEvent) or (("Réception d'un event serveur ^6>^2 %s"):format(baseEvent)))
        handler(...)
    end)
end

_Fw.onReceiveExposed = function(event, handler)
    if (not (isEventRegistred(event))) then
        registerEvent(event)
    end
    AddEventHandler(event, handler)
end

_Fw.onReceiveWithoutNetExposed = function(event, handler)
    AddEventHandler(event, handler)
end

_Fw.onReceiveWithoutNet = function(event, handler)
    event = _Fw.format(event)
    AddEventHandler(event, handler)
end

_Fw.hash = function(string)
    return GetHashKey(string)
end

_Fw.format = function(string)
    return ("FL_%s"):format(GetHashKey(string))
end

_Fw.log = function(string)
    if (_Config.environment == _FwEnum_ENV.DEV) then
        print(("%s %s^7"):format(_Config.prefix, string))
    end
end

_Fw.logOverall = function(string)
    print(("%s %s^7"):format(_Config.prefix, string))
end

_Fw.sql = function(query)
    if (_Config.enableSqlLog) then
        print(("%s ^0%s^7"):format("[^5MySQL^7]", query))
    end
end

_Fw.err = function(string)
    if (_Config.enableErrorsLog) then
        print(("[^1Erreur^7] %s^7"):format(string))
        local isServer = GetGameName() == "fxserver"
        if (isServer) then
            _Fw.toInternal("errorCatcher:report", string)
        end
    end
end

_Fw.suc = function(string)
    print(("[^2Succes^7] %s^7"):format(string))
end

_Fw.errLog = function(string)
    if (_Config.enableErrorsLog) then
        print(("[^1Erreur^7] %s^7"):format(string))
    end
end

_Fw.loadedComponent = function(id)
    _Fw.log(("Chargement du composant ^6>^5 %s"):format(id))
end

_Fw.loadedAddon = function(id)
    _Fw.log(("Chargement de l'addon ^6>^4 %s"):format(id))
end

_Fw.countTable = function(table)
    local i = 0
    for k, v in pairs(table) do
        i = (i + 1)
    end
    return i
end

_Fw.countTableIp = function(table)
    local i = 0
    for k in (table) do
        i = (i + 1)
    end
    return i
end