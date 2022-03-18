AddCSLuaFile()

if CLIENT then
	SWEP.Slot      = 7
 
	SWEP.ViewModelFlip		= false
 end

SWEP.PrintName				= "Chameleon"
SWEP.Author			    	= "Josh Mate"
SWEP.Instructions			= "Go invisible"
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true
SWEP.Primary.Delay 			= 0.5
SWEP.Primary.ClipSize		= 45
SWEP.Primary.DefaultClip	= 45
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		    = "none"
SWEP.Weight					= 5
SWEP.Slot			    	= 7
SWEP.ViewModel              = "models/Items/combine_rifle_ammo01.mdl"
SWEP.WorldModel             = "models/Items/combine_rifle_ammo01.mdl"
SWEP.HoldType 				= "normal" 
SWEP.UseHands               = false
SWEP.AllowDrop 				= true

-- TTT Customisation
SWEP.Base 					= "weapon_jm_base_gun"
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
		+ Your name is hidden while invisible
		+ Your footsteps are silent while invisible
		- Can only be invisible for a finite amount of time
		- Entering invisibility is noisy
	]]
}

	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 15 - ang:Right() *-11 - ang:Up() * 13, ang
	end

end


SWEP.Chameleon_LastLeftClick		= CurTime()
SWEP.Chameleon_DefaultPlayerColour 	= nil
SWEP.Chameleon_NewColour			= nil

function SWEP:Invisibility_Remove(player) 
	if not player:IsValid() then return end
	STATUS:RemoveStatus(player,"jm_chameleon")
	player:SetNWBool(JM_Global_Buff_Chameleon_NWBool, false)
	if SERVER then
		player:SetRenderMode( RENDERMODE_NORMAL )
		if not self.Chameleon_DefaultPlayerColour then 
			player:SetColor(self.Chameleon_DefaultPlayerColour)
		end
		
		
	end
end

function SWEP:Invisibility_Give(player) 
	if not player:IsValid() then return end
	STATUS:AddStatus(player,"jm_chameleon")
	player:SetNWBool(JM_Global_Buff_Chameleon_NWBool, true)
	if SERVER then
		JM_Function_PlaySound("chameleon_activate.wav")
		self.Chameleon_DefaultPlayerColour = player:GetColor()
		player:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self.Chameleon_NewColour = self.Chameleon_DefaultPlayerColour
		self.Chameleon_NewColour.a = 0
		player:SetColor(self.Chameleon_NewColour)
	end
end

function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   	if not self:CanPrimaryAttack() then return end

	self.Chameleon_LastLeftClick = CurTime()
	if (not self:GetOwner():GetNWBool(JM_Global_Buff_Chameleon_NWBool)) then
		self:Invisibility_Give(self:GetOwner()) 
	end

	self:TakePrimaryAmmo( 1 )

	 -- Remove Weapon When out of Ammo
	 if SERVER then
		if self:Clip1() <= 0 then
			self:Invisibility_Remove(self:GetOwner()) 
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
		self:Invisibility_Remove(self:GetOwner()) 
	end
	return self.BaseClass.Holster(self)
end

-- Remove Invisibility on dropping weapons (This prevent tase from giving INF invisibiltiy)
function SWEP:PreDrop()
	if(self:GetOwner():IsValid() and self:GetOwner():GetNWBool(JM_Global_Buff_Chameleon_NWBool)) then
		self:Invisibility_Remove(self:GetOwner()) 
	end
	return self.BaseClass.PreDrop(self)
 end

-- Stop random Cur Time when going invisible
function SWEP:Deploy()
	if(self:GetOwner():IsValid() and self:GetOwner():GetNWBool(JM_Global_Buff_Chameleon_NWBool)) then
		self:Invisibility_Remove(self:GetOwner()) 
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
			self:Invisibility_Remove(player) 
		end

	end

end

-- Quiet Footsteps
hook.Add("PlayerFootstep", "ChameleonSilentFootsteps", function(ply)
	if IsValid(ply) and ply:GetNWBool(JM_Global_Buff_Chameleon_NWBool, false) then
		return true
	end
end)



-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Hold to go invisible", nil, true)
 
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
	if(self:GetOwner():IsValid() and self:GetOwner():GetNWBool(JM_Global_Buff_Chameleon_NWBool)) then
		self:Invisibility_Remove(self:GetOwner()) 
	end
   self:Remove()
end

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################



