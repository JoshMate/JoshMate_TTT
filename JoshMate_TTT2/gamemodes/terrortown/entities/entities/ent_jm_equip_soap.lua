AddCSLuaFile()

ENT.Type                = "anim"
ENT.PrintName           = "Soap"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Trap"
ENT.Instructions        = "Trap"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false


local JM_Soap_Model                 = "models/soap.mdl"
local JM_Soap_Colour_Active         = Color( 255, 255, 255, 25 )
local JM_Soap_Sound_HitPlayer       = "slip.wav"
local JM_Soap_Sound_Destroyed       = "0_main_click.wav"

local JM_Soap_Velocity_Up 			= 700
local JM_Soap_Velocity_Direction	= 1500

ENT.Velocity_Soap_UP				= nil
ENT.Velocity_Soap_Direction			= nil


if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

function ENT:Initialize()
	self:SetModel(JM_Soap_Model)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(false)
	end

	-- Simple Use
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	-- JoshMate Changed
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(JM_Soap_Colour_Active) 
	self:DrawShadow(false)

	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(true,self:EntIndex(),"icon_warn_soap",self:GetPos(),0,true)

end

function ENT:Use( activator, caller )

	if CLIENT then return end

    if IsValid(activator) and activator:IsPlayer() and IsValid(self) then

		if activator:IsTerror() then

			if activator:GetActiveWeapon():GetClass() == "weapon_jm_special_hands" then 
				JM_Function_PrintChat(self.Owner, "Equipment","Your Soap has been destroyed!")
				self:Effect_Sparks()
				-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
				JM_Function_SendHUDWarning(false,self:EntIndex())
				self:Remove()
			else
				JM_Function_PrintChat(activator, "Equipment", "You need your hands free to do that...")
			end

		end
		
	end

end

function ENT:Touch(toucher)

	if SERVER then

        if(not toucher:IsValid()) then return end
        if(not toucher:IsPlayer()) then return end
        if(not toucher:IsTerror()) then return end
        if(not toucher:Alive()) then return end
        if(not GAMEMODE:AllowPVP()) then return end

		-- Drop currently Held Weapon
		local curWep = toucher:GetActiveWeapon()
		if (toucher:GetActiveWeapon():PreDrop()) then toucher:GetActiveWeapon():PreDrop() end
		if (curWep.AllowDrop) then
			toucher:DropWeapon()
		end
		toucher:SelectWeapon("weapon_jm_special_crowbar")
		-- End of Drop

		-- Soap Launch Effect

		if toucher:HasEquipmentItem("item_jm_passive_bombsquad") then 
			self.Velocity_Soap_UP 			=  JM_Soap_Velocity_Up / 2
			self.Velocity_Soap_Direction 	=  JM_Soap_Velocity_Direction / 2
		else
			self.Velocity_Soap_UP 			=  JM_Soap_Velocity_Up
			self.Velocity_Soap_Direction 	=  JM_Soap_Velocity_Direction
		end

		self:EmitSound(JM_Soap_Sound_HitPlayer)
		local directionFacing = toucher:GetAimVector()
		local upwards = Vector( 0, 0, self.Velocity_Soap_UP)
		local directionWithoutY = Vector(directionFacing.x, directionFacing.y, 0)
		local velocity = (directionWithoutY * self.Velocity_Soap_Direction)  + upwards
		toucher:SetVelocity(velocity);
		-- End Of

		-- Give a Hit Marker to This Player
		local hitMarkerOwner = self.Owner
		JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)

        -- HUD Message
		JM_Function_PrintChat(toucher, "Equipment","You have slipped on some Soap!")
		JM_Function_PrintChat(self.Owner, "Equipment",toucher:GetName() .. " has slipped on your Soap!" )
        -- End Of

        toucher:EmitSound(JM_Soap_Sound_HitPlayer);
        self:Effect_Sparks()
        -- When removing this ent, also remove the HUD icon, by changing isEnabled to false
		JM_Function_SendHUDWarning(false,self:EntIndex())
        self:Remove()
	
	end
end

function ENT:Effect_Sparks()

	if not IsValid(self) then return end
    
    self:EmitSound(JM_Soap_Sound_Destroyed);

	local effect = EffectData()
	local ePos = self:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	
	
	util.Effect("cball_explode", effect, true, true)

end

function ENT:OnRemove()
	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())
end
