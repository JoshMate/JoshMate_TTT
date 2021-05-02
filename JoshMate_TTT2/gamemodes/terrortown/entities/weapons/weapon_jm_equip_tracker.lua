
AddCSLuaFile()

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "Tracking Dart"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A utilty weapon
	
Tracks the target through walls for 60 seconds
   
Has 3 uses, silent, perfect acccuracy and long range
]]
};

   SWEP.Icon = "vgui/ttt/joshmate/icon_jm_tracker.png"
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 3
SWEP.Primary.DefaultClip   = 3
SWEP.Primary.ClipMax       = 0
SWEP.DeploySpeed           = 2
SWEP.Primary.SoundLevel    = 100
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = "shoot_tracker.wav"
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_DETECTIVE}
SWEP.LimitedStock          = true
SWEP.WeaponID              = AMMO_TRACKER
SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/c_357.mdl")
SWEP.WorldModel            = Model("models/weapons/w_357.mdl")

local JM_Shoot_Range                = 10000

function SWEP:HitEffectsInit(ent)
   if not IsValid(ent) then return end

   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   
   util.Effect("TeslaZap", effect, true, true)
   util.Effect("TeslaHitboxes", effect, true, true)
   util.Effect("cball_explode", effect, true, true)
end

function SWEP:ApplyEffect(ent,weaponOwner)

   if not IsValid(ent) then return end
   self:HitEffectsInit(ent)
   
   if SERVER then
      
      -- Set Status and print Message
      weaponOwner:ChatPrint("[Tracking Dart]: You hit someone!")
      JM_RemoveBuffFromThisPlayer("jm_buff_trackingdart",ent)
      JM_GiveBuffToThisPlayer("jm_buff_trackingdart",ent,self:GetOwner())
      -- End Of

      -- JM Changes Extra Hit Marker
      net.Start( "hitmarker" )
      net.WriteFloat(0)
      net.Send(weaponOwner)
      -- End Of

   end
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

   if isfunction(owner.LagCompensation) then -- for some reason not always true
      owner:LagCompensation(true)
   end
   
   local tr = util.TraceLine({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * JM_Shoot_Range, filter = owner})
   if (tr.Entity:IsValid() and tr.Entity:IsPlayer() and tr.Entity:IsTerror() and tr.Entity:Alive())then
      self:ApplyEffect(tr.Entity, owner)
   end

   owner:LagCompensation(false)

   -- #########

   -- Remove Weapon When out of Ammo
   if SERVER then
      if self:Clip1() <= 0 then
         self:Remove()
      end
   end
   -- #########

end

function SWEP:SecondaryAttack()
end


-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Track a player", nil, true)
 
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


