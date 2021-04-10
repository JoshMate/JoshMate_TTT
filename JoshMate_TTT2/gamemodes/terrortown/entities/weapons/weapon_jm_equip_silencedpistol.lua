
AddCSLuaFile()

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "Silenced Pistol"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Non-Lethal Weapon
	
Slows the target for 5 seconds
   
The target will drop their currently held weapon
   
Has 3 uses, silent, perfect acccuracy and long range
]]
   };

   SWEP.Icon               = "vgui/ttt/icon_silenced"
end

SWEP.Base                  = "weapon_tttbase"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 3
SWEP.Primary.DefaultClip   = 3
SWEP.Primary.ClipMax       = 0
SWEP.DeploySpeed           = 2
SWEP.Primary.SoundLevel    = 40
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = Sound( "Weapon_USP.SilencedShot" )
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_SILENCED
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_pist_usp.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_usp_silencer.mdl"

SWEP.PrimaryAnim           = ACT_VM_PRIMARYATTACK_SILENCED

local JM_Silenced_Pistol_Duration   = 5
local JM_Shoot_Range                = 10000


function SWEP:Deploy()
   self:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
   return self.BaseClass.Deploy(self)
end

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
      
      -- Remove the existing Timer then reset it (To prevent Duplication)
      timerName = "timer_SilencedPistolEndTimer_" .. ent:SteamID64()
      if(timer.Exists(timerName)) then timer.Remove(timerName) end
      timer.Create( timerName, JM_Silenced_Pistol_Duration, 1, function ()
         if(ent:IsValid() and ent:IsPlayer()) then
            ent:SetNWBool("isSilencedPistoled", false)
            STATUS:RemoveStatus(ent, "jm_silencedpistol")
         end 
      end )

      -- JM Changes Extra Hit Marker
      net.Start( "hitmarker" )
      net.WriteFloat(0)
      net.Send(weaponOwner)
      -- End Of
      
      -- Drop currently Held Weapon
      if(ent:IsValid() and ent:IsPlayer()) then
         local curWep = ent:GetActiveWeapon()
         ent:GetActiveWeapon():PreDrop()
         if (curWep.AllowDrop) then
            ent:DropWeapon()
         end
         ent:SelectWeapon("weapon_zm_improvised")
      end
      -- End of Drop

      -- Set Status and print Message
      STATUS:AddTimedStatus(ent, "jm_silencedpistol", JM_Silenced_Pistol_Duration, 1)
      ent:SetNWBool("isSilencedPistoled", true)
      ent:ChatPrint("[Silenced Pistol]: You have been hit!")
      weaponOwner:ChatPrint("[Silenced Pistol]: You have hit someone!")
      -- End Of
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

   -- New Direct Effect Code (Cuts out all the bullet callback code)
   if SERVER then
      local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * JM_Shoot_Range, filter = self.Owner})
      if (tr.Entity:IsValid() and tr.Entity:IsPlayer() and tr.Entity:IsTerror() and tr.Entity:Alive())then
         self:ApplyEffect(tr.Entity, self:GetOwner())
      end
   end
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
	   self:AddTTT2HUDHelp("Shoot a Player", nil, true)
 
	   return self.BaseClass.Initialize(self)
	end
end
if SERVER then
   function SWEP:OnRemove()
      if self.Owner:IsValid() and self.Owner:IsTerror() then
         self:GetOwner():SelectWeapon("weapon_ttt_unarmed")
      end
   end
end
--
