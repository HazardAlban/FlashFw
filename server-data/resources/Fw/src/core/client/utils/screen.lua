

_Fw.Client_Utils.screen_radar = function(bool)
    DisplayRadar(bool)
end

_Fw.Client_Utils.screen_fade = function(duration, waitUntilFinished)
    DoScreenFadeOut(duration)
    if (waitUntilFinished) then
        while (not (IsScreenFadedOut())) do
            Wait(0)
        end
    end
end

_Fw.Client_Utils.screen_reveal = function(duration, waitUntilFinished)
    DoScreenFadeIn(duration)
    if (waitUntilFinished) then
        while (not (IsScreenFadedIn())) do
            Wait(0)
        end
    end
end