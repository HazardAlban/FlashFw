

_Fw.Client_Utils.notifications_show = function(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(0, 1)
end

_Fw.Client_Utils.notifications_showHelp = function(message)
    AddTextEntry("FwLandHelp", message)
    DisplayHelpTextThisFrame("FwLandHelp", false)
end

_Fw.Client_Utils.notifications_showAdvanced = function(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
    if saveToBrief == nil then
        saveToBrief = true
    end
    AddTextEntry("anotif", msg)
    BeginTextCommandThefeedPost("anotif")
    if hudColorIndex then
        ThefeedNextPostBackgroundColor(hudColorIndex)
    end
    EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
    EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end

_Fw.onReceive("utils:notifications_showAdvanced", function(sender, subject, msg, textureDict, iconType)
    _Fw.Client_Utils.notifications_showAdvanced(sender, subject, msg, textureDict, iconType)
end)

_Fw.Client_Utils.notifications_template_error = function(message)
    _Fw.Client_Utils.notifications_showAdvanced("Framework", "~r~Erreur", message, _FwEnum_CHARACTERPICTURE.EPSILON, _FwEnum_MESSAGEICONTYPE.CHAT)
end

_Fw.Client_Utils.notifications_template_success = function(message)
    _Fw.Client_Utils.notifications_showAdvanced("Framework", "~g~Succès", message, _FwEnum_CHARACTERPICTURE.EPSILON, _FwEnum_MESSAGEICONTYPE.CHAT)
end

_Fw.Client_Utils.notifications_template_info = function(message)
    _Fw.Client_Utils.notifications_showAdvanced("Framework", "~o~Information", message, _FwEnum_CHARACTERPICTURE.EPSILON, _FwEnum_MESSAGEICONTYPE.CHAT)
end

_Fw.onReceive("utils:messenger_system_error", function(message)
    _Fw.Client_Utils.notifications_template_error(message)
end)

_Fw.onReceive("utils:messenger_system_success", function(message)
    _Fw.Client_Utils.notifications_template_success(message)
end)

_Fw.onReceive("utils:messenger_system_info", function(message)
    _Fw.Client_Utils.notifications_template_info(message)
end)

_Fw.onReceive("utils:messenger_playerPed", function(sourcePed, sender, subject, content, iconType)
    local otherPed = GetPlayerPed(GetPlayerFromServerId(sourcePed))
    local mugshot, mugshotStr = _Fw.Client_Utils.ped_getMugShot(otherPed)
    _Fw.Client_Utils.notifications_showAdvanced(sender, subject, content, mugshotStr, iconType, false)
end)

_Fw.onReceive("utils:messenger_system_custom", function(title, message)
    _Fw.Client_Utils.notifications_showAdvanced("Système", title, message, _FwEnum_CHARACTERPICTURE.SYSTEM, _FwEnum_MESSAGEICONTYPE.CHAT)
end)
