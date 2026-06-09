

_Fw.Client_Utils.animation_load = function(dict)
     RequestAnimDict(dict)
     while not HasAnimDictLoaded(dict) do
        Wait(1)
     end
end

_Fw.Client_Utils.process_load = function(name)
    RequestAnimSet(name)
    while not HasAnimSetLoaded(name) do
        Wait(1)
    end
end