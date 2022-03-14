-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end
if CLIENT then return end

-- Slay players who are below certain thresholds
local JM_Karma_Slay_Minimum             = 0
local JM_Karma_Slay_Threshold           = 500
local JM_Karma_Heal_Max                 = 1000
local JM_Karma_Heal_To_Max              = 100
local JM_Karma_Heal_Bonus               = 1250
local JM_Karma_Heal_To_Bonus            = 10

util.AddNetworkString("JM_KarmaSlayMessage")

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

        if JM_Karma_Current < JM_Karma_Slay_Minimum then

            JM_Function_PrintChat_All("Karma Sit-Out", tostring(ply:Nick()) .. " is sitting out Twice")
            ply:SetLiveKarma(JM_Karma_Slay_Minimum)
            Effects_Slay(ply) 
            

        elseif JM_Karma_Current < JM_Karma_Slay_Threshold then

            JM_Function_PrintChat_All("Karma Sit-Out", tostring(ply:Nick()) .. " is sitting out Once")
            ply:SetLiveKarma(JM_Karma_Slay_Threshold)
            Effects_Slay(ply) 

        elseif JM_Karma_Current >= JM_Karma_Slay_Threshold  then

            if JM_Karma_Current >= JM_Karma_Slay_Threshold then 
                newValue = JM_Karma_Current + JM_Karma_Heal_To_Max

                newValue = math.Clamp(newValue, JM_Karma_Slay_Threshold, JM_Karma_Heal_Max)
            end

            if JM_Karma_Current >= JM_Karma_Heal_Max then 
                newValue = JM_Karma_Current + JM_Karma_Heal_To_Bonus

                newValue = math.Clamp(newValue, JM_Karma_Heal_Max, JM_Karma_Heal_Bonus)
            end
                
            ply:SetLiveKarma(newValue)

        end
    
    end
end)


hook.Add("TTTBeginRound", "JMKarmaSlayRevealSittersOut", function()

    local plys = player.GetAll()    
    for i = 1, #plys do

        local ply = plys[i]
        if not ply:IsValid() then continue end

        -- Set Detective Player Model

        if(ply:IsDetective()) then
            ply:SetModel( "models/player/police.mdl" )
        end

        -- Karma Bonus HP
        local JM_Karma_BonusHP_Mult = 0.1

        if ply:GetBaseKarma() > 1000 and ply:GetBaseKarma() < 1250 then 
            local BonusHPFromKarama = math.ceil(((ply:GetBaseKarma() - 1000) * JM_Karma_BonusHP_Mult))
            local FinalHP = 100 + BonusHPFromKarama
            FinalHP = math.Clamp(FinalHP, 100, 125)
            JM_Function_PrintChat(ply, "Karma","Good Karma Bonus: Bonus Health (+" .. tostring(BonusHPFromKarama) .. " HP)")
            ply:SetMaxHealth(FinalHP)
            ply:SetHealth(FinalHP)
        end

        if ply:GetBaseKarma() == 1250 then 
            local BonusHPFromKarama = 30
            local FinalHP = 100 + BonusHPFromKarama
            JM_Function_PrintChat(ply, "Karma","Good Karma Bonus: Bonus Health (+" .. tostring(BonusHPFromKarama) .. " HP)")
            ply:SetMaxHealth(FinalHP)
        ply:SetHealth(FinalHP)
        end
    
        -- Karma Bonus Credit 
        if ply:GetBaseKarma() == 1250 and ATSM_IsDetective(IsDetective) or ATSM_IsTraitor(IsTraitor) then 
            ply:AddCredits(1)
            JM_Function_PrintChat(ply, "Karma","Good Karma Bonus: Bonus Credit (+1 Credit)")
        end

        -- Karma Good Boy Buff
        if ply:GetBaseKarma() == 1250 then 
            JM_RemoveBuffFromThisPlayer("jm_buff_karmabuff",ply)
            JM_GiveBuffToThisPlayer("jm_buff_karmabuff",ply,ply)
            JM_Function_PrintChat(ply, "Karma","Good Karma Bonus: Good Boy Buff (+10% Movement Speed)")
        end

        -- Karma Slay

        if ply:GetNWBool("JM_NWBOOL_IsSittingRoundOut") then

            ply:ConfirmPlayer(true)

            SendPlayerToEveryone(ply)

        end

    end
end)

