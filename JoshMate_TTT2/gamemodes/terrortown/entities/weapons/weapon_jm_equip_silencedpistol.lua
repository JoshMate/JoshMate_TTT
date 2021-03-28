AddCSLuaFile()

if CLIENT then
   SWEP.PrintName          = "Silenced Pistol"
   SWEP.Slot               = 6

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A silent utility weapon
	
Targets will be slowed and drop their held weapon
            
Has 3 uses
]]
   };

   SWEP.Icon               = "vgui/ttt/icon_silenced"
   SWEP.IconLetter         = "a"
end

SWEP.Base                  = "weapon_tttbase"

SWEP.Primary.Damage        = 20
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Cone          = 0
SWEP.Primary.Recoil        = 0.5
SWEP.Primary.ClipSize      = 3
SWEP.Primary.DefaultClip   = 3
SWEP.Primary.ClipMax       = 0

SWEP.HeadshotMultiplier    = 2
SWEP.DeploySpeed           = 1
SWEP.Primary.SoundLevel    = 40
SWEP.Primary.Automatic     = false

SWEP.Primary.Ammo          = "None"
SWEP.Primary.Sound         = Sound( "Weapon_USP.SilencedShot" )
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_SIPISTOL
SWEP.AmmoEnt               = "None"
SWEP.IsSilent              = true
SWEP.UseHands              = true
SWEP.HoldType              = "pistol"
SWEP.ViewModel             = "models/weapons/cstrike/c_pist_usp.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_usp_silencer.mdl"
SWEP.IronSightsPos         = Vector( -5.91, -4, 2.84 )
SWEP.IronSightsAng         = Vector(-0.5, 0, 0)
SWEP.PrimaryAnim           = ACT_VM_PRIMARYATTACK_SILENCED
SWEP.ReloadAnim            = ACT_VM_RELOAD_SILENCED

local JM_Silenced_Pistol_Duration   = 5

function SWEP:Deploy()
   self:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
   return self.BaseClass.Deploy(self)
end


function RemoveSilencedPistolSlow(ent)
    STATUS:RemoveStatus(ent, "jm_silencedpistol")
    ent:SetNWBool("isSilencedPistoled", false)
end


function SilencedPistolTarget(att, path, dmginfo)
 local ent = path.Entity
 if not IsValid(ent) or not IsPlayer(ent) then return end

 STATUS:AddTimedStatus(ent, "jm_silencedpistol", JM_Silenced_Pistol_Duration, 1)
 
    if SERVER then
    -- Only works on players and only outside of post and prep
    if (not ent:IsPlayer()) or (not GAMEMODE:AllowPVP()) then return end

    -- Drop currently Held Weapon
    if ( ent:IsValid() ) then
      local curWep = ent:GetActiveWeapon()
      ent:GetActiveWeapon():PreDrop()
      if curWep == nil or curWep.AllowDrop == nil or curWep.AllowDrop == false then
         ent:SelectWeapon("weapon_zm_improvised")
      end
      if curWep.AllowDrop == true then
         ent:DropWeapon()
         ent:SelectWeapon("weapon_zm_improvised")
      end
   end
   -- End of Drop
        
    weaponInflictor = dmginfo:GetInflictor()

    timerName = "timer_SilencedPistolRemover_" .. ent:SteamID()
    timer.Create( timerName, JM_Silenced_Pistol_Duration, 1, function () if ent:IsPlayer() and ent:Alive() then RemoveSilencedPistolSlow(ent) end end )
    
    ent:SetNWBool("isSilencedPistoled", true)

    end
end



function SWEP:ShootSilencedPistolShot()
 local cone = self.Primary.Cone
 local bullet = {}
 bullet.Num       = 1
 bullet.Src       = self:GetOwner():GetShootPos()
 bullet.Dir       = self:GetOwner():GetAimVector()
 bullet.Spread    = Vector( cone, cone, 0 )
 bullet.Tracer    = 9999
 bullet.Force     = 1
 bullet.Damage    = self.Primary.Damage
 bullet.TracerName = self.Tracer
 bullet.Callback = SilencedPistolTarget

 self:GetOwner():FireBullets( bullet )
end

function SWEP:PrimaryAttack()
 self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

 if not self:CanPrimaryAttack() then return end

 self:EmitSound( self.Primary.Sound )

 self:SendWeaponAnim( self.PrimaryAnim )

 self:ShootSilencedPistolShot()

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




-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Shoot an enemy", nil, true)
 
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