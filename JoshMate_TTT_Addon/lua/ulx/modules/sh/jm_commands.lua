-- Give these files out
AddCSLuaFile()


local CATEGORY_NAME_JM_Karma 		= "JM Karma"
local CATEGORY_NAME_JM_Maps 		= "JM Maps"
local CATEGORY_NAME_JM_Fun 			= "JM Fun"
local CATEGORY_NAME_JM_Tool 		= "JM Tools"
local CATEGORY_NAME_JM_Events 		= "JM Events"

--[Ulx Completes]------------------------------------------------------------------------------
ulx.possibleGamemodes = {}
function updateGamModes()
	table.Empty( ulx.possibleGamemodes )
    table.insert(ulx.possibleGamemodes,"Defuse The Bombs")
    table.insert(ulx.possibleGamemodes,"Powerup")
    table.insert(ulx.possibleGamemodes,"Stash")
	table.insert(ulx.possibleGamemodes,"Grab The Files")
    table.insert(ulx.possibleGamemodes,"Bounty Hunter")
    table.insert(ulx.possibleGamemodes,"Infection")
	table.insert(ulx.possibleGamemodes,"Low Ammo Round")
    table.insert(ulx.possibleGamemodes,"Pistol Round")
    table.insert(ulx.possibleGamemodes,"Traitor Tester")
	table.insert(ulx.possibleGamemodes,"Power Hour")
	table.insert(ulx.possibleGamemodes,"Low Gravity")
	table.insert(ulx.possibleGamemodes,"Slippery Floors")
	table.insert(ulx.possibleGamemodes,"Crowbar Man Mode")
end
hook.Add( ULib.HOOK_UCLCHANGED, "ULXupdateGamModes", updateGamModes )
updateGamModes()
--[End]----------------------------------------------------------------------------------------

-- ##################################################
-- ### Run this Function
-- ##################################################

function ulx.JM_ULX_RunFunction(calling_ply, message)
	RunString(message)
end

local cmdRunFunction = ulx.command(CATEGORY_NAME_JM_Tool, "jm runfunction", ulx.JM_ULX_RunFunction, "!runfunction")
cmdRunFunction:addParam{ type=ULib.cmds.StringArg, hint="", ULib.cmds.takeRestOfLine }
cmdRunFunction:defaultAccess(ULib.ACCESS_ADMIN)


-- ##################################################
-- ### Spawn Care Package
-- ##################################################

local cmdSpawnCarePackage = ulx.command(CATEGORY_NAME_JM_Events, "jm carepackage", function () JMGlobal_SpawnCarePackage(1) end, "!spawncarepackage")
cmdSpawnCarePackage:defaultAccess(ULib.ACCESS_ADMIN)

-- ##################################################
-- ### Spawn Emergency Airdrop
-- ##################################################

local cmdEmergencyAirdrop = ulx.command(CATEGORY_NAME_JM_Events, "jm emergencyairdrop", function () JMGlobal_SpawnCarePackage(2) end, "!spawnemergencyairdrop")
cmdEmergencyAirdrop:defaultAccess(ULib.ACCESS_ADMIN)

-- #########################
-- #####  Spawn Item #####
-- #########################

function ulx.spawnthing( calling_ply, message )

	local ent = ents.Create(message)
	if ent:IsValid() then
		ent:SetPos(calling_ply:GetPos())
		ent:Spawn()
		JM_Function_PrintChat_All("Admin", tostring(calling_ply:Nick()) .. " Spawned: " .. tostring(message))	
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

	JM_Function_PrintChat_All("Admin", tostring(calling_ply:Nick()) .. " Gave Everyone: " .. tostring(message))

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
	JM_Function_PrintChat_All("Map", "Manually starting a Map Vote")
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
    JM_Function_PrintChat_All("Map", "The list of votable maps has been reset")	
    ConfigHelper:WritePlayedMaps({}) 
end

local cmdResetMapList = ulx.command(CATEGORY_NAME_JM_Maps, "jm map reset", ulx.resetmaplist, "!resetmaplist")
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
			ply:SetNWBool("JM_NWBOOL_IsSittingRoundOut", false)	
		end
		JM_Function_PrintChat_All("Karma", "EVERYONE has been reset to 1000 Karma")	
	end
end

local karma = ulx.command(CATEGORY_NAME_JM_Karma, "jm karma reset all", ulx.karmatotalreset, "!karmatotalreset")
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Resets All KARMA")

-- ###########################
-- ###  Karma Punish Minor ###
-- ###########################

function ulx.karmapunishminor(calling_ply, target_plys)
    
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		for i = 1, #target_plys do
            local pl = target_plys[i]
            plKarma = pl:GetLiveKarma() - 300

            plKarma = math.Clamp(plKarma, -9999, 1000)

			pl:SetBaseKarma(plKarma)
			pl:SetLiveKarma(plKarma)
			JM_Function_PrintChat_All("Karma", tostring(pl:Nick()) .. " lost 300 Karma for breaking the rules (Minor)")
		end
	end
end

local karma = ulx.command(CATEGORY_NAME_JM_Karma, "jm karma punish minor", ulx.karmapunishminor, "!karmapunishminor")
karma:addParam{type = ULib.cmds.PlayersArg}
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Take away 300 KARMA")

-- #########################
-- ###  Karma Punish RDM ###
-- #########################

