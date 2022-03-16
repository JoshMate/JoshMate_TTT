AddCSLuaFile()

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

ENT.Type                        = "anim"
ENT.PrintName                   = "A Bird Flew In Radio"
ENT.Author                      = "Josh Mate"
ENT.Purpose                     = "Ent"
ENT.Instructions                = "Ent"
ENT.Spawnable                   = false
ENT.AdminSpawnable              = false

function ENT:Initialize()
	self:SetModel("models/props/cs_office/radio.mdl") 
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(true)
	end

	if SERVER then
		self:EmitSound("radio_birdflewin.mp3", 110, 100, 1, CHAN_AUTO)
	end

end



function ENT:Use( activator, caller )
end

function ENT:Think()
end