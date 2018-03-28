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
		while tM:GetH() > 40 do
			s = s - 1
			SKIN:Bang('!SetOption', t, 'FontSize', s)
			SKIN:Bang('!UpdateMeter', t)
		end
		meter = meter + 1
	end

	currentTheme = SKIN:GetVariable("CurrentTheme")
	spotifyVer = SKIN:GetVariable("LastSpotifyVersion")
	ParseCoreSetting()

	backupCount = SKIN:GetMeasure("BackupFileCount")
	backupName = SKIN:GetMeasure("BackupFileName")
	spotifyCount = SKIN:GetMeasure("SpotifyFileCount")

	cssName = SKIN:GetMeasure("CSSFileName")
	jsName = SKIN:GetMeasure("JSFileName")
	htmlName = SKIN:GetMeasure("HTMlFileName")
	UpdateStatus('Please wait')
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

function ParseCoreSetting()
	injectCSS = SKIN:GetVariable("Inject_CSS") == '1'
	theme = SKIN:GetVariable("Replace_Colors") == '1'
	devTool = SKIN:GetVariable("DevTool") == '1'
	radio = SKIN:GetVariable("Radio") == '1'
	home = SKIN:GetVariable("Home") == '1'
	sentry = SKIN:GetVariable("DisableSentry") == '1'
end

liveUpdate = false
initLive = true
liveUserCSS = ''
oldLiveUserCSS = ''
function Update()
	if (liveUpdate and totalSpa and not firstTimeMod) then
		local f = io.open(userCSSFile, 'r')
		liveUserCSS = f:read('*a')
		f:close()
		if (initLive) then
			oldLiveUserCSS = liveUserCSS
			initLive = false
		end
		if (oldLiveUserCSS ~= liveUserCSS) then
			oldLiveUserCSS = liveUserCSS
			UpdateUserCSS()
		end
	end
	liveUpdate = SKIN:GetVariable("LiveUpdate") == '1'
	return status
end

function UpdateInitStatus()
	totalSpa = backupCount:GetValue()
	if (totalSpa == 0) then
		SKIN:Bang('!HideMeterGroup', 'ClearBackupGroup')
		SKIN:Bang('!SetOptionGroup', 'Button_Disabled', 'StrokeColor', 'Stroke Color 909090')
		SKIN:Bang('!SetOptionGroup', 'Button_Disabled', 'LeftMouseUpAction', '')
		SKIN:Bang('!SetOptionGroup', 'Button_Disabled', 'MouseOverAction', ' ')
		SKIN:Bang('!SetOptionGroup', 'Button_Disabled', 'MouseLeaveAction', ' ')
		SKIN:Bang('!SetOptionGroup', 'ButtonText_Disabled', 'FontColor', '909090')
		if (UpdateSpotifyFolderStatus()) then
			UpdateStatus('Something is wrong. Please reinstall Spotify before backup.', 'warn')
		else
			SKIN:Bang('!ShowMeterGroup', 'BackupButton')
			SKIN:Bang('!ShowMeterGroup', 'Preprocess')
			UpdateStatus('Please backup first', 'ok')
		end
	else
		SKIN:Bang('!HideMeterGroup', 'BackupButton')
		SKIN:Bang('!HideMeterGroup', 'Preprocess')
		if (UpdateSpotifyFolderStatus()) then
			SKIN:Bang('!SetOption', 'ApplyButtonText', 'Text', 'Re-apply')
			UpdateStatus('Ready', 'ok')
		else
			SKIN:Bang('!SetOptionGroup', 'Apply_Disabled', 'StrokeColor', 'Stroke Color 909090')
			SKIN:Bang('!SetOptionGroup', 'Apply_Disabled', 'Color', 'Fill Color 0,0,0,0')
			SKIN:Bang('!SetOptionGroup', 'Apply_Disabled', 'LeftMouseUpAction', '')
			SKIN:Bang('!SetOptionGroup', 'Apply_Disabled', 'MouseOverAction', ' ')
			SKIN:Bang('!SetOptionGroup', 'Apply_Disabled', 'MouseLeaveAction', ' ')
			SKIN:Bang('!SetOptionGroup', 'ApplyText_Disabled', 'FontColor', '909090')
			SKIN:Bang('!SetOption', 'ApplyButtonText', 'Text', 'Apply')
			UpdateStatus('Ready. Please Apply at least one time.', 'ok')
			firstTimeMod = true
		end

		local pref = io.open(SKIN:ReplaceVariables("%appdata%\\Spotify\\prefs"), 'r')
		local currSpotifyVer = pref:read("*a"):match("app%.last%-launched%-version=\"(.-)\"")
		pref:close()

		if (currSpotifyVer ~= spotifyVer) then
			UpdateStatus('Spotify version and backup version are mismatched. Please Clear Backup and Backup again.', 'warn')
		end

		spaList = {}
		for i = 1, totalSpa do
			SKIN:Bang('!SetOption', 'BackupFileName', 'Index', i)
			SKIN:Bang('!UpdateMeasure', 'BackupFileName')
			local name = backupName:GetStringValue():gsub("%.spa$", "")
			table.insert(spaList, name)
		end
	end
	SKIN:Bang('!UpdateMeter', '*')
	SKIN:Bang('!Redraw')
