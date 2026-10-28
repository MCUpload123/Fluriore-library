# FlurioreLib

FlurioreLib is a compact Roblox Lua UI library with a draggable/resizable window, tabs, collapsible sections, notifications, and common UI components. This version includes mobile-friendly slider dragging, editable slider values, responsive text sizing, a smoother minimize animation, in-window search, a code-driven theme API, keybind helpers, and a file-based config system.

## Documentation website

Documentation site: https://mcupload123.github.io/Fluriore-library/

The GitHub Pages homepage is `index.html` at the repository root. The editable documentation source is also kept at `docs/docs-index.html`.

## Executor compatibility

This library is intended for Roblox script-executor environments such as **Delta** and other executors that allow `game:HttpGet()` and `loadstring()`. Executor APIs and compatibility can change between versions, so support is not guaranteed for every executor or configuration. Use scripts only in experiences and environments where you have permission to run them.

### Load from the published GitHub file

The raw source URL for this repository is:

```text
https://raw.githubusercontent.com/MCUpload123/Fluriore-library/refs/heads/main/Flur.lua
```

Example loader:

```lua
local LibraryURL = "https://raw.githubusercontent.com/MCUpload123/Fluriore-library/refs/heads/main/Flur.lua"

local ok, source = pcall(function()
    return game:HttpGet(LibraryURL)
end)
assert(ok, "FlurioreLib download failed: " .. tostring(source))

local chunk, compileError = loadstring(source)
assert(type(chunk) == "function", "FlurioreLib compile failed: " .. tostring(compileError))

local success, FlurioreLib = pcall(chunk)
assert(success, "FlurioreLib initialization failed: " .. tostring(FlurioreLib))
```

`FlurioreLib` is the library table returned by `Flur.lua`. Keep the URL pointed at a trusted source: `loadstring` executes the downloaded Lua code, so review source changes before running them.

## Quick start

```lua
local LibraryURL = "https://raw.githubusercontent.com/MCUpload123/Fluriore-library/refs/heads/main/Flur.lua"
local FlurioreLib = loadstring(game:HttpGet(LibraryURL))()

local Window = FlurioreLib:MakeGui({
    NameHub = "My Hub",
    Description = "Made with FlurioreLib",
    Color = Color3.fromRGB(255, 0, 255),
    UIScale = 0.9,
    TextScale = 0.85, -- default is 0.85 (~15% smaller than original base)
})

local Tab = Window:CreateTab({Name = "Home", Icon = ""})
local Section = Tab:AddSection("General")

Section:AddParagraph({
    Title = "Welcome",
    Content = "This description automatically adjusts to its available width.",
})

Section:AddButton({
    Title = "Say hello",
    Content = "Prints a message when pressed.",
    Callback = function()
        print("Hello!")
    end,
})
```

## Window configuration

`FlurioreLib:MakeGui(config)` accepts these keys:

| Key | Type | Default | Description |
|---|---|---|---|
| `NameHub` | string | `"Hirimi Hub"` | Window title |
| `Description` | string | `"Comeback | developing by Hirimi, Teru"` | Header subtitle |
| `Color` | `Color3` | Magenta | Accent color (also used as Theme.Accent when Theme is omitted) |
| `Logo Player` | string | Current player's headshot URL | Avatar image |
| `Name Player` | string | Current player's name | Name shown at the lower left |
| `Tab Width` | number | `120` | Sidebar width |
| `UIScale` | number | `0.9` | Initial UI scale; clamped to `0.75–1.2` |
| `TextScale` | number | `0.85` | Initial text scale; clamped to `0.7–1.5` |
| `Theme` | table | Built-in palette | Optional color palette (see Theme support) |

There is no settings gear in the header. Text size, UI size, and theme are controlled only through the window API so script authors decide how (or whether) to expose those controls to end users.

The minimize control collapses the window to its header: content is hidden first, then height is tweened. Expanding reverses that order. `RightShift` toggles window visibility by default; change it with `Window:SetToggleKey`. `Window:ToggleUI()` also toggles visibility; `Window:DestroyGui()` removes the UI.

