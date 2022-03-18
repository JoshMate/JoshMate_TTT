AddCSLuaFile()
if CLIENT then
   SWEP.Slot      = 7

	SWEP.ViewModelFlip		= false
	SWEP.ViewModelFOV		= 54
end

SWEP.Base = "weapon_jm_base_gun"

SWEP.HoldType              = "normal"
SWEP.PrintName = "Beartrap"
SWEP.ViewModel  = "models/stiffy360/c_beartrap.mdl"
SWEP.WorldModel  = "models/stiffy360/beartrap.mdl"
SWEP.UseHands	= true
SWEP.Kind = WEAPON_EQUIP2
SWEP.AutoSpawnable = false
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true
SWEP.DeploySpeed           = 4

SWEP.Primary.Delay 			= 0.3
SWEP.Primary.ClipSize		= 2
SWEP.Primary.DefaultClip	= 2

if CLIENT then
   SWEP.Icon = "vgui/ttt/joshmate/icon_jm_beartrap.png"

   SWEP.EquipMenuData = {
      type = "item_weapon",
	  name = "Beartrap",
	  desc = [[Place down a lethal bear trap!
	
	It will immobilize and kill anyone who is caught in it.

	Another player can release you if they are quick.

	You will be informed via chat about how your trap is doing.

	Your traps will show up to other Traitors
	]]
   }

	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 15, ang
	end
end


local JM_Trap_PlaceRange				= 192

function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * JM_Trap_PlaceRange, filter = self.Owner})
	if (tr.HitWorld or (tr.Entity:IsValid() and (tr.Entity:GetClass() == "func_breakable")))then
		local dot = vector_up:Dot(tr.HitNormal)
		if dot > 0.55 and dot <= 1 then
			if SERVER then
				local ent = ents.Create("ent_jm_equip_beartrap")
				ent:SetPos(tr.HitPos + tr.HitNormal)
				local ang = tr.HitNormal:Angle()
				ang:RotateAroundAxis(ang:Right(), -90)
				ent:SetAngles(ang)
				ent:Spawn()
				ent.Owner = self.Owner
				ent.fingerprints = self.fingerprints
				self:TakePrimaryAmmo(1)
				if self:Clip1() <= 0 then
					self:Remove()
				end
			end
		end
	end
end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Place a Beartrap", nil, true)
 
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