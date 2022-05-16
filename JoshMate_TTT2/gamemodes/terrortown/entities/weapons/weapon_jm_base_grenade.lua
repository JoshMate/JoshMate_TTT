-- common code for all types of grenade

AddCSLuaFile()

DEFINE_BASECLASS "weapon_jm_base_gun"

SWEP.HoldType              = "normal"
SWEP.HoldReady             = "normal"
SWEP.HoldNormal            = "normal"

if CLIENT then
   SWEP.PrintName          = "Base grenade"
   SWEP.Instructions       = "Base Desc"
   SWEP.Slot               = 3

   SWEP.ViewModelFlip      = false
   SWEP.DrawCrosshair      = false

   SWEP.ViewModelFOV       = 54

   SWEP.Icon               = "vgui/ttt/icon_nades"
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.UseHands              = false
SWEP.ViewModel             = "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel            = "models/weapons/w_eq_flashbang.mdl"

SWEP.Weight                = 5
SWEP.AutoSwitchFrom        = true
SWEP.NoSights              = true

SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.Automatic     = false
SWEP.Primary.Delay         = 1
SWEP.Primary.Ammo          = "none"

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"
SWEP.Secondary.Delay         = 1

SWEP.Kind                  = WEAPON_NADE
SWEP.WeaponID              = AMMO_NADE_BASE
SWEP.IsGrenade             = true

SWEP.was_thrown            = false
SWEP.DeploySpeed           = 4

-- JM Changes, Throwing
SWEP.JM_Throw_Power        = 800
SWEP.JM_Throw_PowerMult    = 1
-- End of


CreateConVar("ttt_no_nade_throw_during_prep", "0")


function SWEP:PrimaryAttack()
   if not self:CanPrimaryAttack() then return end
   self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
   self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

   if GetRoundState() == ROUND_PREP and GetConVar("ttt_no_nade_throw_during_prep"):GetBool() then
      JM_Function_PrintChat(self:GetOwner(), "Equipment","You can't use Grenades in the Pre-Round..." )
      return
   end
   
   self.JM_Throw_PowerMult = 1
   self:Throw()
end

function SWEP:SecondaryAttack()
   if not self:CanPrimaryAttack() then return end
   self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
   self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

   if GetRoundState() == ROUND_PREP and GetConVar("ttt_no_nade_throw_during_prep"):GetBool() then
      JM_Function_PrintChat(self:GetOwner(), "Equipment","You can't use Grenades in the Pre-Round..." )
      return
   end

   self.JM_Throw_PowerMult = 0.4
   self:Throw()
end


function SWEP:Throw()

   if SERVER then
      local ply = self:GetOwner()
      if not IsValid(ply) then return end

      -- Josh Mate Changes = Massively Simplified this for ease of use
      local A_Src = ply:GetShootPos()
      local A_Angle = Angle(0,0,0)
      local A_Vel = ( ply:GetAimVector() * (self.JM_Throw_Power * self.JM_Throw_PowerMult ))
      local A_AngImp = Vector(600, math.random(-1200, 1200), 0)

      self:GetOwner():EmitSound(Sound("grenade_throw.wav"))
      self:CreateGrenade(A_Src, A_Angle, A_Vel, A_AngImp, ply)

      self:TakePrimaryAmmo(1)
      if self:Clip1() <= 0 then
         self:Remove()
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
      end
   end
end

-- subclasses must override with their own grenade ent
function SWEP:GetGrenadeName()
   return "ent_jm_grenade_smoke_proj"
end


function SWEP:CreateGrenade(src, ang, vel, angimp, ply)
   local gren = ents.Create(self:GetGrenadeName())
   if not IsValid(gren) then return end

   gren:SetPos(src)
   gren:SetAngles(ang)

   --   gren:SetVelocity(vel)
   gren:SetOwner(ply)

   gren:SetGravity(0.25)
   gren:SetFriction(0.30)
   gren:SetElasticity(0.5)

   gren:Spawn()

   gren:PhysWake()

   local phys = gren:GetPhysicsObject()
   if IsValid(phys) then
      phys:SetVelocity(vel)
      phys:AddAngleVelocity(angimp)
   end

   return gren
end

function SWEP:Reload()
   return false
end