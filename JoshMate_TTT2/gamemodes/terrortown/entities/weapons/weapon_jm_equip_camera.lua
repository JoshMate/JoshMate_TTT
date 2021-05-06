AddCSLuaFile()
if engine.ActiveGamemode() ~= "terrortown" then return end
SWEP.Base = "weapon_jm_base_gun"
SWEP.Author = "Josh Mate"
SWEP.HoldType = "normal"
SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/props/cs_office/Cardboard_box02.mdl"
SWEP.Kind = WEAPON_EQUIP2
SWEP.AutoSpawnable = false

SWEP.CanBuy = {ROLE_DETECTIVE}

SWEP.LimitedStock = true
SWEP.AllowDrop = true

if CLIENT then 
    SWEP.PrintName = "CCTV Camera"
    SWEP.Slot = 7
    SWEP.ViewModelFOV = 10
    SWEP.ViewModelFlip = false
    SWEP.Icon = "vgui/ttt/joshmate/icon_jm_camera.png"

    SWEP.EquipMenuData = {
        type = "item_weapon",
        name = "CCTV Camera",
        desc = [[Place down CCTV Camera
        
    Left Click to attached to a wall

    A screen will appear on your hud with a live streamed view
    of what the camera can see

    Your camera can be disconnected by anyone, but only you can pick it back up
    ]]
    }

    surface.CreateFont("JM_CCTVCAM_HUD_TEXT", {
        font = "Roboto",
        size = 32,
        weight = 800,
        antialias = true
    })

    function SWEP:PrimaryAttack()
        self.DrawInstructions = true
        RENDER_CONNECTION_LOST = false
    end

    function SWEP:Deploy()
        if IsValid(self:GetOwner()) then
            self:GetOwner():DrawViewModel(false)
        end

        return true
    end

    function SWEP:DrawWorldModel()
    end

    function SWEP:OnRemove()
        if IsValid(self:GetOwner()) and self:GetOwner() == LocalPlayer() then
            self:GetOwner():ConCommand("lastinv")
        end
    end

    surface.SetFont("TabLarge")
    local w = surface.GetTextSize("Use [Mouse UP/DOWN] to pitch the camera")

    function SWEP:DrawHUD()

        self.BaseClass.DrawHUD(self)

        if self.DrawInstructions then
            surface.SetFont("JM_CCTVCAM_HUD_TEXT")
            surface.SetTextColor(Color(255, 255, 255, 255))
            surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() / 2 + 50)
            surface.DrawText("Use [Mouse UP/DOWN] to pitch the camera")
        end
    end

    net.Receive("TTTCamera.Instructions", function()
        local p = LocalPlayer()

        if p.GetWeapon and IsValid(p:GetWeapon("weapon_jm_equip_camera")) then
            p:GetWeapon("weapon_jm_equip_camera").DrawInstructions = false
        end
    end)
end




function SWEP:Deploy()
    self:GetOwner():DrawViewModel(false)
    self:GetOwner():DrawWorldModel(false)
end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end

    local tr = util.TraceLine({
        start = self:GetOwner():GetShootPos(),
        endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 100,
        filter = self:GetOwner()
    })

    if IsValid(self.camera) and self.camera:GetShouldPitch() then
        self.camera:SetShouldPitch(false)
        self:Remove()
    end

    if tr.HitWorld and not self.camera then
        local camera = ents.Create("ttt_detective_camera")
        camera:SetPlayer(self:GetOwner())
        camera:SetPos(tr.HitPos - self:GetOwner():EyeAngles():Forward())
        camera:SetAngles((self:GetOwner():EyeAngles():Forward() * -1):Angle())
        camera:SetWelded(true)
        camera:Spawn()
        camera:Activate()
        camera:SetPos(tr.HitPos - self:GetOwner():EyeAngles():Forward())
        camera:SetAngles((self:GetOwner():EyeAngles():Forward() * -1):Angle())

        timer.Simple(0, function()
            constraint.Weld(camera, tr.Entity, 0, 0, 0, true)
        end)

        camera:SetShouldPitch(true)
        self.camera = camera
    end

    for _, v in ipairs(ents.FindByClass("ttt_detective_camera")) do
        if v:GetPlayer() == self:GetOwner() and v ~= self.camera then
            v:Remove() -- if the player already has a camera, remove it
        end
    end
end

-- Hud Help Text
if CLIENT then
    function SWEP:Initialize()
       self:AddTTT2HUDHelp("Place a CCTV Camera", nil, true)
    end
 end
 -- 

-- Josh Mate No World Model

function SWEP:OnDrop()
	self:Remove()
 end
  
 function SWEP:DrawWorldModel()
	return
 end
 
 function SWEP:DrawWorldModelTranslucent()
	return
 end
 
 -- END of Josh Mate World Model 