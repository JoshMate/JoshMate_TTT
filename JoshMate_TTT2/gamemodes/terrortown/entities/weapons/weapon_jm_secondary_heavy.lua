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
SWEP.Primary.Range         = 650
SWEP.Primary.ClipSize      = 5
SWEP.Primary.DefaultClip   = 5
SWEP.Primary.ClipMax       = 10
SWEP.Primary.SoundLevel    = 75

SWEP.HeadshotMultiplier    = 3
SWEP.DeploySpeed           = 3
SWEP.BulletForce           = 30
SWEP.Primary.Automatic     = false

-- // End of Gun Stats

SWEP.Primary.Sound         = "shoot_heavypistol.wav"
SWEP.Primary.Ammo          = "357"
SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_jm_ammo_heavy"
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_deagle.mdl"
SWEP.IronSightsPos         = Vector(-6.361, -3.701, 2.15)
SWEP.IronSightsAng         = Vector(0, 0, 0)

-- No Iron Sights
function SWEP:SecondaryAttack()
   return
end
