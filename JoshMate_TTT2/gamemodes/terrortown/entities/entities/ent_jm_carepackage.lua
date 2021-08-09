AddCSLuaFile()

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

ENT.Type                        = "anim"
ENT.PrintName                   = "Care Package"
ENT.Author                      = "Josh Mate"
ENT.Purpose                     = "Drops Loot"
ENT.Instructions                = "Drops Loot"
ENT.Spawnable                   = false
ENT.AdminSpawnable              = false

function ENT:Initialize()
	self:SetModel("models/Items/item_item_crate.mdl") 
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(true)
	end

	if SERVER then self:SendWarn(true) end 

end

function Loot_SpawnThis(carepackage,thingToSpawn)
	local ent = ents.Create(thingToSpawn)
	ent:SetPos(carepackage:GetPos())
    ent:Spawn()
end

function CarePackageUsedEffect(ent)
	if not IsValid(ent) then return end
 
	local effect = EffectData()
	local ePos = ent:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	util.Effect("TeslaZap", effect, true, true)
	
	util.Effect("cball_explode", effect, true, true)
end


function ENT:Use( activator, caller )

	if IsValid(activator) and activator:IsPlayer() and IsValid(self) then

		if activator:IsTerror() and activator:Alive() then
			
			-- All Care Packages

			self:EmitSound("carepackage_open.wav")
			CarePackageUsedEffect(self)

			-- Random Roller
			
			local RNGGoodOrBad = math.random(1, 100)
			local ChanceOfBad	= 25 -- Change of Good will be 100 minus this number

			
			if (RNGGoodOrBad <= ChanceOfBad) then
				
				self:Loot_Bad( activator, caller )

			else

				self:Loot_Good( activator, caller )

			end
		
			self:Remove()

		end
		
	end
	
end

function ENT:Think()
end

-- ESP Halo effect

local JM_CarePackage_Halo_Colour = Color(150,0,255,255)

hook.Add( "PreDrawHalos", "Halos_CarePackage", function()

    halo.Add( ents.FindByClass( "ent_jm_carepackage*" ), JM_CarePackage_Halo_Colour, 5, 5, 2, true, true )
 
 end )

 -- ESP Halo effect
hook.Add( "PreDrawHalos", "Halos_Mega_Tracker", function()

	local players = {}
	local count = 0
 
	 for _, ply in ipairs( player.GetAll() ) do
		 if (ply:IsTerror() and ply:Alive() and ply:GetNWBool("isMegaTracked") ) then
			 count = count + 1
			 players[ count ] = ply
		 end
	 end
 
	 halo.Add( players, Color( 255, 255, 0 ), 2, 2, 3, true, true )
 
 end )


 -- ####################################################
 -- ###### Care Package Loot
 -- ####################################################

