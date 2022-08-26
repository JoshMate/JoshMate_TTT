if engine.ActiveGamemode() ~= "terrortown" then return end

if SERVER then

    util.AddNetworkString("JM_CarePackage_Arrival")
    
    local JM_CarePackage_Spawn_Timer_Min    = 10
    local JM_CarePackage_Spawn_Timer_Max    = 120
    local JM_CarePackage_Spawn_Timer_Final  = 0

    local JM_CarePackage_Spawn_Tripple_Chance = 15

    local function CP_ResetSpawnTimer()
        if SERVER then
    
            -- Reset the Spawn Timer
            JM_CarePackage_Spawn_Timer_Final = math.random( JM_CarePackage_Spawn_Timer_Min, JM_CarePackage_Spawn_Timer_Max )
            JM_CarePackage_Spawn_Timer_Final = math.Round( JM_CarePackage_Spawn_Timer_Final)
            if(timer.Exists("JMCarePackageSpawnTimer")) then timer.Remove("JMCarePackageSpawnTimer") end
            timer.Create("JMCarePackageSpawnTimer", JM_CarePackage_Spawn_Timer_Final, 1, function () JMGlobal_SpawnCarePackage(0) end)
    
        end
    end


    local function CP_CreatePackage()

        local foundASpawn = false
        local spawn = nil
        local randomChoice = nil
        local possibleSpawns = nil

        -- Check if manual spawns exist
        possibleSpawns = ents.FindByClass( "ent_jm_carepackage_spawn" )
        if #possibleSpawns > 0 then
            randomChoice = math.random(1, #possibleSpawns)
            spawn = possibleSpawns[randomChoice]
            foundASpawn = true
        end

        -- Fall back to player spawns
        if not foundASpawn then
            print("[JM Care Package] - WARNING: No Manual spawns found! using player spawn instead...")
            possibleSpawns = ents.FindByClass( "info_player_start" )
            randomChoice = math.random(1, #possibleSpawns)
            spawn = possibleSpawns[randomChoice]
        end

        local ent = ents.Create("ent_jm_carepackage")
		ent:SetPos(spawn:GetPos())
        ent:Spawn()  

    end

    function JMGlobal_SpawnCarePackage(Force_Spawned)



        local CP_Event = 0

        if Force_Spawned == 0 then

            local RNG_Event = math.random(1, 100)

            
            if (RNG_Event <= JM_CarePackage_Spawn_Tripple_Chance) then
                
                -- Emergency Airdrop
                CP_Event = 2

            else

                -- Normal Spawn
                CP_Event = 1

            end
        end

        if Force_Spawned == 1 then
            -- Forced Normal Spawn
            CP_Event = 3
        end
        if Force_Spawned == 2 then
            -- Forced Emergency Airdrop
            CP_Event = 4
        end



        if CP_Event == 1 then 
            print("[JM Care Package] - A Care Package has Spawned Natuarally") 
            CP_CreatePackage()
        end

        if CP_Event == 2 then 
            print("[JM Care Package] - A Emergency Aidrop has Spawned Natuarally") 
            CP_CreatePackage()
            CP_CreatePackage()
            CP_CreatePackage()
        end

        if CP_Event == 3 then 
            print("[JM Care Package] - A Care Package has been spawned in by an Admin") 
            CP_CreatePackage()
        end

        if CP_Event == 4 then 
            print("[JM Care Package] - A Emergency Aidrop has been spawned in by an Admin") 
            CP_CreatePackage()
            CP_CreatePackage()
            CP_CreatePackage()
        end
        

        -- Tell clients it has spawned
        net.Start("JM_CarePackage_Arrival")
        net.WriteInt(CP_Event, 16)
        net.Broadcast()

        -- Reset the spawn timer for the next package
        CP_ResetSpawnTimer()

    end

    -- Init CP Logics at the start of each round
    hook.Add("TTTPrepareRound", "JMCarePackageSpawnTimerHook", function()

        -- Reset the spawn timer for the next package
        CP_ResetSpawnTimer() 

    end)

end

if CLIENT then

    
    net.Receive("JM_CarePackage_Arrival", function(_) 
        local Type = net.ReadInt(16)

        if Type == 0 then return end

        if Type == 1 or Type == 3 then surface.PlaySound("carepackage_arrive.wav") return end

        if Type == 2 or Type == 4 then surface.PlaySound("carepackage_arrive_group.wav") return end

        
    end)
end