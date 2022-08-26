-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end

if CLIENT then return end

local gamemodeNextGameModeCurrentCounter        = 0
local gamemodeChanceOfInnocentDriven            = 30
local gamemodeChanceOfAny                       = 100

function JM_GameMode_Function_Main()

    -- Table of Possible Game Modes
    local tableOfGamemodes_Innocent = {

        JM_GameMode_DefuseTheBombs_Init,
        JM_GameMode_DefuseTheBombs_Init,
        JM_GameMode_Powerup_Init,
        JM_GameMode_Powerup_Init,
        JM_GameMode_Stash_Init,
        JM_GameMode_TraitorTester_Init    

    }

    -- Table of Possible Game Modes
    local tableOfGamemodes_All = {

        JM_GameMode_DefuseTheBombs_Init,
        JM_GameMode_Powerup_Init,
        JM_GameMode_Stash_Init,
        JM_GameMode_ProtectTheFiles_Init,
        JM_GameMode_BountyHunter_Init,
        JM_GameMode_Infection_Init,
        JM_GameMode_LowAmmoMode_Init,
        JM_GameMode_PistolRound_Init,
        JM_GameMode_TraitorTester_Init,
        JM_GameMode_PowerHour_Init,
        JM_GameMode_LowGravity_Init,
        JM_GameMode_SlipperyFloors_Init,
        JM_GameMode_CrowbarManMode_Init

    }

    if gamemodeNextGameModeCurrentCounter == 0 then

        local iRandomRoll = math.random(1, 100)

        if iRandomRoll <= gamemodeChanceOfInnocentDriven then

            -- Log the outcome
            if SERVER then print("[GameModes] There will be an Innocent Driven Game Mode") end

            -- Add to or Reset the Counter
            gamemodeNextGameModeCurrentCounter = gamemodeNextGameModeCurrentCounter + 1

            -- Randomly select from the table of gamemodes
            local iRandomRoll = math.random(1, table.getn(tableOfGamemodes_Innocent))
            tableOfGamemodes_Innocent[iRandomRoll]()  
        else
            -- Add to or Reset the Counter
            gamemodeNextGameModeCurrentCounter = gamemodeNextGameModeCurrentCounter + 1
            if SERVER then print("[GameModes] There was not an Innocent Driven Game Mode") end
        end    

    else

        local iRandomRoll = math.random(1, 100)

        if iRandomRoll <= gamemodeChanceOfAny then

            -- Log the outcome
            if SERVER then print("[GameModes] There will be ANY Game Mode") end

            -- Add to or Reset the Counter
            gamemodeNextGameModeCurrentCounter = 0

            -- Randomly select from the table of gamemodes
            local iRandomRoll = math.random(1, table.getn(tableOfGamemodes_All))
            tableOfGamemodes_All[iRandomRoll]()  
        else
            if SERVER then print("[GameModes] There was not ANY Game Mode") end
        end    
    end


end

-- Gamemode Start Functions

function JM_GameMode_ProtectTheFiles_Init()

    -- Debug
    if SERVER then print("[GameModes] Gamemode: Protect The Files") end

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
			pl:Give(tableOfPossibleItems[iRandomRoll])
            JM_Function_PrintChat(pl, "Power Hour", "You recieve: " .. tostring(tableOfPossibleItems[iRandomRoll]))
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





--- Hook for gamemodes to run on
hook.Add("TTTBeginRound", "JMGameModesMainBeginRound", function()

    if (SERVER) then JM_GameMode_Function_Main() end 

end)