if SERVER then
	AddCSLuaFile()
end

ITEM.EquipMenuData = {
	type = "item_passive",
	name = "Vigor",
	desc = [[Passively grants:
	
		+ 25 Max Health 
		+ Grants 1 HP/s regeneration
	]]
}


ITEM.CanBuy = {ROLE_DETECTIVE}
ITEM.hud = Material("vgui/ttt/joshmate/hud_health.png")
ITEM.material = "vgui/ttt/joshmate/icon_jm_vigor"

local Vigor_Regen_Delay				= 0.5
local Vigor_Regen_HealAmount		= 1



if SERVER then

	AddCSLuaFile()

	function ITEM:Equip(buyer)
		buyer:SetMaxHealth(buyer:GetMaxHealth() + 25)

		timerName = "timer_VigorHPRegen_" .. buyer:GetName()
   		timer.Create( timerName, Vigor_Regen_Delay, 0, function ()

			if not IsValid(buyer) then return end
			if not buyer:IsTerror() then return end
			if not buyer:HasEquipmentItem("item_jm_passive_vigor") then timer.Remove(timerName) return end
			if not buyer:Alive() then return end
			if buyer:Health() >= buyer:GetMaxHealth() then return end
			
			local newHP = buyer:Health() + Vigor_Regen_HealAmount
			if newHP > buyer:GetMaxHealth() then newHP = buyer:GetMaxHealth() end

			buyer:SetHealth(newHP)
		
		end )


	end

	function ITEM:Reset(buyer)
		buyer:SetMaxHealth(buyer:GetMaxHealth() - 25)
	end

end