end

function UpdateSpotifyFolderStatus()
	SKIN:Bang('!UpdateMeasure', 'SpotifyFileCount')
	return spotifyCount:GetValue() == 0
end

-- For progress bar
percent = 0
function GetPercent()
	return percent
end

processSum = 0
curProcess = 0
function UpdatePercent(total)
	if (total) then
		processSum = total
		curProcess = 0
		return
	end
	curProcess = curProcess + 1
	if (processSum == 0) then
		percent = 1
	else
		percent = curProcess / processSum
	end
	SKIN:Bang('!UpdateMeter', 'PercentBar')
	SKIN:Bang('!Redraw')
end

function UpdateStatus(text, kind)
	if (kind == "warn") then
		kind = "[\\xf057] "
	elseif (kind == "ok") then
		kind = "[\\xf118] "
	elseif (kind == "done") then
		kind = "[\\xf164] "
	else
		kind = "[\\xf254] "
	end
	status = text
	SKIN:Bang('!SetOption', 'Status', 'Prefix', kind)
	SKIN:Bang('!UpdateMeasure', 'Script')
	SKIN:Bang('!UpdateMeter', 'Status')
	SKIN:Bang('!Redraw')
end

function Init_Unzip()
	bC = 0
	SKIN:Bang('!SetOption', 'BackupFileCount', 'FinishAction', '[!UpdateMeasure BackupFileCount][!CommandMeasure Script "totalSpa=backupCount:GetValue();UpdatePercent(totalSpa);Unzip()"]')
	SKIN:Bang('!UpdateMeasure', 'BackupFileCount')
	SKIN:Bang('!CommandMeasure', 'BackupFileCount', 'Update')
end

function Unzip()
	--Pre-process
	if (nX) then
		if (sentry) then
			local p = SKIN:ReplaceVariables("#@#Extracted\\Raw\\" .. nX .. "\\bundle.js")
			local f = io.open(p, 'r')
			if (not f) then
				p = SKIN:ReplaceVariables("#@#Extracted\\Raw\\" .. nX .. "\\main.bundle.js")
				f = io.open(p, 'r')
			end
			if (f) then
				UpdateStatus("Removing Sentry of " .. n)
				local d = f:read('*a')
				f:close()
				d = d:gsub('sentry%.install%(%),?', '')
				f = io.open(p, 'w')
				f:write(d)
				f:close()
			end
		end

		fileUtil("#@#Extracted\\Raw\\" .. nX .. "\\index.html", function (data)
				return data:gsub('</head>',
					'<link rel="stylesheet" class="spicetify-userCSS" href="https://zlink.app.spotify.com/user.css">%1', 1)
						:gsub('href="css/glue.css"', 'href="https://zlink.app.spotify.com/css/glue.css"', 1)
			end
		)
		if (nX ~= "zlink") then
			os.remove(SKIN:ReplaceVariables('#@#Extracted\\Raw\\' .. nX .. '\\css\\glue.css'))
		end
	end

	bC = bC + 1
	SKIN:Bang('!SetOption', 'BackupFileName', 'Index', bC)
	SKIN:Bang('!UpdateMeasure', 'BackupFileName')
	n = backupName:GetStringValue()
	if not n or n == '' then
		Duplicate()
		return
	end
	nX = n:gsub('%.spa','')
	UpdateStatus("Unzipping " .. n)
	UpdatePercent()

	SKIN:Bang('!SetOption', 'Unzip', 'Parameter', 'x "Backup\\' .. n .. '" -oExtracted\\Raw\\' .. nX .. '\\ -r')

	SKIN:Bang('!UpdateMeasure', 'Unzip')
	SKIN:Bang('!CommandMeasure', 'Unzip', 'Run')
end

function Duplicate()
	SKIN:Bang('!SetOption', 'Duplicate', 'Parameter', 'robocopy "Raw" "Themed" *.css *.js *.html /S /COPY:D /R:50 /W:1 /NJH /NS')
	SKIN:Bang('!UpdateMeasure', 'Duplicate')
	SKIN:Bang('!CommandMeasure', 'Duplicate', 'Run')
	UpdateStatus("Copying @Resource\\Raw to @Resource\\Themed")
end

