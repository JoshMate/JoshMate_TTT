if engine.ActiveGamemode() ~= "terrortown" then return end
AddCSLuaFile()
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
resource.AddFile("materials/vgui/ttt/weapon_detective_camera.vmt")
resource.AddFile("materials/tttcamera/cameranoise.vmt")

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