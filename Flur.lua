local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local TextService = game:GetService("TextService")
local CoreGui = LocalPlayer:WaitForChild("PlayerGui") 
local function MakeDraggable(topbarobject, object)
	local function CustomPos(topbarobject, object)
		local Dragging = nil
		local DragInput = nil
		local DragStart = nil
		local StartPosition = nil

		local function UpdatePos(input)
			local Delta = input.Position - DragStart
			local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
			object.Position = pos
		end

		topbarobject.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				DragStart = input.Position
				StartPosition = object.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)

		topbarobject.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				DragInput = input
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input == DragInput and Dragging then
				UpdatePos(input)
			end
		end)
	end
	local function CustomSize(object)
		local Dragging = false
		local DragInput = nil
		local DragStart = nil
		local StartSize = nil
		local minSizeX = 320
		local minSizeY = 240
		object.Size = UDim2.new(
			0, math.max(object.Size.X.Offset, minSizeX),
			0, math.max(object.Size.Y.Offset, minSizeY)
		)
		local changesizeobject = Instance.new("Frame");

		changesizeobject.AnchorPoint = Vector2.new(1, 1)
		changesizeobject.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		changesizeobject.BackgroundTransparency = 0.9990000128746033
		changesizeobject.BorderColor3 = Color3.fromRGB(0, 0, 0)
		changesizeobject.BorderSizePixel = 0
		changesizeobject.Position = UDim2.new(1, 20, 1, 20)
		changesizeobject.Size = UDim2.new(0, 40, 0, 40)
		changesizeobject.Name = "changesizeobject"
		changesizeobject.Parent = object

		local function UpdateSize(input)
			local Delta = input.Position - DragStart
			local newWidth = StartSize.X.Offset + Delta.X
			local newHeight = StartSize.Y.Offset + Delta.Y
			newWidth = math.max(newWidth, minSizeX)
			newHeight = math.max(newHeight, minSizeY)
			object.Size = UDim2.new(0, newWidth, 0, newHeight)
		end

		changesizeobject.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				DragStart = input.Position
				StartSize = object.Size
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)

		changesizeobject.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				DragInput = input
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input == DragInput and Dragging then
				UpdateSize(input)
			end
		end)
	end
	CustomSize(object)
	CustomPos(topbarobject, object)
end
function CircleClick(Button, X, Y)
	spawn(function()
		Button.ClipsDescendants = true
		local Circle = Instance.new("ImageLabel")
		Circle.Image = "rbxassetid://266543268"
		Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
		Circle.ImageTransparency = 0.8999999761581421
		Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Circle.BackgroundTransparency = 1
		Circle.ZIndex = 10
		Circle.Name = "Circle"
		Circle.Parent = Button
		
		local NewX = X - Circle.AbsolutePosition.X
		local NewY = Y - Circle.AbsolutePosition.Y
		Circle.Position = UDim2.new(0, NewX, 0, NewY)
		local Size = 0
		if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
			Size = Button.AbsoluteSize.X*1.5
		elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
			Size = Button.AbsoluteSize.Y*1.5
		elseif Button.AbsoluteSize.X == Button.AbsoluteSize.Y then
			Size = Button.AbsoluteSize.X*1.5
		end

		local Time = 0.5
		Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size/2, 0.5, -Size/2), "Out", "Quad", Time, false, nil)
		for i=1,10 do
			Circle.ImageTransparency = Circle.ImageTransparency + 0.01
			wait(Time/10)
		end
		Circle:Destroy()
	end)
end

