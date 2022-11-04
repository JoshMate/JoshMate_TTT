-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end
if CLIENT then return end

-- Max Karma Shoutout Code
local JM_Karma_ListofPeopleWhoHaveHadMax = {}

-- Slay players who are below certain thresholds
local JM_Karma_SitOut_Threshold         = 0
local JM_Karma_Heal_Max                 = 1000
local JM_Karma_Heal_To_Max              = 100
local JM_Karma_Heal_Bonus               = 1300
local JM_Karma_Heal_To_Bonus            = 10

-- Karma Actions Reward Code
local JM_Karma_Reward_Mult_To_Max       = 10
local JM_Karma_Reward_Mult_To_Bonus     = 1

JM_KARMA_REWARD_ACTION_FINDBODY                 = 2
JM_KARMA_REWARD_ACTION_FINDBODYTRAITORBONUS     = 2
JM_KARMA_REWARD_ACTION_BEARTRAP                 = 2
JM_KARMA_REWARD_ACTION_DNASCAN                  = 2
JM_KARMA_REWARD_ACTION_TREEHEAL                 = 2
JM_KARMA_REWARD_ACTION_VISUALISER               = 2
JM_KARMA_REWARD_ACTION_AGENT                    = 2
JM_KARMA_REWARD_ACTION_OBJECTIVE_Bomb           = 2
JM_KARMA_REWARD_ACTION_OBJECTIVE_Battery        = 2
JM_KARMA_REWARD_ACTION_OBJECTIVE_FILE           = 2
JM_KARMA_REWARD_ACTION_OBJECTIVE_ARMS           = 2



function JM_Function_Karma_Reward(player, karmaRewardAmount, karmaRewardTextMessage)

    if CLIENT then return end
    if not player:IsValid() then return end
    if player:IsTraitor() then return end

    local newKarma = 0

    if player:GetLiveKarma() < JM_Karma_Heal_Max then 
        -- Multiply Karma rewards when below Max
        newKarma = player:GetLiveKarma() + (karmaRewardAmount * JM_Karma_Reward_Mult_To_Max)
        newKarma = math.Clamp(newKarma, -99999, JM_Karma_Heal_Max)
        player:SetLiveKarma(newKarma)
    else
        -- Multiply Karma rewards when below Bonus
        newKarma = player:GetLiveKarma() + (karmaRewardAmount * JM_Karma_Reward_Mult_To_Bonus)
        newKarma = math.Clamp(newKarma, JM_Karma_Heal_Max, JM_Karma_Heal_Bonus)
        player:SetLiveKarma(newKarma)
    end

    -- Print Chat Message to player
    local newKarmaMessage = "+".. tostring(karmaRewardAmount).. " Karma ("..tostring(karmaRewardTextMessage)..")"
    JM_Function_PrintChat(player, "Karma",newKarmaMessage)

end

-- Karma Slay Code
local function Effects_Slay(playerToSlay) 

    if not playerToSlay:IsValid() or not playerToSlay:IsPlayer() then return end

    local pos = playerToSlay:GetShootPos()
    local effect = EffectData()
    effect:SetStart(pos)
    effect:SetOrigin(pos)
    util.Effect("cball_explode", effect, true, true)
    
    -- Sound Effect
    JM_Function_PlaySound("karmaslay.wav")

    playerToSlay:Kill()
    playerToSlay:SetNWBool("JM_NWBOOL_IsSittingRoundOut", true)
    playerToSlay:SetTeam(TEAM_SPEC)

end
util.AddNetworkString("JM_KarmaSlayMessage")

