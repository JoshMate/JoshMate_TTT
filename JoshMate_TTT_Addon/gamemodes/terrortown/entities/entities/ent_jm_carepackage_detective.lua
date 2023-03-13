AddCSLuaFile()

include('autorun/jm_carepackage_loot.lua')


if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

ENT.Type                        = "anim"
ENT.PrintName                   = "Detective Care Package"
ENT.Author                      = "Josh Mate"
ENT.Purpose                     = "Drops Loot"
ENT.Instructions                = "Drops Loot"
ENT.Spawnable                   = false
ENT.AdminSpawnable              = false

local detectiveCarePackageLootDelay = 30

function ENT:Initialize()
	self:SetModel("models/Items/item_item_crate.mdl") 
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(Color( 0, 50, 255, 150))

	-- Simple Use
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(true)
	end

	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(true, self:EntIndex(), "icon_warn_carepackage_detective", self:GetPos(), 0, 0)

	-- Timers
	self.detectiveCarePackageTimeReady = CurTime() + detectiveCarePackageLootDelay
	self.detectiveCarePackageIsReady = false
	self.detectiveCarePackageText = "???"

end

function CarePackageUsedEffect(ent)
	if not IsValid(ent) then return end
 
	local effect = EffectData()
	local ePos = ent:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	
	
	util.Effect("cball_explode", effect, true, true)
end


function ENT:Use( activator, caller )

	if IsValid(activator) and activator:IsPlayer() and IsValid(self) then

		if activator:IsTerror() and activator:Alive() then

			if self.detectiveCarePackageIsReady == false then
				JM_Function_PrintChat(activator, "Equipment", "This carepackage is not lootable yet...")
				return
			end

			if activator:IsDetective() then
				JM_Function_PrintChat(activator, "Equipment", "Only Non-Detectives can take a Detective Care Package")
				return
			end
			
			-- All Care Packages

			self:EmitSound("carepackage_open.wav")
			CarePackageUsedEffect(self)

			-- Handle Loot
			JM_CarePackage_Use_LootMaster(activator,self)
		
			self:Remove()
		end
	end
end

function ENT:Think()

	if self.detectiveCarePackageIsReady == false then
		self.detectiveCarePackageText = tostring(math.Round((self.detectiveCarePackageTimeReady - CurTime()), 0))
	end


	if self.detectiveCarePackageIsReady == false and CurTime() >=  self.detectiveCarePackageTimeReady then

		self.detectiveCarePackageIsReady = true
		self:SetColor(Color( 0, 50, 255, 255))
		self.detectiveCarePackageText = "Ready!"

	end

	self:SetNWString("detectiveCarePackageNWSTRStatus", self.detectiveCarePackageText)

end

-- Render 3D floating Text
hook.Add("PostDrawOpaqueRenderables", "drawDetectiveCarePackageText", function()

	listofThings = ents.FindByClass( "ent_jm_carepackage_detective*" )

	-- Set all players Vars
	for i = 1, #listofThings do
		local thing = listofThings[i]
		if (thing:IsValid()) then
				-- Draw Song Name above radio in 3D space
				local pos = thing:GetPos()
				
				-- Get the game's camera angles
				local angle = EyeAngles()

				-- Only use the Yaw component of the angle
				angle = Angle( 0, angle.y, 0 )

				-- Correct the angle so it points at the camera
				-- This is usually done by trial and error using Up(), Right() and Forward() axes
				angle:RotateAroundAxis( angle:Up(), -90 )
				angle:RotateAroundAxis( angle:Forward(), 90 )

				cam.Start3D2D(pos, angle, 0.3)

				-- Decide font colours
				local thingStatusColour = Color(255,255,255,255)

				draw.SimpleTextOutlined(thing:GetNWString("detectiveCarePackageNWSTRStatus", "???"), "DermaLarge", 0, -96, thingStatusColour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, Color(0,0,0,255))
				cam.End3D2D()
		end
	end	
end)

-- ESP Halo effect

local JM_CarePackage_Halo_Colour = Color(150,0,255,255)

hook.Add( "PreDrawHalos", "Halos_CarePackage", function()

    halo.Add( ents.FindByClass( "ent_jm_carepackage*" ), JM_CarePackage_Halo_Colour, 2, 2, 3, true, true )
 
end )



function ENT:OnRemove()
	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())
end