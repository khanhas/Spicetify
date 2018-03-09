color = {
	{
		hex, rgb,
		text = "Main FG",
		var  = "main_fg"
	},
	{
		hex, rgb,
		text = "Secondary FG",
		var  = "secondary_fg"
	},
	{
		hex, rgb,
		text = "Main BG",
		var  = "main_bg"
	},
	{
		hex, rgb,
		text = "Sidebar BG, player BG",
		var  = "sidebar_and_player_bg"
	},
	{
		hex, rgb,
		text = "Cover overlay, Shadow",
		var  = "cover_overlay_and_shadow"
	},
	{
		hex, rgb,
		text = "Indicator FG, Button BG",
		var  = "indicator_fg_and_button_bg"
	},
	{
		hex, rgb,
		text = "Pressing FG",
		var  = "pressing_fg"
	},
	{
		hex, rgb,
		text = "Slider BG",
		var  = "slider_bg"
	},
	{
		hex, rgb,
		text = "Sidebar indicator, Hover button BG",
		var  = "sidebar_indicator_and_hover_button_bg"
	},
	{
		hex, rgb,
		text = "Scrollbar FG, Selected row BG",
		var  = "scrollbar_fg_and_selected_row_bg"
	},
	{
		hex, rgb,
		text = "Pressing button FG",
		var  = "pressing_button_fg"
	},
	{
		hex, rgb,
		text = "Pressing button BG",
		var  = "pressing_button_bg"
	},
	{
		hex, rgb,
		text = "Selected button",
		var  = "selected_button"
	},
	{
		hex, rgb,
		text = "Miscellaneous BG",
		var  = "miscellaneous_bg"
	},
	{
		hex, rgb,
		text = "Miscellaneous hover BG",
		var  = "miscellaneous_hover_bg"
	},
	{
		hex, rgb,
		text = "Preserve",
		var  = "preserve_1"
	}
}

colorIncTemplate = table.concat({
					'[Variables]',
					'Main_FG = 8a4fff',
					'Secondary_FG = 8a4fff',
					'Main_BG = 8a4fff',
					'Sidebar_And_Player_BG = 8a4fff',
					'Cover_Overlay_And_Shadow = 8a4fff',
					'Indicator_FG_And_Button_BG = 8a4fff',
					'Pressing_FG = 8a4fff',
					'Slider_BG = 8a4fff',
					'Sidebar_Indicator_And_Hover_Button_BG = 8a4fff',
					'Scrollbar_FG_And_Selected_Row_BG = 8a4fff',
					'Pressing_Button_FG = 8a4fff',
					'Pressing_Button_BG = 8a4fff',
					'Selected_Button = 8a4fff',
					'Miscellaneous_BG = 8a4fff',
					'Miscellaneous_Hover_BG = 8a4fff',
					'Preserve_1 = 8a4fff'
				}, '\n')

