surface.CreateFont("MapNameFont", {
    font = "Verdana", -- maybe i will change... not sure if I like Tahoma lol
    size = 20,
    weight = 400,
    antialias = true
})

local PANEL = {}

function PANEL:Init()
    self:SetText("")
    self.blink = false

    -- for the flash animation later
    self.PaintInherit = self.Paint
    self.Paint = self.PaintOverride

    self.voterIcons = {}

    local size = MAPBUTTON_W - (2 * SPACING)
    
    self.imageView = vgui.Create("DImage", self)
    self.imageView:SetSize(size, size)
    self.imageView:SetPos(SPACING, 2 * SPACING)

    self.mapName = vgui.Create("DLabel", self)

    local spaceBelowImageView = MAPBUTTON_H - (size + SPACING)
    
    self.mapName:SetPos(SPACING, size + SPACING)
    self.mapName:SetSize(size, spaceBelowImageView)
    self.mapName:SetFont("MapNameFont")
    self.mapName:SetTextColor( Color( 0, 0, 0, 255 ) )
    self.mapName:SetContentAlignment( 5 )
end

function PANEL:PaintOverride(w, h) 
    self:PaintInherit(w, h)
    local color = Color(255, 255, 255, 0)
    
    if self.blink then
        color = Color(255, 150, 0, 255)
    end

    draw.RoundedBox(0, 0, 0, w, h, color)
end

function PANEL:DoClick() 
    if not MapVote.active then return end
    
    local ply = LocalPlayer()
    if IsValid(ply) then 
        net.Start("MapVote_UpdateFromClient")
        net.WriteUInt(self.id, 32)
        net.SendToServer()
    end
end


function PANEL:SetMapName(name)
    
    local newName = string.Replace(name, "ttt", "")
    newName = string.Replace(newName, "_", " ")
    newName = string.gsub(" "..newName, "%W%l", string.upper):sub(2)
    
    self.mapName:SetText(newName)    
    

    if file.Exists("maps/thumb/" .. name .. ".png", "GAME") then
        self.imageView:SetImage("maps/thumb/" .. name .. ".png")
    elseif file.Exists("maps/" .. name .. ".png", "GAME") then
        self.imageView:SetImage("maps/" .. name .. ".png")
    else
        self.imageView:SetImage("maps/thumb/noicon.png")
    end
end

function PANEL:GetAvatarLayoutPlaceBounds()
    local vx, vy, vw, vh = self.imageView:GetBounds()

    return vx, vy, vw, vh
end

function PANEL:AddVoterIcon(ply, icon)
    if IsValid(ply) then
       self.voterIcons[ply:UniqueID()] = icon
    end
end

function PANEL:GetVoterIcon(ply) 
    if IsValid(ply) then
        return self.voterIcons[ply:UniqueID()]
    end
    
    return nil
end

function PANEL:RemoveVoterIcon(ply) 
    if IsValid(ply) then
        self.voterIcons[ply:UniqueID()] = nil
    end
end

function PANEL:RemoveAllVoterIcons()
    for k, icon in pairs(self.voterIcons) do
    	icon:Remove()
    end
end

function PANEL:Think()
    local index_x = 0
    local index_y = 0
    for k, icon in pairs(self.voterIcons) do
        if IsValid(icon.player) then

            local ix, iy, iw, ih = icon:GetBounds()
            local lx, ly, lw, lh = self:GetAvatarLayoutPlaceBounds()
            
            -- check in which row we have to put the avatar icon
            if index_x % (math.floor(lw / iw)) == 0 then
                index_x = 0
                index_y = index_y + 1
            end

            local newx = lx + (iw * (index_x)) 
            local newy = ly + (ih * (index_y - 1))

            local newPosition = Vector(newx, newy, 0)

            -- move only if position changed
            if not icon.curPos or not (icon.curPos.x == newPosition.x and icon.curPos.y == newPosition.y) then
                icon.curPos = newPosition
                icon:SetPos(newPosition.x, newPosition.y)
            end

            index_x = index_x + 1
        else
            icon:Remove()
        end
    end
end

function PANEL:Blink()
    -- 7 repeats: 3 blinks + stay on blink-color status
    local blinks = 0
    MapVote.gui:SetVisible(true)  -- The votemenu will popup once the Map has been decided so everyone knows which map will come next even if they closed the GUI
    timer.Create("WinnerBlinkTimer", 0.3, 7, function()
        self.blink = not self.blink
        if self.blink and blinks < 3 then
            blinks = blinks + 1
            surface.PlaySound(Sound("buttons/blip1.wav"))
        end
    end)
end

--- we need to register the panel
vgui.Register("MapButton", PANEL, "DButton")
