# FlurioreLib

UI library for Roblox script hubs: window, tabs, sections, elements, theme, config, search, keybinds, blur, and mobile toggle.

**Source**

```text
https://raw.githubusercontent.com/MCUpload123/Fluriore-library/refs/heads/main/Flur.lua
```

---

## Installation

```lua
local FlurioreLib = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/MCUpload123/Fluriore-library/refs/heads/main/Flur.lua"
))()
```

Review any `loadstring` source before you run it.

---

## Create a window

```lua
local Window = FlurioreLib:MakeGui({
  NameHub = "My Hub",
  Description = "Built with FlurioreLib",
  Color = Color3.fromRGB(255, 0, 255),

  -- optional
  TextScale = 0.85,          -- 0.7 – 1.5
  UIScale = 0.9,             -- 0.75 – 1.2
  Blur = false,              -- shared Lighting blur (default off)
  BlurSize = 14,             -- 0 – 56
  ThemePreset = "Midnight",  -- Dark | Midnight | Rose | Mint
  MobileToggle = false,      -- floating open/close button (auto on touch)
  SafeArea = { Top = 0, Bottom = 0, Left = 0, Right = 0 },
})
```

### Window controls

| Method | Description |
|---|---|
| `Window:ToggleUI()` | Show / hide the whole window |
| `Window:DestroyGui()` | Destroy the ScreenGui (releases blur ref) |
| `Window:SetTitle(text)` / `GetTitle()` | Change hub title at runtime |
| `Window:SetDescription(text)` / `GetDescription()` | Change subtitle |
| `Window:SetToggleKey(Enum.KeyCode.RightShift)` | Hotkey to toggle UI |
| `Window:SetOpacity(0.15)` / `GetOpacity()` | Main panel transparency |
| `Window:SetBlur(true)` / `GetBlur()` | Enable frosted background (raises transparency) |
| `Window:SetBlurSize(18)` / `GetBlurSize()` | Blur radius shared with notifies |
| `Window:SetTheme({...})` / `GetTheme()` | Accent, Background, Surface, Text, MutedText, Border |
| `Window:SetAccent(color)` | Shortcut for accent only |
| `Window:SetThemePreset("Rose")` | Apply named preset |
| `Window:GetThemePresets()` | List preset names |
| `Window:SetTextScale(0.9)` / `SetUIScale(1)` | Typography / overall scale |
| `Window:SetSearch("farm")` / `ClearSearch()` | Filter elements by title/content |
| `Window:SetSafeArea({ Top = 20, Left = 8 })` | Avoid notches / home bar |
| `Window:SetMobileToggle(true)` | Floating **+ / −** button |
| `Window:BindKey(id, key, fn)` / `UnbindKey` / `GetBinds()` | Global key callbacks |

Minimize hides content first, then shrinks height. Maximize while minimized un-minimizes and goes fullscreen. Content is shown only after the size tween finishes.

---

## Tabs & sections

```lua
local Tab = Window:CreateTab({
  Name = "Main",
  Icon = "", -- optional image id
})

Tab:SetBadge("3")
Tab:ClearBadge()

local Section = Tab:AddSection("Combat")
Section:Open()
Section:Close()
print(Section:IsOpen())

-- optional: only keep a window of items visible while scrolling (long lists)
Section:EnableVirtual(14)
Section:DisableVirtual()
```

---

## Elements

Every main element returns an API table with:

- `SetVisible(bool)` / `GetVisible()`
- `SetLocked(bool)` / `IsLocked()`
- `Frame` — underlying GuiObject

### Paragraph

Supports light markup: `**bold**` and line breaks (`\n`).

```lua
Section:AddParagraph({
  Title = "Notice",
  Content = "Use **bold** for emphasis.\nSecond line here.",
})
```

### Button

```lua
Section:AddButton({
  Title = "Run",
  Content = "Fires once when pressed",
  Callback = function()
    print("clicked")
  end,
})
```

### Toggle

```lua
local Toggle = Section:AddToggle({
  Title = "Auto farm",
  Content = "Farms while enabled",
  Default = false,
  Flag = "auto_farm",
  Callback = function(value)
    print("farm", value)
  end,
})

Toggle:Set(true)
```

**Radio-style groups** — same `Group` string; turning one on turns the others off:

```lua
Section:AddToggle({
  Title = "Mode A",
  Group = "mode",
  Default = true,
  Callback = function(v) end,
})

Section:AddToggle({
  Title = "Mode B",
  Group = "mode",
  Callback = function(v) end,
})
```

### Slider