function Initialize()
	-- Parsing color from skin variables
	local meter = 1
	for k, v in ipairs(color) do
		local rawColor = SKIN:GetVariable(v.var)
		if (not rawColor or rawColor == '') then
			local colorFilePath = SKIN:ReplaceVariables("#ROOTCONFIGPATH#Themes\\#CurrentTheme#\\color.inc")
			local file = io.open(colorFilePath, 'r')
			if (file) then
				file:close()
				SKIN:Bang('!WriteKeyValue', 'Variables', v.var, '8a4fff', colorFilePath)
				SKIN:Bang('!SetVariable', v.var, '8a4fff')
				rawColor = '8a4fff'
			else
				file = io.open(colorFilePath, 'w+')
				file:write(colorIncTemplate)
				file:close()
				SKIN:Bang('!Refresh')
				return
			end
		end
		color[k].hex = parseColor(rawColor)
		color[k].rgb = hexToRGB(color[k].hex)
		SKIN:Bang('!SetOption', 'Box' .. meter, 'Color', 'Fill Color ' .. color[k].hex)
		SKIN:Bang('!SetOption', 'Box' .. meter, 'LeftMouseUpAction', table.concat({'["#@#RainRGB4.exe" "VarName=', v.var, '" "FileName=#ROOTCONFIGPATH#Themes\\#CurrentTheme#\\color.inc\\" "RefreshConfig=#CURRENTCONFIG#"]'}))

		local t = 'Text' .. meter
		local tM = SKIN:GetMeter(t)
		SKIN:Bang('!SetOption', t, 'Text', color[k].text)
		SKIN:Bang('!UpdateMeter', t)
		local s = 13
		while tM:GetH() > 45 do
			s = s - 1
			SKIN:Bang('!SetOption', t, 'FontSize', s)
			SKIN:Bang('!UpdateMeter', t)
		end
		meter = meter + 1
	end

	currentTheme = SKIN:GetVariable("CurrentTheme")
	hideAds = SKIN:GetVariable("Hide_Ads") == '1'
	injectCSS = SKIN:GetVariable("Inject_CSS") == '1'
	theme = SKIN:GetVariable("Replace_Colors") == '1'
	devTool = SKIN:GetVariable("DevTool") == '1'
	wnpComp = SKIN:GetVariable("WebNowPlaying_Compatible") == '1'
	lyrics = SKIN:GetVariable("Lyric") == '1'

	backupCount = SKIN:GetMeasure("BackupFileCount")
	backupName = SKIN:GetMeasure("BackupFileName")
	spotifyCount = SKIN:GetMeasure("SpotifyFileCount")

	cssName = SKIN:GetMeasure("CSSFileName")
	jsName = SKIN:GetMeasure("JSFileName")
	htmlName = SKIN:GetMeasure("HTMlFileName")
	status = 'Please wait'
	nC = 0
	curSpa = 0
	userCSSFile = SKIN:ReplaceVariables('#ROOTCONFIGPATH#Themes\\#CurrentTheme#\\user.css')
	local tryToReadCSS = io.open(userCSSFile, 'r')
	if (not tryToReadCSS) then
		tryToReadCSS:close()
		local f = io.open(userCSSFile, 'w+')
		f:write('')
		f:close()
	end
end

liveUpdate = false
initLive = true
liveUserCSS = ''
oldLiveUserCSS = ''
function Update()
	if (liveUpdate and totalSpa) then
		local f = io.open(userCSSFile, 'r')
		liveUserCSS = f:read('*a')
		f:close()
		if (initLive) then
			oldLiveUserCSS = liveUserCSS
			initLive = false
		end
		if (oldLiveUserCSS ~= liveUserCSS) then
			if (not isModding) then
				StartMod()
				oldLiveUserCSS = liveUserCSS
			end
		end
	end
	liveUpdate = SKIN:GetVariable("LiveUpdate") == '1'
	return status
end

function UpdateInitStatus()
	totalSpa = backupCount:GetValue()
	if (totalSpa == 0) then
		SKIN:Bang('!HideMeterGroup', 'ApplyButton')
		SKIN:Bang('!ShowMeterGroup', 'ApplyButton_Disabled')
		SKIN:Bang('!HideMeterGroup', 'BackupButton_Disabled')
		if (UpdateSpotifyFolderStatus()) then
			status = 'Something is wrong. Please reinstall Spotify before backup.'
		else
			SKIN:Bang('!ShowMeterGroup', 'BackupButton')
			status = 'Please backup first'
		end
	else
		SKIN:Bang('!HideMeterGroup', 'ApplyButton_Disabled')
		SKIN:Bang('!ShowMeterGroup', 'ApplyButton')
		SKIN:Bang('!HideMeterGroup', 'BackupButton')
		SKIN:Bang('!ShowMeterGroup', 'BackupButton_Disabled')
		status = 'Ready'
	end
end

function UpdateSpotifyFolderStatus()
	SKIN:Bang('!UpdateMeasure', 'SpotifyFileCount')
	return spotifyCount:GetValue() == 0
end

-- For progress bar
function UpdatePercent()
	if not totalSpa or not curSpa then
		return 0
	else
		return curSpa / totalSpa
	end
end

function Init_Unzip()
	bC = 0
	SKIN:Bang('!SetOption', 'BackupFileCount', 'FinishAction', '[!UpdateMeasure BackupFileCount][!CommandMeasure Script "totalSpa=backupCount:GetValue();Unzip()"]')
	SKIN:Bang('!UpdateMeasure', 'BackupFileCount')
	SKIN:Bang('!CommandMeasure', 'BackupFileCount', 'Update')
end