function Init_PrepareCSS()
	pC = 1
	glue = nil
	UpdateStatus("Preparing CSS files - Skin might be irresponsive, don't freak out.")
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
		local pref = io.open(SKIN:ReplaceVariables("%appdata%\\Spotify\\prefs"), 'r')
		local currSpotifyVer = pref:read("*a"):match("app%.last%-launched%-version=\"(.-)\"")
		pref:close()
		SKIN:Bang('!WriteKeyValue', 'Variables', 'LastSpotifyVersion', currSpotifyVer)
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
		d = d:gsub("#1ed660", "var(--modspotify_sidebar_indicator_and_hover_button_bg)")
		d = d:gsub("#1ed760", "var(--modspotify_sidebar_indicator_and_hover_button_bg)")
		d = d:gsub("#1db954", "var(--modspotify_indicator_fg_and_button_bg)")
		d = d:gsub("#1df369", "var(--modspotify_indicator_fg_and_button_bg)")
		d = d:gsub("#1df269", "var(--modspotify_indicator_fg_and_button_bg)")
		d = d:gsub("#1cd85e", "var(--modspotify_indicator_fg_and_button_bg)")
		d = d:gsub("#1bd85e", "var(--modspotify_indicator_fg_and_button_bg)")
		d = d:gsub("#18ac4d", "var(--modspotify_selected_button)")
		d = d:gsub("#18ab4d", "var(--modspotify_selected_button)")
		d = d:gsub("#179443", "var(--modspotify_pressing_button_bg)")
		d = d:gsub("#14833b", "var(--modspotify_pressing_button_bg)")
		d = d:gsub("#282828", "var(--modspotify_main_bg)")
		d = d:gsub("#121212", "var(--modspotify_main_bg)")
		d = d:gsub("#999999", "var(--modspotify_main_bg)")
		d = d:gsub("#606060", "var(--modspotify_main_bg)")
		d = d:gsub("rgba%(18, 18, 18, ([%d%.]+)%)", "rgba(var(--modspotify_rgb_sidebar_and_player_bg),%1)")
		d = d:gsub("#181818", "var(--modspotify_sidebar_and_player_bg)")
		d = d:gsub("rgba%(18,19,20,([%d%.]+)%)", "rgba(var(--modspotify_rgb_sidebar_and_player_bg),%1)")
		d = d:gsub("#000000", "var(--modspotify_sidebar_and_player_bg)")
		d = d:gsub("#333333", "var(--modspotify_scrollbar_fg_and_selected_row_bg)")
		d = d:gsub("#3f3f3f", "var(--modspotify_scrollbar_fg_and_selected_row_bg)")
		d = d:gsub("#535353", "var(--modspotify_scrollbar_fg_and_selected_row_bg)")
		d = d:gsub("#404040", "var(--modspotify_slider_bg)")
		d = d:gsub("rgba%(80,55,80,([%d%.]+)%)", "rgba(var(--modspotify_rgb_sidebar_and_player_bg),%1)")
		d = d:gsub("rgba%(40, 40, 40, ([%d%.]+)%)", "rgba(var(--modspotify_rgb_sidebar_and_player_bg),%1)")
		d = d:gsub("rgba%(40,40,40,([%d%.]+)%)", "rgba(var(--modspotify_rgb_sidebar_and_player_bg),%1)")
		d = d:gsub("rgba%(24, 24, 24, ([%d%.]+)%)", "rgba(var(--modspotify_rgb_sidebar_and_player_bg),%1)")
		d = d:gsub("rgba%(18, 19, 20, ([%d%.]+)%)", "rgba(var(--modspotify_rgb_sidebar_and_player_bg),%1)")
		d = d:gsub("#000011", "var(--modspotify_sidebar_and_player_bg)")
		d = d:gsub("#0a1a2d", "var(--modspotify_sidebar_and_player_bg)")
		d = d:gsub("#ffffff", "var(--modspotify_main_fg)")
		d = d:gsub("#f8f8f7", "var(--modspotify_pressing_fg)")
		d = d:gsub("#fcfcfc", "var(--modspotify_pressing_fg)")
		d = d:gsub("#d9d9d9", "var(--modspotify_pressing_fg)")
		d = d:gsub("#cdcdcd", "var(--modspotify_pressing_fg)")
		d = d:gsub("#e6e6e6", "var(--modspotify_pressing_fg)")
		d = d:gsub("#e5e5e5", "var(--modspotify_pressing_fg)")
		d = d:gsub("#adafb2", "var(--modspotify_secondary_fg)")
		d = d:gsub("#c8c8c8", "var(--modspotify_secondary_fg)")
		d = d:gsub("#a0a0a0", "var(--modspotify_secondary_fg)")
		d = d:gsub("#bec0bb", "var(--modspotify_secondary_fg)")
		d = d:gsub("#bababa", "var(--modspotify_secondary_fg)")
		d = d:gsub("#b3b3b3", "var(--modspotify_secondary_fg)")
		d = d:gsub("#c0c0c0", "var(--modspotify_secondary_fg)")
		d = d:gsub("rgba%(179, 179, 179, ([%d%.]+)%)", "rgba(var(--modspotify_rgb_secondary_fg),%1)")
		d = d:gsub("#cccccc", "var(--modspotify_pressing_button_fg)")
		d = d:gsub("#ededed", "var(--modspotify_pressing_button_fg)")
		d = d:gsub("#4687d6", "var(--modspotify_miscellaneous_bg)")
		d = d:gsub("rgba%(70, 135, 214, ([%d%.]+)%)", "rgba(var(--modspotify_rgb_miscellaneous_bg),%1)")
		d = d:gsub("#2e77d0", "var(--modspotify_miscellaneous_hover_bg)")
		d = d:gsub("rgba%(51,153,255,([%d%.]+)%)", "rgba(var(--modspotify_rgb_miscellaneous_hover_bg),%1)")
		d = d:gsub("rgba%(30,50,100,([%d%.]+)%)", "rgba(var(--modspotify_rgb_miscellaneous_hover_bg),%1)")
		d = d:gsub("rgba%(24, 24, 24, ([%d%.]+)%)", "rgba(var(--modspotify_rgb_sidebar_and_player_bg),%1)")
		d = d:gsub("rgba%(25,20,20,([%d%.]+)%)", "rgba(var(--modspotify_rgb_sidebar_and_player_bg),%1)")
		d = d:gsub("rgba%(160, 160, 160, ([%d%.]+)%)", "rgba(var(--modspotify_rgb_pressing_button_fg),%1)")
		d = d:gsub("rgba%(255, 255, 255, ([%d%.]+)%)", "rgba(var(--modspotify_rgb_pressing_button_fg),%1)")
		d = d:gsub("#ddd;", "var(--modspotify_pressing_button_fg);")
		d = d:gsub("#000;", "var(--modspotify_sidebar_and_player_bg);")
		d = d:gsub("#000 ", "var(--modspotify_sidebar_and_player_bg) ")
		d = d:gsub("#333;", "var(--modspotify_scrollbar_fg_and_selected_row_bg);")
		d = d:gsub("#333 ", "var(--modspotify_scrollbar_fg_and_selected_row_bg) ")
		d = d:gsub("#444;", "var(--modspotify_slider_bg);")
		d = d:gsub("#444 ", "var(--modspotify_slider_bg) ")
		d = d:gsub("#fff;", "var(--modspotify_main_fg);")
		d = d:gsub("#fff ", "var(--modspotify_main_fg) ")
		d = d:gsub(" black;", " var(--modspotify_sidebar_and_player_bg);")
		d = d:gsub(" black ", " var(--modspotify_sidebar_and_player_bg) ")
		d = d:gsub(" gray ", " var(--modspotify_main_bg) ")
		d = d:gsub(" gray;", " var(--modspotify_main_bg);")
		d = d:gsub(" lightgray ", " var(--modspotify_pressing_button_fg) ")
		d = d:gsub(" lightgray;", " var(--modspotify_pressing_button_fg);")
		d = d:gsub(" white;", " var(--modspotify_main_fg);")
		d = d:gsub(" white ", " var(--modspotify_main_fg) ")
		d = d:gsub("rgba%(0, 0, 0, ([%d%.]+)%)", "rgba(var(--modspotify_rgb_cover_overlay_and_shadow),%1)")
		d = d:gsub("rgba%(0,0,0,([%d%.]+)%)", "rgba(var(--modspotify_rgb_cover_overlay_and_shadow),%1)")
		d = d:gsub("#fff", "var(--modspotify_main_fg)")
		d = d:gsub("#000", "var(--modspotify_sidebar_and_player_bg)")
		d = table.concat({d, "\n.SearchInput__input {\nbackground-color: var(--modspotify_sidebar_and_player_bg) !important;\ncolor: var(--modspotify_secondary_fg) !important;}\n"})

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
	local totalApply = 3 + (theme and 1 or 0)
		+ (injectCSS and 1 or 0)
		+ (devTool and 1 or 0)
	UpdatePercent(totalApply)
	UpdatePercent()
	CheckSpotifyFolder()
