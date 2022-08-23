---
-- @module RADAR
-- @desc radar rendering

local surface = surface
local math = math
local GetTranslation
local GetPTranslation
local table = table
local net = net
local pairs = pairs
local IsValid = IsValid

local indicator = surface.GetTextureID("vgui/ttt/joshmate/warningicons/icon_warn_player")
local sample_scan = surface.GetTextureID("vgui/ttt/sample_scan")
local det_beacon = surface.GetTextureID("vgui/ttt/det_beacon")
local near_cursor_dist = 180

local colorFallback = Color(150, 150, 150)

RADAR = RADAR or {}
RADAR.targets = {}
RADAR.enable = false
RADAR.startTime = 0
RADAR.jmHudWarnings = {}
RADAR.jmHudWarnings_count = 0
RADAR.repeating = true
RADAR.samples = {}
RADAR.samples_count = 0
RADAR.called_corpses = {}

---
-- Disables the scan
-- @internal
-- @realm client
function RADAR:EndScan()
	self.enable = false
	self.startTime = 0
end

---
-- Clears the radar
-- @internal
-- @realm client
function RADAR:Clear()
	self:EndScan()

	self.jmHudWarnings = {}
	self.samples = {}
	self.jmHudWarnings_count = 0
	self.samples_count = 0
end

---
-- Cache stuff we'll be drawing
-- @internal
-- @realm client
function RADAR.CacheEnts()

	-- also do some corpse cleanup here
	for k, corpse in pairs(RADAR.called_corpses) do
		if corpse.called + 45 < CurTime() then
			RADAR.called_corpses[k] = nil -- will make # inaccurate, no big deal
		end
	end

	if RADAR.jmHudWarnings_count > 0 then  

		-- Update jm warn positions for those we know about
		for i, b in pairs(RADAR.jmHudWarnings) do
			local ent = Entity(i)

			if IsValid(ent) then
				b.vecEntPos = ent:GetPos()
			end
		end

	end
end

---
-- Called if the radar is equipped
-- @param Player ply
-- @hook
-- @internal
-- @realm client
function ITEM:Equip(ply)
	RunConsoleCommand("ttt_radar_scan")
end

---
-- Draws a counter next to the item icon
-- @hook
-- @internal
-- @realm client
function ITEM:DrawInfo()
	return math.ceil(math.max(0, (LocalPlayer().radarTime or 30) - (CurTime() - RADAR.startTime)))
end

local function DrawTarget(tgt, size, offset, no_shrink)
	local scrpos = tgt.pos:ToScreen() -- sweet
	local sz = (IsOffScreen(scrpos) and not no_shrink) and (size * 0.5) or size

	scrpos.x = math.Clamp(scrpos.x, sz, ScrW() - sz)
	scrpos.y = math.Clamp(scrpos.y, sz, ScrH() - sz)

	if IsOffScreen(scrpos) then return end

	surface.DrawTexturedRect(scrpos.x - sz, scrpos.y - sz, sz * 2, sz * 2)

	-- Drawing full size?
	if sz == size then
		local text = math.ceil(LocalPlayer():GetPos():Distance(tgt.pos))
		local w, h = surface.GetTextSize(text)

		-- Show range to target
		surface.SetTextPos(scrpos.x - w * 0.5, scrpos.y + sz * 1)
		surface.DrawText(text)

		if tgt.t then
			-- Show time
			text = util.SimpleTime(tgt.t - CurTime(), "%02i:%02i")
			w, h = surface.GetTextSize(text)

			surface.SetTextPos(scrpos.x - w * 0.5, scrpos.y + sz * 1.7)
			surface.DrawText(text)
		elseif tgt.nick then
			-- Show nickname
			text = tgt.nick
			w, h = surface.GetTextSize(text)

			surface.SetTextPos(scrpos.x - w * 0.5, scrpos.y + sz * 1.7)
			surface.DrawText(text)
		end
	end
end

