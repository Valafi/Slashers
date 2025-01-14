-- Utopia Games - Slashers
--
-- @Author: Garrus2142
-- @Date:   2017-07-26 01:30:34
-- @Last Modified by:   Valafi
-- @Last Modified time: 2021-03-27 09:35:12

local function PlayerSpawn(ply)
	ply.lastpos = ply:GetPos()
	ply.lastang = ply:EyeAngles()
	ply.afktime = CurTime()
end
hook.Add("PlayerSpawn", "antiafk_PlayerSpawn", PlayerSpawn)

local function Think()
	local CV_enable = GetConVar("slash_antiafk_enable")
	local CV_afktime = GetConVar("slash_antiafk_afktime")
	local CV_afkmsgtime = GetConVar("slash_antiafk_afkmsgtime")
	local curtime = CurTime()

	if not CV_enable or not CV_afktime or not CV_afkmsgtime then return end
	if not CV_enable:GetBool() then return end

	for _, v in ipairs(player.GetAll()) do
		if not v:Alive() or v:IsBot() then
			v.afktime = curtime
			goto cont
		end

		-- Reset
		if v.lastpos ~= v:GetPos() or v.lastang ~= v:EyeAngles() then
			v.afktime = curtime
			v.lastpos = v:GetPos()
			v.lastang = v:EyeAngles()
			v:SetNWInt("afk_warn", 0)

		elseif curtime > v.afktime + (CV_afktime:GetInt() + CV_afkmsgtime:GetInt()) then
			-- Kick
			v:Kick("You're kicked by anti-afk system.")
			for _, u in ipairs(player.GetAll()) do
				u:ChatPrint(v:Name() .. " kicked by anti-afk")
			end

		elseif v:GetNWInt("afk_warn") == 0 and curtime > v.afktime + CV_afktime:GetInt() then
			-- Warning
			v:SetNWInt("afk_warn", v.afktime + (CV_afktime:GetInt() + CV_afkmsgtime:GetInt()))
		end

		::cont::
	end
end
hook.Add("Think", "antiafk_Think", Think)
