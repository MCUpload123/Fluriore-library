# FlurioreLib

A Lua UI library for Roblox with animated notifications, a draggable/resizable window, tabs, collapsible sections, and common UI components.

> **Compatibility:** The GitHub loader example uses `game:HttpGet()` and `loadstring()`, which are not available in every Roblox execution environment. For a Roblox Studio experience, place `Flur.lua` in a `ModuleScript` and use `require()` from a `LocalScript` instead. Use this library only in experiences and environments where you have permission to run your code.

## Files

- `Flur.lua` — the library module; returns the `FlurioreLib` table.
- `LoaderExample.lua` — GitHub download loader and runnable showcase for the public API.

This package includes small fixes to the source so the documented methods work as expected: the returned window exposes `CreateTab`, `ToggleUI`, and `DestroyGui`; `Toggle:Set()` keeps `Toggle.Value` synchronized; Paragraph updates recalculate text height; Input uses the configured title and description; and `Dropdown:AddOption()` keeps its `Options` array updated.

## Quick start

```lua
local FlurioreLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MCUpload123/Fluriore-library/refs/heads/main/Flur.lua"
))()

local Window = FlurioreLib:MakeGui({
    NameHub = "My Hub",
    Description = "Made with FlurioreLib",
    Color = Color3.fromRGB(255, 0, 255),
})

local Tab = Window:CreateTab({Name = "Home", Icon = ""})
local Section = Tab:AddSection("General")

Section:AddButton({
    Title = "Say hello",
    Content = "Prints a message to the output.",
    Callback = function()
        print("Hello!")
    end,
})
```

## API reference

All names below match the current source. Configuration keys are case-sensitive.

### 1. Notifications

#### `FlurioreLib:MakeNotify(config)`
Creates a notification and returns a handle with `:Close()`.

| Config key | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"Hirimi Hub"` | Main title |
| `Description` | string | `"Notification"` | Short subtitle |
| `Content` | string | `"Content"` | Message body |
| `Color` | `Color3` | Magenta | Accent color |
| `Time` | number | `0.5` | Animation duration |
| `Delay` | number | `5` | Seconds before auto-close |

```lua
local Notice = FlurioreLib:MakeNotify({
    Title = "Saved",
    Description = "Settings",
    Content = "Your settings were saved.",
    Color = Color3.fromRGB(80, 200, 120),
    Time = 0.4,
    Delay = 4,
})

