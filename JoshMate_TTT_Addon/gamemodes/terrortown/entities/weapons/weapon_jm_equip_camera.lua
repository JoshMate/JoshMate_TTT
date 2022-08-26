AddCSLuaFile()
if engine.ActiveGamemode() ~= "terrortown" then return end
SWEP.Base = "weapon_jm_base_gun"
SWEP.Author = "Josh Mate"
SWEP.HoldType = "normal"
SWEP.ViewModel = "models/dav0r/camera.mdl"
SWEP.WorldModel = "models/dav0r/camera.mdl"
SWEP.Kind = WEAPON_EQUIP2
SWEP.AutoSpawnable = false
SWEP.UseHands              = false

SWEP.CanBuy = {}

SWEP.LimitedStock = true
SWEP.AllowDrop = true

if CLIENT then 
    SWEP.PrintName = "CCTV Camera"
    SWEP.Slot = 7
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

    function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 25 - ang:Right() * -25 - ang:Up() * 10, ang
	end

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

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Place a CCTV camera", "Remove your placed CCTV camera", true)
 
	   return self.BaseClass.Initialize(self)
	end
end
-- Equip Bare Hands on Remove
if SERVER then
   function SWEP:OnRemove()
      if self:GetOwner():IsValid() and self:GetOwner():IsTerror() and self:GetOwner():Alive() then
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
      end
   end
end
-- Hide World Model when Equipped
function SWEP:DrawWorldModel()
   if IsValid(self:GetOwner()) then return end
   self:DrawModel()
end
function SWEP:DrawWorldModelTranslucent()
   if IsValid(self:GetOwner()) then return end
   self:DrawModel()
end
-- Delete on Drop
function SWEP:OnDrop() 
   self:Remove()
end

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################