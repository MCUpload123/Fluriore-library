local Flur_Url = "https://raw.githubusercontent.com/MCUpload123/Fluriore-library/refs/heads/main/Flur.lua"

local function loadFlurioreLib()
	local ok, source = pcall(function()
		return game:HttpGet(Flur_Url)
	end)
	if ok and type(source) == "string" and #source > 0 then
		local fn, err = loadstring(source)
		if fn then
			return fn()
		end
		warn("[Fluriore] loadstring failed:", err)
	end
	warn("[Fluriore] HttpGet failed, expecting Flur.lua beside this script in Studio only")
	return nil
end

local FlurioreLib = loadFlurioreLib()
if not FlurioreLib then return end

-- library-level notify helpers
FlurioreLib:SetNotifyPosition("BottomRight")
FlurioreLib:SetNotifyMax(5)
FlurioreLib:SetNotifyBlur(false)
FlurioreLib:SetBlurSize(14)

local Window = FlurioreLib:MakeGui({
	NameHub = "Fluriore Demo",
	Description = "Full API showcase",
	Color = Color3.fromRGB(140, 90, 255),
	TextScale = 0.85,
	UIScale = 0.9,
	Size = { X = 520, Y = 360 },
	Blur = false,
	RealGlass = false,
	RealGlassIntensity = 1,

	-- Key system: off by default. Set KeySystem = true to require a key before the window opens.
	KeySystem = false,
	KeySettings = {
		Title = "Fluriore Demo",
		Subtitle = "Enter a demo key to continue",
		Keys = {
			"FLUR-DEMO-0001",
			{ Key = "TRIAL-1234", Label = "Trial", Expires = 1798761600 }, -- os.time value: 2027-01-01 UTC
		},
		GetKeyLinks = {
			{ Label = "Discord", Url = "https://discord.gg/your-invite" },
			{ Label = "Copy demo key", Action = function(ctx)
				ctx.Copy("FLUR-DEMO-0001")
				ctx.Status("Demo key copied")
			end },
		},
		Save = true,
		SaveFile = "FlurDemoKey.txt",
	},
	ThemePreset = "Midnight",
	MobileToggle = {
		Size = 44,
		Corner = 10,
		Smooth = true,
		TweenTime = 0.22,
		Position = UDim2.new(0, 14, 0, 14),
	},
	SafeArea = { Top = 0, Bottom = 0, Left = 0, Right = 0 },
})

-- window chrome
Window:SetTitle("Fluriore Demo")
Window:SetDescription("Every public API")
Window:SetFlagPrefix("demo_")
Window:SetCornerRadius(10)
Window:SetOpacity({ Main = 0.12, Top = 0.999, Section = 0.935 })
Window:SetBlur(false)
Window:SetBlurAmount(0.45)
Window:SetBlurAnimate(true)
Window:SetAccent(Color3.fromRGB(140, 90, 255))
Window:SetAccentTransparency(0)
Window:SetBackgroundImage(false)
Window:SetBackgroundScaleType("Crop")
Window:SetToggleKey(Enum.KeyCode.RightShift)
Window:ApplySafeAreaAuto()
Window:SetMobileToggleColor(Color3.fromRGB(140, 90, 255))
Window:SetMobileToggleSmooth(true)

-- config / autosave (Toggle kind off by default)
Window:EnableAutoSave("FlurioreConfigs", "demo", {
	Toggle = false,
	Slider = true,
	Input = true,
	Dropdown = true,
	Keybind = true,
	ColorPicker = true,
	ColorCycle = true,
})
Window:SetAutoSaveFlags(nil)
-- Window:SetAutoSaveFlags({ "power", "map" }) -- only these flags
-- Window:SetAutoSaveFilter("Toggle", true)

Window:BindKey("demo_print", Enum.KeyCode.P, function()
	FlurioreLib:MakeNotify({
		Title = "BindKey",
		Description = "Global",
		Content = "Pressed P",
		Priority = "normal",
		Delay = 3,
	})
end)

local TabMain = Window:CreateTab({ Name = "Main", Icon = "" })
TabMain:SetBadge("API")

local TabMore = Window:CreateTab({ Name = "More", Icon = "" })
TabMore:ClearBadge()

---------------------------------------------------------------- Main / Elements
local SecElements = TabMain:AddSection("Elements")

SecElements:AddParagraph({
	Title = "Paragraph",
	Content = "Supports **bold** and\nline breaks.",
})

SecElements:AddButton({
	Title = "Notify high priority",
	Content = "MakeNotify Priority = high",
	Callback = function()
		FlurioreLib:MakeNotify({
			Title = "Alert",
			Description = "Priority",
			Content = "This toast prefers to stay when the queue is full.",
			Color = Color3.fromRGB(255, 120, 100),
			Priority = "high",
			Delay = 4,
		})
	end,
})

local ToggleA = SecElements:AddToggle({
	Title = "Mode A",
	Content = "Group = mode (radio)",
	Default = true,
	Group = "mode",
	Flag = "mode_a",
	Callback = function(v) end,
})

