-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end


function JM_GameMode_Function_SpawnThisThingRandomly(thingToSpawn, numberOfTimes)

    if CLIENT then return end

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