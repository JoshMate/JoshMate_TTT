
AddCSLuaFile()

SWEP.HoldType              = "rpg"

if CLIENT then
   SWEP.PrintName          = "Prop Launcher"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_gun_special.png"
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 1.50
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 10
SWEP.Primary.DefaultClip   = 10
SWEP.Primary.ClipMax       = 0
SWEP.DeploySpeed           = 1
SWEP.Primary.SoundLevel    = 40
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = nil
SWEP.Secondary.Sound       = nil
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {} 
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_PROPLAUNCHER
SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/c_rpg.mdl")
SWEP.WorldModel            = Model("models/weapons/w_rocket_launcher.mdl")

local PropLauncher_Range_Pickup                 = 800
local PropLauncher_Muzzle_Offset                = 64
local PropLauncher_Shoot_Velocity               = 3000

local PropLauncher_Sound_Shoot                  = "proplauncher_shoot.wav"
local PropLauncher_Sound_Reload                 = "proplauncher_reload.wav"
local PropLauncher_Sound_Fail                   = "proplauncher_fail.wav"

SWEP.PropLauncher_StoredProp                   = nil


function Effects_PropMagic(ent)
	if not IsValid(ent) then return end
 
	local effect = EffectData()
	local ePos = ent:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	
	
	util.Effect("cball_explode", effect, true, true)
end

function SWEP:PrimaryAttack()
   local owner = self:GetOwner()
   if not IsValid(owner) then return end
   if not self:CanPrimaryAttack() then return end

   

   local tr = util.TraceLine({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * PropLauncher_Muzzle_Offset, filter = owner})
   if (tr.Hit) then
      self:SetNextPrimaryFire( CurTime() + self.Primary.Delay/4 )
      self:SetNextSecondaryFire(CurTime() + self.Primary.Delay/4 )
      self:EmitSound(PropLauncher_Sound_Fail)
      return
   end
   
   if self.PropLauncher_StoredProp == nil then
      self:SetNextPrimaryFire( CurTime() + self.Primary.Delay/4 )
      self:SetNextSecondaryFire(CurTime() + self.Primary.Delay/4 )
      self:EmitSound(PropLauncher_Sound_Fail)
   else
      self:SetNextPrimaryFire( CurTime() + self.Primary.Delay/2 )
      self:SetNextSecondaryFire(CurTime() + self.Primary.Delay/2 )
      if SERVER then
         local object = ents.Create("prop_physics")
         object:SetModel(self.PropLauncher_StoredProp)
         object:SetPos(owner:GetShootPos() + owner:GetAimVector() * PropLauncher_Muzzle_Offset)
         object:PhysicsInit(SOLID_VPHYSICS)
         object:SetMoveType(MOVETYPE_VPHYSICS)
         object:SetSolid(SOLID_VPHYSICS)
         object:Spawn()
         
         local objectphysics = object:GetPhysicsObject()
         if objectphysics:IsValid() then
            objectphysics:Wake()
         end
         objectphysics:AddVelocity(owner:GetAimVector() * PropLauncher_Shoot_Velocity)

         -- Karma and extra Effects
         Effects_PropMagic(object)
         object:SetPhysicsAttacker(self:GetOwner())
         objectphysics:AddGameFlag(FVPHYSICS_WAS_THROWN)
         
      end
      self.PropLauncher_StoredProp = nil
      self:Animation_Fire()
      self:TakePrimaryAmmo( 1 )
   end

   if SERVER then
      if self:Clip1() <= 0 then
         self:Remove()
      end
   end
end

function SWEP:SecondaryAttack()

   local owner = self:GetOwner()
   if not IsValid(owner) then return end
   if not self:CanSecondaryAttack() then return end

   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

   -- Store a prop

   local tr = util.TraceLine({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * PropLauncher_Range_Pickup, filter = owner})
   if (tr.Entity:IsValid() and tr.Entity:GetClass() == "prop_physics") then
      self.PropLauncher_StoredProp = tr.Entity:GetModel()
      if SERVER then
         Effects_PropMagic(tr.Entity)
         tr.Entity:Remove()
      end
      self:Animation_Reload()
      self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
      self:SetNextSecondaryFire(CurTime() + self.Primary.Delay )
   else
      self:EmitSound(PropLauncher_Sound_Fail)
      self:SetNextPrimaryFire( CurTime() + self.Primary.Delay/4 )
      self:SetNextSecondaryFire(CurTime() + self.Primary.Delay/4 )
   end  
      	
end

function SWEP:Animation_Fire() 
   self:EmitSound(PropLauncher_Sound_Shoot)
   self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
   if IsValid(self:GetOwner()) then
      self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
   end
end

function SWEP:Animation_Reload() 
   self:EmitSound(PropLauncher_Sound_Reload)
   self:SendWeaponAnim( ACT_VM_RELOAD )
end


-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Launch your stored prop", "Store a prop", true)
 
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