hook.Add("TTTPrepareRound", "JMKarmaSlayAtStartOfRound", function()

    if CLIENT then return end
    
    local plys = player.GetAll()    
    for i = 1, #plys do

        local ply = plys[i]
        if not ply:IsValid() then continue end


        -- Karma Slay
        
        ply:SetNWBool("JM_NWBOOL_IsSittingRoundOut", false)

        local JM_Karma_Current = ply:GetBaseKarma()
        local newValue = 0

        -- Sit out if below minimum karma
        if JM_Karma_Current < JM_Karma_SitOut_Threshold then

            JM_Function_PrintChat_All("Karma Sit-Out", tostring(ply:Nick()) .. " is sitting out...")
            ply:SetLiveKarma(JM_Karma_SitOut_Threshold)
            Effects_Slay(ply) 
        end

        -- Restore Karma
        if JM_Karma_Current >= JM_Karma_SitOut_Threshold and JM_Karma_Current < JM_Karma_Heal_Max  then

            -- Heal back up to Normal Karma
            newValue = JM_Karma_Current + JM_Karma_Heal_To_Max
            newValue = math.Clamp(newValue, JM_Karma_SitOut_Threshold, JM_Karma_Heal_Max)

        elseif JM_Karma_Current >= JM_Karma_Heal_Max then

            -- Heal above normal and up to bonus karma
            newValue = JM_Karma_Current + JM_Karma_Heal_To_Bonus
            newValue = math.Clamp(newValue, JM_Karma_Heal_Max, JM_Karma_Heal_Bonus)

        end

        ply:SetLiveKarma(newValue)
    
    end
end)

hook.Add("TTTBeginRound", "JMKarmaSlayRevealSittersOut", function()

    local plys = player.GetAll()    
    for i = 1, #plys do

        local ply = plys[i]
        if not ply:IsValid() then continue end

        -- Set Player model and Colour for Detective Role
        ply:SetColor(Color( 235, 235, 235 ))
        if(ply:IsDetective()) then
            ply:SetModel( "models/player/police.mdl" )
            ply:SetColor(Color( 0, 50, 255 ))
        end

        -- 1100 Karma Bonus
        if ply:GetBaseKarma() >= 1100 then 
            JM_RemoveBuffFromThisPlayer("jm_buff_karmabuff_extra_grenade",ply)
            JM_GiveBuffToThisPlayer("jm_buff_karmabuff_extra_grenade",ply,ply)
            JM_Function_PrintChat(ply, "Karma","Nade Mule (+1 Grenade slot in inventory)")
        end
    
        -- 1200 Karma Bonus
        if ply:GetBaseKarma() >= 1200 and (ply:IsDetective() or ply:IsTraitor()) then 
            ply:AddCredits(1)
            JM_RemoveBuffFromThisPlayer("jm_buff_karmabuff_extra_credit",ply)
            JM_GiveBuffToThisPlayer("jm_buff_karmabuff_extra_credit",ply,ply)
            JM_Function_PrintChat(ply, "Karma","Clean Money (+1 Credit)")
        end

        -- 1300 Karma Bonus
        if ply:GetBaseKarma() >= 1300 then 
            JM_RemoveBuffFromThisPlayer("jm_buff_karmabuff_movement",ply)
            JM_GiveBuffToThisPlayer("jm_buff_karmabuff_movement",ply,ply)
            JM_Function_PrintChat(ply, "Karma","Angel wings (+10% Movement Speed and 20% less Fall Damage)")
        end

        -- Announce Max Karma once per person
        if ply:GetBaseKarma() == 1300 then 
            if not table.HasValue(JM_Karma_ListofPeopleWhoHaveHadMax, tostring(ply:SteamID64())) then
                JM_Function_PrintChat_All("Karma", tostring(ply:Nick()) .. " has reached MAX Karma!")
                -- Sound Effect
                JM_Function_PlaySound("karma_good.mp3")
                table.insert(JM_Karma_ListofPeopleWhoHaveHadMax, tostring(ply:SteamID64()))
            end
        end

        -- Karma Slay
        if ply:GetNWBool("JM_NWBOOL_IsSittingRoundOut") then
            ply:ConfirmPlayer(true)
            SendPlayerToEveryone(ply)
        end

    end
end)