A search box sits under the active tab title. Typing filters elements by title and content. You can also drive the same filter from code with `Window:SetSearch` / `Window:ClearSearch`.

## Theme support

Themes are fully code-driven. There is no built-in theme picker UI; hub authors can build their own list or color controls and call the API below.

Available theme color keys:

| Key | Purpose |
|---|---|
| `Accent` | Highlight color and active controls |
| `Background` | Main background |
| `Surface` | Component surfaces |
| `Text` | Primary text |
| `MutedText` | Description / secondary text |
| `Border` | UI outlines |

Set a theme when creating the window:

```lua
local Window = FlurioreLib:MakeGui({
    NameHub = "Custom UI",
    Color = Color3.fromRGB(255, 80, 170),
    Theme = {
        Accent = Color3.fromRGB(255, 80, 170),
        Background = Color3.fromRGB(18, 20, 28),
        Surface = Color3.fromRGB(42, 45, 58),
        Text = Color3.fromRGB(245, 245, 250),
        MutedText = Color3.fromRGB(165, 170, 185),
        Border = Color3.fromRGB(70, 75, 95),
    },
})
```

Change colors later. Only keys present in the table are updated; every value must be a Roblox `Color3`:

```lua
-- Full palette update
Window:SetTheme({
    Accent = Color3.fromRGB(80, 190, 255),
    Background = Color3.fromRGB(15, 18, 25),
    Surface = Color3.fromRGB(35, 40, 50),
    Text = Color3.fromRGB(245, 245, 245),
    MutedText = Color3.fromRGB(160, 170, 185),
    Border = Color3.fromRGB(65, 75, 90),
})

-- Accent only (shortcut)
Window:SetAccent(Color3.fromRGB(120, 255, 160))

-- Read current palette (returns a table of Color3 values)
local current = Window:GetTheme()
print(current.Accent)
```

## Scale API

```lua
Window:SetTextScale(0.9)  -- 0.7 to 1.5; returns true when accepted
Window:SetUIScale(1.0)    -- 0.75 to 1.2; returns true when accepted
print(Window:GetTextScale())
print(Window:GetUIScale())
```

Default text scale is `0.85` so body text starts slightly smaller than the original library baseline.

## Search API

```lua
Window:SetSearch("speed") -- shows only elements whose title or content contains "speed" (case-insensitive)
Window:ClearSearch()      -- shows everything again
```

The in-window search box calls the same path as `SetSearch`.

## Keybind API

```lua
-- Change the key that shows/hides the whole window (default RightShift)
Window:SetToggleKey(Enum.KeyCode.LeftControl)
print(Window:GetToggleKey())

-- Named binds: id is a string you choose, callback runs on key down
Window:BindKey("fly", Enum.KeyCode.F, function()
    print("fly toggled from keybind")
end)

Window:UnbindKey("fly")

-- Map of id -> KeyCode currently registered
local binds = Window:GetBinds()
```

Binds fire only when the input is not processed by another GUI text box. They do not block the toggle key.

## Config API (save / load)

Elements can opt into persistence with a `Flag` string. Supported on **Toggle**, **Slider**, **Input**, and **Dropdown**.

```lua
local Toggle = Section:AddToggle({
    Title = "Auto farm",
    Content = "Runs the farm loop.",
    Default = false,
    Flag = "auto_farm", -- included in SaveConfig / ExportConfig
    Callback = function(on)
        print("auto_farm", on)
    end,
})
```

Window-level config methods:

```lua
-- Writes folder/name.json via executor writefile (creates folder when makefolder exists)
-- Saves TextScale, UIScale, Theme, and all registered Flags
local ok, pathOrErr = Window:SaveConfig("FlurioreConfigs", "main")
if not ok then
    warn(pathOrErr)
end

-- Reads the same file via readfile and applies values
local ok2, pathOrErr2 = Window:LoadConfig("FlurioreConfigs", "main")

-- In-memory helpers (no disk)
local flags = Window:GetFlags()           -- { flagName = value, ... }
Window:SetFlags({ auto_farm = true })

local json = Window:ExportConfig()        -- JSON string, or nil + error
Window:ImportConfig(json)                 -- apply a previously exported string
```

