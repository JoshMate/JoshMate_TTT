
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
SWEP.Primary.SoundLevel    = 100
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = "shoot_tracker.wav"
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_DETECTIVE} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_TRACKER
SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/c_357.mdl")
SWEP.WorldModel            = Model("models/weapons/w_357.mdl")

local JM_Tracker_Duration           = 60
local JM_Tracker_Colour             = Color( 255, 255, 0 )
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
   HitEffectsInit(ent)
   
   if SERVER then
      
      -- Remove the existing Timer then reset it (To prevent Duplication)
      timerName = "timer_TrackingEndTimer_" .. ent:SteamID64()
      if(timer.Exists(timerName)) then timer.Remove(timerName) end
      timer.Create( timerName, JM_Tracker_Duration, 1, function ()
         if(ent:IsValid() and ent:IsPlayer()) then
            ent:SetNWBool("isTracked", false)
            STATUS:RemoveStatus(ent, "jm_tracker")
         end 
      end )

      -- JM Changes Extra Hit Marker
      net.Start( "hitmarker" )
      net.WriteFloat(0)
      net.Send(weaponOwner)
      -- End Of

      -- Set Status and print Message
      STATUS:AddTimedStatus(ent, "jm_tracker", JM_Tracker_Duration, 1)
      ent:SetNWBool("isTracked", true)
      ent:ChatPrint("[Tracking Dart]: You're being tracked")
      weaponOwner:ChatPrint("[Tracking Dart]: You have hit someone!")
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

   -- New Direct Effect Code (Cuts out all the bullet callback code)
   if SERVER then
      local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * JM_Shoot_Range, filter = self.Owner})
      if (tr.Entity:IsValid() and tr.Entity:IsTerror() and tr.Entity:Alive())then
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
	   self:AddTTT2HUDHelp("Track a player", nil, true)
 
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


-- ESP Halo effect
hook.Add( "PreDrawHalos", "Halos_Tracking_Dart", function()

   local players = {}
	local count = 0

	for _, ply in ipairs( player.GetAll() ) do
		if (ply:IsTerror() and ply:Alive() and ply:GetNWBool("isTracked") ) then
            count = count + 1
			players[ count ] = ply
		end
	end

    halo.Add( players, JM_Tracker_Colour, 1, 1, 1, true, true )

end )