end

function CheckSpotifyFolder()
	SKIN:Bang('!SetOption', 'SpotifyFileCount', 'FinishAction', '!CommandMeasure Script "DoesSpotifyNeedDelete()"')
	SKIN:Bang('!UpdateMeasure', 'SpotifyFileCount')
	SKIN:Bang('!CommandMeasure', 'SpotifyFileCount', 'Update')
end

function DoesSpotifyNeedDelete()
	if (not UpdateSpotifyFolderStatus()) then
		UpdateStatus("Removing Spotify\\Apps")
		SKIN:Bang('!CommandMeasure', 'Remove', 'Run')
	else
		Transfer()
	end
end

function Transfer()
	UpdatePercent()
	if theme then
		UpdateStatus("Transferring Extracted\\Themed to Spotify")
		SKIN:Bang('!SetOption', 'TransferMod', 'Parameter', 'robocopy "#@#Extracted\\Themed" "%appdata%\\Spotify\\Apps" *.css *.js *.html /S /COPY:D /R:10 /W:1 /NS /LOG:"#@#robocopy_transfer_log.txt"')
	else
		UpdateStatus("Transferring Extracted\\Raw to Spotify")
		SKIN:Bang('!SetOption', 'TransferMod', 'Parameter', 'robocopy "#@#Extracted\\Raw" "%appdata%\\Spotify\\Apps" *.css *.js *.html /S /COPY:D /R:10 /W:1 /NS /LOG:"#@#robocopy_transfer_log.txt"')
	end
	SKIN:Bang('!UpdateMeasure', 'TransferMod')
	SKIN:Bang('!CommandMeasure', 'TransferMod', 'Run')
