---
-- @realm client
-- @section Scoreboard

---
-- @class PANEL
---

---
-- @section TTTScorePlayerRow
-- @desc Scoreboard player score row, based on sandbox version
---

ttt_include("vgui__cl_sb_info")

local GetTranslation = LANG.GetTranslation
local math = math
local table = table
local IsValid = IsValid
local surface = surface
local vgui = vgui

local color_trans = Color(0, 0, 0, 0)

local ttt2_indicator_dev = "vgui/ttt/joshmate/leaderboard/jm_scoreboard_icon_owner"
local ttt2_indicator_vip = "vgui/ttt/ttt2_indicator_vip"
local ttt2_indicator_addondev = "vgui/ttt/ttt2_indicator_admin"

local material_no_team = "vgui/ttt/dynamic/roles/icon_no_team"

local dev_tbl = {
	["76561198045438075"] = true -- Josh Mate
}

local vip_tbl = {
	["0"] = true, -- None
}

local addondev_tbl = {
	["0"] = true, -- None
}

---
-- @param string steamid64
function AddTTT2AddonDev(steamid64)
	if not steamid64 then return end

	addondev_tbl[tostring(steamid64)] = true
end

local namecolor = {
	default = COLOR_WHITE,
	dev = Color(255, 150, 30, 255),
	vip = Color(255, 210, 35, 255),
	addondev = Color(255, 210, 35, 255),
	admin = Color(255, 210, 35, 255)
}

SB_ROW_HEIGHT = 24 --16

local iconSizes = 16

local PANEL = {}

local function _func1(ply)
	return ply:Ping()
end

local function _func2(ply)
	return ply:Deaths()
end

local function _func3(ply)
	return ply:Frags()
end

function PANEL:Init()
	-- cannot create info card until player state is known
	self.info = nil
	self.open = false
	self.cols = {}

	self:AddColumn(GetTranslation("sb_ping"), _func1)
	self:AddColumn(GetTranslation("sb_deaths"), _func2)
	self:AddColumn(GetTranslation("sb_score"), _func3)


	-- Let hooks add their custom columns
	hook.Call("TTTScoreboardColumns", nil, self)

	for i = 1, #self.cols do
		self.cols[i]:SetMouseInputEnabled(false)
	end

	self.tag = vgui.Create("DLabel", self)
	self.tag:SetText("")
	self.tag:SetMouseInputEnabled(false)

	self.sresult = vgui.Create("DImage", self)
	self.sresult:SetSize(iconSizes, iconSizes)
	self.sresult:SetMouseInputEnabled(false)

	self.dev = vgui.Create("DImage", self)
	self.dev:SetSize(iconSizes, iconSizes)
	self.dev:SetMouseInputEnabled(true)
	self.dev:SetKeepAspect(true)
	self.dev:SetTooltip("Server Owner")

	self.vip = vgui.Create("DImage", self)
	self.vip:SetSize(iconSizes, iconSizes)
	self.vip:SetMouseInputEnabled(true)
	self.vip:SetKeepAspect(true)
	self.vip:SetTooltip("VIP")

	self.addondev = vgui.Create("DImage", self)
	self.addondev:SetSize(iconSizes, iconSizes)
	self.addondev:SetMouseInputEnabled(true)
	self.addondev:SetKeepAspect(true)
	self.addondev:SetTooltip("Moderator")

	self.avatar = vgui.Create("AvatarImage", self)
	self.avatar:SetSize(SB_ROW_HEIGHT, SB_ROW_HEIGHT)
	self.avatar:SetMouseInputEnabled(false)

	self.nick2 = vgui.Create("DLabel", self)
	self.nick2:SetMouseInputEnabled(false)

	self.nick3 = vgui.Create("DLabel", self)
	self.nick3:SetMouseInputEnabled(false)

	self.nick = vgui.Create("DLabel", self)
	self.nick:SetMouseInputEnabled(false)

	self.team2 = vgui.Create("DImage", self)
	self.team2:SetSize(iconSizes, iconSizes)
	self.team2:SetMouseInputEnabled(false)
	self.team2:SetKeepAspect(true)

	self.team = vgui.Create("DImage", self)
	self.team:SetSize(iconSizes, iconSizes)
	self.team:SetMouseInputEnabled(true)
	self.team:SetKeepAspect(true)
	self.team:SetTooltip("Team")

	self.voice = vgui.Create("DImageButton", self)
	self.voice:SetSize(iconSizes, iconSizes)

	self:SetCursor("hand")
