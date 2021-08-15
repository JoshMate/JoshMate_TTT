-- Give these files out
AddCSLuaFile()


local CATEGORY_NAME = "JoshMate"

-- ##################################################
-- ### Spawn Care Package
-- ##################################################

local cmdSpawnCarePackage = ulx.command(CATEGORY_NAME, "jm carepackage", function () JMGlobal_SpawnCarePackage(1) end, "!spawncarepackage")
cmdSpawnCarePackage:defaultAccess(ULib.ACCESS_ADMIN)

local CATEGORY_NAME = "JoshMate"

-- ##################################################
-- ### Spawn Emergency Airdrop
-- ##################################################

local cmdEmergencyAirdrop = ulx.command(CATEGORY_NAME, "jm carepacakage x3", function () JMGlobal_SpawnCarePackage(2) end, "!spawnemergencyairdrop")
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

local spawnthis = ulx.command( CATEGORY_NAME, "jm creatething", ulx.spawnthing, "!spawnthis")
spawnthis:addParam{ type=ULib.cmds.StringArg, hint="", ULib.cmds.takeRestOfLine }
spawnthis:defaultAccess( ULib.ACCESS_ADMIN )
spawnthis:help( "Spawns the given entity name: eg. weapon_jm_zloot_prop_launcher" )

-- #########################
-- #####  Spawn Item All ###
-- #########################

function ulx.spawnthing( calling_ply, message )

	net.Start("JM_ULX_Announcement")
    net.WriteString("Giving Everyone: " .. tostring(message))
	net.WriteUInt(0, 16)
    net.Broadcast()

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

local spawnthis = ulx.command( CATEGORY_NAME, "jm creatething all", ulx.spawnthing, "!spawnthisforall")
spawnthis:addParam{ type=ULib.cmds.StringArg, hint="", ULib.cmds.takeRestOfLine }
spawnthis:defaultAccess( ULib.ACCESS_ADMIN )
spawnthis:help( "Spawns the given entity name for everyone: eg. weapon_jm_zloot_prop_launcher" )

-- #########################
-- ######## Mapvote ########
-- #########################
function ulx.mapvote(calling_ply, time, isOppositeCmd)
    if isOppositeCmd then MapVote:Stop() else MapVote:Start(time) end
end

local cmdMapvote = ulx.command(CATEGORY_NAME, "jm map vote", ulx.mapvote, "!mapvote")
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

local cmdResetMapList = ulx.command(CATEGORY_NAME, "jm map resetlist", ulx.resetmaplist, "!resetmaplist")
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

local karma = ulx.command(CATEGORY_NAME, "jm karma reset all", ulx.karmatotalreset, "!karmatotalreset")
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

local karma = ulx.command(CATEGORY_NAME, "jm karma punish 250", ulx.karmapunish250, "!karmapunish250")
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

local karma = ulx.command(CATEGORY_NAME, "jm karma punish 500", ulx.karmapunish500, "!karmapunish500")
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

local karma = ulx.command(CATEGORY_NAME, "jm karma reset 1000", ulx.karmaset1000, "!karmaset1000")
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

local karma = ulx.command(CATEGORY_NAME, "jm karma reset 1250", ulx.karmaset1250, "!karmaset1250")
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

local karma = ulx.command(CATEGORY_NAME, "jm slay all", ulx.slayeveryone, "!slayeveryone")
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Slays Everyone")

-- #########################
-- #####  Announcement #####
-- #########################

function ulx.announcement( calling_ply, message )

	net.Start("JM_ULX_Announcement")
    net.WriteString(tostring(message))
	net.WriteUInt(0, 16)
    net.Broadcast()

end

local announce = ulx.command( CATEGORY_NAME, "jm announcement", ulx.announcement, "!announcement")
announce:addParam{ type=ULib.cmds.StringArg, hint="", ULib.cmds.takeRestOfLine }
announce:defaultAccess( ULib.ACCESS_ADMIN )
announce:help( "Sends a message to everyone" )

-- #########################
-- #####  Sudden Death #####
-- #########################

function ulx.suddendeath( calling_ply)

	net.Start("JM_ULX_Announcement")
    net.WriteString("Sudden Death!")
	net.WriteUInt(1, 16)
    net.Broadcast()

end

local suddendeath = ulx.command( CATEGORY_NAME, "jm x suddendeath", ulx.suddendeath, "!suddendeath")
suddendeath:defaultAccess( ULib.ACCESS_ADMIN )
suddendeath:help( "Starts Sudden Death" )

-- #########################
-- #####  Track Everyone #####
-- #########################

function ulx.trackall( calling_ply)

	net.Start("JM_ULX_Announcement")
    net.WriteString("Everyone is now Tracked!")
	net.WriteUInt(2, 16)
    net.Broadcast()

	local plys = player.GetAll()

	for i = 1, #plys do
		local ply = plys[i]
		if ply:IsValid() and ply:Alive() and ply:IsTerror() then 
			JM_RemoveBuffFromThisPlayer("jm_buff_suddendeath",ply)
			JM_GiveBuffToThisPlayer("jm_buff_suddendeath",ply,ply)	
		end
	end


end

local trackall = ulx.command( CATEGORY_NAME, "jm x trackall", ulx.trackall, "!trackall")
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

        net.Start("JM_ULX_Announcement")
		net.WriteString("Proximity Voice: " .. tostring(ConVarProxy_State_Text) .. " - (Range: " .. tostring(ConVarProxy_Range_Text) .. " Units)")
		net.WriteUInt(3, 16)
		net.Broadcast()

	end

	ulx.fancyLogAdmin(calling_ply, "#A has enabled: Proximity Voice")
end

local karma = ulx.command(CATEGORY_NAME, "jm proxyvoice enable", ulx.enableproxyvoice, "!enableproxyvoice")
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("Enables Proxy Voice until the next map")


-- Extra
if SERVER then
	util.AddNetworkString("JM_ULX_Announcement")
end

if CLIENT then

	surface.CreateFont( "JoshMateFont_Announcements", {
		font = "Calibri", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		extended = false,
		size = 48,
		weight = 300,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = true,
	} )

	local message = nil
	local messageTime = 0

    net.Receive("JM_ULX_Announcement", function(_) 
		
        message = net.ReadString()
		messageType = net.ReadUInt(16)
		messageTime = CurTime()

		surface.PlaySound("0_main_popup.wav")

		if messageType == 1 then surface.PlaySound("0_main_suddendeath.mp3") end
		if messageType == 2 then surface.PlaySound("ping_jake.wav") end
		if messageType == 3 then surface.PlaySound("0_proximity_voice_toggle.wav") end
		
        chat.AddText( Color( 255, 0, 0 ), "[Announcement] - ", Color( 255, 255, 0 ), tostring(message))
    end)

	hook.Add( "HUDPaint", "JM_HOOK_DRAWANNOUNCEMENTTEXT", function()

		if not message then return end
		if messageTime < (CurTime() - 10) then message = nil return end

		draw.DrawText(tostring(message), "JoshMateFont_Announcements", (ScrW()/2), (ScrH()/4), Color(255,255,0,255), TEXT_ALIGN_CENTER)
	end )
end