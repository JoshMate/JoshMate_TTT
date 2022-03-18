AddCSLuaFile()

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "Heavy Pistol"
   SWEP.Slot               = 1

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_gun_sec"
end

SWEP.Base                  = "weapon_jm_base_gun"
SWEP.CanBuy                = {}

SWEP.Kind                  = WEAPON_PISTOL
SWEP.WeaponID              = AMMO_DEAGLE


-- // Gun Stats

SWEP.Primary.Damage        = 45
SWEP.Primary.NumShots      = 1
SWEP.Primary.Delay         = 0.300
SWEP.Primary.Cone          = 0.008
SWEP.Primary.Recoil        = 10
SWEP.Primary.Range         = 750
SWEP.Primary.ClipSize      = 5
SWEP.Primary.DefaultClip   = 5
SWEP.Primary.ClipMax       = 10
SWEP.Primary.SoundLevel    = 75

SWEP.HeadshotMultiplier    = 2.5
SWEP.DeploySpeed           = 3
SWEP.BulletForce           = 30
SWEP.Primary.Automatic     = false

-- JM Changes, Movement Speed
SWEP.MoveMentMultiplier = 1.1
-- End of

-- // End of Gun Stats

SWEP.Primary.Sound         = "shoot_heavypistol.wav"
SWEP.Primary.Ammo          = "357"
SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_deagle.mdl"
SWEP.IronSightsPos         = Vector(-6.361, -3.701, 2.15)
SWEP.IronSightsAng         = Vector(0, 0, 0)

-- No Iron Sights
function SWEP:SecondaryAttack()
   return
end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Shoot", nil, true)
 
	   return self.BaseClass.Initialize(self)
	end
end
-- Equip Bare Hands on Remove
if SERVER then
   function SWEP:OnRemove()
      if self:GetOwner():IsValid() and self:GetOwner():IsTerror() and self:GetOwner():Alive() then
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
      end
   end
end

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################