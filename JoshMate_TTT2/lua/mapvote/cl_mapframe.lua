surface.CreateFont("TimeLeftFont", {
    font = "Verdana",
    size = 42,
    weight = 1000,
    antialias = true,
    shadow = true
})

local PANEL = {}

function PANEL:Init()
    
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
    self:CenterHorizontal()

    self.timeLeftLabel = vgui.Create("DLabel", self)
    self.timeLeftLabel:SetText("")
    self.timeLeftLabel:SetContentAlignment( 5 )
    self.timeLeftLabel:SetPos(0, 0)
    self.timeLeftLabel:SetSize(ScrW(), 40)
    self.timeLeftLabel:SetFont("TimeLeftFont")
    self.timeLeftLabel:SetTextColor( Color( 255, 150, 0, 255 ) )

    self.scrollPanel = vgui.Create("DScrollPanel", self)
    self.scrollPanel:SetSize(ScrW(), ScrH() - 50)
    self.scrollPanel:SetPos(50, 50)

    self.mapButtonList = vgui.Create("DIconLayout", self.scrollPanel)
    self.mapButtonList:SetSpaceY(SPACING)
    self.mapButtonList:SetSpaceX(SPACING)

    local w, h = self.scrollPanel:GetSize()
    self.mapButtonList:SetSize(w, h)

    self.voterIcons = {}

    self:ParentToHUD()
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
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
    self.timeLeftLabel:SetText(tostring(time))
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0 ) )
end


vgui.Register("MapFrame", PANEL)