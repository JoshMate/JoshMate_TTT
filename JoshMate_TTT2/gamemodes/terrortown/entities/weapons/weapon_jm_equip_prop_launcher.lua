
AddCSLuaFile()

SWEP.HoldType              = "ar2"

if CLIENT then
   SWEP.PrintName          = "Prop Launcher"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Lethal Weapon

Pick up a prop and yeet it.
]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_poisondart.png"            --REPLACE
end

SWEP.Base                  = "weapon_tttbase"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 10
SWEP.Primary.DefaultClip   = 10
SWEP.Primary.ClipMax       = 0
SWEP.DeploySpeed           = 2
SWEP.Primary.SoundLevel    = 40
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = "shoot_yaiyai.wav"                                 --REPLACE
SWEP.Secondary.Sound       = Sound("Default.Zoom")
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_DETECTIVE} 
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_PROPLAUNCHER
SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/c_rpg.mdl")
SWEP.WorldModel            = Model("models/weapons/w_rocket_launcher.mdl")
SWEP.IronSightsPos         = Vector( 5, -15, -2 )
SWEP.IronSightsAng         = Vector( 2.6, 1.37, 3.5 )

local RaycastRange = 500
local SpawnDistance = 40
local StoredProp = nil

function SWEP:PrimaryAttack()
   

   local owner = self:GetOwner()
   if not IsValid(owner) then return end
   
   if StoredProp == nil then
      local tr = util.TraceLine({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * RaycastRange, filter = owner})
      if (tr.Entity:IsValid() and tr.Entity:GetClass() == "prop_physics") then
         StoredProp = tr.Entity:GetModel()
         if SERVER then
            tr.Entity:Remove()
         end
      end
      FireAnim()
   else
      if SERVER then
         local object = ents.Create("prop_physics")
         object:SetModel(StoredProp)
         object:SetPos(owner:GetShootPos() + owner:GetAimVector() * SpawnDistance)
         object:PhysicsInit(SOLID_VPHYSICS)
         object:SetMoveType(MOVETYPE_VPHYSICS)
         object:SetSolid(SOLID_VPHYSICS)
         object:Spawn()
         local objectphysics = object:GetPhysicsObject()
         if objectphysics:IsValid() then
            objectphysics:Wake()
         end
         objectphysics:AddVelocity(owner:GetAimVector() * 3000)
      end
      StoredProp = nil
      FireAnim()
      self:TakePrimaryAmmo( 1 )
   end

   if SERVER then
      if self:Clip1() <= 0 then
         self:Remove()
      end
   end
end

function FireAnim() 
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
   self:EmitSound( self.Primary.Sound )
   self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
   if IsValid(self:GetOwner()) then
      self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
   end
end

function SWEP:PreDrop()
   self:SetZoom(false)
   self:SetIronsights(false)
   return self.BaseClass.PreDrop(self)
end

function SWEP:Holster()
   self:SetIronsights(false)
   self:SetZoom(false)
   return true
end

-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Pick up a prop and yeet it.", nil, true)
 
	   return self.BaseClass.Initialize(self)
	end
end
if SERVER then
   function SWEP:OnRemove()
      self:PreDrop()
      if self.Owner:IsValid() and self.Owner:IsTerror() then
         self:GetOwner():SelectWeapon("weapon_ttt_unarmed")
      end
   end
end
-- 
