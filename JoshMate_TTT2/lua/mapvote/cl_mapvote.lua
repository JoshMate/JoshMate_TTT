net.Receive("MapVote_Start", function()
    MapVote:Init() -- init client MapVote
    MapVote:CalcGUIConstants()
    
    local voteTime = net.ReadUInt(16)
    MapVote.voteTime = voteTime
    MapVote.voteTimeEnd = voteTime + CurTime()

    local maps = net.ReadTable()

    local gui = vgui.Create( "MapFrame" )
    gui:AddMaps(maps)
    MapVote.gui = gui
    
end)

net.Receive("MapVote_Stop", function()
    if MapVote.gui then
        MapVote.gui:Clear()
        MapVote.gui:SetVisible(false)
        MapVote.gui = nil
    end
end)

net.Receive("MapVote_End", function()
    MapVote.active = false;
    local winner = net.ReadUInt(32)
    local button = MapVote.gui:GetButton(winner)
    button:Blink()
end)

net.Receive("MapVote_UpdateToAllClient", function()
    local ply = net.ReadEntity()
    if IsValid(ply) then
        local id = net.ReadUInt(32) -- the clicked button id
        local button = MapVote.gui:GetButton(id)

        local curButtonId = MapVote.votes[ply:UniqueID()]
        local icon = nil

        if not curButtonId then
            icon = MapVote:CreateVoterIcon(ply)
        else 
            -- remove avatar icon from button if one already exists on another button
            local curButton = MapVote.gui:GetButton(curButtonId)
            icon = curButton:GetVoterIcon(ply)
            curButton:RemoveVoterIcon(ply)
        end

        
        button:AddVoterIcon(ply, icon)
        icon:SetParent(button)

        MapVote.votes[ply:UniqueID()] = id
    end
end)

hook.Add("OnPlayerChat", "Show mapvote again", function(ply, text)
	text = string.lower(text)
    text = string.Trim(text)

	if text == "!mapvoteshow" then
        if (MapVote.gui) then MapVote.gui:SetVisible(true) end
        return false
	end
end)

-- ConVars (clientsided)
local cv_spacing = 4
local cv_max_button_row = 7
local cv_button_size = 100
local cv_avatar_size = 32
local cv_avatar = 1


function MapVote:CalcGUIConstants() 
    -- global variables for the gui components
    local scale = ScrW() / 1920.0
    UI_SCALE_FACTOR = math.Clamp(scale, 0.5, 1.0)
    MAX_FRAME_W = 1280 * UI_SCALE_FACTOR
    MIN_FRAME_W = 200 * UI_SCALE_FACTOR
    MIN_FRAME_H = 200 * UI_SCALE_FACTOR

    SPACING = math.max(math.min(cv_spacing,25),1)
	
    local buttonFactor = cv_button_size / 100
    MAPBUTTON_W = UI_SCALE_FACTOR * 200 * buttonFactor
    MAPBUTTON_H = UI_SCALE_FACTOR * 250 * buttonFactor

    MAX_BUTTONROW = math.floor(cv_max_button_row)

	if not cv_avatar then
		AVATAR_ICON_SIZE = 0
	else
	local AVATAR_MAX_SIZE = 0
		if MAPBUTTON_H < MAPBUTTON_W then
			AVATAR_MAX_SIZE = MAPBUTTON_H/2
		else
			AVATAR_MAX_SIZE = MAPBUTTON_W/2
		end
		AVATAR_ICON_SIZE = math.floor(cv_avatar_size * UI_SCALE_FACTOR)
	end
end

function MapVote:CreateVoterIcon(ply)
    local icon_blank = vgui.Create("Panel")
    icon_blank:SetSize(AVATAR_ICON_SIZE, AVATAR_ICON_SIZE)
    icon_blank.player = ply

    local icon_holder = vgui.Create("DPanel", icon_blank)
    icon_holder:SetPos(2, 2)
    icon_holder:SetSize(AVATAR_ICON_SIZE - 4, AVATAR_ICON_SIZE - 4)
    
    local icon = vgui.Create("AvatarImage", icon_holder)
    icon:SetPos(1, 1)
    icon:SetSize(AVATAR_ICON_SIZE - 6, AVATAR_ICON_SIZE - 6)
    icon:SetPlayer(ply)
    icon_holder.icon = icon

    return icon_blank
end
