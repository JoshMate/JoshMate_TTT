AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_eq_flashbang_thrown.mdl")

ENT.JM_Fire_Damage                  = 4
ENT.JM_Fire_Damage_Delay            = 0.2
ENT.JM_Fire_Damage_Delay_Start      = 0
ENT.JM_Fire_Duration                = 30
ENT.JM_Fire_Duration_Start          = 0
ENT.JM_Fire_Size_Sprite             = 128
ENT.JM_Fire_Size_Radius             = 100
ENT.JM_Fire_Child                   = nil


function ENT:Initialize()
   self:SetModel(self.Model)
   self:DrawShadow(false)
   self:SetNoDraw(true)

   self:PhysicsInit(SOLID_VPHYSICS)
   self:SetMoveType(MOVETYPE_VPHYSICS)
   self:SetSolid(SOLID_VPHYSICS)
   self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
   self:SetHealth(99999)

   -- Create Fire Ent
   if SERVER then
    local fire = ents.Create("env_fire")
    if not IsValid(fire) then return end

    fire:SetParent(self)
    fire:SetOwner(self:GetOwner())
    fire:SetPos(self:GetPos())
    --no glow + delete when out + start on + last forever
    fire:SetKeyValue("spawnflags", tostring(128 + 32 + 4 + 2 + 1))
    fire:SetKeyValue("firesize", self.JM_Fire_Size_Sprite)
    fire:SetKeyValue("fireattack", 0)
    fire:SetKeyValue("health", 9999)
    fire:SetKeyValue("damagescale", "-10") -- only neg. value prevents dmg

    fire:Spawn()
    fire:Activate()

    self.JM_Fire_Child = fire
    self.JM_Fire_Duration_Start = CurTime()
    self.JM_Fire_Damage_Delay_Start  = CurTime()
   end


end

function RadiusDamage(dmginfo, pos, radius, inflictor)
   for k, vic in ipairs(ents.FindInSphere(pos, radius)) do

        if IsValid(vic) then
            if vic:IsPlayer() and vic:Alive() and vic:Team() == TEAM_TERROR then
                -- Deal Damage to players in the radius
                vic:TakeDamageInfo(dmginfo)
            end
        end
   end
end

function ENT:OnRemove()
   if IsValid(self.JM_Fire_Child) then
      self.JM_Fire_Child:Remove()
   end
end

function ENT:OnTakeDamage()
end


function ENT:Think()
   if CLIENT then return end

    -- Delete this and put out the fire if underwater
    if self:WaterLevel() > 0 then
        self.JM_Fire_Child:Remove()
        self:Remove()
        return
    end

    -- Delete the fire when it burns out
    if self.JM_Fire_Duration_Start + self.JM_Fire_Duration <= CurTime() then
        if IsValid(self.JM_Fire_Child) then
            self.JM_Fire_Child:Remove()
        end
        self:Remove()
        return
    end

    if self.JM_Fire_Damage_Delay_Start + self.JM_Fire_Damage_Delay <= CurTime() then
            
        -- deal damage

        local dmg = DamageInfo()
        dmg:SetDamageType(DMG_BURN)
        dmg:SetDamage(self.JM_Fire_Damage)

        if IsValid(self:GetOwner()) then
            dmg:SetAttacker(self:GetOwner())
        else
            dmg:SetAttacker(self)
        end
        dmg:SetInflictor(self.JM_Fire_Child)

        RadiusDamage(dmg, self:GetPos(), self.JM_Fire_Size_Radius, self)

        self.JM_Fire_Damage_Delay_Start = CurTime()
    end
end

function ENT:Draw()
    return false
end