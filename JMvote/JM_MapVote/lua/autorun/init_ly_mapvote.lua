if SERVER then
    AddCSLuaFile()
    AddCSLuaFile("mapvote/mapvote.lua")
    AddCSLuaFile("mapvote/cl_mapButton.lua")
    AddCSLuaFile("mapvote/cl_mapFrame.lua")
    AddCSLuaFile("mapvote/cl_mapvote.lua")
    include("mapvote/sv_confighelper.lua")
    include("mapvote/mapvote.lua")
    include("mapvote/sv_mapvote.lua")
    include("mapvote/sv_rtv.lua")
else
    include("mapvote/mapvote.lua")
    include("mapvote/cl_mapButton.lua")
    include("mapvote/cl_mapFrame.lua")
    include("mapvote/cl_mapvote.lua")
end

print("[JM Map Vote] - Initializing the map vote addon!")
