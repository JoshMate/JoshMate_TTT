if engine.ActiveGamemode() ~= "terrortown" then return end

if CLIENT then return end
-- ONLY RUNS ON THE SERVER


-- /////////////////////////////////////
-- Functions for processing the file
local FolderName = "joshmate_xplevels"
local FileName = "player_xp"

function File_Init()
    print("[JM XP] - initializing...")
    if not file.Exists(FolderName, "DATA") then
        print("[JM XP] - Folder not found! Creating it...")
        file.CreateDir(FolderName)
    end
end

function File_Read() 
    print("[JM XP] - Reading from File...")
    local jsonString = file.Read(FolderName .. "/" .. FileName .. ".txt", "DATA")
    if jsonString == nil then jsonString = "{}" end
    return util.JSONToTable(jsonString)
end

function File_Write(toWrite) 
    print("[JM XP] - Writing to File...")
    local configString = util.TableToJSON(toWrite, true) -- true = prettyPrint
    file.Write(FolderName .. "/" .. FileName .. ".txt", configString)
end

function CalculateLevelFromXP(XP)
    local Level = 0
    local XPForLevel = 200
    local XPExtraPerLevel = 100
    local NotDone = true
    local XPCheck = 0
    local XPCheckTimes = 0
    local XPLeftToLevel

    while NotDone == true do

        XPCheck = XPForLevel + (XPExtraPerLevel * XPCheckTimes)
        NotDone = false

        if XP >= XPCheck then
            Level = Level + 1
            XP = XP - XPCheck
            NotDone = true
        end

        XPCheckTimes = XPCheckTimes + 1
        XPLeftToLevel = XPCheck - XP

    end

    return Level, XPLeftToLevel

end


function UpdateAndSendNewLevels(SVTableOfPlayerXP)

    File_Write(SVTableOfPlayerXP)
    for id, xp in pairs(SVTableOfPlayerXP) do
        local Level = CalculateLevelFromXP(xp)
		net.Start( "JM_Send_XPLevel_To_CLIENTS" )
        net.WriteString(id)
        net.WriteFloat(Level)
        local rf = RecipientFilter()
        rf:AddAllPlayers()
        net.Send(rf)
	end

end

function WorkOutInitialLevels(SVTableOfPlayerXP)

    local SVTableOfPlayerLevels = {}

    for id, xp in pairs(SVTableOfPlayerXP) do
        SVTableOfPlayerLevels[id] = CalculateLevelFromXP(xp)
	end

    return SVTableOfPlayerLevels

end

-- /////////////////////////////////////
-- Main Flow

-- Netowrking String Setup
util.AddNetworkString("JM_Send_XPLevel_To_CLIENTS")
util.AddNetworkString("JM_Send_XPGained_To_Client")
util.AddNetworkString("JM_Send_LeveledUp_To_Client")
util.AddNetworkString("JM_Send_ChatCommand_To_Client")

File_Init()
local SVTableOfPlayerXP = File_Read()
UpdateAndSendNewLevels(SVTableOfPlayerXP)
local SVTableOfPlayerLevels = WorkOutInitialLevels(SVTableOfPlayerXP)



-- /////////////////////////////////////
-- Hooks
hook.Add("TTTEndRound", "JM_EndRound_XPLevel", function(result)

    for k, ply in ipairs( player.GetAll() ) do

        if ply:IsBot() then
        end
        if not ply:IsBot() then
            local XPGainedFinal         = 0
            local XPGainedFromKarma     = 0 
            local XpGainedFromScore     = 0
            local XpMultiplier          = 1
            

            XPGainedFromKarma = math.Round((ply:GetBaseKarma() / 10), 0)
            XPGainedFromScore = math.Round(ply:Frags()*5)

            -- Extra 50% if you survived
            if ply:Alive() then 
                XpMultiplier = XpMultiplier + 0.5 
            end

            -- Extra 100% if your team won: Traitors
            if tostring(result) == "traitors" and ply:GetRole() == 1 then
                XpMultiplier = XpMultiplier + 1.5
            end

            -- Extra 100% if your team won: Innocents
            if tostring(result) == "innocents" and ply:GetRole() == 0 then
                XpMultiplier = XpMultiplier + 1
            end

            -- Extra 100% if your team won: Detective
            if tostring(result) == "innocents" and ply:GetRole() == 2 then
                XpMultiplier = XpMultiplier + 1.5
            end

            if XPGainedFromKarma < 0 then XPGainedFromKarma = 0 end 
            if XPGainedFromScore < 0 then XPGainedFromScore = 0 end 

            XPGainedFinal = math.Round(((XPGainedFromKarma + XPGainedFromScore)*XpMultiplier))
            if XPGainedFinal < 0 then XPGainedFinal = 0 end
            
            -- Add it to our Servers XP Table
            local ID = "User" .. tostring(ply:SteamID64())
            local PrevXP = SVTableOfPlayerXP["User" .. tostring(ply:SteamID64())]
            if PrevXP == nil then PrevXP = 0 end
            SVTableOfPlayerXP[ID] = PrevXP + XPGainedFinal

            -- Work out if anyone has leveled up
            local Level = CalculateLevelFromXP(SVTableOfPlayerXP[ID])
            if not isnumber(Level) then Level = 0 end

            if isnumber(SVTableOfPlayerLevels[ID]) then
                if Level > SVTableOfPlayerLevels[ID] then
                    SVTableOfPlayerLevels[ID] = Level
                    net.Start( "JM_Send_LeveledUp_To_Client" )
                    net.WriteString(ply:Nick())
                    local rf = RecipientFilter()
                    rf:AddAllPlayers()
                    net.Send(rf)
                end
            end
            if not isnumber(SVTableOfPlayerLevels[ID]) then
                if Level > 0 then
                    SVTableOfPlayerLevels[ID] = Level
                    net.Start( "JM_Send_LeveledUp_To_Client" )
                    net.WriteString(ply:Nick())
                    local rf = RecipientFilter()
                    rf:AddAllPlayers()
                    net.Send(rf)
                end
            end

            -- Log it
            print("[JM XP] - ".. ply:Nick() .. " XP Gained: " .. XPGainedFinal .. " (" .. (XpMultiplier*100) .. "%" ..")")

            -- Send it to the client
            net.Start( "JM_Send_XPGained_To_Client" )
            net.WriteFloat(XPGainedFinal)
            net.Send(ply)
        end

    end

    UpdateAndSendNewLevels(SVTableOfPlayerXP)
end)

hook.Add( "PlayerConnect", "JM_OnConnect_XPLevel", function()
	UpdateAndSendNewLevels(SVTableOfPlayerXP)
end )

hook.Add( "PlayerInitialSpawn", "JM_OnSpawn_XPLevel", function()
	UpdateAndSendNewLevels(SVTableOfPlayerXP)
end )

-- Chat Command to see exp
hook.Add("PlayerSay", "JM_XP_ChatCommand", function(ply, text, public)
	text = string.lower(text)
    text = string.Trim(text)

	if text == "!jmxp" then

        local XP = SVTableOfPlayerXP["User" .. tostring(ply:SteamID64())]
        if not isnumber(XP) then XP = 0 end
        local Level, XPLeftToLevelCL = CalculateLevelFromXP(XP)

        -- Log it
        print("[JM XP] - ".. ply:Nick() .. "Has checked that they need: " .. XPLeftToLevelCL .. " XP Left to Level Up!")
        
		net.Start( "JM_Send_ChatCommand_To_Client" )
        net.WriteFloat(math.Round(XPLeftToLevelCL))
        net.Send(ply)
	end
end)


