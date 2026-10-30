local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local TextService = game:GetService("TextService")
local CoreGui = LocalPlayer:WaitForChild("PlayerGui")

local ThemePresets = {
	Dark = {
		Accent = Color3.fromRGB(255, 0, 255),
		Background = Color3.fromRGB(15, 15, 15),
		Surface = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(235, 235, 235),
		MutedText = Color3.fromRGB(160, 160, 160),
		Border = Color3.fromRGB(50, 50, 50),
	},
	Midnight = {
		Accent = Color3.fromRGB(80, 160, 255),
		Background = Color3.fromRGB(10, 12, 20),
		Surface = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(240, 244, 255),
		MutedText = Color3.fromRGB(140, 150, 170),
		Border = Color3.fromRGB(40, 48, 70),
	},
	Rose = {
		Accent = Color3.fromRGB(255, 90, 140),
		Background = Color3.fromRGB(18, 12, 16),
		Surface = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(250, 240, 245),
		MutedText = Color3.fromRGB(180, 150, 160),
		Border = Color3.fromRGB(70, 45, 55),
	},
	Mint = {
		Accent = Color3.fromRGB(80, 220, 170),
		Background = Color3.fromRGB(12, 18, 16),
		Surface = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(235, 250, 245),
		MutedText = Color3.fromRGB(150, 175, 165),
		Border = Color3.fromRGB(45, 70, 60),
	},
}

local SharedBlur = {
	Effect = nil,
	Users = 0,
	Size = 12,
	NotifyEnabled = false,
}

local function acquireSharedBlur()
	SharedBlur.Users = SharedBlur.Users + 1
	if not SharedBlur.Effect or not SharedBlur.Effect.Parent then
		local effect = Instance.new("BlurEffect")
		effect.Name = "FlurioreSharedBlur"
		effect.Size = SharedBlur.Size
		effect.Enabled = true
		effect.Parent = Lighting
		SharedBlur.Effect = effect
	else
		SharedBlur.Effect.Enabled = true
		SharedBlur.Effect.Size = SharedBlur.Size
	end
end

local function releaseSharedBlur()
	SharedBlur.Users = math.max(0, SharedBlur.Users - 1)
	if SharedBlur.Users <= 0 and SharedBlur.Effect then
		SharedBlur.Effect.Enabled = false
	end
end

local function setSharedBlurSize(size)
	local n = math.clamp(tonumber(size) or SharedBlur.Size, 0, 56)
	SharedBlur.Size = n
	if SharedBlur.Effect then
		SharedBlur.Effect.Size = n
	end
	return n
end

 
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
			if StartSize.Y.Scale == 0 and StartSize.Y.Offset <= 40 then return end
			local Delta = input.Position - DragStart
			local newWidth = StartSize.X.Offset + Delta.X
			local newHeight = StartSize.Y.Offset + Delta.Y
			newWidth = math.max(newWidth, minSizeX)
			newHeight = math.max(newHeight, minSizeY)
			object.Size = UDim2.new(0, newWidth, 0, newHeight)
		end

		changesizeobject.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if object.Size.Y.Scale == 0 and object.Size.Y.Offset <= 40 then return end
				if object.Size.X.Scale == 1 and object.Size.Y.Scale == 1 then return end
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
		local targetSize = UDim2.new(0, Size, 0, Size)
		local targetPosition = UDim2.new(0.5, -Size/2, 0.5, -Size/2)
		-- Legacy GuiObject:TweenSizeAndPosition errors when the control has
		-- already been detached from PlayerGui. Tween only while it is in game.
		if Button:IsDescendantOf(game) and Circle:IsDescendantOf(game) then
			local rippleTween = TweenService:Create(
				Circle,
				TweenInfo.new(Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Size = targetSize, Position = targetPosition}
			)
			rippleTween:Play()
		else
			Circle.Size = targetSize
			Circle.Position = targetPosition
		end
		for i = 1, 10 do
			if not Circle.Parent then break end
			Circle.ImageTransparency = math.min(1, Circle.ImageTransparency + 0.01)
			task.wait(Time / 10)
		end
		if Circle.Parent then Circle:Destroy() end
	end)
end

local FlurioreLib = {}

local NotifyState = {
	Position = "BottomRight",
	MaxVisible = 5,
	Active = {},
}

local NotifyAnchors = {
	BottomRight = {Anchor = Vector2.new(1, 1), Pos = UDim2.new(1, -30, 1, -30), StackDir = -1},
	BottomLeft = {Anchor = Vector2.new(0, 1), Pos = UDim2.new(0, 30, 1, -30), StackDir = -1},
	TopRight = {Anchor = Vector2.new(1, 0), Pos = UDim2.new(1, -30, 0, 30), StackDir = 1},
	TopLeft = {Anchor = Vector2.new(0, 0), Pos = UDim2.new(0, 30, 0, 30), StackDir = 1},
}

local function ensureNotifyLayout()
	if not CoreGui:FindFirstChild("NotifyGui") then
		local NotifyGui = Instance.new("ScreenGui")
		NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		NotifyGui.Name = "NotifyGui"
		NotifyGui.Parent = CoreGui
	end
	local layout = CoreGui.NotifyGui:FindFirstChild("NotifyLayout")
	if not layout then
		layout = Instance.new("Frame")
		layout.BackgroundTransparency = 1
		layout.BorderSizePixel = 0
		layout.Size = UDim2.new(0, 320, 1, 0)
		layout.Name = "NotifyLayout"
		layout.Parent = CoreGui.NotifyGui
	end
	local cfg = NotifyAnchors[NotifyState.Position] or NotifyAnchors.BottomRight
	layout.AnchorPoint = cfg.Anchor
	layout.Position = cfg.Pos
	return layout, cfg
end

local function restackNotifies()
	local layout, cfg = ensureNotifyLayout()
	local stackDir = cfg.StackDir
	local offset = 0
	local children = {}
	for _, child in ipairs(layout:GetChildren()) do
		if child.Name == "NotifyFrame" then
			table.insert(children, child)
		end
	end
	for i, frame in ipairs(children) do
		local target
		if stackDir < 0 then
			target = UDim2.new(0, 0, 1, -(offset))
			frame.AnchorPoint = Vector2.new(0, 1)
		else
			target = UDim2.new(0, 0, 0, offset)
			frame.AnchorPoint = Vector2.new(0, 0)
		end
		TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = target}):Play()
		offset = offset + frame.Size.Y.Offset + 12
	end
end

function FlurioreLib:SetNotifyPosition(position)
	if not NotifyAnchors[position] then return false end
	NotifyState.Position = position
	ensureNotifyLayout()
	restackNotifies()
	return true
end

function FlurioreLib:GetNotifyPosition()
	return NotifyState.Position
end

function FlurioreLib:SetNotifyMax(max)
	local n = tonumber(max)
	if not n then return false end
	NotifyState.MaxVisible = math.max(1, math.floor(n))
	return true
end

function FlurioreLib:GetNotifyMax()
	return NotifyState.MaxVisible
end

function FlurioreLib:SetNotifyBlur(enabled)
	SharedBlur.NotifyEnabled = not not enabled
	return SharedBlur.NotifyEnabled
end

function FlurioreLib:GetNotifyBlur()
	return SharedBlur.NotifyEnabled
end

function FlurioreLib:SetBlurSize(size)
	return setSharedBlurSize(size)
end

function FlurioreLib:GetBlurSize()
	return SharedBlur.Size
end

function FlurioreLib:GetThemePresets()
	local names = {}
	for name in pairs(ThemePresets) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

function FlurioreLib:ClearNotifies()
	local layout = CoreGui:FindFirstChild("NotifyGui") and CoreGui.NotifyGui:FindFirstChild("NotifyLayout")
	if not layout then return true end
	for _, child in ipairs(layout:GetChildren()) do
		if child.Name == "NotifyFrame" then
			child:Destroy()
		end
	end
	NotifyState.Active = {}
	return true
end

