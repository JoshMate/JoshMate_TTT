AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName= "Suppression Wall"
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

local JM_Wall_LifeTime			= 60

local JM_Wall_Colour		= Color( 0, 80, 255, 255 )

local JM_Wall_Sound_Placed		= "weapons/ar2/ar2_reload_rotate.wav"
local JM_Wall_Sound_Destroyed	= "weapons/ar2/npc_ar2_altfire.wav"


function ENT:Wall_Effects_Sparks()
	if not IsValid(self) then return end
	local effect = EffectData()
	local ePos = self:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	util.Effect("cball_explode", effect, true, true)
end

function ENT:Wall_Die()
	if SERVER then
		if IsValid(self) then 
			self:Wall_Effects_Sparks()
			if SERVER then self:EmitSound(JM_Wall_Sound_Destroyed); end
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
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(false)
	end

	-- Visuals
	self:SetMaterial("joshmate/barrier")
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(JM_Wall_Colour) 
	self:DrawShadow(false)

	-- Timer
	self.wallDieTime = CurTime() + JM_Wall_LifeTime

	-- Play Place Sound
	if SERVER then self:EmitSound(JM_Wall_Sound_Placed); end
	
end

function ENT:Think()
	
	if CurTime() >= self.wallDieTime  then
        self:Wall_Die()
    end

end

function ENT:Touch(toucher)
	if IsValid(toucher) and toucher:IsPlayer() and IsValid(self) and toucher:IsTerror() and toucher:Alive() then

		if toucher:IsDetective() then return end

		-- Give the buff
		if not JM_CheckIfPlayerHasBuff("jm_buff_orb_suppression",toucher) then
			JM_GiveBuffToThisPlayer("jm_buff_orb_suppression",toucher,self:GetOwner())
			toucher:EmitSound("orb_suppression_hit.wav");
			-- Give a Hit Marker to This Player
			local hitMarkerOwner = self:GetOwner()
			JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)
		end

	end
end


