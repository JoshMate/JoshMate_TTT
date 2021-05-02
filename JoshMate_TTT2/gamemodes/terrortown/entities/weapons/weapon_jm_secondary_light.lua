AddCSLuaFile()

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "Light Pistol"
   SWEP.Slot               = 1

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_gun_sec"
   SWEP.IconLetter         = "u"
end

SWEP.Base                  = "weapon_jm_base_gun"
SWEP.CanBuy                = {}

SWEP.Kind                  = WEAPON_PISTOL
SWEP.WeaponID              = AMMO_PISTOL

-- // Gun Stats

SWEP.Primary.Damage        = 1
SWEP.Primary.Delay         = 0.10
SWEP.Primary.Cone          = 0.01
SWEP.Primary.Recoil        = 1
SWEP.Primary.Range         = 1000
SWEP.Primary.ClipSize      = 100
SWEP.Primary.DefaultClip   = 100
SWEP.Primary.ClipMax       = 0

SWEP.HeadshotMultiplier    = 2
SWEP.DeploySpeed           = 1
SWEP.Primary.SoundLevel    = 100
SWEP.Primary.Automatic     = true

-- // End of Gun Stats

SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.Sound         = "shoot_lightpistol.wav"
SWEP.AutoSpawnable         = true
SWEP.AmmoEnt               = "item_jm_ammo_light"
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_pist_p228.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_p228.mdl"
SWEP.IronSightsPos         = Vector(-5.95, -4, 2.799)
SWEP.IronSightsAng         = Vector(0, 0, 0)

-- No Iron Sights
function SWEP:SecondaryAttack()
   return
end




