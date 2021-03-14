AddCSLuaFile()

SWEP.HoldType              = "crossbow"

if CLIENT then
   SWEP.PrintName          = "LMG"
   SWEP.Slot               = 2

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_gun_prim"
   SWEP.IconLetter         = "z"
end

SWEP.Base                  = "weapon_tttbase"
SWEP.CanBuy                = {}

SWEP.Spawnable             = true
SWEP.AutoSpawnable         = true

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_M249

SWEP.Primary.Damage        = 20
SWEP.Primary.Delay         = 0.10
SWEP.Primary.Cone          = 0.025
SWEP.Primary.Recoil        = 0.5
SWEP.Primary.ClipSize      = 100
SWEP.Primary.DefaultClip   = 100
SWEP.Primary.ClipMax       = 0

SWEP.HeadshotMultiplier    = 2
SWEP.DeploySpeed           = 1
SWEP.Primary.SoundLevel    = 100
SWEP.Primary.Automatic     = true

SWEP.Primary.Ammo          = "AirboatGun"
SWEP.Primary.Sound         = "shoot_lmg.wav"
SWEP.Tracer                = "AR2Tracer"
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.WorldModel            = "models/weapons/w_mach_m249para.mdl"
SWEP.IronSightsPos         = Vector(-5.96, -5.119, 2.349)
SWEP.IronSightsAng         = Vector(0, 0, 0)


-- No Iron Sights
function SWEP:SecondaryAttack()
   return
end