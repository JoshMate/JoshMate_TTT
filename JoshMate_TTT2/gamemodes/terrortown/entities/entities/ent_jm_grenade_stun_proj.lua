-- burning nade projectile

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ent_jm_base_grenade"
ENT.Model = "models/weapons/csgonade/w_eq_flashbang_thrown.mdl"

ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(0,70,255,150)

local JM_FlashBang_Radius        = 500

-- Grenade Type Setting
ENT.GrenadeType_ExplodeOn_Impact    = false
ENT.GrenadeType_Fuse_Timer          = 2

-- Fix Scorch Spam
ENT.GreandeHasScorched              = false

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
      self.Entity:EmitSound(Sound("flashbang_explode.wav"));
      self:ExplodeEffects(self:GetPos())
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
               net.WriteBool(false)
               net.Send(self:GetOwner())
               -- End of Hit Markers
               

               -- Glue Effects
               self:HitEffectsInit(pl)
                      
            end

         end
      end
      JM_Function_PrintChat(self:GetOwner(), "Stun Grenade", "Hit: " .. tostring(totalPeopleFlashed) .. " people.")
      self.Entity:Remove();
   end
end