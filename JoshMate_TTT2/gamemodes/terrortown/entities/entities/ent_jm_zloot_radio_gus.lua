AddCSLuaFile()

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

ENT.Type                        = "anim"
ENT.PrintName                   = "Gus Radio"
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

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(true)
	end

	if SERVER then
		self:EmitSound("Yeah_Gus_Is_My_Name.mp3")
		local gusSongDurationSeconds = 85

		timer.Simple(gusSongDurationSeconds, function()

			if not self:IsValid() then return end
			-- Done
			self:Remove()
		
		end)
	end

end



function ENT:Use( activator, caller )
end

function ENT:Think()
end
