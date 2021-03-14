if engine.ActiveGamemode() ~= "terrortown" then return end
include("shared.lua")

function ENT:Draw()
    self:DrawModel()
end

surface.CreateFont("DermaExtraLarge", {
    font = "Roboto",
    size = 48,
    weight = 800,
    antialias = true
})

local RENDER_CONNECTION_LOST = false
local NOISE = Material("tttcamera/cameranoise")

hook.Add("HUDPaint", "DrawCameraScreen", function()
    local x = ScrW() / 3.7

    for k, ent in ipairs(ents.FindByClass("ttt_detective_camera")) do
        if IsValid(ent) and ent:GetPlayer() == LocalPlayer() and ent:GetWelded() and LocalPlayer():Alive() and not RENDER_CONNECTION_LOST then
            cam.Start2D()
            IN_CAMERA = true
            LocalPlayer():DrawShadow(false)
            surface.SetDrawColor(Color(0, 0, 0))
            surface.DrawRect(ScrW() - x - 16, 14, x, ScrH() / 3.7)
            surface.SetDrawColor(color_white)
            local cdata = {}
            cdata.origin = ent:GetPos() + ent:GetAngles():Forward() * 3 + ent:GetAngles():Right() * -1
            cdata.angles = ent:GetAngles()
            cdata.x = ScrW() - x - 15
            cdata.y = 15
            cdata.w = x - 2
            cdata.h = ScrH() / 3.7 - 2
            cdata.fov = 90
            cdata.znear = .1
            render.RenderView(cdata)
            IN_CAMERA = false
            cam.End2D()
            surface.SetDrawColor(Color(255, 255, 255, 3))
            surface.SetMaterial(NOISE)
            surface.DrawTexturedRect(ScrW() - x - 16, 14, ScrW() / 3.7 - 2, ScrH() / 3.7 - 2)
        end
    end

    if RENDER_CONNECTION_LOST and LocalPlayer():Alive() then
        surface.SetDrawColor(Color(0, 0, 0))
        surface.DrawRect(ScrW() - x - 18, 14, x, ScrH() / 3.7)
        surface.SetDrawColor(Color(160, 160, 160))
        surface.SetMaterial(NOISE)
        surface.DrawTexturedRect(ScrW() - x - 17, 15, x - 2, ScrH() / 3.7 - 2)
        surface.SetFont("DermaExtraLarge")
        local w, h = surface.GetTextSize("CONNECTION LOST")
        surface.SetTextPos(ScrW() - 17 - x / 2 - w / 2 - 2, (ScrH() / 3.7) / 2 - h / 3.7 - 1)
        surface.SetTextColor(Color(0, 0, 0))
        surface.DrawText("CONNECTION LOST")
        surface.SetTextPos(ScrW() - 17 - x / 2 - w / 2, (ScrH() / 3.7) / 2 - h / 3.7)
        surface.SetTextColor(Color(255, 0, 0))
        surface.DrawText("CONNECTION LOST")
    end
end)

net.Receive("TTTCameraDetach", function()
    if RENDER_CONNECTION_LOST then return end
    surface.PlaySound("ambient/energy/spark5.wav")
    RENDER_CONNECTION_LOST = true

    timer.Simple(2, function()
        RENDER_CONNECTION_LOST = false
    end)
end)

hook.Add("ShouldDrawLocalPlayer", "TTTCamera.DrawLocalPlayer", function(ply) return IN_CAMERA end)