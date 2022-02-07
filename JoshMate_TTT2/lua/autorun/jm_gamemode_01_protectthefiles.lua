-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end


function JM_GameMode_Start_ProtectTheFiles()

    if CLIENT then return end

    JM_Function_Announcement("New Objective: Traitors must destroy the Files! Innocents must protect them!", 0)
    JM_Function_PlaySound("effect_objective_start.wav")

    local NumberToSpawn = 5
    local possibleSpawns = ents.FindByClass( "ent_jm_carepackage_spawn" )
    
    for i=1,NumberToSpawn do 

        if #possibleSpawns > 0 then
            local randomChoice = math.random(1, #possibleSpawns)
            local spawn = possibleSpawns[randomChoice]
            table.remove( possibleSpawns, randomChoice )
            
            local ent = ents.Create("ent_jm_objective_01_file")
            ent:SetPos(spawn:GetPos() + Vector(0, 0, 14))
            ent:Spawn()  
        end

    end

end