local function DrawTargetJmVersion(tgt, size, offset, no_shrink)
	local scrpos = tgt.vecEntPos:ToScreen() -- sweet
	local sz = (IsOffScreen(scrpos) and not no_shrink) and (size * 0.5) or size

	scrpos.x = math.Clamp(scrpos.x, sz, ScrW() - sz)
	scrpos.y = math.Clamp(scrpos.y, sz, ScrH() - sz)

	if IsOffScreen(scrpos) then return end

	surface.SetTextColor(255, 255, 255, 255)
	surface.SetDrawColor(255, 255, 255, 135)
	local strTexturePathStart = "vgui/ttt/joshmate/warningicons/"
	local strTexturePathFull = strTexturePathStart .. tgt.strIcon
	surface.SetTexture(surface.GetTextureID(strTexturePathFull))

	surface.DrawTexturedRect(scrpos.x - sz, scrpos.y - sz, sz * 2, sz * 2)

	-- Drawing full size?
	if sz == size then
		local text = math.ceil(LocalPlayer():GetPos():Distance(tgt.vecEntPos))
		local w, h = surface.GetTextSize(text)

		-- Show range to target
		surface.SetTextPos(scrpos.x - w * 0.5, scrpos.y + sz * 1)
		surface.DrawText(text)

		if tgt.timeExpire > 0 then
			-- Show time
			text = util.SimpleTime(tgt.timeExpire - CurTime(), "%02i:%02i")
			w, h = surface.GetTextSize(text)

			surface.SetTextPos(scrpos.x - w * 0.5, scrpos.y + sz * 1.7)
			surface.DrawText(text)
		end
	end
end

---
-- Draws the indicator on the screen
-- @hook
-- @internal
-- @realm client
function RADAR:Draw(client)
	if not IsValid(client) then return end

	GetPTranslation = GetPTranslation or LANG.GetParamTranslation

	surface.SetFont("HudSelectionText")

	-- JM Custom HUD Warnings
	if self.jmHudWarnings_count ~= 0 then
		for _, jmHudWarning in pairs(self.jmHudWarnings) do
			if  
				client:GetTeam() == TEAM_SPEC or not client:Alive() or jmHudWarning.isTraitor == false			
				or jmHudWarning.isTraitor == true and client:GetTeam() == TEAM_TRAITOR
			then
				DrawTargetJmVersion(jmHudWarning, 24, 0, true)
			end
		end
	end

	-- Corpse calls
	if not table.IsEmpty(self.called_corpses) then
		surface.SetTexture(det_beacon)
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetDrawColor(255, 255, 255, 255)

		for _, corpse in pairs(self.called_corpses) do
			DrawTarget(corpse, 24, 0.5)
		end
	end

	-- Samples
	if self.samples_count ~= 0 then
		surface.SetTexture(sample_scan)
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetDrawColor(255, 255, 255, 255)

		for _, sample in pairs(self.samples) do
			DrawTarget(sample, 24, 0.5, true)
		end
	end

	-- Player radar

	if client:GetTeam() == TEAM_SPEC or not client:Alive() or not client:IsTerror() then return end

	if not self.enable then return end

	surface.SetTexture(indicator)

	local radarTime = client.radarTime or 30
	local remaining = math.max(0, radarTime - (CurTime() - RADAR.startTime))
	local alpha_base = 50 + 180 * (remaining / radarTime)
	local mpos = Vector(ScrW() * 0.5, ScrH() * 0.5, 0)

	local subrole, alpha, scrpos, md

	for i = 1, #RADAR.targets do
		local tgt = RADAR.targets[i]

		alpha = alpha_base
		scrpos = tgt.pos:ToScreen()

		if scrpos.visible then
			md = mpos:Distance(Vector(scrpos.x, scrpos.y, 0))

			if md < near_cursor_dist then
				alpha = math.Clamp(alpha * (md / near_cursor_dist), 40, 230)
			end

			subrole = tgt.subrole or ROLE_INNOCENT

			local roleData = roles.GetByIndex(subrole)
			local c = roleData.radarColor or (TEAMS[tgt.team] and TEAMS[tgt.team].color or colorFallback)

			if tgt.color then
				surface.SetDrawColor(tgt.color.r, tgt.color.g, tgt.color.b, alpha)
				surface.SetTextColor(255, 255, 255, 255)
			else
				surface.SetDrawColor(c.r, c.g, c.b, alpha)
				surface.SetTextColor(255, 255, 255, 255)
			end

			DrawTarget(tgt, 16, 0)
		end
	end
