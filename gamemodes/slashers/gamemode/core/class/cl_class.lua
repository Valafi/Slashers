-- Utopia Games - Slashers
--
-- @Author: Garrus2142
-- @Date:   2017-07-25 16:15:46
-- @Last Modified by:   Valafi
-- @Last Modified time: 2021-03-27 09:35:12

local GM = GM or GAMEMODE
local scrw, scrh = ScrW(), ScrH()
local ICON_CROSS = Material("icons/icon_cross.png")
local ICON_SAFE = Material("icons/icon_safe.png")
local ICON_KEYS = Material("icons/icon_keys.png")
local FIRST

local function DrawHUDSurvivor()
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.SetMaterial(GM.CLASS.Survivors[LocalPlayer().ClassID].icon)
	surface.DrawTexturedRect(20, scrh - 84, 64, 64)
end

local function DrawHUDBlack(numberKeyToDispach)
	while numberKeyToDispach > 0 do
		surface.SetMaterial(ICON_KEYS)
		surface.DrawTexturedRect(scrw - ((64 + 20) * numberKeyToDispach), scrh - 84, 64, 64)
		numberKeyToDispach = numberKeyToDispach - 1
	end
end

local function DrawHUDKiller()
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.SetMaterial(GM.MAP.Killer.Icon)
	surface.DrawTexturedRect(20, scrh - 84, 64, 64)

	for k, v in ipairs(GM.ROUND.Survivors) do
		if not GM.CLASS.Survivors[v.ClassID] then goto cont end

		surface.SetMaterial(GM.CLASS.Survivors[v.ClassID].icon)
		surface.DrawTexturedRect(scrw - ((64 + 20) * k), scrh - 84, 64, 64)
		if not v:Alive() then
			surface.SetMaterial(v:GetNWBool("Escaped") and ICON_SAFE or ICON_CROSS)
			surface.DrawTexturedRect(scrw - ((64 + 20) * k), scrh - 84, 64, 64)
		end

		::cont::
	end
end

local function HUDPaint()
	if not IsValid(LocalPlayer()) then return end
	if not GM.ROUND.Active then return end
	if not LocalPlayer().ClassID then return end

	if LocalPlayer():Team() == TEAM_SURVIVORS and GM.CLASS.Survivors[LocalPlayer().ClassID] then
		DrawHUDSurvivor()
		if LocalPlayer().ClassID == CLASS_SURV_BLACK then
			if FIRST then
				GM.CLASS.Survivors[LocalPlayer().ClassID].keysNumber = 3
				FIRST = false
			end
			DrawHUDBlack(GAMEMODE.CLASS.Survivors[LocalPlayer().ClassID].keysNumber)
		end
	elseif LocalPlayer():Team() == TEAM_KILLER then
		DrawHUDKiller()
	end
end
hook.Add("HUDPaint", "sls_class_HUDPaint", HUDPaint)

--- Show stuff on objective entity

local function getUseKey()
	local cpt = 0
	while input.LookupKeyBinding( cpt ) ~= "+use" and cpt < 159 do
		 cpt = cpt + 1
	end

	if cpt > KEY_Z then
		if cpt == KEY_ENTER or cpt == KEY_PAD_ENTER then
			return "L"
		else
			return ">"
		end
	else
		return input.GetKeyName( cpt )
	end
end
