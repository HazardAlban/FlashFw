

_Fw.Client_Utils.loading_show = function(loadingText, spinnerType)
    if IsLoadingPromptBeingDisplayed() then
        RemoveLoadingPrompt()
    end
    if (loadingText == nil) then
        BeginTextCommandBusyString(nil)
    else
        BeginTextCommandBusyString("STRING");
        AddTextComponentSubstringPlayerName(loadingText);
    end
    EndTextCommandBusyString(spinnerType)
end

_Fw.Client_Utils.loading_hide = function()
    if IsLoadingPromptBeingDisplayed() then
        RemoveLoadingPrompt()
    end
end