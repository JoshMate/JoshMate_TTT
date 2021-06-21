AddCSLuaFile()

ENT.Type                = "anim"
ENT.PrintName           = "CCTV Camera"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Camera"
ENT.Instructions        = "Camera"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false

local NOISE = Material("tttcamera/cameranoise")

function ENT:Initialize()
    self:SetModel("models/dav0r/camera.mdl")
    self:PhysicsInit(SOLID_NONE)
    self:SetSolid(SOLID_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_NONE)
    self:DrawShadow(false)
    self:SetModelScale(0.35, 0)
    self.OriginalY = self:GetAngles().y
end

function ENT:Think()
end

if CLIENT then

	function ENT:Draw()
		self:DrawModel()
	end

	hook.Add("HUDPaint", "JM_DrawCCTV_Window", function()
		local x = ScrW() / 3.7
		for k, ent in ipairs(ents.FindByClass("ent_jm_equip_cctv")) do
			if IsValid(ent) and ent:GetNWEntity("JM_Camera_PlayerOwner") == LocalPlayer() and LocalPlayer():Alive() then
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
				cdata.fov = 100
				cdata.znear = .1
				render.RenderView(cdata)
				IN_CAMERA = false
				cam.End2D()
				surface.SetDrawColor(Color(255, 255, 255, 3))
				surface.SetMaterial(NOISE)
				surface.DrawTexturedRect(ScrW() - x - 16, 14, ScrW() / 3.7 - 2, ScrH() / 3.7 - 2)
			end
		end
	end)
end


-- Josh Mate Changes Stop Cameras from surviving rounds
if SERVER then
	hook.Add("TTTPrepareRound", "ClearUpCCTVCameras", function()

		for k, ent in ipairs(ents.FindByClass("ent_jm_equip_cctv")) do
			if IsValid(ent) then
				ent:Remove()
			end
		end
	end)
end

if CLIENT then

	hook.Add("ShouldDrawLocalPlayer", "TTTCamera.DrawLocalPlayer", function(ply) return IN_CAMERA end)

end