function FlurioreLib:MakeNotify(NotifyConfig)
	local NotifyConfig = NotifyConfig or {}
	NotifyConfig.Title = NotifyConfig.Title or "Hirimi Hub"
	NotifyConfig.Description = NotifyConfig.Description or "Notification"
	NotifyConfig.Content = NotifyConfig.Content or "Content"
	NotifyConfig.Color = NotifyConfig.Color or Color3.fromRGB(255, 0, 255)
	NotifyConfig.Time = math.max(0.05, tonumber(NotifyConfig.Time) or 0.5)
	NotifyConfig.Delay = math.max(0, tonumber(NotifyConfig.Delay) or 5)
	local priority = tostring(NotifyConfig.Priority or "normal"):lower()
	if priority ~= "high" then priority = "normal" end
	local useNotifyBlur = NotifyConfig.Blur
	if useNotifyBlur == nil then useNotifyBlur = SharedBlur.NotifyEnabled end
	local notifyBlurHeld = false
	if useNotifyBlur then
		acquireSharedBlur()
		notifyBlurHeld = true
	end
	local NotifyFunction = {}
	local layout, cfg = ensureNotifyLayout()
	local stackDir = cfg.StackDir

	local frames = {}
	for _, child in ipairs(layout:GetChildren()) do
		if child.Name == "NotifyFrame" then
			table.insert(frames, child)
		end
	end
	if #frames >= NotifyState.MaxVisible then
		local victim = nil
		for _, child in ipairs(frames) do
			if child:GetAttribute("Priority") ~= "high" then
				victim = child
				break
			end
		end
		if not victim and priority == "high" then
			victim = frames[1]
		elseif not victim and priority ~= "high" then
			victim = frames[1]
		end
		if victim then
			victim:Destroy()
		elseif priority ~= "high" then
			if notifyBlurHeld then
				releaseSharedBlur()
				notifyBlurHeld = false
			end
			return {
				Close = function() return false end,
			}
		end
	end

	local NotifyPosHeigh = 0
	for _, v in ipairs(layout:GetChildren()) do
		if v.Name == "NotifyFrame" then
			NotifyPosHeigh = NotifyPosHeigh + v.Size.Y.Offset + 12
		end
	end

	local NotifyFrame = Instance.new("Frame")
	local NotifyFrameReal = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local DropShadowHolder = Instance.new("Frame")
	local DropShadow = Instance.new("ImageLabel")
	local Top = Instance.new("Frame")
	local TextLabel = Instance.new("TextLabel")
	local UIStroke = Instance.new("UIStroke")
	local UICorner1 = Instance.new("UICorner")
	local TextLabel1 = Instance.new("TextLabel")
	local UIStroke1 = Instance.new("UIStroke")
	local Close = Instance.new("TextButton")
	local ImageLabel = Instance.new("ImageLabel")
	local TextLabel2 = Instance.new("TextLabel")
	local Progress = Instance.new("Frame")
	local ProgressFill = Instance.new("Frame")

	NotifyFrame.BackgroundTransparency = 1
	NotifyFrame.BorderSizePixel = 0
	NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
	NotifyFrame.Name = "NotifyFrame"
	NotifyFrame:SetAttribute("Priority", priority)
	NotifyFrame.Parent = layout
	if stackDir < 0 then
		NotifyFrame.AnchorPoint = Vector2.new(0, 1)
		NotifyFrame.Position = UDim2.new(0, 0, 1, -NotifyPosHeigh)
	else
		NotifyFrame.AnchorPoint = Vector2.new(0, 0)
		NotifyFrame.Position = UDim2.new(0, 0, 0, NotifyPosHeigh)
	end

	NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	NotifyFrameReal.BorderSizePixel = 0
	NotifyFrameReal.BackgroundTransparency = useNotifyBlur and 0.45 or 0.15
	NotifyFrameReal.Position = UDim2.new(0, stackDir < 0 and 400 or -400, 0, 0)
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
		local frameHeight = notifyContentHeight < 27 and 65 or (notifyContentHeight + 40)
		NotifyFrame.Size = UDim2.new(1, 0, 0, frameHeight)

		Progress.Name = "Progress"
		Progress.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		Progress.BorderSizePixel = 0
		Progress.AnchorPoint = Vector2.new(0, 1)
		Progress.Position = UDim2.new(0, 8, 1, -6)
		Progress.Size = UDim2.new(1, -16, 0, 3)
		Progress.Parent = NotifyFrameReal
		local ProgressCorner = Instance.new("UICorner")
		ProgressCorner.CornerRadius = UDim.new(1, 0)
		ProgressCorner.Parent = Progress
		ProgressFill.Name = "ProgressFill"
		ProgressFill.BackgroundColor3 = NotifyConfig.Color
		ProgressFill.BorderSizePixel = 0
		ProgressFill.Size = UDim2.new(1, 0, 1, 0)
		ProgressFill.Parent = Progress
		local ProgressFillCorner = Instance.new("UICorner")
		ProgressFillCorner.CornerRadius = UDim.new(1, 0)
		ProgressFillCorner.Parent = ProgressFill

		local closing = false
		function NotifyFunction:Close()
			if closing then return false end
			closing = true
			local slideX = (NotifyAnchors[NotifyState.Position] or NotifyAnchors.BottomRight).StackDir < 0 and 400 or -400
			local outInfo = TweenInfo.new(NotifyConfig.Time, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(NotifyFrameReal, outInfo, {
				Position = UDim2.new(0, slideX, 0, 0),
				BackgroundTransparency = 1,
			}):Play()
			TweenService:Create(DropShadow, outInfo, {ImageTransparency = 1}):Play()
			task.delay(NotifyConfig.Time, function()
				if NotifyFrame.Parent then
					NotifyFrame:Destroy()
				end
				if notifyBlurHeld then
					releaseSharedBlur()
					notifyBlurHeld = false
				end
				restackNotifies()
			end)
			return true
		end
		Close.Activated:Connect(function()
			NotifyFunction:Close()
		end)
		local inInfo = TweenInfo.new(NotifyConfig.Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(NotifyFrameReal, inInfo, {
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = useNotifyBlur and 0.4 or 0.05,
		}):Play()
		if NotifyConfig.Delay > 0 then
			TweenService:Create(ProgressFill, TweenInfo.new(NotifyConfig.Delay, Enum.EasingStyle.Linear), {
				Size = UDim2.new(0, 0, 1, 0),
			}):Play()
			task.delay(NotifyConfig.Delay, function()
				NotifyFunction:Close()
			end)
		end
		restackNotifies()
		return NotifyFunction
end
function FlurioreLib:MakeGui(GuiConfig)
	local GuiConfig = GuiConfig or {}
	GuiConfig.NameHub = GuiConfig.NameHub or "Hirimi Hub"
	GuiConfig.Description = GuiConfig.Description or "Comeback | developing by Hirimi, Teru"
	GuiConfig.Color = GuiConfig.Color or Color3.fromRGB(255, 0, 255)
	GuiConfig.Blur = GuiConfig.Blur == true
	GuiConfig.BlurSize = tonumber(GuiConfig.BlurSize) or SharedBlur.Size
	-- GuiConfig.Size optional: {X=480,Y=320} or UDim2 — independent of maximize
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
	local textScaleValue = math.clamp(tonumber(GuiConfig.TextScale) or 0.85, 0.7, 1.5)
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
			elseif role == "Background" or object.Name == "Main" then
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

	for _, gui in ipairs(CoreGui:GetChildren()) do
		if gui.Name == "HirimiGui" then
			pcall(function() gui:Destroy() end)
		end
	end
	local okPg, pg = pcall(function() return LocalPlayer:FindFirstChild("PlayerGui") end)
	if okPg and pg then
		for _, gui in ipairs(pg:GetChildren()) do
			if gui.Name == "HirimiGui" then
				pcall(function() gui:Destroy() end)
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
	local minimizeToken = 0

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
	NameTab.Size = UDim2.new(1, 0, 0, 24)
	NameTab.Name = "NameTab"
	NameTab.Parent = Layers

	local SearchBox = Instance.new("TextBox")
	SearchBox.Name = "SearchBox"
	SearchBox:SetAttribute("FlurThemeRole", "MutedText")
	SearchBox.PlaceholderText = tostring(GuiConfig.SearchPlaceholder or "Search...")
	SearchBox.Text = ""
	SearchBox.Font = Enum.Font.Gotham
	SearchBox.TextSize = 12
	SearchBox.TextColor3 = Color3.fromRGB(235, 235, 235)
	SearchBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
	SearchBox.TextXAlignment = Enum.TextXAlignment.Left
	SearchBox.ClearTextOnFocus = false
	SearchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SearchBox.BackgroundTransparency = 0.92
	SearchBox.BorderSizePixel = 0
	SearchBox.Position = UDim2.new(0, 0, 0, 26)
	SearchBox.Size = UDim2.new(1, 0, 0, 22)
	SearchBox.Parent = Layers
	local SearchCorner = Instance.new("UICorner")
	SearchCorner.CornerRadius = UDim.new(0, 4)
	SearchCorner.Parent = SearchBox
	local SearchPad = Instance.new("UIPadding")
	SearchPad.PaddingLeft = UDim.new(0, 8)
	SearchPad.Parent = SearchBox
	SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		if GuiFunc.SetSearch then
			GuiFunc:SetSearch(SearchBox.Text)
		end
	end)

	LayersReal.AnchorPoint = Vector2.new(0, 1)
	LayersReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LayersReal.BackgroundTransparency = 0.9990000128746033
	LayersReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LayersReal.BorderSizePixel = 0
	LayersReal.ClipsDescendants = true
	LayersReal.Position = UDim2.new(0, 0, 1, 0)
	LayersReal.Size = UDim2.new(1, 0, 1, -52)
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

	function GuiFunc:SetTitle(text)
		TextLabel.Text = tostring(text or "")
		return true
	end

	function GuiFunc:GetTitle()
		return TextLabel.Text
	end

	function GuiFunc:SetDescription(text)
		TextLabel1.Text = tostring(text or "")
		return true
	end

	function GuiFunc:GetDescription()
		return TextLabel1.Text
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
	end

	function GuiFunc:SetTextScale(value)
		local nextValue = tonumber(value)
		if not nextValue then return false end
		textScaleValue = math.clamp(nextValue, TextScaleMin, TextScaleMax)
		refreshTextScale()
		return true
	end

	function GuiFunc:SetUIScale(value)
		local nextValue = tonumber(value)
		if not nextValue then return false end
		uiScaleValue = math.clamp(nextValue, UIScaleMin, UIScaleMax)
		UIScaleObject.Scale = uiScaleValue
		return true
	end

	function GuiFunc:GetTextScale()
		return textScaleValue
	end

	function GuiFunc:GetUIScale()
		return uiScaleValue
	end

	function GuiFunc:GetTheme()
		return {
			Accent = Theme.Accent,
			Background = Theme.Background,
			Surface = Theme.Surface,
			Text = Theme.Text,
			MutedText = Theme.MutedText,
			Border = Theme.Border,
		}
	end

	function GuiFunc:SetTheme(ThemeConfig)
		if type(ThemeConfig) ~= "table" then return false end
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
		return true
	end

	function GuiFunc:SetAccent(color)
		if typeof(color) ~= "Color3" then return false end
		return GuiFunc:SetTheme({Accent = color})
	end

	local windowOpacity = 0.1
	local blurEnabled = false
	local blurOwned = false
	local blurFrost = 0.45
	local solidOpacity = windowOpacity

	local bgImage = Instance.new("ImageLabel")
	bgImage.Name = "BackgroundImage"
	bgImage.BackgroundTransparency = 1
	bgImage.BorderSizePixel = 0
	bgImage.Size = UDim2.new(1, 0, 1, 0)
	bgImage.Image = ""
	bgImage.ScaleType = Enum.ScaleType.Crop
	bgImage.ImageTransparency = 0.35
	bgImage.Visible = false
	bgImage.ZIndex = 0
	bgImage.Parent = Main
	local bgImageCorner = Instance.new("UICorner")
	bgImageCorner.CornerRadius = UDim.new(0, 8)
	bgImageCorner.Parent = bgImage

	local function applyBackgroundLook()
		if blurEnabled then
			Main.BackgroundTransparency = math.clamp(math.max(windowOpacity, blurFrost), 0.2, 0.92)
		else
			Main.BackgroundTransparency = windowOpacity
		end
	end

	local opacityLayers = { Main = windowOpacity, Top = 0.999, Section = 0.935 }
	local sectionSurfaceFrames = {}
	local windowCorner = 8
	local accentStrokeTransparency = 0
	local flagPrefix = ""
	local blurAnimate = true

	function GuiFunc:SetOpacity(value)
		if type(value) == "table" then
			if value.Main ~= nil then
				windowOpacity = math.clamp(tonumber(value.Main) or windowOpacity, 0, 0.95)
				opacityLayers.Main = windowOpacity
			end
			if value.Top ~= nil then
				opacityLayers.Top = math.clamp(tonumber(value.Top) or opacityLayers.Top, 0, 1)
				Top.BackgroundTransparency = opacityLayers.Top
			end
			if value.Section ~= nil then
				opacityLayers.Section = math.clamp(tonumber(value.Section) or opacityLayers.Section, 0, 1)
				for _, fr in ipairs(sectionSurfaceFrames) do
					if fr and fr.Parent then
						fr.BackgroundTransparency = opacityLayers.Section
					end
				end
			end
			solidOpacity = windowOpacity
			applyBackgroundLook()
			return true
		end
		local n = tonumber(value)
		if not n then return false end
		windowOpacity = math.clamp(n, 0, 0.95)
		opacityLayers.Main = windowOpacity
		solidOpacity = windowOpacity
		applyBackgroundLook()
		return true
	end

	function GuiFunc:GetOpacity()
		return windowOpacity, {
			Main = windowOpacity,
			Top = opacityLayers.Top,
			Section = opacityLayers.Section,
		}
	end

	function GuiFunc:SetCornerRadius(px)
		local n = tonumber(px)
		if not n then return false end
		windowCorner = math.clamp(math.floor(n), 0, 32)
		if UICorner then UICorner.CornerRadius = UDim.new(0, windowCorner) end
		if bgImageCorner then bgImageCorner.CornerRadius = UDim.new(0, windowCorner) end
		return true
	end

	function GuiFunc:GetCornerRadius()
		return windowCorner
	end

	function GuiFunc:SetAccentTransparency(value)
		local n = tonumber(value)
		if not n then return false end
		accentStrokeTransparency = math.clamp(n, 0, 1)
		return true
	end

	function GuiFunc:GetAccentTransparency()
		return accentStrokeTransparency
	end

	function GuiFunc:SetFlagPrefix(prefix)
		flagPrefix = tostring(prefix or "")
		return true
	end

	function GuiFunc:GetFlagPrefix()
		return flagPrefix
	end

	function GuiFunc:SetBlurAnimate(enabled)
		blurAnimate = not not enabled
		return true
	end

	local function resolveFlagName(name)
		if type(name) ~= "string" or name == "" then return name end
		if flagPrefix ~= "" and string.sub(name, 1, #flagPrefix) ~= flagPrefix then
			return flagPrefix .. name
		end
		return name
	end

	-- Window "blur" is local frosting only (higher panel transparency).
	-- It does NOT enable Lighting.BlurEffect (that would blur the whole screen).
	function GuiFunc:SetBlur(enabled)
		enabled = not not enabled
		if enabled == blurEnabled then return true end
		blurEnabled = enabled
		if blurAnimate then
			local target = blurEnabled and math.clamp(math.max(windowOpacity, blurFrost), 0.2, 0.92) or windowOpacity
			TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = target,
			}):Play()
		else
			applyBackgroundLook()
		end
		return true
	end

	function GuiFunc:GetBlur()
		return blurEnabled
	end

	function GuiFunc:SetBlurAmount(amount)
		local n = tonumber(amount)
		if not n then return false end
		blurFrost = math.clamp(n, 0.2, 0.9)
		applyBackgroundLook()
		return true
	end

	function GuiFunc:GetBlurAmount()
		return blurFrost
	end

	function GuiFunc:SetBlurSize(size)
		return setSharedBlurSize(size)
	end

	function GuiFunc:GetBlurSize()
		return SharedBlur.Size
	end

	function GuiFunc:SetBackgroundImage(image)
		if not bgImage then return false end
		if image == nil or image == false or image == "" then
			bgImage.Image = ""
			bgImage.Visible = false
			return true
		end
		bgImage.Image = tostring(image)
		bgImage.Visible = true
		return true
	end

	function GuiFunc:SetBackgroundImageTransparency(value)
		local n = tonumber(value)
		if not n or not bgImage then return false end
		bgImage.ImageTransparency = math.clamp(n, 0, 1)
		return true
	end

	function GuiFunc:GetBackgroundImage()
		if not bgImage or not bgImage.Visible then return "" end
		return bgImage.Image
	end

	function GuiFunc:SetBackgroundScaleType(scaleType)
		if not bgImage then return false end
		if typeof(scaleType) == "EnumItem" then
			bgImage.ScaleType = scaleType
			return true
		end
		local name = string.lower(tostring(scaleType or ""))
		if name == "fit" then bgImage.ScaleType = Enum.ScaleType.Fit
		elseif name == "stretch" then bgImage.ScaleType = Enum.ScaleType.Stretch
		elseif name == "tile" then bgImage.ScaleType = Enum.ScaleType.Tile
		else bgImage.ScaleType = Enum.ScaleType.Crop
		end
		return true
	end

	function GuiFunc:GetBackgroundScaleType()
		if not bgImage then return "Crop" end
		return bgImage.ScaleType.Name
	end

	function GuiFunc:SaveThemePreset(name)
		if type(name) ~= "string" or name == "" then return false end
		ThemePresets[name] = {
			Accent = Theme.Accent,
			Background = Theme.Background,
			Surface = Theme.Surface,
			Text = Theme.Text,
			MutedText = Theme.MutedText,
			Border = Theme.Border,
		}
		return true
	end

	function GuiFunc:SetThemePreset(name)
		local preset = ThemePresets[name]
		if not preset then return false end
		return GuiFunc:SetTheme(preset)
	end

	function GuiFunc:GetThemePresets()
		return FlurioreLib:GetThemePresets()
	end

	local safeInset = {Top = 0, Bottom = 0, Left = 0, Right = 0}
	function GuiFunc:SetSafeArea(insets)
		if type(insets) ~= "table" then return false end
		safeInset.Top = math.max(0, tonumber(insets.Top) or safeInset.Top)
		safeInset.Bottom = math.max(0, tonumber(insets.Bottom) or safeInset.Bottom)
		safeInset.Left = math.max(0, tonumber(insets.Left) or safeInset.Left)
		safeInset.Right = math.max(0, tonumber(insets.Right) or safeInset.Right)
		local pos = DropShadowHolder.Position
		local size = DropShadowHolder.Size
		if size.X.Scale == 0 and size.Y.Scale == 0 then
			DropShadowHolder.Position = UDim2.new(
				0,
				math.max(safeInset.Left, pos.X.Offset),
				0,
				math.max(safeInset.Top, pos.Y.Offset)
			)
		end
		return true
	end

	function GuiFunc:GetSafeArea()
		return {
			Top = safeInset.Top,
			Bottom = safeInset.Bottom,
			Left = safeInset.Left,
			Right = safeInset.Right,
		}
	end

	local oldDestroy = GuiFunc.DestroyGui
	function GuiFunc:DestroyGui()
		if blurOwned then
			releaseSharedBlur()
			blurOwned = false
		end
		if oldDestroy then
			oldDestroy(self)
		elseif HirimiGui and HirimiGui.Parent then
			HirimiGui:Destroy()
		end
	end

	local flagStore = {}
	local searchIndex = {}
	local keyBinds = {}
	local toggleGroups = {}
	local toggleKey = Enum.KeyCode.RightShift
	local autoSaveFolder, autoSaveName = nil, nil
	local autoSaveToken = 0

	local function attachElementControls(api, frame)
		api.Frame = frame
		function api:SetVisible(visible)
			frame.Visible = not not visible
			return true
		end
		function api:GetVisible()
			return frame.Visible
		end
		function api:SetLocked(locked)
			locked = not not locked
			frame:SetAttribute("Locked", locked)
			for _, d in ipairs(frame:GetDescendants()) do
				if d:IsA("GuiButton") or d:IsA("TextBox") then
					d.Active = not locked
					d.AutoButtonColor = not locked
				end
			end
			if frame:IsA("GuiButton") then
				frame.Active = not locked
			end
			return true
		end
		function api:IsLocked()
			return frame:GetAttribute("Locked") == true
		end
		return api
	end

	local function isFrameLocked(frame)
		return frame and frame:GetAttribute("Locked") == true
	end

	local autoSaveFilters = {
		Toggle = false,
		Slider = true,
		Input = true,
		Dropdown = true,
		Keybind = true,
		ColorPicker = true,
		Theme = true,
		Scale = true,
	}

	local function scheduleAutoSave()
		if not autoSaveFolder or not autoSaveName then return end
		autoSaveToken = autoSaveToken + 1
		local token = autoSaveToken
		task.delay(0.65, function()
			if token ~= autoSaveToken then return end
			pcall(function()
				GuiFunc:SaveConfig(autoSaveFolder, autoSaveName)
			end)
		end)
	end

	function GuiFunc:EnableAutoSave(folder, name, filters)
		if type(folder) ~= "string" or type(name) ~= "string" then return false end
		autoSaveFolder, autoSaveName = folder, name
		if type(filters) == "table" then
			for k, v in pairs(filters) do
				if autoSaveFilters[k] ~= nil then
					autoSaveFilters[k] = not not v
				end
			end
		end
		return true
	end

	function GuiFunc:SetAutoSaveFilter(kind, enabled)
		if autoSaveFilters[kind] == nil then return false end
		autoSaveFilters[kind] = not not enabled
		return true
	end

	function GuiFunc:GetAutoSaveFilter()
		local out = {}
		for k, v in pairs(autoSaveFilters) do out[k] = v end
		return out
	end

	function GuiFunc:DisableAutoSave()
		autoSaveFolder, autoSaveName = nil, nil
		return true
	end

	local autoSaveFlagAllow = nil -- nil = all allowed flags by kind filter; set = only these flag names
	local autoSaveFlagDeny = {}

	function GuiFunc:SetAutoSaveFlags(list)
		if list == nil then
			autoSaveFlagAllow = nil
			return true
		end
		if type(list) ~= "table" then return false end
		autoSaveFlagAllow = {}
		for _, name in ipairs(list) do
			if type(name) == "string" then
				autoSaveFlagAllow[name] = true
				autoSaveFlagAllow[resolveFlagName(name)] = true
			end
		end
		return true
	end

	function GuiFunc:DenyAutoSaveFlag(flagName)
		if type(flagName) ~= "string" then return false end
		autoSaveFlagDeny[flagName] = true
		autoSaveFlagDeny[resolveFlagName(flagName)] = true
		return true
	end

	function GuiFunc:AllowAutoSaveFlag(flagName)
		if type(flagName) ~= "string" then return false end
		autoSaveFlagDeny[flagName] = nil
		autoSaveFlagDeny[resolveFlagName(flagName)] = nil
		if autoSaveFlagAllow then
			autoSaveFlagAllow[flagName] = true
			autoSaveFlagAllow[resolveFlagName(flagName)] = true
		end
		return true
	end

	function GuiFunc:NotifyFlagChanged(kind, flagName)
		if kind and autoSaveFilters[kind] == false then return end
		if type(flagName) == "string" then
			local resolved = resolveFlagName(flagName)
			if autoSaveFlagDeny[flagName] or autoSaveFlagDeny[resolved] then return end
			if autoSaveFlagAllow and not (autoSaveFlagAllow[flagName] or autoSaveFlagAllow[resolved]) then return end
		end
		scheduleAutoSave()
	end

	function GuiFunc:RegisterFlag(flag, getFn, setFn, kind)
		if type(flag) ~= "string" or flag == "" then return false end
		if type(getFn) ~= "function" or type(setFn) ~= "function" then return false end
		flag = resolveFlagName(flag)
		flagStore[flag] = {
			Get = getFn,
			Set = function(value)
				setFn(value)
				GuiFunc:NotifyFlagChanged(kind, flag)
			end,
			Kind = kind,
		}
		return true
	end

	function GuiFunc:GetFlags()
		local out = {}
		for flag, handlers in pairs(flagStore) do
			local ok, value = pcall(handlers.Get)
			if ok then out[flag] = value end
		end
		return out
	end

	function GuiFunc:SetFlags(data)
		if type(data) ~= "table" then return false end
		for flag, value in pairs(data) do
			local handlers = flagStore[flag]
			if handlers then
				pcall(handlers.Set, value)
			end
		end
		return true
	end

	local function ensureFolder(path)
		if isfolder and not isfolder(path) and makefolder then
			makefolder(path)
		end
	end

	function GuiFunc:SaveConfig(folder, name)
		if type(folder) ~= "string" or type(name) ~= "string" then return false, "folder and name must be strings" end
		if not writefile then return false, "writefile unavailable" end
		ensureFolder(folder)
		local payload = {
			TextScale = textScaleValue,
			UIScale = uiScaleValue,
			Theme = {
				Accent = {Theme.Accent.R, Theme.Accent.G, Theme.Accent.B},
				Background = {Theme.Background.R, Theme.Background.G, Theme.Background.B},
				Surface = {Theme.Surface.R, Theme.Surface.G, Theme.Surface.B},
				Text = {Theme.Text.R, Theme.Text.G, Theme.Text.B},
				MutedText = {Theme.MutedText.R, Theme.MutedText.G, Theme.MutedText.B},
				Border = {Theme.Border.R, Theme.Border.G, Theme.Border.B},
			},
			Flags = GuiFunc:GetFlags(),
		}
		local ok, encoded = pcall(function()
			return HttpService:JSONEncode(payload)
		end)
		if not ok then return false, encoded end
		local path = folder .. "/" .. name .. ".json"
		local writeOk, writeErr = pcall(writefile, path, encoded)
		if not writeOk then return false, writeErr end
		return true, path
	end

	local function colorFromArray(arr, fallback)
		if type(arr) == "table" and #arr >= 3 then
			return Color3.new(arr[1], arr[2], arr[3])
		end
		return fallback
	end

	function GuiFunc:LoadConfig(folder, name)
		if type(folder) ~= "string" or type(name) ~= "string" then return false, "folder and name must be strings" end
		if not readfile then return false, "readfile unavailable" end
		local path = folder .. "/" .. name .. ".json"
		local ok, raw = pcall(readfile, path)
		if not ok then return false, raw end
		local decodeOk, data = pcall(function()
			return HttpService:JSONDecode(raw)
		end)
		if not decodeOk or type(data) ~= "table" then return false, data end
		if data.TextScale then GuiFunc:SetTextScale(data.TextScale) end
		if data.UIScale then GuiFunc:SetUIScale(data.UIScale) end
		if type(data.Theme) == "table" then
			GuiFunc:SetTheme({
				Accent = colorFromArray(data.Theme.Accent, Theme.Accent),
				Background = colorFromArray(data.Theme.Background, Theme.Background),
				Surface = colorFromArray(data.Theme.Surface, Theme.Surface),
				Text = colorFromArray(data.Theme.Text, Theme.Text),
				MutedText = colorFromArray(data.Theme.MutedText, Theme.MutedText),
				Border = colorFromArray(data.Theme.Border, Theme.Border),
			})
		end
		if type(data.Flags) == "table" then
			GuiFunc:SetFlags(data.Flags)
		end
		return true, path
	end

	function GuiFunc:ExportConfig()
		local payload = {
			TextScale = textScaleValue,
			UIScale = uiScaleValue,
			Theme = GuiFunc:GetTheme(),
			Flags = GuiFunc:GetFlags(),
		}
		local ok, encoded = pcall(function()
			return HttpService:JSONEncode({
				TextScale = payload.TextScale,
				UIScale = payload.UIScale,
				Theme = {
					Accent = {Theme.Accent.R, Theme.Accent.G, Theme.Accent.B},
					Background = {Theme.Background.R, Theme.Background.G, Theme.Background.B},
					Surface = {Theme.Surface.R, Theme.Surface.G, Theme.Surface.B},
					Text = {Theme.Text.R, Theme.Text.G, Theme.Text.B},
					MutedText = {Theme.MutedText.R, Theme.MutedText.G, Theme.MutedText.B},
					Border = {Theme.Border.R, Theme.Border.G, Theme.Border.B},
				},
				Flags = payload.Flags,
			})
		end)
		if not ok then return nil, encoded end
		return encoded
	end

	function GuiFunc:ImportConfig(json)
		if type(json) ~= "string" then return false, "json must be string" end
		local ok, data = pcall(function()
			return HttpService:JSONDecode(json)
		end)
		if not ok or type(data) ~= "table" then return false, data end
		if data.TextScale then GuiFunc:SetTextScale(data.TextScale) end
		if data.UIScale then GuiFunc:SetUIScale(data.UIScale) end
		if type(data.Theme) == "table" then
			GuiFunc:SetTheme({
				Accent = colorFromArray(data.Theme.Accent, Theme.Accent),
				Background = colorFromArray(data.Theme.Background, Theme.Background),
				Surface = colorFromArray(data.Theme.Surface, Theme.Surface),
				Text = colorFromArray(data.Theme.Text, Theme.Text),
				MutedText = colorFromArray(data.Theme.MutedText, Theme.MutedText),
				Border = colorFromArray(data.Theme.Border, Theme.Border),
			})
		end
		if type(data.Flags) == "table" then
			GuiFunc:SetFlags(data.Flags)
		end
		return true
	end

	function GuiFunc:ListConfigs(folder)
		if type(folder) ~= "string" then return {} end
		local names = {}
		if listfiles then
			local ok, files = pcall(listfiles, folder)
			if ok and type(files) == "table" then
				for _, path in ipairs(files) do
					local name = string.match(path, "([^/\\]+)%.json$")
					if name then table.insert(names, name) end
				end
			end
		end
		return names
	end

	function GuiFunc:DeleteConfig(folder, name)
		if type(folder) ~= "string" or type(name) ~= "string" then return false, "folder and name must be strings" end
		if not delfile then return false, "delfile unavailable" end
		local path = folder .. "/" .. name .. ".json"
		local ok, err = pcall(delfile, path)
		if not ok then return false, err end
		return true, path
	end

	function GuiFunc:RenameConfig(folder, oldName, newName)
		if type(folder) ~= "string" or type(oldName) ~= "string" or type(newName) ~= "string" then
			return false, "folder, oldName, newName must be strings"
		end
		if not readfile or not writefile then return false, "filesystem unavailable" end
		local oldPath = folder .. "/" .. oldName .. ".json"
		local newPath = folder .. "/" .. newName .. ".json"
		local ok, raw = pcall(readfile, oldPath)
		if not ok then return false, raw end
		local writeOk, writeErr = pcall(writefile, newPath, raw)
		if not writeOk then return false, writeErr end
		if delfile then pcall(delfile, oldPath) end
		return true, newPath
	end

	function GuiFunc:SetSearch(query)
		local q = string.lower(tostring(query or ""))
		for _, entry in ipairs(searchIndex) do
			if entry.frame and entry.frame.Parent then
				if q == "" then
					entry.frame.Visible = true
				else
					local title = string.lower(tostring(entry.title or ""))
					local content = string.lower(tostring(entry.content or ""))
					entry.frame.Visible = string.find(title, q, 1, true) ~= nil or string.find(content, q, 1, true) ~= nil
				end
			end
		end
		return true
	end

	function GuiFunc:ClearSearch()
		return GuiFunc:SetSearch("")
	end

	function GuiFunc:SetToggleKey(keyCode)
		if typeof(keyCode) ~= "EnumItem" then return false end
		toggleKey = keyCode
		return true
	end

	function GuiFunc:GetToggleKey()
		return toggleKey
	end

	function GuiFunc:BindKey(id, keyCode, callback)
		if type(id) ~= "string" or id == "" then return false end
		if typeof(keyCode) ~= "EnumItem" then return false end
		if type(callback) ~= "function" then return false end
		keyBinds[id] = {Key = keyCode, Callback = callback}
		return true
	end

	function GuiFunc:UnbindKey(id)
		if type(id) ~= "string" then return false end
		keyBinds[id] = nil
		return true
	end

	function GuiFunc:GetBinds()
		local out = {}
		for id, bind in pairs(keyBinds) do
			out[id] = bind.Key
		end
		return out
	end

	local contentRestPosTab = LayersTab.Position
	local contentRestPosLayers = Layers.Position
	local restSize = DropShadowHolder.Size
	local restPos = DropShadowHolder.Position
	local isMaximized = false
	local windowTweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

	local function isHeaderOnlySize(size)
		return size.Y.Scale == 0 and size.Y.Offset <= 40
	end

	local function rememberRestGeometry()
		local size = DropShadowHolder.Size
		if not isHeaderOnlySize(size) and not isMaximized then
			restSize = size
			restPos = DropShadowHolder.Position
		end
	end

	local function showContentLayers()
		LayersTab.Position = contentRestPosTab
		Layers.Position = contentRestPosLayers
		LayersTab.Visible = true
		Layers.Visible = true
	end

	local function hideContentLayers()
		Layers.Visible = false
		LayersTab.Visible = false
		LayersTab.Position = contentRestPosTab
		Layers.Position = contentRestPosLayers
	end

	SetMinimized = function(minimized)
		if IsMinimized == minimized then return end
		IsMinimized = minimized
		minimizeToken = minimizeToken + 1
		local token = minimizeToken
		if minimized then
			rememberRestGeometry()
			hideContentLayers()
			local widthScale = DropShadowHolder.Size.X.Scale
			local widthOffset = DropShadowHolder.Size.X.Offset
			if isMaximized then
				widthScale, widthOffset = 1, 0
			elseif not isHeaderOnlySize(restSize) then
				widthScale, widthOffset = restSize.X.Scale, restSize.X.Offset
			end
			TweenService:Create(DropShadowHolder, windowTweenInfo, {
				Size = UDim2.new(widthScale, widthOffset, 0, 38)
			}):Play()
		else
			hideContentLayers()
			local targetSize = isMaximized and UDim2.new(1, 0, 1, 0) or restSize
			local targetPos = isMaximized and UDim2.new(0, 0, 0, 0) or restPos
			local sizeTween = TweenService:Create(DropShadowHolder, windowTweenInfo, {
				Size = targetSize,
				Position = targetPos,
			})
			sizeTween:Play()
			sizeTween.Completed:Connect(function()
				if token ~= minimizeToken or IsMinimized then return end
				showContentLayers()
			end)
		end
	end

	MaxRestore.Activated:Connect(function()
		CircleClick(MaxRestore, Mouse.X, Mouse.Y)
		minimizeToken = minimizeToken + 1
		local token = minimizeToken
		if IsMinimized then
			IsMinimized = false
			hideContentLayers()
		end
		if not isMaximized then
			rememberRestGeometry()
			isMaximized = true
			ImageLabel.Image = "rbxassetid://9886659001"
			local sizeTween = TweenService:Create(DropShadowHolder, windowTweenInfo, {
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
			})
			sizeTween:Play()
			sizeTween.Completed:Connect(function()
				if token ~= minimizeToken then return end
				showContentLayers()
			end)
		else
			isMaximized = false
			ImageLabel.Image = "rbxassetid://9886659406"
			hideContentLayers()
			local sizeTween = TweenService:Create(DropShadowHolder, windowTweenInfo, {
				Position = restPos,
				Size = restSize,
			})
			sizeTween:Play()
			sizeTween.Completed:Connect(function()
				if token ~= minimizeToken then return end
				showContentLayers()
			end)
		end
		expandedSize = isMaximized and UDim2.new(1, 0, 1, 0) or restSize
		OldSize = restSize
		OldPos = restPos
	end)
	Min.Activated:Connect(function()
		CircleClick(Min, Mouse.X, Mouse.Y)
		SetMinimized(not IsMinimized)
	end)
	Close.Activated:Connect(function()
		CircleClick(Close, Mouse.X, Mouse.Y)
		GuiFunc:DestroyGui()
	end)
	local mobileToggleBtn = nil
	local mobileToggleIcon = nil
	local mobileToggleCorner = nil
	local mobileCfg = {
		Size = 44,
		Corner = 10,
		Icon = "",
		Smooth = true,
		TweenTime = 0.22,
		Position = UDim2.new(0, 14, 0, 14),
	}

	local function refreshMobileToggleVisual()
		if not mobileToggleBtn then return end
		local open = DropShadowHolder.Visible
		if mobileToggleIcon and mobileToggleIcon.Visible then
			mobileToggleBtn.Text = ""
		else
			mobileToggleBtn.Text = open and "−" or "+"
		end
	end

	function GuiFunc:ToggleUI(smooth)
		local useSmooth = mobileCfg.Smooth
		if smooth ~= nil then useSmooth = not not smooth end
		local opening = not DropShadowHolder.Visible
		if useSmooth then
			if opening then
				DropShadowHolder.Visible = true
				DropShadowHolder.BackgroundTransparency = 1
				Main.BackgroundTransparency = 1
				applyBackgroundLook()
				local targetMain = Main.BackgroundTransparency
				Main.BackgroundTransparency = 1
				TweenService:Create(Main, TweenInfo.new(mobileCfg.TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = targetMain,
				}):Play()
			else
				local hideInfo = TweenInfo.new(mobileCfg.TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				local tw = TweenService:Create(Main, hideInfo, {BackgroundTransparency = 1})
				tw:Play()
				tw.Completed:Connect(function()
					DropShadowHolder.Visible = false
					applyBackgroundLook()
				end)
			end
		else
			DropShadowHolder.Visible = not DropShadowHolder.Visible
		end
		refreshMobileToggleVisual()
		return DropShadowHolder.Visible
	end

	local function ensureMobileToggle()
		if mobileToggleBtn then return mobileToggleBtn end
		local btn = Instance.new("TextButton")
		btn.Name = "FlurioreMobileToggle"
		btn.AutoButtonColor = false
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 20
		btn.TextColor3 = Color3.fromRGB(245, 245, 245)
		btn.BackgroundColor3 = Theme.Accent
		btn.BackgroundTransparency = 0.12
		btn.BorderSizePixel = 0
		btn.AnchorPoint = Vector2.new(0, 0)
		btn.Position = mobileCfg.Position
		btn.Size = UDim2.new(0, mobileCfg.Size, 0, mobileCfg.Size)
		btn.ZIndex = 100
		btn.Parent = HirimiGui
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, mobileCfg.Corner)
		corner.Parent = btn
		mobileToggleCorner = corner
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.BackgroundTransparency = 1
		icon.BorderSizePixel = 0
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.new(0.5, 0, 0.5, 0)
		icon.Size = UDim2.new(0.55, 0, 0.55, 0)
		icon.Image = mobileCfg.Icon
		icon.Visible = mobileCfg.Icon ~= ""
		icon.ZIndex = 101
		icon.Parent = btn
		mobileToggleIcon = icon
		-- drag
		local dragging, dragStart, startPos
		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = btn.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local d = input.Position - dragStart
				btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
				mobileCfg.Position = btn.Position
			end
		end)
		local clickToken = 0
		btn.Activated:Connect(function()
			-- ignore if dragged far
			GuiFunc:ToggleUI()
		end)
		mobileToggleBtn = btn
		refreshMobileToggleVisual()
		return btn
	end

	function GuiFunc:SetMobileToggle(enabledOrConfig)
		if type(enabledOrConfig) == "table" then
			local cfg = enabledOrConfig
			if cfg.Size then mobileCfg.Size = math.clamp(tonumber(cfg.Size) or mobileCfg.Size, 28, 96) end
			if cfg.Corner ~= nil then mobileCfg.Corner = math.clamp(tonumber(cfg.Corner) or mobileCfg.Corner, 0, 48) end
			if cfg.Icon ~= nil then mobileCfg.Icon = tostring(cfg.Icon or "") end
			if cfg.Smooth ~= nil then mobileCfg.Smooth = not not cfg.Smooth end
			if cfg.TweenTime then mobileCfg.TweenTime = math.clamp(tonumber(cfg.TweenTime) or mobileCfg.TweenTime, 0.05, 1) end
			if cfg.Position then mobileCfg.Position = cfg.Position end
			if cfg.Enabled == false then
				if mobileToggleBtn then mobileToggleBtn:Destroy(); mobileToggleBtn = nil; mobileToggleIcon = nil end
				return true
			end
			local btn = ensureMobileToggle()
			btn.Size = UDim2.new(0, mobileCfg.Size, 0, mobileCfg.Size)
			btn.Position = mobileCfg.Position
			if mobileToggleCorner then mobileToggleCorner.CornerRadius = UDim.new(0, mobileCfg.Corner) end
			if mobileToggleIcon then
				mobileToggleIcon.Image = mobileCfg.Icon
				mobileToggleIcon.Visible = mobileCfg.Icon ~= ""
			end
			refreshMobileToggleVisual()
			return true
		end
		local enabled = not not enabledOrConfig
		if not enabled then
			if mobileToggleBtn then mobileToggleBtn:Destroy(); mobileToggleBtn = nil; mobileToggleIcon = nil end
			return true
		end
		ensureMobileToggle()
		return true
	end

	function GuiFunc:GetMobileToggle()
		return mobileToggleBtn ~= nil
	end

	function GuiFunc:SetMobileToggleSmooth(enabled)
		mobileCfg.Smooth = not not enabled
		return true
	end

	function GuiFunc:SetMobileToggleColor(color)
		if typeof(color) ~= "Color3" then return false end
		if mobileToggleBtn then mobileToggleBtn.BackgroundColor3 = color end
		return true
	end

	function GuiFunc:ApplySafeAreaAuto()
		local inset = { Top = 0, Bottom = 0, Left = 0, Right = 0 }
		if UserInputService.TouchEnabled then
			inset.Top = 12
			inset.Bottom = 18
			inset.Left = 8
			inset.Right = 8
		end
		return GuiFunc:SetSafeArea(inset)
	end
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == toggleKey then
			GuiFunc:ToggleUI()
		end
		for _, bind in pairs(keyBinds) do
			if bind.Key == input.KeyCode then
				task.spawn(bind.Callback)
			end
		end
	end)

	local CurrentViewport = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(800, 600)
	local DesiredWidth = math.max(360, 150 + headerTitleTextWidth + headerDescriptionTextWidth)
	DesiredWidth = math.min(DesiredWidth, math.max(320, CurrentViewport.X - 24))
	local initW, initH = DesiredWidth, 350
	if type(GuiConfig.Size) == "table" then
		initW = math.max(320, tonumber(GuiConfig.Size.X) or tonumber(GuiConfig.Size.Width) or initW)
		initH = math.max(200, tonumber(GuiConfig.Size.Y) or tonumber(GuiConfig.Size.Height) or initH)
	elseif typeof(GuiConfig.Size) == "UDim2" then
		DropShadowHolder.Size = GuiConfig.Size
		initW = DropShadowHolder.Size.X.Offset
		initH = DropShadowHolder.Size.Y.Offset
	end
	if typeof(GuiConfig.Size) ~= "UDim2" then
		DropShadowHolder.Size = UDim2.new(0, initW, 0, initH)
	end
	DropShadowHolder.Position = UDim2.new(0, math.max(0, (CurrentViewport.X - (typeof(GuiConfig.Size) == "UDim2" and DropShadowHolder.AbsoluteSize.X or initW)) / 2), 0, math.max(0, (CurrentViewport.Y - initH) / 2))
	OldPos = DropShadowHolder.Position
	MakeDraggable(Top, DropShadowHolder)
	OldPos = DropShadowHolder.Position
	OldSize = DropShadowHolder.Size
	expandedSize = DropShadowHolder.Size
	restSize = DropShadowHolder.Size
	restPos = DropShadowHolder.Position

	if typeof(GuiConfig.BlurSize) == "number" then
		setSharedBlurSize(GuiConfig.BlurSize)
	end
	if GuiConfig.Blur then
		GuiFunc:SetBlur(true)
	end
