-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end

if CLIENT then return end

-- Gamemode Chooser Vars
local gamemodeChanceCurrent                     = 0
local gamemodeChanceIncrease                    = 25
local gamemodeChanceMax                         = 100

function JM_GameMode_Function_Main()

    -- Table of Possible Game Modes
    local tableOfGamemodes = {

        JM_GameMode_DefuseTheBombs_Init,
        JM_GameMode_DefuseTheBombs_Init,
        JM_GameMode_DefuseTheBombs_Init,

        JM_GameMode_Antidote_Init,
        JM_GameMode_Antidote_Init,
        JM_GameMode_Antidote_Init,

        JM_GameMode_Powerup_Init,
        JM_GameMode_Powerup_Init,

        JM_GameMode_Stash_Init,
        JM_GameMode_Stash_Init,

        JM_GameMode_GrabTheFiles_Init,
        JM_GameMode_GrabTheFiles_Init,

        JM_GameMode_BountyHunter_Init,
        JM_GameMode_BountyHunter_Init,

        JM_GameMode_ArmsDeal_Init,
        JM_GameMode_ArmsDeal_Init,

        JM_GameMode_Infection_Init,
        JM_GameMode_PistolRound_Init,
        JM_GameMode_TraitorTester_Init,
        JM_GameMode_PowerHour_Init,
        JM_GameMode_LowGravity_Init,
        JM_GameMode_SlipperyFloors_Init
        

    }

    local iRandomRoll = math.random(1, gamemodeChanceMax)

    if iRandomRoll <= gamemodeChanceCurrent then

        -- Log the outcome
        if SERVER then print("[GameModes] Gamemode! Chance: " .. tostring(gamemodeChanceCurrent) .. "%") end

        -- Reset the Counter
        gamemodeChanceCurrent = 0

        -- Randomly select from the table of gamemodes
        local iRandomRoll = math.random(1, table.getn(tableOfGamemodes))
        tableOfGamemodes[iRandomRoll]()  
    else
        -- Add to or Reset the Counter
        if SERVER then print("[GameModes] No Gamemode...  Chance: " .. tostring(gamemodeChanceCurrent) .. "%") end
        gamemodeChanceCurrent = gamemodeChanceCurrent + gamemodeChanceIncrease
    end  


end

-- Gamemode Start Functions

function JM_GameMode_GrabTheFiles_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Grab The Files") end

    -- Spawn the Gamemode Handler Object
    local GameModeHandlerObject = ents.Create("ent_jm_objective_01_file_base")
    GameModeHandlerObject:Spawn()

end

function JM_GameMode_DefuseTheBombs_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Defuse the Bombs") end

    -- Spawn the Gamemode Handler Object
    local GameModeHandlerObject = ents.Create("ent_jm_objective_02_bomb_base")
    GameModeHandlerObject:Spawn()

end

function JM_GameMode_BountyHunter_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Bounty Hunter") end

    -- Spawn the Gamemode Handler Object
    local GameModeHandlerObject = ents.Create("ent_jm_objective_03_bounty_base")
    GameModeHandlerObject:Spawn()

end

function JM_GameMode_Powerup_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Powerup") end

    -- Spawn the Gamemode Handler Object
    local GameModeHandlerObject = ents.Create("ent_jm_objective_04_power_base")
    GameModeHandlerObject:Spawn()

end

function JM_GameMode_Stash_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Stash") end

    -- Spawn the Gamemode Handler Object
    local GameModeHandlerObject = ents.Create("ent_jm_objective_05_stash_base")
    GameModeHandlerObject:Spawn()

end

function JM_GameMode_Infection_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Infection") end

    -- Spawn the Gamemode Handler Object
    local GameModeHandlerObject = ents.Create("ent_jm_objective_06_infection_base")
    GameModeHandlerObject:Spawn()

end

-- REMOVED FROM THE GAME ATM
function JM_GameMode_CrowbarManMode_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Crowbar Man Mode") end

    -- Announce the Goal
	JM_Function_Announcement("[Crowbar Man Mode] There are no weapons on the map!", 0)

	-- Play the Sound
    JM_Function_PlaySound("gamemode/crowbarmanmode_start.mp3")

    -- Do the Round Logic
    for k, v in ipairs( ents.FindByClass( "weapon_jm_primary_*" ) ) do
        v:Remove()
    end

    for k, v in ipairs( ents.FindByClass( "weapon_jm_secondary_*" ) ) do
        v:Remove()
    end

end

-- REMOVED FROM THE GAME ATM
function JM_GameMode_LowAmmoMode_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Low Ammo") end

    -- Announce the Goal
	JM_Function_Announcement("[Low Ammo] Your guns have very little ammo!", 0)

	-- Play the Sound
    JM_Function_PlaySound("gamemode/weapon_start.mp3")

    -- Do the Round Logic
    local plys = player:GetAll() 
    for i = 1, #plys do

        local ply = plys[i]
        if not ply:IsValid() then continue end
        ply:RemoveAmmo( 9999, "Pistol")
	    ply:RemoveAmmo( 9999, "357")

    end

end

function JM_GameMode_PistolRound_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Pistol Round") end

    -- Announce the Goal
	JM_Function_Announcement("[Pistol Round] There are only pistols on the map!", 0)

	-- Play the Sound
    JM_Function_PlaySound("gamemode/weapon_start.mp3")

    -- Do the Round Logic
    for k, v in ipairs( ents.FindByClass( "weapon_jm_primary_*" ) ) do
        v:Remove()
    end

