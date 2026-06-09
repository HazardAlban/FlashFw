

_Fw.Utils.math_round = function(number, decimalPlace)
    local mult = 10 ^ (decimalPlace or 0)
    return math.floor(number * mult + 0.5) / mult
end

_Fw.Utils.math_group = function(value)
    local left, num, right = string.match(value, '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1' .. ","):reverse()) .. right
end

_Fw.Utils.math_price = function(value)
    return ("~g~%s$~s~"):format(_Fw.Utils.math_group(_Fw.Utils.math_round(value, 2)))
end

_Fw.Utils.math_price_integer = function(value)
    return ("~g~%s$~s~"):format(_Fw.Utils.math_group(math.floor(value)))
end

_Fw.Utils.math_price_color = function(value, color)
    return ("%s%s$~s~"):format(color, _Fw.Utils.math_group(_Fw.Utils.math_round(value, 2)))
end

_Fw.Utils.math_getInversedHeading = function(heading)
    return (heading + 180) % 360
end