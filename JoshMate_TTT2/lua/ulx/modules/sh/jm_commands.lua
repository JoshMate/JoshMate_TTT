-- Give these files out
AddCSLuaFile()


local CATEGORY_NAME_JM_Karma 		= "JM Karma"
local CATEGORY_NAME_JM_Maps 		= "JM Maps"
local CATEGORY_NAME_JM_Fun 			= "JM Fun"
local CATEGORY_NAME_JM_Tool 		= "JM Tools"
local CATEGORY_NAME_JM_Event 		= "JM Events"

-- ##################################################
-- ### Spawn Care Package
-- ##################################################

local cmdSpawnCarePackage = ulx.command(CATEGORY_NAME_JM_Fun, "jm carepackage", function () JMGlobal_SpawnCarePackage(1) end, "!spawncarepackage")
cmdSpawnCarePackage:defaultAccess(ULib.ACCESS_ADMIN)

-- ##################################################
-- ### Spawn Emergency Airdrop
-- ##################################################

local cmdEmergencyAirdrop = ulx.command(CATEGORY_NAME_JM_Fun, "jm emergencyairdrop", function () JMGlobal_SpawnCarePackage(2) end, "!spawnemergencyairdrop")
cmdEmergencyAirdrop:defaultAccess(ULib.ACCESS_ADMIN)

-- #########################
-- #####  Spawn Item #####
-- #########################

function ulx.spawnthing( calling_ply, message )

	local ent = ents.Create(message)
	if ent:IsValid() then
		ent:SetPos(calling_ply:GetPos())
		ent:Spawn()
	end

end

local spawnthis = ulx.command( CATEGORY_NAME_JM_Fun, "jm give", ulx.spawnthing, "!spawnthis")
spawnthis:addParam{ type=ULib.cmds.StringArg, hint="", ULib.cmds.takeRestOfLine }
spawnthis:defaultAccess( ULib.ACCESS_ADMIN )
spawnthis:help( "Spawns the given entity name: eg. weapon_jm_zloot_prop_launcher" )

-- #########################
-- #####  Spawn Item All ###
-- #########################

function ulx.spawnthing( calling_ply, message )

	JM_Function_Announcement("Giving Everyone: " .. tostring(message), 0)

	local plys = player.GetAll()

	for i = 1, #plys do
		local ply = plys[i]
		if ply:IsValid() and ply:Alive() and ply:IsTerror() then 
			local ent = ents.Create(message)
			if ent:IsValid() then
				ent:SetPos(ply:GetPos())
				ent:Spawn()
			end
		end
	end

	

end

local spawnthis = ulx.command( CATEGORY_NAME_JM_Fun, "jm give all", ulx.spawnthing, "!spawnthisforall")
spawnthis:addParam{ type=ULib.cmds.StringArg, hint="", ULib.cmds.takeRestOfLine }
spawnthis:defaultAccess( ULib.ACCESS_ADMIN )
spawnthis:help( "Spawns the given entity name for everyone: eg. weapon_jm_zloot_prop_launcher" )

-- #########################
-- ######## Mapvote ########
-- #########################
function ulx.mapvote(calling_ply, time, isOppositeCmd)
    if isOppositeCmd then MapVote:Stop() else MapVote:Start(time) end
end

local cmdMapvote = ulx.command(CATEGORY_NAME_JM_Maps, "jm map vote", ulx.mapvote, "!mapvote")
cmdMapvote:addParam{ type=ULib.cmds.NumArg, min=10, default=30, max=60, ULib.cmds.optional, hint="Votetime" } -- time param
cmdMapvote:addParam{ type=ULib.cmds.BoolArg, invisible=true } -- isOppositeCmd param
cmdMapvote:defaultAccess(ULib.ACCESS_ADMIN)
cmdMapvote:setOpposite("jm mapvote end", {_, _, true}, "!unmapvote")


-- #########################
-- ## Reset Played Maps ####
-- #########################

function ulx.resetmaplist(calling_ply)
    PrintMessage(HUD_PRINTTALK, calling_ply:Nick() .. " resets the list of played maps.")
    ConfigHelper:WritePlayedMaps({}) 
end

local cmdResetMapList = ulx.command(CATEGORY_NAME_JM_Maps, "jm map resetlist", ulx.resetmaplist, "!resetmaplist")
cmdResetMapList:defaultAccess(ULib.ACCESS_ADMIN)


-- #########################
-- ####  Reset All Karma ###
-- #########################

function ulx.karmatotalreset(calling_ply)

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

local karma = ulx.command(CATEGORY_NAME_JM_Karma, "jm karma reset all", ulx.karmatotalreset, "!karmatotalreset")
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Resets All KARMA")

