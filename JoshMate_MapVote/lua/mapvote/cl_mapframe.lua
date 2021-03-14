surface.CreateFont("TimeLeftFont", {
    font = "Verdana",
    size = 42,
    weight = 1000,
    antialias = true,
    shadow = true
})

local PANEL = {}

function PANEL:Init()
    local width, height = self:CalcFrameSize()
    
    self:SetSize(width, height)
    self:SetPos(0, 100)
    self:CenterHorizontal()

    self.timeLeftLabel = vgui.Create("DLabel", self)
    self.timeLeftLabel:SetText("")
    self.timeLeftLabel:SetContentAlignment( 5 )
    self.timeLeftLabel:SetPos(0, 0)
    self.timeLeftLabel:SetSize(width, 40)
    self.timeLeftLabel:SetFont("TimeLeftFont")
    self.timeLeftLabel:SetTextColor( Color( 255, 150, 0, 255 ) )

    self.scrollPanel = vgui.Create("DScrollPanel", self)
    self.scrollPanel:SetSize(width, height - 50)
    self.scrollPanel:SetPos(0, 50)

    self.mapButtonList = vgui.Create("DIconLayout", self.scrollPanel)
    self.mapButtonList:SetSpaceY(SPACING)
    self.mapButtonList:SetSpaceX(SPACING)

    local w, h = self.scrollPanel:GetSize()
    self.mapButtonList:SetSize(w, h)

    self.voterIcons = {}

    self.hideFrame = vgui.Create("DButton", self)
    self.hideFrame:SetText("_")
    self.hideFrame:SetSize(20, 20)
    self.hideFrame:SetVisible(true)
    self.hideFrame:SetPos(width - SPACING - 20, 20 + SPACING)
    self.hideFrame.DoClick = function()
        self:SetVisible(false)
        LocalPlayer():ChatPrint("Mapvote hide - Type !mapvoteshow to show mapvote again.")
    end

    self:ParentToHUD()
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
end

function PANEL:CalcFrameSize() 
    local buttonsPerRow = math.Round(ScrW() / MAPBUTTON_W)
    if buttonsPerRow > MAX_BUTTONROW then
        buttonsPerRow = MAX_BUTTONROW
    end

    local width = buttonsPerRow * MAPBUTTON_W + buttonsPerRow * SPACING

    return width, ScrH() - 100
end

function PANEL:AddMaps(maps) 
     for k, map in pairs(maps) do
        local button = self.mapButtonList:Add("MapButton")
        button:SetSize(MAPBUTTON_W, MAPBUTTON_H)
        button:SetMapName(map)
        button.id = k
    end
end

function PANEL:VoterIconExists(ply)
    return self.voterIcons[ply:UniqueID()]
end

function PANEL:GetButtonForVoter(ply)
    local buttonid = MapVote.votes[ply:UniqueID()]

    for k, button in pairs(self.mapButtonList:GetChildren()) do
        if button.id == buttonid then 
            return button 
        end
    end

    return false
end

function PANEL:GetButton(id)
    for k, button in pairs(self.mapButtonList:GetChildren()) do
        if button.id == id then 
            return button 
        end
    end

    return false
end

function PANEL:Clear()
    for k, button in pairs(self.mapButtonList:GetChildren()) do
        --button:RemoveAllVoterIcons()
    end
end

function PANEL:Think()
    local time = math.ceil(MapVote.voteTimeEnd - CurTime())
    time = math.max(0, time)
    self.timeLeftLabel:SetText(time .. " seconds left to vote")
end


vgui.Register("MapFrame", PANEL)