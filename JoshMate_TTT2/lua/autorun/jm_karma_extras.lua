-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end



-- Punished Movement Speed
local JM_Karma_Speed_Max = 1.0
local JM_Karma_Speed_Min = 0.5

hook.Add("TTTPlayerSpeedModifier", "KarmaMovementSpeedPunish", function(ply, _, _, speedMultiplierModifier)
	if not IsValid(ply)then return end

    local JM_Karma_Speed_Mult = 1.0
    local JM_Karma_Current = ply:GetBaseKarma()

    JM_Karma_Speed_Mult = (JM_Karma_Current / 1000)

    JM_Karma_Speed_Mult = math.Round(JM_Karma_Speed_Mult, 1)

    JM_Karma_Speed_Mult = math.Clamp(JM_Karma_Speed_Mult, JM_Karma_Speed_Min, JM_Karma_Speed_Max)    


	speedMultiplierModifier[1] = speedMultiplierModifier[1] * JM_Karma_Speed_Mult


end)

if SERVER then

    -- Punish Max HP
    local JM_Karma_HP_Max = 1.0
    local JM_Karma_HP_Min = 0.01

    hook.Add("TTTBeginRound", "KarmaMaxHPPunish", function()
        
        local plys = player.GetAll()    
        for i = 1, #plys do

            local ply = plys[i]
            if not ply:IsValid() or not ply:IsTerror() then continue end

            local JM_Karma_HP_Mult = 1.0
            local JM_Karma_Current = ply:GetBaseKarma()

            JM_Karma_HP_Mult = (JM_Karma_Current / 1000)
            JM_Karma_HP_Mult = math.Round(JM_Karma_HP_Mult, 2)
            JM_Karma_HP_Mult = math.Clamp(JM_Karma_HP_Mult, JM_Karma_HP_Min, JM_Karma_HP_Max)    

            ply:SetMaxHealth( ply:GetMaxHealth() *  JM_Karma_HP_Mult)
            ply:SetHealth(ply:GetMaxHealth())
            
        end
    end)
end



