-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end

-- #############################################
-- Global Function to give buffs out
-- #############################################

function JM_GiveBuffToThisPlayer(nameOfBuff, targetPlayer, buffGiver)
    
    local timeOfBuffCreation = CurTime()
    local locationOfBuffCreation = Vector( 0, 0, 0 )

    local ent = ents.Create(nameOfBuff)
    ent:SetPos(locationOfBuffCreation)
    ent.buffGiver = buffGiver
    ent.targetPlayer = targetPlayer
    ent.timeOfBuffCreation = timeOfBuffCreation
    ent:Spawn()

end

-- #############################################
-- All Global Buff Values
-- #############################################

JM_Global_Buff_Taser_Name                               = "Taser"
JM_Global_Buff_Taser_Duration                           = 12
JM_Global_Buff_Taser_NWBool                             = "JM_Buff_NWBool_IsTaser"
JM_Global_Buff_Taser_IconName                           = "JM_Buff_Icon_Taser"
JM_Global_Buff_Taser_IconPath                           = "vgui/ttt/joshmate/hud_taser.png"
JM_Global_Buff_Taser_IconGoodBad                        = "bad"

JM_Global_Buff_SilencedPistol_Name                      = "Silenced Pistol"
JM_Global_Buff_SilencedPistol_Duration                  = 5
JM_Global_Buff_SilencedPistol_NWBool                    = "JM_Buff_NWBool_IsSilencedPistol"
JM_Global_Buff_SilencedPistol_IconName                  = "JM_Buff_Icon_SilencedPistol"
JM_Global_Buff_SilencedPistol_IconPath                  = "vgui/ttt/joshmate/hud_silencedpistol.png"
JM_Global_Buff_SilencedPistol_IconGoodBad               = "bad"

JM_Global_Buff_StunGrenade_Name                         = "Stun Grenade"
JM_Global_Buff_StunGrenade_Duration                     = 7
JM_Global_Buff_StunGrenade_NWBool                       = "JM_Buff_NWBool_IsStunGrenade"
JM_Global_Buff_StunGrenade_IconName                     = "JM_Buff_Icon_StunGrenade"
JM_Global_Buff_StunGrenade_IconPath                     = "vgui/ttt/joshmate/hud_flashbang.png"
JM_Global_Buff_StunGrenade_IconGoodBad                  = "bad"

JM_Global_Buff_TrackingDart_Name                         = "Tracking Dart"
JM_Global_Buff_TrackingDart_Duration                     = 60
JM_Global_Buff_TrackingDart_NWBool                       = "JM_Buff_NWBool_IsTrackingDart"
JM_Global_Buff_TrackingDart_IconName                     = "JM_Buff_Icon_TrackingDart"
JM_Global_Buff_TrackingDart_IconPath                     = "vgui/ttt/joshmate/hud_tracker.png"
JM_Global_Buff_TrackingDart_IconGoodBad                  = "bad"

JM_Global_Buff_TagGrenade_Name                          = "Tag Grenade"
JM_Global_Buff_TagGrenade_Duration                      = 2
JM_Global_Buff_TagGrenade_NWBool                        = "JM_Buff_NWBool_IsTagGrenade"
JM_Global_Buff_TagGrenade_IconName                      = "JM_Buff_Icon_TagGrenade"
JM_Global_Buff_TagGrenade_IconPath                      = "vgui/ttt/joshmate/hud_tracker.png"
JM_Global_Buff_TagGrenade_IconGoodBad                   = "bad"

JM_Global_Buff_FireWall_Name                            = "Fire Wall"
JM_Global_Buff_FireWall_Duration                        = 10
JM_Global_Buff_FireWall_NWBool                          = "JM_Buff_NWBool_IsFireWall"
JM_Global_Buff_FireWall_IconName                        = "JM_Buff_Icon_FireWall"
JM_Global_Buff_FireWall_IconPath                        = "vgui/ttt/joshmate/hud_firewall.png"
JM_Global_Buff_FireWall_IconGoodBad                     = "bad"

JM_Global_Buff_PoisonDart_Name                          = "Poison Dart"
JM_Global_Buff_PoisonDart_Duration                      = 10
JM_Global_Buff_PoisonDart_NWBool                        = "JM_Buff_NWBool_IsPoisonDart"
JM_Global_Buff_PoisonDart_IconName                      = "JM_Buff_Icon_PoisonDart"
JM_Global_Buff_PoisonDart_IconPath                      = "vgui/ttt/joshmate/hud_poisondart.png"
JM_Global_Buff_PoisonDart_IconGoodBad                   = "bad"

