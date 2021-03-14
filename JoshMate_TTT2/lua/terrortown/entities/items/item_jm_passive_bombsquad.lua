if SERVER then
	AddCSLuaFile()
end

ITEM.EquipMenuData = {
	type = "item_passive",
	name = "Bomb Squad",
	desc = [[Passively grants:
	
		+ C4 will be much easier to detect
		+ C4 wires will all be safe when defusing
		+ 50% Immunity to Fire Damage
		+ 50% Immunity to Explosive Damage
]]
}
ITEM.CanBuy = {ROLE_DETECTIVE}

ITEM.hud = Material("vgui/ttt/joshmate/hud_bombsquad.png")
ITEM.material = "vgui/ttt/joshmate/icon_jm_bombsquad.png"

if SERVER then
	

	hook.Add("EntityTakeDamage", "BombSquadDamageFire", function(target, dmginfo)
		if not IsValid(target) or not target:IsPlayer() or not dmginfo:IsDamageType(DMG_BURN) then return end

		if target:Alive() and target:IsTerror() and target:HasEquipmentItem("item_jm_passive_bombsquad") then
			dmginfo:ScaleDamage(0.50)
		end
	end)

	hook.Add("EntityTakeDamage", "BombSquadDamageBlast", function(target, dmginfo)
		if not IsValid(target) or not target:IsPlayer() or not dmginfo:IsDamageType(DMG_BLAST) then return end

		if target:Alive() and target:IsTerror() and target:HasEquipmentItem("item_jm_passive_bombsquad") then
			dmginfo:ScaleDamage(0.50)
		end
	end)


end