end

function Restored()
	UpdateStatus('Restore succeeded')
	SKIN:Bang('!SetOption', 'SpotifyFileCount', 'FinishAction', '!CommandMeasure Script "UpdateInitStatus()"')
	SKIN:Bang('!UpdateMeasure', 'SpotifyFileCount')
	SKIN:Bang('!CommandMeasure', 'SpotifyFileCount', 'Update')
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

--Open file and return file handle in write mode + file data
function fileUtil(path, callback)
	path = SKIN:ReplaceVariables(path)
	local f = io.open(path, 'r')
	local d = nil
	if (f) then
		d = f:read('*a')
		f:close()
		f = io.open(path, 'w')
		d = callback(d)
		f:write(d)
		f:close()
		return true
	end
	return false
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
	fileUtil(jsSpo,
		function (d)
			for _,v in pairs(replaceTable) do
				d = d:gsub(v[1], v[2], v[3] and v[3] or nil)
			end
			return d
		end
	)
end

--Mod HTML file
function ModHTML(packName, replaceTable, modded)
	local htmlSpo = "%appdata%\\Spotify\\Apps\\" .. packName .. "\\index.html"
	fileUtil(htmlSpo,
		function(d)
			for _,v in pairs(replaceTable) do
				d = d:gsub(v[1], v[2], v[3] and v[3] or nil)
			end
			return d
		end
	)
end

--Inject extensions
function ModInjectExtension(packName, extensionFolder, extensionFile)
	local extension = io.open(SKIN:ReplaceVariables(extensionFolder .. extensionFile), 'r')
	if (extension) then
		local extensionData = extension:read('*a')
		extension:close()
		extension = io.open(SKIN:ReplaceVariables("%appdata%\\Spotify\\Apps\\" .. packName .. "\\" .. extensionFile), 'w+')
		extension:write(extensionData)
		extension:close()
	end
end

function CopyUserCSS()
	UpdateStatus('Transferring user.css')
	local d = ''

	f = io.open(SKIN:ReplaceVariables("%appdata%\\Spotify\\Apps\\zlink\\user.css"), 'w+')

	if theme then
		UpdatePercent()
		f:write('\n:root {\n')
		for k,v in ipairs(color) do
			f:write(
				'	--modspotify_', v.var, ':#', v.hex, ';\n',
				'	--modspotify_rgb_', v.var, ':', v.rgb, ';\n'
			)
		end
		f:write('}\n')
	end

	if injectCSS then
		UpdatePercent()
		local css = io.open(SKIN:ReplaceVariables("#ROOTCONFIGPATH#Themes\\#CurrentTheme#\\user.css"),'r')
		local d = ''
		if f then
			d = css:read('*a')
		else
			print('user.css is not found in theme folder. Please make one.')
		end
		css:close()
		f:write(d)
	end

	f:close()
end

function UpdateUserCSS()
	CopyUserCSS()
	UpdateStatus('user.css is updated at ' .. os.date("%X %x"), 'done')
	SKIN:Bang('!CommandMeasure', 'WebSocket', 'reloadspotify')
end

