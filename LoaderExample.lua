local Flur_Url = "https://raw.githubusercontent.com/MCUpload123/Fluriore-library/refs/heads/main/Flur.lua"

local function loadFlurioreLib()
    local requestOK, source = pcall(function()
        return game:HttpGet(Flur_Url)
    end)

    if not requestOK then
        error("[FlurioreLib] Download failed: " .. tostring(source))
    end

    if type(source) ~= "string" or source == "" then
        error("[FlurioreLib] Downloaded source is empty.")
    end

    local compileFunction, compileError = loadstring(source)
    if not compileFunction then
        error("[FlurioreLib] Compile failed: " .. tostring(compileError))
    end

    local runOK, library = pcall(compileFunction)
    if not runOK then
        error("[FlurioreLib] Library initialization failed: " .. tostring(library))
    end

    if type(library) ~= "table" then
        error("[FlurioreLib] Expected the library to return a table.")
    end

    return library
end

local FlurioreLib = loadFlurioreLib()

-- Notification example: MakeNotify + Close()
local notification = FlurioreLib:MakeNotify({
    Title = "FlurioreLib",
    Description = "Library loaded",
    Content = "The GitHub version loaded successfully.",
    Color = Color3.fromRGB(255, 0, 255),
    Time = 0.35,
    Delay = 8,
})

-- Main window example: MakeGui + window methods
local Window = FlurioreLib:MakeGui({
    NameHub = "FlurioreLib Demo",
    Description = "Public API showcase",
    Color = Color3.fromRGB(255, 0, 255),
    ["Tab Width"] = 120,
    -- Optional: ["Logo Player"] = "https://example.com/logo.png",
    -- Optional: ["Name Player"] = "Display name",
})

local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "", -- Optional image URL or Roblox asset string
})

local MainSection = MainTab:AddSection("Components")

-- Paragraph: AddParagraph + Set()
local Paragraph = MainSection:AddParagraph({
    Title = "Information",
    Content = "This paragraph can be updated while the UI is open.",
})

MainSection:AddButton({
    Title = "Update paragraph",
    Content = "Demonstrates Paragraph:Set().",
    Callback = function()
        Paragraph:Set({
            Title = "Updated",
            Content = "Paragraph:Set({Title = ..., Content = ...}) was called.",
        })
    end,
})

-- Button: AddButton + Callback
MainSection:AddButton({
    Title = "Close notification",
    Content = "Demonstrates the notification handle's Close() method.",
    Callback = function()
        notification:Close()
    end,
})

-- Toggle: AddToggle + Set() + Value
local Toggle = MainSection:AddToggle({
    Title = "Example toggle",
    Content = "Callback receives a boolean.",
    Default = false,
    Callback = function(value)
        print("Toggle value:", value)
    end,
})

-- Slider: AddSlider + Set() + Value
local Slider = MainSection:AddSlider({
    Title = "Example slider",
    Content = "Choose a number from 0 to 100.",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    Callback = function(value)
        print("Slider released at:", value)
    end,
})

-- Input: AddInput + Set() + Value
local Input = MainSection:AddInput({
    Title = "Example input",
    Content = "Enter text and press Enter or leave the field.",
    Callback = function(value)
        print("Input value:", value)
    end,
})

-- Dropdown: AddDropdown + Set/Clear/AddOption/Refresh
local Dropdown = MainSection:AddDropdown({
    Title = "Example dropdown",
    Content = "Set Multi = true to allow multiple options.",
    Multi = false,
    Options = {"Apple", "Banana", "Orange"},
    Default = {"Apple"},
    Callback = function(values)
        print("Dropdown values:", table.concat(values, ", "))
    end,
})

local ToolsTab = Window:CreateTab({Name = "Tools", Icon = ""})
local ToolsSection = ToolsTab:AddSection("Programmatic methods")

ToolsSection:AddButton({
    Title = "Set toggle ON",
    Content = "Calls Toggle:Set(true).",
    Callback = function()
        Toggle:Set(true)
    end,
})

ToolsSection:AddButton({
    Title = "Set slider to 75",
    Content = "Calls Slider:Set(75).",
    Callback = function()
        Slider:Set(75)
    end,
})

ToolsSection:AddButton({
    Title = "Set input text",
    Content = "Calls Input:Set('Hello from code').",
    Callback = function()
        Input:Set("Hello from code")
    end,
})

ToolsSection:AddButton({
    Title = "Add dropdown option",
    Content = "Adds 'Mango' to the visible options.",
    Callback = function()
        Dropdown:AddOption("Mango")
    end,
})

ToolsSection:AddButton({
    Title = "Select Banana",
    Content = "Calls Dropdown:Set({'Banana'}).",
    Callback = function()
        Dropdown:Set({"Banana"})
    end,
})

ToolsSection:AddButton({
    Title = "Refresh dropdown options",
    Content = "Replaces the options and selects 'Blue'.",
    Callback = function()
        Dropdown:Refresh({"Red", "Green", "Blue"}, {"Blue"})
    end,
})

ToolsSection:AddButton({
    Title = "Clear dropdown",
    Content = "Removes all visible options.",
    Callback = function()
        Dropdown:Clear()
    end,
})

ToolsSection:AddButton({
    Title = "Toggle window visibility",
    Content = "Calls Window:ToggleUI(). RightShift is also supported.",
    Callback = function()
        Window:ToggleUI()
    end,
})

ToolsSection:AddButton({
    Title = "Destroy window",
    Content = "Removes the FlurioreLib window.",
    Callback = function()
        Window:DestroyGui()
    end,
})

print("[FlurioreLib] Loaded. API showcase is ready.")