function ENT:Loot_Good( activator, caller ) 

	local RNG_Good = math.random(1, 17)

	if RNG_Good == 1 then
		activator:ChatPrint("[Care Package] - Good Loot: Advanced Pistol")
		Loot_SpawnThis(self,"weapon_jm_zloot_advanced_pistol")
	end

	if RNG_Good == 2 then
		activator:ChatPrint("[Care Package] - Good Loot: Advanced SMG")
		Loot_SpawnThis(self,"weapon_jm_zloot_advanced_smg")
	end

	if RNG_Good == 3 then
		activator:ChatPrint("[Care Package] - Good Loot: Advanced Shotgun")
		Loot_SpawnThis(self,"weapon_jm_zloot_advanced_shotgun")
	end
	
	if RNG_Good == 4 then
		activator:ChatPrint("[Care Package] - Good Loot: Advanced Rifle")
		Loot_SpawnThis(self,"weapon_jm_zloot_advanced_rifle")
	end

	if RNG_Good == 5 then
		activator:ChatPrint("[Care Package] - Good Loot: Advanced Sniper")
		Loot_SpawnThis(self,"weapon_jm_zloot_advanced_sniper")
	end

	if RNG_Good == 6 then
		activator:ChatPrint("[Care Package] - Good Loot: Health Boost")
		activator:SetMaxHealth(activator:GetMaxHealth() + 100)
		JM_GiveBuffToThisPlayer("jm_buff_regeneration", activator, self)
	end

	if RNG_Good == 7 then
		activator:ChatPrint("[Care Package] - Good Loot: Speed Boost")
		JM_GiveBuffToThisPlayer("jm_buff_speedboost", activator, self)
	end

	if RNG_Good == 8 then
		activator:ChatPrint("[Care Package] - Good Loot: Mega Frag Grenade")
		Loot_SpawnThis(self,"weapon_jm_zloot_mega_frag")
	end

	if RNG_Good == 9 then
		activator:ChatPrint("[Care Package] - Good Loot: Ninja Blade")
		Loot_SpawnThis(self,"weapon_jm_zloot_ninjablade")
	end

	if RNG_Good == 10 then
		Loot_SpawnThis(self,"npc_pigeon")
		if(activator:IsTraitor() or activator:IsDetective()) then
			activator:ChatPrint("[Care Package] - Good Loot: - Pigeon? (+2 Credits)")
			activator:AddCredits(2)
		else
			activator:ChatPrint("[Care Package] - Good Loot: - Pigeon? (You have been made a Detective!)")
			activator:SetRole(ROLE_DETECTIVE)
			SendFullStateUpdate()
			activator:AddCredits(3)
		end
	end

	if RNG_Good == 11 then
		activator:ChatPrint("[Care Package] - Good Loot: Prop Launcher")
		Loot_SpawnThis(self,"weapon_jm_zloot_prop_launcher")
	end

	if RNG_Good == 12 then
		activator:ChatPrint("[Care Package] - Good Loot: Rapid Fire")
		JM_GiveBuffToThisPlayer("jm_buff_rapidfire", activator, self)
	end

	if RNG_Good == 13 then
		activator:ChatPrint("[Care Package] - Good Loot: Portable Tester")
		Loot_SpawnThis(self,"weapon_jm_zloot_traitor_tester")
		
	end

	if RNG_Good == 14 then
		activator:ChatPrint("[Care Package] - Good Loot: Big Boy")
		Loot_SpawnThis(self,"weapon_jm_zloot_explosive_gun")
		
	end

	if RNG_Good == 15 then
		activator:ChatPrint("[Care Package] - Good Loot: Shredder")
		Loot_SpawnThis(self,"weapon_jm_zloot_shredder")
		
	end	

	if RNG_Good == 16 then
		activator:ChatPrint("[Care Package] - Good Loot: Silenced Pistol")
		Loot_SpawnThis(self,"weapon_jm_zloot_silenced_pistol")
		
	end	

	if RNG_Good == 17 then
		activator:ChatPrint("[Care Package] - Good Loot: Barrel Swep")
		Loot_SpawnThis(self,"weapon_jm_zloot_barrel")
		
	end	

	

 end

