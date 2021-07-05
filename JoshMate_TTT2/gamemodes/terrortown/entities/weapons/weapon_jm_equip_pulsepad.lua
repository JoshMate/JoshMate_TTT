AddCSLuaFile()

if CLIENT then
	SWEP.Slot      = 7
 
	SWEP.ViewModelFlip		= false

 end

SWEP.PrintName				= "Pulse Pad"
SWEP.Author			    	= "Josh Mate"
SWEP.Instructions			= "Leftclick to place a Pulse Pad"
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true
SWEP.Primary.Delay 			= 0.3
SWEP.Primary.ClipSize		= 5
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"
SWEP.Weight					= 5
SWEP.Slot			    	= 7
SWEP.ViewModel              = "models/props_junk/sawblade001a.mdl"
SWEP.WorldModel             = "models/props_junk/sawblade001a.mdl"
SWEP.HoldType 				= "normal" 
SWEP.UseHands              = false
SWEP.AllowDrop 				= true

-- TTT Customisation
SWEP.Base 					= "weapon_jm_base_gun"
SWEP.Kind                  	= WEAPON_EQUIP
SWEP.WeaponID              	= AMMO_BARRIER
SWEP.CanBuy                	= {ROLE_DETECTIVE}
SWEP.AutoSpawnable			= false
SWEP.LimitedStock 			= true

if CLIENT then
	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_pulsepad.png"
 
	SWEP.EquipMenuData = {
	   type = "item_weapon",
	   name = "Pulse Pad",
	   desc = [[Trap Weapon
	
Left click to place a hard to see pulse pad on the floor

Walking on the pad will track that player for the rest of the round

It has 5 uses
]]
	}

	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 25 - ang:Right() * -15 - ang:Up() * 15, ang
	end

end

local JM_Trap_PlaceRange				= 192

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:PlaceTrap()
	
end

function SWEP:SecondaryAttack()
end

function SWEP:PlaceTrap()
	if (CLIENT) then return end

	local tr = util.TraceLine({start = self:GetOwner():GetShootPos(), endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * JM_Trap_PlaceRange, filter = self:GetOwner()})
	if (tr.HitWorld or tr.Entity:IsValid() and (tr.Entity:GetClass() == "func_breakable"))then
		local dot = vector_up:Dot(tr.HitNormal)
		if dot > 0.55 and dot <= 1 then
			local ent = ents.Create("ent_jm_equip_pulsepad")
			ent:SetPos(tr.HitPos + tr.HitNormal)
			local ang = tr.HitNormal:Angle()
			ang:RotateAroundAxis(ang:Right(), -90)
			ent:SetAngles(ang)
			ent:Spawn()
			ent.Owner = self:GetOwner()
			ent:SetOwner(self:GetOwner())
			ent.fingerprints = self.fingerprints
			self:TakePrimaryAmmo(1)
			if SERVER then
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
	   self:AddTTT2HUDHelp("Place a Pulse Pad", nil, true)
 
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

-- Josh Mate No World Model

function SWEP:OnDrop()
	self:Remove()
 end
  
 function SWEP:DrawWorldModel()
	return
 end
 
 function SWEP:DrawWorldModelTranslucent()
	return
 end
 
 -- END of Josh Mate World Model 

