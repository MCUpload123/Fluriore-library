# FlurioreLib

FlurioreLib is a compact Roblox Lua UI library with a draggable/resizable window, tabs, collapsible sections, notifications, and common UI components. This version includes mobile-friendly slider dragging, editable slider values, responsive text sizing, a smooth minimize animation, display settings, and a code-driven theme API.

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
    TextScale = 1,
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
| `Color` | `Color3` | Magenta | Accent color |
| `Logo Player` | string | Current player's headshot URL | Avatar image |
| `Name Player` | string | Current player's name | Name shown at the lower left |
| `Tab Width` | number | `120` | Sidebar width |
| `UIScale` | number | `0.9` | Initial UI scale; clamped to `0.75–1.2` |
| `TextScale` | number | `1` | Initial text scale; clamped to `0.7–1.5` |
| `Theme` | table | Built-in palette | Optional color palette, shown below |

The gear icon beside the minimize control opens **Display settings**. The panel lets users adjust text size and overall UI size, or reset them to defaults. It deliberately does not contain a theme picker.

The minimize control smoothly collapses the window to its header; pressing it again restores the content. `RightShift` toggles window visibility. `Window:ToggleUI()` also toggles visibility; `Window:DestroyGui()` removes the UI.

## Theme support

The library supports custom themes through configuration and code. It does not create a theme editor or theme-selection list, so you can build your own theme interface.

Available theme color keys:

| Key | Purpose |
|---|---|
| `Accent` | Highlight color and active controls |
| `Background` | Main/settings background |
| `Surface` | Component surfaces |
| `Text` | Primary text |
| `MutedText` | Description/secondary text |
| `Border` | UI outlines |

Example at creation time:

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

Change it later:

```lua
Window:SetTheme({
    Accent = Color3.fromRGB(80, 190, 255),
    Background = Color3.fromRGB(15, 18, 25),
    Surface = Color3.fromRGB(35, 40, 50),
    Text = Color3.fromRGB(245, 245, 245),
    MutedText = Color3.fromRGB(160, 170, 185),
    Border = Color3.fromRGB(65, 75, 90),
})
```

Only color keys included in the table are changed. All values must be Roblox `Color3` values.

## Window methods

| Method | Description |
|---|---|
| `Window:CreateTab({Name, Icon})` | Creates a tab and returns a tab handle |
| `Window:ToggleUI()` | Shows/hides the window; returns its new visibility state |
| `Window:DestroyGui()` | Destroys this library window |
| `Window:SetTextScale(number)` | Sets text scale from `0.7` to `1.5`; returns `true` when accepted |
| `Window:SetUIScale(number)` | Sets UI scale from `0.75` to `1.2`; returns `true` when accepted |
| `Window:SetTheme(themeTable)` | Applies theme colors; returns `true` for a table argument |

`Tab:AddSection(title)` creates a collapsible section and returns the component handle used below.

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
- Executor behavior can vary by version and settings. This source has not been runtime-tested in every executor.
- Review downloaded source before execution because a raw GitHub loader runs the code it downloads.
