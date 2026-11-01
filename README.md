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
  RealGlass = false,  -- experimental glass + DepthOfField behind the window (see "Real glass")
  RealGlassIntensity = 1,   -- 0–1, blur strength near the camera (default 1)
  Intro = true,             -- rise-and-fade when the window is built (false = skip)
  KeySystem = false,        -- true = require a key before the window opens (see Key system)
  KeySettings = {},         -- options for the key system, see below
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

### Real glass (experimental)

`RealGlass = true` in `MakeGui`, or `SetRealGlass(true)` at runtime, projects the panel's screen rectangle onto thin, nearly invisible glass wedges in front of the camera. A `DepthOfFieldEffect` then blurs only the depth near the camera, so the world behind the window blurs while the rest of the scene stays sharp. The technique is adapted from MacLib's acrylic.

```lua
local Window = FlurioreLib:MakeGui({
  NameHub = "My Hub",
  RealGlass = true,
  RealGlassIntensity = 1,    -- 0–1, blur strength near the camera (default 1)
})

Window:SetOpacity(0.5)       -- a more see-through panel shows the blur better
Window:SetRealGlass(false)
print(Window:GetRealGlass())
```

Limits:

- Objects closer than about 1.6 studs to the camera (first-person arms, for example) are also blurred, since the near-field blur covers them too.
- It is skipped when graphics quality is below level 8. Automatic quality is allowed.
- The wedges and effect are client-side. They hide when the window is hidden and are removed when the window is destroyed or real glass is turned off.
- Another script that uses its own `DepthOfFieldEffect` in Lighting can conflict with it.
- Not yet runtime-tested in Roblox Studio.

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

Click the row to expand a panel: a saturation/value square on the left and a hue bar on the right. Drag on either one. The swatch on the right shows the current color and stays at the top of the row while the panel is open. The row and its section grow to fit the panel, and dragging inside the panel does not scroll the section. Any color can be picked, including white, grey and black.

```lua
local Picker = Section:AddColorPicker({
  Title = "Accent",
  Content = "Click to open the picker",
  Default = Color3.fromRGB(255, 0, 255),
  Flag = "accent_color",
  Callback = function(color)
    Window:SetAccent(color)
  end,
})

print(Picker.Value)                    -- current Color3
Picker:Set(Color3.fromRGB(80, 200, 255))
Picker:SetHSV(0.55, 0.85, 1)           -- hue, saturation, value (0–1)
Picker:SetExpanded(true)               -- open or close the panel from code
```

`Callback` fires on every change while you drag, not only when you let go. Keep heavy work out of it, or debounce it yourself.

### Color cycle

A simpler control. Each click on the swatch steps the hue forward. Each step keeps saturation at least 0.55 and value at least 0.75, so clicking cannot produce white, grey or black. Use it for quick accent swaps; use `AddColorPicker` when people need to choose a color.

```lua
local Cycle = Section:AddColorCycle({
  Title = "Glow",
  Content = "Click to step the hue",
  Default = Color3.fromRGB(255, 0, 255),
  Flag = "glow_color",
  Callback = function(color)
    print(color)
  end,
})

Cycle:Set(Color3.fromRGB(80, 200, 255))
Cycle:SetHSV(0.55, 0.85, 1)
```

---

## Config

Attach `Flag` on Toggle, Slider, Input, Dropdown, Keybind, ColorPicker, ColorCycle.

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
  ColorCycle = true,
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
- Swipe left or right on the tab content to move to the next or previous tab. Quick flicks and drags past about 60 px both count.
- The header X fades the window out smoothly before it is destroyed.
- Default panel opacity (`Main`) is `0.3`, more see-through than older versions.
- Real glass (`RealGlass`) is experimental. It blurs only depth near the camera, so the far world stays sharp. See Real glass.


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
  ColorCycle = true,
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


---

## Key system

The key system lives inside `MakeGui`. It is off by default. Set `KeySystem = true` and fill `KeySettings`, and the window waits until a key is accepted before it is built.

