AddCSLuaFile()

if CLIENT then
   SWEP.PrintName       = "Energy Drink"
   SWEP.Slot            = 6

   SWEP.Icon            = "vgui/ttt/joshmate/icon_jm_can.png"
   SWEP.IconLetter      = "P"
   
   function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 30 - ang:Right() * -15 - ang:Up() * 10, ang
	end

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Healing Item
	
Grants the drinker Health Regen, movement speed and greatly reduced fall damage

Has 1 use and lasts for 3 seconds

Left click to Drink | Right Click to force feed to someone
]]
};

end

SWEP.Base               = "weapon_jm_base_grenade"
SWEP.Kind               = WEAPON_EQUIP
SWEP.WeaponID           = AMMO_NADE_Can

SWEP.ViewModel          = "models/props_junk/PopCan01a.mdl"
SWEP.WorldModel         = "models/props_junk/PopCan01a.mdl"
SWEP.UseHands 				= false

SWEP.AutoSpawnable      = true
SWEP.Spawnable          = true


SWEP.CanBuy             = {ROLE_DETECTIVE}
SWEP.LimitedStock       = true

SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1

function SWEP:HitEffectsInit(ent)
   if not IsValid(ent) then return end

   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   util.Effect("cball_explode", effect, true, true)
end


function SWEP:HealingGreande_HealTarget(target)

   if (SERVER) then

      target:EmitSound(Sound("effect_can_open.mp3"))

      if target:IsTerror() and target:Alive() then

         -- Give a Hit Marker to This Player
         local hitMarkerOwner = self:GetOwner()
         JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)

         -- Effects
         self:HitEffectsInit(target)
         -- End of Effects
         
         -- Set Status and print Message
         JM_GiveBuffToThisPlayer("jm_buff_energydrink",target,self:GetOwner())
         -- End Of

         JM_Function_PrintChat(target, "Equipment","You drunk an energy drink from: " .. tostring(self:GetOwner():Nick()))

      end

      self:TakePrimaryAmmo(1)
      if self:Clip1() <= 0 then
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
         self:Remove()
      end

   end

end


function SWEP:PrimaryAttack()
   if not self:CanPrimaryAttack() then return end
   self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
   self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

   
   -- Use The Grenade
   self:HealingGreande_HealTarget(self:GetOwner())


end

-- No Iron Sights
function SWEP:SecondaryAttack()

   -- Fire Shot and apply on hit effects (Now with lag compensation to prevent whiffing)
   local JM_Shoot_Range = 150

   local owner = self:GetOwner()
   if not IsValid(owner) then return end

   if isfunction(owner.LagCompensation) then -- for some reason not always true
      owner:LagCompensation(true)
   end
   
   local tr = util.TraceLine({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * JM_Shoot_Range, filter = owner})
   if (tr.Entity:IsValid() and tr.Entity:IsPlayer() and tr.Entity:IsTerror() and tr.Entity:Alive())then
      if SERVER then
         -- Use The Grenade
         self:HealingGreande_HealTarget(tr.Entity)
         JM_Function_Karma_Reward(self:GetOwner(), JM_KARMA_REWARD_ACTION_ENERGYDRINKHEAL, "Energy Drink Given")
      end
   end
   owner:LagCompensation(false)

   -- #########
   
end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("You drink it", "They drink it", true)
 
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

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################