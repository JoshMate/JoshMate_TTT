
AddCSLuaFile()

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "Suppression Orb"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[An AOE Weapon

Creates a large orb of suppression that slows those who stand in it

Has 1 use and lingers for 60 Seconds. Players can't see you holding this
]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_orb_suppression.png"

   function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() *35 - ang:Right() *-15 - ang:Up() * 50, ang
	end

end



SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.ClipMax       = 0
SWEP.Primary.SoundLevel    = 40
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = nil
SWEP.Secondary.Sound       = nil
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_DETECTIVE} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_ORBSUPPRESSION
SWEP.UseHands              = false
SWEP.ViewModel             = Model("models/props_phx/ball.mdl")
SWEP.WorldModel            = Model("models/props_phx/ball.mdl")

local JM_Shoot_Range                = 10000

function SWEP:HitEffectsInit(ent)
   if not IsValid(ent) then return end
   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   util.Effect("cball_explode", effect, true, true)
end

function SWEP:PrimaryAttack()

   -- Weapon Animation, Sound and Cycle data
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
   self:TakePrimaryAmmo( 1 )
   -- #########

   -- Fire Shot and apply on hit effects (Now with lag compensation to prevent whiffing)

   -- Give a Hit Marker to This Player
   local hitMarkerOwner = self:GetOwner()
   JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)
   
   local owner = self:GetOwner()
   if not IsValid(owner) then return end

   if isfunction(owner.LagCompensation) then -- for some reason not always true
      owner:LagCompensation(true)
   end
   
   local tr = util.TraceLine({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * JM_Shoot_Range, filter = owner})
   if (tr.HitSky == false)then
      if SERVER then 
         local ent = ents.Create("ent_jm_equip_Orb_Suppression")
			ent:SetPos(tr.HitPos + tr.HitNormal)
			local ang = tr.HitNormal:Angle()
			ang:RotateAroundAxis(ang:Right(), -90)
			ent:SetAngles(ang)
			ent:Spawn()
			ent.Owner = self:GetOwner()

         -- Another one but flipped
         local ent = ents.Create("ent_jm_equip_Orb_Suppression")
			ent:SetPos(tr.HitPos + tr.HitNormal)
			local ang = tr.HitNormal:Angle()
			ang:RotateAroundAxis(ang:Right(), 90)
			ent:SetAngles(ang)
			ent:Spawn()
			ent.Owner = self:GetOwner()
      end
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

function SWEP:SecondaryAttack()
   return
end


-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Create an Orb", nil, true)
 
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
-- Hide World Model when Equipped
function SWEP:DrawWorldModel()
   if IsValid(self:GetOwner()) then return end
   self:DrawModel()
end
function SWEP:DrawWorldModelTranslucent()
   if IsValid(self:GetOwner()) then return end
   self:DrawModel()
end
-- Delete on Drop
function SWEP:OnDrop() 
   self:Remove()
end

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################
