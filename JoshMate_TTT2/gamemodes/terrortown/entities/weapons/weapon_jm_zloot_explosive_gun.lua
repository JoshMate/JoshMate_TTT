
AddCSLuaFile()

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "Big Boy"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Lethal Weapon

An extremely powerful explosive Revolver

Uses heavy ammo found around the world
]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_gun_special.png"
end

SWEP.Base                  = "weapon_jm_base_gun"

-- // Gun Stats

SWEP.Primary.Delay         = 0.03
SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.ClipMax       = 10
SWEP.Primary.SoundLevel    = 100

SWEP.DeploySpeed           = 3
SWEP.Primary.Automatic     = false

-- // End of Gun Stats

SWEP.Primary.Ammo          = "357"
SWEP.AmmoEnt               = "item_jm_ammo_heavy"

SWEP.Primary.Sound         = "shoot_explosive_gun.wav"
SWEP.Secondary.Sound       = Sound("Default.Zoom")
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_EXPLOSIVEGUN
SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/c_357.mdl")
SWEP.WorldModel            = Model("models/weapons/w_357.mdl")

local ExplosiveGun_Boom_Damage               = 70
local ExplosiveGun_Boom_Radius               = 300

local JM_Shoot_Range                         = 10000



function SWEP:HitEffectsInit(ent)
   if not IsValid(ent) then return end

   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   
   
   
   util.Effect("cball_explode", effect, true, true)
end


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

   -- Fire Shot and apply on hit effects (Now with lag compensation to prevent whiffing)
   
   local owner = self:GetOwner()
   if not IsValid(owner) then return end

   owner:LagCompensation(true)
   
   local tr    = util.TraceLine({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * JM_Shoot_Range, filter = owner})
   local pos   = tr.HitPos
   local spos  = tr.HitPos
   
   if SERVER then
      local effect = EffectData()
      effect:SetStart(pos)
      effect:SetOrigin(pos)
      util.Effect("Explosion", effect, true, true)
      util.Effect("HelicopterMegaBomb", effect, true, true)

      -- Blast
      local JMThrower = self:GetOwner()
      util.BlastDamage(self, JMThrower, pos, ExplosiveGun_Boom_Radius, ExplosiveGun_Boom_Damage)

   else
      util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)      
   end

   owner:LagCompensation(false)

   -- #########
end






-- Add some zoom to ironsights for this gun
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
