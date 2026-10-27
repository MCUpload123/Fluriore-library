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

local notification = FlurioreLib:MakeNotify({
    Title = "FlurioreLib",
    Description = "Library loaded",
    Content = "The GitHub version loaded successfully.",
    Color = Color3.fromRGB(255, 0, 255),
    Time = 0.35,
    Delay = 8,
})

local Window = FlurioreLib:MakeGui({
    NameHub = "FlurioreLib Demo",
    Description = "Public API showcase",
    Color = Color3.fromRGB(255, 0, 255),
    ["Tab Width"] = 120,
})

local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "",
})

local MainSection = MainTab:AddSection("Components")

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

MainSection:AddButton({
    Title = "Close notification",
    Content = "Demonstrates the notification handle's Close() method.",
    Callback = function()
        notification:Close()
    end,
})

local Toggle = MainSection:AddToggle({
    Title = "Example toggle",
    Content = "Callback receives a boolean. Flag is optional for SaveConfig.",
    Default = false,
    Flag = "demo_toggle",
    Callback = function(value)
        print("Toggle value:", value)
    end,
})

local Slider = MainSection:AddSlider({
    Title = "Example slider",
    Content = "Choose a number from 0 to 100.",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    Flag = "demo_slider",
    Callback = function(value)
        print("Slider released at:", value)
    end,
})

local Input = MainSection:AddInput({
    Title = "Example input",
    Content = "Enter text and press Enter or leave the field.",
    Flag = "demo_input",
    Callback = function(value)
        print("Input value:", value)
    end,
})

local Dropdown = MainSection:AddDropdown({
    Title = "Example dropdown",
    Content = "Set Multi = true to allow multiple options.",
    Multi = false,
    Options = {"Apple", "Banana", "Orange"},
    Default = {"Apple"},
    Flag = "demo_dropdown",
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
    Content = "Calls Dropdown:Clear().",
    Callback = function()
        Dropdown:Clear()
    end,
})

ToolsSection:AddButton({
    Title = "Save config",
    Content = "Window:SaveConfig('FlurioreDemo', 'main') — needs writefile.",
    Callback = function()
        local ok, result = Window:SaveConfig("FlurioreDemo", "main")
        print("SaveConfig:", ok, result)
    end,
})

ToolsSection:AddButton({
    Title = "Load config",
    Content = "Window:LoadConfig('FlurioreDemo', 'main') — needs readfile.",
    Callback = function()
        local ok, result = Window:LoadConfig("FlurioreDemo", "main")
        print("LoadConfig:", ok, result)
    end,
})
