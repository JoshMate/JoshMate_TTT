
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/w_eq_smokegrenade_thrown.mdl")

ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(255,255,255,150)


local JM_Tag_Radius  = 400

local JM_Tag_Duration = 2
local JM_Tag_Colour = Color( 255, 255, 255 )

function ENT:HitEffectsInit(ent)
   if not IsValid(ent) then return end

   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   
   util.Effect("TeslaZap", effect, true, true)
   util.Effect("TeslaHitboxes", effect, true, true)
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
               net.Send(self:GetOwner())
               -- End of Hit Markers

               -- Wall Hack
               self:HitEffectsInit(pl)
               STATUS:AddTimedStatus(pl, "jm_tag", JM_Tag_Duration, 1)

               if(timer.Exists(("timer_Tag_RemoveTimer" .. pl:SteamID64()))) then timer.Remove(("timer_Tag_RemoveTimer" .. pl:SteamID64())) end
               timer.Create(("timer_Tag_RemoveTimer" .. pl:SteamID64()), JM_Tag_Duration, 1,function() 
                     if (not pl:IsValid() or not pl:IsPlayer()) then timer.Remove(("timer_Tag_RemoveTimer" .. pl:SteamID64())) return end
                     pl:SetNWBool("isTagged", false)
                     timer.Remove(("timer_Tag_RemoveTimer" .. pl:SteamID64()))
               end)
               pl:SetNWBool("isTagged", true)
               pl:ChatPrint("[Tag Grenade] - You are being tracked!")     
            end

         end
      end
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


-- ESP Halo effect
hook.Add( "PreDrawHalos", "Halos_Tag_Grenade", function()

   local players = {}
	local count = 0

	for _, ply in ipairs( player.GetAll() ) do
		if (ply:IsTerror() and ply:Alive() and ply:GetNWBool("isTagged") ) then
            count = count + 1
			players[ count ] = ply
		end
	end

    halo.Add( players, JM_Tag_Colour, 5, 5, 2, true, true )

end )