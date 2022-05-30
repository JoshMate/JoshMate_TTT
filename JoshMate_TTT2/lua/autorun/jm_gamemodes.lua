-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end

if CLIENT then return end

local iRandomChance_Max = 12
local iRandomChance_Current = iRandomChance_Max
local iRandomChance_inc = 5


function JM_GameMode_Function_Main()

    -- Game Modes have a 1 in X Chance of Happening but increaing each round until reset
    local iRandomChance = math.random(1,iRandomChance_Current)
    
    if iRandomChance == 1 then

        -- Table of Possible Game Modes
        local tableOfGamemodes = {
            JM_GameMode_ProtectTheFiles_Init,
            JM_GameMode_BountyHunter_Init,
            JM_GameMode_Powerup_Init,
            JM_GameMode_Powerup_Init,
            JM_GameMode_DefuseTheBombs_Init,
            JM_GameMode_DefuseTheBombs_Init,
            JM_GameMode_DefuseTheBombs_Init
            
        }


        if SERVER then print("[GameModes] Gamemode: Yes! Chance: " .. tostring(iRandomChance_Current)) end

        -- Reset the Chance Counter
        iRandomChance_Current = iRandomChance_Max
    
        -- Randomly select from the table of gamemodes

        local iRandomRoll = math.random(1, table.getn(tableOfGamemodes))

        tableOfGamemodes[iRandomRoll]()      

    else

        if SERVER then print("[GameModes] Gamemode: No! Chance: " .. tostring(iRandomChance_Current)) end

        -- Increase the odds of a gamemode as it didn't happen this time
        iRandomChance_Current = iRandomChance_Current - iRandomChance_inc
        iRandomChance_Current = math.Clamp(iRandomChance_Current, 1, iRandomChance_Max)
        
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





--- Hook for gamemodes to run on
hook.Add("TTTBeginRound", "JMGameModesMainBeginRound", function()

    if (SERVER) then JM_GameMode_Function_Main() end 

end)