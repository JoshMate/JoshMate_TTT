
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/w_eq_flashbang_thrown.mdl")

ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(0,255,0,150)

local JM_Jump_Radius       = 350
local JM_Jump_Force        = 500

function ENT:Explode(tr)
   if (SERVER) then
      self.Entity:EmitSound(Sound("grenade_jump.wav"))

      local pl = self:GetOwner()
      local playerPos = pl:GetShootPos()
      local nadePos = self:GetPos()

      if nadePos:Distance(playerPos) <= JM_Jump_Radius then


         if pl:IsTerror() and pl:Alive() then

            -- Hit Markers
            net.Start( "hitmarker" )
            net.WriteFloat(0)
            net.Send(pl)
            -- End of Hit Markers
            
            local vel = pl:GetVelocity()
            vel.z = vel.z + JM_Jump_Force

            pl:SetVelocity(vel)

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

function ENT:PhysicsCollide(tr)
	self:SetExplodeTime(CurTime())
end