AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName= "Fire Orb"
ENT.Author= "Josh Mate"
ENT.Purpose= "Blinder"
ENT.Instructions= "Blinder"
ENT.Spawnable = true
ENT.AdminSpawnable = false

local fireOrb_Duration				= 60
local fireOrb_ArmTime				= 4
local fireOrb_Radius_Slow			= 230
local fireOrb_Delay_Tick			= 0.35
local fireOrb_Damage				= 8

local fireOrb_Sound_Deploy			= "firewall_destroy.wav"
local fireOrb_Sound_Arm				= "firewall_arm.wav"
local fireOrb_Sound_Destroy			= "firewall_place.wav"
local fireOrb_Sound_Hit				= "firewall_hit_small.wav"

local fireOrb_Colour				= Color( 150, 0, 0, 150 )


ENT.Model = Model("models/props_phx/construct/metal_dome360.mdl")

function ENT:fireOrbRadiusEffects()

	if CLIENT then return end
	
	if not self:IsValid() then return end

	local r = fireOrb_Radius_Slow * fireOrb_Radius_Slow -- square so we can compare with dot product directly
	local center = self:GetPos()

	-- Heal Players in radius
	d = 0.0
	diff = nil
	local plys = player.GetAll()

	for i = 1, #plys do
		local ply = plys[i]
		
		if not ply:Team() == TEAM_TERROR  or not ply:Alive() then continue end

		-- dot of the difference with itself is distance squared
		diff = center - ply:GetPos()
		d = diff:Dot(diff)

		if d >= r then continue end

		-- Give the buff
		if not JM_CheckIfPlayerHasBuff("jm_buff_fireorb",ply) then
			JM_GiveBuffToThisPlayer("jm_buff_fireorb",ply,self.Owner)
			self:EmitSound(fireOrb_Sound_Hit);
		end
		
		-- Deal More damage the close to the centre you are
		local finalFireOrbDamage = fireOrb_Damage * (1 - (d/r))

		local dmginfo = DamageInfo()
		dmginfo:SetDamage(finalFireOrbDamage)
		dmginfo:SetAttacker(self.Owner)
		local inflictor = self
		dmginfo:SetInflictor(inflictor)
		dmginfo:SetDamageType(DMG_BURN)
		dmginfo:SetDamagePosition(self:GetPos())
		ply:TakeDamageInfo(dmginfo)

	end

end


function ENT:Initialize()

	-- Play Place Sound
	self:EmitSound(fireOrb_Sound_Deploy);
	
	-- Timers
	self.fireOrbTimeCreated		= CurTime()
	self.fireOrbLastTickTime 	= 0
	self.fireOrbIsArmed			= false

	-- Model Stuff
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:SetMaterial("joshmate/barrier")
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(fireOrb_Colour) 
	self:DrawShadow(false)
	self:SetModelScale(0.1, 0)
	self:SetModelScale(4, fireOrb_ArmTime)

	-- Create spark effects on start	 
	local effect = EffectData()
	local ePos = self:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	util.Effect("cball_explode", effect, true, true)

end

function ENT:Think()

	-- Arm Timer
	if self.fireOrbIsArmed == false and CurTime() >= (self.fireOrbTimeCreated + fireOrb_ArmTime) then
		self.fireOrbIsArmed = true
		self:EmitSound(fireOrb_Sound_Arm);
		self:SetMaterial("models/props_lab/Tank_Glass001")
	end

	-- Smoke Effect Tick
	if self.fireOrbIsArmed == true and CurTime() >= (self.fireOrbLastTickTime + fireOrb_Delay_Tick) then
		self:fireOrbRadiusEffects()
		self.fireOrbLastTickTime = CurTime()
		
	end

	-- Delete Smoke after time is up
	if CurTime() >= (self.fireOrbTimeCreated + fireOrb_Duration) then
		if SERVER then 
			self:EmitSound(fireOrb_Sound_Destroy);
			self:Remove()
		end
	end
end
