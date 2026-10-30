# FlurioreLib

Roblox UI library for script hubs.

```text
https://raw.githubusercontent.com/MCUpload123/Fluriore-library/refs/heads/main/Flur.lua
```

```lua
local FlurioreLib = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/MCUpload123/Fluriore-library/refs/heads/main/Flur.lua"
))()
```

Review any loadstring source before running it.

---

## MakeGui

Creates the main window and returns a `Window` API table.

```lua
local Window = FlurioreLib:MakeGui({
  NameHub = "My Hub",
  Description = "Subtitle under the title",
  Color = Color3.fromRGB(255, 0, 255),

  TextScale = 0.85,   -- optional, 0.7–1.5, default 0.85
  UIScale = 0.9,      -- optional, 0.75–1.2, default 0.9

  -- optional initial size (does NOT affect maximize button behavior)
  Size = { X = 480, Y = 340 },
  -- or: Size = UDim2.new(0, 480, 0, 340)

  Blur = false,       -- local frost only (panel more transparent); NOT full-screen blur
  ThemePreset = "Midnight", -- "Dark" | "Midnight" | "Rose" | "Mint"

  BackgroundImage = "",                 -- optional rbxassetid://...
  BackgroundImageTransparency = 0.35,   -- 0 solid image … 1 invisible

  MobileToggle = false,
  -- or table:
  -- MobileToggle = { Size = 44, Corner = 10, Icon = "", Smooth = true, Position = UDim2.new(0, 14, 0, 14) }

  SafeArea = { Top = 0, Bottom = 0, Left = 0, Right = 0 },
})
```

**Header X button** still destroys/hides the whole GUI permanently for that session (existing Close behavior).  
**Mobile toggle** only shows/hides the window; it never replaces Close.

---

## Window API

### Visibility

| Method | Meaning |
|---|---|
| `Window:ToggleUI()` | Show/hide window. Uses smooth fade when mobile smooth is on. |
| `Window:ToggleUI(false)` | Force instant show/hide (no tween). |
| `Window:ToggleUI(true)` | Force smooth tween. |
| `Window:DestroyGui()` | Destroy the ScreenGui and release resources. |

Close (X) in the header is separate: it hides the window frame and is not wired to the mobile button.

### Title & description

```lua
Window:SetTitle("New name")
print(Window:GetTitle())

Window:SetDescription("New subtitle")
print(Window:GetDescription())
```

### Scale

```lua
Window:SetTextScale(0.9)   -- clamps 0.7–1.5
Window:GetTextScale()

Window:SetUIScale(1.0)     -- clamps 0.75–1.2
Window:GetUIScale()
```

### Theme

```lua
Window:SetTheme({
  Accent = Color3.fromRGB(80, 190, 255),
  Background = Color3.fromRGB(15, 18, 25),
  Surface = Color3.fromRGB(255, 255, 255),
  Text = Color3.fromRGB(245, 245, 245),
  MutedText = Color3.fromRGB(160, 170, 185),
  Border = Color3.fromRGB(65, 75, 90),
})

print(Window:GetTheme().Accent)

Window:SetAccent(Color3.fromRGB(120, 255, 160))

Window:SetThemePreset("Rose")
for _, name in ipairs(Window:GetThemePresets()) do
  print(name)
end
```

### Opacity & local frost (“blur”)

`SetOpacity` controls the solid panel transparency.  
`SetBlur(true)` only raises panel transparency further (frosted glass look). **It does not blur the entire game view.**

```lua
Window:SetOpacity(0.12)    -- 0 = solid, higher = more see-through (max ~0.95)
print(Window:GetOpacity())

Window:SetBlur(true)       -- enable local frost
Window:SetBlurAmount(0.5)  -- how strong the frost transparency is (0.2–0.9)
print(Window:GetBlur(), Window:GetBlurAmount())
```

Notify-only shared `Lighting` blur (optional, separate):

```lua
FlurioreLib:SetNotifyBlur(true)
FlurioreLib:SetBlurSize(16)  -- size for notify Lighting blur only
```

### Background image

```lua
Window:SetBackgroundImage("rbxassetid://123456789")
Window:SetBackgroundImageTransparency(0.4)
print(Window:GetBackgroundImage())

Window:SetBackgroundImage(false) -- clear
```

### Search (filters elements in the open tab list)

```lua
Window:SetSearch("farm")
Window:ClearSearch()
```

### Safe area

