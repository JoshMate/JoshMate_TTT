-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end

if SERVER then

    -- Give players Extra HP for bonus Karma

    local function JM_F_GiveBonusKarmaHP(player)

        local JM_Karma_BonusHP_Mult = 0.1

        local FinalHP = 100 + ((player:GetBaseKarma() - 1000) * JM_Karma_BonusHP_Mult)

        FinalHP = math.ceil(FinalHP)
        
        FinalHP = math.Clamp(FinalHP, 100, 125)

        player:SetMaxHealth(FinalHP)
        player:SetHealth(FinalHP)
    
    end

    -- Slay players who are below certain thresholds
    local JM_Karma_Slay_Threshold           = 500
    local JM_Karma_Heal_Max                 = 1000
    local JM_Karma_Heal_To_Max              = 100
    local JM_Karma_Heal_Bonus               = 1250
    local JM_Karma_Heal_To_Bonus            = 10

    util.AddNetworkString("JM_KarmaSlayMessage")

    local function Effects_Slay(playerToSlay) 

        if not playerToSlay:IsValid() then return end
    
        local pos = playerToSlay:GetShootPos()
        local effect = EffectData()
        effect:SetStart(pos)
        effect:SetOrigin(pos)
        util.Effect("cball_explode", effect, true, true)
        
        
    
        playerToSlay:Kill()
        playerToSlay:SetNWBool("JM_NWBOOL_IsSittingRoundOut", true)
        playerToSlay:SetTeam(TEAM_SPEC)

        playerToSlay:SetLiveKarma(JM_Karma_Slay_Threshold)
        net.Start("JM_KarmaSlayMessage")
        net.WriteString(tostring(playerToSlay:Nick()))
        net.Broadcast()
    
    end


    hook.Add("TTTPrepareRound", "JMKarmaSlayAtStartOfRound", function()
        
        local plys = player.GetAll()    
        for i = 1, #plys do

            local ply = plys[i]
            if not ply:IsValid() then continue end

            -- Karma Bonus HP

            JM_F_GiveBonusKarmaHP(ply)

            -- Karma Slay
            
            ply:SetNWBool("JM_NWBOOL_IsSittingRoundOut", false)

            local JM_Karma_Current = ply:GetBaseKarma()
            local newValue = 0

            if JM_Karma_Current < JM_Karma_Slay_Threshold then

                Effects_Slay(ply) 
                ply:SetLiveKarma(JM_Karma_Slay_Threshold)

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

            -- Karma Bonus Detective Credit

            if(ply:IsDetective()) then
                
                if (ply:GetBaseKarma() >= 1250 ) then
                    ply:AddCredits(1)
                end

            end

            -- Karma Bonus Traitor Credit

            if(ply:IsTraitor()) then
                
                if (ply:GetBaseKarma() >= 1250 ) then
                    ply:AddCredits(1)
                end

            end

            -- Karma Bonus HP

            JM_F_GiveBonusKarmaHP(ply)

            -- Karma Slay

            if ply:GetNWBool("JM_NWBOOL_IsSittingRoundOut") then

                ply:ConfirmPlayer(true)

			    SendPlayerToEveryone(ply)

            end

        end


    end)
     



end


if CLIENT then
    net.Receive("JM_KarmaSlayMessage", function(_) 
        local nameOfPlayerSlayed = net.ReadString()

        surface.PlaySound("karmaslay.wav")
        chat.AddText( Color( 255, 0, 0 ), "[KARMA] - ", Color( 255, 255, 0 ), tostring(nameOfPlayerSlayed), Color( 255, 255, 255 ), " is sitting this Round out due to low Karma")
    end)
end