```lua
Section:AddSlider({
  Title = "Power",
  Content = "0 – 10",
  Min = 0,
  Max = 10,
  Increment = 0.25,
  Default = 2,
  Flag = "power",
  Callback = function(value)
    print(value)
  end,
})
```

### Input

```lua
Section:AddInput({
  Title = "Username",
  Content = "Type then press enter / unfocus",
  Flag = "username",
  Callback = function(text)
    print(text)
  end,
})
```

### Dropdown

```lua
local Dropdown = Section:AddDropdown({
  Title = "Map",
  Content = "Pick one or multi",
  Options = { "Forest", "Desert", "Snow" },
  Default = { "Forest" },
  Multi = false,
  Search = true, -- in-list search box
  Flag = "map",
  Callback = function(values)
    print(table.concat(values, ", "))
  end,
})

Dropdown:Filter("for") -- programmatic filter
Dropdown:Refresh({ "A", "B" }, { "A" })
```

### Keybind

```lua
Section:AddKeybind({
  Title = "Fly",
  Content = "Click the chip, then press a key",
  Default = Enum.KeyCode.F,
  Flag = "fly_key",
  Callback = function(keyCode)
    print(keyCode.Name)
  end,
})
```

### Color picker

```lua
local Picker = Section:AddColorPicker({
  Title = "Accent",
  Content = "Click swatch to cycle hue",
  Default = Color3.fromRGB(255, 0, 255),
  Flag = "accent_color",
  Callback = function(color)
    Window:SetAccent(color)
  end,
})

Picker:Set(Color3.fromRGB(80, 200, 255))
Picker:SetHSV(0.55, 0.85, 1)
```

---

## Config persistence

Attach a `Flag` string to Toggle, Slider, Input, Dropdown, Keybind, or ColorPicker.

```lua
-- write / read JSON under executor filesystem
Window:SaveConfig("FlurioreConfigs", "main")
Window:LoadConfig("FlurioreConfigs", "main")

Window:ListConfigs("FlurioreConfigs")
Window:DeleteConfig("FlurioreConfigs", "main")
Window:RenameConfig("FlurioreConfigs", "main", "backup")

local json = Window:ExportConfig()
Window:ImportConfig(json)

-- debounce ~0.65s after flag changes (Load/SetFlags also counts)
Window:EnableAutoSave("FlurioreConfigs", "main")
Window:DisableAutoSave()
```

Requires `writefile` / `readfile` (and ideally `makefolder`, `listfiles`, `delfile`).

---

## Notifications

```lua
FlurioreLib:SetNotifyPosition("TopRight")
-- BottomRight | BottomLeft | TopRight | TopLeft

FlurioreLib:SetNotifyMax(4)
FlurioreLib:ClearNotifies()
FlurioreLib:SetNotifyBlur(true) -- softer glass + shared blur

FlurioreLib:MakeNotify({
  Title = "Saved",
  Description = "Config",
  Content = "Profile written.",
  Color = Color3.fromRGB(80, 200, 120),
  Time = 0.35,          -- slide duration
  Delay = 4,            -- auto close
  Priority = "high",    -- high stays when queue is full; normal is dropped first
  Blur = true,          -- optional per-notify override
})
```

Each toast slides in with fade, shows a progress bar for auto-dismiss, and restacks when one closes.

---

## Example skeleton

```lua
local FlurioreLib = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/MCUpload123/Fluriore-library/refs/heads/main/Flur.lua"
))()

local Window = FlurioreLib:MakeGui({
  NameHub = "Demo",
  Description = "FlurioreLib",
  ThemePreset = "Midnight",
})

Window:EnableAutoSave("FlurioreConfigs", "demo")

local Tab = Window:CreateTab({ Name = "Main", Icon = "" })
local Section = Tab:AddSection("General")

Section:AddToggle({
  Title = "Enabled",
  Default = false,
  Flag = "enabled",
  Callback = function(v) end,
})

Section:AddSlider({
  Title = "Speed",
  Min = 1,
  Max = 20,
  Default = 8,
  Flag = "speed",
  Callback = function(v) end,
})

Section:AddDropdown({
  Title = "Map",
  Options = { "Forest", "Desert", "Snow" },
  Search = true,
  Flag = "map",
  Callback = function(v) end,
})

Section:AddKeybind({
  Title = "Fly",
  Default = Enum.KeyCode.F,
  Flag = "fly_key",
  Callback = function(k) end,
})
```

---

## Docs site

Static page for GitHub Pages lives under `docs/index.html` (optional). Future expansion can mirror this README.

---

## Notes

- Default text scale is `0.85`.
- Blur uses a shared `BlurEffect` in `Lighting`; only transparent panels show it clearly.
- Virtual sections hide off-window items while scrolling; disable when every row must stay interactive at once.
