-- #############################################
-- Buff Base Class Info
-- #############################################
AddCSLuaFile()
ENT.Base                        = "jm_buff_base"

-- #############################################
-- Buff Basic Info
-- #############################################

local JM_PrintName              = JM_Global_Buff_KarmaBuff_Might_Name
local JM_BuffNWBool             = JM_Global_Buff_KarmaBuff_Might_NWBool
local JM_BuffDuration           = JM_Global_Buff_KarmaBuff_Might_Duration
local JM_BuffIconName           = JM_Global_Buff_KarmaBuff_Might_IconName
local JM_BuffIconPath           = JM_Global_Buff_KarmaBuff_Might_IconPath
local JM_BuffIconGoodBad        = JM_Global_Buff_KarmaBuff_Might_IconGoodBad

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

if CLIENT then


    
end

-- #############################################
-- The Actual Effects of this buff
-- #############################################

function ENT:Initialize()
    self.BaseClass.Initialize(self)

end

function ENT:Think()
    self.BaseClass.Think(self)

end

-- Hooks
-- 10% Bonus Damage to others
hook.Add("EntityTakeDamage", ("JM_BuffFallDamageEffects_".. tostring(JM_PrintName)), function(target, dmginfo)
	if dmginfo:GetAttacker():IsValid() and dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker():GetNWBool(JM_BuffNWBool) == true then 
        dmginfo:ScaleDamage(1.10)
    end
end)



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