function ulx.karmapunishmajor(calling_ply, target_plys)
    
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		for i = 1, #target_plys do
            local pl = target_plys[i]
            plKarma = pl:GetLiveKarma() - 700

            plKarma = math.Clamp(plKarma, -9999, 1000)

			pl:SetBaseKarma(plKarma)
			pl:SetLiveKarma(plKarma)
			JM_Function_PrintChat_All("Karma", tostring(pl:Nick()) .. " lost 700 Karma for RDMing (Major)")
		end
	end
end

local karma = ulx.command(CATEGORY_NAME_JM_Karma, "jm karma punish rdm", ulx.karmapunishmajor, "!karmapunishmajor")
karma:addParam{type = ULib.cmds.PlayersArg}
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Take away 700 KARMA")

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
			pl:SetNWBool("JM_NWBOOL_IsSittingRoundOut", false)
			JM_Function_PrintChat_All("Karma", tostring(pl:Nick()) .. " has been reset to 1000 Karma")
		end			
	end
		
end

local karma = ulx.command(CATEGORY_NAME_JM_Karma, "jm karma reset 1000", ulx.karmaset1000, "!karmaset1000")
karma:addParam{type = ULib.cmds.PlayersArg}
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Sets KARMA to 1000")

-- #########################
-- ###  Karma Set 1300 ###
-- #########################

function ulx.karmaset1300(calling_ply, target_plys)
    
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		for i = 1, #target_plys do
            local pl = target_plys[i]
            pl:SetBaseKarma(1300)
			pl:SetLiveKarma(1300)	
			pl:SetNWBool("JM_NWBOOL_IsSittingRoundOut", false)
			JM_Function_PrintChat_All("Karma", tostring(pl:Nick()) .. " has been reset to 1300 Karma")		
		end
	end
end

local karma = ulx.command(CATEGORY_NAME_JM_Karma, "jm karma reset 1300", ulx.karmaset1300, "!karmaset1300")
karma:addParam{type = ULib.cmds.PlayersArg}
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Sets KARMA to 1300")

-- #########################
-- ####  Slay All Players ##
-- #########################

function ulx.slayeveryone(calling_ply)

    local plys = player.GetAll()

    for i = 1, #plys do
        local ply = plys[i]
        ply:Kill()			
    end

	JM_Function_PrintChat_All("Admin", "EVERYONE has been Slain")	
end

local karma = ulx.command(CATEGORY_NAME_JM_Fun, "jm slayall", ulx.slayeveryone, "!slayeveryone")
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
-- #####  Sudden Death #####
-- #########################

function ulx.suddendeath( calling_ply)

	JM_Function_Announcement("[Game Mode] Sudden Death!") 
	JM_Function_PlaySound("0_main_suddendeath.mp3")

end

local suddendeath = ulx.command( CATEGORY_NAME_JM_Events, "jm suddendeath", ulx.suddendeath, "!suddendeath")
suddendeath:defaultAccess( ULib.ACCESS_ADMIN )
suddendeath:help( "Starts Sudden Death" )

-- #########################
-- #####  Track Everyone #####
-- #########################

function ulx.trackall( calling_ply)

	JM_Function_Announcement("[Game Mode] You are all Tracked!") 
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

local trackall = ulx.command( CATEGORY_NAME_JM_Events, "jm trackall", ulx.trackall, "!trackall")
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

		JM_Function_Announcement("[Proxy Voice] ".. tostring(ConVarProxy_State_Text) .. " - (Range: " .. tostring(ConVarProxy_Range_Text) .. " Units)") 
		JM_Function_PlaySound("0_proximity_voice_toggle.wav")

	end

	ulx.fancyLogAdmin(calling_ply, "#A has enabled: Proximity Voice")
end

local karma = ulx.command(CATEGORY_NAME_JM_Events, "jm proxyvoice enable", ulx.enableproxyvoice, "!enableproxyvoice")
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Enables Proxy Voice until the next map")


-- ##################################################
-- ### Reset Server Convars
-- ##################################################

local cmdResetServerCvars = ulx.command(CATEGORY_NAME_JM_Tool, "jm resetservercvars", function () JM_Function_ResetAllSettings() end, "!resetservercvars")
cmdResetServerCvars:defaultAccess(ULib.ACCESS_ADMIN)

-- ##################################################
-- ### Add Rounds
-- ##################################################

local function JM_ULX_Round_Add()
	JM_Function_AddRounds(1) 
end

local cmdRoundAdd = ulx.command(CATEGORY_NAME_JM_Maps, "jm round add", function () JM_ULX_Round_Add()  end, "!roundadd")
cmdRoundAdd:defaultAccess(ULib.ACCESS_ADMIN)

-- ##################################################
-- ### Take away Rounds
-- ##################################################

local function JM_ULX_Round_Remove()
	JM_Function_RemoveRounds(1) 
end

local cmdRoundRemove = ulx.command(CATEGORY_NAME_JM_Maps, "jm round remove", function () JM_ULX_Round_Remove() end, "!roundremove")
cmdRoundRemove:defaultAccess(ULib.ACCESS_ADMIN)

-- ##################################################
-- ### Next Map Full
-- ##################################################

local function JM_ULX_MapVoteFull()

	JM_Function_PrintChat_All("Map", "The next map vote will be a full vote (Manual)")
	JM_Global_MapVote_FullVote = true

end

local cmdMapVoteFull = ulx.command(CATEGORY_NAME_JM_Maps, "jm votemethodFull", function () JM_ULX_MapVoteFull() end, "!votemethodFull")
cmdMapVoteFull:defaultAccess(ULib.ACCESS_ADMIN)


