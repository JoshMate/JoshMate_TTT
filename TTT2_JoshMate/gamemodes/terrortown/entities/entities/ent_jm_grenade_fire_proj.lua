-- burning nade projectile

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/w_eq_fraggrenade_thrown.mdl")

ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(255,255,0,150)

local JM_Explosive_Blast_Damage    = 35
local JM_Explosive_Blast_Radius    = 300

function ENT:Explode(tr)
   if SERVER then

      self:SetNoDraw(true)
      self:SetSolid(SOLID_NONE)

      -- pull out of the surface
      if tr.Fraction != 1.0 then
         self:SetPos(tr.HitPos + tr.HitNormal * 0.6)
      end
      
      local pos = self:GetPos()

      local effect = EffectData()
      effect:SetStart(pos)
      effect:SetOrigin(pos)
      util.Effect("Explosion", effect, true, true)
      util.Effect("HelicopterMegaBomb", effect, true, true)

      -- Blast
      local JMThrower = self:GetThrower()
      util.BlastDamage(self, JMThrower, pos, JM_Explosive_Blast_Radius, JM_Explosive_Blast_Damage)
      
      -- Done
      self:Remove()
   else
      local spos = self:GetPos()
      local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-128), filter=self})
      util.Decal("Scorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)      

      self:SetDetonateExact(0)
   end
end

