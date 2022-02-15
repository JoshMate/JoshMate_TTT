AddCSLuaFile()

if CLIENT then
   SWEP.PrintName       = "Frag Grenade"
   SWEP.Slot            = 3

   SWEP.Icon            = "vgui/ttt/joshmate/icon_jm_gun_nade"
   SWEP.IconLetter      = "P"

   function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 17 - ang:Right() * -8 - ang:Up() * 8, ang
	end
end

SWEP.Base               = "weapon_jm_base_grenade"
SWEP.Kind               = WEAPON_NADE
SWEP.WeaponID           = AMMO_NADE_FRAG

SWEP.ViewModel          = "models/weapons/w_eq_fraggrenade.mdl"
SWEP.WorldModel         = "models/weapons/w_eq_fraggrenade.mdl"
SWEP.UseHands 				= false


SWEP.AutoSpawnable      = true
SWEP.Spawnable          = true

SWEP.CanBuy             = {}
SWEP.LimitedStock       = true

SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1

function SWEP:GetGrenadeName()
   return "ent_jm_grenade_frag_proj"
end