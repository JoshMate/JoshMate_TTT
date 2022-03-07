AddCSLuaFile()

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

ENT.Type                        = "anim"
ENT.PrintName                   = "Time Bomb"
ENT.Author                      = "Josh Mate"
ENT.Purpose                     = "Ent"
ENT.Instructions                = "Ent"
ENT.Spawnable                   = false
ENT.AdminSpawnable              = false

function ENT:BombRadius(dmgowner, center, radius, damage)
	-- It seems intuitive to use FindInSphere here, but that will find all ents
	-- in the radius, whereas there exist only ~16 players. Hence it is more
	-- efficient to cycle through all those players and do a Lua-side distance
	-- check.

	local r = radius * radius -- square so we can compare with dot product directly

	-- pre-declare to avoid realloc
	local d = 0.0
	local diff = nil
	local dmg = 0
	local plys = player.GetAll()

	for i = 1, #plys do
		local ply = plys[i]

		if ply:Team() ~= TEAM_TERROR then continue end

		-- dot of the difference with itself is distance squared
		local distance = center:Distance(ply:GetPos())
		diff = center - ply:GetPos()
		d = diff:Dot(diff)

		if d >= r then continue end

		-- JM Changes, linear damage fall off
		
		dmg = damage * (1-( distance / radius))

		local dmginfo = DamageInfo()
		dmginfo:SetDamage(dmg)
		dmginfo:SetAttacker(dmgowner)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamageType(DMG_BLAST)
		dmginfo:SetDamageForce(center - ply:GetPos())
		dmginfo:SetDamagePosition(ply:GetPos())
		

		ply:TakeDamageInfo(dmginfo)
	end
end

function ENT:Initialize()
	self:SetModel("models/dav0r/tnt/tnttimed.mdl") 
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(true)
	end

	if SERVER then
		self:EmitSound("ticking_time_bomb_music.mp3", 120, 100, 1, CHAN_AUTO)
		local gusSongDurationSeconds = 30

		timer.Simple(gusSongDurationSeconds, function()

			if not self:IsValid() then return end

			local pos = self:GetPos()

			local effect = EffectData()
			effect:SetStart(pos)
			effect:SetOrigin(pos)
			util.Effect("Explosion", effect, true, true)
			util.Effect("HelicopterMegaBomb", effect, true, true)

			local JM_Gus_Explosive_Blast_Damage    = 125
			local JM_Gus_Explosive_Blast_Radius    = 2500

			-- Sound
			sound.Play("c4.explode", pos, 150, 100)
			sound.Play("c4_huge_boom.wav", pos, 150, 100)

			-- Blast
			self:BombRadius(self, pos, JM_Gus_Explosive_Blast_Radius, JM_Gus_Explosive_Blast_Damage)
			
			-- Done
			self:Remove()
		
		end)
	end

end



function ENT:Use( activator, caller )
end

function ENT:Think()
end
