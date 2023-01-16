AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Prop Bomb"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Contract"
ENT.Instructions        = "Contract"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false

local JM_PropBomb_Explosive_Blast_Damage    = 75
local JM_PropBomb_Explosive_Blast_Radius    = 600
local JM_PropBomb_Explosive_Blast_Delay     = 3

-- Fix Scorch Spam
ENT.GreandeHasScorched              = false


if CLIENT then
	return
end

function ENT:Initialize()

	self.propBombDetTime = CurTime() + JM_PropBomb_Explosive_Blast_Delay
	self.propBombProp:Ignite(3, 200)
	self.propBombProp:SetColor(Color(255, 0, 0, 255)) 
	self.propBombProp:EmitSound("propbomb_shoot.wav")

end

function ENT:PropBombExplode()

	-- Decal Effects
	if (SERVER) then
		if self.GreandeHasScorched == false then 
		   self.GreandeHasScorched = true
		   local spos = self.propBombProp:GetPos()
		   local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-128), filter=self})
			util.Decal("Cross", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)      
		end
	end

	if SERVER then 
		local pos = self.propBombProp:GetPos()

		-- Remove Prop
		if self.propBombProp:GetName() == "" then
			self.propBombProp:Remove()
		end

		local effect = EffectData()
		effect:SetStart(pos)
		effect:SetOrigin(pos)
		util.Effect("Explosion", effect, true, true)
		util.Effect("HelicopterMegaBomb", effect, true, true)
		
		-- Give a debuff to players caught in blast
		local plys = player.GetAll()
		for i = 1, #plys do
			local ply = plys[i]
			if ply:IsValid() and ply:IsTerror() and ply:Alive() then
				if ply:GetPos():Distance(self:GetPos()) <= JM_PropBomb_Explosive_Blast_Radius then
					-- Disorientated Debuff on Explosion
					if (SERVER) then
						JM_GiveBuffToThisPlayer("jm_buff_explosion",ply,self.propBombOwner)
					end
				end
			end
		end

		-- Blast
		util.BlastDamage(self, self.propBombOwner, pos, JM_PropBomb_Explosive_Blast_Radius, JM_PropBomb_Explosive_Blast_Damage)

		-- Visual Effects
		self.propBombProp:Extinguish()
		self.propBombProp:SetColor(Color(25, 25, 25, 255)) 

		
		self:Remove()
		

	end

end

function ENT:Think()

	if CurTime() >= self.propBombDetTime then
		self:PropBombExplode()
	end

end
