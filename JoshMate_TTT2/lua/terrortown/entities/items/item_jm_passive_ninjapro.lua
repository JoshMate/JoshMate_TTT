if SERVER then
	AddCSLuaFile()
end

ITEM.EquipMenuData = {
	type = "item_passive",
	name = "Ninja Pro",
	desc = [[Passively grants:

		The Ability to Diguise your name

		Whiles Disguised:
		+ 20% movement speed
		+ 50% jump height
		+ Silent footsteps
		+ Immunity to fall & drown damage

]]
}


ITEM.CanBuy = {}
ITEM.hud = Material("vgui/ttt/joshmate/hud_ninjapro.png")
ITEM.material = "vgui/ttt/joshmate/icon_jm_ninja"
ITEM.oldId = EQUIP_DISGUISE or 4

hook.Add("EntityTakeDamage", "NinjaProDamageFall", function(target, dmginfo)
	if not IsValid(target) or not target:IsPlayer() or not dmginfo:IsFallDamage() then return end
	if not target:GetNWBool("disguised") then return end	
	if target:Alive() and target:IsTerror() and target:HasEquipmentItem("item_jm_passive_ninjapro") then
		dmginfo:ScaleDamage(0)
	end
end)

hook.Add("EntityTakeDamage", "NinjaProDamageDrown", function(target, dmginfo)
	if not IsValid(target) or not target:IsPlayer() or not dmginfo:IsDamageType(DMG_DROWN) then return end
	if not target:GetNWBool("disguised") then return end	
	if target:Alive() and target:IsTerror() and target:HasEquipmentItem("item_jm_passive_ninjapro") then
		dmginfo:ScaleDamage(0)
	end
end)


hook.Add("TTTPlayerSpeedModifier", "NinjaProMoveSpeed", function(ply, _, _, speedMultiplierModifier)
	if not IsValid(ply)then return end
	if SERVER then
		ply:SetJumpPower(180)
		ply:SetCrouchedWalkSpeed(0.3)
	end
	if not ply:HasEquipmentItem("item_jm_passive_ninjapro") then return end
	if not ply:GetNWBool("disguised") then return end	

	speedMultiplierModifier[1] = speedMultiplierModifier[1] * 1.2

	if SERVER then
		ply:SetJumpPower(300)
		ply:SetCrouchedWalkSpeed(0.60)
	end
end)

hook.Add("PlayerFootstep", "NinjaProSilentFootsteps", function(ply)
	if not ply:GetNWBool("disguised") then return end	
	if IsValid(ply) and ply:HasEquipmentItem("item_jm_passive_ninjapro") then
		return true
	end
end)

--disguiser code


DISGUISE = CLIENT and {}
if CLIENT then
	local trans

	---
	-- Creates the Disguiser menu on the parent panel
	-- @param Panel parent parent panel
	-- @return Panel created disguiser menu panel
	-- @realm client
	function DISGUISE.CreateMenu(parent)
		trans = trans or LANG.GetTranslation

		local dform = vgui.Create("DForm", parent)
		dform:SetName(trans("disg_menutitle"))
		dform:StretchToParent(0, 0, 0, 0)
		dform:SetAutoSize(false)

		local owned = LocalPlayer():HasEquipmentItem("item_jm_passive_ninjapro")

		if not owned then
			dform:Help(trans("disg_not_owned"))

			return dform
		end

		local dcheck = vgui.Create("DCheckBoxLabel", dform)
		dcheck:SetText(trans("disg_enable"))
		dcheck:SetIndent(5)
		dcheck:SetValue(LocalPlayer():GetNWBool("disguised", false))

		dcheck.OnChange = function(s, val)
			RunConsoleCommand("ttt_set_disguise", val and "1" or "0")
		end

		dform:AddItem(dcheck)
		dform:Help(trans("disg_help1"))
		dform:Help(trans("disg_help2"))
		dform:SetVisible(true)

		return dform
	end

	hook.Add("TTTEquipmentTabs", "TTTItemDisguiser", function(dsheet)
		trans = trans or LANG.GetTranslation

		if not LocalPlayer():HasEquipmentItem("item_jm_passive_ninjapro") then return end

		local ddisguise = DISGUISE.CreateMenu(dsheet)

		dsheet:AddSheet(trans("disg_name"), ddisguise, "icon16/user.png", false, false, trans("equip_tooltip_disguise"))
	end)

	hook.Add("Initialize", "TTTItemDisguiserInitStatus", function()
		STATUS:RegisterStatus("item_disguiser_status", {
			hud = Material("vgui/ttt/joshmate/hud_disguiser.png"),
			type = "good"
		})
	end)
end

if SERVER then
	local function SetDisguise(ply, cmd, args)
		if not IsValid(ply) or not ply:IsActive() and ply:HasTeam(TEAM_TRAITOR) then return end

		if not ply:HasEquipmentItem("item_jm_passive_ninjapro") then return end

		local state = #args == 1 and tobool(args[1])

		if hook.Run("TTTToggleDisguiser", ply, state) then return end

		ply:SetNWBool("disguised", state)		

		LANG.Msg(ply, state and "disg_turned_on" or "disg_turned_off", nil, MSG_MSTACK_ROLE)
	end
	concommand.Add("ttt_set_disguise", SetDisguise)

	hook.Add("TTT2PlayerReady", "TTTItemDisguiserPlayerReady", function(ply)
		ply:SetNWVarProxy("disguised", function(ent, name, old, new)
			if not IsValid(ent) or not ent:IsPlayer() or name ~= "disguised" then return end

			if new then
				STATUS:AddStatus(ent, "item_disguiser_status")
			else
				STATUS:RemoveStatus(ent, "item_disguiser_status")
			end
		end)
	end)
end
