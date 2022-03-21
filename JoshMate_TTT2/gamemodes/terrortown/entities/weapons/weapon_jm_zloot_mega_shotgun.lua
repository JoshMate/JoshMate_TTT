AddCSLuaFile()

DEFINE_BASECLASS "weapon_jm_base_gun"

SWEP.HoldType              = "shotgun"

if CLIENT then
   SWEP.PrintName          = "Rooty-Tooty"
   SWEP.Slot               = 2

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_gun_special.png"
   SWEP.IconLetter         = "B"
end

SWEP.Base                  = "weapon_jm_base_gun"
SWEP.CanBuy                = {}

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_MEGA_SHOTGUN


-- // Gun Stats

SWEP.Primary.Damage        = 45
SWEP.Primary.NumShots      = 100
SWEP.Primary.Delay         = 0.1
SWEP.Primary.Cone          = 0.20
SWEP.Primary.Recoil        = 0
SWEP.Primary.Range         = 3000
SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.ClipMax       = 1
SWEP.Primary.SoundLevel    = 120

SWEP.HeadshotMultiplier    = 1
SWEP.DeploySpeed           = 1
SWEP.BulletForce           = 50
SWEP.Primary.Automatic     = false

-- // End of Gun Stats


SWEP.Primary.Ammo          = "None"
SWEP.Primary.Sound         = nil
SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.UseHands              = true
SWEP.Tracer                = "AR2Tracer"
SWEP.ViewModel             = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel            = "models/weapons/w_shotgun.mdl"




function SWEP:PrimaryAttack(worldsnd)
	if self.Secondary.IsDelayedByPrimary == 1 then self:SetNextSecondaryFire(CurTime() + self.Primary.Delay) end 

	-- Rapid Fire Changes
	local owner = self:GetOwner()
	if (not owner:GetNWBool(JM_Global_Buff_Care_RapidFire_NWBool)) then self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	else self:SetNextPrimaryFire(CurTime() + (self.Primary.Delay*0.70)) end
	-- End of Rapid Fire Changes

	if not self:CanPrimaryAttack() then return end

   if SERVER then
	   JM_Function_PlaySound("shoot_mega_shotgun.mp3")
   end

	self:ShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetPrimaryCone())
	self:TakePrimaryAmmo(1)

	if not IsValid(owner) or owner:IsNPC() or not owner.ViewPunch then return end

	owner:ViewPunch(Angle(util.SharedRandom(self:GetClass(), -0.2, -0.1, 0) * self.Primary.Recoil, util.SharedRandom(self:GetClass(), -0.1, 0.1, 1) * self.Primary.Recoil, 0))

   if SERVER then
	   self:Remove()
   end
end

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
	   self:AddTTT2HUDHelp("Delete EVERYTHING in front of you", nil, true)
 
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
