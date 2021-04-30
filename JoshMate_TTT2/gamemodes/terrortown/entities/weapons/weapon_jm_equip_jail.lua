-- TODO
-- SOUNDS
-- add jail
-- remove jail

AddCSLuaFile()

SWEP.HoldType              = "ar2"

if CLIENT then
   SWEP.PrintName          = "Jailer"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[Pop a lad in jail]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_poisondart.png"
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

SWEP.Primary.Sound         = "jailer_hit.wav"   
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_DETECTIVE} 
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_JAILER
SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/c_irifle.mdl")
SWEP.WorldModel            = Model("models/weapons/w_irifle.mdl")

local JM_Shoot_Range = 10000
local jail_duration = 10

local mdl1 = Model( "models/props_building_details/Storefront_Template001a_Bars.mdl" )
local jail = {
	{ pos = Vector( 0, 0, -5 ), ang = Angle( 90, 0, 0 ), mdl=mdl1 },
	{ pos = Vector( 0, 0, 97 ), ang = Angle( 90, 0, 0 ), mdl=mdl1 },
	{ pos = Vector( 21, 31, 46 ), ang = Angle( 0, 90, 0 ), mdl=mdl1 },
	{ pos = Vector( 21, -31, 46 ), ang = Angle( 0, 90, 0 ), mdl=mdl1 },
	{ pos = Vector( -21, 31, 46 ), ang = Angle( 0, 90, 0 ), mdl=mdl1 },
	{ pos = Vector( -21, -31, 46), ang = Angle( 0, 90, 0 ), mdl=mdl1 },
	{ pos = Vector( -52, 0, 46 ), ang = Angle( 0, 0, 0 ), mdl=mdl1 },
	{ pos = Vector( 52, 0, 46 ), ang = Angle( 0, 0, 0 ), mdl=mdl1 },
}

local walls = {}
local currentPrisoner = nil

function is_empty(t)
    for _,_ in pairs(t) do
        return false
    end
    return true
end

function SWEP:PrimaryAttack()

    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
    if not self:CanPrimaryAttack() then return end
    self:EmitSound( self.Primary.Sound )
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self:TakePrimaryAmmo( 1 )
    if IsValid(self:GetOwner()) then
       self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
    end

    if SERVER then
        local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * JM_Shoot_Range, filter = self.Owner})
        if (tr.Entity:IsValid() and tr.Entity:IsPlayer() and tr.Entity:IsTerror() and tr.Entity:Alive())then
            RemoveJail()
            PutInJail(tr.Entity)
        end
    end

    if SERVER then
        if self:Clip1() <= 0 then
           self:Remove()
        end
     end
end

function PutInJail(ent) 
    if not is_empty(walls) then 
        if not (currentPrisoner == nil) then
            RemoveJail()
        end
    end
    
    if(timer.Exists(("timer_EndJailTimer_" .. ent:SteamID64()))) then timer.Remove(("timer_EndJailTimer_" .. ent:SteamID64())) end
      timer.Create( ("timer_EndJailTimer_" .. ent:SteamID64()), jail_duration, 1, function ()
            if (not ent:IsValid() or not ent:IsPlayer()) then timer.Remove(("timer_EndJailTimer_" .. ent:SteamID64())) return end
            RemoveJail()
      end )

    local pos = ent:GetPos()

	for _, info in ipairs( jail ) do
		local ent = ents.Create( "prop_physics" )
		ent:SetModel( info.mdl )
		ent:SetPos( pos + info.pos )
		ent:SetAngles( info.ang )
		ent:Spawn()
		ent:GetPhysicsObject():EnableMotion( false )
		ent:SetMoveType( MOVETYPE_NONE )
		ent.jailWall = true
        ent:DisallowDeleting(true)
		table.insert( walls, ent )
	end

    currentPrisoner = ent:SteamID64()
end

function RemoveJail()
    for _, ent in ipairs( walls ) do
        if ent:IsValid() then
            ent:DisallowDeleting( false )
            ent:Remove()
        end
    end
    if(currentPrisoner != nil) then
        timer.Remove(("timer_EndJailTimer_" .. currentPrisoner))
    end
    currentPrisoner = nil
end