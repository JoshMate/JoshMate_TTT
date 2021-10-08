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

    -- Target
    local target = self.targetPlayer

    -- Handle Sound Ticking
    self.SoundbuffTickDelay_Min     = 4
    self.SoundbuffTickDelay_Max     = 12
    self.SoundbuffTickNext          = CurTime() + math.random(self.SoundbuffTickDelay_Min, self.SoundbuffTickDelay_Max)

    -- Zombie HP
    local Zombie_HP_PerPerson       = 50
    local Zombie_HP_People          = 0
    local Zombie_HP_Final           = 0
    
    for _, ply in ipairs( player.GetAll() ) do
        if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
            Zombie_HP_People = Zombie_HP_People + 1
        end
    end

    Zombie_HP_Final = (Zombie_HP_People * Zombie_HP_PerPerson) + target:GetMaxHealth()

    target:SetMaxHealth(Zombie_HP_Final)
    target:SetHealth(Zombie_HP_Final)

    -- Zombie Form

	target:SetModel("models/player/zombie_fast.mdl")
    target:SetPlayerColor( Vector( 1, 0, 0 ) )

    ZombieFormEffects(target)
    sound.Play("npc/fast_zombie/fz_scream1.wav", target:GetPos(), 150, 100)

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
	    speedMultiplierModifier[1] = speedMultiplierModifier[1] * 1.5
    end
end)

function ENT:Think()
    self.BaseClass.Think(self)

    -- Play Zombie Sounds
    if(CurTime() >= self.SoundbuffTickNext) then
        self.SoundbuffTickNext = CurTime() + math.random(self.SoundbuffTickDelay_Min, self.SoundbuffTickDelay_Max)
        local RandChoice = math.random( 0, 15 )
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

        sound.Play(RandSound, self.targetPlayer:GetPos(), 110, 100)
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