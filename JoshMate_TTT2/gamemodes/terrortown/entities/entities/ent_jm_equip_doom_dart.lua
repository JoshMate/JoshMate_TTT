AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Doom Dart"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Contract"
ENT.Instructions        = "Contract"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false

local JM_DoomDart_Explosive_Blast_Damage    = 80
local JM_DoomDart_Explosive_Blast_Radius    = 500


if CLIENT then
	return
end

function ENT:Initialize()
end

function ENT:Think()

	if self.doomedTarget:IsValid() and not self.doomedTarget:Alive() then

		if SERVER then 
			local pos = self.doomedTarget:GetPos()

			local effect = EffectData()
			effect:SetStart(pos)
			effect:SetOrigin(pos)
			util.Effect("Explosion", effect, true, true)
			util.Effect("HelicopterMegaBomb", effect, true, true)

			-- Blast
			local JMThrower = self.doomedBy
			util.BlastDamage(self, JMThrower, pos, JM_DoomDart_Explosive_Blast_Radius, JM_DoomDart_Explosive_Blast_Damage)

			self.doomedTarget:EmitSound("DoomDart.mp3")

			self.doomedBy:ChatPrint("[Doom Dart]: " .. self.doomedTarget:Nick() .. " Has Exploded!" )

			self:Remove()

		end

		if CLIENT then
			local spos = self.doomedTarget:GetPos()
			local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-128), filter=self})
			util.Decal("Scorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)   
		end

	end

end


