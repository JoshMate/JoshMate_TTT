AddCSLuaFile()

if CLIENT then
	SWEP.Slot      = 7
 
	SWEP.ViewModelFlip		= false
	SWEP.ViewModelFOV		= 10
 end

SWEP.PrintName				= "Chameleon"
SWEP.Author			    	= "Josh Mate"
SWEP.Instructions			= "Go invisible"
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true
SWEP.Primary.Delay 			= 0.5
SWEP.Primary.ClipSize		= 60
SWEP.Primary.DefaultClip	= 60
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		    = "none"
SWEP.Weight					= 5
SWEP.Slot			    	= 7
SWEP.ViewModel              = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel             = "models/weapons/w_crowbar.mdl"
SWEP.HoldType 				= "normal" 
SWEP.UseHands 				= true
SWEP.AllowDrop 				= true

-- TTT Customisation
SWEP.Base 					= "weapon_tttbase"
SWEP.Kind                  	= WEAPON_EQUIP
SWEP.WeaponID              	= AMMO_CHAMELEON
SWEP.CanBuy                	= {ROLE_TRAITOR}
SWEP.AutoSpawnable			= false
SWEP.LimitedStock 			= true

if CLIENT then
	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_chameleon.png"
 
	SWEP.EquipMenuData = {
	   type = "item_weapon",
	   name = "Chameleon",
	   desc = [[A Utility Item:
	
		+ Invisibility while holding left click

		- Greatly slows the player
		- Can only be invisible for a finite amount of time
		- Entering / leaving invisibility is noisy
		- Foot steps and your player name are still there
	]]
}
end


SWEP.Chameleon_LastLeftClick		= CurTime()

function Invisibility_Remove(player) 
	STATUS:RemoveStatus(player,"jm_chameleon")
	player:SetNWBool(JM_Global_Buff_Chameleon_NWBool, false)
	if SERVER then
		player:EmitSound(Sound("chameleon_activate.wav"))
		ULib.invisible(player,false,255)
	end
end

function Invisibility_Give(player) 
	STATUS:AddStatus(player,"jm_chameleon")
	player:SetNWBool(JM_Global_Buff_Chameleon_NWBool, true)
	if SERVER then
		player:EmitSound(Sound("chameleon_activate.wav")) 
		ULib.invisible(player,true,255)
	end
end

function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   	if not self:CanPrimaryAttack() then return end

	self.Chameleon_LastLeftClick = CurTime()
	if (not self:GetOwner():GetNWBool(JM_Global_Buff_Chameleon_NWBool)) then
		Invisibility_Give(self:GetOwner()) 
	end

	self:TakePrimaryAmmo( 1 )

	 -- Remove Weapon When out of Ammo
	 if SERVER then
		if self:Clip1() <= 0 then
			Invisibility_Remove(self:GetOwner()) 
		   	self:Remove()
		end
	 end
	 -- #########


end

function SWEP:SecondaryAttack()
end

-- Remove Invisibility on changing weapons
function SWEP:Holster( wep )
	if(self:GetOwner():IsValid() and self:GetOwner():GetNWBool(JM_Global_Buff_Chameleon_NWBool)) then
		Invisibility_Remove(self:GetOwner()) 
	end
	return self.BaseClass.Holster(self)
end

-- Remove Invisibility on dropping weapons (This prevent tase from giving INF invisibiltiy)
function SWEP:PreDrop()
	if(self:GetOwner():IsValid() and self:GetOwner():GetNWBool(JM_Global_Buff_Chameleon_NWBool)) then
		Invisibility_Remove(self:GetOwner()) 
	end
	return self.BaseClass.PreDrop(self)
 end

-- Stop random Cur Time when going invisible
function SWEP:Deploy()
	if(self:GetOwner():IsValid() and self:GetOwner():GetNWBool(JM_Global_Buff_Chameleon_NWBool)) then
		Invisibility_Remove(self:GetOwner()) 
	end
	return self.BaseClass.Deploy(self)
end

-- Handle Invisibility checking
function SWEP:Think()
	if SERVER then
		local player = self:GetOwner()

		if not IsValid(player) then return end
		if not player:IsTerror() then return end
		if not player:Alive() then return end

		if ((self.Chameleon_LastLeftClick+1) <= CurTime() and player:GetNWBool(JM_Global_Buff_Chameleon_NWBool)) then
			Invisibility_Remove(player) 
		end

	end

end



-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
		self:AddTTT2HUDHelp("Hold to go Invisible", nil, true)
 
	   return self.BaseClass.Initialize(self)
	end
end
if SERVER then
   function SWEP:OnRemove()
		if(self:GetOwner():IsValid() and self:GetOwner():GetNWBool(JM_Global_Buff_Chameleon_NWBool)) then
			Invisibility_Remove(self:GetOwner()) 
		end
		if self.Owner:IsValid() and self.Owner:IsTerror() then
			self:GetOwner():SelectWeapon("weapon_ttt_unarmed")
		end
   end
end
-- 


-- Josh Mate No World Model

function SWEP:OnDrop()
	if(self:GetOwner():IsValid() and self:GetOwner():GetNWBool(JM_Global_Buff_Chameleon_NWBool)) then
		Invisibility_Remove(self:GetOwner()) 
	end
	self:Remove()
 end
  
 function SWEP:DrawWorldModel()
	return
 end
 
 function SWEP:DrawWorldModelTranslucent()
	return
 end
 
-- END of Josh Mate World Model 


