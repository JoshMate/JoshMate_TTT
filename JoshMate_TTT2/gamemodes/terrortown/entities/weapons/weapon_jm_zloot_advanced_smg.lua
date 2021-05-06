AddCSLuaFile()

SWEP.HoldType            = "ar2"

if CLIENT then
   SWEP.PrintName        = "Advanced: SMG"
   SWEP.Slot             = 2

   SWEP.ViewModelFlip    = false
   SWEP.ViewModelFOV     = 54

   SWEP.Icon             = "vgui/ttt/joshmate/icon_jm_gun_special.png"
   SWEP.IconLetter       = "l"
end

SWEP.Base                = "weapon_jm_base_gun"
SWEP.CanBuy                = {}

SWEP.Kind                = WEAPON_HEAVY
SWEP.WeaponID            = AMMO_ADVANCED_SMG

-- // Gun Stats

SWEP.Primary.Damage        = 30
SWEP.Primary.NumShots      = 1
SWEP.Primary.Delay         = 0.070
SWEP.Primary.Cone          = 0.030
SWEP.Primary.Recoil        = 0.5
SWEP.Primary.Range         = 600
SWEP.Primary.ClipSize      = 60
SWEP.Primary.DefaultClip   = 60
SWEP.Primary.ClipMax       = 60
SWEP.Primary.SoundLevel    = 75

SWEP.HeadshotMultiplier    = 2
SWEP.DeploySpeed           = 1
SWEP.BulletForce           = 20
SWEP.Primary.Automatic     = true

-- // End of Gun Stats

SWEP.Primary.Ammo        = "smg1"
SWEP.Primary.Sound       = "shoot_advanced_smg.wav"
SWEP.AutoSpawnable       = true
SWEP.AmmoEnt             = "item_jm_ammo_medium"
SWEP.UseHands            = true
SWEP.ViewModel           = "models/weapons/cstrike/c_smg_p90.mdl"
SWEP.WorldModel          = "models/weapons/w_smg_p90.mdl"

-- No Iron Sights
function SWEP:SecondaryAttack()
   return
end