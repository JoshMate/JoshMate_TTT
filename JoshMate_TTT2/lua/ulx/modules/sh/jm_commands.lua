-- Give these files out
AddCSLuaFile()


local CATEGORY_NAME = "JoshMate"

-- ##################################################
-- ### Spawn Care Package
-- ##################################################

local cmdSpawnCarePackage = ulx.command(CATEGORY_NAME, "jm carepackage spawn", function () JMGlobal_SpawnCarePackage(true) end, "!spawncarepackage")
cmdSpawnCarePackage:defaultAccess(ULib.ACCESS_ADMIN)

-- #########################
-- ######## Mapvote ########
-- #########################
function ulx.mapvote(calling_ply, time, isOppositeCmd)
    if isOppositeCmd then MapVote:Stop() else MapVote:Start(time) end
end

local cmdMapvote = ulx.command(CATEGORY_NAME, "jm mapvote start", ulx.mapvote, "!mapvote")
cmdMapvote:addParam{ type=ULib.cmds.NumArg, min=15, default=20, max=60, ULib.cmds.optional, hint="Votetime" } -- time param
cmdMapvote:addParam{ type=ULib.cmds.BoolArg, invisible=true } -- isOppositeCmd param
cmdMapvote:defaultAccess(ULib.ACCESS_ADMIN)
cmdMapvote:setOpposite("jm mapvote end", {_, _, true}, "!unmapvote")

-- #########################
-- ####### RTV reset #######
-- #########################
function ulx.rtvreset(calling_ply)
    PrintMessage(HUD_PRINTTALK, calling_ply:Nick() .. " resets the RTV.")
    RTV:Reset()
end

local cmdRtv = ulx.command(CATEGORY_NAME, "jm mapvote resetrtv", ulx.rtvreset, "!resetrtv")
cmdRtv:defaultAccess(ULib.ACCESS_ADMIN)


-- #########################
-- ## Reset Played Maps ####
-- #########################

function ulx.resetmaplist(calling_ply)
    PrintMessage(HUD_PRINTTALK, calling_ply:Nick() .. " resets the list of played maps.")
    ConfigHelper:WritePlayedMaps({}) 
end

local cmdResetMapList = ulx.command(CATEGORY_NAME, "jm mapvote resetlist", ulx.resetmaplist, "!resetmaplist")
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
    net.WriteString("Sudden Death Has Begun!")
	net.WriteUInt(1, 16)
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

local suddendeath = ulx.command( CATEGORY_NAME, "jm x suddendeath", ulx.suddendeath, "!suddendeath")
suddendeath:defaultAccess( ULib.ACCESS_ADMIN )
suddendeath:help( "Starts Sudden Death" )


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
		
        chat.AddText( Color( 255, 0, 0 ), "[Announcement] - ", Color( 255, 255, 0 ), tostring(message))
    end)

	hook.Add( "HUDPaint", "JM_HOOK_DRAWANNOUNCEMENTTEXT", function()

		if not message then return end
		if messageTime < (CurTime() - 10) then message = nil return end

		draw.DrawText(tostring(message), "JoshMateFont_Announcements", (ScrW()/2), (ScrH()/4), Color(255,255,0,255), TEXT_ALIGN_CENTER)
	end )
end