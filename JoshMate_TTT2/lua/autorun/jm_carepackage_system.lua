if engine.ActiveGamemode() ~= "terrortown" then return end


if SERVER then

    util.AddNetworkString("JM_CarePackage_Arrival")

    local JM_CarePackage_Spawn_Timer_Min    = 30
    local JM_CarePackage_Spawn_Timer_Max    = 240
    local JM_CarePackage_Spawn_Timer_Final  = 0

    function JMGlobal_SpawnCarePackage(Forced)

        local foundASpawn = false
        local spawn = nil
        local randomChoice = nil
        local possibleSpawns = nil

        net.Start("JM_CarePackage_Arrival")
        net.Broadcast()

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
       

        if Forced then print("[JM Care Package] - Force spawning a Care Package!") end
        if not Forced then print("[JM Care Package] - Naturally Spawning Care package after: " .. tostring(JM_CarePackage_Spawn_Timer_Final) .. " Seconds") end 
        print("[JM Care Package] - Spawning Care package at Spawn: " .. tostring(randomChoice) .. " / " .. tostring(#possibleSpawns))

        JM_CarePackage_Spawn_Timer_Final = math.random( JM_CarePackage_Spawn_Timer_Min, JM_CarePackage_Spawn_Timer_Max )
        JM_CarePackage_Spawn_Timer_Final = math.Round( JM_CarePackage_Spawn_Timer_Final)
        if(timer.Exists("JMCarePackageSpawnTimer")) then timer.Remove("JMCarePackageSpawnTimer") end
        timer.Create("JMCarePackageSpawnTimer", JM_CarePackage_Spawn_Timer_Final, 1, function () JMGlobal_SpawnCarePackage(false) end)

    end

    -- Init CP Logics at the start of each round
    hook.Add("TTTPrepareRound", "JMCarePackageSpawnTimerHook", function()

        JM_CarePackage_Spawn_Timer_Final = math.random( JM_CarePackage_Spawn_Timer_Min, JM_CarePackage_Spawn_Timer_Max )
        JM_CarePackage_Spawn_Timer_Final = math.Round( JM_CarePackage_Spawn_Timer_Final)

        if(timer.Exists("JMCarePackageSpawnTimer")) then timer.Remove("JMCarePackageSpawnTimer") end
        timer.Create("JMCarePackageSpawnTimer", JM_CarePackage_Spawn_Timer_Final, 1, function () JMGlobal_SpawnCarePackage(false) end) 

    end)

end

if CLIENT then
    net.Receive("JM_CarePackage_Arrival", function(_) 
        surface.PlaySound("carepackage_arrive.wav")
        LocalPlayer():ChatPrint("[Care Package] - A Care Package has appeared somewhere on the map!")
    end)
end