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
        desc = [[Place a CCTV Camera
        
    Left Click to place the camera

    A screen will appear on your hud with a live streamed view
    of what the camera can see

    Infinite uses, but you can only have one camera active at once
    ]]
    }
end

function SWEP:PrimaryAttack()

    if SERVER then

        for _, v in ipairs(ents.FindByClass("ent_jm_equip_cctv")) do
            if v:GetNWEntity("JM_Camera_PlayerOwner")  == self:GetOwner() then
                v:Remove() -- if the player already has a camera, remove it
            end
        end

        local camera = ents.Create("ent_jm_equip_cctv")
        camera:SetPos(self:GetOwner():EyePos())
        camera:SetAngles(self:GetOwner():EyeAngles())
        camera:Spawn()
        camera:Activate()
        camera:SetNetworkedEntity("JM_Camera_PlayerOwner", self:GetOwner())
    end

    
end

function SWEP:SecondaryAttack()

    if SERVER then

        for _, v in ipairs(ents.FindByClass("ent_jm_equip_cctv")) do
            if v:GetNWEntity("JM_Camera_PlayerOwner") == self:GetOwner() then
                v:Remove() -- if the player already has a camera, remove it
            end
        end

    end

end

-- Hud Help Text
if CLIENT then
    function SWEP:Initialize()
       self:AddTTT2HUDHelp("Place a CCTV Camera", "Remove your CCTV Camera", true)
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