`SaveConfig` / `LoadConfig` require executor filesystem APIs (`writefile` / `readfile`). When those are missing, the methods return `false` and an error string instead of throwing. Theme colors are stored as RGB component tables so JSON stays portable.

You can also register custom flags manually:

```lua
Window:RegisterFlag("custom_stat", function()
    return myStat
end, function(value)
    myStat = value
end)
```

## Window methods

| Method | Description |
|---|---|
| `Window:CreateTab({Name, Icon})` | Creates a tab and returns a tab handle |
| `Window:ToggleUI()` | Shows/hides the window; returns its new visibility state |
| `Window:DestroyGui()` | Destroys this library window |
| `Window:SetTextScale(number)` | Sets text scale from `0.7` to `1.5`; returns `true` when accepted |
| `Window:GetTextScale()` | Returns the current text scale |
| `Window:SetUIScale(number)` | Sets UI scale from `0.75` to `1.2`; returns `true` when accepted |
| `Window:GetUIScale()` | Returns the current UI scale |
| `Window:SetTheme(themeTable)` | Applies theme colors; returns `true` for a table argument |
| `Window:GetTheme()` | Returns a copy of the current theme colors |
| `Window:SetAccent(Color3)` | Updates only the Accent color |
| `Window:SetSearch(string)` | Filters elements by title/content |
| `Window:ClearSearch()` | Clears the search filter |
| `Window:SetToggleKey(KeyCode)` | Sets the show/hide key for the window |
| `Window:GetToggleKey()` | Returns the current toggle KeyCode |
| `Window:BindKey(id, KeyCode, callback)` | Registers a named keybind |
| `Window:UnbindKey(id)` | Removes a named keybind |
| `Window:GetBinds()` | Returns `{ [id] = KeyCode }` |
| `Window:RegisterFlag(flag, getFn, setFn)` | Registers a custom flag |
| `Window:GetFlags()` | Returns all flag values |
| `Window:SetFlags(table)` | Applies flag values |
| `Window:SaveConfig(folder, name)` | Writes config JSON to disk |
| `Window:LoadConfig(folder, name)` | Loads config JSON from disk |
| `Window:ExportConfig()` | Returns config as a JSON string |
| `Window:ImportConfig(json)` | Applies config from a JSON string |

`Tab:AddSection(title)` creates a collapsible section. Closing a section hides its children first, then shrinks height; opening expands height then shows children again.

## Components

### Paragraph

```lua
local Info = Section:AddParagraph({
    Title = "Status",
    Content = "Initial status text.",
})

Info:Set({
    Title = "Updated status",
    Content = "The description height is recalculated when the text changes.",
})
```

### Button

```lua
Section:AddButton({
    Title = "Run",
    Content = "Runs a callback.",
    Icon = "rbxassetid://16932740082", -- optional
    Callback = function()
        print("Button pressed")
    end,
})
```

### Toggle

```lua
local Toggle = Section:AddToggle({
    Title = "Enabled",
    Content = "Turn a feature on or off.",
    Default = false,
    Flag = "feature_enabled", -- optional, for config save/load
    Callback = function(enabled)
        print("Enabled:", enabled)
    end,
})

Toggle:Set(true) -- updates the control and calls Callback
print(Toggle.Value)
```

### Slider

```lua
local Slider = Section:AddSlider({
    Title = "Power",
    Content = "Drag the bar or tap the pink value field to type a number.",
    Min = 0,
    Max = 10,
    Default = 2.5,
    Increment = 0.25,
    Flag = "power", -- optional
    Callback = function(value)
        print("Power:", value)
    end,
})

Slider:Set(4.75)
print(Slider.Value)
```

