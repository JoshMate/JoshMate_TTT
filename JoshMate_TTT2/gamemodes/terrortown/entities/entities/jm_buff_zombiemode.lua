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

    -- Handle Buff Effect Ticking
    if(not self:IsValid()) then return end

    if  not self.targetPlayer:IsValid() or not self.targetPlayer:Alive() then return end

    if(CurTime() >= self.buffTickNext) then
        self.buffTickNext = CurTime() + self.buffTickDelay
        self:BuffTickEffect()
    end
    
end

function ZombieFormEffects(ent)
	if not IsValid(ent) then return end
 
	local effect = EffectData()
	local ePos = ent:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	
	
	util.Effect("cball_explode", effect, true, true)
end


function ENT:Initialize()

    self.BaseClass.Initialize(self)

    -- Target
    local target = self.targetPlayer

    -- Handle Sound Ticking
    self.SoundbuffTickDelay_Min     = 4
    self.SoundbuffTickDelay_Max     = 12
    self.SoundbuffTickNext          = CurTime() + math.random(self.SoundbuffTickDelay_Min, self.SoundbuffTickDelay_Max)

    -- Zombie HP
    target:SetMaxHealth(target:GetMaxHealth() + 100)
    target:SetHealth(target:Health() + 100)

    -- Zombie Form

	target:SetModel("models/player/zombie_fast.mdl")
    target:SetPlayerColor( Vector( 1, 0, 0 ) )

    ZombieFormEffects(target)
    sound.Play("npc/fast_zombie/fz_scream1.wav", target:GetPos(), 150, 100)

end

function ENT:Think()
    self.BaseClass.Think(self)

    -- Handle Buff Effect Ticking
    if(not self:IsValid()) then return end

    -- Play Zombie Sounds
    if(CurTime() >= self.SoundbuffTickNext) then
        self.SoundbuffTickNext = CurTime() + math.random(self.SoundbuffTickDelay_Min, self.SoundbuffTickDelay_Max)
        local RandChoice = math.random( 0, 20 )
        local RandSound = nil
        if (RandChoice == 0) then RandSound = "npc/fast_zombie/fz_frenzy1.wav" end
        if (RandChoice == 1) then RandSound = "npc/fast_zombie/fz_frenzy1.wav" end
        if (RandChoice == 2) then RandSound = "npc/fast_zombie/fz_frenzy1.wav" end
        if (RandChoice == 3) then RandSound = "npc/fast_zombie/fz_frenzy1.wav" end
        if (RandChoice == 4) then RandSound = "npc/fast_zombie/fz_frenzy1.wav" end
        if (RandChoice == 5) then RandSound = "npc/fast_zombie/fz_frenzy1.wav" end
        if (RandChoice == 6) then RandSound = "npc/zombie/zombie_voice_idle1.wav" end
        if (RandChoice == 7) then RandSound = "npc/zombie/zombie_voice_idle2.wav" end
        if (RandChoice == 8) then RandSound = "npc/zombie/zombie_voice_idle3.wav" end
        if (RandChoice == 9) then RandSound = "npc/zombie/zombie_voice_idle4.wav" end
        if (RandChoice == 10) then RandSound = "npc/zombie/zombie_voice_idle5.wav" end
        if (RandChoice == 11) then RandSound = "npc/zombie/zombie_voice_idle6.wav" end
        if (RandChoice == 12) then RandSound = "npc/zombie/zombie_voice_idle7.wav" end
        if (RandChoice == 13) then RandSound = "npc/zombie/zombie_voice_idle8.wav" end
        if (RandChoice == 14) then RandSound = "npc/zombie/zombie_voice_idle9.wav" end
        if (RandChoice == 15) then RandSound = "npc/zombie/zombie_voice_idle10.wav" end
        if (RandChoice == 16) then RandSound = "npc/fast_zombie/fz_alert_close1.wav" end
        if (RandChoice == 17) then RandSound = "npc/fast_zombie/fz_alert_close1.wav" end
        if (RandChoice == 18) then RandSound = "npc/fast_zombie/fz_alert_close1.wav" end
        if (RandChoice == 19) then RandSound = "npc/fast_zombie/fz_alert_close1.wav" end
        if (RandChoice == 20) then RandSound = "npc/fast_zombie/fz_alert_close1.wav" end
        

        sound.Play(RandSound, self.targetPlayer:GetPos(), 110, 100)
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