-- Give these files out
AddCSLuaFile()

local ListOfKnownSteamID64s = {
    ["76561198028744358"] = "Ed",
    ["76561198023804464"] = "Cam",
    ["76561198043368865"] = "Koen",
    ["76561198051939584"] = "Jake", -- Jakes Account
    ["76561198055037725"] = "Matt",
    ["76561197972401416"] = "Laura",
    ["76561198003045046"] = "Simon",
    ["76561198045438075"] = "Josh",
    ["76561198040289103"] = "Kurt",
    ["76561198102744407"] = "Chris",
    ["76561198042973566"] = "Seb",
    ["76561198099452162"] = "India", -- Indias Account
    ["76561198042307496"] = "Ali",
    ["76561198068687157"] = "Noah",
    ["76561198086960314"] = "Vinny",
    ["76561198134267973"] = "Joel",
    ["76561198354732703"] = "Alex",
    ["76561198044695827"] = "Adam"
} 

meta = FindMetaTable( "Player" )
function meta:Nick()


    -- If your Steam ID exists in the known table use your "Forced Name"
    if ListOfKnownSteamID64s[self:SteamID64()] ~= nil then return ListOfKnownSteamID64s[self:SteamID64()] end

    -- Otherwise just use your own steam name
    return self:GetName()
    
end

