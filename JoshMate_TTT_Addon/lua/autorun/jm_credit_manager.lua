-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end
if CLIENT then return end

local creditScoreTraitorKills = 0


function JM_CreditsGiveAllDetectivesCredit(reason)

    local plys = player.GetAll()    
    for i = 1, #plys do

        local ply = plys[i]

        if(IsValid(ply) and ply:Alive() and ply:IsTerror() and ply:IsDetective()) then
            ply:AddCredits(1)
            JM_Function_PrintChat(ply, "Credits", "You recieve 1 Credit for: " .. tostring(reason) )
        end
    end
end

function JM_CreditsGiveAllTraitorsCredit(reason)

    local plys = player.GetAll()    
    for i = 1, #plys do

        local ply = plys[i]

        if(IsValid(ply) and ply:Alive() and ply:IsTerror() and ply:IsTraitor()) then
            ply:AddCredits(1)
            JM_Function_PrintChat(ply, "Credits", "You recieve 1 Credit for: " .. tostring(reason) )
        end
    end
end

-- HOOKS


hook.Add("TTTBeginRound", "JM_Credits_ForSurvival", function()

    creditScoreTraitorKills = 0

    timer.Create( "JM_Timer_Detective_Credits", 60, 3, function() JM_CreditsGiveAllDetectivesCredit("Surviving.") end )
    timer.Create( "JM_Timer_Traitor_Credits", 60, 2, function() JM_CreditsGiveAllTraitorsCredit("Surviving.") end )

end)

hook.Add( "PlayerDeath", "JM_Credits_ForDeaths", function( victim, inflictor, attacker )

    if victim:IsDetective() then JM_CreditsGiveAllTraitorsCredit("Killing a Detective.") end
    if victim:IsTraitor() then JM_CreditsGiveAllDetectivesCredit("Killing a Traitor.") end

    if not victim:IsTraitor() and not victim:IsDetective() then
        creditScoreTraitorKills = creditScoreTraitorKills + 1
    end

    if creditScoreTraitorKills >= 2 then
        creditScoreTraitorKills = 0
        JM_CreditsGiveAllTraitorsCredit("Killing 2 more Innocents.")
    end

    
end )