end

function JM_GameMode_PowerHour_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Power Hour") end

    -- Announce the Goal
	JM_Function_Announcement("[Power Hour] Everyone recieves a random carepackage item!", 0)

	-- Play the Sound
    JM_Function_PlaySound("gamemode/powerhour_start.mp3")

    -- Create the possible items list
    -- Table of Possible Game Modes
    local tableOfPossibleItems = {
        "weapon_jm_zloot_advanced_pistol",
        "weapon_jm_zloot_advanced_rifle",
        "weapon_jm_zloot_advanced_shotgun",
        "weapon_jm_zloot_advanced_smg",
        "weapon_jm_zloot_advanced_sniper",
        "weapon_jm_zloot_explosive_gun",
        "weapon_jm_zloot_gluegun",
        "weapon_jm_zloot_mega_frag",
        "weapon_jm_zloot_mega_glue",
        "weapon_jm_zloot_mega_jump",
        "weapon_jm_zloot_mega_shotgun",
        "weapon_jm_zloot_ninjablade",
        "weapon_jm_zloot_placer_crate",
        "weapon_jm_zloot_placer_medkit",
        "weapon_jm_zloot_prop_launcher",
        "weapon_jm_zloot_shredder",
        "weapon_jm_zloot_slomo_clock",
        "weapon_jm_zloot_traitor_tester",
        "weapon_jm_zloot_teleporterunstable",
        "weapon_jm_zloot_inferno_launcher"
    }

    -- Hand out items
	for _,pl in pairs(player:GetAll()) do
		if pl:IsValid() and pl:Alive() and pl:IsTerror() then 
            local iRandomRoll = math.random(1, table.getn(tableOfPossibleItems))

            -- Remove Weapons on Player
            pl:StripWeapon("weapon_jm_primary_lmg")
            pl:StripWeapon("weapon_jm_primary_rifle")
            pl:StripWeapon("weapon_jm_primary_shotgun")
            pl:StripWeapon("weapon_jm_primary_smg")
            pl:StripWeapon("weapon_jm_primary_sniper")
            pl:StripWeapon("weapon_jm_primary_shotgun")
            pl:StripWeapon("weapon_jm_primary_smg")
            pl:StripWeapon("weapon_jm_secondary_auto")
            pl:StripWeapon("weapon_jm_secondary_heavy")
            pl:StripWeapon("weapon_jm_secondary_light")
            pl:StripWeapon("weapon_jm_grenade_frag")
            pl:StripWeapon("weapon_jm_grenade_glue")
            pl:StripWeapon("weapon_jm_grenade_health")
            pl:StripWeapon("weapon_jm_grenade_jump")
            pl:StripWeapon("weapon_jm_grenade_tag")
			pl:Give(tableOfPossibleItems[iRandomRoll])
            JM_Function_PrintChat(pl, "Power Hour", "Your old weapons have replaced by: ".. tostring(tableOfPossibleItems[iRandomRoll]))
		end
	end
    

end

function JM_GameMode_LowGravity_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Low Gravity") end

    -- Announce the Goal
	JM_Function_Announcement("[Low Gravity] Gravity has been reduced!", 0)

	-- Play the Sound
    JM_Function_PlaySound("effect_low_gravity.mp3")

    -- Do the Round Logic
    RunConsoleCommand("sv_gravity", 100)
    RunConsoleCommand("sv_airaccelerate", 12)

end

function JM_GameMode_SlipperyFloors_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Slippery Floors") end

    -- Announce the Goal
	JM_Function_Announcement("[Slippery Floors] The floors are now made of ice!", 0)

	-- Play the Sound
    JM_Function_PlaySound("effect_slippery_floors.mp3")

    -- Do the Round Logic
    RunConsoleCommand("sv_friction", 0)
    RunConsoleCommand("sv_accelerate", 5)

end

function JM_GameMode_TraitorTester_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Traitor Tester") end

    -- Work out who gets it
    
    local listOfPlayers = player:GetAll()
    local iRandomRoll = math.random(1, #listOfPlayers)
    local chosenPlayer = listOfPlayers[iRandomRoll]
    local chosenPlayerName = "ERROR"

    if chosenPlayer:IsValid() and chosenPlayer:IsTerror() then
        chosenPlayer:Give("weapon_jm_zloot_traitor_tester")
        chosenPlayerName = chosenPlayer:Nick()
    end
    
    -- Announce the Goal
	JM_Function_Announcement("[Traitor Tester] " .. tostring(chosenPlayerName) .. " has recieved the tester!", 0)

	-- Play the Sound
    JM_Function_PlaySound("shoot_portable_tester_scan.wav")

end

function JM_GameMode_Antidote_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Antidote") end

    -- Spawn the Gamemode Handler Object
    local GameModeHandlerObject = ents.Create("ent_jm_objective_07_antidote_base")
    GameModeHandlerObject:Spawn()

end

function JM_GameMode_ArmsDeal_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Arms Deal") end

    -- Spawn the Gamemode Handler Object
    local GameModeHandlerObject = ents.Create("ent_jm_objective_08_armsdeal_base")
    GameModeHandlerObject:Spawn()

end





--- Hook for gamemodes to run on
hook.Add("TTTBeginRound", "JMGameModesMainBeginRound", function()

    if (SERVER) then JM_GameMode_Function_Main() end 

end)