script_name('Wallhack for SA-MP')
script_author('0x23F')
script_version('1.1')

require 'libstd.deps' {
   'fyp:mimgui'
}

local fficheck, ffi = pcall(require, "ffi")
local vkeyscheck, vkeys = pcall(require, "vkeys")
local inicfg = require 'inicfg'
local mimgui = require 'mimgui'
local new = mimgui.new
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)

require 'lib.sampfuncs'
require 'lib.moonloader'

local mainc = mimgui.ImVec4(0.0, 0.52, 0.74, 1.0) -- Синий

local mimShow = new.bool()
local mimWH = new.bool(true)
local mimKosti = new.bool(true)
local mimHealth = new.bool(true)
local mimArmor = new.bool(true)
local mimCheck = new.bool(true)
local mimCheckAFK = new.bool(true)
local mimFontSize = new.int(8)
local mimZazhim = new.bool(true)

mainIni = inicfg.load(
{
	set =
	{
		wh = mimWH[0],
		kosti = mimKosti[0],
		health = mimHealth[0],
		armor = mimArmor[0],
		check = mimCheck[0],
		checkafk = mimCheckAFK[0],
		fontsize = mimFontSize[0],
		zazhim = mimZazhim[0]
	}
}, "wallhack.ini")

local settings = "moonloader/config/wallhack.ini"
local settingsIni = inicfg.load(mainIni, settings)

if not doesFileExist('moonloader/config/wallhack.ini') then inicfg.save(mainIni, 'wallhack.ini') end

local skelet = mainIni.set.kosti
local health = mainIni.set.health
local armor = mainIni.set.armor
local check = mainIni.set.check
local checkafk = mainIni.set.checkafk
local fontsize = mainIni.set.fontsize
local wh = mainIni.set.wh
local fontcheat = renderCreateFont('Tahoma', fontsize, FCR_BORDER)
local zazhim = mainIni.set.zazhim

function main()
	if getMoonloaderVersion() <= 26 then 
		print("Версия moonloader'а ниже 0.27. Скачивание библиотек невозможно.")
		thisScript():unload()
	end
	
	if fficheck == false or vkeyscheck == false then
		print("Одна из важных библиотек (ffi, vkeys) отсутствует.")
		print("Проверьте их наличие у себя в папке с игрой и перезайдите.")
		thisScript():unload()
	end
	
	mimWH[0] = wh
	mimKosti[0] = skelet
	mimHealth[0] = health
	mimArmor[0] = armor
	mimCheck[0] = check
	mimCheckAFK[0] = checkafk
	mimFontSize[0] = fontsize
	mimZazhim[0] = zazhim

	if not isSampLoaded() or not isCleoLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(50) end
	
	sampRegisterChatCommand('wh_settings', cmd_whsettings)
	
	while true do wait(0)
		
		if mimZazhim[0] then
			if isKeyDown(VK_1) and isKeyDown(VK_X) then	
				enablecheat = true
			else enablecheat = false
			end
		else
			if wasKeyPressed(VK_1) and wasKeyPressed(VK_X) then	
				enablecheat = not enablecheat
			end
		end
		
		if enablecheat and mimWH[0] then
			if not mimCheck[0] or mimCheck[0] and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() then
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
								if mimHealth[0] then renderFontDrawText(fontcheat, string.format('Health: %d', sampGetPlayerHealth(ID)), x2 + 2, y2 + 12, 0xFFFFFFFF) end
								if mimArmor[0] then renderFontDrawText(fontcheat, string.format('Armour: %d', sampGetPlayerArmor(ID)), x2 + 2, y2 + 24, 0xFFFFFFFF) end
								if sampIsPlayerPaused(ID) and mimCheckAFK[0] then renderFontDrawText(fontcheat, "AFK", x2 + 100, y2 + 24, 0xFFFF0000) end
								if mimKosti[0] then
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
	end
end

function cmd_whsettings()
	mimShow[0] = not mimShow[0]
end

