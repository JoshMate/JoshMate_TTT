
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ent_jm_base_grenade"
ENT.Model = Model("models/props_lab/jar01b.mdl")

-- Name of Ent in kill messages
ENT.PrintName = "Glue Grenade"

ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(255, 255, 0, 150)

-- Grenade Type Setting
ENT.GrenadeType_ExplodeOn_Impact    = true

-- Fix Scorch Spam
ENT.GreandeHasScorched              = false

local JM_Tag_Radius  = 300


function ENT:HitEffectsInit(ent)
   if not IsValid(ent) then return end

   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   util.Effect("AntlionGib", effect, true, true)
end

function ENT:ExplodeEffects(pos)
   local effect = EffectData()
   effect:SetStart(pos)
   effect:SetOrigin(pos)
   util.Effect("AntlionGib", effect, true, true)
end

function ENT:Explode(tr)
   -- Decal Effects
   if (SERVER) then
      if self.GreandeHasScorched == false then 
         self.GreandeHasScorched = true
         local spos = self:GetPos()
         local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-128), filter=self})
         util.Decal("BeerSplash", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)
         util.Decal("YellowBlood", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)
      end
   end

   -- Server Side Mechanics
   if (SERVER) then
      self.Entity:EmitSound(Sound("grenade_glue.wav"));
      self:ExplodeEffects(self:GetPos())
      local totalPeopleTagged = 0

      for _,pl in pairs(player.GetAll()) do

         local playerPos = pl:GetShootPos()
         local nadePos = self:GetPos()

         -- Do to all players in radius
         if nadePos:Distance(playerPos) <= JM_Tag_Radius then
            if pl:IsTerror() and pl:Alive() then
               totalPeopleTagged = totalPeopleTagged + 1

               -- Give a Hit Marker to This Player
		         local hitMarkerOwner = self:GetOwner()
		         JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)

               -- Glue Effects
               self:HitEffectsInit(pl)
               
               JM_GiveBuffToThisPlayer("jm_buff_gluegrenade",pl,self:GetOwner())
               -- End Of
            end
         end
      end
      
      -- Done
      self:Remove()
   end
end