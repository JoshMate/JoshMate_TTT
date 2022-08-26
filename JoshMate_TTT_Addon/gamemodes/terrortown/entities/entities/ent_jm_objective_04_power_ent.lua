if SERVER then
	AddCSLuaFile()
else
	ENT.PrintName = "Battery"
end

ENT.Type = "anim"
ENT.Model = Model("models/items/car_battery01.mdl")

function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(Color( 255, 255, 0, 30))
	
	-- Battery Stats
	self.isBatteryActive = false
	self.isBatteryActiveDelay = 15
	self.isBatteryActiveTime = CurTime() + self.isBatteryActiveDelay

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(true,self:EntIndex(),"icon_warn_objective_battery",self:GetPos(),0,0)
end

function ENT:Use( activator, caller )

	if CLIENT then return end

	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

    if IsValid(activator) and activator:IsPlayer() and IsValid(self) and activator:IsTerror() and activator:Alive() then

		if activator:GetActiveWeapon():GetClass() == "weapon_jm_special_hands" then 
			if self.isBatteryActive == true then 
				JM_Function_Karma_Reward(activator, JM_KARMA_REWARD_ACTION_OBJECTIVE_Battery, "Battery captured")
				self:BatteryUse() 
			else
				JM_Function_PrintChat(activator, "Powerup", "This Battery will be usable in: " .. tostring(math.Round((self.isBatteryActiveTime - CurTime()))) .. " seconds" )
			end
		else
			JM_Function_PrintChat(activator, "Powerup", "You need your hands free to do that...")
		end

	end
end

function ENT:Think()

	if self.isBatteryActive == false and CurTime() >= self.isBatteryActiveTime then
		self.isBatteryActive = true
		if SERVER then self:EmitSound("gamemode/power_ready.mp3") end
		self:SetColor(Color( 255, 255, 0, 255))
	end

end


function ENT:BatteryUse() 
	if CLIENT then return end
	JM_Function_SendHUDWarning(false,self:EntIndex())
	

	self.batteryMaster:SpawnNextBattery()

	self:Remove()
end

function ENT:OnRemove()
	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())
end

-- ESP Halo effect

local JM_Battery_Halo_Colour = Color(255,255,0,255)

hook.Add( "PreDrawHalos", "Halos_Files", function()

    halo.Add( ents.FindByClass( "ent_jm_objective_04_power_ent" ), JM_Battery_Halo_Colour, 5, 5, 2, true, true )
 
end )