function ENT:Loot_Bad( activator, caller ) 

	local RNG_Bad = math.random(1, 11)

	if RNG_Bad == 1 then
		activator:ChatPrint("[Care Package] - Bad Loot: Best Friend")
		Loot_SpawnThis(self,"npc_rollermine")
	end

	if RNG_Bad == 2 then
		activator:ChatPrint("[Care Package] - Bad Loot: Pigeon")
		Loot_SpawnThis(self,"npc_pigeon")
	end

	if RNG_Bad == 3 then
		activator:ChatPrint("[Care Package] - Bad Loot: Gus Radio (SAFE)")
		Loot_SpawnThis(self,"ent_jm_zloot_radio_gus")
	end

	if RNG_Bad == 4 then
		activator:ChatPrint("[Care Package] - Bad Loot: Mega Tracker")
		
		net.Start("JM_ULX_Announcement")
		net.WriteString("Care Package: You are all being tracked!")
		net.WriteUInt(0, 16)
		net.Broadcast()

		for _, ply in ipairs( player.GetAll() ) do
			if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
				if SERVER then ply:EmitSound(Sound("ping_jake.wav")) end
				JM_GiveBuffToThisPlayer("jm_buff_megatracker",ply,self)
			end
		end
	end

	if RNG_Bad == 5 then
		activator:ChatPrint("[Care Package] - Bad Loot: Godzilla")
		if SERVER then activator:EmitSound(Sound("godzillaroar.wav")) end

		local pushForce = 10000
		local pos = self:GetPos()
		local tpos = activator:LocalToWorld(activator:OBBCenter())
        local dir = (tpos - pos):GetNormal()

		local push = dir * pushForce
		local vel = activator:GetVelocity() + push

		activator:SetVelocity(vel)
		

	end

	if RNG_Bad == 6 then
		activator:ChatPrint("[Care Package] - Bad Loot: Tripping Balls")
		JM_GiveBuffToThisPlayer("jm_buff_trippingballs", activator, self)
	end

	if RNG_Bad == 7 then

		net.Start("JM_ULX_Announcement")
		net.WriteString("Care Package: Gravity is now much weaker!")
		net.WriteUInt(0, 16)
		net.Broadcast()

		activator:ChatPrint("[Care Package] - Bad Loot: Low Gravity")
		RunConsoleCommand("sv_gravity", 100)
		RunConsoleCommand("sv_airaccelerate", 12)
		for _, ply in ipairs( player.GetAll() ) do
			if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
				if SERVER then ply:EmitSound(Sound("effect_low_gravity.mp3")) end
			end
		end
	end

	if RNG_Bad == 8 then

		net.Start("JM_ULX_Announcement")
		net.WriteString("Care Package: The floors are now slippery!")
		net.WriteUInt(0, 16)
		net.Broadcast()

		activator:ChatPrint("[Care Package] - Bad Loot: Slippery Floors")
		RunConsoleCommand("sv_friction", 0)
		RunConsoleCommand("sv_accelerate", 5)
		for _, ply in ipairs( player.GetAll() ) do
			if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
				if SERVER then ply:EmitSound(Sound("effect_slippery_floors.mp3")) end
			end
		end
	end

	if RNG_Bad == 9 then

		local PossibleVictims = {}

		-- Find out who is eligible to be swapped

		for _, ply in ipairs( player.GetAll() ) do

			if (ply:IsValid() and ply:IsTerror() and ply:Alive() and not ply:Crouching()) then

				if ply:GetPos():Distance(activator:GetPos()) >= 32  then
					PossibleVictims[#PossibleVictims+1] = ply
				end				
			end
			
		end

		-- Work out who the victim is

		local Victim = nil

		if #PossibleVictims < 1 then 

			activator:ChatPrint("[Care Package] - Bad Loot: Teleportation (Random Place)")
			local possibleSpawns = ents.FindByClass( "info_player_start" )
			Victim = table.Random(possibleSpawns)
			-- Perform the actual swap
			local PosActivator 	= activator:GetPos()
			local PosVictim 	= Victim:GetPos()
			activator:SetPos(PosVictim)
			if SERVER then activator:EmitSound(Sound("effect_swapping_places.mp3")) end
			
		else

			activator:ChatPrint("[Care Package] - Bad Loot: Teleportation (Swapped with another player)")
            Victim = PossibleVictims[ math.random( #PossibleVictims ) ]
			-- Perform the actual swap
			local PosActivator = activator:GetPos()
			local PosVictim = Victim:GetPos()
			activator:SetPos(PosVictim)
			Victim:SetPos(PosActivator)
			if SERVER then activator:EmitSound(Sound("effect_swapping_places.mp3")) end
			if SERVER then Victim:EmitSound(Sound("effect_swapping_places.mp3")) end
			Victim:ChatPrint("[Care Package] - Bad Loot: Teleportation (Swapped with another player)")

		end
		

		
	end

	if RNG_Bad == 10 then
		activator:ChatPrint("[Care Package] - Bad Loot: Ticking Time Bomb")
		Loot_SpawnThis(self,"ent_jm_zloot_timebomb")
	end

	if RNG_Bad == 11 then
		activator:ChatPrint("[Care Package] - Bad Loot: 1 HP")
		activator:SetHealth(1)
	end

end

--- Josh Mate Hud Warning
if SERVER then
	function ENT:SendWarn(armed)
		net.Start("TTT_LootWarn")
		net.WriteUInt(self:EntIndex(), 16)
		net.WriteBit(armed)

		if armed then
			net.WriteVector(self:GetPos())
		end

		net.Broadcast()
	end

	function ENT:OnRemove()
		self:SendWarn(false)
	end
end


if SERVER then
	--- Josh Mate Reset Gravity Etc...
	--Remove This Buff at the start of the round
	hook.Add("TTTPrepareRound", "JM_Prep_Reset_CVars", function()
		RunConsoleCommand("sv_gravity", 600)
		RunConsoleCommand("sv_friction", 8)
		RunConsoleCommand("sv_airaccelerate", 10)
		RunConsoleCommand("sv_accelerate", 10)
	end)
end