

_Fw.Client_Utils.regex_validate = function(str, regex)
    return (string.match(str, regex))
end

_Fw.Client_Utils.regex_name = function(name)
    return (_Fw.Client_Utils.regex_validate(name, "^[A-Z][A-Za-z\\é\\è\\ê\\-]+$"))
end