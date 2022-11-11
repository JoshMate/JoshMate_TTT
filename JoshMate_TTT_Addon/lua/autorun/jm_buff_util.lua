-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end

-- #############################################
-- Global Function to give buffs out
-- #############################################

function JM_GiveBuffToThisPlayer(nameOfBuff, targetPlayer, buffGiver)

    -- Remove it first before giving them a new one to prevent non-stacking
    JM_RemoveBuffFromThisPlayer(nameOfBuff, targetPlayer)
    
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

function JM_CheckIfPlayerHasBuff(nameOfBuff, targetPlayer)
    
    for k, buff in ipairs(ents.FindByClass(nameOfBuff)) do
        
        if (buff.targetPlayer == targetPlayer) then
            return true
        end

    end

    return false

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
JM_Global_Buff_StunGrenade_Duration                     = 5
JM_Global_Buff_StunGrenade_NWBool                       = "JM_Buff_NWBool_IsStunGrenade"
JM_Global_Buff_StunGrenade_IconName                     = "JM_Buff_Icon_StunGrenade"
JM_Global_Buff_StunGrenade_IconPath                     = "vgui/ttt/joshmate/hud_flashbang.png"
JM_Global_Buff_StunGrenade_IconGoodBad                  = "bad"

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
JM_Global_Buff_TreeOfLife_Duration                      = 1
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

JM_Global_Buff_NewtonLauncher_Name                         = "Newton Launcher"
JM_Global_Buff_NewtonLauncher_Duration                     = 3
JM_Global_Buff_NewtonLauncher_NWBool                       = "JM_Buff_NWBool_IsNewtonLauncher"
JM_Global_Buff_NewtonLauncher_IconName                     = "JM_Buff_Icon_NewtonLauncher"
JM_Global_Buff_NewtonLauncher_IconPath                     = "vgui/ttt/joshmate/hud_newtonlauncher.png"
JM_Global_Buff_NewtonLauncher_IconGoodBad                  = "bad"

JM_Global_Buff_ZombieMode_Name                               = "Zombie Mode"
JM_Global_Buff_ZombieMode_Duration                           = 0
JM_Global_Buff_ZombieMode_NWBool                             = "JM_Buff_NWBool_IsZombieMode"
JM_Global_Buff_ZombieMode_IconName                           = "JM_Buff_Icon_ZombieMode"
JM_Global_Buff_ZombieMode_IconPath                           = "vgui/ttt/joshmate/hud_zombiemode.png"
JM_Global_Buff_ZombieMode_IconGoodBad                        = "good"

JM_Global_Buff_MoneyPrinter_Name                               = "Money Printer"
JM_Global_Buff_MoneyPrinter_Duration                           = 30
JM_Global_Buff_MoneyPrinter_NWBool                             = "JM_Buff_NWBool_IsMoneyPrinter"
JM_Global_Buff_MoneyPrinter_IconName                           = "JM_Buff_Icon_MoneyPrinter"
JM_Global_Buff_MoneyPrinter_IconPath                           = "vgui/ttt/joshmate/hud_moneyprinter.png"
JM_Global_Buff_MoneyPrinter_IconGoodBad                        = "good"

JM_Global_Buff_Agent_Name                                       = "Agent"
JM_Global_Buff_Agent_Duration                                   = 0
JM_Global_Buff_Agent_NWBool                                     = "JM_Buff_NWBool_IsAgent"
JM_Global_Buff_Agent_IconName                                   = "JM_Buff_Icon_Agent"
JM_Global_Buff_Agent_IconPath                                   = "vgui/ttt/joshmate/hud_agent.png"
JM_Global_Buff_Agent_IconGoodBad                                = "good"

JM_Global_Buff_HealthGrenade_Name                               = "Healing Grenade"
JM_Global_Buff_HealthGrenade_Duration                           = 16
JM_Global_Buff_HealthGrenade_NWBool                             = "JM_Buff_NWBool_IsHealthGrenade"
JM_Global_Buff_HealthGrenade_IconName                           = "JM_Buff_Icon_HealthGrenade"
JM_Global_Buff_HealthGrenade_IconPath                           = "vgui/ttt/joshmate/hud_heal.png"
JM_Global_Buff_HealthGrenade_IconGoodBad                        = "good"