-- #########################
-- ###  Karma Punish 250 ###
-- #########################

function ulx.karmapunish250(calling_ply, target_plys)
    
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

local karma = ulx.command(CATEGORY_NAME_JM_Karma, "jm karma punish 250", ulx.karmapunish250, "!karmapunish250")
karma:addParam{type = ULib.cmds.PlayersArg}
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Take away 250 KARMA")

-- #########################
-- ###  Karma Punish 500 ###
-- #########################

function ulx.karmapunish500(calling_ply, target_plys)
    
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

local karma = ulx.command(CATEGORY_NAME_JM_Karma, "jm karma punish 500", ulx.karmapunish500, "!karmapunish500")
karma:addParam{type = ULib.cmds.PlayersArg}
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Take away 500 KARMA")

-- #########################
-- ###  Karma Set 1000 ###
-- #########################

function ulx.karmaset1000(calling_ply, target_plys)
    
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		for i = 1, #target_plys do
            local pl = target_plys[i]
            pl:SetBaseKarma(1000)
			pl:SetLiveKarma(1000)			
		end
	end

	ulx.fancyLogAdmin(calling_ply, "#A set #T to #i KARMA", target_plys, 1000)
end

local karma = ulx.command(CATEGORY_NAME_JM_Karma, "jm karma reset 1000", ulx.karmaset1000, "!karmaset1000")
karma:addParam{type = ULib.cmds.PlayersArg}
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Sets KARMA to 1000")

-- #########################
-- ###  Karma Set 1250 ###
-- #########################

function ulx.karmaset1250(calling_ply, target_plys)
    
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		for i = 1, #target_plys do
            local pl = target_plys[i]
            pl:SetBaseKarma(1250)
			pl:SetLiveKarma(1250)			
		end
	end

	ulx.fancyLogAdmin(calling_ply, "#A set #T to #i KARMA", target_plys, 1250)
end

local karma = ulx.command(CATEGORY_NAME_JM_Karma, "jm karma reset 1250", ulx.karmaset1250, "!karmaset1250")
karma:addParam{type = ULib.cmds.PlayersArg}
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Sets KARMA to 1250")

-- #########################
-- ####  Slay All Players ##
-- #########################

function ulx.slayeveryone(calling_ply)

    local plys = player.GetAll()

    for i = 1, #plys do
        local ply = plys[i]
        ply:Kill()			
    end

	ulx.fancyLogAdmin(calling_ply, "#A Slayed EVERYONE")
end

local karma = ulx.command(CATEGORY_NAME_JM_Fun, "jm x slayall", ulx.slayeveryone, "!slayeveryone")
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Slays Everyone")

-- #########################
-- #####  Announcement #####
-- #########################

function ulx.announcement( calling_ply, message )

	JM_Function_Announcement(message, 0)

end

local announce = ulx.command( CATEGORY_NAME_JM_Tool, "jm announcement", ulx.announcement, "!announcement")
announce:addParam{ type=ULib.cmds.StringArg, hint="", ULib.cmds.takeRestOfLine }
announce:defaultAccess( ULib.ACCESS_ADMIN )
announce:help( "Sends a message to everyone" )

-- #########################
-- #####  Play Sound   #####
-- #########################

function ulx.playsound( calling_ply, message )

	JM_Function_PlaySound(message)

end

local playsounds = ulx.command( CATEGORY_NAME_JM_Tool, "jm playsound", ulx.playsound, "!playsound")
playsounds:addParam{ type=ULib.cmds.StringArg, hint="", ULib.cmds.takeRestOfLine }
playsounds:defaultAccess( ULib.ACCESS_ADMIN )
playsounds:help( "Play a client side sound on all players. Eg: ping_jake.wav" )

-- #########################
-- ##  Protect The Server ##
-- #########################

function ulx.protectthefilesfunction( calling_ply)

	JM_GameMode_Start_ProtectTheFiles()

end

local protectthefiles = ulx.command( CATEGORY_NAME_JM_Event, "jm protectthefiles", ulx.protectthefilesfunction, "!protectthefiles")
protectthefiles:defaultAccess( ULib.ACCESS_ADMIN )
protectthefiles:help( "Starts the Gamemode: Protect the Files" )

-- #########################
-- ##  Defuse the Bombs  ##
-- #########################

function ulx.defusethebombsfunction( calling_ply)

	JM_GameMode_Start_DefuseTheBombs()

end

local defusethebombs = ulx.command( CATEGORY_NAME_JM_Event, "jm defusethebombs", ulx.defusethebombsfunction, "!defusethebombs")
defusethebombs:defaultAccess( ULib.ACCESS_ADMIN )
defusethebombs:help( "Starts the Gamemode: Protect the Bombs" )

