-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end


function JM_GameMode_Start_DefuseTheBombs()

    if CLIENT then return end

    -- Bomb Handler
    local bombHandler = ents.Create("ent_jm_objective_02_bomb_sub")
    bombHandler:Spawn()
    -- End of Bomb Handler

end