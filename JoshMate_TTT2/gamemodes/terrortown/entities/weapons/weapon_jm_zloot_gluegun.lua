
AddCSLuaFile()

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "Glue Gun"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false


   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_gluegun.png"
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 5
SWEP.Primary.DefaultClip   = 5
SWEP.Primary.ClipMax       = 0
SWEP.DeploySpeed           = 2
SWEP.Primary.SoundLevel    = 40
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = "shoot_gluegun.wav"
SWEP.Secondary.Sound       = Sound("Default.Zoom")
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {} -- only traitors can buy
SWEP.WeaponID              = AMMO_GLUEGUN
SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/cstrike/c_rif_famas.mdl")
SWEP.WorldModel            = Model("models/weapons/w_rif_famas.mdl")


local glueGunRange         = 1200

function SWEP:HitEffectsInit(ent)
   if not IsValid(ent) then return end

   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   
   
   util.Effect("AntlionGib", effect, true, true)
end

function SWEP:ApplyEffect(ent, weaponOwner)

   if not IsValid(ent) then return end

   self:HitEffectsInit(ent)
   
   if SERVER then
      
      -- JM Changes Extra Hit Marker
      local hitMarkerOwner = self:GetOwner()
      JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)
      -- End Of

      -- Set Status and print Message
      JM_Function_PrintChat(weaponOwner, "Equipment", ent:Nick() .. " has been Glued!" )
      JM_RemoveBuffFromThisPlayer("jm_buff_gluegrenade",ent)
      JM_GiveBuffToThisPlayer("jm_buff_gluegrenade",ent,self:GetOwner())
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

   -- Fire Shot and apply on hit effects (Now with lag compensation to prevent whiffing)
   
   local owner = self:GetOwner()
   if not IsValid(owner) then return end

   if isfunction(owner.LagCompensation) then -- for some reason not always true
      owner:LagCompensation(true)
   end
   
   local tr = util.TraceLine({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * glueGunRange, filter = owner})

   if (tr.Entity:IsValid() and tr.Entity:IsPlayer() and tr.Entity:IsTerror() and tr.Entity:Alive())then
      self:ApplyEffect(tr.Entity, owner)
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