```lua
local Window = FlurioreLib:MakeGui({
  NameHub = "My Hub",
  KeySystem = true,
  KeySettings = {
    Title = "My Hub",
    Subtitle = "Enter your key",
    Keys = {"KEY-ONE", {Key = "TRIAL", Label = "Trial", Expires = 1798761600}},
    GetKeyLinks = {{Label = "Discord", Url = "https://discord.gg/..."}},
    Save = true,
  },
})
```

`MakeGui` yields while the gate is up, so call it from a normal script body, not inside a callback or a Heartbeat connection.

The key window takes its colors from the same theme as the main menu (`ThemePreset` or `Theme`), so it uses the same surface, border, radius, fonts and accent. Use `KeySettings.Theme` to give it a different theme.

You can also call `FlurioreLib:RequireKey(settings)` on its own. It returns `true` once a key is accepted. Every option below is optional, so you can use only what you need.

```lua
local passed = FlurioreLib:RequireKey({
  Title = "My Hub",
  Subtitle = "Enter your key to continue",
  VerifyLabel = "Verify",            -- button text
  Logo = "rbxassetid://123456789",   -- or LogoFile = "logo.png" (getcustomasset)

  -- Local keys (several allowed, no server needed)
  Keys = {
    "KEY-ONE",
    {Key = "TRIAL-KEY", Label = "Trial", Expires = os.time() + 86400},
  },
  CaseSensitive = true,

  -- Get key buttons: any number, each a link or your own action
  GetKeyLinks = {
    {Label = "Discord", Url = "https://discord.gg/..."},
    {Label = "Copy key", Action = function(ctx)
      ctx.Copy("KEY-ONE")
      ctx.Status("Key copied")
    end},
  },

  Save = true,                       -- remember an accepted key
  SaveFile = "MyHubKey.txt",
})
if not passed then return end

local Window = FlurioreLib:MakeGui({ NameHub = "My Hub" })
```

### Checking a key

Checks run in this order. The first one that gives an answer decides.

1. `Keys`: local list, no network. `Expires` is an `os.time()` value.
2. `Verify = function(key, ctx) return ok, message end`: your own Lua check. `Validator` is the same thing under the old name.
3. `Service`: a registered service (see below).
4. `Api`: an HTTP check. Your server can return any shape:

```lua
Api = {
  Url = "https://your-server/check?key={key}&uid={uid}", -- or no placeholders: key/uid are appended
  Method = "GET",                        -- or "POST" (JSON body, needs the executor's request())
  Headers = {["X-Token"] = "..."},
  Extra = {hub = "main"},                -- sent with every check
  KeyParam = "key", UidParam = "uid",

  -- Optional: your own transport. Return the response body and status code.
  -- Request = function(key, uid) return body, statusCode end,

  -- Optional: your own parser. Return true/false and a message for the user.
  -- Parse = function(body, statusCode, key) return ok, message end,

  -- Used when Parse is not given: JSON paths for the answer
  ValidPath = "data.valid",
  MessagePath = "message",
}
```

### Services

Register a service once, then use it by name. This works like `WindUI.Services`: a service is a table with a `Verify` function, and it can also add a Get key button.

```lua
FlurioreLib.Services.myservice = {
  Args = {"ServiceId"},                              -- names of the values you pass in ServiceArgs
  Verify = function(key, ctx)
    -- ctx.Args.ServiceId, ctx.Uid, ctx.Status(text), ctx.Copy(text) are available
    return key == "abc", "Wrong key"
  end,
  GetKey = function(ctx)                             -- optional: custom action for the Get key button
    ctx.Copy("https://your-site/get-key")
  end,
  -- Url = "https://...",                            -- or a plain link, used when GetKey is missing
  -- GetKeyLabel = "Get key",
}

local passed = FlurioreLib:RequireKey({
  Title = "My Hub",
  Service = "myservice",                             -- or pass the table directly
  ServiceArgs = {ServiceId = "abc"},
})
```

### Get key buttons

- `GetKeyLinks`: any number of buttons. Each one has either a `Url` or an `Action`.
- A `Url` opens in a browser. If that fails, the link is copied. If copying is not available either, the link is shown in the status line.
- An `Action` gets a `ctx` with `Key`, `Uid`, `Args`, `Status(text, color)` and `Copy(text)`.
- `GetKeyUrl` / `GetKeyLabel` is a shorthand for a single link.

