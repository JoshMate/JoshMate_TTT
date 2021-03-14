AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

local JM_Tree_Duration				= 30
local JM_Tree_Radius				= 150
local JM_Tree_Heal_Amount			= 3
local JM_Tree_Heal_Delay			= 0.50

local JM_Tree_Colour				= Color( 0, 255, 80, 255 )
local JM_Tree_Sound_Placed			= "ambient/levels/canals/windchime4.wav"
local JM_Tree_Sound_Destroyed		= "physics/wood/wood_box_break1.wav"
local JM_Tree_Sound_Heal			= "ambient/levels/canals/windchime5.wav"

function ENT:Tree_Effects_Destroyed()
	if not IsValid(self) then return end
 
	local effect = EffectData()
	local ePos = self:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	util.Effect("TeslaZap", effect, true, true)
	util.Effect("TeslaHitboxes", effect, true, true)
	util.Effect("cball_explode", effect, true, true)
 end


function ENT:Tree_Die()
	if SERVER then
		if IsValid(self) then 
			self:Tree_Effects_Destroyed()
			self:EmitSound(JM_Tree_Sound_Destroyed);
			self:Remove()
		end 
	end
end

function DetectTreeStacking(ent)
	if not ent:IsValid() then return end

	local r = JM_Tree_Radius * JM_Tree_Radius -- square so we can compare with dot product directly
	local center = ent:GetPos()

	-- Destroy other trees to prevent stacking
	local d = 0.0
	local diff = nil
	local trees = ents.FindByClass( "ent_jm_tree" )
	
	for i = 1, #trees do
		local tree = trees[i]

		if not tree:IsValid() then continue end

		if tree == ent then continue end

		diff = center - tree:GetPos()
		d = diff:Dot(diff)

		if d >= (r*2.5)  then continue end
		tree:Tree_Die()
	end
end

function HealSphere(ent)
	
	if not ent:IsValid() then return end

	local r = JM_Tree_Radius * JM_Tree_Radius -- square so we can compare with dot product directly
	local center = ent:GetPos()

	-- Heal Players in radius
	d = 0.0
	diff = nil
	local plys = player.GetAll()

	for i = 1, #plys do
		local ply = plys[i]
		
		if not ply:Team() == TEAM_TERROR  or not ply:Alive() then continue end

		-- dot of the difference with itself is distance squared
		diff = center - ply:GetPos()
		d = diff:Dot(diff)

		if d >= r then continue end
		
		STATUS:AddTimedStatus(ply, "jm_treeoflife", 1, 1)

		if(ply:Health() >= ply:GetMaxHealth()) then continue end

		ent:EmitSound( JM_Tree_Sound_Heal )
		
		if ((ply:Health() + JM_Tree_Heal_Amount) > ply:GetMaxHealth()) then
			ply:SetHealth(ply:GetMaxHealth())
		else
			ply:SetHealth(ply:Health() + JM_Tree_Heal_Amount)
		end

	end

	

end



function ENT:Initialize()
	self:SetModel( "models/props_foliage/tree_deciduous_03a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_NONE )
	self:SetModelScale( 0.5)

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(false)
	end

	-- Play Place Sound
	self:EmitSound(JM_Tree_Sound_Placed);

	-- JoshMate Changed
	self:SetMaterial("joshmate/barrier")
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(JM_Tree_Colour) 
	self:DrawShadow(false)

	-- Timer to Heal Players
	local timerName = "timer_TreeHealSphere_" .. CurTime()
	timer.Create( timerName, JM_Tree_Heal_Delay, JM_Tree_Duration*2, function () DetectTreeStacking(self) HealSphere(self) end )

	-- Timer To Delete this Ent
	timer.Simple(JM_Tree_Duration, function() if IsValid(self) then  self:Tree_Die() end end)

end





function ENT:Use( activator, caller )
end

function ENT:Think()
end

function ENT:OnRemove()
end

function ENT:Touch(toucher)
end

-- Draw Visuals

if CLIENT then

	function ENT:Draw()
		self:DrawModel()
	end

end
