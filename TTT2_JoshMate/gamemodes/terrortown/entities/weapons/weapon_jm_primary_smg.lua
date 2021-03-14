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

SWEP.Base                = "weapon_tttbase"
SWEP.CanBuy                = {}

SWEP.Kind                = WEAPON_HEAVY
SWEP.WeaponID            = AMMO_MAC10

SWEP.Primary.Damage        = 30
SWEP.Primary.Delay         = 0.08
SWEP.Primary.Cone          = 0.05
SWEP.Primary.Recoil        = 1
SWEP.Primary.ClipSize      = 30
SWEP.Primary.DefaultClip   = 30
SWEP.Primary.ClipMax       = 60

SWEP.HeadshotMultiplier    = 2
SWEP.DeploySpeed           = 1
SWEP.Primary.SoundLevel    = 100
SWEP.Primary.Automatic     = true

SWEP.Primary.Ammo        = "smg1"
SWEP.Primary.Sound       = "shoot_smg.wav"
SWEP.AutoSpawnable       = true
SWEP.AmmoEnt             = "item_jm_ammo_medium"
SWEP.UseHands            = true
SWEP.ViewModel           = "models/weapons/cstrike/c_smg_mp5.mdl"
SWEP.WorldModel          = "models/weapons/w_smg_mp5.mdl"
SWEP.IronSightsPos       = Vector(-3, -2, 2)
SWEP.IronSightsAng       = Vector(2, 2, 2)

-- No Iron Sights
function SWEP:SecondaryAttack()
   return
end