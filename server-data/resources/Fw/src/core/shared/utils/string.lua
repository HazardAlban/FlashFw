

_Fw.Utils.string_startsWith = function(str, start)
    return (string.sub(str, 1, string.len(start)) == start)
end

_Fw.Utils.string_split = function(str, delimiter)
    result = {};
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match);
    end
    return result;
end

_Fw.Utils.string_replaceAll = function(str, find, replace)
    return str:gsub(find, replace)
end