SecElements:AddToggle({
	Title = "Mode B",
	Content = "Same group",
	Group = "mode",
	Flag = "mode_b",
	Callback = function(v) end,
})

local ToggleLock = SecElements:AddToggle({
	Title = "Lock demo toggle",
	Content = "Try SetLocked on Mode A",
	Default = false,
	Callback = function(v)
		ToggleA:SetLocked(v)
	end,
})

SecElements:AddSlider({
	Title = "Power",
	Content = "0 – 10",
	Min = 0,
	Max = 10,
	Increment = 0.25,
	Default = 2,
	Flag = "power",
	Callback = function(v) end,
})

SecElements:AddInput({
	Title = "Username",
	Content = "Flag = username",
	Flag = "username",
	Callback = function(t) end,
})

SecElements:AddDropdown({
	Title = "Map",
	Content = "Search = true",
	Options = { "Forest", "Desert", "Snow", "Coast", "City" },
	Default = { "Forest" },
	Multi = false,
	Search = true,
	SearchPlaceholder = "Type map name...",
	Flag = "map",
	Callback = function(v) end,
})

SecElements:AddKeybind({
	Title = "Fly key",
	Content = "Click chip then press a key",
	Default = Enum.KeyCode.F,
	Flag = "fly_key",
	Callback = function(k) end,
})

SecElements:AddColorPicker({
	Title = "Accent color",
	Content = "Click row to open the picker",
	Default = Color3.fromRGB(140, 90, 255),
	Flag = "accent_color",
	Callback = function(c)
		Window:SetAccent(c)
	end,
})

SecElements:AddColorCycle({
	Title = "Glow color",
	Content = "Click to step hue (drives mobile toggle color)",
	Default = Color3.fromRGB(140, 90, 255),
	Flag = "glow_color",
	Callback = function(c)
		Window:SetMobileToggleColor(c)
	end,
})

---------------------------------------------------------------- Main / Window tools
local SecWindow = TabMain:AddSection("Window tools")

SecWindow:AddButton({
	Title = "ToggleUI smooth",
	Content = "Hide/show with tween",
	Callback = function()
		Window:ToggleUI(true)
	end,
})

SecWindow:AddButton({
	Title = "ToggleUI instant",
	Content = "No tween",
	Callback = function()
		Window:ToggleUI(false)
	end,
})

SecWindow:AddButton({
	Title = "SetSearch farm",
	Content = "Filter elements",
	Callback = function()
		Window:SetSearch("farm")
	end,
})

SecWindow:AddButton({
	Title = "ClearSearch",
	Content = "Show all",
	Callback = function()
		Window:ClearSearch()
	end,
})

SecWindow:AddButton({
	Title = "SaveConfig",
	Content = "FlurioreConfigs/demo",
	Callback = function()
		local ok, err = Window:SaveConfig("FlurioreConfigs", "demo")
		FlurioreLib:MakeNotify({
			Title = ok and "Saved" or "Save failed",
			Content = ok and "demo.json written" or tostring(err),
			Delay = 3,
		})
	end,
})

SecWindow:AddButton({
	Title = "LoadConfig",
	Content = "FlurioreConfigs/demo",
	Callback = function()
		local ok, err = Window:LoadConfig("FlurioreConfigs", "demo")
		FlurioreLib:MakeNotify({
			Title = ok and "Loaded" or "Load failed",
			Content = ok and "demo.json applied" or tostring(err),
			Delay = 3,
		})
	end,
})

SecWindow:AddButton({
	Title = "ListConfigs",
	Content = "Print folder entries",
	Callback = function()
		local names = Window:ListConfigs("FlurioreConfigs")
		print("configs:", table.concat(names, ", "))
	end,
})

SecWindow:AddButton({
	Title = "ExportConfig → ImportConfig",
	Content = "Round-trip JSON in memory",
	Callback = function()
		local json = Window:ExportConfig()
		Window:ImportConfig(json)
	end,
})

SecWindow:AddButton({
	Title = "Theme preset Rose",
	Content = "SetThemePreset",
	Callback = function()
		Window:SetThemePreset("Rose")
	end,
})

SecWindow:AddButton({
	Title = "SaveThemePreset MyDemo",
	Content = "From current theme",
	Callback = function()
		Window:SaveThemePreset("MyDemo")
	end,
})

SecWindow:AddButton({
	Title = "Local frost on",
	Content = "SetBlur(true) — panel only",
	Callback = function()
		Window:SetBlur(true)
	end,
})

SecWindow:AddButton({
	Title = "Local frost off",
	Content = "SetBlur(false)",
	Callback = function()
		Window:SetBlur(false)
	end,
})

SecWindow:AddButton({
	Title = "Real glass on",
	Content = "Experimental · lower opacity to see it",
	Callback = function()
		Window:SetRealGlass(true)
	end,
})

SecWindow:AddButton({
	Title = "Real glass off",
	Content = "SetRealGlass(false)",
	Callback = function()
		Window:SetRealGlass(false)
	end,
})

---------------------------------------------------------------- More / Section API
local SecMore = TabMore:AddSection("Section & virtual")

SecMore:AddParagraph({
	Title = "Virtual lists",
	Content = "Default **off**. Enable only for very long sections.",
})

