if SERVER then
	AddCSLuaFile()
end

ITEM.EquipMenuData = {
	type = "item_passive",
	name = "Agility",
	desc = [[Passively grants:

		+ 20% movement speed
		+ 50% jump height
		+ 50% reduction to Fall Damage
]]
}


ITEM.CanBuy = {ROLE_DETECTIVE}
ITEM.hud = Material("vgui/ttt/joshmate/hud_agility.png")
ITEM.material = "vgui/ttt/joshmate/icon_jm_agility.png"

hook.Add("EntityTakeDamage", "AgilityDamageFall", function(target, dmginfo)
	if not IsValid(target) or not target:IsPlayer() or not dmginfo:IsFallDamage() then return end
	if target:Alive() and target:IsTerror() and target:HasEquipmentItem("item_jm_passive_agility") then
		dmginfo:ScaleDamage(0.5)
	end
end)

hook.Add("TTTPlayerSpeedModifier", "AgilityProMoveSpeed", function(ply, _, _, speedMultiplierModifier)
	if not IsValid(ply)then return end
	if not ply:HasEquipmentItem("item_jm_passive_agility") then return end

	speedMultiplierModifier[1] = speedMultiplierModifier[1] * 1.2

	if SERVER then
		ply:SetJumpPower(280)
	end
	
end)


