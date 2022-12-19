AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName= "Suppression Orb"
ENT.Author= "Josh Mate"
ENT.Purpose= "Blinder"
ENT.Instructions= "Blinder"
ENT.Spawnable = true
ENT.AdminSpawnable = false

local suppressionOrb_Duration				= 60
local suppressionOrb_ArmTime				= 2.5
local suppressionOrb_Radius_Slow			= 230
local suppressionOrb_Delay_Tick				= 0.35
local suppressionOrb_Damage					= 8

local suppressionOrb_Sound_Deploy			= "orb_suppression_deploy.wav"
local suppressionOrb_Sound_Arm				= "orb_suppression_arm.wav"
local suppressionOrb_Sound_Destroy			= "orb_suppression_destroy.wav"
local suppressionOrb_Sound_Hit				= "orb_suppression_hit.wav"

local suppressionOrb_Colour				= Color( 0, 150, 255, 255 )


ENT.Model = Model("models/props_phx/construct/metal_dome360.mdl")

function ENT:suppressionOrbRadiusEffects()

	if CLIENT then return end
	
	if not self:IsValid() then return end

	local r = suppressionOrb_Radius_Slow * suppressionOrb_Radius_Slow -- square so we can compare with dot product directly
	local center = self:GetPos()

	-- Heal Players in radius
	d = 0.0
	diff = nil
	local plys = player.GetAll()

	for i = 1, #plys do
		local ply = plys[i]
		
		if not ply:Team() == TEAM_TERROR  or not ply:Alive() or ply:IsDetective() then continue end

		-- dot of the difference with itself is distance squared
		diff = center - ply:GetPos()
		d = diff:Dot(diff)

		if d >= r then continue end

		-- Give the buff
		if not JM_CheckIfPlayerHasBuff("jm_buff_orb_suppression",ply) then
			JM_GiveBuffToThisPlayer("jm_buff_orb_suppression",ply,self.Owner)
			ply:EmitSound(suppressionOrb_Sound_Hit);
			-- Give a Hit Marker to This Player
			local hitMarkerOwner = self:GetOwner()
			JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)
		end

	end

end


function ENT:Initialize()

	-- Play Place Sound
	self:EmitSound(suppressionOrb_Sound_Deploy);
	
	-- Timers
	self.suppressionOrbTimeCreated		= CurTime()
	self.suppressionOrbLastTickTime 	= 0
	self.suppressionOrbIsArmed			= false

	-- Model Stuff
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:SetMaterial("joshmate/barrier")
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(suppressionOrb_Colour) 
	self:DrawShadow(false)
	self:SetModelScale(0.1, 0)
	self:SetModelScale(4, suppressionOrb_ArmTime)

	-- Create spark effects on start	 
	local effect = EffectData()
	local ePos = self:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	util.Effect("cball_explode", effect, true, true)

end

function ENT:Think()

	-- Arm Timer
	if self.suppressionOrbIsArmed == false and CurTime() >= (self.suppressionOrbTimeCreated + suppressionOrb_ArmTime) then
		self.suppressionOrbIsArmed = true
		self:EmitSound(suppressionOrb_Sound_Arm);
		self:SetMaterial("Models/effects/comball_sphere")
	end

	-- Smoke Effect Tick
	if self.suppressionOrbIsArmed == true and CurTime() >= (self.suppressionOrbLastTickTime + suppressionOrb_Delay_Tick) then
		self:suppressionOrbRadiusEffects()
		self.suppressionOrbLastTickTime = CurTime()
		
	end

	-- Delete Smoke after time is up
	if CurTime() >= (self.suppressionOrbTimeCreated + suppressionOrb_Duration) then
		if SERVER then 
			self:EmitSound(suppressionOrb_Sound_Destroy);
			self:Remove()
		end
	end
end
