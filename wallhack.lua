script_name('Wallhack for SA-MP')
script_author('0x23F')
script_version('1.0')

local ffi = require "ffi"
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local inicfg = require 'inicfg'

require 'lib.sampfuncs'
require 'lib.moonloader'

mainIni = inicfg.load(
{
	set =
	{
		kosti = true,
		health = true,
		armor = true,
		checkdialog = true,
		checkinput = true
	}
}, "wallhack.ini")

local settings = "moonloader/config/wallhack.ini"
local settingsIni = inicfg.load(mainIni, settings)

if not doesFileExist('moonloader/config/wallhack.ini') then inicfg.save(mainIni, 'wallhack.ini') end

local skeletenable = mainIni.set.kosti
local healthenable = mainIni.set.health
local armorenable = mainIni.set.armor
local checkdialog = mainIni.set.checkdialog
local checkinput = mainIni.set.checkinput

function main()
	if not isSampLoaded() or not isCleoLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(50) end
	
	fontcheat = renderCreateFont('Tahoma', 8, FCR_BORDER)
	
	while true do wait(0)
		
		if isKeyDown(VK_1) then	
			enablecheat = true
		else enablecheat = false
		end
		
		if enablecheat then
			for ID = 0, sampGetMaxPlayerId() do
				if sampIsPlayerConnected(ID) then
					result, ped = sampGetCharHandleBySampPlayerId(ID)
					if result then
						X, Y, Z = getOffsetFromCharInWorldCoords(ped, 0.0, 0.0, 0.0)
						if isPointOnScreen(X, Y, Z, 0.0) then
							x2, y2 = convert3DCoordsToScreen(X, Y, Z)
							local color = sampGetPlayerColor(ID)
							local aa, rr, gg, bb = explode_argb(color)
							local color = join_argb(255, rr, gg, bb)
							renderFontDrawText(fontcheat, string.format('%s[%d]', sampGetPlayerNickname(ID), ID), x2 + 2, y2, color)
							renderFontDrawText(fontcheat, string.format('Health: %d', sampGetPlayerHealth(ID)), x2 + 2, y2 + 12, 0xFFFFFFFF)
							renderFontDrawText(fontcheat, string.format('Armour: %d', sampGetPlayerArmor(ID)), x2 + 2, y2 + 24, 0xFFFFFFFF)
							if sampIsPlayerPaused(ID) then renderFontDrawText(fontcheat, "AFK", x2 + 100, y2 + 24, 0xFFFF0000) end
							local t = {3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2}
							for v = 1, #t do
								pos1X, pos1Y, pos1Z = getBodyPartCoordinates(t[v], ped)
								pos2X, pos2Y, pos2Z = getBodyPartCoordinates(t[v] + 1, ped)
								pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
								pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
								renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
							end
							for v = 4, 5 do
								pos2X, pos2Y, pos2Z = getBodyPartCoordinates(v * 10 + 1, ped)
								pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
								renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
							end
							local t = {53, 43, 24, 34, 6}
							for v = 1, #t do
								posX, posY, posZ = getBodyPartCoordinates(t[v], ped)
								pos1, pos2 = convert3DCoordsToScreen(posX, posY, posZ)
							end
						end
					end
				end
			end
		end
	end
end

function getBodyPartCoordinates(id, handle)
  local pedptr = getCharPointer(handle)
  local vec = ffi.new("float[3]")
  getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
  return vec[0], vec[1], vec[2]
end

function join_argb(a, r, g, b)
  local argb = b  -- b
  argb = bit.bor(argb, bit.lshift(g, 8))  -- g
  argb = bit.bor(argb, bit.lshift(r, 16)) -- r
  argb = bit.bor(argb, bit.lshift(a, 24)) -- a
  return argb
end

function explode_argb(argb)
  local a = bit.band(bit.rshift(argb, 24), 0xFF)
  local r = bit.band(bit.rshift(argb, 16), 0xFF)
  local g = bit.band(bit.rshift(argb, 8), 0xFF)
  local b = bit.band(argb, 0xFF)
  return a, r, g, b
end