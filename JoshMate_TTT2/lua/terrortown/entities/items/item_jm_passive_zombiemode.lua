if SERVER then
	AddCSLuaFile()
end

ITEM.EquipMenuData = {
	type = "item_passive",
	name = "Zombie Mode",
	desc = [[Passively grants:
	
		+ 25 max HP
		+ 20% movement speed
		+ 50% jump height
		+ 50% reduction to Fall Damage
		- You become a very loud zombie
	]]
}


ITEM.CanBuy = {}
ITEM.hud = Material("vgui/ttt/joshmate/hud_zombiemode.png")
ITEM.material = "vgui/ttt/joshmate/icon_jm_zombiemode.png"


hook.Add("EntityTakeDamage", "ZombieModeFallDamage", function(target, dmginfo)
	if not IsValid(target) or not target:IsPlayer() or not dmginfo:IsFallDamage() then return end
	if target:Alive() and target:IsTerror() and target:HasEquipmentItem("item_jm_passive_zombiemode") then
		dmginfo:ScaleDamage(0.50)
	end
end)

hook.Add("TTTPlayerSpeedModifier", "ZombieModeMoveSpeed", function(ply, _, _, speedMultiplierModifier)
	if not IsValid(ply)then return end
	if not ply:HasEquipmentItem("item_jm_passive_zombiemode") then return end

	speedMultiplierModifier[1] = speedMultiplierModifier[1] * 1.2

	if SERVER then
		ply:SetJumpPower(300)
	end
	
end)


if SERVER then

	AddCSLuaFile()

	function ITEM:Equip(buyer)

		-- Set Status and print Message
		JM_GiveBuffToThisPlayer("jm_buff_zombiemode",buyer,buyer)
		-- End Of


	end

	function ITEM:Reset(buyer)
	end

end