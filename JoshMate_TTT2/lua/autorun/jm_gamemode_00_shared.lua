-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end

if CLIENT then return end

local iRandomChance_Max = 8
local iRandomChance_Current = iRandomChance_Max
local iRandomChance_inc = 2

function JM_GameMode_Function_Main()

    -- Game Modes have a 1 in 8 Chance of Happening but increaing each round until reset
    local iRandomChance = math.random(1,iRandomChance_Current)
    
    if iRandomChance == 1 then

        local tableOfGamemodes = {}
        table.insert(tableOfGamemodes, "ProtectTheFiles")
        table.insert(tableOfGamemodes, "DefuseTheBombs")
        table.insert(tableOfGamemodes, "DefuseTheBombs")
        table.insert(tableOfGamemodes, "DefuseTheBombs")

        -- JM DEBUG
        -- JM_Function_PrintChat_All("DEBUG", "This round will have a Gamemode! Chance Was: " .. tostring(iRandomChance_Current))

        -- Reset the Chance Counter
        iRandomChance_Current = iRandomChance_Max
    
        -- Randomly select from the table of gamemodes
        selectedGameMode = tableOfGamemodes[math.random( #tableOfGamemodes )]

        -- Protect the Files
        if selectedGameMode == "ProtectTheFiles" then

            -- JM DEBUG
            -- JM_Function_PrintChat_All("DEBUG", "Gamemode: Protect the Files")

            JM_GameMode_Start_ProtectTheFiles()

        end

        -- Defuse the Bomb
        if selectedGameMode == "DefuseTheBombs" then

            -- JM DEBUG
            -- JM_Function_PrintChat_All("DEBUG", "Gamemode: Defuse the Bomb")

            JM_GameMode_Start_DefuseTheBombs()

        end

    else
        -- JM DEBUG
        -- JM_Function_PrintChat_All("DEBUG", "No Gamemode this round, Chance was: " .. tostring(iRandomChance_Current))

        -- Increase the odds of a gamemode as it didn't happen this time
        iRandomChance_Current = iRandomChance_Current - iRandomChance_inc
        iRandomChance_Current = math.Clamp(iRandomChance_Current, 1, iRandomChance_Max)
        

    end


end

function JM_GameMode_Function_SpawnThisThingRandomly(thingToSpawn, numberOfTimes)

    local NumberToSpawn = numberOfTimes
    local possibleSpawns = ents.FindByClass( "ent_jm_carepackage_spawn" )
    local possibleSpawnsPlayer = ents.FindByClass( "info_player_start" )
    
    for i=1,NumberToSpawn do 

        local randomChoice = math.random( 0, 100 )

        -- 10% chance to use a player spawn
        if randomChoice > 10 then

            if #possibleSpawns > 0 then
                local randomChoice = math.random(1, #possibleSpawns)
                local spawn = possibleSpawns[randomChoice]
                table.remove( possibleSpawns, randomChoice )
                
                local ent = ents.Create(thingToSpawn)
                ent:SetPos(spawn:GetPos() + Vector(0, 0, 14))
                ent:Spawn()  
                ent.gmEntIndex = i
            else

                if #possibleSpawnsPlayer > 0 then
                    local randomChoice = math.random(1, #possibleSpawnsPlayer)
                    local spawn = possibleSpawnsPlayer[randomChoice]
                    table.remove( possibleSpawnsPlayer, randomChoice )
                    
                    local ent = ents.Create(thingToSpawn)
                    ent:SetPos(spawn:GetPos() + Vector(0, 0, 6))
                    ent:Spawn()  
                    ent.gmEntIndex = i
                end

            end

        else

            if #possibleSpawnsPlayer > 0 then
                local randomChoice = math.random(1, #possibleSpawnsPlayer)
                local spawn = possibleSpawnsPlayer[randomChoice]
                table.remove( possibleSpawnsPlayer, randomChoice )
                
                local ent = ents.Create(thingToSpawn)
                ent:SetPos(spawn:GetPos() + Vector(0, 0, 6))
                ent:Spawn()  
                ent.gmEntIndex = i
            end

        end

        

    end

end



--- Hook for gamemodes to run on
hook.Add("TTTBeginRound", "JMGameModesMainBeginRound", function()

    if (SERVER) then JM_GameMode_Function_Main() end 

end)