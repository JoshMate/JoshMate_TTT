-- burning nade projectile

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ent_jm_base_grenade"
ENT.Model = Model("models/props_junk/PopCan01a.mdl")

-- Name of Ent in kill messages
ENT.PrintName = "Inferno Launcher Bomb"

ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(200,150,0,150)

-- Grenade Type Setting
ENT.GrenadeType_ExplodeOn_Impact    = false
ENT.GrenadeType_Fuse_Timer          = 3

-- Fix Scorch Spam
ENT.GreandeHasScorched              = false

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
      local JMThrower = self:GetOwner()
      util.BlastDamage(self, JMThrower, pos, JM_Explosive_Blast_Radius, JM_Explosive_Blast_Damage)

      -- Fire 
      local fire = ents.Create("ent_jm_base_fire")
      if not IsValid(fire) then return end
   
      fire:SetOwner(nil)
      fire:SetPos(pos)
      fire:Spawn()
      
      -- Done
      self:Remove() 
   end
end