```lua
Window:SetSafeArea({ Top = 24, Bottom = 12, Left = 8, Right = 8 })
print(Window:GetSafeArea().Top)
```

### Keybinds (global)

```lua
Window:SetToggleKey(Enum.KeyCode.RightShift)
print(Window:GetToggleKey())

Window:BindKey("my_fly", Enum.KeyCode.F, function()
  print("fly")
end)
Window:UnbindKey("my_fly")
for id, key in pairs(Window:GetBinds()) do
  print(id, key)
end
```

### Mobile toggle (open API)

Independent from the header X button. Default: slightly rounded square, top-left, draggable.

```lua
-- simple
Window:SetMobileToggle(true)
Window:SetMobileToggle(false)

-- full config
Window:SetMobileToggle({
  Enabled = true,
  Size = 48,                 -- px
  Corner = 10,               -- 0 = square, higher = more round
  Icon = "rbxassetid://…",   -- empty = show + / − text
  Smooth = true,             -- fade window when toggling
  TweenTime = 0.22,
  Position = UDim2.new(0, 14, 0, 14),
})

Window:SetMobileToggleSmooth(false)
print(Window:GetMobileToggle()) -- whether the button exists
```

---

## Tabs

```lua
local Tab = Window:CreateTab({
  Name = "Main",
  Icon = "", -- optional image
})

Tab:SetBadge("3")
Tab:ClearBadge()
```

---

## Sections

```lua
local Section = Tab:AddSection("Combat")

Section:Open()
Section:Close()
print(Section:IsOpen())

-- long lists: only keep a window of rows visible while scrolling
Section:EnableVirtual(14)
Section:DisableVirtual()
```

---

## Elements

Every main element returns:

- `SetVisible(bool)` / `GetVisible()`
- `SetLocked(bool)` / `IsLocked()` — locked controls ignore clicks
- `Frame` — underlying GuiObject

### Paragraph

```lua
Section:AddParagraph({
  Title = "Notice",
  Content = "Supports **bold** and\nnew lines.",
})
```

### Button

```lua
Section:AddButton({
  Title = "Run",
  Content = "Short description",
  Icon = "rbxassetid://16932740082", -- optional
  Callback = function()
    print("pressed")
  end,
})
```

### Toggle

```lua
local Toggle = Section:AddToggle({
  Title = "Auto farm",
  Content = "Runs while enabled",
  Default = false,
  Flag = "auto_farm",
  Callback = function(value)
    print(value)
  end,
})

Toggle:Set(true)
```

Radio-style group (only one on):

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
  Content = "0 to 10",
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
  Content = "Press enter or unfocus",
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
  Content = "Choose a map",
  Options = { "Forest", "Desert", "Snow" },
  Default = { "Forest" },
  Multi = false,
  Search = true, -- search box inside the list
  Flag = "map",
  Callback = function(values)
    print(table.concat(values, ", "))
  end,
})

