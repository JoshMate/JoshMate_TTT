-- #############################################
-- Buff Base Class Info
-- #############################################
AddCSLuaFile()
ENT.Base                        = "jm_buff_base"

-- #############################################
-- Buff Basic Info
-- #############################################

local JM_PrintName              = JM_Global_Buff_Care_TrippingBalls_Name
local JM_BuffNWBool             = JM_Global_Buff_Care_TrippingBalls_NWBool
local JM_BuffDuration           = JM_Global_Buff_Care_TrippingBalls_Duration
local JM_BuffIconName           = JM_Global_Buff_Care_TrippingBalls_IconName
local JM_BuffIconPath           = JM_Global_Buff_Care_TrippingBalls_IconPath
local JM_BuffIconGoodBad        = JM_Global_Buff_Care_TrippingBalls_IconGoodBad

-- #############################################
-- Generated Values (important for instances)
-- #############################################

ENT.PrintName                   = JM_PrintName
ENT.BuffNWBool                  = JM_BuffNWBool
ENT.BuffDuration                = JM_BuffDuration
ENT.BuffIconName                = JM_BuffIconName


-- #############################################
-- Client Side Visual Effects
-- #############################################

if CLIENT then

    
    -- Set up screen effect table
    local effectTable_TrippingBalls = {

        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 2.5,
        ["$pp_colour_colour"] = 5,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    -- Render Any Screen Effects
    hook.Add("RenderScreenspaceEffects", ("JM_BuffScreenEffects_".. tostring(JM_PrintName)), function()

        if LocalPlayer():GetNWBool(JM_BuffNWBool) == true then 
            DrawColorModify( effectTable_TrippingBalls )
            DrawSobel( 1 )
            DrawBloom( 0.65, 2, 9, 9, 1, 1, 1, 1, 1 )
            DrawToyTown(2, ScrH() / 2)
            DrawMotionBlur( 0.1, 0.8, 0.01 )
        end 
    
    end)

end

-- #############################################
-- The Actual Effects of this buff
-- #############################################

function ENT:Initialize()
    self.BaseClass.Initialize(self)

end

function ENT:Think()
    self.BaseClass.Think(self)

end

-- #############################################
-- AUTOMATICALLY GENERATED STUFF
-- #############################################

--Remove This Buff at the start of the round
hook.Add("TTTPrepareRound", ("JM_ResetNwBool_".. tostring(JM_PrintName)), function()
    for _, v in ipairs(player.GetAll()) do
        v:SetNWBool(JM_BuffNWBool, false)
    end
end)

-- Register Buff Icon
if CLIENT then
	hook.Add("Initialize", ("JM_BuffRegisterIcon_".. tostring(JM_PrintName)), function() 
        STATUS:RegisterStatus(JM_BuffIconName, {
			hud = Material(JM_BuffIconPath),
			type = JM_BuffIconGoodBad
		})
    end)
end