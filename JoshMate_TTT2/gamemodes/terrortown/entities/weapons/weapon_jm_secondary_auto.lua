AddCSLuaFile()

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "Auto Pistol"
   SWEP.Slot               = 1

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_gun_sec"
   SWEP.IconLetter         = "c"
end

SWEP.Base                  = "weapon_jm_base_gun"
SWEP.CanBuy                = {}

-- // Gun Stats

SWEP.Primary.Damage        = 20
SWEP.Primary.NumShots      = 1
SWEP.Primary.Delay         = 0.080
SWEP.Primary.Cone          = 0.040
SWEP.Primary.Recoil        = 0.5
SWEP.Primary.Range         = 300
SWEP.Primary.ClipSize      = 20
SWEP.Primary.DefaultClip   = 20
SWEP.Primary.ClipMax       = 40
SWEP.Primary.SoundLevel    = 75

SWEP.HeadshotMultiplier    = 2
SWEP.DeploySpeed           = 2
SWEP.BulletForce           = 10
SWEP.Primary.Automatic     = true

-- // End of Gun Stats

SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.Sound         = "shoot_autopistol.wav"
SWEP.AmmoEnt               = "item_jm_ammo_light"
SWEP.Kind                  = WEAPON_PISTOL
SWEP.WeaponID              = AMMO_GLOCK
SWEP.AutoSpawnable         = true
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_glock18.mdl"
SWEP.IronSightsPos         = Vector( -5.79, -3.9982, 2.8289 )

-- No Iron Sights
function SWEP:SecondaryAttack()
   return
end