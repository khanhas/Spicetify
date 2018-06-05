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

defaultSpotifyColor_Inc = table.concat({
	'[Variables]',
	'Main_FG = ffffff',
	'Secondary_FG = c0c0c0',
	'Main_BG = 282828',
	'Sidebar_And_Player_BG = 000000',
	'Cover_Overlay_And_Shadow = 000000',
	'Indicator_FG_And_Button_BG = 1db954',
	'Pressing_FG = cdcdcd',
	'Slider_BG = 404040',
	'Sidebar_Indicator_And_Hover_Button_BG = 1ed660',
	'Scrollbar_FG_And_Selected_Row_BG = 333333',
	'Pressing_Button_FG = cccccc',
	'Pressing_Button_BG = 179443',
	'Selected_Button = 18ac4d',
	'Miscellaneous_BG = 4687d6',
	'Miscellaneous_Hover_BG = 2e77d0',
	'Preserve_1 = ffffff'
}, '\n')

defaultSpotifyColorList = {
	"ffffff",
	"c0c0c0",
	"282828",
	"000000",
	"000000",
	"1db954",
	"cdcdcd",
	"404040",
	"1ed660",
	"333333",
	"cccccc",
	"179443",
	"18ac4d",
	"4687d6",
	"2e77d0",
	"ffffff"
}

function Initialize()
	-- Default Spotify colors
	defaultSpotifyColor = {}

	for i = 1, 16 do
		defaultSpotifyColor[i] = {
			hex = defaultSpotifyColorList[i],
			rgb = hexToRGB(defaultSpotifyColorList[i]),
			var = color[i].var
		}
	end

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
				file:write(defaultSpotifyColorScheme_Inc)
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
	DevTool_Button()
end

function ParseCoreSetting()
	injectCSS = SKIN:GetVariable("Inject_CSS") == '1'
	theme = SKIN:GetVariable("Replace_Colors") == '1'
	radio = SKIN:GetVariable("Radio") == '1'
	home = SKIN:GetVariable("Home") == '1'
	sentry = SKIN:GetVariable("DisableSentry") == '1'
	lyric_alwaysShow = SKIN:GetVariable("LyricAlwaysShow") == '1'
	lyric_noSync = SKIN:GetVariable("LyricForceNoSync") == '1'
	experimentalFeatures = SKIN:GetVariable("ExperimentalFeatures") == '1'
	fastUserSwitching = SKIN:GetVariable("FastUserSwitching") == '1'
	logging = SKIN:GetVariable("DisableUILogging") == '1'
end

