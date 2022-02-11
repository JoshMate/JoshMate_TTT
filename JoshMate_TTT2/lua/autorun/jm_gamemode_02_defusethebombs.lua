-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end


function JM_GameMode_Start_DefuseTheBombs()

    if CLIENT then return end

    JM_Function_Announcement("New Objective: Innocents you have 60 seconds to defuse 3 Bombs!", 0)
    JM_Function_PlaySound("gamemode/bomb_started.wav")

    JM_GameMode_Function_SpawnThisThingRandomly("ent_jm_objective_02_bomb", 3)

end