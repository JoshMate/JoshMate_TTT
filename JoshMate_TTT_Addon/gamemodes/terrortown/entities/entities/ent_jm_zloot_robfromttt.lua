AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Rob from TTT Contract"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Contract"
ENT.Instructions        = "Contract"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false


if CLIENT then
	return
end

function ENT:Initialize()

    self.rob = ents.Create("npc_zombie")
	self.rob:SetPos(self:GetPos())
    self.rob:Spawn()
	self.rob:SetMaxHealth(250)
    self.rob:SetHealth(250)
	self.rob:SetColor(Color( 255, 255, 200 ))
	self.rob:AddRelationship("player D_LI 99")
	self.rob:AddRelationship("prop_physics D_HT 99")

end

function ENT:Think()
	if SERVER then
		if self.rob:Health() <= 0 then
			JM_Function_PlaySound("radio_koen_scream.mp3")
			JM_Function_PrintChat_All("Care Package", "Rob from TTT has been murdered!")
			self:Remove()
		end
	end
end