liveUpdate = false
initLive = true
liveUserCSS = ''
oldLiveUserCSS = ''
function Update()
	if (totalSpa and not firstTimeMod) then
		if (liveUpdate) then
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
		if (#extensionWatch > 0) then
			for k,v in pairs(extensionWatch) do
				local f = io.open(SKIN:ReplaceVariables('#ROOTCONFIGPATH#Extensions\\' .. extensionTable[v.index].file), 'r')
				local cur = f:read('*a')
				f:close()
				if (v.init) then
					extensionWatch[k].old = cur
					extensionWatch[k].init = false
				end
				if (extensionWatch[k].old ~= cur) then
					extensionWatch[k].old = cur
					Extension_Update(v.index)
				end
			end
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
		local p = "#@#Extracted\\Raw\\" .. nX .. "\\bundle.js"
		local altP = "#@#Extracted\\Raw\\" .. nX .. "\\main.bundle.js"
		if (sentry) then
			function disableSentry(d)
				d = d:gsub('sentry%.install%(%),?', '', 1)
				return d
			end

			UpdateStatus("Removing Sentry of " .. n)
			if (not fileUtil(p, disableSentry)) then
				fileUtil(altP, disableSentry)
			end
		end

		if (logging and (
			nX == "browse" or nX == "collection" or
			nX == "genre" or nX == "hub" or
			nX == "zlink" or nX == "lyrics" or
			nX == "playlist"
		)) then
			function disableLogging(d)
				if (nX == "browse" or nX == "collection" or
					nX == "genre" or nX == "hub") then
					UpdateStatus("Removing UI logger of " .. n)
					d =d:gsub('logUIInteraction5%(json, logInConsole%) %{', '%1return;', 1)
						:gsub('logUIImpression5%(json, logInConsole%) %{', '%1return;', 1)
						:gsub('_logUIInteraction5%(json%) %{', '%1return;', 1)
						:gsub('_logUIImpression5%(json%) %{', '%1return;', 1)
						:gsub('this%._documentFragment%.query%(\'%[data%-log%-click%]\'%)', 'return;%1')
						:gsub('_onClickDataLogClick%(element%) %{', '%1return;')
						:gsub('_setUpStandardImpressionLogging%(%) %{', '%1return;')
				end

				if (nX == "zlink") then
					UpdateStatus("Removing UI logger of " .. n)
					d = d:gsub('_logUIInteraction5=function.-{', '%1return;')
							:gsub('_UIInteraction2%.default%.log', 'void')
				end

				if (nX == "lyrics") then
					UpdateStatus("Removing UI logger of " .. n)
					d = d:gsub('LoggingService%.prototype%..-%{', '%1return;')
				end

				if (nX == "playlist") then
					UpdateStatus("Removing UI logger of " .. n)
					d = d:gsub('(exports%.logPlaylistImpression = )logPlaylistImpression', '%1()=>{}', 1)
						 :gsub('(exports%.logEndOfListImpression = )logEndOfListImpression', '%1()=>{}', 1)
						 :gsub('(exports%.logListQuickJump = )logListQuickJump', '%1()=>{}', 1)
						 :gsub('(exports%.logListItemSelected = )logListItemSelected', '%1()=>{}', 1)
						 :gsub('(exports%.logFeedbackInteraction = )logFeedbackInteraction', '%1()=>{}', 1)
				end
				return d
			end

			if (not fileUtil(p, disableLogging)) then
				fileUtil(altP, disableLogging)
			end
		end

		fileUtil("#@#Extracted\\Raw\\" .. nX .. "\\index.html", function (data)
				if (nX ~= "zlink" and nX ~= "login") then
					data = data:gsub('css/glue%.css', 'https://zlink.app.spotify.com/css/glue.css', 1)
							:gsub('</head>', '<link rel="stylesheet" class="spicetify-userCSS" href="https://zlink.app.spotify.com/css/user.css">%1', 1)
				else
					data = data:gsub('</head>', '<link rel="stylesheet" class="spicetify-userCSS" href="css/user.css">%1', 1)
				end
				return data
			end
		)

		if (nX ~= "zlink" and nX ~= "login") then
			local path = SKIN:ReplaceVariables("#@#Extracted\\Raw\\" .. nX .. "\\css\\glue.css")
			local glue = io.open(path, 'r')
			if (glue) then
				glue:close()
				os.remove(path)
			end
		end
	end

	bC = bC + 1
	SKIN:Bang('!SetOption', 'BackupFileName', 'Index', bC)
	SKIN:Bang('!UpdateMeasure', 'BackupFileName')
	n = backupName:GetStringValue()
	if not n or n == '' then
		Duplicate()
		nx = nil
		return
	end
	nX = n:gsub('%.spa','')
	UpdateStatus("Unzipping " .. n)
	UpdatePercent()

	SKIN:Bang('!SetOption', 'Unzip', 'Parameter', '"7z.exe x "Backup\\' .. n .. '" -oExtracted\\Raw\\' .. nX .. '\\ -r"')

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
	local totalApply = 3
			+ (injectCSS and 1 or 0)
			+ (theme and 1 or 0)
			+ (devTool and 1 or 0)
			+ (radio and 1 or 0)
			+ (home and 1 or 0)
			+ (lyric_alwaysShow and 1 or 0)
			+ (lyric_noSync and 1 or 0)
			+ (experimentalFeatures and 1 or 0)
			+ (fastUserSwitching and 1 or 0)
			+ (vis_highFramerate and 1 or 0)
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
	file:write(defaultSpotifyColorScheme_Inc)
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
		if (extension) then
			extension:write(extensionData)
			extension:close()
		else
			print("Cannot inject extension" .. extensionFile .. ". Check %appdata%\\Spotify\\Apps\\" .. packName .. " folder to see if it exists.")
		end
	end
end

function CopyUserCSS()
	UpdateStatus('Transferring user.css')
	local d = {}


	UpdatePercent()
	table.insert(d, ':root {')
	local colorTable = theme and color or defaultSpotifyColor
	for k,v in ipairs(colorTable) do
		table.insert(d, table.concat({
			'	--modspotify_', v.var, ':#', v.hex, ';\n',
			'	--modspotify_rgb_', v.var, ':', v.rgb, ';'
		}))
	end
	table.insert(d, '}')


	if injectCSS then
		UpdatePercent()
		local css = io.open(SKIN:ReplaceVariables("#ROOTCONFIGPATH#Themes\\#CurrentTheme#\\user.css"),'r')
		local u = ''
		if (css) then
			u = css:read('*a')
		else
			print('user.css is not found in theme folder. Please make one.')
		end
		css:close()
		table.insert(d, u)
	end
	for _, v in pairs({"zlink", "login"}) do
		local f = io.open(SKIN:ReplaceVariables("%appdata%\\Spotify\\Apps\\" .. v .. "\\css\\user.css"), 'w+')
		if (f) then
			f:write(table.concat(d, '\n'))
			f:close()
		end
	end
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
		UpdatePercent()
	end

	if (radio) then
		UpdateStatus('Enabling Radio')
		ModJS('zlink', 'main.bundle', {
			{'%(0,_productState%.hasValue%)%("radio","1"%)', 'true'}
		})
		UpdatePercent()
	end

	if (home) then
		UpdateStatus('Enabling Home')
		ModJS('zlink', 'main.bundle', {
			{'this._initialState.isHomeEnabled', 'true'},
			{'isHomeEnabled(%?void 0:_flowControl)', 'true%1', 1}
		})
		UpdatePercent()
	end

	if (lyric_alwaysShow) then
		UpdateStatus('Enabling Always show lyrics button')
		ModJS('zlink', 'main.bundle', {
			{'(lyricsEnabled%()trackHasLyrics&&%(.-%)', '%1true', 1}
		})
		UpdatePercent()
	end

	local modOptions = ''

	if (vis_highFramerate) then
		modOptions = modOptions .. 'trackControllerOpts.highVisualizationFrameRate = true;\n'
		UpdatePercent()
	end
	if (lyric_noSync) then
		modOptions = modOptions .. 'lyricsControllerOpts.forceNoSyncLyrics = true;\n'
		UpdatePercent()
	end

	if (modOptions ~= '') then
		ModJS('lyrics', 'bundle', {
			{'trackController%.init%(trackControllerOpts%)', modOptions .. '%1', 1}
		})
	end

	if (experimentalFeatures) then
		UpdateStatus('Enabling Experimental Features')
		ModJS('zlink', 'main.bundle', {
			{'isExperimentalFeaturesEnabled&&', 'true&&', 1}
		})
		UpdatePercent()
	end

	if (fastUserSwitching) then
		UpdateStatus('Enabling Fast user switching')
		ModJS('zlink', 'main.bundle', {
			{'isFastUserSwitchingEnabled&&', 'true&&', 1}
		})
		UpdatePercent()
	end

	UpdateStatus('Injecting a websocket and jquery 3.3.1')
	ModHTML('zlink', {
		{'(</body>)', '<script type="text/javascript" src="/jquery-3.3.1.min.js"></script><script type="text/javascript" src="/spicetifyWebSocket.js"></script>%1'}
	})

	ModInjectExtension('zlink', "#@#JavascriptInject\\", 'spicetifyWebSocket.js')
	ModInjectExtension('zlink', "#@#JavascriptInject\\", 'jquery-3.3.1.min.js')

	UpdateStatus('Leaking useful functions, objects')
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
			'chrome.player.dispatchEvent=(event)=>{if(!(event.type in chrome.player.eventListeners)){return true}var stack=chrome.player.eventListeners[event.type];for(var i=0,l=stack.length;i<l;i+=1){stack[i](event)}return!event.defaultPrevented};',
		}), 1},

		--Leak track meta data, player state, current playlist to chrome.playerData
		{'const metadata=data%.track%.metadata;', '%1chrome.playerData=data;', 1},
		--Leak localStorage and showNotification
		{'_localStorage2%.default%.get%(SETTINGS_KEY_AD%);', '%1chrome.localStorage=_localStorage2.default;chrome.showNotification = text => {_eventDispatcher2.default.dispatchEvent(new _event2.default(_event2.default.TYPES.SHOW_NOTIFICATION_BUBBLE, {i18n: text}))};', 1},
		--Leak bridgeAPI
		{'BuddyList%.prototype%.setup=function%(%)%{', '%1chrome.bridgeAPI = _bridge;', 1},
		--Leak audio data fetcher to chrome.getAudioData
		{'PlayerHelper%.prototype%._player=null', table.concat({
			'var uriToId=u=>{var t=u.match(/^spotify:track:(.*)/);if(!t||t.length<2)return false;else return t[1]};',
			'chrome.getAudioData=(callback, uri)=>{uri=uri||chrome.playerData.track.uri;if(typeof(callback)!=="function"){console.log("chrome.getAudioData: callback has to be a function");return;};var id=uriToId(uri);if(id)cosmos.resolver.get(`hm://audio-attributes/v1/audio-analysis/${id}`, (e,p)=>{if(e){console.log(e);callback(null);return;}if(p._status===200&&p._body&&p._body!==""){var data=JSON.parse(p._body);data.uri=uri;callback(data);}else callback(null)})};',
			'new Player(cosmos.resolver,"spotify:internal:queue","queue","1.0.0").subscribeToQueue((e,r)=>{if(e){console.log(e);return;}chrome.queue=r.getJSONBody();});',
			'%1'}), 1},
		{'const Adaptor=function%(bridge,cosmos%)%{', table.concat({'%1',
			'chrome.libURI = liburi;',
			'chrome.addToQueue=(uri,callback)=>{uri=liburi.from(uri);if(uri.type===liburi.Type.ALBUM){this.getAlbumTracks(uri,(err,tracks)=>{if(err){console.log("chrome.addToQueue",err);return};this.queueTracks(tracks,callback)})}else if(uri.type===liburi.Type.TRACK||uri.type===liburi.Type.EPISODE){this.queueTracks([uri],callback)}else{console.log("chrome.addToQueue: Only Track, Album, Episode URIs are accepted")}};',
			'chrome.removeFromQueue=(uri,callback)=>{if(chrome.queue){var indices=[],uriObj=liburi.from(uri);if(uriObj.type===liburi.Type.ALBUM){this.getAlbumTracks(uriObj,(err,tracks)=>{if(err){console.log(err);return}tracks.forEach(t=>chrome.queue.next_tracks.forEach((nt,index)=>t==nt.uri&&indices.push(index)))})}else if(uriObj.type===liburi.Type.TRACK||uriObj.type===liburi.Type.EPISODE){chrome.queue.next_tracks.forEach((track,index)=>track.uri==uri&&indices.push(index))}else{console.log("chrome.removeFromQueue: Only Album, Track and Episode URIs are accepted")}indices=indices.reduce((a,b)=>{if(a.indexOf(b)<0){a.push(b)}return a},[]);this.removeTracksFromQueue(indices,callback)}};',
		}), 1},
		--Register song change event
		{'this%._uri=track%.uri,this%._trackMetadata=track%.metadata', '%1,chrome.player&&chrome.player.dispatchEvent(new Event("songchange"))', 1},
		--Register play/pause state change event
		{'this%.playing%(data%.is_playing&&!data%.is_paused%).-;', '%1(this.playing()!==this._isPlaying)&&(this._isPlaying=this.playing(),chrome.player&&chrome.player.dispatchEvent(new Event("onplaypause")));', 1},
		--Register progress change event
		{'PlayerUI%.prototype%._onProgressBarProgress=function.-%{', '%1chrome.player&&chrome.player.dispatchEvent(new Event("onprogress"));', 1},
		--Leak Cosmos API to chrome.cosmosAPI
		{'var _cosmosApi2=_interop.-;', '%1chrome.cosmosAPI=_cosmosApi2.default;', 1}
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

	actApp, actAppCount = App_ParseActivated()
	if (actAppCount > 0) then
		App_CopyRountine(1)
	else
		Succeeded()
	end
