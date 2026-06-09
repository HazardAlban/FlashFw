

gameType = _FwEnum_GAMETYPE.RP
gameState = _FwENUM_GAMESTATE.WAITING

isAllowedToInteract = true
isWaitingForServer = false

_Fw.setGameState = function(newGameState)
    gameState = newGameState
    if (gameState == _FwENUM_GAMESTATE.PLAYING) then
        _Fw.toInternal("nowPlaying")
    end
end

_Fw.setIsWaitingForServer = function(newState)
    isWaitingForServer = newState
    if(isWaitingForServer) then
        CreateThread(function()
            _Fw.Client_Utils.loading_show("En attente du serveur", 4)
            while (isWaitingForServer) do
                Wait(1)
            end
            _Fw.Client_Utils.loading_hide()
        end)
    end
end

_Fw.toServer = function(event, ...)
    TriggerServerEvent(_Fw.format(event), ...)
    _Fw.log(("Envoie d'un event au serveur ^6>^1 %s"):format(event))
end

_Fw.toServerExposed = function(event, ...)
    TriggerServerEvent(event, ...)
    _Fw.log(("Envoie d'un event (^1Exposé^7) au serveur ^6>^1 %s"):format(event))
end

_Fw.onReceive("serverReturnedCb", function()
    _Fw.setIsWaitingForServer(false)
end)


_Fw.log("Bienvenue sur ^1Framework ^7!")