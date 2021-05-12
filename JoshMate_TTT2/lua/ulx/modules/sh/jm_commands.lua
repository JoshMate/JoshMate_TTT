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
-- ## Reset Played Maps ####
-- #########################

function ulx.resetmaplist(calling_ply)
    PrintMessage(HUD_PRINTTALK, calling_ply:Nick() .. " resets the list of played maps.")
    ConfigHelper:WritePlayedMaps({}) 
end

local cmdResetMapList = ulx.command(CATEGORY_NAME, "resetmaplist", ulx.resetmaplist, "!resetmaplist")
cmdResetMapList:defaultAccess(ULib.ACCESS_ADMIN)


-- #########################
-- ####  Reset All Karma ###
-- #########################

function ulx.karma(calling_ply)

	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else

        local plys = player.GetAll()

        for i = 1, #plys do
            local ply = plys[i]
            ply:SetBaseKarma(1000)
			ply:SetLiveKarma(1000)			
		end

	end

	ulx.fancyLogAdmin(calling_ply, "#A reset everyones KARMA")
end

local karma = ulx.command(CATEGORY_NAME, "karmatotalreset", ulx.karma, "!karmatotalreset")
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Resets All KARMA")

-- #########################
-- ###  Karma Punish 250 ###
-- #########################

function ulx.karma(calling_ply, target_plys)
    
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		for i = 1, #target_plys do
            local pl = target_plys[i]
            plKarma = pl:GetLiveKarma() - 250

            plKarma = math.Clamp(plKarma, 0, 1000)

			pl:SetBaseKarma(plKarma)
			pl:SetLiveKarma(plKarma)
		end
	end

	ulx.fancyLogAdmin(calling_ply, "#A punished #T for #i KARMA", target_plys, 250)
end

local karma = ulx.command(CATEGORY_NAME, "karmapunish250", ulx.karma, "!karmapunish250")
karma:addParam{type = ULib.cmds.PlayersArg}
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Take away 250 KARMA")

-- #########################
-- ###  Karma Punish 500 ###
-- #########################

function ulx.karma(calling_ply, target_plys)
    
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		for i = 1, #target_plys do
            local pl = target_plys[i]
            plKarma = pl:GetLiveKarma() - 500

            plKarma = math.Clamp(plKarma, 0, 1000)

			pl:SetBaseKarma(plKarma)
			pl:SetLiveKarma(plKarma)
		end
	end

	ulx.fancyLogAdmin(calling_ply, "#A punished #T for #i KARMA", target_plys, 500)
end

local karma = ulx.command(CATEGORY_NAME, "karmapunish500", ulx.karma, "!karmapunish500")
karma:addParam{type = ULib.cmds.PlayersArg}
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Take away 500 KARMA")

-- #########################
-- ####  Slay All Players ##
-- #########################

function ulx.karma(calling_ply)

    local plys = player.GetAll()

    for i = 1, #plys do
        local ply = plys[i]
        ply:Kill()			
    end

	ulx.fancyLogAdmin(calling_ply, "#A Slayed EVERYONE")
end

local karma = ulx.command(CATEGORY_NAME, "slayeveryone", ulx.karma, "!slayeveryone")
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Slays Everyone")