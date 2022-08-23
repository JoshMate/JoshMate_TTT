AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Hook Rope"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Grappling Hook"
ENT.Instructions        = "Grappling Hook"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false


if CLIENT then
	return
end

function ENT:Initialize()
	
end

function ENT:Think()
 
	if self.hookOwner:IsValid() and self.hookOwner:IsPlayer() and self.hookOwner:IsTerror() then


		if self.hookOwner:GetPos():Distance(self.hookHitPos) <= 64 then return end

		-- Add Jump Velcity
		local vel = self.hookOwner:GetVelocity()

		vel = self.hookOwner:GetPos():Cross(self.hookHitPos)
		vel:Normalize()
		vel:Mul(100)

		JM_Function_PrintChat(self.hookOwner, "Grapple Hook", "Hooked to: " .. tostring(vel))
		
		self.hookOwner:SetVelocity(vel)

	end

end


