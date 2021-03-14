if engine.ActiveGamemode() ~= "terrortown" then return end
include("shared.lua")
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