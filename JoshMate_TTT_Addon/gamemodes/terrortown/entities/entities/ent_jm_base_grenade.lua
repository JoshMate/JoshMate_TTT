-- common grenade projectile code

AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_eq_flashbang_thrown.mdl")

-- Trail Settings

ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(255,255,255,150)
ENT.Trail_StartWidth = 5
ENT.Trail_EndWidth = 1

-- Grenade Type Setting
ENT.GrenadeType_ExplodeOn_Impact    = false
ENT.GrenadeType_Fuse_Timer          = 2


function ENT:Initialize()

   if SERVER then
      if self.Trail_Enabled then
         if IsValid(self) then 
            util.SpriteTrail( self, 0, self.Trail_Colour, true, self.Trail_StartWidth, self.Trail_EndWidth, 0.5, (1 / ( self.Trail_StartWidth + self.Trail_EndWidth ) * 0.5), "sprites/laserbeam" )
         end
   end
   end

   self:SetModel(self.Model)

   self:PhysicsInit(SOLID_VPHYSICS)
   self:SetMoveType(MOVETYPE_VPHYSICS)
   self:SetSolid(SOLID_BBOX)
   self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

   -- Fuse Timings
   self.GreandeSpawnTime = CurTime()

end

-- override to describe what happens when the nade explodes
function ENT:Explode(tr)
   ErrorNoHalt("ERROR: BaseGrenadeProjectile explosion code not overridden!\n")
end

function ENT:PhysicsCollide(data,phys)
	if data.Speed > 50 then
		self.Entity:EmitSound(Sound("flashbang_collide.wav"))
	end
	
	local lollol = -data.Speed * data.HitNormal * .1 + (data.OurOldVelocity * -0.6)
	phys:ApplyForceCenter(lollol)

   if self.GrenadeType_ExplodeOn_Impact == true then
      self:Explode(data)
   end
end

function ENT:Think()
   local etime = self.GreandeSpawnTime + self.GrenadeType_Fuse_Timer or 0
   if etime != 0 and etime < CurTime() then
      -- if thrower disconnects before grenade explodes, just don't explode
      if SERVER and (not IsValid(self:GetOwner())) then
         self:Remove()
         etime = 0
         return
      end

      -- find the ground if it's near and pass it to the explosion
      local spos = self:GetPos()
      local tr = util.TraceLine({start=spos, endpos=spos + Vector(0,0,-32), mask=MASK_SHOT_HULL, filter=self.thrower})

      local success, err = pcall(self.Explode, self, tr)
      if not success then
         -- prevent effect spam on Lua error
         self:Remove()
         ErrorNoHalt("ERROR CAUGHT: ttt_basegrenade_proj: " .. err .. "\n")
      end
   end
end
