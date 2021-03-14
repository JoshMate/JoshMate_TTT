-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end

if SERVER then return end
-- ONLY RUNS ON THE CLIENT


-- This is the clients collected user levels
-- ["SteamID String"] = Level Int
local TableOfPlayerLevels = {}

-- Recieve People's Levels from teh server
net.Receive("JM_Send_XPLevel_To_CLIENTS", function(_)
    local readSteamID = net.ReadString()
    local readLevel = net.ReadFloat()
    TableOfPlayerLevels[readSteamID] = readLevel
end)

-- Recieve Someone Has Leveled Up!
net.Receive("JM_Send_LeveledUp_To_Client", function(_)
    local readName = net.ReadString()
    local connector = " Has "
    if readName == LocalPlayer():Nick() then 
        surface.PlaySound("jmxp/levelup.wav") 
        readName = "You"
        connector = " Have "
    end
    chat.AddText( Color( 255, 150, 0 ), "[JM XP] - ", Color( 255, 255, 0 ), tostring(readName), Color( 255, 255, 255 ), connector, "Leveled Up!")
end)

-- Recieve XP Gained from the server
net.Receive("JM_Send_XPGained_To_Client", function(_)
    local readXP = net.ReadFloat()
    chat.AddText( Color( 255, 150, 0 ), "[JM XP] - ", Color( 255, 255, 255 ), "You Gained: ", Color( 255, 255, 0 ), tostring(readXP), Color( 255, 255, 255 ), " XP!")
end)

-- Recieve Chat Command Info from the server
net.Receive("JM_Send_ChatCommand_To_Client", function(_)
    local readXPLeft = net.ReadFloat()
    chat.AddText( Color( 255, 150, 0 ), "[JM XP] - ", Color( 255, 255, 255 ), "You Need: ", Color( 255, 255, 0 ), tostring(readXPLeft), Color( 255, 255, 255 ), " XP to level up!")
end)

-- Update Scoreborad with Level Column
hook.Add("TTTScoreboardColumns", "JM_ScoreBoard_XPLevel", function (panel)
	
    panel:AddColumn( "Level", function(ply, lbl)

        local color = Color(255,    255,   255)
        local level = 0

        if IsValid(ply) then 
            level = "Bot"
            if not ply:IsBot() then
                level = TableOfPlayerLevels["User" .. tostring(ply:SteamID64())]
                if not isnumber(level)then level = 0 end
            end
        end

        lbl:SetText(tostring(level))
        lbl:SetTextColor(color)
    
        return level
        
    end, 75)

end)

