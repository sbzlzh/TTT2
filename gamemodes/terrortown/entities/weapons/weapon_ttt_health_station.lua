---
-- @class SWEP
-- @desc health staion
-- @section weapon_ttt_health_station

if SERVER then
	AddCSLuaFile()
end

SWEP.HoldType = "normal"

if CLIENT then
	SWEP.PrintName = "hstation_name"
	SWEP.Slot = 6

	SWEP.ViewModelFOV = 10
	SWEP.DrawCrosshair = false

	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "hstation_desc"
	}

	SWEP.Icon = "vgui/ttt/icon_health"
end

SWEP.Base = "weapon_tttbase"

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/props/cs_office/microwave.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1.0

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1.0

-- This is special equipment
SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_DETECTIVE} -- only detectives can buy
SWEP.LimitedStock = true -- only buyable once
SWEP.WeaponID = AMMO_HEALTHSTATION

SWEP.builtin = true

SWEP.AllowDrop = false
SWEP.NoSights = true
SWEP.InvisibleViewModel = true

---
-- @ignore
function SWEP:OnDrop()
	self:Remove()
end

---
-- @ignore
function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:HealthDrop()
end

local throwsound = Sound("Weapon_SLAM.SatchelThrow")

--- ye olde droppe code
-- @ignore
function SWEP:HealthDrop()
	if SERVER then
		local ply = self:GetOwner()
		if not IsValid(ply) then return end

		if self.Planted then return end

		local vsrc = ply:GetShootPos()
		local vang = ply:GetAimVector()
		local vvel = ply:GetVelocity()

		local vthrow = vvel + vang * 200

		local health = ents.Create("ttt_health_station")
		if IsValid(health) then
			health:SetPos(vsrc + vang * 10)
			health:Spawn()

			health:SetPlacer(ply)

			health:PhysWake()
			local phys = health:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(vthrow)
			end
			self:Remove()

			self.Planted = true
		end
	end

	self:EmitSound(throwsound)
end

---
-- @ignore
function SWEP:Reload()
	return false
end

---
-- @ignore
function SWEP:OnRemove()
	if CLIENT and IsValid(self:GetOwner()) and self:GetOwner() == LocalPlayer() and self:GetOwner():Alive() then
		RunConsoleCommand("lastinv")
	end
end

if CLIENT then
	---
	-- @ignore
	function SWEP:Initialize()
		self:AddTTT2HUDHelp("hstation_help_primary")

		return self.BaseClass.Initialize(self)
	end
end

---
-- @ignore
function SWEP:DrawWorldModel() end

---
-- @ignore
function SWEP:DrawWorldModelTranslucent() end
