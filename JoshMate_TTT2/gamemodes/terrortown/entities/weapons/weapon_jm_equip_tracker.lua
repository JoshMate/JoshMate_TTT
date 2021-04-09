AddCSLuaFile()

SWEP.HoldType = "Pistol"

if CLIENT then 
   SWEP.PrintName = "Tracking Dart"
   SWEP.Slot = 6
   SWEP.ViewModelFOV = 54
   SWEP.ViewModelFlip = false
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A utilty weapon
	
Shoot a player to track them (Does No Damage)
            
Tracked players can be seen by everyone through walls
            
3 uses and each track lasts for 45 seconds
]]
};


    SWEP.Icon = "vgui/ttt/joshmate/icon_jm_tracker.png"
end

SWEP.Base = "weapon_tttbase"

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
SWEP.Tracer                = "AR2Tracer"
SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/c_357.mdl")
SWEP.WorldModel            = Model("models/weapons/w_357.mdl")

local JM_Tracker_Duration = 60
local JM_Tracker_Colour = Color( 255, 255, 0 )

function TrackerEffectsInit(ent)
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

function TrackTarget(att, path) 
    local ent = path.Entity
    if not IsValid(ent) or not IsPlayer(ent) then return end
    if not ent:IsTerror() or not ent:Alive() then return end

    TrackerEffectsInit(ent)
    STATUS:AddTimedStatus(ent, "jm_tracker", JM_Tracker_Duration, 1)

    if SERVER then

        timerName = "timer_Tracker_RemoveTimer" .. ent:SteamID64()
        timer.Create(timerName, JM_Tracker_Duration, 1, 
            function() 
                if ent:IsPlayer() then
                    ent:SetNWBool("isTracked", false)
                    STATUS:RemoveStatus(ent, "jm_tracker")
                end
        end)
        
        ent:ChatPrint("[Tracking Dart]: You're being tracked!")
        ent:SetNWBool("isTracked", true)
    end
end

function SWEP:ShootTrackerShot()
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
    bullet.Callback = TrackTarget
 
    self:GetOwner():FireBullets( bullet )
 end

 function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
 
    if not self:CanPrimaryAttack() then return end
 
    self:EmitSound( self.Primary.Sound )
 
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
 
    self:ShootTrackerShot()
 
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


-- ESP Halo effect
hook.Add( "PreDrawHalos", "Add", function()

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