JM_Global_Buff_Glue_Name                                        = "Glue"
JM_Global_Buff_Glue_Duration                                    = 7
JM_Global_Buff_Glue_NWBool                                      = "JM_Buff_NWBool_IsGlue"
JM_Global_Buff_Glue_IconName                                    = "JM_Buff_Icon_Glue"
JM_Global_Buff_Glue_IconPath                                    = "vgui/ttt/joshmate/hud_glue.png"
JM_Global_Buff_Glue_IconGoodBad                                 = "bad"

JM_Global_Buff_FireOrb_Name                                        = "Fire Orb"
JM_Global_Buff_FireOrb_Duration                                    = 7
JM_Global_Buff_FireOrb_NWBool                                      = "JM_Buff_NWBool_IsFireOrb"
JM_Global_Buff_FireOrb_IconName                                    = "JM_Buff_Icon_FireOrb"
JM_Global_Buff_FireOrb_IconPath                                    = "vgui/ttt/joshmate/hud_smoke.png"
JM_Global_Buff_FireOrb_IconGoodBad                                 = "bad"

JM_Global_Buff_Uav_Name                                         = "UAV Buff"
JM_Global_Buff_Uav_Duration                                     = 8
JM_Global_Buff_Uav_NWBool                                       = "JM_Buff_NWBool_IsUavBuff"
JM_Global_Buff_Uav_IconName                                     = "JM_Buff_Icon_UavBuff"
JM_Global_Buff_Uav_IconPath                                     = "vgui/ttt/joshmate/hud_uav.png"
JM_Global_Buff_Uav_IconGoodBad                                  = "good"

JM_Global_Buff_Dash_Name                                        = "Dash"
JM_Global_Buff_Dash_Duration                                    = 5
JM_Global_Buff_Dash_NWBool                                      = "JM_Buff_NWBool_IsDash"
JM_Global_Buff_Dash_IconName                                    = "JM_Buff_Icon_Dash"
JM_Global_Buff_Dash_IconPath                                    = "vgui/ttt/joshmate/hud_dash.png"
JM_Global_Buff_Dash_IconGoodBad                                 = "good"

JM_Global_Buff_BarrierSlow_Name                                 = "Barrier Slow"
JM_Global_Buff_BarrierSlow_Duration                             = 6
JM_Global_Buff_BarrierSlow_NWBool                               = "JM_Buff_NWBool_IsBarrierSlow"
JM_Global_Buff_BarrierSlow_IconName                             = "JM_Buff_Icon_BarrierSlow"
JM_Global_Buff_BarrierSlow_IconPath                             = "vgui/ttt/joshmate/hud_slow.png"
JM_Global_Buff_BarrierSlow_IconGoodBad                          = "bad"

JM_Global_Buff_CannibalHeal_Name                                = "Cannibal Heal"
JM_Global_Buff_CannibalHeal_Duration                            = 20
JM_Global_Buff_CannibalHeal_NWBool                              = "JM_Buff_NWBool_IsCannibalHeal"
JM_Global_Buff_CannibalHeal_IconName                            = "JM_Buff_Icon_CannibalHeal"
JM_Global_Buff_CannibalHeal_IconPath                            = "vgui/ttt/joshmate/hud_heal.png"
JM_Global_Buff_CannibalHeal_IconGoodBad                         = "good"

JM_Global_Buff_BarrierDamage_Name                                 = "Barrier Damage Increase"
JM_Global_Buff_BarrierDamage_Duration                             = 30
JM_Global_Buff_BarrierDamage_NWBool                               = "JM_Buff_NWBool_IsBarrierDamage"
JM_Global_Buff_BarrierDamage_IconName                             = "JM_Buff_Icon_BarrierDamage"
JM_Global_Buff_BarrierDamage_IconPath                             = "vgui/ttt/joshmate/hud_damagemultbad.png"
JM_Global_Buff_BarrierDamage_IconGoodBad                          = "bad"

JM_Global_Buff_MotionSensorTrack_Name                             = "Motion Sensor Tracking"
JM_Global_Buff_MotionSensorTrack_Duration                         = 5
JM_Global_Buff_MotionSensorTrack_NWBool                           = "JM_Buff_NWBool_IsMotionSensorTracking"
JM_Global_Buff_MotionSensorTrack_IconName                         = "JM_Buff_Icon_MotionSensorTracking"
JM_Global_Buff_MotionSensorTrack_IconPath                         = "vgui/ttt/joshmate/hud_motionsensortracking.png"
JM_Global_Buff_MotionSensorTrack_IconGoodBad                      = "bad"

