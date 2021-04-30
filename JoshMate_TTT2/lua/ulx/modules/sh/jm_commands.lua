local CATEGORY_NAME = "JoshMate"

-- ##################################################
-- ### Spawn Care Package
-- ##################################################

local cmdSpawnCarePackage = ulx.command(CATEGORY_NAME, "spawncarepackage", function () JMGlobal_SpawnCarePackage(true) end, "!spawncarepackage")
cmdSpawnCarePackage:defaultAccess(ULib.ACCESS_ADMIN)

-- #########################
-- ######## Mapvote ########
-- #########################
function ulx.mapvote(calling_ply, time, isOppositeCmd)
    if isOppositeCmd then MapVote:Stop() else MapVote:Start(time) end
end

local cmdMapvote = ulx.command(CATEGORY_NAME, "mapvote", ulx.mapvote, "!mapvote")
cmdMapvote:addParam{ type=ULib.cmds.NumArg, min=15, default=20, max=60, ULib.cmds.optional, hint="Votetime" } -- time param
cmdMapvote:addParam{ type=ULib.cmds.BoolArg, invisible=true } -- isOppositeCmd param
cmdMapvote:defaultAccess(ULib.ACCESS_ADMIN)
cmdMapvote:setOpposite("unmapvote", {_, _, true}, "!unmapvote")

-- #########################
-- ####### RTV reset #######
-- #########################
function ulx.rtvreset(calling_ply)
    PrintMessage(HUD_PRINTTALK, calling_ply:Nick() .. " resets the RTV.")
    RTV:Reset()
end

local cmdRtv = ulx.command(CATEGORY_NAME, "resetrtv", ulx.rtvreset, "!resetrtv")
cmdRtv:defaultAccess(ULib.ACCESS_ADMIN)


-- #########################
-- ##Reset Played Maps #####
-- #########################

function ulx.resetmaplist(calling_ply)
    PrintMessage(HUD_PRINTTALK, calling_ply:Nick() .. " resets the list of played maps.")
    ConfigHelper:WritePlayedMaps({}) 
end

local cmdResetMapList = ulx.command(CATEGORY_NAME, "resetmaplist", ulx.resetmaplist, "!resetmaplist")
cmdResetMapList:defaultAccess(ULib.ACCESS_ADMIN)