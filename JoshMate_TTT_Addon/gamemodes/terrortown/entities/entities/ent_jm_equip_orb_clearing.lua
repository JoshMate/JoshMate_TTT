AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName= "Suppression Orb"
ENT.Author= "Josh Mate"
ENT.Purpose= "Blinder"
ENT.Instructions= "Blinder"
ENT.Spawnable = true
ENT.AdminSpawnable = false

local suppressionOrb_Duration				= 30
local suppressionOrb_ArmTime				= 2.5
local suppressionOrb_Radius_Slow			= 280
local suppressionOrb_Delay_Tick				= 0.35
local suppressionOrb_Damage					= 8

local suppressionOrb_Sound_Deploy			= "orb_suppression_deploy.wav"
local suppressionOrb_Sound_Arm				= "orb_suppression_arm.wav"
local suppressionOrb_Sound_Destroy			= "orb_suppression_destroy.wav"
local suppressionOrb_Sound_Hit				= "orb_suppression_hit.wav"

local suppressionOrb_Colour				= Color( 0, 150, 255, 255 )


ENT.Model = Model("models/props_phx/construct/metal_dome360.mdl")

function ENT:HitEffectsInit(ent)
	if not IsValid(ent) then return end
 
	local effect = EffectData()
	local ePos = ent:GetPos()
	if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	util.Effect("cball_explode", effect, true, true)
 end

function ENT:clearingOrbClearItem(thing)

	-- Workout Radius
	local r = suppressionOrb_Radius_Slow * suppressionOrb_Radius_Slow -- square so we can compare with dot product directly
	local center = self:GetPos()
	d = 0.0
	diff = nil

	-- Check Distance
	-- dot of the difference with itself is distance squared
	diff = center - thing:GetPos()
	d = diff:Dot(diff)
	if d >= r then return end

	-- Check for protected props
	if thing:GetClass() == "prop_physics" then
		if thing:GetName() == "" then
			thing:EmitSound(suppressionOrb_Sound_Hit);
			self:HitEffectsInit(thing)
			thing:Remove()
		end
	else
		thing:EmitSound(suppressionOrb_Sound_Hit);
		self:HitEffectsInit(thing)
		thing:Remove()
	end
	
	

end

function ENT:suppressionOrbRadiusEffects()

	if CLIENT then return end
	
	if not self:IsValid() then return end

	-- Clear Items Caught in radius
	for k, v in ipairs( ents.FindByClass( "prop_physics" ) ) do self:clearingOrbClearItem(v) end
	for k, v in ipairs( ents.FindByClass( "npc_*" ) ) do self:clearingOrbClearItem(v) end
	for k, v in ipairs( ents.FindByClass( "ent_jm_grenade_*" ) ) do self:clearingOrbClearItem(v) end
	for k, v in ipairs( ents.FindByClass( "ent_jm_equip_throwing_knife" ) ) do self:clearingOrbClearItem(v) end
	for k, v in ipairs( ents.FindByClass( "ent_jm_equip_orb_fire" ) ) do self:clearingOrbClearItem(v) end
	for k, v in ipairs( ents.FindByClass( "ent_jm_barrier_traitor" ) ) do self:clearingOrbClearItem(v) end
	for k, v in ipairs( ents.FindByClass( "ent_jm_grenade_infernolaunch*" ) ) do self:clearingOrbClearItem(v) end
	for k, v in ipairs( ents.FindByClass( "ent_jm_equip_beartrap" ) ) do self:clearingOrbClearItem(v) end
	for k, v in ipairs( ents.FindByClass( "ent_jm_equip_soap" ) ) do self:clearingOrbClearItem(v) end
	for k, v in ipairs( ents.FindByClass( "ent_jm_equip_landmine" ) ) do self:clearingOrbClearItem(v) end
	

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
	self:SetModelScale(5, suppressionOrb_ArmTime)

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
