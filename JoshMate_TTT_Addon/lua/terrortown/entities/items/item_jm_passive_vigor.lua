if SERVER then
	AddCSLuaFile()
end

ITEM.EquipMenuData = {
	type = "item_passive",
	name = "Vigor",
	desc = [[Passively grants:
	
		+ 25 Max Health 
		+ Grants 2 HP/s regeneration
	]]
}


ITEM.CanBuy = {}
ITEM.hud = Material("vgui/ttt/joshmate/hud_health.png")
ITEM.material = "vgui/ttt/joshmate/icon_jm_vigor"



if SERVER then

	AddCSLuaFile()

	function ITEM:Equip(buyer)

		buyer:SetMaxHealth(buyer:GetMaxHealth() + 25)
		-- Set Status and print Message
		JM_GiveBuffToThisPlayer("jm_buff_vigor",buyer,buyer)
		-- End Of

	end

	function ITEM:Reset(buyer)
		buyer:SetMaxHealth(buyer:GetMaxHealth() - 25)
	end

end