end

function Succeeded()
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
extensionWatch = {}
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
	Extension_DrawPage()
end

function Extension_ParseActivated()
	local r = {}
	local list = SKIN:GetVariable('ActivatedExtensions', '')
	if (list:len() <= 1) then
		SKIN:Bang('!SetVariable', 'ActivatedExtensions', " ")
		SKIN:Bang('!WriteKeyValue', 'Variables', 'ActivatedExtensions', " ")
		return r
	elseif (list:sub(list:len()) ~= ';') then
		list = list .. ';'
		SKIN:Bang('!SetVariable', 'ActivatedExtensions', list)
		SKIN:Bang('!WriteKeyValue', 'Variables', 'ActivatedExtensions', list)
	end

	local needRewrite = false
	for extension in list:gmatch('(.-);') do
		extension = extension:lower()
		for _, v in pairs(extensionTable) do
			if (v.file == extension) then
				r[extension] = true
				break
			end
			needRewrite = true
		end
	end
	if (needRewrite) then
		local newList = ''
		for k,_ in pairs(r) do
			newList = newList .. k .. ';'
		end
		SKIN:Bang('!SetVariable', 'ActivatedExtensions', newList)
		SKIN:Bang('!WriteKeyValue', 'Variables', 'ActivatedExtensions', newList)
	end

	return r
