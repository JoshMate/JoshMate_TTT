
AddCSLuaFile()

if CLIENT then
   SWEP.PrintName          = "Swapper"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Set-Up Weapon
	
Left Click: Swap HP with another player you are aiming at

Has 1 use
]]
};

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_swapper.png"

   function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 30 - ang:Right() * -12 - ang:Up() * 12, ang
	end

end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 1
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.ClipMax       = 0
SWEP.Primary.SoundLevel    = 20
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = Sound( "Weapon_USP.SilencedShot" )
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_SWAPPER
SWEP.UseHands              = false
SWEP.ViewModel             = "models/maxofs2d/button_01.mdl"
SWEP.WorldModel            = "models/maxofs2d/button_01.mdl"
SWEP.HoldType 				   = "normal" 


local JM_Shoot_Range                = 10000

function SWEP:ApplyEffect(ent,weaponOwner)

   if not IsValid(ent) then return end
   
   if SERVER then

      -- Give a Hit Marker to This Player
      local hitMarkerOwner = self:GetOwner()
      JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)

      if not ent:IsTerror() or not ent:Alive() then return end

      -- Swap
      activator = self:GetOwner()
      Victim = ent

      -- Perform the actual swap
      local PosActivator = activator:GetPos()
      local PosVictim = Victim:GetPos()
      activator:SetPos(PosVictim)
      Victim:SetPos(PosActivator)
      if SERVER then Victim:EmitSound(Sound("effect_swapping_places.mp3")) end
      if SERVER then activator:EmitSound(Sound("effect_swapping_places.mp3")) end
      JM_Function_PrintChat(Victim, "Equipment", "Someone has swapped places with you")
      JM_Function_PrintChat(activator, "Equipment", "You have swapped places with: " .. tostring(Victim:Nick()))
      -- End of

   end
end

function SWEP:PrimaryAttack()

   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
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
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
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
      self:TakePrimaryAmmo( 1 )
   else
      JM_Function_PrintChat(self:GetOwner(), "Equipment", "You must aim at another play to swap with them...")
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
   return
end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Swap Places", nil, true)
 
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
-- Hide World Model when Equipped
function SWEP:DrawWorldModel()
   if IsValid(self:GetOwner()) then return end
   self:DrawModel()
end
function SWEP:DrawWorldModelTranslucent()
   if IsValid(self:GetOwner()) then return end
   self:DrawModel()
end
-- Delete on Drop
function SWEP:OnDrop() 
   self:Remove()
end

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################
