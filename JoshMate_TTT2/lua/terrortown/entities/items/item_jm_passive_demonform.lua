if SERVER then
	AddCSLuaFile()
end

ITEM.EquipMenuData = {
	type = "item_passive",
	name = "Demon Form",
	desc = [[Passively grants:
	
		+ Gain Large amounts of HP and Speed
		+ You deal constant AOE fire damage to nearby players
		- Everyone will know what you have become
		- You will slowly burn out and die
		- You will be tormented by the burning pain
	]]
}


ITEM.CanBuy = {ROLE_TRAITOR}
ITEM.hud = Material("vgui/ttt/joshmate/hud_demonform.png")
ITEM.material = "vgui/ttt/joshmate/icon_jm_demonform.png"


hook.Add("TTTPlayerSpeedModifier", "DemonFormMoveSpeed", function(ply, _, _, speedMultiplierModifier)
	if not IsValid(ply)then return end
	if not ply:HasEquipmentItem("item_jm_passive_demonform") then return end
	speedMultiplierModifier[1] = speedMultiplierModifier[1] * 1.2
end)

if SERVER then

	AddCSLuaFile()

	function ITEM:Equip(buyer)

		-- Set Status and print Message
		JM_GiveBuffToThisPlayer("jm_buff_demonform",buyer,buyer)
		-- End Of


	end

	hook.Add("EntityTakeDamage", "DemonFormFireDamage", function(target, dmginfo)
		if not IsValid(target) or not target:IsPlayer() or not dmginfo:IsDamageType(DMG_BURN) then return end

		if target:Alive() and target:IsTerror() and target:HasEquipmentItem("item_jm_passive_demonform") then
			dmginfo:ScaleDamage(0)
		end
	end)

	function ITEM:Reset(buyer)
	end

end