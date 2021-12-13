if SERVER then
	AddCSLuaFile()
end

ITEM.EquipMenuData = {
	type = "item_passive",
	name = "Zombie Mode",
	desc = [[Passively grants:
	
		+ You gain +50 Max HP
		+ You gain +10% Movement Speed
		+ You gain passive HP Regeneration
		- You will be shot on sight
	]]
}


ITEM.CanBuy = {ROLE_TRAITOR}
ITEM.hud = Material("vgui/ttt/joshmate/hud_zombiemode.png")
ITEM.material = "vgui/ttt/joshmate/icon_jm_zombiemode.png"




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