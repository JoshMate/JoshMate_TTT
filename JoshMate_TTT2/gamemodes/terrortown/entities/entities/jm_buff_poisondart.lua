-- #############################################
-- Buff Base Class Info
-- #############################################
AddCSLuaFile()
ENT.Base                        = "jm_buff_base"

-- #############################################
-- Buff Basic Info
-- #############################################

local JM_PrintName              = JM_Global_Buff_PoisonDart_Name
local JM_BuffNWBool             = JM_Global_Buff_PoisonDart_NWBool
local JM_BuffDuration           = JM_Global_Buff_PoisonDart_Duration
local JM_BuffIconName           = JM_Global_Buff_PoisonDart_IconName
local JM_BuffIconPath           = JM_Global_Buff_PoisonDart_IconPath
local JM_BuffIconGoodBad        = JM_Global_Buff_PoisonDart_IconGoodBad

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

    
    -- Set up screen effect table
    local effectTable_PoisonDart = {

        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0.25,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 1,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    -- Render Any Screen Effects
    hook.Add("RenderScreenspaceEffects", ("JM_BuffScreenEffects_".. tostring(JM_PrintName)), function()

        if LocalPlayer():GetNWBool(JM_BuffNWBool) == true then 
            DrawColorModify( effectTable_PoisonDart)
        end 
    
    end)

end

-- #############################################
-- The Actual Effects of this buff
-- #############################################

function ENT:BuffTickEffect()

    local poisonDartDamageTick = 2
    
    local dmginfo = DamageInfo()
    dmginfo:SetDamage(poisonDartDamageTick)

    dmginfo:SetAttacker(self.buffGiver)

    local inflictor = ents.Create("weapon_jm_equip_poisondart")
    dmginfo:SetInflictor(inflictor)
    dmginfo:SetDamageType(DMG_GENERIC)
    dmginfo:SetDamagePosition(self.targetPlayer:GetPos())
    self.targetPlayer:TakeDamageInfo(dmginfo)

    if(not self.buffGiver:IsValid() or not self.buffGiver:IsPlayer() or not self.buffGiver:Alive()) then return end

    -- Heal the User
    if (self.buffGiver:Health()+ poisonDartDamageTick) <= self.buffGiver:GetMaxHealth() then
        self.buffGiver:SetHealth(self.buffGiver:Health() + poisonDartDamageTick)
    end



end


function ENT:Initialize()
    self.BaseClass.Initialize(self)

    -- Handle Buff Effect Ticking
    self.buffTickDelay  = 0.25
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