end

function Extension_DrawPage()
	local n = extensionPage
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
			SKIN:Bang('!SetOption', 'ExtensionBack' .. i, 'LeftMouseUpAction', '!CommandMeasure Script "Extension_ShowOption(' .. index .. ',' .. i .. ')"')
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

	local isWatching, watchIndex = Extension_IsWatching(n)
	if (isWatching) then
		table.remove(extensionWatch, watchIndex)
	end

	UpdateStatus('Hit Re-apply to update extension changes', 'ok')
	Extension_DrawPage()
end

function Extension_ChangePage(dir)
	if ((extensionPage + dir) >= 1) and ((extensionPage + dir) <= extensionTotalPage) then
		extensionPage = extensionPage + dir
		Extension_DrawPage()
	end
end

function Extension_IsWatching(i)
	for k,v in pairs(extensionWatch) do
		if (i == v.index) then
			return true, k
		end
	end
	return false
end

function Extension_ShowOption(index, meterIndex)
	SKIN:Bang('!ShowMeterGroup', 'ExtensionOption')
	SKIN:Bang('!SetOption', 'ExtensionOptionOpen', 'LeftMouseUpAction',
		'["#ROOTCONFIGPATH#Extensions\\' .. extensionTable[index].file .. '"]')

		SKIN:Bang('!SetOption', 'ExtensionOptionUpdate', 'LeftMouseUpAction',
		'!CommandMeasure Script "Extension_Update(' .. index .. ')"')

	local actExtension = Extension_ParseActivated()
	if (actExtension[extensionTable[index].file]) then
		SKIN:Bang('!SetOption', 'ExtensionOptionOpen', 'X', '(150-50)r')
		SKIN:Bang('!SetOption', 'ExtensionOptionWatch', 'LeftMouseUpAction',
			'!CommandMeasure Script "Extension_WatchToggle(' .. index .. ')"')

		if (Extension_IsWatching(index)) then
			SKIN:Bang('!SetOption', 'ExtensionOptionWatch', 'FontColor', '8a4fff')
		else
			SKIN:Bang('!SetOption', 'ExtensionOptionWatch', 'FontColor', '000000')
		end
	else
		SKIN:Bang('!SetOption', 'ExtensionOptionOpen', 'X', '150r')
		SKIN:Bang('!HideMeter', 'ExtensionOptionWatch')
		SKIN:Bang('!HideMeter', 'ExtensionOptionUpdate')
	end

	SKIN:Bang('!SetOption', 'ExtensionOptionBack', 'Y',
		SKIN:GetMeter('ExtensionBack' .. meterIndex):GetY())
	SKIN:Bang('!SetOption', 'ExtensionOptionBack', 'MouseLeaveAction',
		'[!HideMeterGroup ExtensionOption][!CommandMeasure Script "Extension_DrawPage()"]')
	SKIN:Bang('!UpdateMeterGroup', 'ExtensionOption')

	SKIN:Bang('!SetOption', 'ExtensionName' .. meterIndex, 'ToolTipText', '')
	SKIN:Bang('!SetOption', 'ExtensionAuthor' .. meterIndex, 'ToolTipText', '')
	SKIN:Bang('!SetOption', 'ExtensionBack' .. meterIndex, 'LeftMouseUpAction', '')
	SKIN:Bang('!SetOption', 'ExtensionActivate' .. meterIndex, 'LeftMouseUpAction', '')
	SKIN:Bang('!SetOption', 'ExtensionActivate' .. meterIndex, 'MouseOverAction', '')
	SKIN:Bang('!SetOption', 'ExtensionActivate' .. meterIndex, 'MouseLeaveAction', '')
	SKIN:Bang('!UpdateMeterGroup ', 'ExtensionGroup' .. meterIndex)
	SKIN:Bang('!Redraw')
