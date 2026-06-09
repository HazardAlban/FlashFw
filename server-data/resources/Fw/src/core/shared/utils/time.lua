

_Fw.Utils.setCurrentTime = function()
    return (os.time())
end

_Fw.Utils.getCurrentTime = function()
    local actualTime = os.date("*t")
    return (("%s/%s/%s %sh%s"):format(actualTime.day, actualTime.month, actualTime.year, actualTime.hour, actualTime.min))
end

_Fw.Utils.decodeTime = function(timeDecode)
    local actualTime = os.date("*t", timeDecode)
    return (("%s/%s/%s %sh%s"):format(actualTime.day, actualTime.month, actualTime.year, actualTime.hour, actualTime.min))
end