local FlurioreLib = {}
function FlurioreLib:MakeNotify(NotifyConfig)
	local NotifyConfig = NotifyConfig or {}
	NotifyConfig.Title = NotifyConfig.Title or "Hirimi Hub"
	NotifyConfig.Description = NotifyConfig.Description or "Notification"
	NotifyConfig.Content = NotifyConfig.Content or "Content"
	NotifyConfig.Color = NotifyConfig.Color or Color3.fromRGB(255, 0, 255)
	NotifyConfig.Time = math.max(0.05, tonumber(NotifyConfig.Time) or 0.5)
	NotifyConfig.Delay = math.max(0, tonumber(NotifyConfig.Delay) or 5)
	local NotifyFunction = {}
		if not CoreGui:FindFirstChild("NotifyGui") then
			local NotifyGui = Instance.new("ScreenGui");
			NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			NotifyGui.Name = "NotifyGui"
			NotifyGui.Parent = CoreGui
		end
		if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
			local NotifyLayout = Instance.new("Frame");
			NotifyLayout.AnchorPoint = Vector2.new(1, 1)
			NotifyLayout.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			NotifyLayout.BackgroundTransparency = 0.9990000128746033
			NotifyLayout.BorderColor3 = Color3.fromRGB(0, 0, 0)
			NotifyLayout.BorderSizePixel = 0
			NotifyLayout.Position = UDim2.new(1, -30, 1, -30)
			NotifyLayout.Size = UDim2.new(0, 320, 1, 0)
			NotifyLayout.Name = "NotifyLayout"
			NotifyLayout.Parent = CoreGui.NotifyGui
			local Count = 0
			CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(function()
				Count = 0
				for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
					TweenService:Create(
						v,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12)*Count))}
					):Play()
					Count = Count + 1
				end
			end)
		end
		local NotifyPosHeigh = 0
		for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
			NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
		end
		local NotifyFrame = Instance.new("Frame");
		local NotifyFrameReal = Instance.new("Frame");
		local UICorner = Instance.new("UICorner");
		local DropShadowHolder = Instance.new("Frame");
		local DropShadow = Instance.new("ImageLabel");
		local Top = Instance.new("Frame");
		local TextLabel = Instance.new("TextLabel");
		local UIStroke = Instance.new("UIStroke");
		local UICorner1 = Instance.new("UICorner");
		local TextLabel1 = Instance.new("TextLabel");
		local UIStroke1 = Instance.new("UIStroke");
		local Close = Instance.new("TextButton");
		local ImageLabel = Instance.new("ImageLabel");
		local TextLabel2 = Instance.new("TextLabel");

		NotifyFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		NotifyFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		NotifyFrame.BorderSizePixel = 0
		NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
		NotifyFrame.Name = "NotifyFrame"
		NotifyFrame.BackgroundTransparency = 1
		NotifyFrame.Parent = CoreGui.NotifyGui.NotifyLayout
		NotifyFrame.AnchorPoint = Vector2.new(0, 1)
		NotifyFrame.Position = UDim2.new(0, 0, 1, -(NotifyPosHeigh))

		NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		NotifyFrameReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
		NotifyFrameReal.BorderSizePixel = 0
		NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
		NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
		NotifyFrameReal.Name = "NotifyFrameReal"
		NotifyFrameReal.Parent = NotifyFrame

		UICorner.Parent = NotifyFrameReal
		UICorner.CornerRadius = UDim.new(0, 8)

		DropShadowHolder.BackgroundTransparency = 1
		DropShadowHolder.BorderSizePixel = 0
		DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
		DropShadowHolder.ZIndex = 0
		DropShadowHolder.Name = "DropShadowHolder"
		DropShadowHolder.Parent = NotifyFrameReal

		DropShadow.Image = "rbxassetid://6015897843"
		DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
		DropShadow.ImageTransparency = 0.5
		DropShadow.ScaleType = Enum.ScaleType.Slice
		DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
		DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
		DropShadow.BackgroundTransparency = 1
		DropShadow.BorderSizePixel = 0
		DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
		DropShadow.Size = UDim2.new(1, 47, 1, 47)
		DropShadow.ZIndex = 0
		DropShadow.Name = "DropShadow"
		DropShadow.Parent = DropShadowHolder

		Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		Top.BackgroundTransparency = 0.9990000128746033
		Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Top.BorderSizePixel = 0
		Top.Size = UDim2.new(1, 0, 0, 36)
		Top.Name = "Top"
		Top.Parent = NotifyFrameReal

		TextLabel.Font = Enum.Font.GothamBold
		TextLabel.Text = NotifyConfig.Title
		TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.TextSize = 14
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.BackgroundTransparency = 0.9990000128746033
		TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel.BorderSizePixel = 0
		local notifyTitleTextWidth = math.min(170, math.ceil(TextService:GetTextSize(tostring(NotifyConfig.Title), TextLabel.TextSize, TextLabel.Font, Vector2.new(1000, 30)).X))
		TextLabel.Size = UDim2.new(0, notifyTitleTextWidth, 1, 0)
		TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
		TextLabel.Parent = Top
		TextLabel.Position = UDim2.new(0, 10, 0, 0)

		UIStroke.Color = Color3.fromRGB(255, 255, 255)
		UIStroke.Thickness = 0.30000001192092896
		UIStroke.Parent = TextLabel

		UICorner1.Parent = Top
		UICorner1.CornerRadius = UDim.new(0, 5)

		TextLabel1.Font = Enum.Font.GothamBold
		TextLabel1.Text = NotifyConfig.Description
		TextLabel1.TextColor3 = NotifyConfig.Color
		TextLabel1.TextSize = 14
		TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel1.BackgroundTransparency = 0.9990000128746033
		TextLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel1.BorderSizePixel = 0
		TextLabel1.Size = UDim2.new(1, -(notifyTitleTextWidth + 50), 1, 0)
		TextLabel1.Position = UDim2.new(0, notifyTitleTextWidth + 15, 0, 0)
		TextLabel1.TextTruncate = Enum.TextTruncate.AtEnd
		TextLabel1.Parent = Top

		UIStroke1.Color = NotifyConfig.Color
		UIStroke1.Thickness = 0.4000000059604645
		UIStroke1.Parent = TextLabel1

		Close.Font = Enum.Font.SourceSans
		Close.Text = ""
		Close.TextColor3 = Color3.fromRGB(0, 0, 0)
		Close.TextSize = 14
		Close.AnchorPoint = Vector2.new(1, 0.5)
		Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Close.BackgroundTransparency = 0.9990000128746033
		Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Close.BorderSizePixel = 0
		Close.Position = UDim2.new(1, -5, 0.5, 0)
		Close.Size = UDim2.new(0, 25, 0, 25)
		Close.Name = "Close"
		Close.Parent = Top

		ImageLabel.Image = "rbxassetid://9886659671"
		ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ImageLabel.BackgroundTransparency = 0.9990000128746033
		ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ImageLabel.BorderSizePixel = 0
		ImageLabel.Position = UDim2.new(0.49000001, 0, 0.5, 0)
		ImageLabel.Size = UDim2.new(1, -8, 1, -8)
		ImageLabel.Parent = Close

		TextLabel2.Font = Enum.Font.GothamBold
		TextLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel2.TextSize = 13
		TextLabel2.Text = NotifyConfig.Content
		TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
		TextLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel2.BackgroundTransparency = 0.9990000128746033
		TextLabel2.TextColor3 = Color3.fromRGB(150.0000062584877, 150.0000062584877, 150.0000062584877)
		TextLabel2.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel2.BorderSizePixel = 0
		TextLabel2.Position = UDim2.new(0, 10, 0, 27)
		TextLabel2.Parent = NotifyFrameReal
		TextLabel2.TextWrapped = true
		local notifyTextWidth = 300
		local notifyTextBounds = TextService:GetTextSize(tostring(NotifyConfig.Content), TextLabel2.TextSize, TextLabel2.Font, Vector2.new(notifyTextWidth, 10000))
		local notifyContentHeight = math.max(13, math.ceil(notifyTextBounds.Y))
		TextLabel2.Size = UDim2.new(1, -20, 0, notifyContentHeight)
		if notifyContentHeight < 27 then
			NotifyFrame.Size = UDim2.new(1, 0, 0, 65)
		else
			NotifyFrame.Size = UDim2.new(1, 0, 0, notifyContentHeight + 40)
		end
		local waitbruh = false
		function NotifyFunction:Close()
			if waitbruh then
				return false
			end
			waitbruh = true
			TweenService:Create(
				NotifyFrameReal,
				TweenInfo.new(NotifyConfig.Time, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
				{Position = UDim2.new(0, 400, 0, 0)}
			):Play()
			task.wait(NotifyConfig.Time / 1.2)
			NotifyFrame:Destroy()
		end
		Close.Activated:Connect(function()
			NotifyFunction:Close()
		end)
	TweenService:Create(
		NotifyFrameReal,
		TweenInfo.new(NotifyConfig.Time, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
		{Position = UDim2.new(0, 0, 0, 0)}
	):Play()
	task.spawn(function()
		task.wait(NotifyConfig.Delay)
		NotifyFunction:Close()
	end)
	return NotifyFunction
end
function FlurioreLib:MakeGui(GuiConfig)
	local GuiConfig = GuiConfig or {}
	GuiConfig.NameHub = GuiConfig.NameHub or "Hirimi Hub"
	GuiConfig.Description = GuiConfig.Description or "Comeback | developing by Hirimi, Teru"
	GuiConfig.Color = GuiConfig.Color or Color3.fromRGB(255, 0, 255)
	GuiConfig["Logo Player"] = GuiConfig["Logo Player"] or "https://www.roblox.com/headshot-thumbnail/image?userId="..game:GetService("Players").LocalPlayer.UserId .."&width=420&height=420&format=png"
	GuiConfig["Name Player"] = GuiConfig["Name Player"] or tostring(game:GetService("Players").LocalPlayer.Name)
	GuiConfig["Tab Width"] = GuiConfig["Tab Width"] or 120

	-- Theme support is API/config driven; no theme picker is added to the Settings panel.
	local Theme = {
		Accent = GuiConfig.Color,
		Background = Color3.fromRGB(15, 15, 15),
		Surface = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(235, 235, 235),
		MutedText = Color3.fromRGB(160, 160, 160),
		Border = Color3.fromRGB(50, 50, 50),
	}
	if type(GuiConfig.Theme) == "table" then
		for key, value in pairs(GuiConfig.Theme) do
			if Theme[key] ~= nil and typeof(value) == "Color3" then
				Theme[key] = value
			end
		end
	end
	GuiConfig.Color = Theme.Accent
	local lastAccent = GuiConfig.Color
	local textScaleValue = math.clamp(tonumber(GuiConfig.TextScale) or 1, 0.7, 1.5)
	local uiScaleValue = math.clamp(tonumber(GuiConfig.UIScale) or 0.9, 0.75, 1.2)
	local textBaseSizes = setmetatable({}, {__mode = "k"})
	local GuiFunc = {}

	local function isTextObject(object)
		return object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")
	end

	local function registerTextObject(object)
		if not isTextObject(object) then return end
		if textBaseSizes[object] == nil then
			textBaseSizes[object] = object.TextSize
		end
		object.TextSize = math.max(8, math.floor(textBaseSizes[object] * textScaleValue + 0.5))
	end

	-- Measure wrapped descriptions with TextService instead of dividing TextBounds by
	-- AbsoluteSize (which can be zero during creation and clips text on mobile).
	local function BindWrappedText(label, container, rightPadding, minimumTextHeight, minimumContainerHeight, bottomPadding, onResize)
		local updating = false
		local function update()
			if updating or not label.Parent or not container.Parent then return end
			local dynamicRightPadding = type(rightPadding) == "function" and rightPadding() or rightPadding
			dynamicRightPadding = tonumber(dynamicRightPadding) or 10
			local leftPadding = label.Position.X.Offset
			local availableWidth = container.AbsoluteSize.X - leftPadding - dynamicRightPadding
			if availableWidth < 24 then return end
			updating = true
			local measured = TextService:GetTextSize(tostring(label.Text or ""), label.TextSize, label.Font, Vector2.new(availableWidth, 10000))
			local wantedTextHeight = math.max(minimumTextHeight or 12, math.ceil(measured.Y))
			local wantedXOffset = -(leftPadding + dynamicRightPadding)
			if label.Size.X.Scale ~= 1 or label.Size.X.Offset ~= wantedXOffset or label.Size.Y.Offset ~= wantedTextHeight then
				label.Size = UDim2.new(1, wantedXOffset, 0, wantedTextHeight)
			end
			local wantedContainerHeight = math.max(minimumContainerHeight or 44, label.Position.Y.Offset + wantedTextHeight + (bottomPadding or 8))
			local sizeChanged = container.Size.Y.Scale ~= 0 or container.Size.Y.Offset ~= wantedContainerHeight
			if sizeChanged then
				container.Size = UDim2.new(container.Size.X.Scale, container.Size.X.Offset, 0, wantedContainerHeight)
			end
			updating = false
			if sizeChanged and onResize then task.defer(onResize) end
		end
		label.TextWrapped = true
		label:GetPropertyChangedSignal("Text"):Connect(update)
		label:GetPropertyChangedSignal("TextSize"):Connect(update)
		container:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
		task.defer(update)
		return update
	end

	local surfaceNames = {
		Section = true, Paragraph = true, Button = true, Toggle = true,
		Slider = true, Input = true, Dropdown = true, Info = true,
		SelectOptionsFrame = true,
	}
	local contentNameFragments = {"Content", "Description", "OptionSelecting"}
	local function colorNearlyEqual(a, b)
		return math.abs(a.R - b.R) < 0.012 and math.abs(a.G - b.G) < 0.012 and math.abs(a.B - b.B) < 0.012
	end
	local function applyThemeToObject(object)
		if not object or not object.Parent then return end
		local role = object:GetAttribute("FlurThemeRole")
		if object:IsA("UIGradient") then
			object.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Theme.Background),
				ColorSequenceKeypoint.new(0.5, Theme.Accent),
				ColorSequenceKeypoint.new(1, Theme.Background),
			})
		elseif object:IsA("UIStroke") then
			if role == "Accent" or object.Color == lastAccent then
				object.Color = Theme.Accent
			elseif role == "Border" or object.Name == "UIStroke" then
				object.Color = Theme.Border
			end
		elseif object:IsA("GuiObject") then
			if object.BackgroundColor3 == lastAccent or role == "AccentBackground" then
				object.BackgroundColor3 = Theme.Accent
			elseif role == "Background" or object.Name == "Main" or object.Name == "SettingsPanel" then
				object.BackgroundColor3 = Theme.Background
			elseif role == "Surface" or surfaceNames[object.Name] then
				object.BackgroundColor3 = Theme.Surface
			end
			if isTextObject(object) then
				if object.TextColor3 == lastAccent or role == "AccentText" then
					object.TextColor3 = Theme.Accent
				elseif role == "MutedText" then
					object.TextColor3 = Theme.MutedText
				elseif role ~= "Text" and (string.find(object.Name, "Content", 1, true) or string.find(object.Name, "Description", 1, true) or object.Name == "OptionSelecting") then
					object.TextColor3 = Theme.MutedText
				elseif role == "Text" or colorNearlyEqual(object.TextColor3, Color3.fromRGB(230, 230, 230)) or colorNearlyEqual(object.TextColor3, Color3.fromRGB(235, 235, 235)) or colorNearlyEqual(object.TextColor3, Color3.fromRGB(255, 255, 255)) then
					object.TextColor3 = Theme.Text
				end
			end
		end
	end

	local HirimiGui = Instance.new("ScreenGui");
	local DropShadowHolder = Instance.new("Frame");
	local DropShadow = Instance.new("ImageLabel");
	local Main = Instance.new("Frame");
	local UICorner = Instance.new("UICorner");
	local UIStroke = Instance.new("UIStroke");
	local Top = Instance.new("Frame");
	local TextLabel = Instance.new("TextLabel");
	local UICorner1 = Instance.new("UICorner");
	local TextLabel1 = Instance.new("TextLabel");
	local UIStroke1 = Instance.new("UIStroke");
	local MaxRestore = Instance.new("TextButton");
	local ImageLabel = Instance.new("ImageLabel");
	local Close = Instance.new("TextButton");
	local ImageLabel1 = Instance.new("ImageLabel");
	local Min = Instance.new("TextButton");
	local ImageLabel2 = Instance.new("ImageLabel");
	local LayersTab = Instance.new("Frame");
	local UICorner2 = Instance.new("UICorner");
	local DecideFrame = Instance.new("Frame");
	local UIStroke3 = Instance.new("UIStroke");
	local Layers = Instance.new("Frame");
	local UICorner6 = Instance.new("UICorner");
	local NameTab = Instance.new("TextLabel");
	local LayersReal = Instance.new("Frame");
	local LayersFolder = Instance.new("Folder");
	local LayersPageLayout = Instance.new("UIPageLayout");

	HirimiGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	HirimiGui.Name = "HirimiGui"
	HirimiGui.ResetOnSpawn = false
	HirimiGui.Parent = CoreGui

	local UIScaleObject = Instance.new("UIScale")
	UIScaleObject.Name = "FlurioreUIScale"
	UIScaleObject.Scale = uiScaleValue
	UIScaleObject.Parent = DropShadowHolder

	HirimiGui.DescendantAdded:Connect(function(object)
		task.defer(function()
			if not object.Parent then return end
			registerTextObject(object)
			applyThemeToObject(object)
		end)
	end)

	DropShadowHolder.BackgroundTransparency = 1
	DropShadowHolder.BorderSizePixel = 0
	DropShadowHolder.Size = UDim2.new(0, 455, 0, 350)
	DropShadowHolder.ZIndex = 0
	DropShadowHolder.Name = "DropShadowHolder"
	DropShadowHolder.Parent = HirimiGui
	
	local InitialViewport = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(800, 600)
	DropShadowHolder.Position = UDim2.new(0, math.max(0, (InitialViewport.X - DropShadowHolder.Size.X.Offset) / 2), 0, math.max(0, (InitialViewport.Y - DropShadowHolder.Size.Y.Offset) / 2))
	DropShadow.Image = "rbxassetid://6015897843"
	DropShadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
	DropShadow.ImageTransparency = 0.5
	DropShadow.ScaleType = Enum.ScaleType.Slice
	DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
	DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow.BackgroundTransparency = 1
	DropShadow.BorderSizePixel = 0
	DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	DropShadow.Size = UDim2.new(1, 47, 1, 47)
	DropShadow.ZIndex = 0
	DropShadow.Name = "DropShadow"
	DropShadow.Parent = DropShadowHolder

	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Main.BackgroundTransparency = 0.1
	Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Position = UDim2.new(0.5, 0, 0.5, 0)
	Main.Size = UDim2.new(1, -47, 1, -47)
	Main.Name = "Main"
	Main.Parent = DropShadow

	UICorner.Parent = Main

	UIStroke.Color = Color3.fromRGB(50, 50, 50)
	UIStroke.Thickness = 1.600000023841858
	UIStroke.Parent = Main

	Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Top.BackgroundTransparency = 0.9990000128746033
	Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Top.BorderSizePixel = 0
	Top.Size = UDim2.new(1, 0, 0, 38)
	Top.ZIndex = 10
	Top.Name = "Top"
	Top.Parent = Main

	TextLabel.Font = Enum.Font.GothamBold
	TextLabel.Text = GuiConfig.NameHub
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextSize = 14
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.BackgroundTransparency = 0.9990000128746033
	TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.BorderSizePixel = 0
	local headerTitleTextWidth = math.min(160, math.ceil(TextService:GetTextSize(tostring(GuiConfig.NameHub), TextLabel.TextSize, TextLabel.Font, Vector2.new(1000, 30)).X))
	TextLabel.Size = UDim2.new(0, headerTitleTextWidth, 1, 0)
	TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
	TextLabel.Position = UDim2.new(0, 10, 0, 0)
	TextLabel.Parent = Top

	UICorner1.Parent = Top

	TextLabel1.Font = Enum.Font.GothamBold
	TextLabel1.Text = GuiConfig.Description
	TextLabel1.TextColor3 = GuiConfig.Color
	TextLabel1.TextSize = 14
	TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel1.BackgroundTransparency = 0.9990000128746033
	TextLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel1.BorderSizePixel = 0
	local headerDescriptionTextWidth = math.ceil(TextService:GetTextSize(tostring(GuiConfig.Description), TextLabel1.TextSize, TextLabel1.Font, Vector2.new(1000, 30)).X)
	TextLabel1.Size = UDim2.new(1, -(headerTitleTextWidth + 160), 1, 0)
	TextLabel1.TextTruncate = Enum.TextTruncate.AtEnd
	TextLabel1.Position = UDim2.new(0, headerTitleTextWidth + 15, 0, 0)
	TextLabel1.Parent = Top

	UIStroke1.Color = GuiConfig.Color
	UIStroke1.Thickness = 0.4000000059604645
	UIStroke1.Parent = TextLabel1

	MaxRestore.Font = Enum.Font.SourceSans
	MaxRestore.Text = ""
	MaxRestore.TextColor3 = Color3.fromRGB(0, 0, 0)
	MaxRestore.TextSize = 14
	MaxRestore.AnchorPoint = Vector2.new(1, 0.5)
	MaxRestore.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	MaxRestore.BackgroundTransparency = 0.9990000128746033
	MaxRestore.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MaxRestore.BorderSizePixel = 0
	MaxRestore.Position = UDim2.new(1, -42, 0.5, 0)
	MaxRestore.Size = UDim2.new(0, 25, 0, 25)
	MaxRestore.Name = "MaxRestore"
	MaxRestore.Parent = Top

	ImageLabel.Image = "rbxassetid://9886659406"
	ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageLabel.BackgroundTransparency = 0.9990000128746033
	ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	ImageLabel.Size = UDim2.new(1, -8, 1, -8)
	ImageLabel.Parent = MaxRestore

	Close.Font = Enum.Font.SourceSans
	Close.Text = ""
	Close.TextColor3 = Color3.fromRGB(0, 0, 0)
	Close.TextSize = 14
	Close.AnchorPoint = Vector2.new(1, 0.5)
	Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Close.BackgroundTransparency = 0.9990000128746033
	Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Close.BorderSizePixel = 0
	Close.Position = UDim2.new(1, -8, 0.5, 0)
	Close.Size = UDim2.new(0, 25, 0, 25)
	Close.Name = "Close"
	Close.Parent = Top

	ImageLabel1.Image = "rbxassetid://9886659671"
	ImageLabel1.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageLabel1.BackgroundTransparency = 0.9990000128746033
	ImageLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel1.BorderSizePixel = 0
	ImageLabel1.Position = UDim2.new(0.49, 0, 0.5, 0)
	ImageLabel1.Size = UDim2.new(1, -8, 1, -8)
	ImageLabel1.Parent = Close

	Min.Font = Enum.Font.SourceSans
	Min.Text = ""
	Min.TextColor3 = Color3.fromRGB(0, 0, 0)
	Min.TextSize = 14
	Min.AnchorPoint = Vector2.new(1, 0.5)
	Min.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Min.BackgroundTransparency = 0.9990000128746033
	Min.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Min.BorderSizePixel = 0
	Min.Position = UDim2.new(1, -78, 0.5, 0)
	Min.Size = UDim2.new(0, 25, 0, 25)
	Min.Name = "Min"
	Min.Parent = Top

	ImageLabel2.Image = "rbxassetid://9886659276"
	ImageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageLabel2.BackgroundTransparency = 0.9990000128746033
	ImageLabel2.ImageTransparency = 0.2
	ImageLabel2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel2.BorderSizePixel = 0
	ImageLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
	ImageLabel2.Size = UDim2.new(1, -9, 1, -9)
	ImageLabel2.Parent = Min

	local IsMinimized = false
	local SetMinimized
	local SettingsButton = Instance.new("TextButton")
	SettingsButton.Name = "SettingsButton"
	SettingsButton:SetAttribute("FlurThemeRole", "Text")
	SettingsButton.AnchorPoint = Vector2.new(1, 0.5)
	SettingsButton.Position = UDim2.new(1, -112, 0.5, 0)
	SettingsButton.Size = UDim2.new(0, 25, 0, 25)
	SettingsButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SettingsButton.BackgroundTransparency = 0.999
	SettingsButton.BorderSizePixel = 0
	SettingsButton.Text = "⚙"
	SettingsButton.Font = Enum.Font.GothamBold
	SettingsButton.TextSize = 16
	SettingsButton.TextColor3 = Color3.fromRGB(235, 235, 235)
	SettingsButton.AutoButtonColor = false
	SettingsButton.ZIndex = 21
	SettingsButton.Parent = Top

	local SettingsPanel = Instance.new("Frame")
	SettingsPanel.Name = "SettingsPanel"
	SettingsPanel:SetAttribute("FlurThemeRole", "Background")
	SettingsPanel.AnchorPoint = Vector2.new(1, 0)
	SettingsPanel.Position = UDim2.new(1, -8, 0, 44)
	SettingsPanel.Size = UDim2.new(0, 230, 0, 132)
	SettingsPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	SettingsPanel.BackgroundTransparency = 0.04
	SettingsPanel.BorderSizePixel = 0
	SettingsPanel.Visible = false
	SettingsPanel.ZIndex = 20
	SettingsPanel.Parent = Main
	local SettingsCorner = Instance.new("UICorner")
	SettingsCorner.CornerRadius = UDim.new(0, 7)
	SettingsCorner.Parent = SettingsPanel
	local SettingsStroke = Instance.new("UIStroke")
	SettingsStroke.Color = Theme.Border
	SettingsStroke.Thickness = 1
	SettingsStroke.Parent = SettingsPanel

	local function makeSettingsLabel(name, text, position, size, textSize, alignment)
		local label = Instance.new("TextLabel")
		label.Name = name
		label:SetAttribute("FlurThemeRole", "Text")
		label.Text = text
		label.Position = position
		label.Size = size
		label.BackgroundTransparency = 1
		label.BorderSizePixel = 0
		label.Font = Enum.Font.Gotham
		label.TextSize = textSize or 11
		label.TextColor3 = Theme.Text
		label.TextXAlignment = alignment or Enum.TextXAlignment.Left
		label.ZIndex = 21
		label.Parent = SettingsPanel
		return label
	end
	local function makeSettingsButton(name, text, position, size)
		local button = Instance.new("TextButton")
		button.Name = name
		button:SetAttribute("FlurThemeRole", "Surface")
		button.Text = text
		button.Position = position
		button.Size = size
		button.BackgroundColor3 = Theme.Surface
		button.BackgroundTransparency = 0.86
		button.BorderSizePixel = 0
		button.Font = Enum.Font.GothamBold
		button.TextSize = 12
		button.TextColor3 = Theme.Text
		button.AutoButtonColor = true
		button.ZIndex = 21
		button.Parent = SettingsPanel
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = button
		return button
	end
	makeSettingsLabel("SettingsTitle", "Display settings", UDim2.new(0, 10, 0, 7), UDim2.new(1, -20, 0, 18), 12)
	local TextScaleLabel = makeSettingsLabel("TextScaleLabel", "Text size: 100%", UDim2.new(0, 10, 0, 33), UDim2.new(0, 96, 0, 20), 11)
	local TextScaleMinus = makeSettingsButton("TextScaleMinus", "−", UDim2.new(0, 111, 0, 30), UDim2.new(0, 22, 0, 23))
	local TextScaleValueLabel = makeSettingsLabel("TextScaleValueLabel", "100%", UDim2.new(0, 137, 0, 32), UDim2.new(0, 48, 0, 20), 11, Enum.TextXAlignment.Center)
	local TextScalePlus = makeSettingsButton("TextScalePlus", "+", UDim2.new(0, 190, 0, 30), UDim2.new(0, 22, 0, 23))
	local UIScaleLabel = makeSettingsLabel("UIScaleLabel", "UI size", UDim2.new(0, 10, 0, 63), UDim2.new(0, 96, 0, 20), 11)
	local UIScaleMinus = makeSettingsButton("UIScaleMinus", "−", UDim2.new(0, 111, 0, 60), UDim2.new(0, 22, 0, 23))
	local UIScaleValueLabel = makeSettingsLabel("UIScaleValueLabel", "90%", UDim2.new(0, 137, 0, 62), UDim2.new(0, 48, 0, 20), 11, Enum.TextXAlignment.Center)
	local UIScalePlus = makeSettingsButton("UIScalePlus", "+", UDim2.new(0, 190, 0, 60), UDim2.new(0, 22, 0, 23))
	local ResetSettingsButton = makeSettingsButton("ResetSettingsButton", "Reset", UDim2.new(1, -72, 1, -31), UDim2.new(0, 62, 0, 23))
	SettingsButton.Activated:Connect(function()
		if IsMinimized and SetMinimized then
			SetMinimized(false)
		end
		SettingsPanel.Visible = not SettingsPanel.Visible
		if SettingsPanel.Visible then
			TweenService:Create(SettingsPanel, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.04}):Play()
		end
	end)

	LayersTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LayersTab.BackgroundTransparency = 0.9990000128746033
	LayersTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LayersTab.BorderSizePixel = 0
	LayersTab.Position = UDim2.new(0, 9, 0, 50)
	LayersTab.Size = UDim2.new(0, GuiConfig["Tab Width"], 1, -59)
	LayersTab.Name = "LayersTab"
	LayersTab.Parent = Main

	UICorner2.CornerRadius = UDim.new(0, 2)
	UICorner2.Parent = LayersTab

	DecideFrame.AnchorPoint = Vector2.new(0.5, 0)
	DecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	DecideFrame.BackgroundTransparency = 0.85
	DecideFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	DecideFrame.BorderSizePixel = 0
	DecideFrame.Position = UDim2.new(0.5, 0, 0, 38)
	DecideFrame.Size = UDim2.new(1, 0, 0, 1)
	DecideFrame.Name = "DecideFrame"
	DecideFrame.Parent = Main

	Layers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Layers.BackgroundTransparency = 0.9990000128746033
	Layers.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Layers.BorderSizePixel = 0
	Layers.Position = UDim2.new(0, GuiConfig["Tab Width"] + 18, 0, 50)
	Layers.Size = UDim2.new(1, -(GuiConfig["Tab Width"] + 9 + 18), 1, -59)
	Layers.Name = "Layers"
	Layers.Parent = Main

	UICorner6.CornerRadius = UDim.new(0, 2)
	UICorner6.Parent = Layers

	NameTab.Font = Enum.Font.GothamBold
	NameTab.Text = ""
	NameTab.TextColor3 = Color3.fromRGB(255, 255, 255)
	NameTab.TextSize = 18
	NameTab.TextWrapped = true
	NameTab.TextXAlignment = Enum.TextXAlignment.Left
	NameTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	NameTab.BackgroundTransparency = 0.9990000128746033
	NameTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
	NameTab.BorderSizePixel = 0
	NameTab.Size = UDim2.new(1, 0, 0, 30)
	NameTab.Name = "NameTab"
	NameTab.Parent = Layers

	LayersReal.AnchorPoint = Vector2.new(0, 1)
	LayersReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LayersReal.BackgroundTransparency = 0.9990000128746033
	LayersReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LayersReal.BorderSizePixel = 0
	LayersReal.ClipsDescendants = true
	LayersReal.Position = UDim2.new(0, 0, 1, 0)
	LayersReal.Size = UDim2.new(1, 0, 1, -33)
	LayersReal.Name = "LayersReal"
	LayersReal.Parent = Layers

	LayersFolder.Name = "LayersFolder"
	LayersFolder.Parent = LayersReal

	LayersPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	LayersPageLayout.Name = "LayersPageLayout"
	LayersPageLayout.Parent = LayersFolder
	LayersPageLayout.TweenTime = 0.5
	LayersPageLayout.EasingDirection = Enum.EasingDirection.InOut
	LayersPageLayout.EasingStyle = Enum.EasingStyle.Quad
	--// Layer Tabs
	local ScrollTab = Instance.new("ScrollingFrame");
	local UIListLayout = Instance.new("UIListLayout");

	ScrollTab.CanvasSize = UDim2.new(0, 0, 1.10000002, 0)
	ScrollTab.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
	ScrollTab.ScrollBarThickness = 0
	ScrollTab.Active = true
	ScrollTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ScrollTab.BackgroundTransparency = 0.9990000128746033
	ScrollTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ScrollTab.BorderSizePixel = 0
	ScrollTab.Size = UDim2.new(1, 0, 1, -50)
	ScrollTab.Name = "ScrollTab"
	ScrollTab.Parent = LayersTab

	UIListLayout.Padding = UDim.new(0, 3)
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Parent = ScrollTab

	local function UpdateSize1()
		local OffsetY = 0
		for _, child in ScrollTab:GetChildren() do
			if child.Name ~= "UIListLayout" then
				OffsetY = OffsetY + 3 + child.Size.Y.Offset
			end
		end
		ScrollTab.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
	end
	ScrollTab.ChildAdded:Connect(UpdateSize1)
	ScrollTab.ChildRemoved:Connect(UpdateSize1)

	local Info = Instance.new("Frame");
	local UICorner = Instance.new("UICorner");
	local LogoPlayerFrame = Instance.new("Frame")
	local UICorner1 = Instance.new("UICorner");
	local LogoPlayer = Instance.new("ImageLabel");
	local UICorner2 = Instance.new("UICorner");
	local NamePlayer = Instance.new("TextLabel");
		
	Info.AnchorPoint = Vector2.new(1, 1)
	Info.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Info.BackgroundTransparency = 0.95
	Info.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Info.BorderSizePixel = 0
	Info.Position = UDim2.new(1, 0, 1, 0)
	Info.Size = UDim2.new(1, 0, 0, 40)
	Info.Name = "Info"
	Info.Parent = LayersTab

	UICorner.CornerRadius = UDim.new(0, 5)
	UICorner.Parent = Info

	LogoPlayerFrame.AnchorPoint = Vector2.new(0, 0.5)
	LogoPlayerFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LogoPlayerFrame.BackgroundTransparency = 0.95
	LogoPlayerFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LogoPlayerFrame.BorderSizePixel = 0
	LogoPlayerFrame.Position = UDim2.new(0, 5, 0.5, 0)
	LogoPlayerFrame.Size = UDim2.new(0, 30, 0, 30)
	LogoPlayerFrame.Name = "LogoPlayerFrame"
	LogoPlayerFrame.Parent = Info

	UICorner1.CornerRadius = UDim.new(0, 1000)
	UICorner1.Parent = LogoPlayerFrame

	LogoPlayer.Image = GuiConfig["Logo Player"]
	LogoPlayer.AnchorPoint = Vector2.new(0.5, 0.5)
	LogoPlayer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LogoPlayer.BackgroundTransparency = 0.999
	LogoPlayer.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LogoPlayer.BorderSizePixel = 0
	LogoPlayer.Position = UDim2.new(0.5, 0, 0.5, 0)
	LogoPlayer.Size = UDim2.new(1, -5, 1, -5)
	LogoPlayer.Name = "LogoPlayer"
	LogoPlayer.Parent = LogoPlayerFrame

	UICorner2.CornerRadius = UDim.new(0, 1000)
	UICorner2.Parent = LogoPlayer

	NamePlayer.Font = Enum.Font.GothamBold
	NamePlayer.Text = GuiConfig["Name Player"]
	NamePlayer.TextColor3 = Color3.fromRGB(230.00000149011612, 230.00000149011612, 230.00000149011612)
	NamePlayer.TextSize = 10
	NamePlayer.TextWrapped = true
	NamePlayer.TextXAlignment = Enum.TextXAlignment.Left
	NamePlayer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	NamePlayer.BackgroundTransparency = 0.9990000128746033
	NamePlayer.BorderColor3 = Color3.fromRGB(0, 0, 0)
	NamePlayer.BorderSizePixel = 0
	NamePlayer.Position = UDim2.new(0, 40, 0, 0)
	NamePlayer.Size = UDim2.new(1, -45, 1, 0)
	NamePlayer.Name = "NamePlayer"
	NamePlayer.Parent = Info

	function GuiFunc:DestroyGui()
		if HirimiGui and HirimiGui.Parent then
			HirimiGui:Destroy()
		end
	end

	local OldPos = DropShadowHolder.Position
	local OldSize = DropShadowHolder.Size
	local expandedSize = DropShadowHolder.Size
	local LayersTabExpandedPosition = LayersTab.Position
	local LayersExpandedPosition = Layers.Position
	local TextScaleMin, TextScaleMax = 0.7, 1.5
	local UIScaleMin, UIScaleMax = 0.75, 1.2

	local function refreshTextScale()
		for _, object in ipairs(HirimiGui:GetDescendants()) do
			if isTextObject(object) then
				if textBaseSizes[object] == nil then
					textBaseSizes[object] = object.TextSize / math.max(textScaleValue, 0.01)
				end
				object.TextSize = math.max(8, math.floor(textBaseSizes[object] * textScaleValue + 0.5))
			end
		end
		TextScaleValueLabel.Text = tostring(math.floor(textScaleValue * 100 + 0.5)) .. "%"
	end

	local function refreshScaleLabels()
		TextScaleValueLabel.Text = tostring(math.floor(textScaleValue * 100 + 0.5)) .. "%"
		TextScaleLabel.Text = "Text size"
		UIScaleValueLabel.Text = tostring(math.floor(uiScaleValue * 100 + 0.5)) .. "%"
	end

	function GuiFunc:SetTextScale(value)
		local nextValue = tonumber(value)
		if not nextValue then return false end
		textScaleValue = math.clamp(nextValue, TextScaleMin, TextScaleMax)
		refreshTextScale()
		refreshScaleLabels()
		return true
	end

	function GuiFunc:SetUIScale(value)
		local nextValue = tonumber(value)
		if not nextValue then return false end
		uiScaleValue = math.clamp(nextValue, UIScaleMin, UIScaleMax)
		UIScaleObject.Scale = uiScaleValue
		refreshScaleLabels()
		return true
	end

	function GuiFunc:SetTheme(ThemeConfig)
		if type(ThemeConfig) ~= "table" then return false end
		-- Keep lastAccent unchanged while applying so existing objects using the old
		-- accent can be detected and replaced with the new palette color.
		for key, value in pairs(ThemeConfig) do
			if Theme[key] ~= nil and typeof(value) == "Color3" then
				Theme[key] = value
			end
		end
		GuiConfig.Color = Theme.Accent
		for _, object in ipairs(HirimiGui:GetDescendants()) do
			applyThemeToObject(object)
		end
		lastAccent = Theme.Accent
		SettingsStroke.Color = Theme.Border
		return true
	end

	SetMinimized = function(minimized)
		if IsMinimized == minimized then return end
		IsMinimized = minimized
		if minimized then
			expandedSize = DropShadowHolder.Size
			SettingsPanel.Visible = false
			TweenService:Create(DropShadowHolder, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = UDim2.new(expandedSize.X.Scale, expandedSize.X.Offset, 0, 38)
			}):Play()
			TweenService:Create(LayersTab, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Position = UDim2.new(LayersTabExpandedPosition.X.Scale, LayersTabExpandedPosition.X.Offset, LayersTabExpandedPosition.Y.Scale, LayersTabExpandedPosition.Y.Offset - 350)
			}):Play()
			TweenService:Create(Layers, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Position = UDim2.new(LayersExpandedPosition.X.Scale, LayersExpandedPosition.X.Offset, LayersExpandedPosition.Y.Scale, LayersExpandedPosition.Y.Offset - 350)
			}):Play()
		else
			TweenService:Create(DropShadowHolder, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = expandedSize}):Play()
			TweenService:Create(LayersTab, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = LayersTabExpandedPosition}):Play()
			TweenService:Create(Layers, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = LayersExpandedPosition}):Play()
		end
	end

	MaxRestore.Activated:Connect(function()
		CircleClick(MaxRestore, Mouse.X, Mouse.Y)
		if ImageLabel.Image == "rbxassetid://9886659406" then
			ImageLabel.Image = "rbxassetid://9886659001"
			OldPos = DropShadowHolder.Position
			OldSize = DropShadowHolder.Size
			TweenService:Create(DropShadowHolder, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 0)}):Play()
			TweenService:Create(DropShadowHolder, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 1, 0)}):Play()
			expandedSize = UDim2.new(1, 0, 1, 0)
		else
			ImageLabel.Image = "rbxassetid://9886659406"
			TweenService:Create(DropShadowHolder, TweenInfo.new(0.3), {Position = OldPos}):Play()
			TweenService:Create(DropShadowHolder, TweenInfo.new(0.3), {Size = OldSize}):Play()
			expandedSize = OldSize
		end
	end)
	Min.Activated:Connect(function()
		CircleClick(Min, Mouse.X, Mouse.Y)
		SetMinimized(not IsMinimized)
	end)
	Close.Activated:Connect(function()
		CircleClick(Close, Mouse.X, Mouse.Y)
		SettingsPanel.Visible = false
		DropShadowHolder.Visible = false
	end)
	function GuiFunc:ToggleUI()
		DropShadowHolder.Visible = not DropShadowHolder.Visible
		return DropShadowHolder.Visible
	end
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
			DropShadowHolder.Visible = not DropShadowHolder.Visible
		end
	end)

	TextScaleMinus.Activated:Connect(function() GuiFunc:SetTextScale(textScaleValue - 0.1) end)
	TextScalePlus.Activated:Connect(function() GuiFunc:SetTextScale(textScaleValue + 0.1) end)
	UIScaleMinus.Activated:Connect(function() GuiFunc:SetUIScale(uiScaleValue - 0.05) end)
	UIScalePlus.Activated:Connect(function() GuiFunc:SetUIScale(uiScaleValue + 0.05) end)
	ResetSettingsButton.Activated:Connect(function()
		GuiFunc:SetTextScale(1)
		GuiFunc:SetUIScale(0.9)
	end)
	refreshScaleLabels()

	local CurrentViewport = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(800, 600)
	local DesiredWidth = math.max(360, 150 + headerTitleTextWidth + headerDescriptionTextWidth)
	DesiredWidth = math.min(DesiredWidth, math.max(320, CurrentViewport.X - 24))
	DropShadowHolder.Size = UDim2.new(0, DesiredWidth, 0, 350)
	DropShadowHolder.Position = UDim2.new(0, math.max(0, (CurrentViewport.X - DesiredWidth) / 2), 0, math.max(0, (CurrentViewport.Y - 350) / 2))
	OldPos = DropShadowHolder.Position
	MakeDraggable(Top, DropShadowHolder)
	OldPos = DropShadowHolder.Position
	OldSize = DropShadowHolder.Size
	expandedSize = DropShadowHolder.Size

	-- Apply the current palette to the window itself; future descendants are themed as they are created.
	for _, object in ipairs(HirimiGui:GetDescendants()) do
		applyThemeToObject(object)
		registerTextObject(object)
	end
	--// Blur
	local MoreBlur = Instance.new("Frame");
	local DropShadowHolder1 = Instance.new("Frame");
	local DropShadow1 = Instance.new("ImageLabel");
	local UICorner28 = Instance.new("UICorner");
	local ConnectButton = Instance.new("TextButton");
	
	MoreBlur.AnchorPoint = Vector2.new(1, 1)
	MoreBlur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	MoreBlur.BackgroundTransparency = 0.999
	MoreBlur.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MoreBlur.BorderSizePixel = 0
	MoreBlur.ClipsDescendants = true
	MoreBlur.Position = UDim2.new(1, 8, 1, 8)
	MoreBlur.Size = UDim2.new(1, 154, 1, 54)
	MoreBlur.Visible = false
	MoreBlur.Name = "MoreBlur"
	MoreBlur.Parent = Layers

	DropShadowHolder1.BackgroundTransparency = 1
	DropShadowHolder1.BorderSizePixel = 0
	DropShadowHolder1.Size = UDim2.new(1, 0, 1, 0)
	DropShadowHolder1.ZIndex = 0
	DropShadowHolder1.Name = "DropShadowHolder"
	DropShadowHolder1.Parent = MoreBlur

	DropShadow1.Image = "rbxassetid://6015897843"
	DropShadow1.ImageColor3 = Color3.fromRGB(0, 0, 0)
	DropShadow1.ImageTransparency = 0.5
	DropShadow1.ScaleType = Enum.ScaleType.Slice
	DropShadow1.SliceCenter = Rect.new(49, 49, 450, 450)
	DropShadow1.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow1.BackgroundTransparency = 1
	DropShadow1.BorderSizePixel = 0
	DropShadow1.Position = UDim2.new(0.5, 0, 0.5, 0)
	DropShadow1.Size = UDim2.new(1, 35, 1, 35)
	DropShadow1.ZIndex = 0
	DropShadow1.Name = "DropShadow"
	DropShadow1.Parent = DropShadowHolder1

	UICorner28.Parent = MoreBlur

	ConnectButton.Font = Enum.Font.SourceSans
	ConnectButton.Text = ""
	ConnectButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	ConnectButton.TextSize = 14
	ConnectButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ConnectButton.BackgroundTransparency = 0.999
	ConnectButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ConnectButton.BorderSizePixel = 0
	ConnectButton.Size = UDim2.new(1, 0, 1, 0)
	ConnectButton.Name = "ConnectButton"
	ConnectButton.Parent = MoreBlur

	local DropdownSelect = Instance.new("Frame");
	local UICorner36 = Instance.new("UICorner");
	local UIStroke14 = Instance.new("UIStroke");
	local DropdownSelectReal = Instance.new("Frame");
	local DropdownFolder = Instance.new("Folder");
	local DropPageLayout = Instance.new("UIPageLayout");

	DropdownSelect.AnchorPoint = Vector2.new(1, 0.5)
	DropdownSelect.BackgroundColor3 = Color3.fromRGB(30.00000011175871, 30.00000011175871, 30.00000011175871)
	DropdownSelect.BorderColor3 = Color3.fromRGB(0, 0, 0)
	DropdownSelect.BorderSizePixel = 0
	DropdownSelect.LayoutOrder = 1
	DropdownSelect.Position = UDim2.new(1, 172, 0.5, 0)
	DropdownSelect.Size = UDim2.new(0, 160, 1, -16)
	DropdownSelect.Name = "DropdownSelect"
	DropdownSelect.ClipsDescendants = true
	DropdownSelect.Parent = MoreBlur

	ConnectButton.Activated:Connect(function()
		if MoreBlur.Visible then
			TweenService:Create(MoreBlur, TweenInfo.new(0.3), {BackgroundTransparency = 0.999}):Play()
			TweenService:Create(DropdownSelect, TweenInfo.new(0.3), {Position = UDim2.new(1, 172, 0.5, 0)}):Play()
			task.wait(0.3)
			MoreBlur.Visible = false
		end
	end)
	UICorner36.CornerRadius = UDim.new(0, 3)
	UICorner36.Parent = DropdownSelect

	UIStroke14.Color = Color3.fromRGB(255, 255, 255)
	UIStroke14.Thickness = 2.5
	UIStroke14.Transparency = 0.8
	UIStroke14.Parent = DropdownSelect

	DropdownSelectReal.AnchorPoint = Vector2.new(0.5, 0.5)
	DropdownSelectReal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	DropdownSelectReal.BackgroundTransparency = 0.9990000128746033
	DropdownSelectReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
	DropdownSelectReal.BorderSizePixel = 0
	DropdownSelectReal.LayoutOrder = 1
	DropdownSelectReal.Position = UDim2.new(0.5, 0, 0.5, 0)
	DropdownSelectReal.Size = UDim2.new(1, -10, 1, -10)
	DropdownSelectReal.Name = "DropdownSelectReal"
	DropdownSelectReal.Parent = DropdownSelect

	DropdownFolder.Name = "DropdownFolder"
	DropdownFolder.Parent = DropdownSelectReal

	DropPageLayout.EasingDirection = Enum.EasingDirection.InOut
	DropPageLayout.EasingStyle = Enum.EasingStyle.Quad
	DropPageLayout.TweenTime = 0.009999999776482582
	DropPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	DropPageLayout.Archivable = false
	DropPageLayout.Name = "DropPageLayout"
	DropPageLayout.Parent = DropdownFolder
	--// Tabs
	local Tabs = GuiFunc
	local CountTab = 0
	local CountDropdown = 0
	function Tabs:CreateTab(TabConfig)
		local TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or ""

		local ScrolLayers = Instance.new("ScrollingFrame");
		local UIListLayout1 = Instance.new("UIListLayout");

		ScrolLayers.ScrollBarImageColor3 = Color3.fromRGB(80.00000283122063, 80.00000283122063, 80.00000283122063)
		ScrolLayers.ScrollBarThickness = 0
		ScrolLayers.Active = true
		ScrolLayers.LayoutOrder = CountTab
		ScrolLayers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ScrolLayers.BackgroundTransparency = 0.9990000128746033
		ScrolLayers.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ScrolLayers.BorderSizePixel = 0
		ScrolLayers.Size = UDim2.new(1, 0, 1, 0)
		ScrolLayers.Name = "ScrolLayers"
		ScrolLayers.Parent = LayersFolder

		UIListLayout1.Padding = UDim.new(0, 3)
		UIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout1.Parent = ScrolLayers

		local Tab = Instance.new("Frame");
		local UICorner3 = Instance.new("UICorner");
		local TabButton = Instance.new("TextButton");
		local TabName = Instance.new("TextLabel")
		local FeatureImg = Instance.new("ImageLabel");
		local UIStroke2 = Instance.new("UIStroke");
		local UICorner4 = Instance.new("UICorner");

		Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		if CountTab == 0 then
			Tab.BackgroundTransparency = 0.9200000166893005
		else
			Tab.BackgroundTransparency = 0.9990000128746033
		end
		Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Tab.BorderSizePixel = 0
		Tab.LayoutOrder = CountTab
		Tab.Size = UDim2.new(1, 0, 0, 30)
		Tab.Name = "Tab"
		Tab.Parent = ScrollTab

		UICorner3.CornerRadius = UDim.new(0, 4)
		UICorner3.Parent = Tab

		TabButton.Font = Enum.Font.GothamBold
		TabButton.Text = ""
		TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabButton.TextSize = 13
		TabButton.TextXAlignment = Enum.TextXAlignment.Left
		TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabButton.BackgroundTransparency = 0.9990000128746033
		TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabButton.BorderSizePixel = 0
		TabButton.Size = UDim2.new(1, 0, 1, 0)
		TabButton.Name = "TabButton"
		TabButton.Parent = Tab

		TabName.Font = Enum.Font.GothamBold
		TabName.Text = TabConfig.Name
		TabName.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabName.TextSize = 13
		TabName.TextXAlignment = Enum.TextXAlignment.Left
		TabName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabName.BackgroundTransparency = 0.9990000128746033
		TabName.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabName.BorderSizePixel = 0
		TabName.Size = UDim2.new(1, 0, 1, 0)
		TabName.Position = UDim2.new(0, 30, 0, 0)
		TabName.Name = "TabName"
		TabName.Parent = Tab

		FeatureImg.Image = TabConfig.Icon
		FeatureImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		FeatureImg.BackgroundTransparency = 0.9990000128746033
		FeatureImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
		FeatureImg.BorderSizePixel = 0
		FeatureImg.Position = UDim2.new(0, 9, 0, 7)
		FeatureImg.Size = UDim2.new(0, 16, 0, 16)
		FeatureImg.Name = "FeatureImg"
		FeatureImg.Parent = Tab
		if CountTab == 0 then
			LayersPageLayout:JumpToIndex(0)
			NameTab.Text = TabConfig.Name
			local ChooseFrame = Instance.new("Frame");
			ChooseFrame.BackgroundColor3 = GuiConfig.Color
			ChooseFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ChooseFrame.BorderSizePixel = 0
			ChooseFrame.Position = UDim2.new(0, 2, 0, 9)
			ChooseFrame.Size = UDim2.new(0, 1, 0, 12)
			ChooseFrame.Name = "ChooseFrame"
			ChooseFrame.Parent = Tab

			UIStroke2.Color = GuiConfig.Color
			UIStroke2.Thickness = 1.600000023841858
			UIStroke2.Parent = ChooseFrame

			UICorner4.Parent = ChooseFrame
		end
		TabButton.Activated:Connect(function()
			CircleClick(TabButton, Mouse.X, Mouse.Y)
			local FrameChoose
			for a, s in ScrollTab:GetChildren() do
				for i, v in s:GetChildren() do
					if v.Name == "ChooseFrame" then
						FrameChoose = v
						break
					end
				end
			end
			if FrameChoose ~= nil and Tab.LayoutOrder ~= LayersPageLayout.CurrentPage.LayoutOrder then
				for _, TabFrame in ScrollTab:GetChildren() do
					if TabFrame.Name == "Tab" then
						TweenService:Create(
							TabFrame,
							TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
							{BackgroundTransparency = 0.9990000128746033}
						):Play()
					end    
				end
				TweenService:Create(
					Tab,
					TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
					{BackgroundTransparency = 0.9200000166893005}
				):Play()
				TweenService:Create(
					FrameChoose,
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{Position = UDim2.new(0, 2, 0, 9 + (33 * Tab.LayoutOrder))}
				):Play()
				LayersPageLayout:JumpToIndex(Tab.LayoutOrder)
				task.wait(0.05)
				NameTab.Text = TabConfig.Name
				TweenService:Create(
					FrameChoose,
					TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{Size = UDim2.new(0, 1, 0, 20)}
				):Play()
				task.wait(0.2)
				TweenService:Create(
					FrameChoose,
					TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{Size = UDim2.new(0, 1, 0, 12)}
				):Play()
			end
		end)
		--// Section 
		local Sections = {}
		local CountSection = 0
		function Sections:AddSection(Title)
			local Title = Title or "Title"
			local Section = Instance.new("Frame");
			local SectionDecideFrame = Instance.new("Frame");
			local UICorner1 = Instance.new("UICorner");
			local UIGradient = Instance.new("UIGradient");

			Section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Section.BackgroundTransparency = 0.9990000128746033
			Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Section.BorderSizePixel = 0
			Section.LayoutOrder = CountSection
			Section.ClipsDescendants = true
			Section.LayoutOrder = 1
			Section.Size = UDim2.new(1, 0, 0, 30)
			Section.Name = "Section"
			Section.Parent = ScrolLayers

			local SectionReal = Instance.new("Frame");
			local UICorner = Instance.new("UICorner");
			local UIStroke = Instance.new("UIStroke");
			local SectionButton = Instance.new("TextButton");
			local FeatureFrame = Instance.new("Frame");
			local FeatureImg = Instance.new("ImageLabel");
			local SectionTitle = Instance.new("TextLabel");

			SectionReal.AnchorPoint = Vector2.new(0.5, 0)
			SectionReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionReal.BackgroundTransparency = 0.9350000023841858
			SectionReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SectionReal.BorderSizePixel = 0
			SectionReal.LayoutOrder = 1
			SectionReal.Position = UDim2.new(0.5, 0, 0, 0)
			SectionReal.Size = UDim2.new(1, 1, 0, 30)
			SectionReal.Name = "SectionReal"
			SectionReal.Parent = Section

			UICorner.CornerRadius = UDim.new(0, 4)
			UICorner.Parent = SectionReal

			SectionButton.Font = Enum.Font.SourceSans
			SectionButton.Text = ""
			SectionButton.TextColor3 = Color3.fromRGB(0, 0, 0)
			SectionButton.TextSize = 14
			SectionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionButton.BackgroundTransparency = 0.9990000128746033
			SectionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SectionButton.BorderSizePixel = 0
			SectionButton.Size = UDim2.new(1, 0, 1, 0)
			SectionButton.Name = "SectionButton"
			SectionButton.Parent = SectionReal

			FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
			FeatureFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			FeatureFrame.BackgroundTransparency = 0.9990000128746033
			FeatureFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			FeatureFrame.BorderSizePixel = 0
			FeatureFrame.Position = UDim2.new(1, -5, 0.5, 0)
			FeatureFrame.Size = UDim2.new(0, 20, 0, 20)
			FeatureFrame.Name = "FeatureFrame"
			FeatureFrame.Parent = SectionReal

			FeatureImg.Image = "rbxassetid://16851841101"
			FeatureImg.AnchorPoint = Vector2.new(0.5, 0.5)
			FeatureImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			FeatureImg.BackgroundTransparency = 0.9990000128746033
			FeatureImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
			FeatureImg.BorderSizePixel = 0
			FeatureImg.Position = UDim2.new(0.5, 0, 0.5, 0)
			FeatureImg.Rotation = -90
			FeatureImg.Size = UDim2.new(1, 6, 1, 6)
			FeatureImg.Name = "FeatureImg"
			FeatureImg.Parent = FeatureFrame

			SectionTitle.Font = Enum.Font.GothamBold
			SectionTitle.Text = Title
			SectionTitle.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
			SectionTitle.TextSize = 13
			SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
			SectionTitle.TextYAlignment = Enum.TextYAlignment.Top
			SectionTitle.AnchorPoint = Vector2.new(0, 0.5)
			SectionTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionTitle.BackgroundTransparency = 0.9990000128746033
			SectionTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SectionTitle.BorderSizePixel = 0
			SectionTitle.Position = UDim2.new(0, 10, 0.5, 0)
			SectionTitle.Size = UDim2.new(1, -50, 0, 13)
			SectionTitle.Name = "SectionTitle"
			SectionTitle.Parent = SectionReal

			SectionDecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionDecideFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SectionDecideFrame.AnchorPoint = Vector2.new(0.5, 0)
			SectionDecideFrame.BorderSizePixel = 0
			SectionDecideFrame.Position = UDim2.new(0.5, 0, 0, 33)
			SectionDecideFrame.Size = UDim2.new(0, 0, 0, 2)
			SectionDecideFrame.Name = "SectionDecideFrame"
			SectionDecideFrame.Parent = Section

			UICorner1.Parent = SectionDecideFrame

			UIGradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
				ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
			}
			UIGradient.Parent = SectionDecideFrame
			--// Section Add
			local SectionAdd = Instance.new("Frame");
			local UICorner8 = Instance.new("UICorner");
			local UIListLayout2 = Instance.new("UIListLayout");

			SectionAdd.AnchorPoint = Vector2.new(0.5, 0)
			SectionAdd.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionAdd.BackgroundTransparency = 0.9990000128746033
			SectionAdd.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SectionAdd.BorderSizePixel = 0
			SectionAdd.ClipsDescendants = true
			SectionAdd.LayoutOrder = 1
			SectionAdd.Position = UDim2.new(0.5, 0, 0, 38)
			SectionAdd.Size = UDim2.new(1, 0, 0, 100)
			SectionAdd.Name = "SectionAdd"
			SectionAdd.Parent = Section

			UICorner8.CornerRadius = UDim.new(0, 2)
			UICorner8.Parent = SectionAdd

			UIListLayout2.Padding = UDim.new(0, 3)
			UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout2.Parent = SectionAdd
			local OpenSection = true
			local function UpdateSizeScroll()
				local OffsetY = 0
				for _, child in ScrolLayers:GetChildren() do
					if child.Name ~= "UIListLayout" then
						OffsetY = OffsetY + 3 + child.Size.Y.Offset
					end
				end
				ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
			end
			local function UpdateSizeSection()
				if OpenSection then
					local SectionSizeYWitdh = 38
					for i, v in SectionAdd:GetChildren() do
						if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" then
							SectionSizeYWitdh = SectionSizeYWitdh + v.Size.Y.Offset + 3
						end
					end
					TweenService:Create(FeatureFrame, TweenInfo.new(0.5), {Rotation = 90}):Play()
					TweenService:Create(Section, TweenInfo.new(0.5), {Size = UDim2.new(1, 1, 0, SectionSizeYWitdh)}):Play()
					TweenService:Create(SectionAdd, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, 0, SectionSizeYWitdh - 38)}):Play()
					TweenService:Create(SectionDecideFrame, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, 0, 2)}):Play()
					task.wait(0.5)
					UpdateSizeScroll()
				end
			end
			SectionButton.Activated:Connect(function()
				CircleClick(SectionButton, Mouse.X, Mouse.Y)
				if OpenSection then
					TweenService:Create(FeatureFrame, TweenInfo.new(0.5), {Rotation = 0}):Play()
					TweenService:Create(Section, TweenInfo.new(0.5), {Size = UDim2.new(1, 1, 0, 30)}):Play()
					TweenService:Create(SectionDecideFrame, TweenInfo.new(0.5), {Size = UDim2.new(0, 0, 0, 2)}):Play()
					OpenSection = false
					task.wait(0.5)
					UpdateSizeScroll()
				else
					OpenSection = true
					UpdateSizeSection()
				end
			end)
			SectionAdd.ChildAdded:Connect(UpdateSizeSection)
			SectionAdd.ChildRemoved:Connect(UpdateSizeSection)
			UpdateSizeScroll()
			
			local Items = {}
			local CountItem = 0
			function Items:AddParagraph(ParagraphConfig)
				local ParagraphConfig = ParagraphConfig or {}
				ParagraphConfig.Title = ParagraphConfig.Title or "Title"
				ParagraphConfig.Content = ParagraphConfig.Content or "Content"
				local ParagraphFunc = {}
				
				local Paragraph = Instance.new("Frame");
				local UICorner14 = Instance.new("UICorner");
				local ParagraphTitle = Instance.new("TextLabel");
				local ParagraphContent = Instance.new("TextLabel");

				Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Paragraph.BackgroundTransparency = 0.9350000023841858
				Paragraph.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Paragraph.BorderSizePixel = 0
				Paragraph.LayoutOrder = CountItem
				Paragraph.Size = UDim2.new(1, 0, 0, 46)
				Paragraph.Name = "Paragraph"
				Paragraph.Parent = SectionAdd

				UICorner14.CornerRadius = UDim.new(0, 4)
				UICorner14.Parent = Paragraph

				ParagraphTitle.Font = Enum.Font.GothamBold
				ParagraphTitle.Text = ParagraphConfig.Title
				ParagraphTitle.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
				ParagraphTitle.TextSize = 13
				ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
				ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
				ParagraphTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ParagraphTitle.BackgroundTransparency = 0.9990000128746033
				ParagraphTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ParagraphTitle.BorderSizePixel = 0
				ParagraphTitle.Position = UDim2.new(0, 10, 0, 10)
				ParagraphTitle.Size = UDim2.new(1, -16, 0, 13)
				ParagraphTitle.Name = "ParagraphTitle"
				ParagraphTitle.Parent = Paragraph

				ParagraphContent.Font = Enum.Font.GothamBold
				ParagraphContent.Text = ParagraphConfig.Content
				ParagraphContent.TextColor3 = Color3.fromRGB(255, 255, 255)
				ParagraphContent.TextSize = 12
				ParagraphContent.TextTransparency = 0.6000000238418579
				ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
				ParagraphContent.TextYAlignment = Enum.TextYAlignment.Bottom
				ParagraphContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ParagraphContent.BackgroundTransparency = 0.9990000128746033
				ParagraphContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ParagraphContent.BorderSizePixel = 0
				ParagraphContent.Position = UDim2.new(0, 10, 0, 23)
				ParagraphContent.Name = "ParagraphContent"
				ParagraphContent.Parent = Paragraph

				local refreshParagraphHeight = BindWrappedText(ParagraphContent, Paragraph, 10, 12, 44, 9, UpdateSizeSection)

				function ParagraphFunc:Set(ParagraphConfig)
					ParagraphConfig = ParagraphConfig or {}
					ParagraphConfig.Title = ParagraphConfig.Title or "Title"
					ParagraphConfig.Content = ParagraphConfig.Content or "Content"
					ParagraphTitle.Text = tostring(ParagraphConfig.Title)
					ParagraphContent.Text = tostring(ParagraphConfig.Content)
					refreshParagraphHeight()
				end
				CountItem = CountItem + 1
				return ParagraphFunc
			end
			function Items:AddButton(ButtonConfig)
				local ButtonConfig = ButtonConfig or {}
				ButtonConfig.Title = ButtonConfig.Title or "Title"
				ButtonConfig.Content = ButtonConfig.Content or "Content"
				ButtonConfig.Icon = ButtonConfig.Icon or "rbxassetid://16932740082"
				ButtonConfig.Callback = ButtonConfig.Callback or function() end
				local ButtonFunc = {}

				local Button = Instance.new("Frame");
				local UICorner9 = Instance.new("UICorner");
				local ButtonTitle = Instance.new("TextLabel");
				local ButtonContent = Instance.new("TextLabel");
				local ButtonButton = Instance.new("TextButton");
				local FeatureFrame1 = Instance.new("Frame");
				local FeatureImg3 = Instance.new("ImageLabel");

				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Button.BackgroundTransparency = 0.9350000023841858
				Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Button.BorderSizePixel = 0
				Button.LayoutOrder = CountItem
				Button.Size = UDim2.new(1, 0, 0, 46)
				Button.Name = "Button"
				Button.Parent = SectionAdd

				UICorner9.CornerRadius = UDim.new(0, 4)
				UICorner9.Parent = Button

				ButtonTitle.Font = Enum.Font.GothamBold
				ButtonTitle.Text = ButtonConfig.Title
				ButtonTitle.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
				ButtonTitle.TextSize = 13
				ButtonTitle.TextXAlignment = Enum.TextXAlignment.Left
				ButtonTitle.TextYAlignment = Enum.TextYAlignment.Top
				ButtonTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ButtonTitle.BackgroundTransparency = 0.9990000128746033
				ButtonTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ButtonTitle.BorderSizePixel = 0
				ButtonTitle.Position = UDim2.new(0, 10, 0, 10)
				ButtonTitle.Size = UDim2.new(1, -65, 0, 13)
				ButtonTitle.Name = "ButtonTitle"
				ButtonTitle.Parent = Button

				ButtonContent.Font = Enum.Font.GothamBold
				ButtonContent.Text = ButtonConfig.Content
				ButtonContent.TextColor3 = Color3.fromRGB(255, 255, 255)
				ButtonContent.TextSize = 12
				ButtonContent.TextTransparency = 0.6000000238418579
				ButtonContent.TextXAlignment = Enum.TextXAlignment.Left
				ButtonContent.TextYAlignment = Enum.TextYAlignment.Bottom
				ButtonContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ButtonContent.BackgroundTransparency = 0.9990000128746033
				ButtonContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ButtonContent.BorderSizePixel = 0
				ButtonContent.Position = UDim2.new(0, 10, 0, 23)
				ButtonContent.Name = "ButtonContent"
				ButtonContent.Parent = Button
				ButtonContent.Size = UDim2.new(1, -65, 0, 12)
				local refreshButtonHeight = BindWrappedText(ButtonContent, Button, 55, 12, 44, 9, UpdateSizeSection)

				ButtonButton.Font = Enum.Font.SourceSans
				ButtonButton.Text = ""
				ButtonButton.TextColor3 = Color3.fromRGB(0, 0, 0)
				ButtonButton.TextSize = 14
				ButtonButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				ButtonButton.BackgroundTransparency = 0.9990000128746033
				ButtonButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ButtonButton.BorderSizePixel = 0
				ButtonButton.Size = UDim2.new(1, 0, 1, 0)
				ButtonButton.Name = "ButtonButton"
				ButtonButton.Parent = Button

				FeatureFrame1.AnchorPoint = Vector2.new(1, 0.5)
				FeatureFrame1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				FeatureFrame1.BackgroundTransparency = 0.9990000128746033
				FeatureFrame1.BorderColor3 = Color3.fromRGB(0, 0, 0)
				FeatureFrame1.BorderSizePixel = 0
				FeatureFrame1.Position = UDim2.new(1, -15, 0.5, 0)
				FeatureFrame1.Size = UDim2.new(0, 25, 0, 25)
				FeatureFrame1.Name = "FeatureFrame"
				FeatureFrame1.Parent = Button

				FeatureImg3.Image = ButtonConfig.Icon
				FeatureImg3.AnchorPoint = Vector2.new(0.5, 0.5)
				FeatureImg3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				FeatureImg3.BackgroundTransparency = 0.9990000128746033
				FeatureImg3.BorderColor3 = Color3.fromRGB(0, 0, 0)
				FeatureImg3.BorderSizePixel = 0
				FeatureImg3.Position = UDim2.new(0.5, 0, 0.5, 0)
				FeatureImg3.Size = UDim2.new(1, 0, 1, 0)
				FeatureImg3.Name = "FeatureImg"
				FeatureImg3.Parent = FeatureFrame1

				ButtonButton.Activated:Connect(function()
					CircleClick(ButtonButton, Mouse.X, Mouse.Y)
					ButtonConfig.Callback()
				end)
				CountItem = CountItem + 1
				return ButtonFunc
			end
			function Items:AddToggle(ToggleConfig)
				local ToggleConfig = ToggleConfig or {}
				ToggleConfig.Title = ToggleConfig.Title or "Title"
				ToggleConfig.Content = ToggleConfig.Content or "Content"
				ToggleConfig.Default = ToggleConfig.Default or false
				ToggleConfig.Callback = ToggleConfig.Callback or function() end
				local ToggleFunc = {Value = ToggleConfig.Default, Options = ToggleConfig.Options, Selecting = ToggleConfig.Selecting}

				local Toggle = Instance.new("Frame");
				local UICorner20 = Instance.new("UICorner");
				local ToggleTitle = Instance.new("TextLabel");
				local ToggleContent = Instance.new("TextLabel");
				local ToggleButton = Instance.new("TextButton");
				local Frame = Instance.new("Frame");
				local ImageLabel3 = Instance.new("ImageLabel");
				local UICorner21 = Instance.new("UICorner");
				local TextButton = Instance.new("TextButton");
				local FeatureFrame2 = Instance.new("Frame");
				local UICorner22 = Instance.new("UICorner");
				local UIStroke8 = Instance.new("UIStroke");
				local ToggleCircle = Instance.new("Frame");
				local UICorner23 = Instance.new("UICorner");

				Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Toggle.BackgroundTransparency = 0.9350000023841858
				Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Toggle.BorderSizePixel = 0
				Toggle.LayoutOrder = CountItem
				Toggle.Size = UDim2.new(1, 0, 0, 46)
				Toggle.Name = "Toggle"
				Toggle.Parent = SectionAdd

				UICorner20.CornerRadius = UDim.new(0, 4)
				UICorner20.Parent = Toggle

				ToggleTitle.Font = Enum.Font.GothamBold
				ToggleTitle.Text = ToggleConfig.Title
				ToggleTitle.TextSize = 13
				ToggleTitle.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
				ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
				ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
				ToggleTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ToggleTitle.BackgroundTransparency = 0.9990000128746033
				ToggleTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ToggleTitle.BorderSizePixel = 0
				ToggleTitle.Position = UDim2.new(0, 10, 0, 10)
				ToggleTitle.Size = UDim2.new(1, -82, 0, 13)
				ToggleTitle.Name = "ToggleTitle"
				ToggleTitle.Parent = Toggle

				ToggleContent.Font = Enum.Font.GothamBold
				ToggleContent.Text = ToggleConfig.Content
				ToggleContent.TextColor3 = Color3.fromRGB(255, 255, 255)
				ToggleContent.TextSize = 12
				ToggleContent.TextTransparency = 0.6000000238418579
				ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
				ToggleContent.TextYAlignment = Enum.TextYAlignment.Bottom
				ToggleContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ToggleContent.BackgroundTransparency = 0.9990000128746033
				ToggleContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ToggleContent.BorderSizePixel = 0
				ToggleContent.Position = UDim2.new(0, 10, 0, 23)
				ToggleContent.Size = UDim2.new(1, -82, 0, 12)
				ToggleContent.Name = "ToggleContent"
				ToggleContent.Parent = Toggle
				local refreshToggleHeight = BindWrappedText(ToggleContent, Toggle, 72, 12, 44, 9, UpdateSizeSection)

				ToggleButton.Font = Enum.Font.SourceSans
				ToggleButton.Text = ""
				ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
				ToggleButton.TextSize = 14
				ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				ToggleButton.BackgroundTransparency = 0.9990000128746033
				ToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ToggleButton.BorderSizePixel = 0
				ToggleButton.Size = UDim2.new(1, 0, 1, 0)
				ToggleButton.Name = "ToggleButton"
				ToggleButton.Parent = Toggle

				FeatureFrame2.AnchorPoint = Vector2.new(1, 0.5)
				FeatureFrame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				FeatureFrame2.BackgroundTransparency = 0.9200000166893005
				FeatureFrame2.BorderColor3 = Color3.fromRGB(0, 0, 0)
				FeatureFrame2.BorderSizePixel = 0
				FeatureFrame2.Position = UDim2.new(1, -30, 0.5, 0)
				FeatureFrame2.Size = UDim2.new(0, 30, 0, 15)
				FeatureFrame2.Name = "FeatureFrame"
				FeatureFrame2.Parent = Toggle

				UICorner22.Parent = FeatureFrame2

				UIStroke8.Color = Color3.fromRGB(255, 255, 255)
				UIStroke8.Thickness = 2
				UIStroke8.Transparency = 0.9
				UIStroke8.Parent = FeatureFrame2

				ToggleCircle.BackgroundColor3 = Color3.fromRGB(230.00000149011612, 230.00000149011612, 230.00000149011612)
				ToggleCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ToggleCircle.BorderSizePixel = 0
				ToggleCircle.Position = UDim2.new(0, 0, 0, 0)
				ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
				ToggleCircle.Name = "ToggleCircle"
				ToggleCircle.Parent = FeatureFrame2

				UICorner23.CornerRadius = UDim.new(0, 15)
				UICorner23.Parent = ToggleCircle
				
				ToggleButton.Activated:Connect(function()
					CircleClick(ToggleButton, Mouse.X, Mouse.Y) 
					ToggleFunc.Value = not ToggleFunc.Value
					ToggleFunc:Set(ToggleFunc.Value)
				end)
				function ToggleFunc:Set(Value)
					ToggleFunc.Value = not not Value
					Value = ToggleFunc.Value
					ToggleConfig.Callback(Value)
					if Value then
						TweenService:Create(
							ToggleTitle,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{TextColor3 = GuiConfig.Color}
						):Play()
						TweenService:Create(
							ToggleCircle,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{Position = UDim2.new(0, 15, 0, 0)}
						):Play()
						TweenService:Create(
							UIStroke8,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{Color = GuiConfig.Color, Transparency = 0}
						):Play()
						TweenService:Create(
							FeatureFrame2,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{BackgroundColor3 = GuiConfig.Color, BackgroundTransparency = 0} 
						):Play()
					else
						TweenService:Create(
							ToggleTitle,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)}
						):Play()
						TweenService:Create(
							ToggleCircle,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{Position = UDim2.new(0, 0, 0, 0)}
						):Play()
						TweenService:Create(
							UIStroke8,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9}
						):Play()
						TweenService:Create(
							FeatureFrame2,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.9200000166893005}
						):Play()
					end
				end
				ToggleFunc:Set(ToggleFunc.Value)
				CountItem = CountItem + 1
				return ToggleFunc
			end
			function Items:AddSlider(SliderConfig)
				SliderConfig = SliderConfig or {}
				SliderConfig.Title = SliderConfig.Title or "Slider"
				SliderConfig.Content = SliderConfig.Content or "Content"
				SliderConfig.Increment = tonumber(SliderConfig.Increment) or 1
				if SliderConfig.Increment <= 0 then SliderConfig.Increment = 1 end
				SliderConfig.Min = tonumber(SliderConfig.Min) or 0
				SliderConfig.Max = tonumber(SliderConfig.Max) or 100
				if SliderConfig.Max < SliderConfig.Min then
					SliderConfig.Min, SliderConfig.Max = SliderConfig.Max, SliderConfig.Min
				end
				if SliderConfig.Default == nil then SliderConfig.Default = 50 end
				SliderConfig.Default = tonumber(SliderConfig.Default) or SliderConfig.Min
				SliderConfig.Callback = SliderConfig.Callback or function() end
				local SliderFunc = {Value = SliderConfig.Min}

				local Slider = Instance.new("Frame")
				local UICorner15 = Instance.new("UICorner")
				local SliderTitle = Instance.new("TextLabel")
				local SliderContent = Instance.new("TextLabel")
				local SliderInput = Instance.new("Frame")
				local UICorner16 = Instance.new("UICorner")
				local TextBox = Instance.new("TextBox")
				local SliderFrame = Instance.new("Frame")
				local UICorner17 = Instance.new("UICorner")
				local SliderDraggable = Instance.new("Frame")
				local UICorner18 = Instance.new("UICorner")
				local SliderCircle = Instance.new("Frame")
				local UICorner19 = Instance.new("UICorner")
				local UIStroke6 = Instance.new("UIStroke")

				Slider.BackgroundColor3 = Theme.Surface
				Slider.BackgroundTransparency = 0.935
				Slider.BorderSizePixel = 0
				Slider.LayoutOrder = CountItem
				Slider.Size = UDim2.new(1, 0, 0, 68)
				Slider.Name = "Slider"
				Slider.Parent = SectionAdd
				UICorner15.CornerRadius = UDim.new(0, 4)
				UICorner15.Parent = Slider

				SliderTitle.Font = Enum.Font.GothamBold
				SliderTitle.Text = tostring(SliderConfig.Title)
				SliderTitle.TextColor3 = Theme.Text
				SliderTitle.TextSize = 12
				SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
				SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
				SliderTitle.BackgroundTransparency = 1
				SliderTitle.BorderSizePixel = 0
				SliderTitle.Position = UDim2.new(0, 9, 0, 7)
				SliderTitle.Size = UDim2.new(1, -18, 0, 14)
				SliderTitle.Name = "SliderTitle"
				SliderTitle.Parent = Slider

				SliderContent.Font = Enum.Font.Gotham
				SliderContent.Text = tostring(SliderConfig.Content)
				SliderContent.TextColor3 = Theme.MutedText
				SliderContent.TextSize = 11
				SliderContent.TextTransparency = 0.2
				SliderContent.TextXAlignment = Enum.TextXAlignment.Left
				SliderContent.TextYAlignment = Enum.TextYAlignment.Top
				SliderContent.TextWrapped = true
				SliderContent.BackgroundTransparency = 1
				SliderContent.BorderSizePixel = 0
				SliderContent.Position = UDim2.new(0, 9, 0, 23)
				SliderContent.Size = UDim2.new(1, -18, 0, 14)
				SliderContent.Name = "SliderContent"
				SliderContent.Parent = Slider

				local function updateSliderDescriptionHeight()
					local parentWidth = Slider.AbsoluteSize.X
					if parentWidth <= 0 then return end
					local textWidth = math.max(40, parentWidth - 18)
					local measured = TextService:GetTextSize(tostring(SliderContent.Text or ""), SliderContent.TextSize, SliderContent.Font, Vector2.new(textWidth, 10000))
					local contentHeight = math.max(13, math.ceil(measured.Y))
					SliderContent.Size = UDim2.new(1, -18, 0, contentHeight)
					local wantedHeight = math.max(68, SliderContent.Position.Y.Offset + contentHeight + 28)
					if Slider.Size.Y.Scale ~= 0 or Slider.Size.Y.Offset ~= wantedHeight then
						Slider.Size = UDim2.new(1, 0, 0, wantedHeight)
						UpdateSizeSection()
					end
				end
				Slider:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSliderDescriptionHeight)
				SliderContent:GetPropertyChangedSignal("Text"):Connect(updateSliderDescriptionHeight)
				task.defer(updateSliderDescriptionHeight)

				SliderInput.AnchorPoint = Vector2.new(1, 1)
				SliderInput.BackgroundColor3 = GuiConfig.Color
				SliderInput.BorderSizePixel = 0
				SliderInput.Position = UDim2.new(1, -8, 1, -5)
				SliderInput.Size = UDim2.new(0, 64, 0, 22)
				SliderInput.Name = "SliderInput"
				SliderInput.Parent = Slider
				UICorner16.CornerRadius = UDim.new(0, 4)
				UICorner16.Parent = SliderInput

				TextBox.Font = Enum.Font.GothamBold
				TextBox.Text = ""
				TextBox.TextColor3 = Theme.Text
				TextBox.TextSize = 10
				TextBox.TextWrapped = false
				TextBox.TextXAlignment = Enum.TextXAlignment.Center
				TextBox.ClearTextOnFocus = false
				TextBox.BackgroundTransparency = 1
				TextBox.BorderSizePixel = 0
				TextBox.Size = UDim2.new(1, -4, 1, 0)
				TextBox.Position = UDim2.new(0, 2, 0, 0)
				TextBox.ZIndex = 2
				TextBox.Parent = SliderInput

				SliderFrame.AnchorPoint = Vector2.new(0, 1)
				SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				SliderFrame.BackgroundTransparency = 0.78
				SliderFrame.BorderSizePixel = 0
				SliderFrame.Position = UDim2.new(0, 9, 1, -14)
				SliderFrame.Size = UDim2.new(1, -90, 0, 4)
				SliderFrame.Name = "SliderFrame"
				SliderFrame.Active = true
				SliderFrame.Parent = Slider
				UICorner17.Parent = SliderFrame

				SliderDraggable.AnchorPoint = Vector2.new(0, 0.5)
				SliderDraggable.BackgroundColor3 = GuiConfig.Color
				SliderDraggable.BorderSizePixel = 0
				SliderDraggable.Position = UDim2.new(0, 0, 0.5, 0)
				SliderDraggable.Size = UDim2.new(0, 0, 0, 2)
				SliderDraggable.Name = "SliderDraggable"
				SliderDraggable.Active = true
				SliderDraggable.Parent = SliderFrame
				UICorner18.Parent = SliderDraggable

				SliderCircle.AnchorPoint = Vector2.new(0.5, 0.5)
				SliderCircle.BackgroundColor3 = GuiConfig.Color
				SliderCircle.BorderSizePixel = 0
				SliderCircle.Position = UDim2.new(1, 0, 0.5, 0)
				SliderCircle.Size = UDim2.new(0, 9, 0, 9)
				SliderCircle.Name = "SliderCircle"
				SliderCircle.Active = true
				SliderCircle.Parent = SliderDraggable
				UICorner19.Parent = SliderCircle
				UIStroke6.Color = GuiConfig.Color
				UIStroke6.Parent = SliderCircle

				local function countDecimals(number)
					local formatted = string.format("%.8f", number):gsub("0+$", ""):gsub("%.$", "")
					local decimalPart = string.match(formatted, "%.(%d+)$")
					return decimalPart and #decimalPart or 0
				end
				local decimalPlaces = math.max(countDecimals(SliderConfig.Increment), countDecimals(SliderConfig.Min), countDecimals(SliderConfig.Max))
				local function formatNumber(value)
					if decimalPlaces > 0 then
						return string.format("%." .. tostring(decimalPlaces) .. "f", value)
					end
					return tostring(math.floor(value + 0.5))
				end
				local function roundToIncrement(value)
					if value <= SliderConfig.Min then return SliderConfig.Min end
					if value >= SliderConfig.Max then return SliderConfig.Max end
					return SliderConfig.Min + math.floor(((value - SliderConfig.Min) / SliderConfig.Increment) + 0.5) * SliderConfig.Increment
				end
				local dragging = false
				local activeTouch = nil
				local function updateSliderFromX(x, fromDrag)
					local width = SliderFrame.AbsoluteSize.X
					if width <= 0 or SliderConfig.Max == SliderConfig.Min then return end
					local ratio = math.clamp((x - SliderFrame.AbsolutePosition.X) / width, 0, 1)
					local value = SliderConfig.Min + (SliderConfig.Max - SliderConfig.Min) * ratio
					SliderFunc:Set(value, true, fromDrag)
				end

				function SliderFunc:Set(Value, SkipCallback, IsDragging)
					Value = tonumber(Value)
					if not Value then return false end
					Value = math.clamp(roundToIncrement(Value), SliderConfig.Min, SliderConfig.Max)
					-- Avoid floating-point tails such as 0.30000000004 in callbacks and labels.
					if decimalPlaces > 0 then Value = tonumber(string.format("%." .. tostring(decimalPlaces) .. "f", Value)) end
					SliderFunc.Value = Value
					TextBox.Text = formatNumber(Value)
					local span = SliderConfig.Max - SliderConfig.Min
					local ratio = span == 0 and 0 or math.clamp((Value - SliderConfig.Min) / span, 0, 1)
					local nextSize = UDim2.new(ratio, 0, 0, 2)
					if IsDragging then
						SliderDraggable.Size = nextSize
						SliderDraggable.BackgroundColor3 = GuiConfig.Color
					else
						TweenService:Create(SliderDraggable, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = nextSize}):Play()
					end
					if not SkipCallback then SliderConfig.Callback(Value) end
					return true
				end

				local function beginDrag(input)
					if dragging then return end
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						activeTouch = nil
						updateSliderFromX(input.Position.X, true)
					elseif input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						activeTouch = input
						updateSliderFromX(input.Position.X, true)
						input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End and activeTouch == input then
								dragging = false
								activeTouch = nil
								SliderConfig.Callback(SliderFunc.Value)
							end
						end)
					end
				end
				SliderFrame.InputBegan:Connect(beginDrag)
				SliderDraggable.InputBegan:Connect(beginDrag)
				SliderCircle.InputBegan:Connect(beginDrag)
				UserInputService.InputChanged:Connect(function(input)
					if not dragging then return end
					if input.UserInputType == Enum.UserInputType.MouseMovement or (input.UserInputType == Enum.UserInputType.Touch and input == activeTouch) then
						updateSliderFromX(input.Position.X, true)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
						activeTouch = nil
						SliderConfig.Callback(SliderFunc.Value)
					end
				end)

				TextBox.FocusLost:Connect(function(enterPressed)
					local parsed = tonumber((TextBox.Text or ""):gsub(",", "."))
					if parsed == nil then
						TextBox.Text = formatNumber(SliderFunc.Value)
						return
					end
					SliderFunc:Set(parsed)
				end)
				TextBox.Focused:Connect(function()
					TextBox.Text = formatNumber(SliderFunc.Value)
				end)

				SliderFunc:Set(SliderConfig.Default, true, false)
				CountItem = CountItem + 1
				return SliderFunc
			end
			function Items:AddInput(InputConfig)
				local InputConfig = InputConfig or {}
				InputConfig.Title = InputConfig.Title or "Title"
				InputConfig.Content = InputConfig.Content or "Content"
				InputConfig.Callback = InputConfig.Callback or function() end
				local InputFunc = {Value = ""}

				local Input = Instance.new("Frame");
				local UICorner12 = Instance.new("UICorner");
				local InputTitle = Instance.new("TextLabel");
				local InputContent = Instance.new("TextLabel");
				local InputFrame = Instance.new("Frame");
				local UICorner13 = Instance.new("UICorner");
				local InputTextBox = Instance.new("TextBox");

				Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Input.BackgroundTransparency = 0.9350000023841858
				Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Input.BorderSizePixel = 0
				Input.LayoutOrder = CountItem
				Input.Size = UDim2.new(1, 0, 0, 46)
				Input.Name = "Input"
				Input.Parent = SectionAdd

				UICorner12.CornerRadius = UDim.new(0, 4)
				UICorner12.Parent = Input

				InputTitle.Font = Enum.Font.GothamBold
				InputTitle.Text = InputConfig.Title
				InputTitle.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
				InputTitle.TextSize = 13
				InputTitle.TextXAlignment = Enum.TextXAlignment.Left
				InputTitle.TextYAlignment = Enum.TextYAlignment.Top
				InputTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				InputTitle.BackgroundTransparency = 0.9990000128746033
				InputTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
				InputTitle.BorderSizePixel = 0
				InputTitle.Position = UDim2.new(0, 10, 0, 10)
				InputTitle.Size = UDim2.new(1, -180, 0, 13)
				InputTitle.Name = "InputTitle"
				InputTitle.Parent = Input

				InputContent.Font = Enum.Font.GothamBold
				InputContent.Text = InputConfig.Content
				InputContent.TextColor3 = Color3.fromRGB(255, 255, 255)
				InputContent.TextSize = 12
				InputContent.TextTransparency = 0.6000000238418579
				InputContent.TextWrapped = true
				InputContent.TextXAlignment = Enum.TextXAlignment.Left
				InputContent.TextYAlignment = Enum.TextYAlignment.Bottom
				InputContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				InputContent.BackgroundTransparency = 0.9990000128746033
				InputContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
				InputContent.BorderSizePixel = 0
				InputContent.Position = UDim2.new(0, 10, 0, 23)
				InputContent.Size = UDim2.new(1, -155, 0, 12)
				InputContent.Name = "InputContent"
				InputContent.Parent = Input

				InputFrame.AnchorPoint = Vector2.new(1, 0.5)
				InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				InputFrame.BackgroundTransparency = 0.949999988079071
				InputFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
				InputFrame.BorderSizePixel = 0
				InputFrame.ClipsDescendants = true
				InputFrame.Position = UDim2.new(1, -7, 0.5, 0)
				InputFrame.Size = UDim2.new(0, 122, 0, 28)
				InputFrame.Name = "InputFrame"
				InputFrame.Parent = Input

				local refreshInputDescription
				local function updateInputLayout()
					local width = Input.AbsoluteSize.X
					if width <= 0 then return end
					local inputWidth = math.clamp(math.floor(width * 0.42), 88, 122)
					InputFrame.Size = UDim2.new(0, inputWidth, 0, 28)
					local rightPadding = inputWidth + 22
					InputTitle.Size = UDim2.new(1, -(InputTitle.Position.X.Offset + rightPadding), 0, 13)
					if refreshInputDescription then refreshInputDescription() end
				end
				refreshInputDescription = BindWrappedText(InputContent, Input, function()
					return InputFrame.Size.X.Offset + 22
				end, 12, 44, 9, UpdateSizeSection)
				Input:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateInputLayout)
				task.defer(updateInputLayout)

				UICorner13.CornerRadius = UDim.new(0, 4)
				UICorner13.Parent = InputFrame

				InputTextBox.CursorPosition = -1
				InputTextBox.Font = Enum.Font.GothamBold
				InputTextBox.PlaceholderColor3 = Color3.fromRGB(120.00000044703484, 120.00000044703484, 120.00000044703484)
				InputTextBox.PlaceholderText = "Write your input there"
				InputTextBox.Text = ""
				InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
				InputTextBox.TextSize = 12
				InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
				InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
				InputTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				InputTextBox.BackgroundTransparency = 0.9990000128746033
				InputTextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
				InputTextBox.BorderSizePixel = 0
				InputTextBox.Position = UDim2.new(0, 5, 0.5, 0)
				InputTextBox.Size = UDim2.new(1, -10, 1, -8)
				InputTextBox.Name = "InputTextBox"
				InputTextBox.Parent = InputFrame
				function InputFunc:Set(Value)
					Value = tostring(Value == nil and "" or Value)
					InputTextBox.Text = Value
					InputFunc.Value = Value
					InputConfig.Callback(Value)
				end
				InputTextBox.FocusLost:Connect(function()
					InputFunc:Set(InputTextBox.Text)
				end)
				CountItem = CountItem + 1
				return InputFunc
			end
			function Items:AddDropdown(DropdownConfig)
				local DropdownConfig = DropdownConfig or {}
				DropdownConfig.Title = DropdownConfig.Title or "Title"
				DropdownConfig.Content = DropdownConfig.Content or "Content"
				DropdownConfig.Multi = DropdownConfig.Multi or false
				DropdownConfig.Options = DropdownConfig.Options or {}
				DropdownConfig.Default = DropdownConfig.Default or {}
				if type(DropdownConfig.Default) ~= "table" then DropdownConfig.Default = {DropdownConfig.Default} end
				DropdownConfig.Callback = DropdownConfig.Callback or function() end

				local DropdownFunc = {Value = DropdownConfig.Default, Options = DropdownConfig.Options}
	
				local Dropdown = Instance.new("Frame");
				local DropdownButton = Instance.new("TextButton");
				local UICorner10 = Instance.new("UICorner");
				local DropdownTitle = Instance.new("TextLabel");
				local DropdownContent = Instance.new("TextLabel");
				local SelectOptionsFrame = Instance.new("Frame");
				local UICorner11 = Instance.new("UICorner");
				local OptionSelecting = Instance.new("TextLabel");
				local OptionImg = Instance.new("ImageLabel");

				Dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Dropdown.BackgroundTransparency = 0.9350000023841858
				Dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Dropdown.BorderSizePixel = 0
				Dropdown.LayoutOrder = CountItem
				Dropdown.Size = UDim2.new(1, 0, 0, 46)
				Dropdown.Name = "Dropdown"
				Dropdown.Parent = SectionAdd

				DropdownButton.Font = Enum.Font.SourceSans
				DropdownButton.Text = ""
				DropdownButton.TextColor3 = Color3.fromRGB(0, 0, 0)
				DropdownButton.TextSize = 14
				DropdownButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				DropdownButton.BackgroundTransparency = 0.9990000128746033
				DropdownButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
				DropdownButton.BorderSizePixel = 0
				DropdownButton.Size = UDim2.new(1, 0, 1, 0)
				DropdownButton.Name = "ToggleButton"
				DropdownButton.Parent = Dropdown

				UICorner10.CornerRadius = UDim.new(0, 4)
				UICorner10.Parent = Dropdown

				DropdownTitle.Font = Enum.Font.GothamBold
				DropdownTitle.Text = DropdownConfig.Title
				DropdownTitle.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
				DropdownTitle.TextSize = 13
				DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
				DropdownTitle.TextYAlignment = Enum.TextYAlignment.Top
				DropdownTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				DropdownTitle.BackgroundTransparency = 0.9990000128746033
				DropdownTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
				DropdownTitle.BorderSizePixel = 0
				DropdownTitle.Position = UDim2.new(0, 10, 0, 10)
				DropdownTitle.Size = UDim2.new(1, -165, 0, 14)
				DropdownTitle.Name = "DropdownTitle"
				DropdownTitle.Parent = Dropdown

				DropdownContent.Font = Enum.Font.GothamBold
				DropdownContent.Text = DropdownConfig.Content
				DropdownContent.TextColor3 = Color3.fromRGB(255, 255, 255)
				DropdownContent.TextSize = 12
				DropdownContent.TextTransparency = 0.6000000238418579
				DropdownContent.TextWrapped = true
				DropdownContent.TextXAlignment = Enum.TextXAlignment.Left
				DropdownContent.TextYAlignment = Enum.TextYAlignment.Bottom
				DropdownContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				DropdownContent.BackgroundTransparency = 0.9990000128746033
				DropdownContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
				DropdownContent.BorderSizePixel = 0
				DropdownContent.Position = UDim2.new(0, 10, 0, 23)
				DropdownContent.Size = UDim2.new(1, -165, 0, 14)
				DropdownContent.Name = "DropdownContent"
				DropdownContent.Parent = Dropdown

				local function updateDropdownDescriptionHeight()
					local parentWidth = Dropdown.AbsoluteSize.X
					if parentWidth <= 0 then return end
					local selectorWidth = math.clamp(math.floor(parentWidth * 0.40), 84, 110)
					SelectOptionsFrame.Size = UDim2.new(0, selectorWidth, 0, 25)
					SelectOptionsFrame.Position = UDim2.new(1, -5, 0.5, 0)
					local rightPadding = selectorWidth + 27
					local textWidth = math.max(24, parentWidth - 10 - rightPadding)
					DropdownTitle.Size = UDim2.new(1, -(10 + rightPadding), 0, 14)
					DropdownContent.Size = UDim2.new(1, -(10 + rightPadding), 0, 14)
					local measured = TextService:GetTextSize(tostring(DropdownContent.Text or ""), DropdownContent.TextSize, DropdownContent.Font, Vector2.new(textWidth, 10000))
					local contentHeight = math.max(14, math.ceil(measured.Y))
					DropdownContent.Size = UDim2.new(1, -(10 + rightPadding), 0, contentHeight)
					local wantedHeight = math.max(44, DropdownContent.Position.Y.Offset + contentHeight + 8)
					if Dropdown.Size.Y.Scale ~= 0 or Dropdown.Size.Y.Offset ~= wantedHeight then
						Dropdown.Size = UDim2.new(1, 0, 0, wantedHeight)
						UpdateSizeSection()
					end
				end
				DropdownContent.TextWrapped = true
				DropdownContent:GetPropertyChangedSignal("Text"):Connect(updateDropdownDescriptionHeight)
				DropdownContent:GetPropertyChangedSignal("TextSize"):Connect(updateDropdownDescriptionHeight)
				task.defer(updateDropdownDescriptionHeight)
				Dropdown:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateDropdownDescriptionHeight)

				SelectOptionsFrame.AnchorPoint = Vector2.new(1, 0.5)
				SelectOptionsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				SelectOptionsFrame.BackgroundTransparency = 0.949999988079071
				SelectOptionsFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
				SelectOptionsFrame.BorderSizePixel = 0
				SelectOptionsFrame.Position = UDim2.new(1, -5, 0.5, 0)
				SelectOptionsFrame.Size = UDim2.new(0, 110, 0, 25)
				SelectOptionsFrame.Name = "SelectOptionsFrame"
				SelectOptionsFrame.LayoutOrder = CountDropdown
				SelectOptionsFrame.Parent = Dropdown

				UICorner11.CornerRadius = UDim.new(0, 4)
				UICorner11.Parent = SelectOptionsFrame

				DropdownButton.Activated:Connect(function()
					if not MoreBlur.Visible then
						MoreBlur.Visible = true 
						DropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder)
						TweenService:Create(MoreBlur, TweenInfo.new(0.3), {BackgroundTransparency = 0.7}):Play()
						TweenService:Create(DropdownSelect, TweenInfo.new(0.3), {Position = UDim2.new(1, -11, 0.5, 0)}):Play()
					end
				end)

				OptionSelecting.Font = Enum.Font.GothamBold
				OptionSelecting.Text = ""
				OptionSelecting.TextColor3 = Color3.fromRGB(255, 255, 255)
				OptionSelecting.TextSize = 11
				OptionSelecting.TextTruncate = Enum.TextTruncate.AtEnd
				OptionSelecting.TextTransparency = 0.6000000238418579
				OptionSelecting.TextWrapped = true
				OptionSelecting.TextXAlignment = Enum.TextXAlignment.Left
				OptionSelecting.AnchorPoint = Vector2.new(0, 0.5)
				OptionSelecting.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				OptionSelecting.BackgroundTransparency = 0.9990000128746033
				OptionSelecting.BorderColor3 = Color3.fromRGB(0, 0, 0)
				OptionSelecting.BorderSizePixel = 0
				OptionSelecting.Position = UDim2.new(0, 6, 0.5, 0)
				OptionSelecting.Size = UDim2.new(1, -28, 1, -6)
				OptionSelecting.Name = "OptionSelecting"
				OptionSelecting.Parent = SelectOptionsFrame

				OptionImg.Image = "rbxassetid://16851841101"
				OptionImg.ImageColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
				OptionImg.AnchorPoint = Vector2.new(1, 0.5)
				OptionImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				OptionImg.BackgroundTransparency = 0.9990000128746033
				OptionImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
				OptionImg.BorderSizePixel = 0
				OptionImg.Position = UDim2.new(1, 0, 0.5, 0)
				OptionImg.Size = UDim2.new(0, 20, 0, 20)
				OptionImg.Name = "OptionImg"
				OptionImg.Parent = SelectOptionsFrame

				local ScrollSelect = Instance.new("ScrollingFrame");
				local UIListLayout4 = Instance.new("UIListLayout");

				ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, 0)
				ScrollSelect.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
				ScrollSelect.ScrollBarThickness = 0
				ScrollSelect.Active = true
				ScrollSelect.LayoutOrder = CountDropdown
				ScrollSelect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ScrollSelect.BackgroundTransparency = 0.9990000128746033
				ScrollSelect.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ScrollSelect.BorderSizePixel = 0
				ScrollSelect.Size = UDim2.new(1, 0, 1, 0)
				ScrollSelect.Name = "ScrollSelect"
				ScrollSelect.Parent = DropdownFolder
			
				UIListLayout4.Padding = UDim.new(0, 3)
				UIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout4.Parent = ScrollSelect

				local DropCount = 0
				function DropdownFunc:Clear()
					for _, DropFrame in ipairs(ScrollSelect:GetChildren()) do
						if DropFrame.Name == "Option" then DropFrame:Destroy() end
					end
					DropdownFunc.Value = {}
					DropdownFunc.Options = {}
					OptionSelecting.Text = "Select Options"
					ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, 0)
				end
				function DropdownFunc:Set(Value)
					if Value ~= nil then
						if type(Value) ~= "table" then Value = {Value} end
						DropdownFunc.Value = Value
					end
					for _, Drop in ScrollSelect:GetChildren() do
						if Drop.Name ~= "UIListLayout" and not table.find(DropdownFunc.Value, Drop.OptionText.Text) then
							TweenService:Create(
								Drop.ChooseFrame,
								TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
								{Size = UDim2.new(0, 0, 0, 0)}
							):Play()
							TweenService:Create(
								Drop.ChooseFrame.UIStroke,
								TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
								{Transparency = 0.999}
							):Play()
							TweenService:Create(
								Drop,
								TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
								{BackgroundTransparency = 0.999}
							):Play()
						elseif Drop.Name ~= "UIListLayout" and table.find(DropdownFunc.Value, Drop.OptionText.Text) then
							TweenService:Create(
								Drop.ChooseFrame.UIStroke,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
								{Transparency = 0}
							):Play()
							TweenService:Create(
								Drop.ChooseFrame,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
								{Size = UDim2.new(0, 1, 0, 12)}
							):Play()
							TweenService:Create(
								Drop,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
								{BackgroundTransparency = 0.935}
							):Play()
						end
					end
					local DropdownValueTable = table.concat(DropdownFunc.Value, ", ")
					if DropdownValueTable == "" then
						OptionSelecting.Text = "Select Options"
					else
						OptionSelecting.Text = tostring(DropdownValueTable)
					end
					DropdownConfig.Callback(DropdownFunc.Value)
				end
				function DropdownFunc:AddOption(OptionName)
					OptionName = tostring(OptionName or "Option")
					DropdownFunc.Options = DropdownFunc.Options or {}
					table.insert(DropdownFunc.Options, OptionName)
					local Option = Instance.new("Frame");
					local UICorner37 = Instance.new("UICorner");
					local OptionButton = Instance.new("TextButton");
					local OptionText = Instance.new("TextLabel")
					local ChooseFrame = Instance.new("Frame");
					local UIStroke15 = Instance.new("UIStroke");
					local UICorner38 = Instance.new("UICorner");
					
					Option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Option.BackgroundTransparency = 0.999
					Option.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Option.BorderSizePixel = 0
					Option.LayoutOrder = DropCount
					Option.Size = UDim2.new(1, 0, 0, 30)
					Option.Name = "Option"
					Option.Parent = ScrollSelect
				
					UICorner37.CornerRadius = UDim.new(0, 3)
					UICorner37.Parent = Option
				
					OptionButton.Font = Enum.Font.GothamBold
					OptionButton.Text = ""
					OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
					OptionButton.TextSize = 13
					OptionButton.TextXAlignment = Enum.TextXAlignment.Left
					OptionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					OptionButton.BackgroundTransparency = 0.9990000128746033
					OptionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
					OptionButton.BorderSizePixel = 0
					OptionButton.Size = UDim2.new(1, 0, 1, 0)
					OptionButton.Name = "OptionButton"
					OptionButton.Parent = Option

					OptionText.Font = Enum.Font.GothamBold
					OptionText.Text = OptionName
					OptionText.TextSize = 13
					OptionText.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
					OptionText.TextXAlignment = Enum.TextXAlignment.Left
					OptionText.TextYAlignment = Enum.TextYAlignment.Top
					OptionText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					OptionText.BackgroundTransparency = 0.9990000128746033
					OptionText.BorderColor3 = Color3.fromRGB(0, 0, 0)
					OptionText.BorderSizePixel = 0
					OptionText.Position = UDim2.new(0, 8, 0, 8)
					OptionText.Size = UDim2.new(1, -100, 0, 13)
					OptionText.Name = "OptionText"
					OptionText.Parent = Option
	
					ChooseFrame.AnchorPoint = Vector2.new(0, 0.5)
					ChooseFrame.BackgroundColor3 = GuiConfig.Color
					ChooseFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
					ChooseFrame.BorderSizePixel = 0
					ChooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
					ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
					ChooseFrame.Name = "ChooseFrame"
					ChooseFrame.Parent = Option
				
					UIStroke15.Color = GuiConfig.Color
					UIStroke15.Thickness = 1.600000023841858
					UIStroke15.Transparency = 0.999
					UIStroke15.Parent = ChooseFrame
				
					UICorner38.Parent = ChooseFrame
					
					OptionButton.Activated:Connect(function()
						CircleClick(OptionButton, Mouse.X, Mouse.Y) 
						if DropdownConfig.Multi then
							if Option.BackgroundTransparency > 0.95 then
								table.insert(DropdownFunc.Value, OptionName)
								DropdownFunc:Set(DropdownFunc.Value)
							else
								for i, value in pairs(DropdownFunc.Value) do
									if value == OptionName then
										table.remove(DropdownFunc.Value, i)
										break
									end
								end
								DropdownFunc:Set(DropdownFunc.Value)
							end
						else
							DropdownFunc.Value = {OptionName}
							DropdownFunc:Set(DropdownFunc.Value)
						end
					end)
					local OffsetY = 0
					for _, child in ScrollSelect:GetChildren() do
						if child.Name ~= "UIListLayout" then
							OffsetY = OffsetY + 3 + child.Size.Y.Offset
						end
					end
					ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
					DropCount = DropCount + 1
				end
				function DropdownFunc:Refresh(RefreshList, Selecting)
					RefreshList = RefreshList or {}
					Selecting = Selecting or {}
					if type(Selecting) ~= "table" then Selecting = {Selecting} end
					DropdownFunc:Clear()
					for _, Drop in ipairs(RefreshList) do
						DropdownFunc:AddOption(Drop)
					end
					DropdownFunc.Options = RefreshList
					DropdownFunc:Set(Selecting)
				end
				DropdownFunc:Refresh(DropdownFunc.Options, DropdownFunc.Value)
				CountItem = CountItem + 1
				CountDropdown = CountDropdown + 1
				return DropdownFunc
			end
			CountSection = CountSection + 1
			return Items
		end
		CountTab = CountTab + 1
		return Sections
	end
	return Tabs
end
return FlurioreLib