end

function Extension_WatchToggle(i)
	local isWatching, watchIndex = Extension_IsWatching(i)
	if (isWatching) then
		table.remove(extensionWatch, watchIndex)
		SKIN:Bang('!SetOption', 'ExtensionOptionWatch', 'FontColor', '000000')
		SKIN:Bang('!UpdateMeter', 'ExtensionOptionWatch')
		SKIN:Bang('!Redraw')
		return
	end
	table.insert(extensionWatch, {
		index = i,
		old = '',
		init = true
	})
	SKIN:Bang('!SetOption', 'ExtensionOptionWatch', 'FontColor', '8a4fff')
	SKIN:Bang('!UpdateMeter', 'ExtensionOptionWatch')
	SKIN:Bang('!Redraw')
end

function Extension_Update(index)
	local file = extensionTable[index].file
	ModInjectExtension('zlink', '#ROOTCONFIGPATH#Extensions\\', file)
	SKIN:Bang('!CommandMeasure', 'WebSocket', 'reloadspotify')
	UpdateStatus(file .. ' is updated at ' .. os.date("%X %x"), 'done')
end

-- APPS
appTable = {}
appPage = 1
appTotalPage = 1
function App_Init()
	SKIN:Bang('!UpdateMeasure', 'AppFolderCount')
	local count = SKIN:GetMeasure("AppFolderCount"):GetValue()
	local name = SKIN:GetMeasure("AppFolderName")

	appTotalPage = math.ceil(count / 5)
	for i = 1, count do
		SKIN:Bang('!SetOption', 'AppFolderName', 'Index', i)
		SKIN:Bang('!UpdateMeasure', 'AppFolderName')
		local p = name:GetStringValue()
		local isValid = true
		-- Check folder name
		for char in p:gmatch('.') do
			local b = string.byte(char)
			if (not (b >= 97 and b <= 122)) then
				isValid = false
				print('"'..p .. '" folder name is not valid. Please use only lowercase alphabet characters and no space.')
				break
			end
		end

		if (isValid) then
			local f = io.open(SKIN:ReplaceVariables('#ROOTCONFIGPATH#Apps\\' .. p ..'\\index.html'), 'r')

			local appElement = {
				file = p,
				name = p,
				author = 'N/A',
				descr = 'N/A'
			}
			if (f) then
				local d = f:read("*a")
				f:close()
				d = d:match("// START METADATA(.-)// END METADATA")

				if (d) then
					local appName = d:match('// NAME:(.-)\n'):gsub('^ ', '')
					appElement.name = appName and appName or p
					local appAuthor = d:match('// AUTHOR:(.-)\n'):gsub('^ ', '')
					appElement.author = appAuthor and appAuthor or 'N/A'
					local appDescr = d:match('// DESCRIPTION:(.-)\n'):gsub('^ ', '')
					appElement.descr = appDescr and appDescr or 'N/A'
				end
			end

			table.insert(appTable, appElement)
		end
	end
	App_DrawPage()
end

function NormalizeAppId(name)
	return name
end

