if SERVER then
	AddCSLuaFile()
end

ITEM.EquipMenuData = {
	type = "item_passive",
	name = "Demon Form",
	desc = [[Passively grants:
	
		+ Gain a large amount of HP and Speed
		+ You deal constant AOE fire damage to nearby players
		- Everyone will attack you on sight
		- You are forced into using the Demon Blade
		- You will slowly burn out and die
	]]
}


ITEM.CanBuy = {ROLE_TRAITOR}
ITEM.hud = Material("vgui/ttt/joshmate/hud_demonform.png")
ITEM.material = "vgui/ttt/joshmate/icon_jm_demonform.png"




if SERVER then

	AddCSLuaFile()

	function ITEM:Equip(buyer)

		-- Set Status and print Message
		JM_GiveBuffToThisPlayer("jm_buff_demonform",buyer,buyer)
		-- End Of


	end

	

	function ITEM:Reset(buyer)
	end

end