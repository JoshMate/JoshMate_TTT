-- #############################################
-- Buff Base Class Info
-- #############################################
AddCSLuaFile()
ENT.Base                        = "jm_buff_base"

-- #############################################
-- Buff Basic Info
-- #############################################

local JM_PrintName              = JM_Global_Buff_AntidotePoison_Name
local JM_BuffNWBool             = JM_Global_Buff_AntidotePoison_NWBool
local JM_BuffDuration           = JM_Global_Buff_AntidotePoison_Duration
local JM_BuffIconName           = JM_Global_Buff_AntidotePoison_IconName
local JM_BuffIconPath           = JM_Global_Buff_AntidotePoison_IconPath
local JM_BuffIconGoodBad        = JM_Global_Buff_AntidotePoison_IconGoodBad

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
    local effectTable_AntidotePoison = {

        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0.15,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 1.2,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

        -- Render Any Screen Effects
        hook.Add("RenderScreenspaceEffects", ("JM_BuffScreenEffects_".. tostring(JM_PrintName)), function()

            if LocalPlayer():GetNWBool(JM_BuffNWBool) == true then 
                DrawColorModify( effectTable_AntidotePoison)
            end 
        
        end)


end

-- #############################################
-- The Actual Effects of this buff
-- #############################################

function ENT:BuffTickEffect()
    
    local dmginfo = DamageInfo()
    dmginfo:SetDamage(self.buffTickAmount)

    dmginfo:SetAttacker(self.buffGiver)

    local inflictor = self.buffGiver
    dmginfo:SetInflictor(inflictor)
    dmginfo:SetDamageType(DMG_GENERIC)
    dmginfo:SetDamagePosition(self.targetPlayer:GetPos())
    self.targetPlayer:TakeDamageInfo(dmginfo)

    self.buffTickAmount = self.buffTickAmount + 1
end


function ENT:Initialize()
    self.BaseClass.Initialize(self)

    -- Handle Buff Effect Ticking
    self.buffTickDelay  = 2.5
    self.buffTickNext   = CurTime()
    self.buffTickAmount = 1

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