Dropdown:Filter("for")
Dropdown:Refresh({ "A", "B" }, { "A" })
Dropdown:Clear()
Dropdown:AddOption("Coast")
```

### Keybind

```lua
Section:AddKeybind({
  Title = "Fly",
  Content = "Click chip, then press a key",
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
  Content = "Click to cycle hue",
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

## Config

Attach `Flag` on Toggle, Slider, Input, Dropdown, Keybind, ColorPicker.

```lua
Window:SaveConfig("FlurioreConfigs", "main")
Window:LoadConfig("FlurioreConfigs", "main")

Window:ListConfigs("FlurioreConfigs")
Window:DeleteConfig("FlurioreConfigs", "main")
Window:RenameConfig("FlurioreConfigs", "main", "backup")

local json = Window:ExportConfig()
Window:ImportConfig(json)
```

### Auto-save

Default filters: **Toggle = false** (off until you enable it). Other kinds default true.

```lua
Window:EnableAutoSave("FlurioreConfigs", "main", {
  Toggle = false,      -- default
  Slider = true,
  Input = true,
  Dropdown = true,
  Keybind = true,
  ColorPicker = true,
  Theme = true,
  Scale = true,
})

Window:SetAutoSaveFilter("Toggle", true)  -- opt-in toggles later
print(Window:GetAutoSaveFilter().Toggle)

Window:DisableAutoSave()
```

Needs executor `writefile` / `readfile` (and ideally `makefolder`, `listfiles`, `delfile`).

---

## Notifications (library-level)

```lua
FlurioreLib:SetNotifyPosition("TopRight")
-- BottomRight | BottomLeft | TopRight | TopLeft

FlurioreLib:GetNotifyPosition()
FlurioreLib:SetNotifyMax(4)
FlurioreLib:GetNotifyMax()
FlurioreLib:ClearNotifies()

FlurioreLib:SetNotifyBlur(true)  -- optional Lighting blur for toasts only
FlurioreLib:GetNotifyBlur()
FlurioreLib:SetBlurSize(16)
FlurioreLib:GetBlurSize()

FlurioreLib:MakeNotify({
  Title = "Saved",
  Description = "Config",
  Content = "Profile written.",
  Color = Color3.fromRGB(80, 200, 120),
  Time = 0.35,
  Delay = 4,
  Priority = "high",  -- or "normal"
  Blur = true,        -- per-toast override for notify blur
})
```

High priority is kept longer when the queue is full; normal toasts are removed first.

---

## Notes

- Maximize / minimize are independent of the initial `Size` you pass to `MakeGui`.
- Window frost (`SetBlur`) is panel transparency only, not a full-screen post effect.
- Default text scale is `0.85`.


---

## Extra window styling APIs

### Layered opacity

```lua
Window:SetOpacity(0.12)

Window:SetOpacity({
  Main = 0.12,
  Top = 0.999,
  Section = 0.935,
})

local o = Window:GetOpacity()
print(o.Main, o.Top, o.Section)
```

### Corner radius

```lua
Window:SetCornerRadius(12)
print(Window:GetCornerRadius())
```

### Accent stroke transparency

```lua
Window:SetAccentTransparency(0.2)
print(Window:GetAccentTransparency())
```

### Frost animation

```lua
Window:SetBlurAnimate(true)  -- tween when SetBlur toggles
Window:SetBlur(true)
```

### Background image scale

```lua
Window:SetBackgroundScaleType("Crop") -- Crop | Fit | Stretch | Tile
print(Window:GetBackgroundScaleType())
```

### Custom theme preset

```lua
Window:SetTheme({ Accent = Color3.fromRGB(255, 120, 80), Background = Color3.fromRGB(12, 12, 16) })
Window:SaveThemePreset("MyOrange")
Window:SetThemePreset("MyOrange")
```

### Flag prefix (multi-window configs)

```lua
Window:SetFlagPrefix("hub1_")
-- Flag = "farm" is stored as "hub1_farm"
print(Window:GetFlagPrefix())
```

### Mobile toggle color

```lua
Window:SetMobileToggleColor(Color3.fromRGB(80, 160, 255))
```

### Safe area auto (touch)

```lua
Window:ApplySafeAreaAuto()
```

### Dropdown search placeholder

```lua
Section:AddDropdown({
  Title = "Map",
  Options = { "A", "B" },
  Search = true,
  SearchPlaceholder = "Type map name...",
  Callback = function() end,
})
```

---

## Auto-save: open control by flag name

Kinds still filter first (`Toggle` defaults **false**).  
On top of that you can allow only specific **flag names** the user chose on elements.

```lua
-- enable autosave; still keep Toggle kind off unless you set it true
Window:EnableAutoSave("FlurioreConfigs", "main", {
  Toggle = false,
  Slider = true,
  Input = true,
  Dropdown = true,
  Keybind = true,
  ColorPicker = true,
})

-- only these flags may auto-write (names = Flag strings you set on elements)
Window:SetAutoSaveFlags({ "power", "map", "username" })

-- or clear allow-list (all flags that pass kind filter)
Window:SetAutoSaveFlags(nil)

-- block one flag even if allowed
Window:DenyAutoSaveFlag("map")
Window:AllowAutoSaveFlag("map")
```

Manual save/load is unchanged:

```lua
Window:SaveConfig("FlurioreConfigs", "main")
Window:LoadConfig("FlurioreConfigs", "main")
```


---

## Window lifetime

- **Header Close (X)** calls `DestroyGui()` — the UI is removed completely, not only hidden.
- **Mobile toggle** only shows/hides; it never destroys.
- **Re-running the script** destroys any existing `HirimiGui` first, then creates a new one. You will not get two hubs stacked.

## Virtual sections (default off)

```lua
Section:EnableVirtual(14)  -- optional
Section:DisableVirtual()
```

Keep this **off** unless a section has a very large number of rows and scrolling feels heavy.
When enabled, only a window of rows stays `Visible` based on scroll position (estimated from each row’s `Size.Y`, not screen AbsolutePosition).
All rows still exist in the tree; layout height stays correct.