function App_ParseActivated()
	local r = {}
	local list = SKIN:GetVariable('ActivatedApps', '')
	local appCount = 0

	if (list:len() <= 1) then
		SKIN:Bang('!SetVariable', 'ActivatedApps', " ")
		SKIN:Bang('!WriteKeyValue', 'Variables', 'ActivatedApps', " ")
		return r, 0
	elseif (list:sub(list:len()) ~= ';') then
		list = list .. ';'
		SKIN:Bang('!SetVariable', 'ActivatedApps', list)
		SKIN:Bang('!WriteKeyValue', 'Variables', 'ActivatedApps', list)
	end

	local needRewrite = false
	for app in list:gmatch('(.-);') do
		app = app:lower()
		for _, v in pairs(appTable) do
			if (v.file == app) then
				r[app] = true
				appCount = appCount + 1
				break
			end
			needRewrite = true
		end
	end

	if (needRewrite) then
		local newList = ''
		for k,_ in pairs(r) do
			newList = newList .. k .. ';'
		end
		SKIN:Bang('!SetVariable', 'ActivatedApps', newList)
		SKIN:Bang('!WriteKeyValue', 'Variables', 'ActivatedApps', newList)
	end
	return r, appCount
end

function App_DrawPage()
	local n = appPage
	local actApp = App_ParseActivated()
	for i = 1, 5 do
		local index = (n - 1) * 5 + i
		if (appTable[index]) then
			local p = appTable[index]
			SKIN:Bang('!SetOption', 'AppName' .. i, 'Text', p.name)
			SKIN:Bang('!SetOption', 'AppName' .. i, 'ToolTipText', p.name)
			SKIN:Bang('!SetOption', 'AppAuthor' .. i, 'Text', 'By ' .. p.author)
			SKIN:Bang('!SetOption', 'AppAuthor' .. i, 'ToolTipText', p.author)
			SKIN:Bang('!SetOption', 'AppDescr' .. i, 'Text', p.descr)
			SKIN:Bang('!SetOption', 'AppDescr' .. i, 'ToolTipText', p.descr)
			SKIN:Bang('!SetOption', 'AppBack' .. i, 'LeftMouseUpAction', '!CommandMeasure Script "App_ShowOption(' .. index .. ',' .. i .. ')"')
			if (actApp[p.file]) then
				SKIN:Bang('!SetOption', 'AppShadow' .. i, 'ImageAlpha', '')
				SKIN:Bang('!SetOption', 'AppBack' .. i, 'Active', 'StrokeColor 8a4fff')
				SKIN:Bang('!SetOption', 'AppActivate' .. i, 'Active', 'StrokeColor 8a4fff|FillColor 8a4fff')
				SKIN:Bang('!SetOption', 'AppActivate' .. i, 'Active2', 'StrokeColor FFFFFF')
				SKIN:Bang('!SetOption', 'AppActivate' .. i, 'MouseOverAction', '')
				SKIN:Bang('!SetOption', 'AppActivate' .. i, 'MouseLeaveAction', '')
			else
				SKIN:Bang('!SetOption', 'AppShadow' .. i, 'ImageAlpha', '0')
				SKIN:Bang('!SetOption', 'AppBack' .. i, 'Active', 'StrokeColor 200,200,200,200')
				SKIN:Bang('!SetOption', 'AppActivate' .. i, 'Active', 'StrokeColor 200,200,200,200|FillColor 0,0,0,0')
				SKIN:Bang('!SetOption', 'AppActivate' .. i, 'Active2', 'StrokeColor 0,0,0,0')
				SKIN:Bang('!SetOption', 'AppActivate' .. i, 'MouseOverAction',
					'[!SetOption #*CURRENTSECTION*# Active "StrokeColor 8a4fff|FillColor 8a4fff"][!UpdateMeter #*CURRENTSECTION*#][!Redraw]')
				SKIN:Bang('!SetOption', 'AppActivate' .. i, 'MouseLeaveAction',
					'[!SetOption #*CURRENTSECTION*# Active "StrokeColor 200,200,200,200|FillColor 0,0,0,0"][!UpdateMeter #*CURRENTSECTION*#][!Redraw]')
			end
			SKIN:Bang('!SetOption', 'AppActivate' .. i, 'LeftMouseUpAction',
				'!CommandMeasure Script "App_Toggle('.. index ..')"')
			SKIN:Bang('!ShowMeterGroup', 'AppGroup' .. i)
		else
			SKIN:Bang('!HideMeterGroup', 'AppGroup' .. i)
		end
		SKIN:Bang('!UpdateMeterGroup', 'AppGroup' .. i)
	end

	if (n == 1) then
		SKIN:Bang('!ShowMeter', 'AppBack_Disabled')
		SKIN:Bang('!HideMeter', 'AppBack')
	end
	if (n == appTotalPage) then
		SKIN:Bang('!ShowMeter', 'AppNext_Disabled')
		SKIN:Bang('!HideMeter', 'AppNext')
	end
	if (n > 1) then
		SKIN:Bang('!HideMeter', 'AppBack_Disabled')
		SKIN:Bang('!ShowMeter', 'AppBack')
	end
	if (n < appTotalPage) then
		SKIN:Bang('!HideMeter', 'AppNext_Disabled')
		SKIN:Bang('!ShowMeter', 'AppNext')
	end
	SKIN:Bang('!Redraw')
end

function App_Toggle(n)
	local actApp = App_ParseActivated()
	local fileName = appTable[n].file
	actApp[fileName] = not actApp[fileName]
	local list = ''
	for k, v in pairs(actApp) do
		if (v) then
			list = list .. k .. ';'
		end
	end
	SKIN:Bang('!SetVariable', 'ActivatedApps', list)
	SKIN:Bang('!WriteKeyValue', 'Variables', 'ActivatedApps', list)

	UpdateStatus('Hit Re-apply to update app changes', 'ok')
	App_DrawPage()
