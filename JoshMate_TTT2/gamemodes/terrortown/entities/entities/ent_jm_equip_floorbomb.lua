AddCSLuaFile()

ENT.Type                = "anim"
ENT.PrintName           = "Floor Bomb"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Trap"
ENT.Instructions        = "Trap"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false


local JM_FloorBomb_Model            = "models/maxofs2d/button_02.mdl"
local JM_FloorBomb_Colour			= Color( 255, 0, 0, 255 )
local JM_FloorBomb_Sound_Triggered	= "floorbomb_triggered.mp3"
local JM_FloorBomb_Sound_Destroyed	= "0_main_click.wav"
      
local JM_FloorBomb_TriggerDelay     = 0.7
local JM_FloorBomb_DMG_Direct     	= 100
local JM_FloorBomb_DMG_Splash		= 25
local JM_FloorBomb_DMG_Radius		= 200

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

function ENT:Initialize()
	self:SetModel(JM_FloorBomb_Model)
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
	self:SetColor(JM_FloorBomb_Colour) 
	self:DrawShadow(false)

	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(true,self:EntIndex(),"icon_warn_floorbomb",self:GetPos(),0,true)

	-- Setup Trigger
	self.floorBombHasBeenTriggered 	= false
	self.floorBombTriggeredTime 	= 0
	self.floorBombTriggeredTarget 	= 0

end

function ENT:Use( activator, caller )

	if CLIENT then return end

    if IsValid(activator) and activator:IsPlayer() and IsValid(self) then

		if activator:IsTerror() and activator:HasEquipmentItem("item_jm_passive_bombsquad") then
            self:Effect_Sparks()
            -- When removing this ent, also remove the HUD icon, by changing isEnabled to false
			JM_Function_SendHUDWarning(false,self:EntIndex())
			JM_Function_PrintChat(self.Owner, "Equipment","Someone has defused your Floor Bomb...")
			self:EmitSound(JM_FloorBomb_Sound_Destroyed);
			self:Remove()
		else
			JM_Function_PrintChat(activator, "Equipment","You need Bomb Squad to be able to defuse this...")
		end

	end

end

function ENT:Think()

	if CLIENT then return end

	if self.floorBombHasBeenTriggered == true then

		if CurTime() >= self.floorBombTriggeredTime + JM_FloorBomb_TriggerDelay then


			if not self:IsValid() or not self.floorBombTriggeredTarget:IsValid() then return end

			-- Deal direct damage to toucher
			if self.floorBombTriggeredTarget:GetPos():Distance(self:GetPos()) <= JM_FloorBomb_DMG_Radius then
				local dmg = DamageInfo()
				dmg:SetDamage(JM_FloorBomb_DMG_Direct)
				dmg:SetAttacker(self.Owner)
				dmg:SetInflictor(self)
				dmg:SetDamageForce(Vector(0, 0, 1))
				dmg:SetDamagePosition(self:GetPos())
				dmg:SetDamageType(DMG_BLAST)   

				self.floorBombTriggeredTarget:TakeDamageInfo(dmg)
			end

			-- Create splash damage explosion
			local effect = EffectData()
			effect:SetStart(self:GetPos())
			effect:SetOrigin(self:GetPos())
			util.Effect("Explosion", effect, true, true)
			util.Effect("HelicopterMegaBomb", effect, true, true)

			-- Blast
			util.BlastDamage(self, self.Owner, self:GetPos(), JM_FloorBomb_DMG_Radius, JM_FloorBomb_DMG_Splash)
			
			-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
			JM_Function_SendHUDWarning(false,self:EntIndex())
			self:Remove()

		end

	end

end

function ENT:Touch(toucher)

	if SERVER then

		if self.floorBombHasBeenTriggered == true then return end

        if(not toucher:IsValid()) then return end
        if(not toucher:IsPlayer()) then return end
        if(not toucher:IsTerror()) then return end
        if(not toucher:Alive()) then return end
        if(not GAMEMODE:AllowPVP()) then return end

		-- Trigger Settings
		self.floorBombHasBeenTriggered 	= true
		self.floorBombTriggeredTime 	= CurTime()
		self.floorBombTriggeredTarget 	= toucher

		-- Effects
		self:EmitSound(JM_FloorBomb_Sound_Triggered)
		self:Effect_Sparks()

		-- Give a Hit Marker to This Player
		local hitMarkerOwner = self.Owner
		JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)

        -- HUD Message
		JM_Function_PrintChat(toucher, "Equipment","You have triggered a Floor Bomb!")
		JM_Function_PrintChat(self.Owner, "Equipment",toucher:Nick() .. " has triggered your Floor Bomb!" )
        -- End Of
        
	end
end

function ENT:Effect_Sparks()

	if not IsValid(self) then return end

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
