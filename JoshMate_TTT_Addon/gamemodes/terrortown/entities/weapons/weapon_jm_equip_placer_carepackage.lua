AddCSLuaFile()

SWEP.PrintName				= "Care Package Placer"
SWEP.Author			    	= "Seb Mate"
SWEP.Instructions			= "Places a Carepackage"
SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = [[A Utility Item

Place 1 Detective Carepackage

Only non detective players can take them
]]
};

if CLIENT then
	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_carepackage.png"
	
	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 35 - ang:Right() * -25 - ang:Up() * 30, ang
	end
end


SWEP.Primary.Delay 			= 1
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"
SWEP.Weight					= 5
SWEP.Slot			    	= 7
SWEP.ViewModel 				= "models/Items/item_item_crate.mdl"
SWEP.WorldModel				= "models/Items/item_item_crate.mdl"
SWEP.HoldType              = "normal"
SWEP.HoldReady             = "normal"
SWEP.HoldNormal            = "normal"
SWEP.UseHands 				= false
SWEP.AllowDrop 				= true


SWEP.Base 					= "weapon_jm_base_gun"
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_DETECTIVE}
SWEP.LimitedStock          = true
SWEP.WeaponID              = AMMO_CAREPACKAGE


SWEP.JM_Trap_PlaceRange					= 255
SWEP.JM_Trap_Entity_Class				= "ent_jm_carepackage_detective"
SWEP.JM_Trap_Entity_Colour				= Color( 0, 50, 255, 255)

function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() then 
		JM_Function_PrintChat(self.Owner, "Equipment", " Your next carepackge isn't ready yet... (20s delay)" )
		return 
	end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.JM_Trap_PlaceRange, filter = self.Owner})
	if (tr.HitWorld or (tr.Entity:IsValid() and (tr.Entity:GetClass() == "func_breakable")))then
		local dot = vector_up:Dot(tr.HitNormal)
		if dot > 0.55 and dot <= 1 then
			if SERVER then

				self:GetOwner():EmitSound("shoot_barrel.mp3")


				local ent = ents.Create(self.JM_Trap_Entity_Class)
				ent:SetPos(tr.HitPos + tr.HitNormal)
				local ang = tr.HitNormal:Angle()
				ang:RotateAroundAxis(ang:Right(), -90)
				ent:SetAngles(ang)
				ent:Spawn()

				ent:SetRenderMode( RENDERMODE_TRANSCOLOR )
				ent:SetColor(self.JM_Trap_Entity_Colour)

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
	   self:AddTTT2HUDHelp("Place in front of you", nil, true)
 
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