end

function App_ChangePage(dir)
	if ((appPage + dir) >= 1) and ((appPage + dir) <= appTotalPage) then
		appPage = appPage + dir
		App_DrawPage()
	end
end

function App_CopyRountine(appIndex)
	if (not appPageLogger or not appMenuItems) then
		appPageLogger, appMenuItems = {}, {}
	end

	if appIndex > #appTable then
		ModJS('zlink', 'main.bundle', {
			{'PAGE_LOGGER_MAP=%{', '%1' .. table.concat(appPageLogger), 1},
			{'(return _pageIdentifiers2%.default%[normalizedAppId%]||)(_pageIdentifiers2%.default%.unknownUncovered)',
			'%1normalizedAppId||%2', 1},
			{'_react2%.default%.createElement%(_SidebarList2%.default,%{title',
			'_react2.default.createElement(_SidebarList2.default,{title:"Your app"},'
				.. table.concat(appMenuItems, ",") .. ')),_react2.default.createElement("div",{className:"LeftSidebar__section"},%1', 1}
		})
		appPageLogger, appMenuItems = nil, nil
		Succeeded()
		return
	end
	local app = appTable[appIndex]
	if (actApp[app.file]) then
		App_UpdateManifest(app.file)

		UpdateStatus('Injecting app ' .. app.name)
		SKIN:Bang('!SetOption', 'CopyApp', 'Parameter', table.concat({
			'robocopy "#ROOTCONFIGPATH#Apps\\', app.file,
			'" "%appdata%\\Spotify\\Apps\\', app.file,
			'" /S /COPY:D /R:10 /W:1 /NS /LOG', appIndex ~= 1 and '+' or '',
			':"#@#robocopy_copyapp_log.txt"'
		}))
		SKIN:Bang('!SetOption', 'CopyApp', 'FinishAction',
			'!CommandMeasure Script "App_CopyRountine(' .. (appIndex + 1) .. ')"')
		SKIN:Bang('!UpdateMeasure', 'CopyApp')

		table.insert(appPageLogger, table.concat(
			{'"', app.file, '":"',  app.file, '",'}
		))

		table.insert(appMenuItems, table.concat(
			{'_react2.default.createElement(_SidebarListItem2.default,{isActive:/^spotify:app:', app.file,'(\\:.*)?$/.test(lastRequestedPageUri),isBold:!0,label:"', app.name, '",uri:"spotify:app:', app.file, '"})'}
		))

		SKIN:Bang('!CommandMeasure', 'CopyApp', 'Run')
		return
	end

	App_CopyRountine(appIndex + 1)
end

function App_ShowOption(index, meterIndex)
	SKIN:Bang('!ShowMeterGroup', 'AppOption')
	SKIN:Bang('!SetOption', 'AppOptionOpen', 'LeftMouseUpAction',
		'"#ROOTCONFIGPATH#Apps\\' .. appTable[index].file .. '"')

	SKIN:Bang('!SetOption', 'AppOptionUpdate', 'LeftMouseUpAction',
		'!CommandMeasure Script "App_Update(' .. index .. ')"')

	local actApp = App_ParseActivated()
	if (actApp[appTable[index].file]) then
		SKIN:Bang('!SetOption', 'AppOptionOpen', 'X', '(150-20)r')
	else
		SKIN:Bang('!SetOption', 'AppOptionOpen', 'X', '150r')
		SKIN:Bang('!HideMeter', 'AppOptionUpdate')
	end

	SKIN:Bang('!SetOption', 'AppOptionBack', 'Y',
		SKIN:GetMeter('AppBack' .. meterIndex):GetY())
	SKIN:Bang('!SetOption', 'AppOptionBack', 'MouseLeaveAction',
		'[!HideMeterGroup AppOption][!CommandMeasure Script "App_DrawPage()"]')
	SKIN:Bang('!UpdateMeterGroup', 'AppOption')

	SKIN:Bang('!SetOption', 'AppName' .. meterIndex, 'ToolTipText', '')
	SKIN:Bang('!SetOption', 'AppAuthor' .. meterIndex, 'ToolTipText', '')
	SKIN:Bang('!SetOption', 'AppBack' .. meterIndex, 'LeftMouseUpAction', '')
	SKIN:Bang('!SetOption', 'AppActivate' .. meterIndex, 'LeftMouseUpAction', '')
	SKIN:Bang('!SetOption', 'AppActivate' .. meterIndex, 'MouseOverAction', '')
	SKIN:Bang('!SetOption', 'AppActivate' .. meterIndex, 'MouseLeaveAction', '')
	SKIN:Bang('!UpdateMeterGroup ', 'AppGroup' .. meterIndex)
	SKIN:Bang('!Redraw')
end

