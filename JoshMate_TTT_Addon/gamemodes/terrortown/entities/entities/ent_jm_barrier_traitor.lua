AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName= "Barrier"
ENT.Author= "Josh Mate"
ENT.Purpose= "Blocker"
ENT.Instructions= "Blocker"
ENT.Spawnable = true
ENT.AdminSpawnable = false

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

local JM_Barrier_LifeTime			= 30

local JM_Barrier_Colour				= Color( 255, 0, 0, 200 )

local JM_Barrier_Sound_Placed		= "shoot_barrel.mp3"
local JM_Barrier_Sound_Destroyed	= "weapons/ar2/npc_ar2_altfire.wav"


function ENT:Barrier_Effects_Sparks()
	if not IsValid(self) then return end
	local effect = EffectData()
	local ePos = self:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	util.Effect("cball_explode", effect, true, true)
end

function ENT:Barrier_Die()
	if SERVER then
		if IsValid(self) then 
			self:Barrier_Effects_Sparks()
			self:EmitSound(JM_Barrier_Sound_Destroyed)
			self:Remove()
		end 
	end
end

function ENT:Initialize()

	-- Collisions and Phyiscs
	self:SetModel( "models/hunter/plates/plate4x6.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_NONE)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(false)
	end

	-- Visuals
	self:SetMaterial("joshmate/barrier")
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(JM_Barrier_Colour) 
	self:DrawShadow(false)

	-- Set Stats
	self.barrierTimeItWillDie = CurTime() + JM_Barrier_LifeTime

	-- Play Place Sound
	if SERVER then self:EmitSound(JM_Barrier_Sound_Placed); end
	
end

function ENT:Think()
	
	if CurTime() >= self.barrierTimeItWillDie then
        self:Barrier_Die()
    end

end