The gate runs on the client. `Keys`, `Verify` and `Validator` are inside the script, so anyone who reads it can see them. For a key that must stay hidden, check it on your server with `Api` or a service.

## Topbar buttons

Adds a small button to the left of the header's minimize button.

```lua
local btn = Window:AddTopbarButton({
  Name = "Theme",
  Icon = "T",                    -- single letter, or rbxassetid://… for an image
  Callback = function()
    Window:SetThemePreset("Rose")
  end,
})

btn:SetVisible(false)
btn:SetCallback(function() print("new handler") end)
btn:Destroy()
```

## Config as a string

Copy-paste friendly base64 version of the config (same content as `ExportConfig`).

```lua
local str = Window:ExportConfigString()   -- base64 text
local ok, err = Window:ImportConfigString(str)
```

## Label, divider and listeners

```lua
local Info = Section:AddLabel({ Title = "Status: idle", Color = Color3.fromRGB(180, 160, 255) })
Info:Set("Status: running")
Info:SetColor(Color3.fromRGB(120, 220, 160))

Section:AddDivider()

local Toggle = Section:AddToggle({ Title = "Auto farm", Flag = "auto_farm", Callback = function() end })
Toggle:OnChanged(function(value)
  print("auto farm is now", value)
end)
```

`OnChanged` works on Toggle, Slider, Input, Dropdown, Keybind, ColorPicker and ColorCycle. It returns the element, so calls can be chained. Listeners run in their own task, so one failing listener cannot break the others.


---

## Elements and popups (tier 1-2)

### Code block (copyable)

```lua
Section:AddCode({Title = "Webhook", Code = "https://discord.com/api/webhooks/..."})
```
A "Copy" button copies the text. `:Set(text)` changes it, `:Copy()` copies from code.

### Image

```lua
Section:AddImage({Image = "rbxassetid://123456789", Height = 140, Crop = false})
```
`:Set(id)` changes the picture and `:SetHeight(h)` changes its height. Only `rbxassetid://` images work.

### Space and group

```lua
Section:AddSpace(8)

local Group = Section:AddGroup({Columns = 2})
Group[1]:AddToggle({Title = "Left", Flag = "left", Callback = function() end})
Group[2]:AddSlider({Title = "Right", Min = 0, Max = 100, Flag = "right", Callback = function() end})
```
Each column accepts every `Add*` method. The group grows to fit its tallest column.

### Popup (window dialog)

```lua
Window:Popup({
  Title = "Reset settings",
  Content = "This clears every saved value. Continue?",
  Buttons = {
    {Title = "Cancel", Primary = false},
    {Title = "Reset", Callback = function(popup) print("reset") end},  -- Close = false keeps it open
  },
})
```
The last button is the primary one unless you set `Primary`. Pressing a button closes the popup unless `Close = false`.

### Notification with buttons

```lua
FlurioreLib:MakeNotify({
  Title = "Deleted",
  Content = "The config was removed.",
  Buttons = {
    {Title = "Undo", Callback = function() print("undo") end},
  },
})
```

### Element helpers

Every element now has `:Destroy()`, `:SetTitle(text)` and `:SetDesc(text)`. `SetTitle` and `SetDesc` change the first and second text labels in the element. Elements with a custom layout (such as Label) may need `Set` instead.

### Keybind modes

```lua
Section:AddKeybind({
  Title = "Boost",
  Default = Enum.KeyCode.LeftShift,
  Flag = "boost",
  Mode = "Hold",                          -- "Toggle" (default), "Hold" or "Always"
  OnTrigger = function(active) print("boost", active) end,
})
```
`Toggle` flips on each press, `Hold` is true while the key is held, and `Always` is on all the time. `:SetMode(mode)` changes the mode and `:GetState()` returns the current state. The existing `Callback` still runs when the key is set.

### Searchable dropdown

```lua
Section:AddDropdown({
  Title = "Target",
  Options = {"Alpha", "Beta", "Gamma"},
  Searchable = true,
  SearchPlaceholder = "Search options...",
  Callback = function(value) end,
})
```

