-- Give these files out
AddCSLuaFile()


-- Gathers data and numbers for actions in TTT
if engine.ActiveGamemode() ~= "terrortown" then return end
if CLIENT then return end

local nameOfMetricsDir              = "joshmate_metrics"
local nameOfMetricsFile             = "jm_ttt_metrics.txt"
local nameOfMetricsFileCombined     = nameOfMetricsDir .. "/" .. nameOfMetricsFile
metricsTable                  = {
    mapRoundsPlayed         = {},
    detectiveShopPurchases  = {},
    traitorShopPurchases    = {},
    goombaScores            = {},
    goombaCounts            = {},
    carePackages            = {},
    roundWins               = {},
    karmaLost               = {},
    roundsPlayed            = {}
}

function Metrics_Init()

    if file.Exists( nameOfMetricsDir, "DATA" ) then
        Metrics_ReadMetricsFromFile()

    else
        file.CreateDir(nameOfMetricsDir)
        Metrics_WriteMetricsToFile()
    end

end

function Metrics_Print()
    Metrics_SortMetricsTable()
    print("###########################################")
    print("###### Josh Mate TTT Metrics Table:")
    print("###########################################")
    print(util.TableToJSON(metricsTable, true))
    print("###########################################")

end

function Metrics_WriteMetricsToFile()
    Metrics_SortMetricsTable()
	local converted = util.TableToJSON(metricsTable, true)
	file.Write(nameOfMetricsFileCombined, converted)
end

function Metrics_ReadMetricsFromFile()
	local JSONData = file.Read(nameOfMetricsFileCombined)
	metricsTable = util.JSONToTable(JSONData)
end

function Metrics_SortMetricsTable()
    table.sort(metricsTable)
end

function Metrics_Event_MapNewRound(nameOfCurrentMap)

    -- Patch this table into existing data file
    if  metricsTable.mapRoundsPlayed == nil then 
        metricsTable.mapRoundsPlayed = {}
    end
    -- End of patch
    
    -- Check if the map name exists, then add it in if not
    if  metricsTable.mapRoundsPlayed[nameOfCurrentMap] == nil then 
        metricsTable.mapRoundsPlayed[nameOfCurrentMap] = 0
    end

    -- Add 1 played round to that map in metrics data
    metricsTable.mapRoundsPlayed[nameOfCurrentMap] = metricsTable.mapRoundsPlayed[nameOfCurrentMap] + 1

    -- Write updated Metrics to file
    Metrics_WriteMetricsToFile()
end

function Metrics_Event_Win_Traitor()

    -- Patch this table into existing data file
    if  metricsTable.roundWins == nil then 
        metricsTable.roundWins = {}
    end
    -- End of patch

    -- Check if the map name exists, then add it in if not
    if  metricsTable.roundWins["Traitor"] == nil then 
        metricsTable.roundWins["Traitor"] = 0
    end

    -- Add 1 to victory counter
    metricsTable.roundWins["Traitor"] = metricsTable.roundWins["Traitor"] + 1

    -- Write updated Metrics to file
    Metrics_WriteMetricsToFile()
end

function Metrics_Event_Win_Innocent()

    -- Patch this table into existing data file
    if  metricsTable.roundWins == nil then 
        metricsTable.roundWins = {}
    end
    -- End of patch

    -- Check if the map name exists, then add it in if not
    if  metricsTable.roundWins["Innocent"] == nil then 
        metricsTable.roundWins["Innocent"] = 0
    end

    -- Add 1 to victory counter
    metricsTable.roundWins["Innocent"] = metricsTable.roundWins["Innocent"] + 1

    -- Write updated Metrics to file
    Metrics_WriteMetricsToFile()
end

function Metrics_Event_ShopPurchase_Traitor(nameOfItemPurchased)

    -- Patch this table into existing data file
    if  metricsTable.traitorShopPurchases == nil then 
        metricsTable.traitorShopPurchases = {}
    end
    -- End of patch
    
    -- Check if the map name exists, then add it in if not
    if  metricsTable.traitorShopPurchases[nameOfItemPurchased] == nil then 
        metricsTable.traitorShopPurchases[nameOfItemPurchased] = 0
    end

    -- Add 1 played round to that map in metrics data
    metricsTable.traitorShopPurchases[nameOfItemPurchased] = metricsTable.traitorShopPurchases[nameOfItemPurchased] + 1

    -- Write updated Metrics to file
    Metrics_WriteMetricsToFile()
end

