-- #############################################
-- Buff Base Class Info
-- #############################################
AddCSLuaFile()
ENT.Base                        = "jm_buff_base"

-- #############################################
-- Buff Basic Info
-- #############################################

local JM_PrintName              = JM_Global_Buff_DemonForm_Name
local JM_BuffNWBool             = JM_Global_Buff_DemonForm_NWBool
local JM_BuffDuration           = JM_Global_Buff_DemonForm_Duration
local JM_BuffIconName           = JM_Global_Buff_DemonForm_IconName
local JM_BuffIconPath           = JM_Global_Buff_DemonForm_IconPath
local JM_BuffIconGoodBad        = JM_Global_Buff_DemonForm_IconGoodBad

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

    if  not self.targetPlayer:IsValid() or not self.targetPlayer:Alive() then return end

    self.targetPlayer:Extinguish()
    self.targetPlayer:Ignite( 9999, 256)
			
    local newHP = self.targetPlayer:Health() - 5

    self.targetPlayer:SetHealth(newHP)

    if self.targetPlayer:Health() <= 0 then
        self.targetPlayer:Kill()
    end

    
end

function DemonFormEffects(ent)
	if not IsValid(ent) then return end
 
	local effect = EffectData()
	local ePos = ent:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	util.Effect("TeslaZap", effect, true, true)
	
	util.Effect("cball_explode", effect, true, true)
end


function ENT:Initialize()
    self.BaseClass.Initialize(self)

    -- Handle Buff Effect Ticking
    self.buffTickDelay  = 0.5
    self.buffTickNext   = CurTime()

    -- Demon Form

    local target = self.targetPlayer
    
    target:SetMaxHealth(target:GetMaxHealth() + 400)
    target:SetHealth(target:GetMaxHealth())

	target:SetModel("models/player/zombie_fast.mdl")

    DemonFormEffects(target)
    target:Extinguish()
    target:Ignite( 9999, 256)
    DemonFormEffects(target)
    sound.Play("npc/fast_zombie/fz_scream1.wav", target:GetPos(), 150, 100)
    DemonFormEffects(target)

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