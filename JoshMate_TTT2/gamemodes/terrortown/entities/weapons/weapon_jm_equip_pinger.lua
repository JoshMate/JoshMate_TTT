AddCSLuaFile()

SWEP.HoldType = "ar2"

if CLIENT then 
   SWEP.PrintName = "Pinger"
   SWEP.Slot = 6
   SWEP.ViewModelFOV = 54
   SWEP.ViewModelFlip = false
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[pop an e lad]]
   };

    SWEP.Icon = "vgui/ttt/joshmate/icon_jm_pinger.png"
end

SWEP.Base = "weapon_tttbase"

SWEP.Primary.Recoil        = 2
SWEP.Primary.Damage        = 1
SWEP.HeadshotMultiplier    = 1
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 3
SWEP.Primary.DefaultClip   = 3
SWEP.Primary.ClipMax       = 0
SWEP.DeploySpeed           = 1
SWEP.Primary.SoundLevel    = 50
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = "shoot_pinger.wav"
SWEP.Tracer                = "None"
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_DETECTIVE} 
SWEP.LimitedStock          = true 
SWEP.WeaponID              = AMMO_PINGER
SWEP.UseHands              = true
SWEP.IsSilent              = true
SWEP.ViewModel             = Model("models/weapons/cstrike/c_rif_aug.mdl")
SWEP.WorldModel            = Model("models/weapons/w_rif_aug.mdl")

local ping_duration = 30
local ping_delay = 3

function PingEffect_Tick(ent, att, timerName)
    print("ping tick")
    if SERVER then
        if not IsValid(ent) then
            return
        end
        if not ent:GetNWBool("isPinging") then
            timer.Remove(timerName)
        end
        ent:EmitSound(Sound("ping_jake.wav"), 75)
    end
end

function RemovePing(ent) 
    print("not pinging")
    ent:SetNWBool("isPinging", false)
end

function PingTarget(att, path) 
    print("starting ping")
    local ent = path.Entity
    if not IsValid(ent) or not IsPlayer(ent) then return end

    if SERVER then
        if(not ent:IsPlayer()) or (not GAMEMODE:AllowPVP()) then return end

        timerName = "timer_PingEffectTimer_" .. ent:EntIndex()
        timer.Create(timerName, ping_delay, ping_duration / ping_delay, 
            function() 
                if ent:IsPlayer() then
                    print("work pls")
                    PingEffect_Tick(ent, att, timerName)
                end
            end)
        timerName = "timer_PingRemoveTimer_" .. ent:EntIndex()
        timer.Create(timerName, ping_duration, 1, 
            function() 
                if ent:IsPlayer() then
                    RemovePing(ent)
                end
            end)
        
        ent:ChatPrint("[Pinger]: You're pinging lad!")
        ent:SetNWBool("isPinging", true)
    end
end

function SWEP:ShootPingerShot()
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
    bullet.Callback = PingTarget
 
    self:GetOwner():FireBullets( bullet )
 end

 function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
 
    if not self:CanPrimaryAttack() then return end
 
    self:EmitSound( self.Primary.Sound )
 
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
 
    self:ShootPingerShot()
 
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

 function SWEP:PreDrop()
    self:SetZoom(false)
    self:SetIronsights(false)
    return self.BaseClass.PreDrop(self)
 end
 
 function SWEP:Reload()
     if ( self:Clip1() == self.Primary.ClipSize or self:GetOwner():GetAmmoCount( self.Primary.Ammo ) <= 0 ) then return end
    self:DefaultReload( ACT_VM_RELOAD )
 end

 function SWEP:Holster()
    self:SetIronsights(false)
    self:SetZoom(false)
    return true
 end

 if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Put a pinger on an enemy", nil, true)
 
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