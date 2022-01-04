-- burning nade projectile

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/props_junk/PopCan01a.mdl")

ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(200,150,0,150)

local InfernoLauncher_NumberOfNades    = 12
local InfernoLauncher_FuseDelay        = 3


function ENT:Explode(tr)
   if SERVER then

      self:SetNoDraw(true)
      self:SetSolid(SOLID_NONE)
      -- pull out of the surface
      if tr.Fraction != 1.0 then
         self:SetPos(tr.HitPos + tr.HitNormal * 0.6)
      end

      -- Create the Nades
      for i=1,InfernoLauncher_NumberOfNades do 
         self:CreateInfernoLauncherSecondarys()
      end 

      -- Done
      self:Remove()
   else
      self:SetDetonateExact(0)
   end
end


function ENT:CreateInfernoLauncherSecondarys()

         -- Josh Mate Changes = Massively Simplified this for ease of use
         local A_Src = self:GetPos()
         local A_Angle = Angle(0,0,0)
         local A_Vel = VectorRand(-1, 1 ) * VectorRand(-600, 600)
         local A_AngImp = Vector(600, math.random(-1200, 1200), 0)
   
         self:CreateGrenade(A_Src, A_Angle, A_Vel, A_AngImp, self:GetOwner())
         
end

function ENT:CreateGrenade(src, ang, vel, angimp, ply)
   local gren = ents.Create("ent_jm_grenade_infernolaunch_second")
   if not IsValid(gren) then return end

   gren:SetPos(src)
   gren:SetAngles(ang)

   gren:SetOwner(ply)
   gren:SetThrower(ply)

   gren:SetGravity(2)
   gren:SetFriction(0.3)
   gren:SetElasticity(0.5)
   gren:SetColor(Color(200,150,0,150))

   gren:Spawn()

   gren:PhysWake()

   local phys = gren:GetPhysicsObject()
   if IsValid(phys) then
      phys:SetVelocity(vel)
      phys:AddAngleVelocity(angimp)
   end

   -- This has to happen AFTER Spawn() calls gren's Initialize()
   gren:SetDetonateExact(CurTime() + InfernoLauncher_FuseDelay)

   return gren
end

function ENT:PhysicsCollide(tr)
	self:Explode(tr)
end