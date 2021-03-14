AddCSLuaFile()

if CLIENT then
   SWEP.PrintName          = "Inferno Bomb"
   SWEP.Slot               = 6

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_inferno"
   SWEP.IconLetter         = "n"

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A deadly grenade
	
Creates a large orange radius that damages all players
      
The fire damage will quickly kill anyone who stands in it
      
2 uses, explodes on impact and lasts for (10 Seconds)
]]
};
end

SWEP.Base               = "weapon_jm_base_grenade"

SWEP.Kind               = WEAPON_EQUIP
SWEP.WeaponID           = AMMO_INFERNO

SWEP.ViewModel          = "models/weapons/c_grenade.mdl"
SWEP.WorldModel         = "models/weapons/w_grenade.mdl"

SWEP.AutoSpawnable      = false
SWEP.Spawnable          = false

SWEP.CanBuy             = {ROLE_TRAITOR}
SWEP.LimitedStock       = true

SWEP.Primary.ClipSize      = 2
SWEP.Primary.DefaultClip   = 2

function SWEP:GetGrenadeName()
   return "ent_jm_infernogrenade_proj"
end