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

function JM_RemoveBuffFromThisPlayer(nameOfBuff, targetPlayer)
    
    for k, buff in ipairs(ents.FindByClass(nameOfBuff)) do
        
        if (buff.targetPlayer == targetPlayer) then
            buff:Remove()
        end

    end

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
JM_Global_Buff_SilencedPistol_Duration                  = 7
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

JM_Global_Buff_TagGrenade_Name                          = "Tag Grenade"
JM_Global_Buff_TagGrenade_Duration                      = 2
JM_Global_Buff_TagGrenade_NWBool                        = "JM_Buff_NWBool_IsTagGrenade"
JM_Global_Buff_TagGrenade_IconName                      = "JM_Buff_Icon_TagGrenade"
JM_Global_Buff_TagGrenade_IconPath                      = "vgui/ttt/joshmate/hud_tracker.png"
JM_Global_Buff_TagGrenade_IconGoodBad                   = "bad"

JM_Global_Buff_PulsePad_Name                            = "Pulse Pad"
JM_Global_Buff_PulsePad_Duration                        = 90
JM_Global_Buff_PulsePad_NWBool                          = "JM_Buff_NWBool_IsPulsePad"
JM_Global_Buff_PulsePad_IconName                        = "JM_Buff_Icon_PulsePad"
JM_Global_Buff_PulsePad_IconPath                        = "vgui/ttt/joshmate/hud_tracker.png"
JM_Global_Buff_PulsePad_IconGoodBad                     = "bad"

JM_Global_Buff_PoisonDart_Name                          = "Poison Dart"
JM_Global_Buff_PoisonDart_Duration                      = 15
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
JM_Global_Buff_Care_MegaTracker_Duration                 = 30
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

JM_Global_Buff_Care_TrippingBalls_Name                   = "Tripping Balls"
JM_Global_Buff_Care_TrippingBalls_Duration               = 30
JM_Global_Buff_Care_TrippingBalls_NWBool                 = "JM_Buff_NWBool_IsTrippingBalls"
JM_Global_Buff_Care_TrippingBalls_IconName               = "JM_Buff_Icon_TrippingBalls"
JM_Global_Buff_Care_TrippingBalls_IconPath               = "vgui/ttt/joshmate/hud_trippingballs.png"
JM_Global_Buff_Care_TrippingBalls_IconGoodBad            = "bad"

JM_Global_Buff_Care_RapidFire_Name                      = "Rapid Fire"
JM_Global_Buff_Care_RapidFire_Duration                  = 0
JM_Global_Buff_Care_RapidFire_NWBool                    = "JM_Buff_NWBool_IsRapidFire"
JM_Global_Buff_Care_RapidFire_IconName                  = "JM_Buff_Icon_RapidFire"
JM_Global_Buff_Care_RapidFire_IconPath                  = "vgui/ttt/joshmate/hud_rapidfire.png"
JM_Global_Buff_Care_RapidFire_IconGoodBad               = "good"

-- Special Buffs

JM_Global_Buff_SuddenDeath_Name                     = "Sudden Death"
JM_Global_Buff_SuddenDeath_Duration                 = 0
JM_Global_Buff_SuddenDeath_NWBool                   = "JM_Buff_NWBool_IsSuddenDeath"
JM_Global_Buff_SuddenDeath_IconName                 = "JM_Buff_Icon_SuddenDeath"
JM_Global_Buff_SuddenDeath_IconPath                 = "vgui/ttt/joshmate/hud_tracker.png"
JM_Global_Buff_SuddenDeath_IconGoodBad              = "bad"