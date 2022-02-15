AddCSLuaFile()

SWEP.HoldType            = "ar2"

if CLIENT then
   SWEP.PrintName        = "SMG"
   SWEP.Slot             = 2

   SWEP.ViewModelFlip    = false
   SWEP.ViewModelFOV     = 54

   SWEP.Icon             = "vgui/ttt/joshmate/icon_jm_gun_prim"
   SWEP.IconLetter       = "l"
end

SWEP.Base                = "weapon_jm_base_gun"
SWEP.CanBuy                = {}

SWEP.Kind                = WEAPON_HEAVY
SWEP.WeaponID            = AMMO_MAC10

-- // Gun Stats

SWEP.Primary.Damage        = 35
SWEP.Primary.NumShots      = 1
SWEP.Primary.Delay         = 0.080
SWEP.Primary.Cone          = 0.045
SWEP.Primary.Recoil        = 1.0
SWEP.Primary.Range         = 500
SWEP.Primary.ClipSize      = 30
SWEP.Primary.DefaultClip   = 30
SWEP.Primary.ClipMax       = 60
SWEP.Primary.SoundLevel    = 75

SWEP.HeadshotMultiplier    = 2
SWEP.DeploySpeed           = 1
SWEP.BulletForce           = 20
SWEP.Primary.Automatic     = true

-- // End of Gun Stats

SWEP.Primary.Ammo        = "pistol"
SWEP.Primary.Sound       = "shoot_smg.wav"
SWEP.AutoSpawnable       = true
SWEP.UseHands            = true
SWEP.ViewModel           = "models/weapons/cstrike/c_smg_mp5.mdl"
SWEP.WorldModel          = "models/weapons/w_smg_mp5.mdl"

-- No Iron Sights
function SWEP:SecondaryAttack()
   return
end