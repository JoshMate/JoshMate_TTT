-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end

if CLIENT then return end

-- ### The old Random Chance System
-- local iRandomChance_Max = 2
-- local iRandomChance_Current = iRandomChance_Max
-- local iRandomChance_inc = 1
-- Game Modes have a 1 in X Chance of Happening but increaing each round until reset
-- local iRandomChance = math.random(1,iRandomChance_Current)
-- if iRandomChance == 1 then
-- Increase the odds of a gamemode as it didn't happen this time
--iRandomChance_Current = iRandomChance_Current - iRandomChance_inc
--iRandomChance_Current = math.Clamp(iRandomChance_Current, 1, iRandomChance_Max)

local gamemodeNextGameModeCurrentCounter        = 0

function JM_GameMode_Function_Main()

    if gamemodeNextGameModeCurrentCounter == 1 then

        -- Table of Possible Game Modes
        local tableOfGamemodes = {

            JM_GameMode_DefuseTheBombs_Init,
            JM_GameMode_DefuseTheBombs_Init,
            JM_GameMode_DefuseTheBombs_Init,
            JM_GameMode_DefuseTheBombs_Init,

            JM_GameMode_Powerup_Init,
            JM_GameMode_Powerup_Init,
            JM_GameMode_Powerup_Init,
            JM_GameMode_Powerup_Init,
            
            JM_GameMode_Stash_Init,
            JM_GameMode_Stash_Init,
            JM_GameMode_Stash_Init,
            JM_GameMode_Stash_Init,

            JM_GameMode_ProtectTheFiles_Init,
            JM_GameMode_ProtectTheFiles_Init,
            JM_GameMode_ProtectTheFiles_Init,

            JM_GameMode_BountyHunter_Init,
            JM_GameMode_BountyHunter_Init,
            JM_GameMode_BountyHunter_Init,

            JM_GameMode_Infection_Init,
            JM_GameMode_Infection_Init,
            JM_GameMode_Infection_Init,
            
            JM_GameMode_LowAmmoMode_Init,
            JM_GameMode_LowAmmoMode_Init,

            JM_GameMode_PistolRound_Init,
            JM_GameMode_PistolRound_Init,

            JM_GameMode_PowerHour_Init,

            JM_GameMode_CrowbarManMode_Init
            
        }

        if SERVER then print("[GameModes] There will be a gamemode!") end

        -- Reset the Chance Counter
        gamemodeNextGameModeCurrentCounter = 0
    
        -- Randomly select from the table of gamemodes

        local iRandomRoll = math.random(1, table.getn(tableOfGamemodes))

        tableOfGamemodes[iRandomRoll]()      

    else
        if SERVER then print("[GameModes] No gamemode this time...") end
        gamemodeNextGameModeCurrentCounter = gamemodeNextGameModeCurrentCounter + 1
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
    local plys = player.GetAll() 
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
        "weapon_jm_zloot_teleporterunstable"
    }

    -- Hand out items
	for _,pl in pairs(player.GetAll()) do
		if pl:IsValid() and pl:Alive() and pl:IsTerror() then 
            local iRandomRoll = math.random(1, table.getn(tableOfPossibleItems))
			pl:Give(tableOfPossibleItems[iRandomRoll])
            JM_Function_PrintChat(pl, "Power Hour", "You recieve: " .. tostring(tableOfPossibleItems[iRandomRoll]))
		end
	end
    

end





--- Hook for gamemodes to run on
hook.Add("TTTBeginRound", "JMGameModesMainBeginRound", function()

    if (SERVER) then JM_GameMode_Function_Main() end 

end)