AddCSLuaFile()

include('autorun/jm_carepackage_loot.lua')


if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

ENT.Type                        = "anim"
ENT.PrintName                   = "Drop Spot"
ENT.Author                      = "Josh Mate"
ENT.Purpose                     = "Drops Loot"
ENT.Instructions                = "Drops Loot"
ENT.Spawnable                   = false
ENT.AdminSpawnable              = false

local dropSpotColour 			= Color( 0, 50, 255, 255)
local dropSpotSpawnDelayFirst 	= 25
local dropSpotSpawnDelaySecond 	= 45
local dropSpotDistanceOffFloor  = 60


function ENT:Initialize()
	self:SetModel("models/props_trainstation/TrackSign03.mdl") 
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:SetMaterial("joshmate/barrier")
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(dropSpotColour)

	-- Simple Use
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(false)
	end

	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(true, self:EntIndex(), "icon_warn_dropspot", self:GetPos(), 0, 0)

	-- Timers
	self.dropSpotTimeReady = CurTime() + dropSpotSpawnDelayFirst
	self.dropSpotAmountSpawned = 0
	self.dropSpotText = "???"

end

function CarePackageUsedEffect(ent)
	if not IsValid(ent) then return end
 
	local effect = EffectData()
	local ePos = ent:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	util.Effect("cball_explode", effect, true, true)
end

function ENT:Think()

	if CLIENT then return end

	if CurTime() >=  self.dropSpotTimeReady then

		self.dropSpotTimeReady = CurTime() + dropSpotSpawnDelaySecond
		self.dropSpotAmountSpawned = self.dropSpotAmountSpawned + 1

		if self.dropSpotAmountSpawned < 2 then
			self:EmitSound("0_main_click.wav")
			CarePackageUsedEffect(self)
			local ent = ents.Create("ent_jm_carepackage_detective")
			ent:SetPos(self:GetPos()  + Vector(0, 0, 0 - dropSpotDistanceOffFloor))
    		ent:Spawn()
		
		else
			CarePackageUsedEffect(self)
			self:Remove()
		end

	end

	self.dropSpotText = tostring(math.Round((self.dropSpotTimeReady - CurTime()), 0))
	self:SetNWString("dropSpotNWSTRStatus", self.dropSpotText)

end

-- Render 3D floating Text
hook.Add("PostDrawOpaqueRenderables", "drawDropSpotText", function()

	listofThings = ents.FindByClass( "ent_jm_equip_dropspot*" )

	-- Set all players Vars
	for i = 1, #listofThings do
		local thing = listofThings[i]
		if (thing:IsValid()) then
				-- Draw Song Name above radio in 3D space
				local pos = thing:GetPos() + Vector(0, 0, 0 - (dropSpotDistanceOffFloor / 2))
				
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

				draw.SimpleTextOutlined(thing:GetNWString("dropSpotNWSTRStatus", "???"), "DermaLarge", 0, -156, thingStatusColour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, Color(0,0,0,255))
				cam.End3D2D()
		end
	end	
end)

-- ESP Halo effect

hook.Add( "PreDrawHalos", "Halos_DropSpot", function()

    halo.Add( ents.FindByClass( "ent_jm_equip_dropspot*"), dropSpotColour, 2, 2, 3, true, true )
 
end )

function ENT:OnRemove()
	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())
end