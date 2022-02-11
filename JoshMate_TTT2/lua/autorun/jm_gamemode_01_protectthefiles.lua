-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end


function JM_GameMode_Start_ProtectTheFiles()

    if CLIENT then return end

    JM_Function_Announcement("New Objective: Innocents must protect the files!", 0)
    JM_Function_PlaySound("effect_objective_start.wav")

    JM_GameMode_Function_SpawnThisThingRandomly("ent_jm_objective_01_file", 5)

end