Slider dragging supports mouse and touch input. The pink value field is editable. `Increment` controls rounding and precision: use `Increment = 1` for whole numbers, `0.1` for tenths, or `0.25` for quarter steps. The value is rounded to the nearest increment and clamped to `Min`/`Max`; the minimum and maximum endpoints remain selectable even when the range is not an exact multiple of `Increment`.

### Input

```lua
local TextInput = Section:AddInput({
    Title = "Player name",
    Content = "Enter a name.",
    Flag = "player_name", -- optional
    Callback = function(value)
        print("Input:", value)
    end,
})

TextInput:Set("Example")
print(TextInput.Value)
```

### Dropdown

```lua
local Dropdown = Section:AddDropdown({
    Title = "Target",
    Content = "Choose an option.",
    Multi = false,
    Options = {"Alpha", "Bravo", "Charlie"},
    Default = "Alpha",
    Flag = "target", -- optional
    Callback = function(values)
        print(table.concat(values, ", "))
    end,
})

Dropdown:Set("Bravo")
Dropdown:AddOption("Delta")
Dropdown:Refresh({"One", "Two", "Three"}, "Two")
-- Dropdown:Clear() removes the available options and selection.
```

A dropdown's `Value` is a table of selected option strings, including when `Multi = false`. `Options` stores the available option strings.

## Notifications

```lua
local Notice = FlurioreLib:MakeNotify({
    Title = "Saved",
    Description = "Settings",
    Content = "Your settings were saved.",
    Color = Color3.fromRGB(80, 200, 120),
    Time = 0.5,
    Delay = 4,
})
```

`Time` controls the animation duration, and `Delay` is the auto-close delay in seconds. The notification also has a close button.

## Notes

- UI descriptions use text measurement to wrap to their available width instead of relying on `TextBounds / AbsoluteSize`, which may be zero during initial creation.
- Slider numeric input precision comes from `Increment`, `Min`, and `Max`.
- Section and window minimize animations hide content before changing height to avoid clipped or jumping layouts.
- Config disk APIs depend on the executor exposing `writefile` / `readfile` (and ideally `makefolder` / `isfolder`).
- Executor behavior can vary by version and settings. This source has not been runtime-tested in every executor.
- Review downloaded source before execution because a raw GitHub loader runs the code it downloads.

## Notify API (global)

```lua
FlurioreLib:SetNotifyPosition("TopRight") -- BottomRight | BottomLeft | TopRight | TopLeft
FlurioreLib:GetNotifyPosition()
FlurioreLib:SetNotifyMax(4)              -- drop oldest when full
FlurioreLib:GetNotifyMax()
FlurioreLib:ClearNotifies()
```

Each notify slides in with fade, shows a progress bar for auto-dismiss, and restacks when one closes.

## Opacity

```lua
Window:SetOpacity(0.2) -- 0 = solid, higher = more transparent (clamped 0–0.95)
print(Window:GetOpacity())
```

## Tab badge

```lua
local Tab = Window:CreateTab({Name = "Combat", Icon = ""})
Tab:SetBadge("3")
Tab:ClearBadge()
```

## Section open / close

```lua
local Section = Tab:AddSection("Farm")
Section:Close()
Section:Open()
print(Section:IsOpen())
```

## Color picker

```lua
local Picker = Section:AddColorPicker({
    Title = "Accent",
    Content = "Cycles hue on click (script authors can replace with a full HSV panel).",
    Default = Color3.fromRGB(255, 0, 255),
    Flag = "accent_color",
    Callback = function(color)
        Window:SetAccent(color)
    end,
})
Picker:Set(Color3.fromRGB(80, 200, 255))
```

## Config list helpers

```lua
local names = Window:ListConfigs("FlurioreConfigs") -- needs listfiles
Window:DeleteConfig("FlurioreConfigs", "main")     -- needs delfile
Window:RenameConfig("FlurioreConfigs", "main", "backup")
```