JM_Global_Buff_BearTrap_Name                            = "Beartrap"
JM_Global_Buff_BearTrap_Duration                        = 0
JM_Global_Buff_BearTrap_NWBool                          = "JM_Buff_NWBool_IsBearTrap"
JM_Global_Buff_BearTrap_IconName                        = "JM_Buff_Icon_BearTrap"
JM_Global_Buff_BearTrap_IconPath                        = "vgui/ttt/hud_icon_beartrap.png"
JM_Global_Buff_BearTrap_IconGoodBad                     = "bad"

JM_Global_Buff_TreeOfLife_Name                          = "Tree of Life"
JM_Global_Buff_TreeOfLife_Duration                      = 0
JM_Global_Buff_TreeOfLife_NWBool                        = "JM_Buff_NWBool_IsTreeOfLife"
JM_Global_Buff_TreeOfLife_IconName                      = "JM_Buff_Icon_TreeOfLife"
JM_Global_Buff_TreeOfLife_IconPath                      = "vgui/ttt/joshmate/hud_tree.png"
JM_Global_Buff_TreeOfLife_IconGoodBad                   = "good"

JM_Global_Buff_Vigor_Name                               = "Vigor"
JM_Global_Buff_Vigor_Duration                           = 0
JM_Global_Buff_Vigor_NWBool                             = "JM_Buff_NWBool_IsVigor"
JM_Global_Buff_Vigor_IconName                           = "JM_Buff_Icon_Vigor"
JM_Global_Buff_Vigor_IconPath                           = "vgui/ttt/joshmate/hud_heal.png"
JM_Global_Buff_Vigor_IconGoodBad                        = "good"

JM_Global_Buff_Chameleon_Name                           = "Chameleon"
JM_Global_Buff_Chameleon_Duration                       = 0
JM_Global_Buff_Chameleon_NWBool                         = "JM_Buff_NWBool_IsChameleon"
JM_Global_Buff_Chameleon_IconName                       = "JM_Buff_Icon_Chameleon"
JM_Global_Buff_Chameleon_IconPath                       = "vgui/ttt/joshmate/hud_chameleon.png"
JM_Global_Buff_Chameleon_IconGoodBad                    = "good"



-- Care Package Buffs

JM_Global_Buff_Care_MegaTracker_Name                     = "Mega Tracker"
JM_Global_Buff_Care_MegaTracker_Duration                 = 45
JM_Global_Buff_Care_MegaTracker_NWBool                   = "JM_Buff_NWBool_IsCareMegaTracker"
JM_Global_Buff_Care_MegaTracker_IconName                 = "JM_Buff_Icon_CareMegaTracker"
JM_Global_Buff_Care_MegaTracker_IconPath                 = "vgui/ttt/joshmate/hud_tracker.png"
JM_Global_Buff_Care_MegaTracker_IconGoodBad              = "bad"

JM_Global_Buff_Care_SpeedBoost_Name                     = "Speed Boost"
JM_Global_Buff_Care_SpeedBoost_Duration                 = 0
JM_Global_Buff_Care_SpeedBoost_NWBool                   = "JM_Buff_NWBool_IsSpeedBoost"
JM_Global_Buff_Care_SpeedBoost_IconName                 = "JM_Buff_Icon_SpeedBoost"
JM_Global_Buff_Care_SpeedBoost_IconPath                 = "vgui/ttt/joshmate/hud_carepackage.png"
JM_Global_Buff_Care_SpeedBoost_IconGoodBad              = "good"

JM_Global_Buff_Care_Health_Name                         = "Health"
JM_Global_Buff_Care_Health_Duration                     = 0
JM_Global_Buff_Care_Health_NWBool                       = "JM_Buff_NWBool_IsHealth"
JM_Global_Buff_Care_Health_IconName                     = "JM_Buff_Icon_Health"
JM_Global_Buff_Care_Health_IconPath                     = "vgui/ttt/joshmate/hud_health.png"
JM_Global_Buff_Care_Health_IconGoodBad                  = "good"

JM_Global_Buff_Care_Regeneration_Name                    = "Regeneration"
JM_Global_Buff_Care_Regeneration_Duration                = 0
JM_Global_Buff_Care_Regeneration_NWBool                  = "JM_Buff_NWBool_IsRegeneration"
JM_Global_Buff_Care_Regeneration_IconName                = "JM_Buff_Icon_Regeneration"
JM_Global_Buff_Care_Regeneration_IconPath                = "vgui/ttt/joshmate/hud_heal.png"
JM_Global_Buff_Care_Regeneration_IconGoodBad             = "good"