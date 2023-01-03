
AddCSLuaFile()

SWEP.HoldType              = "normal"

if CLIENT then
   SWEP.PrintName          = "Prop Bomb"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A AOE Weapon
	
Fire at a prop to set it on fire, after a short delay it explodes!

Has 1 uses
]]
};

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_propbomb.png"

   function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 35 - ang:Right() *-15 - ang:Up() * 20, ang
	end

end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.50
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.ClipMax       = 0
SWEP.Primary.SoundLevel    = 0
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = nil
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_PROPBOMB
SWEP.UseHands              = false
SWEP.ViewModel             = "models/dynamite/dynamite.mdl"
SWEP.WorldModel            = "models/dynamite/dynamite.mdll"

local JM_Shoot_Range = 10000

function SWEP:ApplyEffect(ent,weaponOwner)

   if not IsValid(ent) then return end
   
   if SERVER then

      JM_Function_PrintChat(weaponOwner, "Equipment", "Prop Bomb Planted!" )

      -- Give a Hit Marker to This Player
      local hitMarkerOwner = self:GetOwner()
      JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)

      -- Prop Bomb the Target
      local propBomb = ents.Create("ent_jm_equip_propbomb")
      propBomb.propBombProp = ent
      propBomb.propBombOwner = self:GetOwner()
      propBomb:Spawn()
      -- End of

   end
end

function SWEP:PrimaryAttack()

   -- Weapon Animation, Sound and Cycle data
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   -- #########

   -- Fire Shot and apply on hit effects (Now with lag compensation to prevent whiffing)
   
   local owner = self:GetOwner()
   if not IsValid(owner) then return end

   if isfunction(owner.LagCompensation) then -- for some reason not always true
      owner:LagCompensation(true)
   end
   
   local tr = util.TraceLine({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * JM_Shoot_Range, filter = owner})

   if tr.Entity:IsValid() then
      if tr.Entity:GetClass() == "prop_physics" then
         self:ApplyEffect(tr.Entity, owner, false)
         self:TakePrimaryAmmo( 1 )
         if CLIENT then surface.PlaySound("propbomb_shoot.wav") end
      end
   else
      JM_Function_PrintChat(owner, "Equipment", "Only non special props can be turned into Prop Bombs!" )
      if CLIENT then surface.PlaySound("proplauncher_fail.wav") end
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
	   self:AddTTT2HUDHelp("Turn a prop into a Prop Bomb", nil, true)
 
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