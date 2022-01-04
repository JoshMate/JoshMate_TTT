-- burning nade projectile

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/props_junk/PopCan01a.mdl")

ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(200,150,0,150)

local JM_Explosive_Blast_Damage    = 8
local JM_Explosive_Blast_Radius    = 500


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
      util.Effect("cball_bounce", effect, true, true)

      self:EmitSound(Sound("firewall_arm.wav"), 100, 80, 1)

      -- Blast
      local JMThrower = self:GetThrower()
      util.BlastDamage(self, JMThrower, pos, JM_Explosive_Blast_Radius, JM_Explosive_Blast_Damage)

      -- Fire 
      local fire = ents.Create("ent_jm_base_fire")
      if not IsValid(fire) then return end
   
      fire:SetOwner(self:GetOwner())
      fire:SetPos(pos)
      fire:Spawn()
      
      -- Done
      self:Remove()
   else
      local spos = self:GetPos()
      local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-128), filter=self})
      util.Decal("Scorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)      

      self:SetDetonateExact(0)
   end
end