function Finishing()
	CopyUserCSS()

	if (devTool) then
		UpdateStatus('Enabling developer tools')
		UpdatePercent()
		ModJS('settings', 'bundle', {
			{"(const isEmployee = ).-;", "%1true;"}
		})
	end

	if (radio) then
		UpdateStatus('Enabling Radio')
		ModJS('zlink', 'main.bundle', {
			{'%(0,_productState%.hasValue%)%("radio","1"%)', 'true'}
		})
	end

	if (home) then
		UpdateStatus('Enabling Home')
		ModJS('zlink', 'main.bundle', {
			{'this._initialState.isHomeEnabled', 'true'},
			{'isHomeEnabled(%?void 0:_flowControl)', 'true%1', 1}
		})
	end

	UpdateStatus('Injecting a websocket and jquery 3.3.1')
	ModHTML('zlink', {
		{'(</body>)', '<script type="text/javascript" src="/jquery-3.3.1.min.js"></script><script type="text/javascript" src="/spicetifyWebSocket.js"></script>%1'}
	})

	ModInjectExtension('zlink', "#@#JavascriptInject\\", 'spicetifyWebSocket.js')
	ModInjectExtension('zlink', "#@#JavascriptInject\\", 'jquery-3.3.1.min.js')

	ModJS('zlink', 'main.bundle', {
		{'PlayerUI%.prototype%.setup=function%(%){', table.concat({'%1',
			'chrome.player={};',
			'chrome.player.seek=(p)=>{if(p<=1)p=Math.round(p*(chrome.playerData?chrome.playerData.track.metadata.duration:0));this.seek(p)};',
			'chrome.player.getProgressMs=()=>this.progressbar.getRealValue();',
			'chrome.player.getProgressPercent=()=>this.progressbar.getPercentage();',
			'chrome.player.getDuration=()=>this.progressbar.getMaxValue();',
			'chrome.player.skipForward=(a=15e3)=>chrome.player.seek(chrome.player.getProgressMs()+a);',
			'chrome.player.skipBack=(a=15e3)=>chrome.player.seek(chrome.player.getProgressMs()-a);',
			'chrome.player.setVolume=(v)=>this.changeVolume(v, false);',
			'chrome.player.increaseVolume=()=>this.increaseVolume();',
			'chrome.player.decreaseVolume=()=>this.decreaseVolume();',
			'chrome.player.getVolume=()=>this.volumebar.getValue();',
			'chrome.player.next=()=>this._doSkipToNext();',
			'chrome.player.back=()=>this._doSkipToPrevious();',
			'chrome.player.togglePlay=()=>this._doTogglePlay();',
			'chrome.player.play=()=>{eventDispatcher.dispatchEvent(new Event(Event.TYPES.PLAYER_RESUME))};',
			'chrome.player.pause=()=>{eventDispatcher.dispatchEvent(new Event(Event.TYPES.PLAYER_PAUSE))};',
			'chrome.player.isPlaying=()=>this.progressbar.isPlaying();',
			'chrome.player.toggleShuffle=()=>this.toggleShuffle();',
			'chrome.player.getShuffle=()=>this.shuffle();',
			'chrome.player.setShuffle=(b)=>{this.shuffle(b)};',
			'chrome.player.toggleRepeat=()=>this.toggleRepeat();',
			'chrome.player.getRepeat=()=>this.repeat();',
			'chrome.player.setRepeat=(r)=>{this.repeat(r)};',
			'chrome.player.getMute=()=>this.mute();',
			'chrome.player.toggleMute=()=>this._doToggleMute();',
			'chrome.player.setMute=(b)=>{this.volumeEnabled()&&this.changeVolume(this._unmutedVolume,b)};',
			'chrome.player.thumbUp=()=>this.thumbUp();',
			'chrome.player.getThumbUp=()=>this.trackThumbedUp();',
			'chrome.player.thumbDown=()=>this.thumbDown();',
			'chrome.player.getThumbDown=()=>this.trackThumbedDown();',
			'chrome.player.formatTime=(ms)=>this._formatTime(ms);',
			'chrome.player.eventListeners={};',
			'chrome.player.addEventListener=(type,callback)=>{if(!(type in chrome.player.eventListeners)){chrome.player.eventListeners[type]=[]}chrome.player.eventListeners[type].push(callback)};',
			'chrome.player.removeEventListener=(type,callback)=>{if(!(type in chrome.player.eventListeners)){return}var stack=chrome.player.eventListeners[type];for(var i=0,l=stack.length;i<l;i+=1){if(stack[i]===callback){stack.splice(i,1);return}}};',
			'chrome.player.dispatchEvent=(event)=>{if(!(event.type in chrome.player.eventListeners)){return true}var stack=chrome.player.eventListeners[event.type];for(var i=0,l=stack.length;i<l;i+=1){stack[i](event)}return!event.defaultPrevented};'
		}), 1},

		--Leak track meta data, player state, current playlist to chrome.playerData
		{'const metadata=data%.track%.metadata;', '%1chrome.playerData=data;', 1},
		{'_localStorage2%.default%.get%(SETTINGS_KEY_AD%);', '%1chrome.localStorage=_localStorage2.default;', 1},

		--Leak audio data fetcher to chrome.getAudioData
		{'PlayerHelper%.prototype%._player=null', table.concat({
			'var uriToId=u=>{var t=u.match(/^spotify:track:(.*)/);if(!t||t.length<2)return false;else return t[1]};',
			'chrome.getAudioData=(callback, uri)=>{uri=uri||chrome.playerData.track.uri;if(typeof(callback)!=="function"){console.log("chrome.getAudioData: callback has to be a function");return;};var id=uriToId(uri);if(id)cosmos.resolver.get(`hm://audio-attributes/v1/audio-analysis/${id}`, (e,p)=>{if(e){console.log(e);callback(null);return;}if(p._status===200&&p._body&&p._body!==""){var data=JSON.parse(p._body);data.uri=uri;callback(data);}else callback(null)})};',
			'new Player(cosmos.resolver,"spotify:internal:queue","queue","1.0.0").subscribeToQueue((e,r)=>{if(e){console.log(e);return;}chrome.queue=r.getJSONBody();});',
			'%1'})
		, 1},
		--Register song change event
		{'this%._uri=track%.uri,this%._trackMetadata=track%.metadata', '%1,chrome.player&&chrome.player.dispatchEvent(new Event("songchange"))', 1},
		--Leak Cosmos API to chrome.cosmosAPI
		{'var _spotifyCosmosApi2=_interop.-;', '%1chrome.cosmosAPI=_spotifyCosmosApi2.default;',1}

	})

	local actExtension = Extension_ParseActivated()
	for k, v in pairs(extensionTable) do
		if (actExtension[v.file]) then
			UpdateStatus('Injecting extension ' .. v.name)
            ModHTML('zlink', {
                {'(</body>)', '<script type="text/javascript" src="/' .. v.file .. '"></script>%1'}
            })
			ModInjectExtension('zlink', "#ROOTCONFIGPATH#Extensions\\", v.file)
		end
	end

	UpdateStatus('Mod succeeded', 'done')
	UpdatePercent()
	if (firstTimeMod) then
		SKIN:Bang('["#@#AutoRestart.exe"]')
		SKIN:Bang('!Refresh')
	else
		SKIN:Bang('!CommandMeasure', 'Websocket', 'reloadspotify')
	end
