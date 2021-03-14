-- common code for all types of grenade

AddCSLuaFile()

DEFINE_BASECLASS "weapon_tttbase"

SWEP.HoldType              = "grenade"
SWEP.HoldReady             = "grenade"
SWEP.HoldNormal            = "grenade"

if CLIENT then
   SWEP.PrintName          = "Base grenade"
   SWEP.Instructions       = "Base Desc"
   SWEP.Slot               = 3

   SWEP.ViewModelFlip      = false
   SWEP.DrawCrosshair      = false

   SWEP.ViewModelFOV       = 54

   SWEP.Icon               = "vgui/ttt/icon_nades"
end

SWEP.Base                  = "weapon_tttbase"

SWEP.UseHands           = true
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
SWEP.IsGrenade             = true

SWEP.was_thrown            = false
SWEP.detonate_timer        = 2
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
      self:GetOwner():ChatPrint("[Grenade] - You can't use that during prep time...")
      return
   end

   self.JM_Throw_PowerMult = 0.4
   self:Throw()
end


function SWEP:Throw()
   self:GetOwner():SetAnimation(PLAYER_ATTACK1)
   self:SendWeaponAnim(ACT_VM_DRAW)

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
         self:GetOwner():SelectWeapon("weapon_ttt_unarmed")
      end
   end
end

-- subclasses must override with their own grenade ent
function SWEP:GetGrenadeName()
   ErrorNoHalt("SWEP BASEGRENADE ERROR: GetGrenadeName not overridden! This is probably wrong!\n")
   return "ttt_firegrenade_proj"
end


function SWEP:CreateGrenade(src, ang, vel, angimp, ply)
   local gren = ents.Create(self:GetGrenadeName())
   if not IsValid(gren) then return end

   gren:SetPos(src)
   gren:SetAngles(ang)

   --   gren:SetVelocity(vel)
   gren:SetOwner(ply)
   gren:SetThrower(ply)

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

   -- This has to happen AFTER Spawn() calls gren's Initialize()
   gren:SetDetonateExact(CurTime() + self.detonate_timer)

   return gren
end

function SWEP:Reload()
   return false
end

-- Hud Help Text
if CLIENT then
   function SWEP:Initialize()
      self:AddTTT2HUDHelp("Full Throw", "Half Throw", true)
   end
end
-- 