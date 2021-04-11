if engine.ActiveGamemode() ~= "terrortown" then return end


if SERVER then

    util.AddNetworkString("JM_CarePackage_Arrival")

    local JM_CarePackage_Spawn_Timer_Min    = 30
    local JM_CarePackage_Spawn_Timer_Max    = 300
    local JM_CarePackage_Spawn_Timer_Final  = 0

    function JMGlobal_SpawnCarePackage(Forced)

        net.Start("JM_CarePackage_Arrival")
        net.Broadcast()

        local possibleSpawns = ents.FindByClass( "info_player_start" )
        local randomChoice = math.random(1, #possibleSpawns)
        local spawn = possibleSpawns[randomChoice]
        local ent = ents.Create("ent_jm_carepackage")
		ent:SetPos(spawn:GetPos())
        ent:Spawn()     
       
        if Forced then print("[JM Care Package] - Force spawning a Care Package!") end
        if not Forced then print("[JM Care Package] - Naturally Spawning Care package after: " .. tostring(JM_CarePackage_Spawn_Timer_Final) .. " Seconds") end 
        print("[JM Care Package] - Spawning Care package at Spawn: " .. tostring(randomChoice) .. " / " .. tostring(#possibleSpawns))

    end

    -- Init CP Logics at the start of each round
    hook.Add("TTTPrepareRound", "JMCarePackageSpawnTimerHook", function()

        JM_CarePackage_Spawn_Timer_Final = math.random( JM_CarePackage_Spawn_Timer_Min, JM_CarePackage_Spawn_Timer_Max )
        JM_CarePackage_Spawn_Timer_Final = math.Round( JM_CarePackage_Spawn_Timer_Final)

        if(timer.Exists("JMCarePackageSpawnTimer")) then timer.Remove("JMCarePackageSpawnTimer") end
        timer.Create("JMCarePackageSpawnTimer", JM_CarePackage_Spawn_Timer_Final, 5, function () JMGlobal_SpawnCarePackage(false) end)
        
    end)

end

if CLIENT then
    net.Receive("JM_CarePackage_Arrival", function(_) 
        surface.PlaySound("carepackage_arrive.wav")
        LocalPlayer():ChatPrint("[Care Package] - A Care Package has appeared somewhere on the map!")
    end)
end