end

extensionTable = {}
extensionPage = 1
extensionTotalPage = 1
function Extension_Init()
	local actExtension = Extension_ParseActivated()
	SKIN:Bang('!UpdateMeasure', 'ExtensionFolderCount')
	local count = SKIN:GetMeasure("ExtensionFolderCount"):GetValue()
	local name = SKIN:GetMeasure("ExtensionFolderName")

	extensionTotalPage = math.ceil(count / 5)
	for i = 1, count do
		SKIN:Bang('!SetOption', 'ExtensionFolderName', 'Index', i)
		SKIN:Bang('!UpdateMeasure', 'ExtensionFolderName')
		local p = name:GetStringValue()
		local f = io.open(SKIN:ReplaceVariables('#ROOTCONFIGPATH#Extensions\\') .. p, 'r')
		local d = f:read("*a")
		f:close()
		d = d:match("// START METADATA(.-)// END METADATA")
		local extensionElement = {
			file = p:lower(),
			name = p,
			author = 'N/A',
			descr = 'N/A'
		}
		if (d) then
			local extensionName = d:match('// NAME:(.-)\n'):gsub('^ ', '')
			extensionElement.name = extensionName and extensionName or p
			local extensionAuthor = d:match('// AUTHOR:(.-)\n'):gsub('^ ', '')
			extensionElement.author = extensionAuthor and extensionAuthor or 'N/A'
			local extensionDescr = d:match('// DESCRIPTION:(.-)\n'):gsub('^ ', '')
			extensionElement.descr = extensionDescr and extensionDescr or 'N/A'
		end

		table.insert(extensionTable, extensionElement)
	end
	Extension_DrawPage(extensionPage)
end

function Extension_ParseActivated()
	local r = {}
	local list = SKIN:GetVariable('ActivatedExtensions')
	if (list:sub(list:len()) ~= ';') then
		list = list .. ';'
		SKIN:Bang('!SetVariable', 'ActivatedExtensions', list)
		SKIN:Bang('!WriteKeyValue', 'Variables', 'ActivatedExtensions', list)
	end

	for extension in list:gmatch('(.-);') do
		r[extension:lower()] = true
	end
	return r
end