function Unzip()
	bC = bC + 1

	SKIN:Bang('!SetOption', 'BackupFileName', 'Index', bC)
	SKIN:Bang('!UpdateMeasure', 'BackupFileName')
	n = backupName:GetStringValue()
	if not n or n == '' then
		Duplicate()
		return
	end
	nX = n:gsub('%.spa','')
	status = "Unzipping " .. n
	curSpa = bC
	UpdatePercent()

	if (nX == "settings") then
		SKIN:Bang('!SetOption', 'Unzip', 'Parameter', 'x "Backup\\' .. n .. '" -oExtracted\\Raw\\' .. nX .. '\\ -r')
	else
		SKIN:Bang('!SetOption', 'Unzip', 'Parameter', 'x "Backup\\' .. n .. '" -oExtracted\\Raw\\' .. nX .. '\\ -r')
	end
	SKIN:Bang('!UpdateMeasure', 'Unzip')
	SKIN:Bang('!CommandMeasure', 'Unzip', 'Run')
end

function Duplicate()
	SKIN:Bang('!SetOption', 'Duplicate', 'Parameter', 'robocopy "Raw" "Themed" /E')
	SKIN:Bang('!UpdateMeasure', 'Duplicate')
	SKIN:Bang('!CommandMeasure', 'Duplicate', 'Run')
	status = "Copying @Resource\\Raw to @Resource\\Themed"
end

function Init_PrepareCSS()
	pC = 1
	glue = nil
	status = "Preparing CSS files - Skin might be irresponsive, don't freak out."
	SKIN:Bang('!SetOption', 'CSSFileView', 'Path', '#@#Extracted\\Themed')
	SKIN:Bang('!SetOption', 'CSSFileView', 'FinishAction', '[!CommandMeasure Script "PrepareCSS()"]')
	SKIN:Bang('!UpdateMeasure', 'CSSFileView')
	SKIN:Bang('!CommandMeasure', 'CSSFileView', 'Update')
end