function App_Update(index)
	local file = appTable[index].file

	App_UpdateManifest(file)

	SKIN:Bang('!SetOption', 'CopyApp', 'Parameter', table.concat({
		'robocopy "#ROOTCONFIGPATH#Apps\\', file,
		'" "%appdata%\\Spotify\\Apps\\', file,
		'" /S /COPY:D /R:10 /W:1 /NS /LOG',
		':"#@#robocopy_copyapp_log.txt"'
	}))
	SKIN:Bang('!SetOption', 'CopyApp', 'FinishAction',
		'!CommandMeasure Script "App_UpdateStatus(' .. index .. ')"')
	SKIN:Bang('!UpdateMeasure', 'CopyApp')
	SKIN:Bang('!CommandMeasure', 'CopyApp', 'Run')
end

function App_UpdateStatus(index)
	local file = appTable[index].file
	UpdateStatus(file .. ' app is updated at ' .. os.date("%X %x"), 'done')
	SKIN:Bang('!CommandMeasure', 'WebSocket', 'reloadspotify')
end

function App_UpdateManifest(file)
	UpdateStatus('Checking manifest.json of app ' .. file)
	local path = SKIN:ReplaceVariables("#ROOTCONFIGPATH#Apps\\" .. file .. "\\manifest.json")
	local manifest = io.open(path, 'r')
	local needCopy = false
	if (manifest) then
		local data = manifest:read("*a")
		manifest:close()
		local bundleID, appName = data:match('("BundleIdentifier").-"(.-)"')
		if (bundleID) then
			if (appName and appName ~= file) then
				data = data:gsub('("BundleIdentifier".-)".-"', '%1"' .. file .. '"')
				manifest = io.open(path, 'w')
				manifest:write(data)
				manifest:close()
			elseif (not appName) then
				needCopy = true
			end
		else
			needCopy = true
		end
	else
		needCopy = true
	end

	if (needCopy) then
		local templateManifest = io.open(SKIN:ReplaceVariables("#@#Extracted\\Raw\\zlink\\manifest.json"), 'r')
		local data = templateManifest:read("*a")
		templateManifest:close()
		data = data:gsub('("BundleIdentifier".-)".-"', '%1"' .. file .. '"')
		manifest = io.open(path, 'w+')
		manifest:write(data)
		manifest:close()
	end
end

function DevTool_Button()
	local prefsFilePath = SKIN:ReplaceVariables("%appdata%\\Spotify\\prefs")
	local f = io.open(prefsFilePath, "r")
	if (f) then
		local data = f:read("*a")
		f:close()
		local key, value = data:match("(app%.enable%-developer%-mode).-(%w+)")
		if (key and value == "true") then
			SKIN:Bang("!SetOption", "DevToolText", "Text", "[\\xf14a] Developer mode")
			SKIN:Bang("!SetOption", "DevToolText", "LeftMouseUpAction", '!CommandMeasure Script "DevTool_Toggle(false)"')
		else
			SKIN:Bang("!SetOption", "DevToolText", "Text", "[\\xf0c8] Developer mode")
			SKIN:Bang("!SetOption", "DevToolText", "LeftMouseUpAction", '!CommandMeasure Script "DevTool_Toggle(true)"')
		end
	else
		SKIN:Bang("!SetOption", "DevTool", "MouseOverAction", "[!ShowMeterGroup DevToolTip][!Redraw]")
		SKIN:Bang("!SetOption", "DevTool", "MouseLeaveAction", "[!HideMeterGroup DevToolTip][!Redraw]")
		SKIN:Bang("!SetOption", "DevTool", "StrokeColor", "Stroke Color 909090")
		SKIN:Bang("!SetOption", "DevToolText", "FontColor", "909090")
		SKIN:Bang("!SetOption", "DevToolTipText", "Text", "%appdata%\\Spotify\\prefs file is not found. Please make one or reinstall Spotify, then refresh Spicetify.")
		SKIN:Bang("!UpdateMeter", "DevTool")
		SKIN:Bang("!UpdateMeter", "DevToolTipText")
	end
	SKIN:Bang("!UpdateMeter", "DevToolText")
	SKIN:Bang("!Redraw")
end

function DevTool_Toggle(enable)
	local prefsFilePath = SKIN:ReplaceVariables("%appdata%\\Spotify\\prefs")
	local f = io.open(prefsFilePath, "r")
	if (f) then
		local data = f:read("*a")
		f:close()
		local key = data:match("(app%.enable%-developer%-mode).-%w+")
		if (key) then
			data = data:gsub("(app%.enable%-developer%-mode).-%w+", "%1=" .. (enable and "true" or "false"), 1)
		else
			data = data .. "\napp.enable-developer-mode=" .. (enable and "true" or "false") .. "\n"
		end
		f = io.open(prefsFilePath, "w")
		if (f) then
			f:write(data)
			f:close()
			DevTool_Button()
			SKIN:Bang('["#@#AutoRestart.exe"]')
		else
			UpdateStatus("Cannot write to file %appdata%\\Spotify\\prefs.", "warn")
		end
	else
		UpdateStatus("%appdata%\\Spotify\\prefs file is not found. Please make one or reinstall Spotify.", "warn")
	end
end