end

---
-- Adds a column
-- @param string label
-- @param function func
-- @param number width
-- @return Panel DLabel
function PANEL:AddColumn(label, func, width)
	local lbl = vgui.Create("DLabel", self)
	lbl.GetPlayerText = func
	lbl.IsHeading = false
	lbl.Width = width or 50 -- Retain compatibility with existing code

	self.cols[#self.cols + 1] = lbl

	return lbl
end

---
-- Mirror sb_main, of which it and this file both call using the
--	TTTScoreboardColumns hook, but it is useless in this file
-- Exists only so the hook wont return an error if it tries to
--	use the AddFakeColumn function of `sb_main`, which would
--	cause this file to raise a `function not found` error or others
function PANEL:AddFakeColumn()

end

---
-- Updates the color for a @{Player} in the scoreboard
-- @param Player ply
-- @return Color
-- @hook
function GM:TTTScoreboardColorForPlayer(ply)
	if IsValid(ply) then
		local steamid64 = ply:SteamID64()
		if steamid64 then
			steamid64 = tostring(steamid64)

			if dev_tbl[steamid64] and GetGlobalBool("ttt_highlight_dev", true) then
				return namecolor.dev
			elseif vip_tbl[steamid64] and GetGlobalBool("ttt_highlight_vip", true) then
				return namecolor.vip
			elseif addondev_tbl[steamid64] and GetGlobalBool("ttt_highlight_addondev", true) then
				return namecolor.addondev
			end
		end
	end

	return namecolor.default
end

---
-- Updates the row color for a @{Player} in the scoreboard
-- @param Player ply
-- @return Color
-- @hook
function GM:TTTScoreboardRowColorForPlayer(ply)
	local col = color_trans

	if IsValid(ply) and ply.GetRoleColor and ply:GetRoleColor() and ply:GetSubRole() and ply:GetSubRole() ~= ROLE_INNOCENT then
		col = table.Copy(ply:GetRoleColor())
		col.a = 255 -- old value: 30
	end

	return col
end

local function ColorForPlayer(ply)
	if IsValid(ply) then
		local c = hook.Call("TTTScoreboardColorForPlayer", GAMEMODE, ply)

		-- verify that we got a proper color
		if c and istable(c) and c.r and c.b and c.g and c.a then
			return c
		else
			ErrorNoHalt("TTTScoreboardColorForPlayer hook returned something that isn't a color!\n")
		end
	end

	return namecolor.default
end

---
-- @param number width
-- @param number height
function PANEL:Paint(width, height)
	if not IsValid(self.Player) then
		return false
	end

	--	if (self.Player:GetFriendStatus() == "friend") then
	--		color = Color(236, 181, 113, 255)
	--	end

	local ply = self.Player
	local c = hook.Call("TTTScoreboardRowColorForPlayer", GAMEMODE, ply)

	surface.SetDrawColor(clr(c))
	surface.DrawRect(0, 0, width, SB_ROW_HEIGHT)

	if ply == LocalPlayer() then
		surface.SetDrawColor(200, 200, 200, math.Clamp(math.sin(RealTime() * 2) * 50, 0, 100))
		surface.DrawRect(0, 0, width, SB_ROW_HEIGHT)
	end

	return true
end

---
-- @param Player ply
function PANEL:SetPlayer(ply)
	self.Player = ply
	self.avatar:SetPlayer(ply)

	if not self.info then
		local g = ScoreGroup(ply)
		-- TODO add teams

		if g == GROUP_TERROR and ply ~= LocalPlayer() then
			self.info = vgui.Create("TTTScorePlayerInfoTags", self)
			self.info:SetPlayer(ply)

			self:InvalidateLayout()
		elseif g == GROUP_FOUND or g == GROUP_NOTFOUND then
			self.info = vgui.Create("TTTScorePlayerInfoSearch", self)
			self.info:SetPlayer(ply)

			self:InvalidateLayout()
		end
	else
		self.info:SetPlayer(ply)

		self:InvalidateLayout()
	end

	self.voice.DoClick = function()
		if IsValid(ply) and ply ~= LocalPlayer() then
			ply:SetMuted(not ply:IsMuted())
		end
	end

	self:UpdatePlayerData()
end

---
-- @return Player
function PANEL:GetPlayer()
	return self.Player
end

function PANEL:UpdatePlayerData()
	if not IsValid(self.Player) then return end

	local ply = self.Player

	for i = 1, #self.cols do
		-- Set text from function, passing the label along so stuff like text
		-- color can be changed
		self.cols[i]:SetText(self.cols[i].GetPlayerText(ply, self.cols[i]))
	end

	self.nick2:SetText(ply:Nick())
	self.nick2:SizeToContents()
	self.nick2:SetTextColor(COLOR_BLACK)

	self.nick3:SetText(ply:Nick())
	self.nick3:SizeToContents()
	self.nick3:SetTextColor(COLOR_BLACK)

	self.nick:SetText(ply:Nick())
	self.nick:SizeToContents()
	self.nick:SetTextColor(ColorForPlayer(ply))

	local tm = ply:GetTeam() or nil
	if tm then
		local tmData = TEAMS[tm]
		if tm == TEAM_NONE or not tmData or tmData.alone then
			self.team2:SetImage(material_no_team)
			self.team:SetImage(material_no_team)
		else
			local teamImageName = tmData.iconMaterial:GetName()

			self.team2:SetImage(teamImageName)
			self.team:SetImage(teamImageName)
		end

		self.team2:SetImageColor(COLOR_BLACK)
		self.team:SetImageColor(COLOR_WHITE)

		self.team:SetTooltip(LANG.GetTranslation(tm))
	end

	local showTeam = not ply:IsRole(ROLE_INNOCENT) or ply:RoleKnown()

	self.team2:SetVisible(showTeam)
	self.team:SetVisible(showTeam)

	local steamid64 = ply:SteamID64()
	if steamid64 then
		steamid64 = tostring(steamid64)
	end

	local isdev = steamid64 and dev_tbl[steamid64] == true

	self.dev:SetVisible(isdev and GetGlobalBool("ttt_highlight_dev", true))

	if not isdev or not GetGlobalBool("ttt_highlight_dev", true) then
		self.vip:SetVisible(steamid64 and vip_tbl[steamid64] and GetGlobalBool("ttt_highlight_vip", true))
		self.addondev:SetVisible(steamid64 and addondev_tbl[steamid64] and GetGlobalBool("ttt_highlight_addondev", true))
	else
		self.vip:SetVisible(false)
		self.addondev:SetVisible(false)
	end

	local ptag = ply.sb_tag

	if ScoreGroup(ply) ~= GROUP_TERROR then
		ptag = nil
	end

	self.tag:SetText(ptag and GetTranslation(ptag.txt) or "")
	self.tag:SetTextColor(ptag and ptag.color or COLOR_WHITE)

	self.sresult:SetVisible(ply.search_result and ply.search_result.detective_search)

	-- more blue if a detective searched them
	if ply.search_result and (LocalPlayer():IsDetective() or not ply.search_result.show) then
		self.sresult:SetImageColor(Color(200, 200, 255))
	end

	-- cols are likely to need re-centering
	self:LayoutColumns()

	if self.info then
		self.info:UpdatePlayerData()
	end

	if self.Player ~= LocalPlayer() then
		local muted = self.Player:IsMuted()

		self.voice:SetImage(muted and "icon16/sound_mute.png" or "icon16/sound.png")
	else
		self.voice:Hide()
	end
end

function PANEL:ApplySchemeSettings()
	local ply = self.Player

	for i = 1, #self.cols do
		local v = self.cols[i]

		v:SetFont("treb_small")
		v:SetTextColor(COLOR_WHITE)
	end

	self.nick2:SetFont("treb_small")
	self.nick2:SetTextColor(COLOR_BLACK)

	self.nick3:SetFont("treb_small")
	self.nick3:SetTextColor(COLOR_BLACK)

	self.nick:SetFont("treb_small")

	if IsValid(ply) then
		self.nick:SetTextColor(ColorForPlayer(ply))
	end

	local ptag = IsValid(ply) and ply.sb_tag or nil
	self.tag:SetTextColor(ptag and ptag.color or COLOR_WHITE)
	self.tag:SetFont("treb_small")

	self.sresult:SetImage("icon16/magnifier.png")
	self.sresult:SetImageColor(Color(170, 170, 170, 150))

	self.dev:SetImage(ttt2_indicator_dev)
	self.dev:SetImageColor(namecolor.dev)

	self.vip:SetImage(ttt2_indicator_vip)
	self.vip:SetImageColor(namecolor.vip)

	self.addondev:SetImage(ttt2_indicator_addondev)
	self.addondev:SetImageColor(namecolor.addondev)


end

function PANEL:LayoutColumns()
	local cx = self:GetWide()

	for i = 1, #self.cols do
		local v = self.cols[i]

		v:SizeToContents()

		cx = cx - v.Width

		v:SetPos(cx - v:GetWide() * 0.5, (SB_ROW_HEIGHT - v:GetTall()) * 0.5)
	end

	self.tag:SizeToContents()

	cx = cx - 90

	self.tag:SetPos(cx - self.tag:GetWide() * 0.5, (SB_ROW_HEIGHT - self.tag:GetTall()) * 0.5)

	self.sresult:SetPos(cx - 8, (SB_ROW_HEIGHT - iconSizes) * 0.5)

	local x = self.nick:GetPos()
	local w = self.nick:GetSize()

	local count = 0
	local mgn = 10

	local tx = x + w + mgn
	local ty = (SB_ROW_HEIGHT - iconSizes) * 0.5

	local iconTbl = {
		"dev",
		"vip",
		"addondev",
	}

	for i = 1, #iconTbl do
		local entry = iconTbl[i]
		local iconData = self[entry]

		if iconData:IsVisible() then
			iconData:SetPos(tx + (iconSizes + mgn) * count, ty)

			count = count + 1
		end
	end
end

function PANEL:PerformLayout()
	self.avatar:SetPos(0, 0)
	self.avatar:SetSize(SB_ROW_HEIGHT, SB_ROW_HEIGHT)

	local fw = sboard_panel.ply_frame:GetWide()

	self:SetWide(sboard_panel.ply_frame.scroll.Enabled and (fw - iconSizes) or fw)

	if not self.open then
		self:SetSize(self:GetWide(), SB_ROW_HEIGHT)

		if self.info then
			self.info:SetVisible(false)
		end
	elseif self.info then
		self:SetSize(self:GetWide(), 100 + SB_ROW_HEIGHT)

		self.info:SetVisible(true)
		self.info:SetPos(5, SB_ROW_HEIGHT + 5)
		self.info:SetSize(self:GetWide(), 100)
		self.info:PerformLayout()

		self:SetSize(self:GetWide(), SB_ROW_HEIGHT + self.info:GetTall())
	end

	local tx = SB_ROW_HEIGHT + 10 + iconSizes
	local ty = (SB_ROW_HEIGHT - self.nick:GetTall()) * 0.5

	self.nick2:SizeToContents()
	self.nick2:SetPos(tx + 1, ty + 1)

	self.nick3:SizeToContents()
	self.nick3:SetPos(tx, ty)

	self.nick:SizeToContents()
	self.nick:SetPos(tx, ty)

	self.team2:SetPos(tx - iconSizes - 4, (SB_ROW_HEIGHT - iconSizes) * 0.5 + 1)
	self.team:SetPos(tx - iconSizes - 5, (SB_ROW_HEIGHT - iconSizes) * 0.5)

	self:LayoutColumns()

	self.voice:SetVisible(not self.open)
	self.voice:SetSize(iconSizes, iconSizes)
	self.voice:DockMargin(4, 4, 4, 4)
	self.voice:Dock(RIGHT)
end

---
-- @param number x
-- @param number y
function PANEL:DoClick(x, y)
	self:SetOpen(not self.open)
end

---
-- @param boolean o
function PANEL:SetOpen(o)
	if self.open then
		surface.PlaySound("ui/buttonclickrelease.wav")
	else
		surface.PlaySound("ui/buttonclick.wav")
	end

	self.open = o

	self:PerformLayout()
	self:GetParent():PerformLayout()

	sboard_panel:PerformLayout()
end

function PANEL:DoRightClick()
	local menu = DermaMenu()
	menu.Player = self:GetPlayer()

	local close = hook.Call("TTTScoreboardMenu", nil, menu)
	if close then
		menu:Remove()

		return
	end

	menu:Open()
end

vgui.Register("TTTScorePlayerRow", PANEL, "DButton")