-- #########################
-- #####  Sudden Death #####
-- #########################

function ulx.suddendeath( calling_ply)

	net.Start("JM_Net_Announcement")
    net.WriteString("Sudden Death!")
    net.Broadcast()

	JM_Function_PlaySound("0_main_suddendeath.mp3")

end

local suddendeath = ulx.command( CATEGORY_NAME_JM_Event, "jm suddendeath", ulx.suddendeath, "!suddendeath")
suddendeath:defaultAccess( ULib.ACCESS_ADMIN )
suddendeath:help( "Starts Sudden Death" )

-- #########################
-- #####  Track Everyone #####
-- #########################

function ulx.trackall( calling_ply)

	net.Start("JM_Net_Announcement")
    net.WriteString("Everyone is now Tracked!")
    net.Broadcast()

	JM_Function_PlaySound("ping_jake.wav")

	local plys = player.GetAll()

	for i = 1, #plys do
		local ply = plys[i]
		if ply:IsValid() and ply:Alive() and ply:IsTerror() then 
			JM_RemoveBuffFromThisPlayer("jm_buff_suddendeath",ply)
			JM_GiveBuffToThisPlayer("jm_buff_suddendeath",ply,ply)	
		end
	end


end

local trackall = ulx.command( CATEGORY_NAME_JM_Event, "jm trackall", ulx.trackall, "!trackall")
trackall:defaultAccess( ULib.ACCESS_ADMIN )
trackall:help( "Starts Sudden Death" )

-- #########################
-- ####  Turn On Proxy Voice ###
-- #########################

function ulx.enableproxyvoice(calling_ply)

	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else

		local ConVarProxy_State = GetConVar("ttt_locational_voice")
		local ConVarProxy_Range = GetConVar("ttt_locational_voice_distance")

		if ConVarProxy_State:GetBool() == 0 or ConVarProxy_State:GetBool() == false then

			ConVarProxy_State:SetBool( true )

		else

			ConVarProxy_State:SetBool( false )

		end

		ConVarProxy_State = GetConVar("ttt_locational_voice")
		ConVarProxy_Range = GetConVar("ttt_locational_voice_distance")


		local ConVarProxy_State_Text = "Enabled"

		if ConVarProxy_State:GetBool() == false then
			ConVarProxy_State_Text = "Disabled"
		end

		local ConVarProxy_Range_Text = ConVarProxy_Range:GetInt()

        net.Start("JM_Net_Announcement")
		net.WriteString("Proximity Voice: " .. tostring(ConVarProxy_State_Text) .. " - (Range: " .. tostring(ConVarProxy_Range_Text) .. " Units)")
		net.Broadcast()

		JM_Function_PlaySound("0_proximity_voice_toggle.wav")

	end

	ulx.fancyLogAdmin(calling_ply, "#A has enabled: Proximity Voice")
end

local karma = ulx.command(CATEGORY_NAME_JM_Event, "jm proxyvoice enable", ulx.enableproxyvoice, "!enableproxyvoice")
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Enables Proxy Voice until the next map")


-- ##################################################
-- ### Reset Server Convars
-- ##################################################

local cmdResetServerCvars = ulx.command(CATEGORY_NAME_JM_Tool, "jm resetservercvars", function () JM_ResetAllSettings() end, "!resetservercvars")
cmdResetServerCvars:defaultAccess(ULib.ACCESS_ADMIN)

-- ##################################################
-- ### Add Rounds
-- ##################################################

local function JM_ULX_Round_Add()

	local curRounds = GetGlobalInt("ttt_rounds_left", 6)
	curRounds = curRounds + 1
	
	SetGlobalInt("ttt_rounds_left",curRounds)

	GAMEMODE:SyncGlobals()
end

local cmdRoundAdd = ulx.command(CATEGORY_NAME_JM_Maps, "jm round add", function () JM_ULX_Round_Add()  end, "!roundadd")
cmdRoundAdd:defaultAccess(ULib.ACCESS_ADMIN)

-- ##################################################
-- ### Take away Rounds
-- ##################################################

local function JM_ULX_Round_Remove()

	local curRounds = GetGlobalInt("ttt_rounds_left", 6)
	curRounds = curRounds - 1
	
	SetGlobalInt("ttt_rounds_left",curRounds)

	GAMEMODE:SyncGlobals()
end

local cmdRoundRemove = ulx.command(CATEGORY_NAME_JM_Maps, "jm round remove", function () JM_ULX_Round_Remove() end, "!roundremove")
cmdRoundRemove:defaultAccess(ULib.ACCESS_ADMIN)

