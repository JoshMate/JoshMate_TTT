if SERVER then
	AddCSLuaFile()
end

ITEM.EquipMenuData = {
	type = "item_passive",
	name = "Ninja Pro",
	desc = [[Passively grants:
	
		+ Silent Footsteps
		+ Immunity to Fall & Drown Damage
		+ 20% Movement Speed 
		+ 50% Jump Height
		+ 50% Faster Crouch Walking
]]
}


ITEM.CanBuy = {ROLE_TRAITOR}
ITEM.hud = Material("vgui/ttt/joshmate/hud_ninjapro.png")
ITEM.material = "vgui/ttt/joshmate/icon_jm_ninja"

hook.Add("EntityTakeDamage", "NinjaProDamageFall", function(target, dmginfo)
	if not IsValid(target) or not target:IsPlayer() or not dmginfo:IsFallDamage() then return end

	if target:Alive() and target:IsTerror() and target:HasEquipmentItem("item_jm_passive_ninjapro") then
		dmginfo:ScaleDamage(0)
	end
end)

hook.Add("EntityTakeDamage", "NinjaProDamageDrown", function(target, dmginfo)
	if not IsValid(target) or not target:IsPlayer() or not dmginfo:IsDamageType(DMG_DROWN) then return end

	if target:Alive() and target:IsTerror() and target:HasEquipmentItem("item_jm_passive_ninjapro") then
		dmginfo:ScaleDamage(0)
	end
end)


hook.Add("TTTPlayerSpeedModifier", "NinjaProMoveSpeed", function(ply, _, _, speedMultiplierModifier)
	if not IsValid(ply)then return end
	if not ply:HasEquipmentItem("item_jm_passive_ninjapro") then return end

	speedMultiplierModifier[1] = speedMultiplierModifier[1] * 1.2
end)

hook.Add("PlayerFootstep", "NinjaProSilentFootsteps", function(ply)
	if IsValid(ply) and ply:HasEquipmentItem("item_jm_passive_ninjapro") then
		return true
	end
end)

if SERVER then

	function ITEM:Equip(buyer)
		buyer:SetJumpPower(250)
		buyer:SetCrouchedWalkSpeed(0.50)
	end

	function ITEM:Reset(buyer)
		buyer:SetJumpPower(160)
		buyer:SetCrouchedWalkSpeed(0.3)
	end

end


