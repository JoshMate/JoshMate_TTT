-- thrown knife

AddCSLuaFile()

if CLIENT then
   ENT.PrintName = "Throwing Knife"
   ENT.Icon = "vgui/ttt/icon_knife"
end


ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_knife_t.mdl")

-- When true, score code considers us a weapon
ENT.Projectile = true

ENT.HasHit = false
ENT.IsSilent = true

ENT.KnifeTimeOutDelay = 2

ENT.WeaponID = AMMO_THROWINGKNIFEPROJ

--JM Changes Trails
ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(25,25,25,150)
ENT.Trail_StartWidth = 5
ENT.Trail_EndWidth = 1
-- End of

function ENT:Initialize()
   self:SetModel(self.Model)

   self:PhysicsInit(SOLID_VPHYSICS)

   if SERVER then
      if self.Trail_Enabled then
         if IsValid(self) then 
            util.SpriteTrail( self, 0, self.Trail_Colour, true, self.Trail_StartWidth, self.Trail_EndWidth, 0.5, (1 / ( self.Trail_StartWidth + self.Trail_EndWidth ) * 0.5), "sprites/laserbeam" )
         end
      end
   end

   -- Set up Prints
   local knife = self
   local prints = self.fingerprints
   self:SetNWBool("HasPrints", true)

   -- Ent Creation Time
   self.KnifeCreationTime = CurTime()
   self.KnifeBounces = 0

   if SERVER then
      self:SetGravity(0.25)
      self:SetFriction(1.0)
      self:SetElasticity(0.45)

      self.StartPos = self:GetPos()

      self:NextThink(CurTime())
   end

end

function ENT:HitPlayer(other, tr)

   if self.HasHit == true then return end

   -- Calculate Knife Damage
   local damageTimeDifference = CurTime() - self.KnifeCreationTime
   if damageTimeDifference <= 0 then damageTimeDifference = 0 end
   
   local damageBase = 330

   damageFinal = damageBase * damageTimeDifference

   damageFinal = math.Round(damageFinal, 0)
   damageFinal = math.Clamp(damageFinal, 40, 999999)

   local damageRating = "[0] Terrible"
   if damageFinal >= 50 then damageRating =     "[1] Bad" end
   if damageFinal >= 60 then damageRating =     "[2] Okay" end
   if damageFinal >= 70 then damageRating =     "[3] Decent" end
   if damageFinal >= 80 then damageRating =     "[4] Nice" end
   if damageFinal >= 100 then damageRating =    "[5] Good" end
   if damageFinal >= 115 then damageRating =    "[6] Great" end
   if damageFinal >= 130 then damageRating =    "[7] Impressive" end
   if damageFinal >= 150 then damageRating =    "[8] Excellent" end
   if damageFinal >= 200 then damageRating =    "[9] Brilliant" end
   if damageFinal >= 250 then damageRating =    "[10] Fantastic" end
   if damageFinal >= 300 then damageRating =    "[11] Insane" end
   if damageFinal >= 350 then damageRating =    "[12] Awe Inspiring" end
   if damageFinal >= 400 then damageRating =    "[13] Godlike" end
   if damageFinal >= 500 then damageRating =    "[14] Oh! Cross Map" end
   if damageFinal >= 550 then damageRating =    "[15] Faze wants to know your location" end
   if damageFinal >= 600 then damageRating =    "[16] Mum, Get the FUCKING CAMERA! MUMMY!" end

   JM_Function_PrintChat(self:GetOwner(), "Equipment", "Throwing Knife Score: " .. tostring(damageFinal) .. " ".. tostring(damageRating))
   
   local dmg = DamageInfo()
   dmg:SetDamage(damageFinal)
   dmg:SetAttacker(self:GetOwner())
   dmg:SetInflictor(self)
   dmg:SetDamageForce(self:EyeAngles():Forward())
   dmg:SetDamagePosition(self:GetPos())
   dmg:SetDamageType(DMG_SLASH)   

   other:TakeDamageInfo(dmg)
   self.HasHit = true

   self:Remove()

end

if SERVER then
  function ENT:Think()

      if self.KnifeBounces >= 1 then 

         if (self.KnifeBounceTime + self.KnifeTimeOutDelay) <= CurTime() then
            self.HasHit = true
            self:Remove()
         end

      end

  end
end

-- When this entity touches anything that is not a player, it should turn into a
-- weapon ent again. If it touches a player it sticks in it.
if SERVER then

   function ENT:PhysicsCollide(data, phys)

      if self.KnifeBounces < 1 then 
         self.KnifeBounceTime = CurTime()
      end

      self.KnifeBounces = self.KnifeBounces + 1

      local other = data.HitEntity
      if not IsValid(other) and not other:IsWorld() then return end

      if other:IsPlayer() or other:IsNPC() then
         local tr = util.TraceLine({start=self:GetPos(), endpos=other:LocalToWorld(other:OBBCenter()), filter={self, self:GetOwner()}, mask=MASK_SHOT_HULL})
         if tr.Hit and tr.Entity == other then
            self:HitPlayer(other, tr)
         end

         return true
      end

   end

end