function Extension_DrawPage(n)
	local actExtension = Extension_ParseActivated()
	for i = 1, 5 do
		local index = (n - 1) * 5 + i
		if (extensionTable[index]) then
			local p = extensionTable[index]
			SKIN:Bang('!SetOption', 'ExtensionName' .. i, 'Text', p.name)
			SKIN:Bang('!SetOption', 'ExtensionName' .. i, 'ToolTipText', p.name)
			SKIN:Bang('!SetOption', 'ExtensionAuthor' .. i, 'Text', 'By ' .. p.author)
			SKIN:Bang('!SetOption', 'ExtensionAuthor' .. i, 'ToolTipText', p.author)
			SKIN:Bang('!SetOption', 'ExtensionDescr' .. i, 'Text', p.descr)
			SKIN:Bang('!SetOption', 'ExtensionDescr' .. i, 'ToolTipText', p.descr)
			if (actExtension[p.file]) then
				SKIN:Bang('!SetOption', 'ExtensionShadow' .. i, 'ImageAlpha', '')
				SKIN:Bang('!SetOption', 'ExtensionBack' .. i, 'Active', 'StrokeColor 8a4fff')
				SKIN:Bang('!SetOption', 'ExtensionActivate' .. i, 'Active', 'StrokeColor 8a4fff|FillColor 8a4fff')
				SKIN:Bang('!SetOption', 'ExtensionActivate' .. i, 'Active2', 'StrokeColor FFFFFF')
				SKIN:Bang('!SetOption', 'ExtensionActivate' .. i, 'MouseOverAction', '')
				SKIN:Bang('!SetOption', 'ExtensionActivate' .. i, 'MouseLeaveAction', '')
			else
				SKIN:Bang('!SetOption', 'ExtensionShadow' .. i, 'ImageAlpha', '0')
				SKIN:Bang('!SetOption', 'ExtensionBack' .. i, 'Active', 'StrokeColor 200,200,200,200')
				SKIN:Bang('!SetOption', 'ExtensionActivate' .. i, 'Active', 'StrokeColor 200,200,200,200|FillColor 0,0,0,0')
				SKIN:Bang('!SetOption', 'ExtensionActivate' .. i, 'Active2', 'StrokeColor 0,0,0,0')
				SKIN:Bang('!SetOption', 'ExtensionActivate' .. i, 'MouseOverAction',
					'[!SetOption #*CURRENTSECTION*# Active "StrokeColor 8a4fff|FillColor 8a4fff"][!UpdateMeter #*CURRENTSECTION*#][!Redraw]')
				SKIN:Bang('!SetOption', 'ExtensionActivate' .. i, 'MouseLeaveAction',
					'[!SetOption #*CURRENTSECTION*# Active "StrokeColor 200,200,200,200|FillColor 0,0,0,0"][!UpdateMeter #*CURRENTSECTION*#][!Redraw]')
			end
			SKIN:Bang('!SetOption', 'ExtensionActivate' .. i, 'LeftMouseUpAction',
				'!CommandMeasure Script "Extension_Toggle('.. index ..')"')
			SKIN:Bang('!ShowMeterGroup', 'ExtensionGroup' .. i)
		else
			SKIN:Bang('!HideMeterGroup', 'ExtensionGroup' .. i)
		end
		SKIN:Bang('!UpdateMeterGroup', 'ExtensionGroup' .. i)
		SKIN:Bang('!Redraw')
	end

	if (n == 1) then
		SKIN:Bang('!ShowMeter', 'ExtensionBack_Disabled')
		SKIN:Bang('!HideMeter', 'ExtensionBack')
	end
	if (n == extensionTotalPage) then
		SKIN:Bang('!ShowMeter', 'ExtensionNext_Disabled')
		SKIN:Bang('!HideMeter', 'ExtensionNext')
	end
	if (n > 1) then
		SKIN:Bang('!HideMeter', 'ExtensionBack_Disabled')
		SKIN:Bang('!ShowMeter', 'ExtensionBack')
	end
	if (n < extensionTotalPage) then
		SKIN:Bang('!HideMeter', 'ExtensionNext_Disabled')
		SKIN:Bang('!ShowMeter', 'ExtensionNext')
	end
	SKIN:Bang('!Redraw')
end

function Extension_Toggle(n)
	local actExtension = Extension_ParseActivated()
	local fileName = extensionTable[n].file
	actExtension[fileName] = not actExtension[fileName]
	local list = ''
	for k, v in pairs(actExtension) do
		if (v) then
			list = list .. k .. ';'
		end
	end
	SKIN:Bang('!SetVariable', 'ActivatedExtensions', list)
	SKIN:Bang('!WriteKeyValue', 'Variables', 'ActivatedExtensions', list)
	Extension_DrawPage(extensionPage)
end

function Extension_ChangePage(dir)
	if ((extensionPage + dir) >= 1) and ((extensionPage + dir) <= extensionTotalPage) then
		extensionPage = extensionPage + dir
		Extension_DrawPage(extensionPage)
	end
end
