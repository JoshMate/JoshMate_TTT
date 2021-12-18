if SERVER then
	AddCSLuaFile()
end

ITEM.EquipMenuData = {
	type = "item_passive",
	name = "Zombie Mode",
	desc = [[Passively grants:
	
		+ You gain +100 max HP
		+ You heal 100 HP
		- You become a very loud zombie
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