-- Close it early:
Notice:Close()
```

`Notice:Close()` begins the closing animation and removes the notification. It is safe against repeated close calls in the current implementation.

### 2. Window

#### `FlurioreLib:MakeGui(config)`
Creates the main window and returns a window handle.

| Config key | Type | Default | Description |
|---|---|---|---|
| `NameHub` | string | `"Hirimi Hub"` | Window title |
| `Description` | string | `"Comeback \| developing by Hirimi, Teru"` | Subtitle |
| `Color` | `Color3` | Magenta | Accent color |
| `Logo Player` | string | Current player's Roblox headshot URL | Player avatar image |
| `Name Player` | string | Current player's name | Display name |
| `Tab Width` | number | `120` | Width of the tab sidebar |

Returned window methods:

- `Window:ToggleUI()` — toggles the window's visibility.
- `Window:DestroyGui()` — removes this window's ScreenGui.
- `Window:CreateTab(config)` — creates a tab and returns a tab handle.

### 3. Tabs and sections

#### `Window:CreateTab(config)`

| Config key | Type | Default | Description |
|---|---|---|---|
| `Name` | string | `"Tab"` | Tab label |
| `Icon` | string | `""` | Image URL or Roblox asset string |

Returns a tab handle containing:

- `Tab:AddSection(title)` — creates a collapsible section and returns an item handle.

Example:

```lua
local Tab = Window:CreateTab({Name = "Settings", Icon = ""})
local Section = Tab:AddSection("General settings")
```

### 4. Components

All component methods are called on the section handle returned by `Tab:AddSection(...)`.

#### `Section:AddParagraph(config)`
Displays informational text. Returns a paragraph handle.

| Config key | Type | Default |
|---|---|---|
| `Title` | string | `"Title"` |
| `Content` | string | `"Content"` |

Paragraph methods:

- `Paragraph:Set({Title = "New title", Content = "New text"})` — updates its title and content.

#### `Section:AddButton(config)`
Displays a clickable button. Returns an empty handle; use `Callback` for its action.

| Config key | Type | Default |
|---|---|---|
| `Title` | string | `"Title"` |
| `Content` | string | `"Content"` |
| `Icon` | string | `"rbxassetid://16932740082"` |
| `Callback` | function | Empty function | 

`Callback` is called without arguments when the user activates the button.

#### `Section:AddToggle(config)`
Displays an on/off toggle. Returns a toggle handle with `Value` and `:Set(value)`.

| Config key | Type | Default |
|---|---|---|
| `Title` | string | `"Title"` |
| `Content` | string | `"Content"` |
| `Default` | boolean | `false` |
| `Callback` | function | Empty function |

`Callback(value)` receives a boolean. `Toggle:Set(true)` updates the visual state, updates `Toggle.Value`, and calls the callback.

#### `Section:AddSlider(config)`
Displays a numeric slider and text entry. Returns a slider handle with `Value` and `:Set(value)`.

| Config key | Type | Default |
|---|---|---|
| `Title` | string | `"Slider"` |
| `Content` | string | `"Content"` |
| `Min` | number | `0` |
| `Max` | number | `100` |
| `Default` | number | `50` |
| `Increment` | number | `1` |
| `Callback` | function | Empty function |

The slider clamps values to `Min`–`Max` and rounds to `Increment`. `Callback(value)` is called when the user finishes dragging the slider; calling `Slider:Set(value)` changes the stored/displayed value but does not call the callback in the current implementation. Set `Min` lower than `Max` and use a positive `Increment`.

#### `Section:AddInput(config)`
Displays a text input. Returns an input handle with `Value` and `:Set(value)`.

| Config key | Type | Default |
|---|---|---|
| `Title` | string | `"Title"` |
| `Content` | string | `"Content"` |
| `Callback` | function | Empty function |

`Callback(value)` receives a string when the field loses focus or `Input:Set(value)` is called.

#### `Section:AddDropdown(config)`
Displays a dropdown. Returns a dropdown handle with `Value`, `Options`, and methods below.

| Config key | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"Title"` | Component title |
| `Content` | string | `"Content"` | Description |
| `Multi` | boolean | `false` | Allow more than one selection |
| `Options` | array of strings | `{}` | Initial options |
| `Default` | array of strings | `{}` | Initial selected option(s) |
| `Callback` | function | Empty function | Called with the selected-value array |

Dropdown methods:

- `Dropdown:Set(values)` — selects the values in an array and calls the callback.
- `Dropdown:Clear()` — removes all options and clears the selection.
- `Dropdown:AddOption(name)` — adds an option to the UI and the `Options` array.
- `Dropdown:Refresh(options, selectedValues)` — replaces the option list and applies the selected values; both arguments are optional arrays.

Even with `Multi = false`, the callback receives an array, for example `{"Banana"}`, rather than a plain string.

### 5. Full component example

See `LoaderExample.lua` for a complete example that demonstrates:

- `MakeNotify()` and notification `:Close()`
- `MakeGui()`, `:ToggleUI()`, and `:DestroyGui()`
- `:CreateTab()` and `:AddSection()`
- `:AddParagraph()` and `:Set()`
- `:AddButton()` and `Callback`
- `:AddToggle()` and `:Set()`
- `:AddSlider()` and `:Set()`
- `:AddInput()` and `:Set()`
- `:AddDropdown()`, `:Set()`, `:Clear()`, `:AddOption()`, and `:Refresh()`

## Notes and limitations

- The GUI is parented to the local player's `PlayerGui`; `CoreGui` is only the name of a local variable in the source.
- `RightShift` toggles the window in addition to `Window:ToggleUI()`.
- The slider's text input currently accepts digits only, so it is not suitable for negative or decimal values without further changes.
- This library creates client-side UI; it does not grant server permissions or make server-side game changes.
