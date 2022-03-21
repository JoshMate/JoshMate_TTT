
AddCSLuaFile()

SWEP.HoldType              = "crossbow"

if CLIENT then
   SWEP.PrintName          = "Inferno Launcher"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Lethal Weapon
	
Shoots out a cluster bomb that splits on impact

These explode dealing damage and starting lots of fires

Has 1 use and is extremely obvious you have used it
]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_infernolauncher.png"
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.ClipMax       = 0
SWEP.DeploySpeed           = 2
SWEP.Primary.SoundLevel    = 100
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = "shoot_inferno_launcher.wav"
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_INFERNOLAUNCHER
SWEP.Tracer                = "AR2Tracer"
SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/c_crossbow.mdl")
SWEP.WorldModel            = Model("models/weapons/w_crossbow.mdl")

local JM_Explosive_FuseDelay       = 3
local JM_Explosive_ShootForce      = 1350

function SWEP:PrimaryAttack()

   -- Weapon Animation, Sound and Cycle data
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
   self:EmitSound( self.Primary.Sound )
   self:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 
   self:TakePrimaryAmmo( 1 )
   if IsValid(self:GetOwner()) then
      self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
   end
   -- #########

   -- Do the launching
   if SERVER then
      local ply = self:GetOwner()
      if not IsValid(ply) then return end

      -- Control the power of the launch
      self.JM_Throw_PowerMult = 1
      self.JM_Throw_Power = JM_Explosive_ShootForce

      -- Josh Mate Changes = Massively Simplified this for ease of use
      local A_Src = ply:GetShootPos()
      local A_Angle = Angle(0,0,0)
      local A_Vel = ( ply:GetAimVector() * (self.JM_Throw_Power * self.JM_Throw_PowerMult ))
      local A_AngImp = Vector(600, math.random(-1200, 1200), 0)

      self:CreateGrenade(A_Src, A_Angle, A_Vel, A_AngImp, ply)
      self:TakePrimaryAmmo(1)
   end

   -- Remove Weapon When out of Ammo
   if SERVER then
      if self:Clip1() <= 0 then
         self:Remove()
      end
   end
   -- #########

end


function SWEP:CreateGrenade(src, ang, vel, angimp, ply)
   local gren = ents.Create("ent_jm_grenade_infernolaunch_first")
   if not IsValid(gren) then return end

   gren:SetPos(src)
   gren:SetAngles(ang)

   gren:SetOwner(ply)

   gren:SetGravity(0.20)
   gren:SetFriction(0.20)
   gren:SetElasticity(0.20)
   gren:SetColor(Color(200,150,0,150))

   gren:Spawn()

   gren:PhysWake()

   local phys = gren:GetPhysicsObject()
   if IsValid(phys) then
      phys:SetVelocity(vel)
      phys:AddAngleVelocity(angimp)
   end

   return gren
end

function SWEP:SecondaryAttack()
   return false
end

function SWEP:Reload()
   return false
end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Launcher an Inferno Cluster Bomb", nil, true)
 
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
-- Delete on Drop
function SWEP:OnDrop() 
   self:Remove()
end

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################
