if CLIENT then
   SWEP.Slot      = 7

	SWEP.ViewModelFlip		= false
	SWEP.ViewModelFOV		= 54
end

SWEP.Base = "weapon_tttbase"

SWEP.HoldType              = "normal"
SWEP.PrintName = "Beartrap"
SWEP.ViewModel  = "models/stiffy360/c_beartrap.mdl"
SWEP.WorldModel  = "models/stiffy360/beartrap.mdl"
SWEP.UseHands	= true
SWEP.Kind = WEAPON_EQUIP2
SWEP.AutoSpawnable = false
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = false
SWEP.DeploySpeed           = 4

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

if SERVER then
	AddCSLuaFile()


	function SWEP:PrimaryAttack()
		local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 100, filter = self.Owner})
		if (tr.HitWorld or (tr.Entity:GetClass() == "func_breakable"))then
			local dot = vector_up:Dot(tr.HitNormal)
			if dot > 0.55 and dot <= 1 then
				local ent = ents.Create("ttt_bear_trap")
				ent:SetPos(tr.HitPos + tr.HitNormal)
				local ang = tr.HitNormal:Angle()
				ang:RotateAroundAxis(ang:Right(), -90)
				ent:SetAngles(ang)
				ent:Spawn()
				ent.Owner = self.Owner
				ent.fingerprints = self.fingerprints
				self:Remove()
			end
		end
	end

	function SWEP:OnRemove()
		if self.Owner:IsValid() and self.Owner:IsTerror() then
			self.Owner:ConCommand("lastinv")
		end
	end


end

-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Place a Beartrap", nil, true)
 
	   return self.BaseClass.Initialize(self)
	end
end
if SERVER then
   function SWEP:OnRemove()
      if self.Owner:IsValid() and self.Owner:IsTerror() then
         self:GetOwner():SelectWeapon("weapon_ttt_unarmed")
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