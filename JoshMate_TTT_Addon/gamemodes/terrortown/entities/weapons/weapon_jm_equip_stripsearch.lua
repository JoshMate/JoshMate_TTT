
AddCSLuaFile()

SWEP.HoldType              = "normal"

if CLIENT then
   SWEP.PrintName          = "Strip Search"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Utility Weapon
	
Left clicking a player will strip them of their weapons

Does not include Special or bought weapons

Has 2 uses and short range
]]
};

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_stripsearch.png"

   function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 25 - ang:Right() *-12 - ang:Up() * 8, ang
	end

end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.50
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 2
SWEP.Primary.DefaultClip   = 2
SWEP.Primary.ClipMax       = 0
SWEP.Primary.SoundLevel    = 0
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = nil
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_DETECTIVE} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_STRIPSEARCH
SWEP.UseHands              = false
SWEP.ViewModel             = "models/props_lab/desklamp01.mdl"
SWEP.WorldModel            = "models/props_lab/desklamp01.mdl"

local JM_Shoot_Range = 196

function SWEP:ApplyEffect(ent,weaponOwner)

   if not IsValid(ent) then return end
   
   if SERVER then

      JM_Function_PrintChat(weaponOwner, "Equipment", ent:Nick() .. " has been stripped of their weapons!" )
      JM_Function_PrintChat(ent, "Equipment", weaponOwner:Nick() .. " has stripped you of your weapons!" )

      -- Give a Hit Marker to This Player
      local hitMarkerOwner = self:GetOwner()
      JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)

      -- Remove Weapons on Player
      ent:StripWeapon("weapon_jm_primary_lmg")
      ent:StripWeapon("weapon_jm_primary_rifle")
      ent:StripWeapon("weapon_jm_primary_shotgun")
      ent:StripWeapon("weapon_jm_primary_smg")
      ent:StripWeapon("weapon_jm_primary_sniper")
      ent:StripWeapon("weapon_jm_primary_shotgun")
      ent:StripWeapon("weapon_jm_primary_smg")
      ent:StripWeapon("weapon_jm_secondary_auto")
      ent:StripWeapon("weapon_jm_secondary_heavy")
      ent:StripWeapon("weapon_jm_secondary_light")
      ent:StripWeapon("weapon_jm_grenade_frag")
      ent:StripWeapon("weapon_jm_grenade_glue")
      ent:StripWeapon("weapon_jm_grenade_health")
      ent:StripWeapon("weapon_jm_grenade_jump")
      ent:StripWeapon("weapon_jm_grenade_tag")

      ent:SelectWeapon("weapon_jm_special_crowbar")

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
      if tr.Entity:IsPlayer() and tr.Entity:IsTerror() and tr.Entity:Alive()then
         self:ApplyEffect(tr.Entity, owner, true)
         self:TakePrimaryAmmo( 1 )
         owner:EmitSound("stripsearch.mp3")         
      end
   else
      JM_Function_PrintChat(owner, "Equipment", "No Target to strip search..." )
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
	   self:AddTTT2HUDHelp("Strip a player's weapons", nil, true)
 
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