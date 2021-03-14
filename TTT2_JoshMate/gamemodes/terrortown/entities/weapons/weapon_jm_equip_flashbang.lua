AddCSLuaFile()

if (CLIENT) then

	SWEP.PrintName 			= "Stun Grenade"
	SWEP.Slot				= 6
	SWEP.IconLetter			= "g"
	SWEP.Icon 				= "vgui/ttt/joshmate/icon_jm_flashbang"

	SWEP.ViewModelFOV       = 68

	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = [[A Non-Lethal Grenade
		
Targets are slowed by 70%
	 
Targets drop their currently equipped weapon
	 
Targets also have their vision distorted

3 uses and lasts for (5 Seconds)
]]
};
end

SWEP.Base               = "weapon_jm_base_grenade"

SWEP.Kind               = WEAPON_EQUIP
SWEP.WeaponID           = AMMO_INFERNO

SWEP.ViewModel			= "models/weapons/csgonade/v_eq_flashbang.mdl"
SWEP.WorldModel			= "models/weapons/csgonade/w_eq_flashbang.mdl"

SWEP.AutoSpawnable      = false
SWEP.Spawnable          = false

SWEP.CanBuy = {ROLE_DETECTIVE}
SWEP.LimitedStock = true

SWEP.Primary.ClipSize      = 3
SWEP.Primary.DefaultClip   = 3

function SWEP:GetGrenadeName()
   return "ent_jm_flashbanggrenade_proj"
end
