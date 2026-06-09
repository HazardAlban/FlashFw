

_Fw.onReceiveWithoutNet("creator:init", function(_src)
    print("1")
end)
_Fw.onReceive("creator:init", function(_src)
    print("3")
end)
_Fw.onReceiveWithoutNetExposed("creator:init", function(_src)
    print("2")
end)