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

local JM_Barrier_Colour				= Color( 255, 0, 0, 255 )
local JM_Barrier_Colour_Dormant		= Color( 0, 0, 0, 0 )

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
	self:SetSolid( SOLID_NONE )
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

	-- Visuals
	self:SetMaterial("joshmate/barrier")
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(JM_Barrier_Colour_Dormant) 
	self:DrawShadow(false)

	-- Set stats
	self.barrierIsActivated = false

	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(true,self:EntIndex(),"icon_warn_barrier",self:GetPos(),0,1)

	
end

function ENT:BarrierActivate()

	if self.barrierIsActivated == true then return end

	-- Collisions and Phyiscs
	self:SetModel( "models/hunter/plates/plate4x6.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_NONE)

	-- Visuals
	self:SetMaterial("joshmate/barrier")
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(JM_Barrier_Colour) 
	self:DrawShadow(false)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(false)
	end

	-- Set Stats
	self.barrierTimeItWillDie = CurTime() + JM_Barrier_LifeTime
	self.barrierIsActivated = true

	-- Play Place Sound
	if SERVER then self:EmitSound(JM_Barrier_Sound_Placed); end

	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(false,self:EntIndex())

end

function ENT:Think()

	if self.barrierIsActivated == false then return end
	
	if CurTime() >= self.barrierTimeItWillDie then
        self:Barrier_Die()
    end

end

function ENT:OnRemove()
	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())
end


