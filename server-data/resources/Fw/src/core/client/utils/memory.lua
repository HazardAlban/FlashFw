

_Fw.Client_Utils.memory_load = function(model, alreadyHashed, noLoading)
    if (not (noLoading)) then
        _Fw.Client_Utils.loading_show(("Chargement du modèle %s"):format(model), 4)
    end
    if (not (alreadyHashed)) then
        model = GetHashKey(model)
    end
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    if (not (noLoading)) then
        _Fw.Client_Utils.loading_hide()
    end
end

_Fw.Client_Utils.memory_loadAll = function(models)
    for _, model in pairs(models) do
        _Fw.Client_Utils.memory_load(model)
    end
end

_Fw.Client_Utils.memory_loadDict = function(dict)
    RequestStreamedTextureDict(dict)
    while (not (HasStreamedTextureDictLoaded(dict))) do
        Wait(1)
    end
end

_Fw.Client_Utils.memory_unload = function(model, alreadyHashed)
    if (not (alreadyHashed)) then
        model = GetHashKey(model)
    end
    SetModelAsNoLongerNeeded(model)
end