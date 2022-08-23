
AddCSLuaFile()

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "Grappling Hook"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Movement Item
	
Left Click: Shoot a grappling hook

Has 6 uses
]]
};

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_gun_special.png"
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 6
SWEP.Primary.DefaultClip   = 6
SWEP.Primary.ClipMax       = 0
SWEP.Primary.SoundLevel    = 20
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = Sound( "Weapon_USP.SilencedShot" )
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {}
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_GRAPPLEHOOK
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_pist_fiveseven.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_fiveseven.mdl"

local JM_Shoot_Range                = 10000

SWEP.GrappleIsHooked                = false
SWEP.GrappleHookPos                 = nil




function SWEP:PrimaryAttack()

   -- Weapon Animation, Sound and Cycle data
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
   self:EmitSound( self.Primary.Sound )
   self:SendWeaponAnim( self.PrimaryAnim )
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
   if (tr.HitWorld) then
      -- Create the Hook Ent
      if SERVER then
         local newHook = ents.Create("ent_jm_zloot_hookrope")
         newHook.hookHitPos = tr.HitPos
         newHook.hookOwner = self:GetOwner()
         newHook:Spawn()
      end
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

   -- Check for Use Counters
   if self.Swapper_Use_Count_Location >= self.JM_Swapper_Max_Use_Location then 

      self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
      if not self:CanSecondaryAttack() then return end

      if SERVER then  
         JM_Function_PrintChat(self:GetOwner(), "Equipment", "You have already swapped Places the maximum amount of times")
      end
      return
   end
   
   -- #########

   -- Check for crouching user

   if self:GetOwner():Crouching() then

      self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
      if not self:CanSecondaryAttack() then return end

      if SERVER then 
         JM_Function_PrintChat(self:GetOwner(), "Equipment", "You can't swap places while YOU are Crouched")
      end

      return
   end
   -- #########

   -- Weapon Animation, Sound and Cycle data
   self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
   if not self:CanSecondaryAttack() then return end
   self:EmitSound( self.Primary.Sound )
   self:SendWeaponAnim( self.PrimaryAnim )
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
      self:ApplyEffect(tr.Entity, owner,true)
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



-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Swap HP", "Swap Places", true)
 
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