end

-- Josh Mate Custom HUD Warning Icons Recieve Message
local function JMReceiveCustomHUDWarning()
	
	local isEnabled 			= net.ReadBool()
	local entIndex 				= net.ReadUInt(16)	

	if isEnabled then

		local strIcon 				= net.ReadString()
		local vecEntPos 			= net.ReadVector()
		local timeExpire 			= net.ReadFloat()
		local isTraitor			 	= net.ReadBool()
		
		RADAR.jmHudWarnings[entIndex] = {
			isTraitor 			= isTraitor, 
			strIcon 			= strIcon,
			vecEntPos 			= vecEntPos,
			timeExpire 			= timeExpire
		}

	else

		RADAR.jmHudWarnings[entIndex] = nil

	end

	RADAR.jmHudWarnings_count = table.Count(RADAR.jmHudWarnings)
end
net.Receive("JM_NET_CustomHudWarning", JMReceiveCustomHUDWarning)



local function TTT_CorpseCall()
	local pos = net.ReadVector()
	local _tmp = {pos = pos, called = CurTime()}

	table.insert(RADAR.called_corpses, _tmp)
end
net.Receive("TTT_CorpseCall", TTT_CorpseCall)

local function ReceiveRadarScan()
	local num_targets = net.ReadUInt(16)

	RADAR.targets = {}

	for i = 1, num_targets do
		local pos = Vector(
			net.ReadInt(32),
			net.ReadInt(32),
			net.ReadInt(32)
		)

		local hasSubrole = net.ReadBool()
		local subrole

		if hasSubrole then
			subrole = net.ReadUInt(ROLE_BITS)
		end

		local team = net.ReadString()

		local color
		if net.ReadBool() then
			color = net.ReadColor()
		end

		RADAR.targets[#RADAR.targets + 1] = {pos = pos, subrole = subrole, team = team, hasSubrole = hasSubrole, color = color}
	end

	RADAR.enable = true
	RADAR.startTime = CurTime()
end
net.Receive("TTT_Radar", ReceiveRadarScan)

local function ReceiveRadarTime()
	LocalPlayer().radarTime = net.ReadUInt(8)
end
net.Receive("TTT2RadarUpdateTime", ReceiveRadarTime)

---
-- Creates the settings menu
-- @internal
-- @realm client
function RADAR.CreateMenu(parent, frame)
	GetTranslation = GetTranslation or LANG.GetTranslation
	GetPTranslation = GetPTranslation or LANG.GetParamTranslation
	--local w, h = parent:GetSize()

	local dform = vgui.Create("DForm", parent)
	dform:SetName(GetTranslation("radar_menutitle"))
	dform:StretchToParent(0, 0, 0, 0)
	dform:SetAutoSize(false)

	local owned = LocalPlayer():HasEquipmentItem("item_ttt_radar")
	if not owned then
		dform:Help(GetTranslation("radar_not_owned"))

		return dform
	end

	local bw, bh = 100, 25

	local dscan = vgui.Create("DButton", dform)
	dscan:SetSize(bw, bh)
	dscan:SetText(GetTranslation("radar_scan"))

	dscan.DoClick = function(s)
		RunConsoleCommand("ttt_radar_scan")

		frame:Close()
	end

	dform:AddItem(dscan)

	local dlabel = vgui.Create("DLabel", dform)
	dlabel:SetText(GetPTranslation("radar_help", {num = LocalPlayer().radarTime or 30}))
	dlabel:SetWrap(true)
	dlabel:SetTall(50)

	dform:AddItem(dlabel)

	local dcheck = vgui.Create("DCheckBoxLabel", dform)
	dcheck:SetText(GetTranslation("radar_auto"))
	dcheck:SetIndent(5)
	dcheck:SetValue(RADAR.repeating)

	dcheck.OnChange = function(s, val)
		net.Start("TTT2RadarUpdateAutoScan")
		net.WriteBool(val)
		net.SendToServer()

		RADAR.repeating = val
	end

	dform:AddItem(dcheck)

	dform.Think = function(s)
		if RADAR.repeating or not owned then
			dscan:SetDisabled(true)
		else
			dscan:SetDisabled(false)
		end
	end

	dform:SetVisible(true)

	return dform
end