if GuiConfig.BackgroundImage then
		GuiFunc:SetBackgroundImage(GuiConfig.BackgroundImage)
	end
if GuiConfig.BackgroundImageTransparency then
		GuiFunc:SetBackgroundImageTransparency(GuiConfig.BackgroundImageTransparency)
	end
	if type(GuiConfig.SafeArea) == "table" then
		GuiFunc:SetSafeArea(GuiConfig.SafeArea)
	end
	if type(GuiConfig.ThemePreset) == "string" then
		GuiFunc:SetThemePreset(GuiConfig.ThemePreset)
	end
	if GuiConfig.MobileToggle then
		GuiFunc:SetMobileToggle(true)
	end
if type(GuiConfig.MobileToggle) == "table" then
		GuiFunc:SetMobileToggle(GuiConfig.MobileToggle)
	end

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
		TabName.Size = UDim2.new(1, -48, 1, 0)
		TabName.Position = UDim2.new(0, 30, 0, 0)
		TabName.Name = "TabName"
		TabName.Parent = Tab

		local TabBadge = Instance.new("TextLabel")
		TabBadge.Name = "TabBadge"
		TabBadge.BackgroundColor3 = GuiConfig.Color
		TabBadge.BackgroundTransparency = 1
		TabBadge.BorderSizePixel = 0
		TabBadge.AnchorPoint = Vector2.new(1, 0.5)
		TabBadge.Position = UDim2.new(1, -6, 0.5, 0)
		TabBadge.Size = UDim2.new(0, 18, 0, 14)
		TabBadge.Font = Enum.Font.GothamBold
		TabBadge.TextSize = 10
		TabBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabBadge.Text = ""
		TabBadge.Visible = false
		TabBadge.ZIndex = 5
		TabBadge.Parent = Tab
		local TabBadgeCorner = Instance.new("UICorner")
		TabBadgeCorner.CornerRadius = UDim.new(0, 6)
		TabBadgeCorner.Parent = TabBadge

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
			table.insert(sectionSurfaceFrames, Section)
			Section.BackgroundTransparency = opacityLayers.Section

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
			local sectionAnimToken = 0
			local sectionTweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			local function UpdateSizeScroll()
				local OffsetY = 0
				for _, child in ScrolLayers:GetChildren() do
					if child.Name ~= "UIListLayout" then
						OffsetY = OffsetY + 3 + child.Size.Y.Offset
					end
				end
				ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
			end
			local function measureSectionHeight()
				local height = 38
				for _, v in SectionAdd:GetChildren() do
					if v:IsA("GuiObject") and v.Name ~= "UIListLayout" and v.Name ~= "UICorner" then
						height = height + v.Size.Y.Offset + 3
					end
				end
				return height
			end
			local function UpdateSizeSection()
				if not OpenSection then return end
				local SectionSizeYWitdh = measureSectionHeight()
				SectionAdd.Visible = true
				TweenService:Create(FeatureFrame, sectionTweenInfo, {Rotation = 90}):Play()
				TweenService:Create(Section, sectionTweenInfo, {Size = UDim2.new(1, 1, 0, SectionSizeYWitdh)}):Play()
				TweenService:Create(SectionAdd, sectionTweenInfo, {Size = UDim2.new(1, 0, 0, SectionSizeYWitdh - 38)}):Play()
				TweenService:Create(SectionDecideFrame, sectionTweenInfo, {Size = UDim2.new(1, 0, 0, 2)}):Play()
				sectionAnimToken = sectionAnimToken + 1
				local token = sectionAnimToken
				task.delay(0.28, function()
					if token == sectionAnimToken then
						UpdateSizeScroll()
					end
				end)
			end
			SectionButton.Activated:Connect(function()
				CircleClick(SectionButton, Mouse.X, Mouse.Y)
				sectionAnimToken = sectionAnimToken + 1
				local token = sectionAnimToken
				if OpenSection then
					SectionAdd.Visible = false
					TweenService:Create(FeatureFrame, sectionTweenInfo, {Rotation = 0}):Play()
					TweenService:Create(Section, sectionTweenInfo, {Size = UDim2.new(1, 1, 0, 30)}):Play()
					TweenService:Create(SectionDecideFrame, sectionTweenInfo, {Size = UDim2.new(0, 0, 0, 2)}):Play()
					OpenSection = false
					task.delay(0.28, function()
						if token == sectionAnimToken then
							UpdateSizeScroll()
						end
					end)
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
				ParagraphContent.RichText = true
				ParagraphContent.Text = (function(s)
					s = tostring(s or "")
					s = s:gsub("%*%*(.-)%*%*", "<b>%1</b>")
					s = s:gsub("\n", "<br/>")
					return s
				end)(ParagraphConfig.Content)
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
					local raw = tostring(ParagraphConfig.Content or "")
					raw = raw:gsub("%*%*(.-)%*%*", "<b>%1</b>")
					raw = raw:gsub("\n", "<br/>")
					ParagraphContent.RichText = true
					ParagraphContent.Text = raw
					refreshParagraphHeight()
				end
				table.insert(searchIndex, {
					frame = Paragraph,
					title = ParagraphConfig.Title,
					content = ParagraphConfig.Content,
				})
				CountItem = CountItem + 1
				return attachElementControls(ParagraphFunc, Paragraph)
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
					if isFrameLocked(Button) then return end
					CircleClick(ButtonButton, Mouse.X, Mouse.Y)
					ButtonConfig.Callback()
				end)
				table.insert(searchIndex, {
					frame = Button,
					title = ButtonConfig.Title,
					content = ButtonConfig.Content,
				})
				CountItem = CountItem + 1
				return attachElementControls(ButtonFunc, Button)
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
					if isFrameLocked(Toggle) then return end
					CircleClick(ToggleButton, Mouse.X, Mouse.Y) 
					ToggleFunc.Value = not ToggleFunc.Value
					ToggleFunc:Set(ToggleFunc.Value)
					if type(ToggleConfig.Flag) == "string" then GuiFunc:NotifyFlagChanged("Toggle", resolveFlagName(ToggleConfig.Flag)) end
				end)
				function ToggleFunc:Set(Value, fromGroup)
					ToggleFunc.Value = not not Value
					Value = ToggleFunc.Value
					if Value and type(ToggleConfig.Group) == "string" and ToggleConfig.Group ~= "" and not fromGroup then
						local group = toggleGroups[ToggleConfig.Group]
						if group then
							for _, other in ipairs(group) do
								if other ~= ToggleFunc and other.Value then
									other:Set(false, true)
								end
							end
						end
					end
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
				if type(ToggleConfig.Group) == "string" and ToggleConfig.Group ~= "" then
					toggleGroups[ToggleConfig.Group] = toggleGroups[ToggleConfig.Group] or {}
					table.insert(toggleGroups[ToggleConfig.Group], ToggleFunc)
				end
				ToggleFunc:Set(ToggleFunc.Value, true)
				table.insert(searchIndex, {
					frame = Toggle,
					title = ToggleConfig.Title,
					content = ToggleConfig.Content,
				})
				if type(ToggleConfig.Flag) == "string" and ToggleConfig.Flag ~= "" then
					GuiFunc:RegisterFlag(ToggleConfig.Flag, function()
						return ToggleFunc.Value
					end, function(value)
						ToggleFunc:Set(value)
					end, "Toggle")
				end
				CountItem = CountItem + 1
				return attachElementControls(ToggleFunc, Toggle)
			end
			function Items:AddKeybind(KeybindConfig)
				KeybindConfig = KeybindConfig or {}
				KeybindConfig.Title = KeybindConfig.Title or "Keybind"
				KeybindConfig.Content = KeybindConfig.Content or "Click then press a key"
				KeybindConfig.Default = KeybindConfig.Default
				KeybindConfig.Callback = KeybindConfig.Callback or function() end
				local KeybindFunc = {Value = KeybindConfig.Default, Listening = false}
				local Row = Instance.new("Frame")
				Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Row.BackgroundTransparency = 0.935
				Row.BorderSizePixel = 0
				Row.LayoutOrder = CountItem
				Row.Size = UDim2.new(1, 0, 0, 46)
				Row.Name = "Keybind"
				Row.Parent = SectionAdd
				local Corner = Instance.new("UICorner")
				Corner.CornerRadius = UDim.new(0, 4)
				Corner.Parent = Row
				local Title = Instance.new("TextLabel")
				Title.Font = Enum.Font.GothamBold
				Title.Text = KeybindConfig.Title
				Title.TextColor3 = Color3.fromRGB(235, 235, 235)
				Title.TextSize = 13
				Title.TextXAlignment = Enum.TextXAlignment.Left
				Title.BackgroundTransparency = 1
				Title.Position = UDim2.new(0, 10, 0, 6)
				Title.Size = UDim2.new(1, -110, 0, 14)
				Title.Parent = Row
				local Content = Instance.new("TextLabel")
				Content.Font = Enum.Font.GothamBold
				Content.Text = KeybindConfig.Content
				Content.TextColor3 = Color3.fromRGB(160, 160, 160)
				Content.TextSize = 12
				Content.TextXAlignment = Enum.TextXAlignment.Left
				Content.BackgroundTransparency = 1
				Content.Position = UDim2.new(0, 10, 0, 24)
				Content.Size = UDim2.new(1, -110, 0, 14)
				Content.Parent = Row
				local Chip = Instance.new("TextButton")
				Chip.AutoButtonColor = false
				Chip.Font = Enum.Font.GothamBold
				Chip.TextSize = 12
				Chip.TextColor3 = Color3.fromRGB(235, 235, 235)
				Chip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Chip.BackgroundTransparency = 0.9
				Chip.BorderSizePixel = 0
				Chip.AnchorPoint = Vector2.new(1, 0.5)
				Chip.Position = UDim2.new(1, -10, 0.5, 0)
				Chip.Size = UDim2.new(0, 88, 0, 26)
				Chip.Parent = Row
				local ChipCorner = Instance.new("UICorner")
				ChipCorner.CornerRadius = UDim.new(0, 6)
				ChipCorner.Parent = Chip
				local function keyName(code)
					if typeof(code) ~= "EnumItem" then return "None" end
					return code.Name
				end
				local function applyKey(code, skipCb)
					KeybindFunc.Value = code
					Chip.Text = keyName(code)
					if not skipCb then
						KeybindConfig.Callback(code)
						if type(KeybindConfig.Flag) == "string" then
							GuiFunc:NotifyFlagChanged("Keybind", resolveFlagName(KeybindConfig.Flag))
						end
					end
				end
				applyKey(KeybindConfig.Default, true)
				function KeybindFunc:Set(code)
					if code ~= nil and typeof(code) ~= "EnumItem" then return false end
					KeybindFunc.Listening = false
					Chip.TextColor3 = Color3.fromRGB(235, 235, 235)
					applyKey(code)
					return true
				end
				Chip.Activated:Connect(function()
					if KeybindFunc.Listening then return end
					KeybindFunc.Listening = true
					Chip.Text = "..."
					Chip.TextColor3 = GuiConfig.Color
					local conn
					conn = UserInputService.InputBegan:Connect(function(input, gp)
						if gp then return end
						if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
						if conn then conn:Disconnect() end
						KeybindFunc.Listening = false
						Chip.TextColor3 = Color3.fromRGB(235, 235, 235)
						applyKey(input.KeyCode)
					end)
				end)
				table.insert(searchIndex, {
					frame = Row,
					title = KeybindConfig.Title,
					content = KeybindConfig.Content,
				})
				if type(KeybindConfig.Flag) == "string" and KeybindConfig.Flag ~= "" then
					GuiFunc:RegisterFlag(KeybindConfig.Flag, function()
						local v = KeybindFunc.Value
						return v and v.Name or ""
					end, function(value)
						if type(value) == "string" and value ~= "" and Enum.KeyCode[value] then
							KeybindFunc:Set(Enum.KeyCode[value])
						elseif typeof(value) == "EnumItem" then
							KeybindFunc:Set(value)
						end
					end, "Keybind")
				end
				CountItem = CountItem + 1
				return attachElementControls(KeybindFunc, Row)
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
					if not SkipCallback then
						SliderConfig.Callback(Value)
						if type(SliderConfig.Flag) == "string" then GuiFunc:NotifyFlagChanged("Slider", resolveFlagName(SliderConfig.Flag)) end
					end
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
					local cleaned = (TextBox.Text or ""):gsub(",", ".")
					local parsed = tonumber(cleaned)
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
				table.insert(searchIndex, {
					frame = Slider,
					title = SliderConfig.Title,
					content = SliderConfig.Content,
				})
				if type(SliderConfig.Flag) == "string" and SliderConfig.Flag ~= "" then
					GuiFunc:RegisterFlag(SliderConfig.Flag, function()
						return SliderFunc.Value
					end, function(value)
						SliderFunc:Set(value, false, false)
					end, "Slider")
				end
				CountItem = CountItem + 1
				return attachElementControls(SliderFunc, Slider)
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
				function InputFunc:Set(Value, fromLoad)
					Value = tostring(Value == nil and "" or Value)
					InputTextBox.Text = Value
					InputFunc.Value = Value
					InputConfig.Callback(Value)
					if not fromLoad and type(InputConfig.Flag) == "string" then
						GuiFunc:NotifyFlagChanged("Input", resolveFlagName(InputConfig.Flag))
					end
				end
				InputTextBox.FocusLost:Connect(function()
					InputFunc:Set(InputTextBox.Text)
				end)
				table.insert(searchIndex, {
					frame = Input,
					title = InputConfig.Title,
					content = InputConfig.Content,
				})
				if type(InputConfig.Flag) == "string" and InputConfig.Flag ~= "" then
					GuiFunc:RegisterFlag(InputConfig.Flag, function()
						return InputFunc.Value
					end, function(value)
						InputFunc:Set(value)
					end, "Input")
				end
				CountItem = CountItem + 1
				return attachElementControls(InputFunc, Input)
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

				if DropdownConfig.Search then
					local SearchRow = Instance.new("Frame")
					SearchRow.BackgroundTransparency = 1
					SearchRow.BorderSizePixel = 0
					SearchRow.LayoutOrder = -1
					SearchRow.Size = UDim2.new(1, 0, 0, 28)
					SearchRow.Name = "SearchRow"
					SearchRow.Parent = ScrollSelect
					local SearchBox = Instance.new("TextBox")
					SearchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					SearchBox.BackgroundTransparency = 0.92
					SearchBox.BorderSizePixel = 0
					SearchBox.Size = UDim2.new(1, -4, 1, -2)
					SearchBox.Position = UDim2.new(0, 2, 0, 1)
					SearchBox.Font = Enum.Font.Gotham
					SearchBox.TextSize = 12
					SearchBox.TextColor3 = Color3.fromRGB(230, 230, 230)
					SearchBox.PlaceholderText = "Search..."
					SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
					SearchBox.ClearTextOnFocus = false
					SearchBox.Text = ""
					SearchBox.Name = "SearchBox"
					SearchBox.Parent = SearchRow
					local SearchCorner = Instance.new("UICorner")
					SearchCorner.CornerRadius = UDim.new(0, 4)
					SearchCorner.Parent = SearchBox
					SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
						DropdownFunc:Filter(SearchBox.Text)
					end)
				end

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
					local selectedValues = DropdownFunc.Value
					if type(selectedValues) ~= "table" then
						selectedValues = selectedValues == nil and {} or {selectedValues}
						DropdownFunc.Value = selectedValues
					end
					for _, Drop in ipairs(ScrollSelect:GetChildren()) do
						-- SearchRow and UIListLayout are not selectable option frames.
						if Drop.Name == "Option" and Drop:IsA("GuiObject") then
							local optionText = Drop:FindFirstChild("OptionText")
							local chooseFrame = Drop:FindFirstChild("ChooseFrame")
							local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")
							if optionText and chooseFrame and chooseStroke then
								local isSelected = table.find(selectedValues, optionText.Text) ~= nil
								if isSelected then
									TweenService:Create(
										chooseStroke,
										TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
										{Transparency = 0}
									):Play()
									TweenService:Create(
										chooseFrame,
										TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
										{Size = UDim2.new(0, 1, 0, 12)}
									):Play()
									TweenService:Create(
										Drop,
										TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
										{BackgroundTransparency = 0.935}
									):Play()
								else
									TweenService:Create(
										chooseFrame,
										TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
										{Size = UDim2.new(0, 0, 0, 0)}
									):Play()
									TweenService:Create(
										chooseStroke,
										TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
										{Transparency = 0.999}
									):Play()
									TweenService:Create(
										Drop,
										TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
										{BackgroundTransparency = 0.999}
									):Play()
								end
							end
						end
					end
					local DropdownValueTable = table.concat(DropdownFunc.Value, ", ")
					if DropdownValueTable == "" then
						OptionSelecting.Text = "Select Options"
					else
						OptionSelecting.Text = tostring(DropdownValueTable)
					end
					DropdownConfig.Callback(DropdownFunc.Value)
					if type(DropdownConfig.Flag) == "string" then
						GuiFunc:NotifyFlagChanged("Dropdown", resolveFlagName(DropdownConfig.Flag))
					end
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
				function DropdownFunc:Filter(query)
					local q = string.lower(tostring(query or ""))
					for _, Drop in ipairs(ScrollSelect:GetChildren()) do
						if Drop.Name == "Option" then
							local label = Drop:FindFirstChild("OptionText")
							local text = label and string.lower(tostring(label.Text)) or ""
							Drop.Visible = (q == "" or string.find(text, q, 1, true) ~= nil)
						end
					end
					return true
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
				table.insert(searchIndex, {
					frame = Dropdown,
					title = DropdownConfig.Title,
					content = DropdownConfig.Content,
				})
				if type(DropdownConfig.Flag) == "string" and DropdownConfig.Flag ~= "" then
					GuiFunc:RegisterFlag(DropdownConfig.Flag, function()
						return DropdownFunc.Value
					end, function(value)
						DropdownFunc:Set(value)
					end, "Dropdown")
				end
				CountItem = CountItem + 1
				CountDropdown = CountDropdown + 1
				return attachElementControls(DropdownFunc, Dropdown)
			end
			CountSection = CountSection + 1
			function Items:Open()
				if not OpenSection then
					OpenSection = true
					UpdateSizeSection()
				end
				return true
			end
			function Items:Close()
				if OpenSection then
					sectionAnimToken = sectionAnimToken + 1
					local token = sectionAnimToken
					SectionAdd.Visible = false
					TweenService:Create(FeatureFrame, sectionTweenInfo, {Rotation = 0}):Play()
					TweenService:Create(Section, sectionTweenInfo, {Size = UDim2.new(1, 1, 0, 30)}):Play()
					TweenService:Create(SectionDecideFrame, sectionTweenInfo, {Size = UDim2.new(0, 0, 0, 2)}):Play()
					OpenSection = false
					task.delay(0.28, function()
						if token == sectionAnimToken then
							UpdateSizeScroll()
						end
					end)
				end
				return true
			end
			function Items:IsOpen()
				return OpenSection
			end
			local virtualEnabled = false
			local virtualWindow = 14
			local function refreshVirtual()
				if not virtualEnabled then return end
				local kids = {}
				for _, child in ipairs(SectionAdd:GetChildren()) do
					if child:IsA("GuiObject") and child.Name ~= "UIListLayout" and child.Name ~= "UICorner" and child.Name ~= "SearchRow" then
						table.insert(kids, child)
					end
				end
				table.sort(kids, function(a, b)
					return (a.LayoutOrder or 0) < (b.LayoutOrder or 0)
				end)
				local total = #kids
				if total <= virtualWindow then
					for _, child in ipairs(kids) do child.Visible = true end
					return
				end
				-- Estimate index from cumulative Size.Y (stable; does not rely on AbsolutePosition)
				local canvasY = ScrolLayers.CanvasPosition.Y
				local viewH = math.max(1, ScrolLayers.AbsoluteWindowSize.Y)
				local acc = 0
				local mid = canvasY + viewH * 0.5
				local best = 1
				for i, child in ipairs(kids) do
					local h = math.max(1, child.Size.Y.Offset)
					local center = acc + h * 0.5
					if center >= mid then best = i break end
					acc = acc + h + 3
					best = i
				end
				local half = math.floor(virtualWindow / 2)
				local fromI = math.max(1, best - half)
				local toI = math.min(total, fromI + virtualWindow - 1)
				fromI = math.max(1, toI - virtualWindow + 1)
				for i, child in ipairs(kids) do
					child.Visible = (i >= fromI and i <= toI)
				end
			end
			function Items:EnableVirtual(windowSize)
				virtualEnabled = true
				virtualWindow = math.max(6, math.floor(tonumber(windowSize) or 14))
				refreshVirtual()
				return true
			end
			function Items:DisableVirtual()
				virtualEnabled = false
				for _, child in ipairs(SectionAdd:GetChildren()) do
					if child:IsA("GuiObject") then child.Visible = true end
				end
				return true
			end
			ScrolLayers:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				if virtualEnabled then refreshVirtual() end
			end)
			SectionAdd.ChildAdded:Connect(function()
				if virtualEnabled then task.defer(refreshVirtual) end
			end)
			function Items:AddColorPicker(ColorConfig)
				ColorConfig = ColorConfig or {}
				ColorConfig.Title = ColorConfig.Title or "Color"
				ColorConfig.Content = ColorConfig.Content or "Pick a color"
				ColorConfig.Default = typeof(ColorConfig.Default) == "Color3" and ColorConfig.Default or Theme.Accent
				ColorConfig.Callback = ColorConfig.Callback or function() end
				local ColorFunc = {Value = ColorConfig.Default}
				local Row = Instance.new("Frame")
				Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Row.BackgroundTransparency = 0.935
				Row.BorderSizePixel = 0
				Row.LayoutOrder = CountItem
				Row.Size = UDim2.new(1, 0, 0, 46)
				Row.Name = "ColorPicker"
				Row.Parent = SectionAdd
				local Corner = Instance.new("UICorner")
				Corner.CornerRadius = UDim.new(0, 4)
				Corner.Parent = Row
				local Title = Instance.new("TextLabel")
				Title.Font = Enum.Font.GothamBold
				Title.Text = ColorConfig.Title
				Title.TextColor3 = Color3.fromRGB(235, 235, 235)
				Title.TextSize = 13
				Title.TextXAlignment = Enum.TextXAlignment.Left
				Title.BackgroundTransparency = 1
				Title.Position = UDim2.new(0, 10, 0, 6)
				Title.Size = UDim2.new(1, -70, 0, 14)
				Title.Parent = Row
				local Content = Instance.new("TextLabel")
				Content.Font = Enum.Font.GothamBold
				Content.Text = ColorConfig.Content
				Content.TextColor3 = Color3.fromRGB(160, 160, 160)
				Content.TextSize = 12
				Content.TextXAlignment = Enum.TextXAlignment.Left
				Content.BackgroundTransparency = 1
				Content.Position = UDim2.new(0, 10, 0, 24)
				Content.Size = UDim2.new(1, -70, 0, 14)
				Content.Parent = Row
				local Swatch = Instance.new("TextButton")
				Swatch.Text = ""
				Swatch.AutoButtonColor = false
				Swatch.BackgroundColor3 = ColorConfig.Default
				Swatch.BorderSizePixel = 0
				Swatch.AnchorPoint = Vector2.new(1, 0.5)
				Swatch.Position = UDim2.new(1, -12, 0.5, 0)
				Swatch.Size = UDim2.new(0, 28, 0, 28)
				Swatch.Parent = Row
				local SwatchCorner = Instance.new("UICorner")
				SwatchCorner.CornerRadius = UDim.new(0, 6)
				SwatchCorner.Parent = Swatch
				local Hue, Sat, Val = ColorConfig.Default:ToHSV()
				local function applyColor(c, fromLoad)
					ColorFunc.Value = c
					Swatch.BackgroundColor3 = c
					Hue, Sat, Val = c:ToHSV()
					ColorConfig.Callback(c)
					if not fromLoad and type(ColorConfig.Flag) == "string" then
						GuiFunc:NotifyFlagChanged("ColorPicker", resolveFlagName(ColorConfig.Flag))
					end
				end
				function ColorFunc:Set(c)
					if typeof(c) ~= "Color3" then return false end
					applyColor(c)
					return true
				end
				function ColorFunc:SetHSV(h, s, v)
					h = math.clamp(tonumber(h) or Hue, 0, 1)
					s = math.clamp(tonumber(s) or Sat, 0, 1)
					v = math.clamp(tonumber(v) or Val, 0, 1)
					applyColor(Color3.fromHSV(h, s, v))
					return true
				end
				Swatch.Activated:Connect(function()
					Hue = (Hue + 0.045) % 1
					applyColor(Color3.fromHSV(Hue, math.clamp(Sat, 0.55, 1), math.clamp(Val, 0.75, 1)))
				end)
				table.insert(searchIndex, {
					frame = Row,
					title = ColorConfig.Title,
					content = ColorConfig.Content,
				})
				if type(ColorConfig.Flag) == "string" and ColorConfig.Flag ~= "" then
					GuiFunc:RegisterFlag(ColorConfig.Flag, function()
						local c = ColorFunc.Value
						return {c.R, c.G, c.B}
					end, function(value)
						if type(value) == "table" and #value >= 3 then
							ColorFunc:Set(Color3.new(value[1], value[2], value[3]))
						end
					end, "ColorPicker")
				end
				CountItem = CountItem + 1
				return attachElementControls(ColorFunc, Row)
			end
			return Items
		end
		function Sections:SetBadge(text)
			local label = tostring(text or "")
			if label == "" then
				TabBadge.Visible = false
				TabBadge.Text = ""
				TabBadge.BackgroundTransparency = 1
			else
				TabBadge.Text = label
				TabBadge.Visible = true
				TabBadge.BackgroundTransparency = 0.15
				TabBadge.BackgroundColor3 = Theme.Accent
			end
			return true
		end
		function Sections:ClearBadge()
			return Sections:SetBadge("")
		end
		CountTab = CountTab + 1
		return Sections
	end
	return Tabs
end
return FlurioreLib