### Color picker alpha and hex

The color picker now has an alpha bar and a hex box. `Alpha = 0.5` sets the starting alpha. `Callback(color, alpha)` receives both values, and `:SetAlpha(a)` changes the alpha. The flag saves `{r, g, b, a}`.

### Tab icons

`CreateTab({Icon = "rbxassetid://..."})` already shows an image icon. Text icons are not supported yet.


---

## Elements (tier 3)

### Text area (multi-line)

```lua
Section:AddTextArea({
  Title = "Notes",
  Content = "Shown under the title",
  Placeholder = "Write something...",
  Height = 96,
  Default = "",
  Flag = "notes",
  Callback = function(value) end,   -- fires when focus leaves the box
})
```
`:Get()`, `:Set(text)` and `:Clear()` work as usual. `OnChanged` works here too.

### Progress bar

```lua
local bar = Section:AddProgress({Title = "Download", Default = 35, Max = 100, Color = Color3.fromRGB(120, 220, 160)})
bar:Set(80)                   -- animates to the new value
bar:SetLabel("Almost done")   -- replaces the right-hand text
```
`Format = function(value, max) return "..." end` changes the right-hand text.

### Log console

```lua
local log = Section:AddLog({Title = "Console", Lines = 6, Timestamp = true})
log:Add("Script loaded", Color3.fromRGB(120, 220, 160))
log:Add("Warning: retrying")
log:Clear()
```
Only the newest lines are shown. New lines fade in and the oldest one is removed.

### Sub-tabs

```lua
local tabs = Section:AddSubTabs({"General", "Advanced"})
tabs[1]:AddToggle({Title = "Option A", Callback = function() end})
tabs[2]:AddSlider({Title = "Power", Min = 0, Max = 100, Callback = function() end})
tabs:Select(2)
```
Each page accepts every `Add*` method, the same as Group columns. The section resizes to fit the open page.

### Tag

```lua
local tags = Section:AddTag({
  Title = "Status",
  Tags = {"Beta", {Text = "Stable", Color = Color3.fromRGB(120, 220, 160)}},
})
tags:Add("New")
tags:Set({"Only this"})
```

### Card (link card)

```lua
Section:AddCard({
  Title = "Discord",
  Content = "Join the community",
  ButtonLabel = "Join",
  Image = "rbxassetid://123456789",   -- optional; otherwise the first letter is shown
  Url = "https://discord.gg/your-invite",   -- or Action = function() end
})
```
The button tries to open the link. If that fails, the link is copied and a notification shows it.

### Viewport (3D preview)

```lua
Section:AddViewport({
  Model = workspace:FindFirstChildWhichIsA("Model"),   -- any Model or BasePart instance
  Height = 150,
})
```
The model is cloned into a preview that slowly rotates. Its parts are anchored and not collidable. `:SetModel(instance)` changes the model.

### Not included

- **Video and audio** are not included. Roblox GUI can only play uploaded video assets (`VideoFrame`) and cannot show arbitrary media links, so the element would fail for most users.
- **Video and audio** are covered above.

### Discord widget (live)

```lua
Section:AddDiscord({
  Invite = "https://discord.gg/your-invite",   -- full link, discord.com/invite/... or the bare code
  Refresh = 60,                                 -- seconds, minimum 30
})
```

The card shows the server icon, name, description (or the channel name), online and member counts, and the names of up to three online members. The **Join** button opens the invite, and copies it if it cannot be opened.

It uses Discord's public endpoints and needs no token:

- `GET discord.com/api/v10/invites/{code}?with_counts=true` for the name, icon, description and counts.
- `GET discord.com/api/guilds/{id}/widget.json` for the live online list. This only works when the server owner has enabled the widget. If it is off, the card shows the invite counts and hides the list.

Results are cached for 20 seconds. The card refreshes at most every 30 seconds. If Discord rate-limits the request, it waits for `Retry-After`. The server icon is downloaded and cached with `writefile` and `getcustomasset` when the executor supports them, and a letter is shown otherwise.

Methods: `:Refresh()`, `:SetInvite(text)`, `:GetData()`, `:Join()`.
