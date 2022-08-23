-- #############################################
-- Buff Base Class Info
-- #############################################
AddCSLuaFile()
ENT.Base                        = "jm_buff_base"

-- #############################################
-- Buff Basic Info
-- #############################################

local JM_PrintName              = JM_Global_Buff_Care_MegaTracker_Name
local JM_BuffNWBool             = JM_Global_Buff_Care_MegaTracker_NWBool
local JM_BuffDuration           = JM_Global_Buff_Care_MegaTracker_Duration
local JM_BuffIconName           = JM_Global_Buff_Care_MegaTracker_IconName
local JM_BuffIconPath           = JM_Global_Buff_Care_MegaTracker_IconPath
local JM_BuffIconGoodBad        = JM_Global_Buff_Care_MegaTracker_IconGoodBad

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


-- ESP Halo effect
hook.Add( "PreDrawHalos", "Halos_Mega_Tracker", function()

    local players = {}
     local count = 0
 
     for _, ply in ipairs( player.GetAll() ) do
         if (ply:IsTerror() and ply:Alive() and ply:GetNWBool(JM_BuffNWBool) ) then
             count = count + 1
             players[ count ] = ply
         end
     end
 
     halo.Add( players, Color( 255, 255, 100 ), 2, 2, 3, true, true )
 
end )

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