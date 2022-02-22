-- burning nade projectile

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ent_jm_base_grenade"
ENT.Model = Model("models/weapons/w_eq_fraggrenade_thrown.mdl")

-- Name of Ent in kill messages
ENT.PrintName = "Frag Grenade"

ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(255,0,0,150)

-- Grenade Type Setting
ENT.GrenadeType_ExplodeOn_Impact    = false
ENT.GrenadeType_Fuse_Timer          = 2

-- Fix Scorch Spam
ENT.GreandeHasScorched              = false

local JM_Explosive_Blast_Damage    = 60
local JM_Explosive_Blast_Radius    = 400

function ENT:Explode(tr)
   -- Server Side Mechanics
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
      local JMThrower = self:GetOwner()
      util.BlastDamage(self, JMThrower, pos, JM_Explosive_Blast_Radius, JM_Explosive_Blast_Damage)
      
      -- Done
      self:Remove()
   end
end

