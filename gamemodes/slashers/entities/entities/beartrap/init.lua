-- Utopia Games - Slashers
--
-- @Author: Vyn
-- @Date:   2017-07-26 12:09:24
-- @Last Modified by:   Valafi
-- @Last Modified time: 2021-03-21 03:27:00

 
AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

util.AddNetworkString("slashers_beartrap_tap")

local function IsKiller(ent) 
	if ent:Team() == TEAM_KILLER then return true end -- MODIFY
	return false
end

local function RefreshTap(ent, self)
	net.Start("slashers_beartrap_tap")
	net.WriteInt(self.tapleft, 32)
	net.Send(ent)
end

local function ActivateOnPlayer(ent, self)
	self.runspeed = ent:GetRunSpeed()
	self.walkspeed = ent:GetWalkSpeed()
	self.jumppower = ent:GetJumpPower()
	self.tapleft = slashers_beartrap_maxtap
	self.playertraped = ent
	self.isused = 1

	ent.beartrap = self
	ent:SetWalkSpeed(1)
	ent:SetRunSpeed(1)
	ent:SetJumpPower(1)

	self:EmitSound("slashers/effects/beartrap_trigger.wav") -- Play sound
	self:SetSequence(self:LookupSequence("open")) -- Play animation

	RefreshTap(ent, self)

	self.lasttime = CurTime()
end

function ENT:DesactivateOnPlayer(ent, self)
	self.playertraped:SetWalkSpeed(self.walkspeed)
	self.playertraped:SetRunSpeed(self.runspeed)
	self.playertraped:SetJumpPower(self.jumppower)
	self.playertraped.beartrap = nil
	self.playertraped = nil
	self.tapleft = 0
	RefreshTap(ent, self)
end

function ENT:Think()
	if not self.playertraped then return end

	if CurTime() - self.lasttime > 0.1 and self.tapleft <= slashers_beartrap_maxtap then
		self.lasttime = CurTime()
		self.tapleft = self.tapleft + 5
		RefreshTap(self.playertraped, self)
	end
end

function ENT:Initialize()

	self:SetModel("models/zerochain/props_industrial/beartrap/beartrap.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS) 
	self:SetUseType(SIMPLE_USE)
	self.isused = 0
	self.tapleft = 0

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		self:GetPhysicsObject():EnableMotion(false)
	end
end

function ENT:Use(activator, caller, useType, value)
	if not IsKiller(caller) and self.tapleft > 0 then
		if self.playertraped:SteamID() ~= caller:SteamID() then return end
		self.tapleft = self.tapleft - 10
		RefreshTap(caller, self)
		if self.tapleft <= 0 then
			self:DesactivateOnPlayer(caller, self)
		end
	elseif IsKiller(caller) and not self.playertraped then
		caller:GiveAmmo(1, "ammo_beartrap", true)
		self:Remove()
	end
end

function ENT:Touch(ent)
	if ent.beartrap or self.isused == 1 or not ent:IsPlayer() or IsKiller(ent) then return end

	ActivateOnPlayer(ent, self)

	local effectdata = EffectData()
	local bloodorigin = self:GetPos()
	bloodorigin.z = bloodorigin.z + 25
	effectdata:SetOrigin(bloodorigin)
	util.Effect("BloodImpact", effectdata)
	ent:TakeDamage(50, self, self)
end
