AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Doom Dart"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Contract"
ENT.Instructions        = "Contract"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false

local JM_DoomDart_Explosive_Blast_Damage    = 100
local JM_DoomDart_Explosive_Blast_Radius    = 800

-- Fix Scorch Spam
ENT.GreandeHasScorched              = false


if CLIENT then
	return
end

function ENT:Initialize()
end

function ENT:Think()

	local hasdied = self.doomedTarget:IsValid()
	if self.targetIsPlayer then
		hasdied = hasdied and not self.doomedTarget:Alive()
	else
		hasdied = hasdied and self.doomedTarget:Health() <= 0
	end

	if hasdied then

		-- Decal Effects
		if (SERVER) then
			if self.GreandeHasScorched == false then 
			   self.GreandeHasScorched = true
			   local spos = self.doomedTarget:GetPos()
			   local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-128), filter=self})
				util.Decal("Cross", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)      
			end
		end

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

			self.doomedTarget:EmitSound("DoomDart.mp3", 120)

			JM_Function_PrintChat(self.doomedBy, "Equipment", self.deathMessage)

			self:Remove()

		end
	end

end