function PrepareCSS()
	SKIN:Bang('!SetOption', 'CSSFileName', 'Index', pC)
	SKIN:Bang('!UpdateMeasure', 'CSSFileName')
	local nP = cssName:GetStringValue()
	if not nP or nP == '' then
		SKIN:Bang('!Refresh')
		return
	end

	local d = ''

	if glue and nP:match("glus%.css$") then
		d = glue
	else
		local f = io.open(nP, 'r')
		d = f:read("*a")
		f:close()
		-- Replace default color scheme with our keywords.
		-- When we apply custom color scheme, we just find
		-- and replace keywords, no need to search color
		-- again and again.
		d = d:gsub("1ed660", "modspotify_sidebar_indicator_and_hover_button_bg")
		d = d:gsub("1ed760", "modspotify_sidebar_indicator_and_hover_button_bg")
		d = d:gsub("1db954", "modspotify_indicator_fg_and_button_bg")
		d = d:gsub("1df369", "modspotify_indicator_fg_and_button_bg")
		d = d:gsub("1df269", "modspotify_indicator_fg_and_button_bg")
		d = d:gsub("1cd85e", "modspotify_indicator_fg_and_button_bg")
		d = d:gsub("1bd85e", "modspotify_indicator_fg_and_button_bg")
		d = d:gsub("18ac4d", "modspotify_selected_button")
		d = d:gsub("18ab4d", "modspotify_selected_button")
		d = d:gsub("179443", "modspotify_pressing_button_bg")
		d = d:gsub("14833b", "modspotify_pressing_button_bg")
		d = d:gsub("282828", "modspotify_main_bg")
		d = d:gsub("121212", "modspotify_main_bg")
		d = d:gsub("rgba%(18, 18, 18, ([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("181818", "modspotify_sidebar_and_player_bg")
		d = d:gsub("rgba%(18,19,20,([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("000000", "modspotify_sidebar_and_player_bg")
		d = d:gsub("333333", "modspotify_scrollbar_fg_and_selected_row_bg")
		d = d:gsub("3f3f3f", "modspotify_scrollbar_fg_and_selected_row_bg")
		d = d:gsub("535353", "modspotify_scrollbar_fg_and_selected_row_bg")
		d = d:gsub("404040", "modspotify_slider_bg")
		d = d:gsub("rgba%(80,55,80,([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("rgba%(40, 40, 40, ([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("rgba%(40,40,40,([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("rgba%(24, 24, 24, ([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("rgba%(18, 19, 20, ([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("#000011", "#modspotify_sidebar_and_player_bg")
		d = d:gsub("#0a1a2d", "#modspotify_sidebar_and_player_bg")
		d = d:gsub("ffffff", "modspotify_main_fg")
		d = d:gsub("f8f8f7", "modspotify_pressing_fg")
		d = d:gsub("fcfcfc", "modspotify_pressing_fg")
		d = d:gsub("d9d9d9", "modspotify_pressing_fg")
		d = d:gsub("adafb2", "modspotify_secondary_fg")
		d = d:gsub("c8c8c8", "modspotify_secondary_fg")
		d = d:gsub("a0a0a0", "modspotify_secondary_fg")
		d = d:gsub("bec0bb", "modspotify_secondary_fg")
		d = d:gsub("bababa", "modspotify_secondary_fg")
		d = d:gsub("b3b3b3", "modspotify_secondary_fg")
		d = d:gsub("rgba%(179, 179, 179, ([%d%.]+)%)", "rgba(modspotify_rgb_secondary_fg,%1)")
		d = d:gsub("cccccc", "modspotify_pressing_button_fg")
		d = d:gsub("ededed", "modspotify_pressing_button_fg")
		d = d:gsub("4687d6", "modspotify_miscellaneous_bg")
		d = d:gsub("rgba%(70, 135, 214, ([%d%.]+)%)", "rgba(modspotify_rgb_miscellaneous_bg,%1)")
		d = d:gsub("2e77d0", "modspotify_miscellaneous_hover_bg")
		d = d:gsub("rgba%(51,153,255,([%d%.]+)%)", "rgba(modspotify_rgb_miscellaneous_hover_bg,%1)")
		d = d:gsub("rgba%(30,50,100,([%d%.]+)%)", "rgba(modspotify_rgb_miscellaneous_hover_bg,%1)")
		d = d:gsub("rgba%(24, 24, 24, ([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("rgba%(25,20,20,([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("rgba%(160, 160, 160, ([%d%.]+)%)", "rgba(modspotify_rgb_pressing_button_fg,%1)")
		d = d:gsub("rgba%(255, 255, 255, ([%d%.]+)%)", "rgba(modspotify_rgb_pressing_button_fg,%1)")
		d = d:gsub("#ddd;", "#modspotify_pressing_button_fg;")
		d = d:gsub("#000;", "#modspotify_sidebar_and_player_bg;")
		d = d:gsub("#000 ", "#modspotify_sidebar_and_player_bg ")
		d = d:gsub("#333;", "#modspotify_scrollbar_fg_and_selected_row_bg;")
		d = d:gsub("#333 ", "#modspotify_scrollbar_fg_and_selected_row_bg ")
		d = d:gsub("#444;", "#modspotify_slider_bg;")
		d = d:gsub("#444 ", "#modspotify_slider_bg ")
		d = d:gsub("#fff;", "#modspotify_main_fg;")
		d = d:gsub("#fff ", "#modspotify_main_fg ")
		d = d:gsub(" black;", " #modspotify_sidebar_and_player_bg;")
		d = d:gsub(" black ", " #modspotify_sidebar_and_player_bg ")
		d = d:gsub(" gray ", " #modspotify_main_bg ")
		d = d:gsub(" gray;", " #modspotify_main_bg;")
		d = d:gsub(" lightgray ", " #modspotify_pressing_button_fg ")
		d = d:gsub(" lightgray;", " #modspotify_pressing_button_fg;")
		d = d:gsub(" white;", " #modspotify_main_fg;")
		d = d:gsub(" white ", " #modspotify_main_fg ")
		d = d:gsub("rgba%(0, 0, 0, ([%d%.]+)%)", "rgba(modspotify_rgb_cover_overlay_and_shadow,%1)")
		d = d:gsub("rgba%(0,0,0,([%d%.]+)%)", "rgba(modspotify_rgb_cover_overlay_and_shadow,%1)")
		d = d:gsub("#fff", "#modspotify_main_fg")
		d = d:gsub("#000", "#modspotify_sidebar_and_player_bg")
		d = table.concat({d, "\n.SearchInput__input {\nbackground-color: #modspotify_sidebar_and_player_bg !important;\ncolor: #modspotify_secondary_fg !important;}\n"})

		--Because all glue.css in all spa are the same, so
		--just store modded glue.css and we can apply to all remaining glue.css
		if not glue and nP:match("glue%.css$") then
			glue = d
		end
	end

	f = io.open(nP, 'w')
	f:write(d)
	f:close()
	pC = pC + 1
	PrepareCSS()
end

function StartMod()
	isModding = true
	if injectCSS then
		local userCSS = io.open(SKIN:ReplaceVariables("#ROOTCONFIGPATH#Themes\\#CurrentTheme#\\user.css"),'r')
		if userCSS then
			customCSS = userCSS:read('*a')
			for k, v in ipairs(color) do
				customCSS = customCSS:gsub("modspotify_" .. v.var, v.hex)
				customCSS = customCSS:gsub("modspotify_rgb_" .. v.var, v.rgb)
			end
		else
			customCSS = ''
			print('user.css is not found in @Resource folder. Please make one.')
		end
		userCSS:close()
	end
	status = "Removing @Resource\\Decomp"
	SKIN:Bang('!CommandMeasure', 'Remove', 'Run')
end

function CheckSpotifyFolder()
	SKIN:Bang('!SetOption', 'SpotifyFileCount', 'FinishAction', '!CommandMeasure Script "DoesSpotifyNeedDelete()"')
	SKIN:Bang('!UpdateMeasure', 'SpotifyFileCount')
	SKIN:Bang('!CommandMeasure', 'SpotifyFileCount', 'Update')
end

function DoesSpotifyNeedDelete()
	if (not UpdateSpotifyFolderStatus()) then
		status = "Removing Spotify\\Apps"
		SKIN:Bang('!CommandMeasure', 'Remove2', 'Run')
	else
		Replicate()
	end
end

function Replicate()
	if theme then
		status = "Copying Extracted\\Themed to Decomp"
		SKIN:Bang('!SetOption', 'Replicate', 'Parameter', 'robocopy "Extracted\\Themed" "Decomp" *.css /S')
	else
		status = "Copying Extracted\\Raw to Decomp"
		SKIN:Bang('!SetOption', 'Replicate', 'Parameter', 'robocopy "Extracted\\Raw" "Decomp" *.css /S')
	end
	SKIN:Bang('!UpdateMeasure', 'Replicate')
	SKIN:Bang('!CommandMeasure', 'Replicate', 'Run')
end

function StartCSS()
	c2 = 1
	glue = nil
	SKIN:Bang('!SetOption', 'CSSFileView', 'Path', '#@#Decomp')
	SKIN:Bang('!SetOption', 'CSSFileView', 'FinishAction', '!CommandMeasure Script "ModCSS()"')
	SKIN:Bang('!UpdateMeasure', 'CSSFileView')
	SKIN:Bang('!CommandMeasure', 'CSSFileView', 'Update')
end

function ModCSS()
	SKIN:Bang('!SetOption', 'CSSFileName', 'Index', c2)
	SKIN:Bang('!UpdateMeasure', 'CSSFileName')
	n2 = cssName:GetStringValue()
	if not n2 or n2 == '' then
		glue = nil
		status = 'Transfering mod to Spotify'
		SKIN:Bang('!CommandMeasure', 'TransferMod', 'Run')
		return
	end

	local d = ''

	if glue and n2:match("glue%.css$") then
		d = glue
	else
		local f = io.open(n2, 'r')
		d = f:read("*a")
		f:close()

		-- Replace keywords that we prepared when backing up and unzipping
		-- with actual color hex or rgb value
		if theme then
			for k, v in ipairs(color) do
				d = d:gsub("modspotify_" .. v.var, v.hex)
				d = d:gsub("modspotify_rgb_" .. v.var, v.rgb)
			end
		end

		if hideAds then
			d = table.concat({d,
				"#hpto-container {\ndisplay: none !important}\n",
				"#concerts {\ndisplay: none !important}\n",
				".sponsored-credits {\ndisplay: none !important}\n",
				".billboard-ad {\ndisplay: none !important}\n",
				"#leaderboard-ad-wrapper {\ndisplay: none !important}\n"
			})
		end

		if lyrics then 
			d = table.concat({d,
				".lyrics-button {\ndisplay: inline-block !important;\nvisibility: visible !important;\n}\n"
			})
		end

		if fullscreen then 
			d = table.concat({d,
				".lyrics-button {\ndisplay: inline-block !important;\nvisibility: visible !important;\n}\n"
			})
		end

		if injectCSS then
			d = table.concat({d, customCSS})
		end

		if not glue and n2:match("glue%.css$") then
			glue = d
		end
	end
	f = io.open(n2, 'w')
	f:write(d)
	f:close()

	c2 = c2 + 1

	ModCSS()
end

function parseColor(raw)
	local hex = ''
	--RRR,GGG,BBB
	if raw:find(',') then
		for c in raw:gmatch('%d+') do
			c = string.format("%x", c)
			hex = hex .. c
		end
	else
		hex = raw
	end
	local r = 6 - hex:len()
	--Less than 6 hex
	if r > 0 then
		for i = 1, r do
			hex = hex .. 'f'
		end
	-- More than 6 hex
	elseif r < 0 then
		while hex:len() ~= 6 do
			hex = hex:sub(1, -2)
		end
	end
	return hex
end

function hexToRGB(hex)
	local rgb = {}
	for h in hex:gmatch("..") do
		table.insert(rgb, tonumber(h, 16))
	end
	return table.concat(rgb, ',')
end

function NameToIndex(nameTable, name)
	for i = 1, #nameTable do
		if name == nameTable[i] then
			return i
		end
	end
	return nil
end

themeTable = {}
function UpdateTheme()
	local themeCount = SKIN:GetMeasure("ThemeFolderCount"):GetValue()
	if (themeCount == 0) then
		print('No theme found in Themes folder.')
		return
	end
	themeName = SKIN:GetMeasure("ThemeFolderName")

	for i = 1, themeCount do
		SKIN:Bang('!SetOption', 'ThemeFolderName', 'Index', i)
		SKIN:Bang('!UpdateMeasure', 'ThemeFolderName')
		table.insert(themeTable, themeName:GetStringValue())
	end

	currentThemeIndex = NameToIndex(themeTable, currentTheme)

	if not currentThemeIndex then
		--Fallback to first theme if cannot find current theme name in Themes folder.
		SKIN:Bang('!WriteKeyValue', 'Variables', 'CurrentTheme', themeTable[1])
		SKIN:Bang('!Refresh')
		return
	end

	if currentThemeIndex > 1 then
		SKIN:Bang('!ShowMeter', 'ThemeBack')
		SKIN:Bang('!HideMeter', 'ThemeBack_Disabled')
	end

	if (themeCount - currentThemeIndex) > 0 then
		SKIN:Bang('!ShowMeter', 'ThemeNext')
		SKIN:Bang('!HideMeter', 'ThemeNext_Disabled')
	end
end

function ThemeChange(dir)
	currentThemeIndex = currentThemeIndex + dir
	SKIN:Bang('!SetOption', 'ThemeFolderName', 'Index', currentThemeIndex)
	SKIN:Bang('!UpdateMeasure', 'ThemeFolderName')
	SKIN:Bang('!WriteKeyValue', 'Variables', 'CurrentTheme', themeName:GetStringValue())
	SKIN:Bang('!Refresh')
end

function ThemeNew()
	local name = "New_Theme"
	local n = 1
	while NameToIndex(themeTable, name) do
		n = n + 1
		name = "New_Theme_" .. n
	end
	newThemeFolder = SKIN:ReplaceVariables('#ROOTCONFIGPATH#Themes\\' .. name)
	SKIN:Bang('!WriteKeyValue', 'Variables', 'CurrentTheme', name)
	SKIN:Bang('!SetOption', 'ThemeRunCommand', 'Parameter', 'mkdir "' .. newThemeFolder .. '"')
	SKIN:Bang('!SetOption', 'ThemeRunCommand', 'FinishAction', '!CommandMeasure Script "ThemeNewContent()"')
	SKIN:Bang('!UpdateMeasure', 'ThemeRunCommand')
	SKIN:Bang('!CommandMeasure', 'ThemeRunCommand', 'Run')
end

function ThemeNewContent()
	local file = io.open(newThemeFolder .. '\\color.inc', 'w+')
	file:write(colorIncTemplate)
	file:close()

	file = io.open(newThemeFolder .. '\\user.css', 'w+')
	file:write()
	file:close()
	SKIN:Bang('!Refresh')
end

function ThemeDuplicate()
	local name = currentTheme .. '_2'
	local n = 2
	while NameToIndex(themeTable, name) do
		n = n + 1
		name = currentTheme .. '_' .. n
	end
	SKIN:Bang('!SetOption', 'ThemeRunCommand', 'Parameter', table.concat(
		{'robocopy "', currentTheme, '" "', name, '"'}
	))
	SKIN:Bang('!SetOption', 'ThemeRunCommand', 'FinishAction', '[!WriteKeyValue Variables CurrentTheme "' .. name .. '"][!Refresh]')
	SKIN:Bang('!UpdateMeasure', 'ThemeRunCommand')
	SKIN:Bang('!CommandMeasure', 'ThemeRunCommand', 'Run')
end

--Mod JS file
function ModJS(packName, jsFile, replaceTable, modded)
	local jsSpo = SKIN:ReplaceVariables("%appdata%\\Spotify\\Apps\\" .. packName .. "\\" .. jsFile .. ".js")
	local jsRaw = '';
	if modded then
		jsRaw = jsSpo
	else
		jsRaw = SKIN:ReplaceVariables("#@#Extracted\\Raw\\" .. packName .. "\\" .. jsFile .. '.js')
	end
	local f = io.open(jsRaw, 'r')
	local d = f:read("*a")
	f:close()
	for k, v in pairs(replaceTable) do
		print(k,v)
		d = d:gsub(k, v)
	end
	f = io.open(jsSpo, 'w+')
	f:write(d)
	f:close()
end

--Mod HTML file
function ModHTML(packName, replaceTable, modded)
	local htmlSpo = SKIN:ReplaceVariables("%appdata%\\Spotify\\Apps\\" .. packName .. "\\index.html")
	local htmlRaw = ''
	if modded then
		htmlRaw = htmlSpo
	else
		htmlRaw = SKIN:ReplaceVariables("#@#Extracted\\Raw\\" .. packName .. "\\index.html")
	end
	local f = io.open(htmlRaw, 'r')
	local d = f:read("*a")
	f:close()
	for k, v in pairs(replaceTable) do
		d = d:gsub(k, v)
	end
	f = io.open(htmlSpo, 'w+')
	f:write(d)
	f:close()
end

--Inject plugins
function ModInjectPlugin(packName, pluginFile)
	pluginFile = pluginFile .. '.js'
	local plugin = io.open(SKIN:ReplaceVariables("#@#Plugins\\" .. pluginFile), 'r')
	if (plugin) then
		local pluginData = plugin:read('*a')
		plugin:close()
		plugin = io.open(SKIN:ReplaceVariables("%appdata%\\Spotify\\Apps\\" .. packName .. "\\" .. pluginFile), 'w+')
		plugin:write(pluginData)
	end
	plugin:close()
end

function Finishing()
	local htmlModded = {}
	local jsModded = {}
	if (devTool) then
		ModJS('settings', 'bundle', {
			["model%.get%('enabled'%)"] = "true",
			["(const isEmployee = ).-;"] = "%1true;"
		}, jsModded['settings'])
		jsModded['settings'] = true
	end

	if (wnpComp) then
		ModInjectPlugin('zlink', 'wnpPlugin')

		ModHTML('zlink', {
			--Inject WNP script declaration
			['(</body>)'] = '<script type="text/javascript" src="/wnpPlugin.js"></script>%1',
			--Set up a decoy button for us to trigger PlayerUI.prototyp.injectSpicetify
			['<div class="controls">'] = '%1<button type="button" id="spicetify-inject" class="button hidden" data-bind="click: injectSpicetify"></button>',
		}, htmlModded['zlink'])
		htmlModded['zlink'] = true

		ModJS('zlink', 'main.bundle', {
			--Inject PlayerUI.prototype.injectSpicetify function into main.bundle.js
			--	chrome.globalSeek(position): change song position
			--		@param: position		in milisecond
			--
			--	chrome.globalVolume(volume): change player volume
			--		@param: volume			float 0 to 1
			['(,PlayerUI%.prototype%.setup)'] = ',PlayerUI.prototype.injectSpicetify=function(){chrome.globalSeek=this.seek;chrome.globalVolume=function(v){eventDispatcher.dispatchEvent(new Event(Event.TYPES.PLAYER_VOLUME, v))};}%1'
		}, jsModded['zlink'])
		jsModded['zlink'] = true
	end

	if (lyrics) then
		ModJS('lyrics', 'bundle', {
			["(trackControllerOpts%.noService = ).-;"] = "%1false;",
			["(const anyAbLyricsEnabled = ).-;"] = "%1true"
		}, jsModded['lyrics'])
		jsModded['lyrics'] = fatruelse
	end

	status = 'Mod succeeded'
	if (SKIN:GetVariable("AutoRestart")=='1') then SKIN:Bang('["#@#AutoRestart.exe"]') end
	isModding = false
end