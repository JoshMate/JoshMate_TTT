-- #############################################
-- Buff Base Class Info
-- #############################################
AddCSLuaFile()
ENT.Base                        = "jm_buff_base"

-- #############################################
-- Buff Basic Info
-- #############################################

local JM_PrintName              = JM_Global_Buff_ZombieMode_Name
local JM_BuffNWBool             = JM_Global_Buff_ZombieMode_NWBool
local JM_BuffDuration           = JM_Global_Buff_ZombieMode_Duration
local JM_BuffIconName           = JM_Global_Buff_ZombieMode_IconName
local JM_BuffIconPath           = JM_Global_Buff_ZombieMode_IconPath
local JM_BuffIconGoodBad        = JM_Global_Buff_ZombieMode_IconGoodBad

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
    if self.targetPlayer:GetMaxHealth() > 100 then
        self.targetPlayer:SetMaxHealth(newHP)
    end

    if self.targetPlayer:Health() <= 0 then
        self.targetPlayer:Kill()
    end

    
end

function ZombieFormEffects(ent)
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

    -- Handle Sound Ticking
    self.SoundbuffTickDelay_Min     = 10
    self.SoundbuffTickDelay_Max     = 20
    self.SoundbuffTickNext          = CurTime() + math.random(self.SoundbuffTickDelay_Min, self.SoundbuffTickDelay_Max)

    -- Zombie Form

    local target = self.targetPlayer
    
    target:SetMaxHealth(500)
    target:SetHealth(500)

	target:SetModel("models/player/zombie_fast.mdl")
    target:SetPlayerColor( Vector( 1, 0, 0 ) )

    ZombieFormEffects(target)
    target:Extinguish()
    target:Ignite( 9999, 256)
    ZombieFormEffects(target)
    sound.Play("npc/fast_zombie/fz_scream1.wav", target:GetPos(), 150, 100)
    ZombieFormEffects(target)

    target:StripWeapons()
    local ent = ents.Create("weapon_jm_equip_zombiemodemelee")
    if ent:IsValid() then
        ent:SetPos(target:GetPos())
        ent:Spawn()
    end

    target:SelectWeapon("weapon_jm_equip_zombiemodemelee")

end

-- Speed Buff
hook.Add("TTTPlayerSpeedModifier", "ZombieFormMoveSpeed", function(ply, _, _, speedMultiplierModifier)
	if not IsValid(ply)then return end
	if ply:GetNWBool(JM_BuffNWBool) == true then
	    speedMultiplierModifier[1] = speedMultiplierModifier[1] * 1.6
    end
end)

-- No fire damage on self
if SERVER then
    hook.Add("EntityTakeDamage", "ZombieFormFireDamage", function(target, dmginfo)
        if not IsValid(target) or not target:IsPlayer() or not dmginfo:IsDamageType(DMG_BURN) then return end

        if target:Alive() and target:IsTerror() then
	        if target:GetNWBool(JM_BuffNWBool) == true then
                dmginfo:ScaleDamage(0)
            end
        end
    end)
end

function ENT:Think()
    self.BaseClass.Think(self)

    

    -- Handle Buff Effect Ticking
    if(not self:IsValid()) then return end

    if(CurTime() >= self.buffTickNext) then
        self.buffTickNext = CurTime() + self.buffTickDelay
        self:BuffTickEffect()
    end

    -- Play Zombie Sounds
    if(CurTime() >= self.SoundbuffTickNext) then
        self.SoundbuffTickNext = CurTime() + math.random(self.SoundbuffTickDelay_Min, self.SoundbuffTickDelay_Max)
        sound.Play("npc/fast_zombie/fz_frenzy1.wav", self.targetPlayer:GetPos(), 110, 100)
    end
    

    -- Make sure they are holding Zombie Blade
    if  not self.targetPlayer:IsValid() or not self.targetPlayer:Alive() then return end
    self.targetPlayer:SelectWeapon("weapon_jm_equip_zombiemodemelee")

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