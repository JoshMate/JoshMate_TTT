-- #############################################
-- Buff Base Class Info
-- #############################################
AddCSLuaFile()
ENT.Base                        = "jm_buff_base"

-- #############################################
-- Buff Basic Info
-- #############################################

local JM_PrintName              = JM_Global_Buff_EnergyDrink_Name
local JM_BuffNWBool             = JM_Global_Buff_EnergyDrink_NWBool
local JM_BuffDuration           = JM_Global_Buff_EnergyDrink_Duration
local JM_BuffIconName           = JM_Global_Buff_EnergyDrink_IconName
local JM_BuffIconPath           = JM_Global_Buff_EnergyDrink_IconPath
local JM_BuffIconGoodBad        = JM_Global_Buff_EnergyDrinke_IconGoodBad

-- #############################################
-- Generated Values (important for instances)
-- #############################################

ENT.PrintName                   = JM_PrintName
ENT.BuffNWBool                  = JM_BuffNWBool
ENT.BuffDuration                = JM_BuffDuration
ENT.BuffIconName                = JM_BuffIconName


-- #############################################
-- Client Side Visual Effects
-- #############################################

-- #############################################
-- The Actual Effects of this buff
-- #############################################

function ENT:BuffTickEffect()

    if self.targetPlayer:Health() >= self.targetPlayer:GetMaxHealth() then return end
			
    local newHP = self.targetPlayer:Health() + 1
    if newHP > self.targetPlayer:GetMaxHealth() then newHP = self.targetPlayer:GetMaxHealth() end

    self.targetPlayer:SetHealth(newHP)



end


function ENT:Initialize()
    self.BaseClass.Initialize(self)

    -- Handle Buff Effect Ticking
    self.buffTickDelay  = 0.3
    self.buffTickNext   = CurTime()

end

function ENT:Think()
    self.BaseClass.Think(self)

    -- Handle Buff Effect Ticking
    if(not self:IsValid()) then return end

    if(CurTime() >= self.buffTickNext) then
        self.buffTickNext = CurTime() + self.buffTickDelay
        self:BuffTickEffect()
    end

end

-- Hooks
hook.Add("TTTPlayerSpeedModifier", ("JM_BuffSpeedEffects_".. tostring(JM_PrintName)), function(ply, _, _, speedMultiplierModifier)

    if ply:IsValid() and ply:IsTerror() and ply:GetNWBool(JM_BuffNWBool) == true  then 
        speedMultiplierModifier[1] = speedMultiplierModifier[1] * 1.2
    end 
end)

-- Scale Damage
if SERVER then
    hook.Add("EntityTakeDamage", ("JM_BuffDamageEffects_".. tostring(JM_PrintName)), function(target, dmginfo)
		if not IsValid(target) or not target:IsPlayer() or not target:IsTerror() or not dmginfo:IsFallDamage() then return end
        if target:GetNWBool(JM_BuffNWBool) == true then 
            dmginfo:ScaleDamage(0.25)
        end
	end)
end

-- #############################################
-- AUTOMATICALLY GENERATED STUFF
-- #############################################

--Remove This Buff at the start of the round
hook.Add("TTTPrepareRound", ("JM_ResetNwBool_".. tostring(JM_PrintName)), function()
    for _, v in ipairs(player.GetAll()) do
        v:SetNWBool(JM_BuffNWBool, false)
    end
end)

-- Register Buff Icon
if CLIENT then
	hook.Add("Initialize", ("JM_BuffRegisterIcon_".. tostring(JM_PrintName)), function() 
        STATUS:RegisterStatus(JM_BuffIconName, {
			hud = Material(JM_BuffIconPath),
			type = JM_BuffIconGoodBad
		})
    end)
end