function apply_custom_style()
   local style = mimgui.GetStyle()
   local colors = style.Colors
   local clr = mimgui.Col
   local ImVec4 = mimgui.ImVec4
   style.WindowRounding = 1.5
   style.WindowTitleAlign = mimgui.ImVec2(0.5, 0.5)
   style.FrameRounding = 1.0
   style.ItemSpacing = mimgui.ImVec2(4.0, 4.0)
   style.ScrollbarSize = 13.0
   style.ScrollbarRounding = 0
   style.GrabMinSize = 8.0
   style.GrabRounding = 1.0
   style.WindowBorderSize = 0.0
   style.WindowPadding = mimgui.ImVec2(4.0, 4.0)
   style.FramePadding = mimgui.ImVec2(2.5, 3.5)
   style.ButtonTextAlign = mimgui.ImVec2(0.5, 0.35)
   style.WindowMinSize = mimgui.ImVec2(500, 235)
 
   colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
   colors[clr.TextDisabled]           = ImVec4(0.7, 0.7, 0.7, 1.0)
   colors[clr.WindowBg]               = ImVec4(0.07, 0.07, 0.07, 1.0)
   colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
   colors[clr.Border]                 = ImVec4(mainc.x, mainc.y, mainc.z, 0.4)
   colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
   colors[clr.FrameBg]                = ImVec4(mainc.x, mainc.y, mainc.z, 0.7)
   colors[clr.FrameBgHovered]         = ImVec4(mainc.x, mainc.y, mainc.z, 0.4)
   colors[clr.FrameBgActive]          = ImVec4(mainc.x, mainc.y, mainc.z, 0.9)
   colors[clr.TitleBg]                = ImVec4(mainc.x, mainc.y, mainc.z, 1.0)
   colors[clr.TitleBgActive]          = ImVec4(mainc.x, mainc.y, mainc.z, 1.0)
   colors[clr.TitleBgCollapsed]       = ImVec4(mainc.x, mainc.y, mainc.z, 0.79)
   colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
   colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
   colors[clr.ScrollbarGrab]          = ImVec4(mainc.x, mainc.y, mainc.z, 0.8)
   colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
   colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
   colors[clr.CheckMark]              = ImVec4(mainc.x + 0.13, mainc.y + 0.13, mainc.z + 0.13, 1.00)
   colors[clr.SliderGrab]             = ImVec4(0.28, 0.28, 0.28, 1.00)
   colors[clr.SliderGrabActive]       = ImVec4(0.35, 0.35, 0.35, 1.00)
   colors[clr.Button]                 = ImVec4(mainc.x, mainc.y, mainc.z, 0.8)
   colors[clr.ButtonHovered]          = ImVec4(mainc.x, mainc.y, mainc.z, 0.63)
   colors[clr.ButtonActive]           = ImVec4(mainc.x, mainc.y, mainc.z, 1.0)
   colors[clr.Header]                 = ImVec4(mainc.x, mainc.y, mainc.z, 0.6)
   colors[clr.HeaderHovered]          = ImVec4(mainc.x, mainc.y, mainc.z, 0.43)
   colors[clr.HeaderActive]           = ImVec4(mainc.x, mainc.y, mainc.z, 0.8)
   colors[clr.Separator]              = colors[clr.Border]
   colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
   colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
   colors[clr.ResizeGrip]             = ImVec4(mainc.x, mainc.y, mainc.z, 0.8)
   colors[clr.ResizeGripHovered]      = ImVec4(mainc.x, mainc.y, mainc.z, 0.63)
   colors[clr.ResizeGripActive]       = ImVec4(mainc.x, mainc.y, mainc.z, 1.0)
   colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
   colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
   colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
   colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
   colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
end

mimgui.OnInitialize(function()
	apply_custom_style()
end)

mimgui.OnFrame(function () return mimShow[0] end,
function ()
    local w, h = getScreenResolution()
    mimgui.SetNextWindowPos(mimgui.ImVec2(w / 2, h / 2), mimgui.Cond.Always, mimgui.ImVec2(0.5, 0.5))
    mimgui.SetNextWindowSize(mimgui.ImVec2(500, 235), mimgui.Cond.Always)
    mimgui.Begin(u8"Настройки Wallhack'a", mimShow, mimgui.WindowFlags.NoCollapse + mimgui.WindowFlags.NoResize + mimgui.WindowFlags.NoMove + mimgui.WindowFlags.NoBringToFrontOnFocus + mimgui.WindowFlags.AlwaysAutoResize)
	if mimgui.Checkbox(u8"Включить Wallhack", mimWH) then 
		wh = tostring(mimWH[0])
		settingsIni.set.wh = wh
		inicfg.save(mainIni, settings)
	end
	if mimgui.Checkbox(u8"Скелет", mimKosti) then 
		skelet = tostring(mimKosti[0])
		settingsIni.set.kosti = kosti
		inicfg.save(mainIni, settings)
	end
	if mimgui.Checkbox(u8"Уровень здоровья", mimHealth) then 
		health = tostring(mimHealth[0])
		settingsIni.set.health = health
		inicfg.save(mainIni, settings)
	end
	if mimgui.Checkbox(u8"Уровень брони", mimArmor) then 
		armor = tostring(mimArmor[0])
		settingsIni.set.armor = armor
		inicfg.save(mainIni, settings)
	end
	if mimgui.Checkbox(u8"Проверять включён ли чат, показан ли диалог", mimCheck) then 
		check = tostring(mimCheck[0])
		settingsIni.set.check = check
		inicfg.save(mainIni, settings)
	end
	if mimgui.Checkbox(u8"Статус AFK", mimCheckAFK) then 
		checkafk = tostring(mimCheckAFK[0])
		settingsIni.set.checkafk = checkafk
		inicfg.save(mainIni, settings)
	end
	if mimgui.Checkbox(u8"Зажимать или нет", mimZazhim) then
		zazhim = tostring(mimZazhim[0])
		settingsIni.set.zazhim = zazhim
		inicfg.save(mainIni, settings)
	end
	mimgui.Separator()
	if mimgui.SliderInt(u8"Размер шрифта", mimFontSize, 4, 25) then
		fontsize = tostring(mimFontSize[0])
		fontcheat = nil
		fontcheat = renderCreateFont("Tahoma", fontsize, FCR_BORDER)
		settingsIni.set.fontsize = fontsize
		inicfg.save(mainIni, settings)
	end
    mimgui.End()
end)

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