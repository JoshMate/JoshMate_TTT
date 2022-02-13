
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ent_jm_base_grenade"
ENT.Model = Model("models/props_lab/jar01b.mdl")

ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(255, 255, 0, 150)

-- Grenade Type Setting
ENT.GrenadeType_ExplodeOn_Impact    = true


local JM_Tag_Radius  = 250


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
   if (SERVER) then
      self.Entity:EmitSound(Sound("grenade_glue.wav"));
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

               -- Glue Effects
               self:HitEffectsInit(pl)
               
               JM_GiveBuffToThisPlayer("jm_buff_gluegrenade",pl,self:GetOwner())
               -- End Of
            end

         end
      end
      
      self:GetOwner():ChatPrint("[Glue Grenade]: You glued: " .. tostring(totalPeopleTagged) .. " people")
      self.Entity:Remove();
   end
end