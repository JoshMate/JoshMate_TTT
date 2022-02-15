
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ent_jm_base_grenade"
ENT.Model = Model("models/weapons/w_eq_smokegrenade.mdl")

ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(255, 255, 255, 150)

-- Grenade Type Setting
ENT.GrenadeType_ExplodeOn_Impact    = false
ENT.GrenadeType_Fuse_Timer          = 2

-- Fix Scorch Spam
ENT.GreandeHasScorched              = false


local JM_Tag_Radius  = 400


function ENT:HitEffectsInit(ent)
   if not IsValid(ent) then return end

   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   util.Effect("cball_explode", effect, true, true)
end

function ENT:ExplodeEffects(pos)
   local effect = EffectData()
   effect:SetStart(pos)
   effect:SetOrigin(pos)
   util.Effect("cball_explode", effect, true, true)
end

function ENT:Explode(tr)

   -- Decal Effects
   if (SERVER) then
      if self.GreandeHasScorched == false then 
         self.GreandeHasScorched = true
         local spos = self:GetPos()
         local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-128), filter=self})
         util.Decal("Splash.Large", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)      
      end
   end

   -- Server Side Mechanics
   if (SERVER) then
      self.Entity:EmitSound(Sound("grenade_tag.wav"));
      self:ExplodeEffects(self:GetPos())
      local totalPeopleTagged = 0
      for _,pl in pairs(player.GetAll()) do

         if pl == self:GetOwner() then continue end

         local playerPos = pl:GetShootPos()
         local nadePos = self:GetPos()

         -- Do to all players in radius
         if nadePos:Distance(playerPos) <= JM_Tag_Radius then


            if pl:IsTerror() and pl:Alive() then
               totalPeopleTagged = totalPeopleTagged + 1

               -- Hit Markers
               net.Start( "hitmarker" )
               net.WriteFloat(0)
               net.WriteBool(false)
               net.Send(self:GetOwner())
               -- End of Hit Markers

               -- Wall Hack
               self:HitEffectsInit(pl)
               -- Set Status and print Message
               
               JM_GiveBuffToThisPlayer("jm_buff_taggrenade",pl,self:GetOwner())
               -- End Of
            end

         end
      end
      JM_Function_PrintChat(self:GetOwner(), "Tag Grenade", "Hit: " .. tostring(totalPeopleTagged) .. " people.")
      -- Done
      self:Remove()
   end

end