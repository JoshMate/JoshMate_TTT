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
		local gusSongDurationSeconds = math.random( 5, 80 )

		timer.Simple(gusSongDurationSeconds, function()

			if not self:IsValid() then return end

			local pos = self:GetPos()

			local effect = EffectData()
			effect:SetStart(pos)
			effect:SetOrigin(pos)
			util.Effect("Explosion", effect, true, true)
			util.Effect("HelicopterMegaBomb", effect, true, true)

			local JM_Gus_Explosive_Blast_Damage    = 120
			local JM_Gus_Explosive_Blast_Radius    = 3000

			-- Blast
			util.BlastDamage(self, self, pos, JM_Gus_Explosive_Blast_Radius, JM_Gus_Explosive_Blast_Damage)
			
			-- Done
			self:Remove()
		
		end)
	end

end



function ENT:Use( activator, caller )
end

function ENT:Think()
end
