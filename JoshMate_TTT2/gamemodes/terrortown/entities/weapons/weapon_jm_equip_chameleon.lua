AddCSLuaFile()

if CLIENT then
	SWEP.Slot      = 7
 
	SWEP.ViewModelFlip		= false
	SWEP.ViewModelFOV		= 10
 end

SWEP.PrintName				= "Chameleon"
SWEP.Author			    	= "Josh Mate"
SWEP.Instructions			= "Hold out to go invisible"
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true
SWEP.Primary.Delay 			= 1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
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
	
		+ Invisibility while standing still 

		- You must be holding this weapon
		- Takes 3 seconds to activate
		- Any action will cancel it
		- You can still look around
	]]
}
end

local Chameleon_Tick				= 1
local Chameleon_Delay				= 3

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
	if SERVER then
		local player = self:GetOwner()

		if not IsValid(player) then return end
		if not player:IsTerror() then return end
		if not player:Alive() then return end

		if not player:GetVelocity():IsZero() then
			player:SetNWFloat("lastTimePlayerDidInput", CurTime())
			player:SetNWBool("isChameleoned", false)
			player:SetNWFloat("lastTimePlayerDidInput", CurTime())
			STATUS:RemoveStatus(player,"jm_chameleon")
			if SERVER then
				ULib.invisible(player,false,255)
			end
		end

		if player:GetNWFloat("lastTimePlayerDidInput") <= (CurTime() - Chameleon_Delay) then

			if player:GetNWInt("isChameleoned") == false then
				if SERVER then
					ULib.invisible(player,true,255)
				end
				STATUS:AddStatus(player,"jm_chameleon")
				player:EmitSound(Sound("chameleon_activate.wav"))
			end

			player:SetNWBool("isChameleoned", true)

		end
	end

end

-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
		self:AddTTT2HUDHelp("Stand still while holding this weapon to go invisible!", nil, true)
 
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


-- Chameleon
hook.Add( "PlayerButtonDown", "JM_Chameleon_Activation", function( ply, key )
    ply:SetNWBool("isChameleoned", false)
	ply:SetNWFloat("lastTimePlayerDidInput", CurTime())
	STATUS:RemoveStatus(ply,"jm_chameleon")
	if SERVER then
		ULib.invisible(ply,false,255)
	end
end )