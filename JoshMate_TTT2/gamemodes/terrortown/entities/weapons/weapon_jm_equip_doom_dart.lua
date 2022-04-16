
AddCSLuaFile()

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "Doom Dart"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Set-Up Weapon
	
Hitting a target marks them with Doom.

Doomed players explode on death dealing DMG to others.

Mark up to 2 players, who won't be informed they are doomed.
]]
};

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_silencedpistol.png"
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 2
SWEP.Primary.DefaultClip   = 2
SWEP.Primary.ClipMax       = 0
SWEP.Primary.SoundLevel    = 20
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = Sound( "Weapon_USP.SilencedShot" )
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_DOOMDART
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_pist_usp.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_usp_silencer.mdl"

SWEP.PrimaryAnim           = ACT_VM_PRIMARYATTACK_SILENCED

local JM_Shoot_Range = 10000
local isDoomableNPC = { 
   npc_zombie = true,
   npc_fastzombie = true,
   npc_headcrab = true,
   npc_headcrab_fast = true,
   npc_poisonzombie = true,
   npc_seagull = true,
   npc_pigeon = true,
   npc_crow = true,
   npc_antlion = true
}


function SWEP:Deploy()
   self:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
   return self.BaseClass.Deploy(self)
end

function SWEP:ApplyEffect(ent,weaponOwner, targetIsPlayer)

   if not IsValid(ent) then return end
   
   if SERVER then

      -- Give a Hit Marker to This Player
      JM_Function_GiveHitMarkerToPlayer(weaponOwner, 0, false)

      local deathMessage
      if targetIsPlayer then
         JM_Function_PrintChat(weaponOwner, "Equipment", ent:Nick() .. " has been Doom Darted!" )
         deathMessage = "Doomed " .. ent:Nick() .. " has EXPLODED!"
      else
         JM_Function_PrintChat(weaponOwner, "Equipment", string.sub(ent:GetClass(), 5) .. " has been Doom Darted!" )
         deathMessage = "Doomed " .. string.sub(ent:GetClass(), 5) ..  " has EXPLODED!"
      end
      

      -- Doom the Target
      local doomDart = ents.Create("ent_jm_equip_doom_dart")
      doomDart.doomedTarget = ent
      doomDart.doomedBy = self:GetOwner()
      doomDart.targetIsPlayer = targetIsPlayer
      doomDart.deathMessage = deathMessage
      doomDart:Spawn()
      -- End of
         

   end
end

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

   if tr.Entity:IsValid() then
      if tr.Entity:IsNPC() and isDoomableNPC[tr.Entity:GetClass()] == true then
         self:ApplyEffect(tr.Entity, owner, false)
      end
 
      if tr.Entity:IsPlayer() and tr.Entity:IsTerror() and tr.Entity:Alive()then
         self:ApplyEffect(tr.Entity, owner, true)
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
   return
end


-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Doom a player to explode on death", nil, true)
 
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
