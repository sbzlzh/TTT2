if SERVER then
    AddCSLuaFile()
end

ENT.Type = "anim"
ENT.Base = "base_ammo_ttt"
ENT.AmmoType = "Pistol"
ENT.AmmoAmount = 20
ENT.AmmoMax = 60
ENT.Model = Model("models/items/boxsrounds.mdl")
ENT.AutoSpawnable = true
ENT.spawnType = AMMO_TYPE_PISTOL
