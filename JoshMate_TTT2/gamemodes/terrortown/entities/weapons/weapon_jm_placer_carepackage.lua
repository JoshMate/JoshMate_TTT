AddCSLuaFile()

SWEP.PrintName				= "Carepackage Swep"
SWEP.Author			    	= "Seb Mate"
SWEP.Instructions			= "Places 2 Carepackages"
SWEP.Primary.Delay 			= 0.5
SWEP.Primary.ClipSize		= 2
SWEP.Primary.DefaultClip	= 2
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"
SWEP.Weight					= 5
SWEP.Slot			    	= 7
SWEP.ViewModel 				= "models/props_junk/wood_crate001a.mdl"
SWEP.WorldModel				= "models/hunter/blocks/cube025x025x025.mdl"
SWEP.HoldType              = "grenade"
SWEP.HoldReady             = "grenade"
SWEP.HoldNormal            = "grenade"
SWEP.UseHands 				= false
SWEP.AllowDrop 				= true

SWEP.Base 					= "weapon_jm_base_gun"
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_DETECTIVE}
SWEP.LimitedStock          = true
SWEP.WeaponID              = AMMO_CARE

if CLIENT then
	SWEP.PrintName				= "Carepackage Swep"
	SWEP.Slot               = 7
 
 
	SWEP.EquipMenuData = 
	{
		type = "item_weapon",
		name = "Carepackage",
		desc = [[Place down 2 carepackages for yourself and other innocents.]]
	}
	
	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_gun_special.png"
		
	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 35 - ang:Right() * -25 - ang:Up() * 30, ang
	end

end

local JM_Trap_PlaceRange				= 192
at
function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * JM_Trap_PlaceRange, filter = self.Owner})
	if (tr.HitWorld or (tr.Entity:IsValid() and (tr.Entity:GetClass() == "func_breakable")))then
		local dot = vector_up:Dot(tr.HitNormal)
		if dot > 0.55 and dot <= 1 then
			if SERVER then
				local ent = ents.Create("ent_jm_carepackage")
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


-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Place in front of you", nil, true)
 
	   return self.BaseClass.Initialize(self)
	end
end
if SERVER then
   function SWEP:OnRemove()
      if self:GetOwner():IsValid() and self:GetOwner():IsTerror() then
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
      end
   end
end
--
