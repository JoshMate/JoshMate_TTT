AddCSLuaFile()

SWEP.HoldType              = "duel"

if CLIENT then
   SWEP.PrintName          = "Vampire Pistols"
   SWEP.Slot               = 1

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_gun_special.png"
   SWEP.IconLetter         = "u"
end

SWEP.Base                  = "weapon_jm_base_gun"
SWEP.CanBuy                = {}

SWEP.Kind                  = WEAPON_PISTOL
SWEP.WeaponID              = AMMO_ADVANCED_PISTOL_DUAL

-- // Gun Stats

SWEP.Primary.Damage        = 25
SWEP.Primary.NumShots      = 1
SWEP.Primary.Delay         = 0.15
SWEP.Primary.Cone          = 0.008
SWEP.Primary.Recoil        = 1
SWEP.Primary.Range         = 3000
SWEP.Primary.ClipSize      = 32
SWEP.Primary.DefaultClip   = 32
SWEP.Primary.ClipMax       = 0
SWEP.Primary.SoundLevel    = 75

SWEP.HeadshotMultiplier    = 1
SWEP.DeploySpeed           = 1
SWEP.BulletForce           = 30
SWEP.Primary.Automatic     = false

-- // End of Gun Stats

SWEP.Primary.Ammo          = "none"
SWEP.Primary.Sound         = "shoot_dual_pistols.wav"
SWEP.AutoSpawnable         = true
SWEP.UseHands              = true
SWEP.Tracer                = "AR2Tracer"
SWEP.ViewModel             = "models/weapons/cstrike/c_pist_elite.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_elite.mdl"

-- JM Changes, Movement Speed
SWEP.MoveMentMultiplier = 1.3
-- End of

-- Dual Animations
SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK

function SWEP:HitEffectsInit(ent)
   if not IsValid(ent) then return end

   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   util.Effect("bloodspray", effect, true, true)
   util.Effect("BloodImpact", effect, true, true)
   
   local jitter = VectorRand() * 15
   jitter.z = 20
   util.PaintDown(ent:GetPos() + jitter, "Blood", ent)
   
end

function SWEP:ApplyEffect(ent,weaponOwner)

   if not IsValid(ent) then return end
   self:HitEffectsInit(ent)
   
   if SERVER then
      
      -- Give a Hit Marker to This Player
      local hitMarkerOwner = self:GetOwner()
      JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)

      -- Deal Damage
      local dmg = DamageInfo()
      local attacker = nil
      local Owner = self:GetOwner()
      local attacker = Owner

      local inflictor = ents.Create("weapon_jm_zloot_dual_pistols")
      dmg:SetInflictor(inflictor)
      dmg:SetAttacker(attacker)
      dmg:SetDamage(self.Primary.Damage)
      dmg:SetDamageType(DMG_BULLET)
      dmg:SetDamageForce(Vector( 0, 0, 0 ))
      ent:TakeDamageInfo(dmg)

      -- Heal the User
      local dmgHeal = (self.Primary.Damage * 0.75)
      Owner:SetHealth(math.Clamp(Owner:Health() + dmgHeal, 0, Owner:GetMaxHealth() + 50))

   end
end

function SWEP:PrimaryAttack(worldsnd)

   -- Weapon Animation, Sound and Cycle data
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
   self:EmitSound( self.Primary.Sound )
   self:TakePrimaryAmmo( 1 )
   if IsValid(self:GetOwner()) then
      self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
   end
   -- #########

   -- Handle Dual Pistols Anim
   local doOnce = false
   if self.PrimaryAnim == ACT_VM_PRIMARYATTACK and doOnce == false then
      doOnce = true
      self.PrimaryAnim = ACT_VM_SECONDARYATTACK
   end
   if self.PrimaryAnim == ACT_VM_SECONDARYATTACK and doOnce == false then
      doOnce = true
      self.PrimaryAnim = ACT_VM_PRIMARYATTACK
   end
   self:SendWeaponAnim( self.PrimaryAnim )
   -- #########

   -- Fire Shot and apply on hit effects (Now with lag compensation to prevent whiffing)
   
   local owner = self:GetOwner()
   if not IsValid(owner) then return end

   if isfunction(owner.LagCompensation) then -- for some reason not always true
      owner:LagCompensation(true)
   end
   
   local tr = util.TraceLine({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * self.Primary.Range, filter = owner})
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

-- No Iron Sights
function SWEP:SecondaryAttack()
   return
end

-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Shoot your target", nil, true)
 
	   return self.BaseClass.Initialize(self)
	end
end
if SERVER then
   function SWEP:OnRemove()
      self:PreDrop()
      if self.Owner:IsValid() and self.Owner:IsTerror() then
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
      end
   end
end
-- 




