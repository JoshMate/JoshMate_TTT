
AddCSLuaFile()

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "Taser"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Non-Lethal Weapon
	
Stuns the target for 10 seconds
   
Stips them of all their non-purchased weapons
   
Only has 3 uses
]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_usp"
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

SWEP.Primary.Sound         = "shoot_taser.wav"
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_DETECTIVE} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_TASER
SWEP.Tracer                = "AR2Tracer"
SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/c_pistol.mdl")
SWEP.WorldModel            = Model("models/weapons/w_pistol.mdl")

local Taser_Stun_Duration      = 10

local weaponArray = {
   "weapon_jm_secondary_auto",
   "weapon_jm_secondary_light",
   "weapon_jm_secondary_heavy",
   "weapon_jm_primary_rifle",
   "weapon_jm_primary_smg",
   "weapon_jm_primary_shotgun",
   "weapon_jm_primary_sniper",
   "weapon_jm_primary_lmg",
   "weapon_jm_grenade_smoke",
   "weapon_jm_grenade_fire",
   "weapon_jm_grenade_push"
}

function TaseEffects(ent, timerName)
   if not IsValid(ent) then
      timer.Remove(timerName)
      return
   end
   if not ent:GetNWBool("isTased") then
      timer.Remove(timerName)
      return
   end
   if not ent:Alive() then 
      timer.Remove(timerName)
      return 
   end
   local edata = EffectData()
   edata:SetMagnitude(1)
   edata:SetScale(1)
   edata:SetRadius(8)
   local v = ent:GetPos()
   if ent:IsPlayer() then v:Add(Vector(0,0,40))end
   edata:SetOrigin(v)
   util.Effect("Sparks", edata)

end

function TaseEffectsInit(ent)
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

function RemoveTase(ent)
   ent:SetNWBool("isTased", false)
   if (not ent:GetNWBool("isBearTrapped") == true) then ent:Freeze(false) end 
   STATUS:RemoveStatus(ent, "jm_taser")
end

function TaseTarget(att, path, dmginfo)
   local ent = path.Entity
   if not IsValid(ent) then return end

   TaseEffectsInit(ent)
   
   if SERVER then

      -- Only works on players and only outside of post and prep
      if (not ent:IsPlayer()) or (not GAMEMODE:AllowPVP()) then return end
      STATUS:AddTimedStatus(ent, "jm_taser", Taser_Stun_Duration, 1)
      timerName = "timer_TaserEffectTimer_" .. ent:EntIndex()
      timer.Create( timerName, 0.5, Taser_Stun_Duration*2, function () if ent:IsPlayer() and ent:Alive() then TaseEffects(ent, timerName) end end )
      timerName = "timer_TaserEndTimer_" .. ent:EntIndex()
      timer.Create( timerName, Taser_Stun_Duration, 1, function () if ent:IsPlayer() then RemoveTase(ent) end end )

      -- JM Changes Extra Hit Marker
      net.Start( "hitmarker" )
      net.WriteFloat(0)
      net.Send(att)
      -- End Of
      
      ent:GetActiveWeapon():PreDrop()

      ent:Freeze(true)
      ent:SetNWBool("isTased", true)

      for names = 1, #weaponArray do
         ent:StripWeapon(weaponArray[names])
      end

      ent:SelectWeapon("weapon_zm_improvised")

      ent:ChatPrint("[Taser]: You have been Tased!")
      

   end
end

function SWEP:ShootTaserShot()
   local cone = self.Primary.Cone
   local bullet = {}
   bullet.Num       = 1
   bullet.Src       = self:GetOwner():GetShootPos()
   bullet.Dir       = self:GetOwner():GetAimVector()
   bullet.Spread    = Vector( cone, cone, 0 )
   bullet.Tracer    = 1
   bullet.Force     = 2
   bullet.Damage    = self.Primary.Damage
   bullet.TracerName = self.Tracer
   bullet.Callback = TaseTarget

   self:GetOwner():FireBullets( bullet )
end

function SWEP:PrimaryAttack()
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not self:CanPrimaryAttack() then return end

   self:EmitSound( self.Primary.Sound )

   self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

   self:ShootTaserShot()

   self:TakePrimaryAmmo( 1 )

   if IsValid(self:GetOwner()) then
      self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

      self:GetOwner():ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
   end

   if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
      self:SetNWFloat( "LastShootTime", CurTime() )
   end

   if SERVER then
      if self:Clip1() <= 0 then
         self:Remove()
      end
   end
end

function SWEP:SecondaryAttack()
end

-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Tase an Player", nil, true)
 
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
