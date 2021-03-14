-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end

-- Register Effects
if CLIENT then
	hook.Add("Initialize", "jm_register_buffs", function() 

		STATUS:RegisterStatus("jm_taser", {
			hud = Material("vgui/ttt/joshmate/hud_taser.png"),
			type = "bad"
		})

        STATUS:RegisterStatus("jm_poisondart", {
			hud = Material("vgui/ttt/joshmate/hud_poisondart.png"),
			type = "bad"
		})

        STATUS:RegisterStatus("ttt2_beartrap", {
			hud = Material("vgui/ttt/hud_icon_beartrap.png"),
			type = "bad"
		})

        STATUS:RegisterStatus("jm_stungrenade", {
			hud = Material("vgui/ttt/joshmate/hud_flashbang.png"),
			type = "bad"
		})

        STATUS:RegisterStatus("jm_treeoflife", {
			hud = Material("vgui/ttt/joshmate/hud_tree.png"),
			type = "good"
		})

        STATUS:RegisterStatus("jm_chameleon", {
			hud = Material("vgui/ttt/joshmate/hud_chameleon.png"),
			type = "good"
		})
	end)
end

-- Remove all Buffs on round start
if SERVER then
	hook.Add("TTTPrepareRound", "JMCleanUpTimers_Taser", function()
		for _, v in ipairs(player.GetAll()) do
			if IsValid(v) then
				v:SetNWBool("isTased", false)
                v:SetNWBool("isPoisonDarted", false)
                v:SetNWBool("isBearTrapped", false)
                v:SetNWBool("isStunGrenaded", false)
                v:SetNWBool("isChameleoned", false)
                v:SetNWFloat("lastTimePlayerDidInput", CurTime())
                if SERVER then
                    ULib.invisible(v,false,255)
                end
			end
		end
	end)
end


-- Set up Screen Effects
-- then
-- Draw Screen Effects
if CLIENT then

    local effectTable_Taser = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0.25,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 1,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    local effectTable_PoisonDart = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0.25,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 1,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    local effectTable_BearTrap = {
        ["$pp_colour_addr"] = 0.25,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 1,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    local effectTable_Chameleon = {
        ["$pp_colour_addr"] = 0.25,
        ["$pp_colour_addg"] = 0.25,
        ["$pp_colour_addb"] = 0.25,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 1,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    hook.Add("RenderScreenspaceEffects", "JM_ScreenEffects_Buffs", function()
        if not LocalPlayer():IsTerror() == true then return end
        if not LocalPlayer():Alive() == true  then return end

        -- Taser
        if (LocalPlayer():GetNWBool("isTased") == true) then
            DrawColorModify( effectTable_Taser )
            DrawMaterialOverlay( "effects/tvscreen_noise002a", -0.01 )
        end

        -- Bear Trap
        if (LocalPlayer():GetNWBool("isBearTrapped") == true) then
            DrawColorModify( effectTable_BearTrap )
        end

        -- Poison Dart
        if (LocalPlayer():GetNWBool("isPoisonDarted") == true) then
            DrawColorModify( effectTable_PoisonDart )
        end

        -- Stun Grenade
        if (LocalPlayer():GetNWBool("isStunGrenaded") == true) then
            DrawMotionBlur( 0.05, 1, 0.01 )
        end

        -- Chameleon Invisibility
        if (LocalPlayer():GetNWBool("isChameleoned") == true) then
            DrawColorModify( effectTable_Chameleon )
        end

    end )
end

-- Stat changes via hooks
hook.Add("TTTPlayerSpeedModifier", "JM_GrenadeSlowEffect", function(ply, _, _, speedMultiplierModifier)
	if not IsValid(ply)then return end
   speedMultiplierModifier[1] = speedMultiplierModifier[1] * 1.0
   if ply:GetNWBool("isStunGrenaded") == true then 
	speedMultiplierModifier[1] = speedMultiplierModifier[1] * 0.3
   end   
end)