SecMore:AddButton({
	Title = "Section:Close",
	Callback = function()
		SecMore:Close()
	end,
})

SecMore:AddButton({
	Title = "Section:Open",
	Callback = function()
		SecMore:Open()
	end,
})

SecMore:AddButton({
	Title = "EnableVirtual(12)",
	Content = "Optional performance path",
	Callback = function()
		SecMore:EnableVirtual(12)
	end,
})

SecMore:AddButton({
	Title = "DisableVirtual",
	Callback = function()
		SecMore:DisableVirtual()
	end,
})

for i = 1, 8 do
	SecMore:AddParagraph({
		Title = "Row " .. i,
		Content = "Sample row for virtual demo",
	})
end

local SecMisc = TabMore:AddSection("Misc")

SecMisc:AddButton({
	Title = "ClearNotifies",
	Callback = function()
		FlurioreLib:ClearNotifies()
	end,
})

SecMisc:AddButton({
	Title = "Unbind P",
	Callback = function()
		Window:UnbindKey("demo_print")
	end,
})

SecMisc:AddButton({
	Title = "DestroyGui",
	Content = "Same as header X",
	Callback = function()
		Window:DestroyGui()
	end,
})

-- v2 extras
Window:AddTopbarButton({
	Name = "Demo",
	Icon = "D",
	Callback = function()
		FlurioreLib:MakeNotify({ Title = "Topbar", Content = "Topbar button pressed", Delay = 2 })
	end,
})

local InfoLabel = SecElements:AddLabel({ Title = "Label: live text", Color = Color3.fromRGB(180, 160, 255) })
SecElements:AddDivider()
ToggleA:OnChanged(function(value)
	InfoLabel:Set("Mode A is " .. tostring(value))
end)

SecWindow:AddButton({
	Title = "Copy config string",
	Content = "ExportConfigString → clipboard",
	Callback = function()
		local str = Window:ExportConfigString()
		if str and setclipboard then
			setclipboard(str)
			FlurioreLib:MakeNotify({ Title = "Copied", Content = "Config string on clipboard", Delay = 3 })
		end
	end,
})

-- new elements (tier 1-2)
SecElements:AddSpace(8)
SecElements:AddCode({ Title = "Webhook example", Code = "https://discord.com/api/webhooks/your-id/your-token" })

local ExtraGroup = SecElements:AddGroup({ Columns = 2 })
ExtraGroup[1]:AddToggle({ Title = "Left", Flag = "left_toggle", Callback = function() end })
ExtraGroup[2]:AddToggle({ Title = "Right", Flag = "right_toggle", Callback = function() end })

SecElements:AddKeybind({
	Title = "Boost",
	Content = "Hold to boost",
	Default = Enum.KeyCode.LeftShift,
	Flag = "boost_key",
	Mode = "Hold",
	OnTrigger = function(active) print("boost", active) end,
})

SecElements:AddDropdown({
	Title = "Target",
	Options = {"Alpha", "Beta", "Gamma"},
	Searchable = true,
	Callback = function() end,
})

SecWindow:AddButton({
	Title = "Reset settings",
	Content = "Opens a popup",
	Callback = function()
		Window:Popup({
			Title = "Reset settings",
			Content = "This clears every saved value. Continue?",
			Buttons = {
				{ Title = "Cancel", Primary = false },
				{ Title = "Reset", Callback = function() print("reset") end },
			},
		})
	end,
})

-- tier 3 elements
SecElements:AddTextArea({ Title = "Notes", Content = "Multi-line text box", Placeholder = "Write something...", Height = 80, Callback = function() end })
SecElements:AddProgress({ Title = "Download", Default = 35, Max = 100, Color = Color3.fromRGB(120, 220, 160) })
local Console = SecElements:AddLog({ Title = "Console", Lines = 6 })
Console:Add("Script loaded", Color3.fromRGB(120, 220, 160))
local SubPages = SecElements:AddSubTabs({ "General", "Advanced" })
SubPages[1]:AddToggle({ Title = "General option", Callback = function() end })
SubPages[2]:AddSlider({ Title = "Advanced value", Min = 0, Max = 100, Default = 50, Callback = function() end })
SecElements:AddTag({ Title = "Status", Tags = {"Beta", {Text = "Stable", Color = Color3.fromRGB(120, 220, 160)}} })
SecElements:AddCard({ Title = "Discord", Content = "Join the community", ButtonLabel = "Join", Url = "https://discord.gg/your-invite" })
local previewModel = workspace:FindFirstChildWhichIsA("Model")
if previewModel then
	SecElements:AddViewport({ Model = previewModel, Height = 140 })
end

-- Discord widget (replace the invite with your own server)
SecElements:AddDiscord({ Invite = "https://discord.gg/your-invite", Refresh = 60 })

-- try load previous session if file exists
pcall(function()
	Window:LoadConfig("FlurioreConfigs", "demo")
end)

FlurioreLib:MakeNotify({
	Title = "Fluriore",
	Description = "Demo",
	Content = "RightShift toggles UI. Mobile button is top-left if enabled.",
	Delay = 5,
})
