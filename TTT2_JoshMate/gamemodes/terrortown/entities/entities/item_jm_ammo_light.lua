-- Pistol ammo override

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_ammo_ttt"
ENT.AmmoType = "Pistol"
ENT.AmmoAmount = 20
ENT.AmmoMax = 40
ENT.Model = Model("models/items/357ammo.mdl")
ENT.AutoSpawnable = true