function Metrics_Event_ShopPurchase_Detective(nameOfItemPurchased)

    -- Patch this table into existing data file
    if  metricsTable.detectiveShopPurchases == nil then 
        metricsTable.detectiveShopPurchases = {}
    end
    -- End of patch
    
    -- Check if the map name exists, then add it in if not
    if  metricsTable.detectiveShopPurchases[nameOfItemPurchased] == nil then 
        metricsTable.detectiveShopPurchases[nameOfItemPurchased] = 0
    end

    -- Add 1 played round to that map in metrics data
    metricsTable.detectiveShopPurchases[nameOfItemPurchased] = metricsTable.detectiveShopPurchases[nameOfItemPurchased] + 1

    -- Write updated Metrics to file
    Metrics_WriteMetricsToFile()
end

function Metrics_Event_Goomba(nameOfPlayer, amountOfDamage)

    -- Patch this table into existing data file
    if  metricsTable.goombaCounts == nil then 
        metricsTable.goombaCounts = {}
    end
    -- End of patch

    local roundedDamage = math.ceil(amountOfDamage)

    -- Add Goomba Counts

    -- Check if the map name exists, then add it in if not
    if  metricsTable.goombaCounts[nameOfPlayer] == nil then 
        metricsTable.goombaCounts[nameOfPlayer] = 0
    end

    -- Add 1
    metricsTable.goombaCounts[nameOfPlayer] = metricsTable.goombaCounts[nameOfPlayer] + 1

    -- Update Goomba Scores

    -- Patch this table into existing data file
    if  metricsTable.goombaScores == nil then 
        metricsTable.goombaScores = {}
    end
    -- End of patch

    -- Check if the map name exists, then add it in if not
    if  metricsTable.goombaScores[nameOfPlayer] == nil then 
        metricsTable.goombaScores[nameOfPlayer] = 0
    end

    if roundedDamage > metricsTable.goombaScores[nameOfPlayer] then
        metricsTable.goombaScores[nameOfPlayer] = roundedDamage
    end


    -- Write updated Metrics to file
    Metrics_WriteMetricsToFile()

end

function Metrics_Event_CarePackage(Player)

    -- Patch this table into existing data file
    if  metricsTable.carePackages == nil then 
        metricsTable.carePackages = {}
    end
    -- End of patch
    
    local plyNick = Player:Nick()

    -- Check if the map name exists, then add it in if not
    if  metricsTable.carePackages[plyNick] == nil then 
        metricsTable.carePackages[plyNick] = 0
    end

    -- Add 1 played round to that map in metrics data
    metricsTable.carePackages[plyNick] = metricsTable.carePackages[plyNick] + 1

    -- Write updated Metrics to file
    Metrics_WriteMetricsToFile()
end

function Metrics_Event_KarmaLost(namePlayer, karmaLost)

    -- Patch this table into existing data file
    if  metricsTable.karmaLost == nil then 
        metricsTable.karmaLost = {}
    end
    -- End of patch
    
    -- Check if the map name exists, then add it in if not
    if  metricsTable.karmaLost[namePlayer] == nil then 
        metricsTable.karmaLost[namePlayer] = 0
    end

    -- Add 1 played round to that map in metrics data
    metricsTable.karmaLost[namePlayer] = metricsTable.karmaLost[namePlayer] + math.ceil(karmaLost) 

    -- Write updated Metrics to file
    Metrics_WriteMetricsToFile()
end

function Metrics_Event_RoundsPlayed()

    -- Patch this table into existing data file
    if  metricsTable.roundsPlayed == nil then 
        metricsTable.roundsPlayed = {}
    end
    -- End of patch

    local plys = player.GetAll()    
    for i = 1, #plys do

        local ply = plys[i]
        local namePlayer = ply:Nick()
        if namePlayer == nil then continue end
        -- Check if the map name exists, then add it in if not
        if  metricsTable.roundsPlayed[namePlayer] == nil then 
            metricsTable.roundsPlayed[namePlayer] = 0
        end

        -- Add 1 played round to that map in metrics data
        metricsTable.roundsPlayed[namePlayer] = metricsTable.roundsPlayed[namePlayer] + 1

    end
    
    -- Write updated Metrics to file
    Metrics_WriteMetricsToFile()
end

-- Initialise Metrics
Metrics_Init()

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Gameplay Hooks to Trigger Metric Gathering
------------------------------------------------------------------------------
------------------------------------------------------------------------------

hook.Add("TTTEndRound", "JM_MetricsHook_EndOfRound", function(result)

    Metrics_Event_MapNewRound(game.GetMap())
    Metrics_Event_RoundsPlayed()

    -- Depending on who won, update metrics
    if tostring(result) == "traitors" then
        Metrics_Event_Win_Traitor()
    elseif tostring(result) == "innocents" then
        Metrics_Event_Win_Innocent()
    end

end)

hook.Add("TTTOrderedEquipment", "JM_MetricsHook_ShopPurchase", function(ply, id, isItem)

    if ply:IsTraitor() then
        Metrics_Event_ShopPurchase_Traitor(id)
    else
        Metrics_Event_ShopPurchase_Detective(id)
    end

end)
