
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/w_eq_smokegrenade_thrown.mdl")

ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(255,255,255,150)


local JM_Tag_Radius  = 400


function ENT:HitEffectsInit(ent)
   if not IsValid(ent) then return end

   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   
   util.Effect("TeslaZap", effect, true, true)
   
   util.Effect("cball_explode", effect, true, true)
end

function ENT:Explode(tr)
   if (SERVER) then
      self.Entity:EmitSound(Sound("grenade_tag.wav"));
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
      
      self:GetOwner():ChatPrint("[Tag Grenade]: You tagged: " .. tostring(totalPeopleTagged) .. " people")
      self.Entity:Remove();
   end
   if (CLIENT) then
      if not IsValid(self) then return end
      local effect = EffectData()
      local ePos = self:GetPos()
      effect:SetStart(ePos)
      effect:SetOrigin(ePos)
      util.Effect("TeslaZap", effect, true, true)
      
      util.Effect("cball_explode", effect, true, true)
   end

end