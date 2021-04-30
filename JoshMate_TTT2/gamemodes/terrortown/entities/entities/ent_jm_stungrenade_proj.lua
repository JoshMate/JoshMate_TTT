-- burning nade projectile

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = "models/weapons/csgonade/w_eq_flashbang_thrown.mdl"

ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(0,70,255,150)

local JM_FlashBang_Radius        = 500


function ENT:Explode(tr)
   if (SERVER) then
      self.Entity:EmitSound(Sound("flashbang_explode.wav"));
      local totalPeopleFlashed = 0
      for _,pl in pairs(player.GetAll()) do

         local playerPos = pl:GetShootPos()
         local nadePos = self:GetPos()

         -- Do to all players in radius
         if nadePos:Distance(playerPos) <= JM_FlashBang_Radius then

            -- Apply Blind (If the grenade can see them)
            local tracedata = {}
            tracedata.start = nadePos
            tracedata.endpos = playerPos
            tracedata.filter = function( ent ) if ( ent:GetClass() == "prop_physics" ) or ( ent:GetClass() == "prop_ragdoll" ) then return true end end
            local tr = util.TraceLine(tracedata)

            if not tr.HitWorld and pl:IsTerror() and pl:Alive() then
               totalPeopleFlashed = totalPeopleFlashed + 1

               -- Set Status and print Message
               JM_RemoveBuffFromThisPlayer("jm_buff_stungrenade",ent)
               JM_GiveBuffToThisPlayer("jm_buff_stungrenade",pl,self:GetOwner())
               -- End Of

               -- Hit Markers
               net.Start( "hitmarker" )
               net.WriteFloat(0)
               net.Send(self:GetOwner())
               -- End of Hit Markers
                      
            end

         end
      end
      self:GetOwner():ChatPrint("[Stun Grenade]: You stunned: " .. tostring(totalPeopleFlashed) .. " people")
      self.Entity:Remove();
   end
   if (CLIENT) then
      if not IsValid(self) then return end
      local effect = EffectData()
      local ePos = self:GetPos()
      effect:SetStart(ePos)
      effect:SetOrigin(ePos)
      util.Effect("TeslaZap", effect, true, true)
      util.Effect("TeslaHitboxes", effect, true, true)
      util.Effect("cball_explode", effect, true, true)
   end

end