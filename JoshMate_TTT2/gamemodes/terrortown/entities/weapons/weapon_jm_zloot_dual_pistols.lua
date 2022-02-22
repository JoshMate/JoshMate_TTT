AddCSLuaFile()

SWEP.HoldType              = "duel"

if CLIENT then
   SWEP.PrintName          = "Fenner & Lucker"
   SWEP.Slot               = 1

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_gun_special.png"
   SWEP.IconLetter         = "u"
end

SWEP.Base                  = "weapon_jm_base_gun"
SWEP.CanBuy                = {}

SWEP.Kind                  = WEAPON_PISTOL
SWEP.WeaponID              = AMMO_ADVANCED_PISTOL_DUAL

-- // Gun Stats

SWEP.Primary.Damage        = 50
SWEP.Primary.NumShots      = 1
SWEP.Primary.Delay         = 0.10
SWEP.Primary.Cone          = 0.008
SWEP.Primary.Recoil        = 1
SWEP.Primary.Range         = 800
SWEP.Primary.ClipSize      = 60
SWEP.Primary.DefaultClip   = 60
SWEP.Primary.ClipMax       = 0
SWEP.Primary.SoundLevel    = 75

SWEP.HeadshotMultiplier    = 2
SWEP.DeploySpeed           = 1
SWEP.BulletForce           = 50
SWEP.Primary.Automatic     = false

-- // End of Gun Stats

SWEP.Primary.Ammo          = "none"
SWEP.Primary.Sound         = "shoot_dual_pistols.wav"
SWEP.AutoSpawnable         = true
SWEP.UseHands              = true
SWEP.Tracer                = "None"
SWEP.ViewModel             = "models/weapons/cstrike/c_pist_elite.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_elite.mdl"
SWEP.IronSightsPos         = Vector(-5.95, -4, 2.799)
SWEP.IronSightsAng         = Vector(0, 0, 0)

-- JM Changes, Movement Speed
SWEP.MoveMentMultiplier = 1.3
-- End of

-- Dual Animations
SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK

function SWEP:PrimaryAttack(worldsnd)
	
   self.BaseClass.PrimaryAttack( self.Weapon, worldsnd )
   
   local doOnce = false

   if self.PrimaryAnim == ACT_VM_PRIMARYATTACK and doOnce == false then
      doOnce = true
      self.PrimaryAnim = ACT_VM_SECONDARYATTACK
   end
   if self.PrimaryAnim == ACT_VM_SECONDARYATTACK and doOnce == false then
      doOnce = true
      self.PrimaryAnim = ACT_VM_PRIMARYATTACK
   end

   self:SendWeaponAnim( self.PrimaryAnim )

   if SERVER then
      local own = self:GetOwner()
      own:SetHealth(math.Clamp(own:Health() + 3, 0, own:GetMaxHealth()))

      if self:Clip1() <= 0 then
         self:Remove()
      end
   end

   

end


-- No Iron Sights
function SWEP:SecondaryAttack()
   return
end

-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Shoot", nil, true)
 
	   return self.BaseClass.Initialize(self)
	end
end
if SERVER then
   function SWEP:OnRemove()
      self:PreDrop()
      if self.Owner:IsValid() and self.Owner:IsTerror() then
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
      end
   end
end
-- 