JM_Global_Buff_Explosion_Name                                   = "Disorientated"
JM_Global_Buff_Explosion_Duration                               = 5
JM_Global_Buff_Explosion_NWBool                                 = "JM_Buff_NWBool_IsDisorientated"
JM_Global_Buff_Explosion_IconName                               = "JM_Buff_Icon_Disorientated"
JM_Global_Buff_Explosion_IconPath                               = "vgui/ttt/joshmate/hud_explosion.png"
JM_Global_Buff_Explosion_IconGoodBad                            = "bad"

JM_Global_Buff_SlowShort_Name                                   = "Short Slow"
JM_Global_Buff_SlowShort_Duration                               = 5
JM_Global_Buff_SlowShort_NWBool                                 = "JM_Buff_NWBool_IsShortSlow"
JM_Global_Buff_SlowShort_IconName                               = "JM_Buff_Icon_ShortSlow"
JM_Global_Buff_SlowShort_IconPath                               = "vgui/ttt/joshmate/hud_slow.png"
JM_Global_Buff_SlowShort_IconGoodBad                            = "bad"

JM_Global_Buff_AntidotePoison_Name                              = "Antidote Poison"
JM_Global_Buff_AntidotePoison_Duration                          = 0
JM_Global_Buff_AntidotePoison_NWBool                            = "JM_Buff_NWBool_IsAntidotePoison"
JM_Global_Buff_AntidotePoison_IconName                          = "JM_Buff_Icon_AntidotePoison"
JM_Global_Buff_AntidotePoison_IconPath                          = "vgui/ttt/joshmate/hud_poisondart.png"
JM_Global_Buff_AntidotePoison_IconGoodBad                       = "bad"



-- Karma Buffs

JM_Global_Buff_KarmaBuff_Movement_Name                            = "Angel Wings"
JM_Global_Buff_KarmaBuff_Movement_Duration                        = 0
JM_Global_Buff_KarmaBuff_Movement_NWBool                          = "JM_Buff_NWBool_IsKarmaBuffMovement"
JM_Global_Buff_KarmaBuff_Movement_IconName                        = "JM_Buff_Icon_KarmaBuffMovement"
JM_Global_Buff_KarmaBuff_Movement_IconPath                        = "vgui/ttt/joshmate/hud_karma.png"
JM_Global_Buff_KarmaBuff_Movement_IconGoodBad                     = "good"

JM_Global_Buff_KarmaBuff_Extra_Grenade_Name                       = "Nade Mule"
JM_Global_Buff_KarmaBuff_Extra_Grenade_Duration                   = 0
JM_Global_Buff_KarmaBuff_Extra_Grenade_NWBool                     = "JM_Buff_NWBool_IsKarmaBuffExtraGrenade"
JM_Global_Buff_KarmaBuff_Extra_Grenade_IconName                   = "JM_Buff_Icon_KarmaBuffExtraGrenade"
JM_Global_Buff_KarmaBuff_Extra_Grenade_IconPath                   = "vgui/ttt/joshmate/hud_grenades.png"
JM_Global_Buff_KarmaBuff_Extra_Grenade_IconGoodBad                = "good"

JM_Global_Buff_KarmaBuff_Extra_Credit_Name                       = "Clean Money"
JM_Global_Buff_KarmaBuff_Extra_Credit_Duration                   = 0
JM_Global_Buff_KarmaBuff_Extra_Credit_NWBool                     = "JM_Buff_NWBool_IsKarmaBuffExtraCredit"
JM_Global_Buff_KarmaBuff_Extra_Credit_IconName                   = "JM_Buff_Icon_KarmaBuffExtraCredit"
JM_Global_Buff_KarmaBuff_Extra_Credit_IconPath                   = "vgui/ttt/joshmate/hud_credit.png"
JM_Global_Buff_KarmaBuff_Extra_Credit_IconGoodBad                = "good"


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
JM_Global_Buff_Care_TrippingBalls_Duration               = 20
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