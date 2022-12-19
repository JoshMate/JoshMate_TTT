
AddCSLuaFile()

SWEP.HoldType              = "ar2"

if CLIENT then
   SWEP.PrintName          = "Glue Gun"
   SWEP.Slot               = 2

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Setup Weapon

A weapon that bullets also inflict an AOE glue effect

Glue slows, tags and makes the target take extra damage
   
Goes in the primary weapon slot and deals damage (Not karma free)
]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_gluegun.png"
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.25
SWEP.Primary.Cone          = 0.012
SWEP.Primary.ClipSize      = 5
SWEP.Primary.DefaultClip   = 5
SWEP.Primary.ClipMax       = 0
SWEP.Primary.SoundLevel    = 70
SWEP.Primary.Automatic     = false

SWEP.Primary.Ammo          = "None"
SWEP.Primary.Sound         = "shoot_gluegun.wav"
SWEP.Secondary.Sound       = Sound("Default.Zoom")
SWEP.Kind                  = WEAPON_HEAVY
SWEP.CanBuy                = {} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_GLUEGUN
SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/cstrike/c_rif_sg552.mdl")
SWEP.WorldModel            = Model("models/weapons/w_rif_sg552.mdl")

local glueHitRadius                 = 256
local JM_Shoot_Range                = 10000


function SWEP:HitEffectsInit(ent)
   if not IsValid(ent) then return end

   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   util.Effect("AntlionGib", effect, true, true)
end

function SWEP:ExplodeEffects(pos)
   local effect = EffectData()
   effect:SetStart(pos)
   effect:SetOrigin(pos)
   util.Effect("AntlionGib", effect, true, true)
end

function SWEP:Explode(tr)
   -- Decal Effects
   if (SERVER) then
      local spos = self:GetPos()
      util.Decal("BeerSplash", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
      util.Decal("YellowBlood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal) 
   end

   -- Server Side Mechanics
   if (SERVER) then
      sound.Play("grenade_glue.wav", tr.HitPos, 80, 100, 1)
      self:ExplodeEffects(tr.HitPos)
      local totalPeopleTagged = 0

      for _,pl in pairs(player.GetAll()) do

         local playerPos = pl:GetShootPos()
         local nadePos = tr.HitPos

         -- Do to all players in radius
         if nadePos:Distance(playerPos) <= glueHitRadius then
            if pl:IsTerror() and pl:Alive() then
               totalPeopleTagged = totalPeopleTagged + 1

               -- Deal Damage
               --local dmg = DamageInfo()
               --dmg:SetDamage(self.Primary.Damage)
               --dmg:SetAttacker(self:GetOwner())
               --dmg:SetInflictor(self)
               --dmg:SetDamageForce(self:EyeAngles():Forward())
               --dmg:SetDamagePosition(self:GetPos())
               --dmg:SetDamageType(DMG_BULLET)   
               --pl:TakeDamageInfo(dmg)

               -- Glue Effects
               if (pl:IsValid() and pl:IsPlayer() and pl:IsTerror() and pl:Alive()) then
                  self:HitEffectsInit(pl)
                  JM_GiveBuffToThisPlayer("jm_buff_glue",pl,self:GetOwner())
               end
               -- End Of
            end
         end
      end
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
   
   local tr = util.TraceLine({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * JM_Shoot_Range, filter = owner})
   self:Explode(tr)

   owner:LagCompensation(false)

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
	   self:AddTTT2HUDHelp("Glue explosion at range", nil, true)
 
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

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################
