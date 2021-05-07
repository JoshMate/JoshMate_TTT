-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end




if SERVER then

    local function Effects_Slay(playerToSlay) 

        if not playerToSlay:IsValid() then return end
    
        local pos = playerToSlay:GetShootPos()
        local effect = EffectData()
        effect:SetStart(pos)
        effect:SetOrigin(pos)
        util.Effect("cball_explode", effect, true, true)
        
        playerToSlay:EmitSound("karmaslay.wav")
    
        playerToSlay:Kill()
        playerToSlay:SetLiveKarma(JM_Karma_Slay_Threshold_First)
        net.Start("JM_KarmaSlayMessage")
        net.WriteString(tostring(playerToSlay:Nick()))
        net.Broadcast()
    
    end


    -- Slay players who are below certain thresholds
    local JM_Karma_Slay_Threshold_First     = 300
    local JM_Karma_Slay_Threshold_Second    = 600
    local JM_Karma_Heal_Max                 = 1000
    local JM_Karma_Heal_After_Slays         = 100

    util.AddNetworkString("JM_KarmaSlayMessage")

    hook.Add("TTTBeginRound", "JMKarmaSlayAtStartOfRound", function()
        
        local plys = player.GetAll()    
        for i = 1, #plys do

            local ply = plys[i]
            if not ply:IsValid() or not ply:IsTerror() then continue end

            local JM_Karma_Current = ply:GetBaseKarma()

            if JM_Karma_Current < JM_Karma_Slay_Threshold_First then

                Effects_Slay(ply) 
                ply:SetLiveKarma(JM_Karma_Slay_Threshold_First)
                
            elseif JM_Karma_Current < JM_Karma_Slay_Threshold_Second then

                Effects_Slay(ply) 
                ply:SetLiveKarma(JM_Karma_Slay_Threshold_Second)

            elseif JM_Karma_Current >= JM_Karma_Slay_Threshold_Second then

                local newValue = JM_Karma_Current + JM_Karma_Heal_After_Slays
                ply:SetLiveKarma(math.Clamp(newValue, JM_Karma_Slay_Threshold_Second, JM_Karma_Heal_Max) )

            end
        
        end
    end)
end

if CLIENT then
    net.Receive("JM_KarmaSlayMessage", function(_) 
        local nameOfPlayerSlayed = net.ReadString()

        chat.AddText( Color( 255, 0, 0 ), "[KARMA] - ", Color( 255, 255, 0 ), tostring(nameOfPlayerSlayed), Color( 255, 255, 255 ), " was killed because they had low karma!")
    end)
end


