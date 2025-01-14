-- Utopia Games - Slashers
--
-- @Author: Garrus2142
-- @Date:   2017-07-25 16:15:47
-- @Last Modified by:   Valafi
-- @Last Modified time: 2021-03-21 03:27:00

local GM = GM or GAMEMODE

GM.ROUND = {}
GM.ROUND.Count = 0
GM.ROUND.Active = false
GM.ROUND.WaitingPlayers = true
GM.ROUND.CameraEnable = true
GM.ROUND.WaitingPolice = false
GM.ROUND.Escape = false

function GM.ROUND:GetSurvivorsAlive()
	local alive = {}
	if GM.ROUND.Survivors then
		for _, v in ipairs(GM.ROUND.Survivors) do
			if IsValid(v) and v:Alive() then
				table.insert(alive, v)
			end
		end
	end
	return alive
end

function getSurvivorByClass(class)
	if GM.ROUND.Survivors then
		for _, v in ipairs(GM.ROUND.Survivors) do
			if IsValid(v) and v:Alive() and v.ClassID == class then
				return v
			end
		end
	end
	return nil
end
