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

	DropShadow.Image = ""
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

			local notifyButtons = type(NotifyConfig.Buttons) == "table" and NotifyConfig.Buttons or nil
			if notifyButtons and #notifyButtons > 0 then
				local rowY = 27 + notifyContentHeight + 8
				local buttonRow = Instance.new("Frame")
				buttonRow.Name = "NotifyButtons"
				buttonRow.BackgroundTransparency = 1
				buttonRow.BorderSizePixel = 0
				buttonRow.Position = UDim2.new(0, 10, 0, rowY)
				buttonRow.Size = UDim2.new(1, -20, 0, 22)
				buttonRow.Parent = NotifyFrameReal
				local rowLayout = Instance.new("UIListLayout")
				rowLayout.FillDirection = Enum.FillDirection.Horizontal
				rowLayout.Padding = UDim.new(0, 6)
				rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
				rowLayout.Parent = buttonRow
				for i, b in ipairs(notifyButtons) do
					local nb = Instance.new("TextButton")
					nb.Name = "NotifyButton" .. i
					nb.Text = tostring(b.Title or b.Name or "OK")
					nb.Font = Enum.Font.GothamBold
					nb.TextSize = 11
					nb.TextColor3 = (i == 1) and NotifyConfig.Color or Color3.fromRGB(200, 200, 205)
					nb.AutoButtonColor = false
					nb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					nb.BackgroundTransparency = 0.935
					nb.BorderSizePixel = 0
					nb.LayoutOrder = i
					nb.Size = UDim2.new(1 / #notifyButtons, -6, 1, 0)
					nb.Parent = buttonRow
					local nbCorner = Instance.new("UICorner")
					nbCorner.CornerRadius = UDim.new(0, 4)
					nbCorner.Parent = nb
					nb.Activated:Connect(function()
						if type(b.Callback) == "function" then
							task.spawn(b.Callback, NotifyFunction)
						end
						if b.Close ~= false then
							NotifyFunction:Close()
						end
					end)
				end
				frameHeight = rowY + 22 + 14
				NotifyFrame.Size = UDim2.new(1, 0, 0, frameHeight)
			end


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
		local inInfo = TweenInfo.new(NotifyConfig.Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
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

-- Key services registry (same idea as WindUI.Services). Register once, use by name:
--   FlurioreLib.Services.myservice = {
--     Args = {"ServiceId"},                              -- names you pass in ServiceArgs (informational)
--     Verify = function(key, ctx) return ok, message end, -- required for this service
--     GetKey = function(ctx) end,                        -- optional: action for the Get key button
--     Url = "https://...",                               -- optional: opened by Get key when GetKey is missing
--     GetKeyLabel = "Get key",                           -- optional
--   }
-- ctx = {Key, Uid, Args (ServiceArgs), Status(text, color), Copy(text)}
FlurioreLib.Services = FlurioreLib.Services or {}

-- Key gate: blocks until a key is accepted, then returns true.
-- Every option is optional. Mix what you need:
--   FlurioreLib:RequireKey({
--     Title = "Hub", Subtitle = "Enter your key", VerifyLabel = "Verify", GetKeyLabel = "Get key",
--     Logo = "rbxassetid://..."  -- or LogoFile = "logo.png" (getcustomasset)
--     Keys = {"KEY-ONE", {Key = "TRIAL", Label = "Trial", Expires = os.time() + 86400}},
--     CaseSensitive = true,
--     Verify = function(key, ctx) return ok, message end,   -- your own Lua check (or Validator)
--     Service = "myservice", ServiceArgs = {ServiceId = "abc"},
--     Api = {                                                -- HTTP check, any response shape
--       Url = "https://your-server/check?key={key}&uid={uid}", Method = "GET" | "POST",
--       Headers = {}, Extra = {}, KeyParam = "key", UidParam = "uid",
--       Request = function(key, uid) return body, statusCode end,   -- optional: own transport
--       Parse = function(body, statusCode, key) return ok, message end, -- optional: own parser
--       ValidPath = "data.valid", MessagePath = "message",            -- used when Parse is missing
--     },
--     GetKeyLinks = {                                        -- any buttons, any count
--       {Label = "Discord", Url = "https://discord.gg/..."},
--       {Label = "Copy key", Action = function(ctx) ctx.Copy("KEY-ONE") ctx.Status("Copied") end},
--     },
--     GetKeyUrl = "https://...",                             -- single-link shorthand
--     Save = true, SaveFile = "FlurioreKey.txt",
--   })
-- Get key: an Action runs your function. A Url opens in a browser; if that fails, it is copied.
-- Keys, Verify and Service run inside the script, so they can be read. Use Api or a Service
-- when the check must happen on a server. The gate itself is client-side.
function FlurioreLib:RequireKey(KeyConfig)
    KeyConfig = KeyConfig or {}
    local Players = game:GetService("Players")
    local GuiService = game:GetService("GuiService")
    local LocalPlayer = Players.LocalPlayer
    local title = tostring(KeyConfig.Title or "Script")
    local subtitle = tostring(KeyConfig.Subtitle or "Enter your key to continue")
    local verifyLabel = tostring(KeyConfig.VerifyLabel or "Verify")
    local theme = type(KeyConfig.Theme) == "table" and KeyConfig.Theme or {}
    local accent = theme.Accent or (typeof(KeyConfig.Accent) == "Color3" and KeyConfig.Accent) or Color3.fromRGB(255, 0, 255)
    local textColor = theme.Text or Color3.fromRGB(235, 235, 235)
    local bgColor = theme.Background or Color3.fromRGB(15, 15, 15)
    local borderColor = theme.Border or Color3.fromRGB(50, 50, 50)
    local good = accent
    local bad = Color3.fromRGB(255, 110, 110)
    local muted = theme.MutedText or Color3.fromRGB(160, 160, 160)
    local saveEnabled = KeyConfig.Save ~= false
    local saveFile = tostring(KeyConfig.SaveFile or "FlurioreKey.txt")
    local caseSensitive = KeyConfig.CaseSensitive ~= false
    local finished = Instance.new("BindableEvent")
    local setStatus, copyText -- assigned in the UI section; used by actions and services

    -- service: a registered name, or a table passed directly
    local service = nil
    if type(KeyConfig.Service) == "string" then
        service = FlurioreLib.Services[KeyConfig.Service]
    elseif type(KeyConfig.Service) == "table" then
        service = KeyConfig.Service
    end

    -- local keys: plain strings or {Key = "...", Label = "...", Expires = os.time()}
    local keyList = {}
    for _, entry in ipairs(KeyConfig.Keys or {}) do
        if type(entry) == "string" then
            table.insert(keyList, {Key = entry})
        elseif type(entry) == "table" and type(entry.Key) == "string" then
            table.insert(keyList, {Key = entry.Key, Label = entry.Label, Expires = tonumber(entry.Expires)})
        end
    end

    -- Get key buttons: {Label, Url} or {Label, Action}
    local buttons = {}
    if type(KeyConfig.GetKeyLinks) == "table" then
        for _, item in ipairs(KeyConfig.GetKeyLinks) do
            if type(item) == "table" then
                local label = tostring(item.Label or "Get key")
                if type(item.Action) == "function" then
                    table.insert(buttons, {Label = label, Action = item.Action})
                elseif type(item.Url) == "string" and item.Url ~= "" then
                    table.insert(buttons, {Label = label, Url = item.Url})
                end
            end
        end
    end
    if #buttons == 0 and type(KeyConfig.GetKeyUrl) == "string" and KeyConfig.GetKeyUrl ~= "" then
        table.insert(buttons, {Label = tostring(KeyConfig.GetKeyLabel or "Get key"), Url = KeyConfig.GetKeyUrl})
    end
    if #buttons == 0 and service then
        local label = tostring(service.GetKeyLabel or KeyConfig.GetKeyLabel or "Get key")
        if type(service.GetKey) == "function" then
            table.insert(buttons, {Label = label, Action = service.GetKey})
        elseif type(service.Url) == "string" and service.Url ~= "" then
            table.insert(buttons, {Label = label, Url = service.Url})
        end
    end

    local function tw(obj, time, goal, style, dir)
        return TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), goal)
    end

    local function sameKey(a, b)
        if caseSensitive then return a == b end
        return string.lower(a) == string.lower(b)
    end

    local function getPath(data, path)
        local node = data
        for part in string.gmatch(path, "[^%.]+") do
            if type(node) ~= "table" then return nil end
            node = node[part]
        end
        return node
    end

    local function isTruthy(v)
        return v == true or v == "true" or v == 1 or v == "1"
    end

    local function readSavedKey()
        if not saveEnabled or type(isfile) ~= "function" or type(readfile) ~= "function" then return nil end
        local ok, result = pcall(function()
            if isfile(saveFile) then return readfile(saveFile) end
        end)
        if ok and type(result) == "string" and result ~= "" then return result end
        return nil
    end

    -- context handed to Verify, Api hooks and button actions
    local function makeCtx(key)
        return {
            Key = key,
            Uid = LocalPlayer and LocalPlayer.UserId or 0,
            Args = KeyConfig.ServiceArgs or {},
            Status = function(text, color)
                setStatus(tostring(text), color or muted)
            end,
            Copy = function(text)
                return copyText(tostring(text))
            end,
        }
    end

    -- Api: custom transport (Request) and parser (Parse) are optional overrides
    local function callApi(api, key, ctx)
        local responseBody, statusCode
        if type(api.Request) == "function" then
            local okReq, body, code = pcall(api.Request, key, ctx.Uid)
            if not okReq then return false, "Request error" end
            responseBody, statusCode = body, code
        else
            local params = {}
            if type(api.Extra) == "table" then
                for k, v in pairs(api.Extra) do params[tostring(k)] = tostring(v) end
            end
            params[tostring(api.KeyParam or "key")] = key
            params[tostring(api.UidParam or "uid")] = tostring(ctx.Uid)

            local method = string.upper(tostring(api.Method or "GET"))
            local url = tostring(api.Url)
            local usedPlaceholder = false
            url = string.gsub(url, "{key}", function()
                usedPlaceholder = true
                return HttpService:UrlEncode(key)
            end)
            url = string.gsub(url, "{uid}", function()
                return HttpService:UrlEncode(tostring(ctx.Uid))
            end)

            local bodyText = nil
            if method == "GET" then
                if not usedPlaceholder then
                    local pieces = {}
                    for k, v in pairs(params) do
                        table.insert(pieces, HttpService:UrlEncode(k) .. "=" .. HttpService:UrlEncode(v))
                    end
                    if #pieces > 0 then
                        url = url .. (string.find(url, "?", 1, true) and "&" or "?") .. table.concat(pieces, "&")
                    end
                end
            else
                bodyText = HttpService:JSONEncode(params)
            end

            local requestFn = (type(request) == "function" and request) or (type(http_request) == "function" and http_request) or nil
            if requestFn then
                local headers = {}
                if type(api.Headers) == "table" then
                    for k, v in pairs(api.Headers) do headers[tostring(k)] = tostring(v) end
                end
                if bodyText and headers["Content-Type"] == nil then
                    headers["Content-Type"] = "application/json"
                end
                local okReq, res = pcall(requestFn, {Url = url, Method = method, Headers = headers, Body = bodyText})
                if not okReq or type(res) ~= "table" then return false, "Server unreachable" end
                responseBody = res.Body
                statusCode = res.StatusCode
            elseif method == "GET" then
                local okGet, body = pcall(function() return game:HttpGet(url) end)
                if not okGet then return false, "Server unreachable" end
                responseBody = body
            else
                return false, "POST needs executor request()"
            end
        end

        if type(api.Parse) == "function" then
            local okParse, ok, message = pcall(api.Parse, responseBody, statusCode, key)
            if not okParse then return false, "Parse error" end
            return isTruthy(ok), message
        end

        if type(responseBody) ~= "string" then return false, "Bad server response" end
        local okDecode, data = pcall(function() return HttpService:JSONDecode(responseBody) end)
        if not okDecode or type(data) ~= "table" then return false, "Bad server response" end
        local valid = getPath(data, tostring(api.ValidPath or "valid"))
        local message = getPath(data, tostring(api.MessagePath or "message"))
        if isTruthy(valid) or (api.SuccessValue ~= nil and valid == api.SuccessValue) then
            return true, message
        end
        if type(message) ~= "string" or message == "" then
            if type(statusCode) == "number" and statusCode >= 400 then
                message = "Server error " .. tostring(statusCode)
            else
                message = "Invalid key"
            end
        end
        return false, message
    end

    local function checkKey(key)
        for _, entry in ipairs(keyList) do
            if sameKey(key, entry.Key) then
                if entry.Expires and os.time() > entry.Expires then
                    return false, "Key expired"
                end
                return true, entry.Label
            end
        end

        local ctx = makeCtx(key)

        local verifyFn = KeyConfig.Verify or KeyConfig.Validator
        if type(verifyFn) == "function" then
            local ok, valid, message = pcall(verifyFn, key, ctx)
            if not ok then return false, "Verify error" end
            return isTruthy(valid), message
        end

        if service and type(service.Verify) == "function" then
            local ok, valid, message = pcall(service.Verify, key, ctx)
            if not ok then return false, "Service error" end
            return isTruthy(valid), message
        end

        local api = KeyConfig.Api
        if type(api) == "string" then
            api = {Url = api}
        elseif type(api) ~= "table" and type(KeyConfig.Validate) == "string" then
            api = {Url = KeyConfig.Validate}
        end
        if type(api) == "table" and (type(api.Url) == "string" or type(api.Request) == "function") then
            local okCall, ok, message = pcall(callApi, api, key, ctx)
            if not okCall then return false, "Server error" end
            return ok, message
        end

        if #keyList > 0 then return false, "Invalid key" end
        return false, "No key source configured"
    end

    -- UI: same surface, border, radius, fonts and accent as the main menu ------
    local CARD_W = 320
    local statusY = 150
    local linkTop = 176
    local cardH = (#buttons > 0) and (linkTop + #buttons * 24 + 8) or (statusY + 14 + 14)
    local restPos = UDim2.new(0.5, 0, 0.5, 0)

    local parent = nil
    pcall(function()
        if type(gethui) == "function" then
            parent = gethui()
        else
            parent = game:GetService("CoreGui")
        end
    end)
    if not parent then
        parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FlurKeyGate"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 1000
    gui.Parent = parent

    local card = Instance.new("Frame")
    card.Name = "Card"
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = restPos
    card.Size = UDim2.new(0, CARD_W, 0, cardH)
    card.BackgroundColor3 = bgColor
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = gui
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = borderColor
    cardStroke.Thickness = 1
    cardStroke.Transparency = 0.5
    cardStroke.Parent = card

    -- top bar: logo (optional) and title, separated by a hairline like the main menu
    local hasLogo = false
    local topLogo = nil
    if type(KeyConfig.Logo) == "string" and KeyConfig.Logo:find("rbxassetid", 1, true) then
        topLogo = Instance.new("ImageLabel")
        topLogo.Image = KeyConfig.Logo
    elseif type(KeyConfig.LogoFile) == "string" and type(getcustomasset) == "function" then
        local okAsset, asset = pcall(getcustomasset, KeyConfig.LogoFile)
        if okAsset and asset then
            topLogo = Instance.new("ImageLabel")
            topLogo.Image = asset
        end
    end
    if topLogo then
        hasLogo = true
        topLogo.Name = "Logo"
        topLogo.BackgroundTransparency = 1
        topLogo.AnchorPoint = Vector2.new(0, 0.5)
        topLogo.Position = UDim2.new(0, 12, 0, 19)
        topLogo.Size = UDim2.new(0, 16, 0, 16)
        topLogo.Parent = card
    end

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextColor3 = textColor
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.Position = UDim2.new(0, hasLogo and 36 or 12, 0, 0)
    titleLabel.Size = UDim2.new(1, -(hasLogo and 48 or 24), 0, 38)
    titleLabel.Parent = card

    local topLine = Instance.new("Frame")
    topLine.Name = "TopLine"
    topLine.Position = UDim2.new(0, 0, 0, 38)
    topLine.Size = UDim2.new(1, 0, 0, 1)
    topLine.BackgroundColor3 = borderColor
    topLine.BackgroundTransparency = 0.5
    topLine.BorderSizePixel = 0
    topLine.Parent = card

    local subLabel = Instance.new("TextLabel")
    subLabel.Name = "Subtitle"
    subLabel.BackgroundTransparency = 1
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextSize = 12
    subLabel.TextColor3 = muted
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.Text = subtitle
    subLabel.Position = UDim2.new(0, 12, 0, 46)
    subLabel.Size = UDim2.new(1, -24, 0, 16)
    subLabel.Parent = card

    -- input: same fill as the menu's element rows
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "Input"
    inputFrame.Position = UDim2.new(0, 12, 0, 70)
    inputFrame.Size = UDim2.new(1, -24, 0, 32)
    inputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    inputFrame.BackgroundTransparency = 0.935
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = card
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = inputFrame
    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = accent
    inputStroke.Thickness = 1
    inputStroke.Transparency = 1
    inputStroke.Parent = inputFrame

    local box = Instance.new("TextBox")
    box.Name = "KeyBox"
    box.BackgroundTransparency = 1
    box.Position = UDim2.new(0, 10, 0, 0)
    box.Size = UDim2.new(1, -20, 1, 0)
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.TextColor3 = textColor
    box.PlaceholderText = tostring(KeyConfig.Placeholder or "Enter your key")
    box.PlaceholderColor3 = muted
    box.Text = ""
    box.ClearTextOnFocus = false
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Parent = inputFrame

    local verify = Instance.new("TextButton")
    verify.Name = "Verify"
    verify.Text = verifyLabel
    verify.Font = Enum.Font.GothamBold
    verify.TextSize = 12
    verify.TextColor3 = bgColor
    verify.AutoButtonColor = false
    verify.BackgroundColor3 = accent
    verify.BackgroundTransparency = 0
    verify.BorderSizePixel = 0
    verify.Position = UDim2.new(0, 12, 0, 110)
    verify.Size = UDim2.new(1, -24, 0, 32)
    verify.Parent = card
    local verifyCorner = Instance.new("UICorner")
    verifyCorner.CornerRadius = UDim.new(0, 4)
    verifyCorner.Parent = verify

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = 11
    status.TextColor3 = muted
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextTruncate = Enum.TextTruncate.AtEnd
    status.Text = ""
    status.Position = UDim2.new(0, 12, 0, statusY)
    status.Size = UDim2.new(1, -24, 0, 14)
    status.Parent = card

    setStatus = function(text, color)
        status.Text = text
        tw(status, 0.2, {TextColor3 = color or muted}, Enum.EasingStyle.Quad):Play()
    end

    copyText = function(text)
        if type(setclipboard) == "function" then
            return (pcall(setclipboard, text))
        end
        return false
    end

    local function openLink(url, label)
        local okOpen = pcall(function() GuiService:OpenBrowserWindow(url) end)
        if okOpen then
            setStatus("Opened " .. label, muted)
        elseif copyText(url) then
            setStatus("Couldn't open it. Link copied", muted)
        else
            setStatus(url, muted)
        end
    end

    local function runButton(b)
        if b.Action then
            local okAct, err = pcall(b.Action, makeCtx(nil))
            if not okAct then
                setStatus("Action failed", bad)
                warn("[RequireKey] action error: " .. tostring(err))
            end
        else
            openLink(b.Url, b.Label)
        end
    end

    -- Get key: plain text rows under a hairline, like the menu's secondary actions
    if #buttons > 0 then
        local sep = Instance.new("Frame")
        sep.Name = "Separator"
        sep.Position = UDim2.new(0, 12, 0, linkTop - 8)
        sep.Size = UDim2.new(1, -24, 0, 1)
        sep.BackgroundColor3 = borderColor
        sep.BackgroundTransparency = 0.5
        sep.BorderSizePixel = 0
        sep.Parent = card
    end
    for i, b in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Name = "GetKey" .. i
        btn.Text = b.Label
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.TextColor3 = muted
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.Position = UDim2.new(0, 12, 0, linkTop + (i - 1) * 24)
        btn.Size = UDim2.new(1, -24, 0, 22)
        btn.Parent = card
        btn.MouseEnter:Connect(function() tw(btn, 0.18, {TextColor3 = textColor}, Enum.EasingStyle.Quad):Play() end)
        btn.MouseLeave:Connect(function() tw(btn, 0.18, {TextColor3 = muted}, Enum.EasingStyle.Quad):Play() end)
        btn.Activated:Connect(function() runButton(b) end)
    end

    local function shake()
        local offsets = {-8, 7, -5, 3, -1, 0}
        local function step(k)
            if k > #offsets then
                card.Position = restPos
                return
            end
            local t = tw(card, 0.05, {Position = restPos + UDim2.new(0, offsets[k], 0, 0)}, Enum.EasingStyle.Quad)
            t:Play()
            t.Completed:Connect(function() step(k + 1) end)
        end
        step(1)
    end

    local function fadeTree(root, info)
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("GuiObject") then
                local goal = {BackgroundTransparency = 1}
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then goal.TextTransparency = 1 end
                if d:IsA("ImageLabel") or d:IsA("ImageButton") then goal.ImageTransparency = 1 end
                TweenService:Create(d, info, goal):Play()
            elseif d:IsA("UIStroke") then
                TweenService:Create(d, info, {Transparency = 1}):Play()
            end
        end
        TweenService:Create(root, info, {BackgroundTransparency = 1}):Play()
    end

    local function fadeOutCard()
        fadeTree(card, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.In))
        tw(card, 0.3, {Position = restPos + UDim2.new(0, 0, 0, 16)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In):Play()
    end

    local function success(label)
        setStatus(type(label) == "string" and label ~= "" and ("Access granted: " .. label) or "Access granted", good)
        task.delay(0.5, function()
            fadeOutCard()
            task.delay(0.3, function()
                gui:Destroy()
                finished:Fire(true)
            end)
        end)
    end

    local busy = false
    local function attempt(rawKey)
        if busy then return end
        local key = tostring(rawKey or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if #key < 1 then
            setStatus("Enter a key first", bad)
            shake()
            return
        end
        busy = true
        setStatus("Checking...", muted)
        task.spawn(function()
            local ok, message = checkKey(key)
            busy = false
            if ok then
                if saveEnabled and type(writefile) == "function" then
                    pcall(writefile, saveFile, key)
                end
                success(message)
            else
                setStatus(type(message) == "string" and message ~= "" and message or "Invalid key", bad)
                shake()
            end
        end)
    end

    verify.Activated:Connect(function() attempt(box.Text) end)
    box.FocusLost:Connect(function(enterPressed)
        tw(inputStroke, 0.2, {Transparency = 1}, Enum.EasingStyle.Quad):Play()
        if enterPressed then attempt(box.Text) end
    end)
    box.Focused:Connect(function()
        tw(inputStroke, 0.2, {Transparency = 0.4}, Enum.EasingStyle.Quad):Play()
    end)
    verify.MouseEnter:Connect(function() tw(verify, 0.18, {BackgroundTransparency = 0.12}, Enum.EasingStyle.Quad):Play() end)
    verify.MouseLeave:Connect(function() tw(verify, 0.18, {BackgroundTransparency = 0}, Enum.EasingStyle.Quad):Play() end)

    -- intro: rise and fade in, the same motion as the main window
    card.Position = restPos + UDim2.new(0, 0, 0, 16)
    tw(card, 0.45, {Position = restPos, BackgroundTransparency = 0.3}):Play()

    -- remembered key: check it quietly once the card is in
    local saved = readSavedKey()
    if saved then
        box.Text = saved
        setStatus("Checking saved key...", muted)
        task.delay(0.6, function() attempt(saved) end)
    end

    finished.Event:Wait()
    finished:Destroy()
    return true
end

function FlurioreLib:MakeGui(GuiConfig)
	local GuiConfig = GuiConfig or {}
	-- Key system (off by default). KeySystem = true + KeySettings = {...} blocks here until a key is accepted.
	if GuiConfig.KeySystem then
		local source = type(GuiConfig.KeySettings) == "table" and GuiConfig.KeySettings or {}
		local settings = {}
		for k, v in pairs(source) do settings[k] = v end
		if settings.Theme == nil then
			local keyTheme = {}
			for k, v in pairs(ThemePresets[GuiConfig.ThemePreset or "Dark"] or ThemePresets.Dark) do keyTheme[k] = v end
			if type(GuiConfig.Theme) == "table" then
				for k, v in pairs(GuiConfig.Theme) do keyTheme[k] = v end
			end
			settings.Theme = keyTheme
		end
		if not FlurioreLib:RequireKey(settings) then
			return nil
		end
	end
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
		if object:GetAttribute("FlurRaw") then return end
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
	DropShadow.Image = ""
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
	UIStroke.Thickness = 1
	UIStroke.Transparency = 0.5
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
	LayersPageLayout.TweenTime = 0.42
	LayersPageLayout.EasingDirection = Enum.EasingDirection.Out
	LayersPageLayout.EasingStyle = Enum.EasingStyle.Quint
	-- stop UIPageLayout's own touch paging; the tab swipe handler below does it instead
	pcall(function()
		LayersPageLayout.TouchInputEnabled = false
	end)
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

	local windowOpacity = 0.3
	local blurEnabled = false
	local blurOwned = false
	local blurFrost = 0.35
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
	-- Real glass (opt-in: GuiConfig.RealGlass = true; GuiConfig.RealGlassIntensity 0..1, default 1).
	-- Adapted from MacLib's acrylic technique. The panel's screen rectangle is projected onto thin,
	-- nearly invisible glass wedges just in front of the camera. DepthOfField uses only NearIntensity,
	-- so the blur applies to depth near the camera (the wedges) while the far world stays sharp.
	-- Objects closer than about 1.6 studs are also blurred.
	do
		local RunService = game:GetService("RunService")
		local GuiService = game:GetService("GuiService")
		local realGlass = {Enabled = false, Conn = nil, Sensor = nil, DoF = nil, Parts = {}}
		local WEDGE_SIZE = 0.2
		local WEDGE_DEPTH_STEP = 0.05
		local DOF_FOCUS = 51.6
		local DOF_IN_FOCUS = 50

		local function qualityAllows()
			local ok, level = pcall(function() return settings().Rendering.QualityLevel end)
			if not ok then return true end
			local v = typeof(level) == "EnumItem" and level.Value or tonumber(level) or 0
			return v <= 0 or v >= 8
		end

		local function isVisible(instance)
			local foundScreenGui = false
			while instance do
				if instance:IsA("GuiObject") then
					if not instance.Visible then return false end
				elseif instance:IsA("ScreenGui") then
					if not instance.Enabled then return false end
					foundScreenGui = true
					break
				end
				instance = instance.Parent
			end
			return foundScreenGui
		end

		local function drawTriangle(v1, v2, v3, p0, p1)
			local s1 = (v1 - v2).Magnitude
			local s2 = (v2 - v3).Magnitude
			local s3 = (v3 - v1).Magnitude
			local smax = math.max(s1, s2, s3)
			local A, B, C
			if s1 == smax then
				A, B, C = v1, v2, v3
			elseif s2 == smax then
				A, B, C = v2, v3, v1
			else
				A, B, C = v3, v1, v2
			end

			local para = (B - A):Dot(C - A) / (A - B).Magnitude
			local perp = math.sqrt((C - A).Magnitude ^ 2 - para * para)
			local difPara = (A - B).Magnitude - para

			local st = CFrame.new(B, A)
			local za = CFrame.Angles(math.pi / 2, 0, 0)
			local cf0 = st
			local topLook = (cf0 * za).LookVector
			local midPoint = A + CFrame.new(A, B).LookVector * para
			local neededLook = CFrame.new(midPoint, C).LookVector
			local dot = math.clamp(topLook:Dot(neededLook), -1, 1)
			local ac = CFrame.Angles(0, 0, math.acos(dot))

			cf0 = cf0 * ac
			if ((cf0 * za).LookVector - neededLook).Magnitude > 0.01 then
				cf0 = cf0 * CFrame.Angles(0, 0, -2 * math.acos(dot))
			end
			cf0 = cf0 * CFrame.new(0, perp / 2, -(difPara + para / 2))

			local cf1 = st * ac * CFrame.Angles(0, math.pi, 0)
			if ((cf1 * za).LookVector - neededLook).Magnitude > 0.01 then
				cf1 = cf1 * CFrame.Angles(0, 0, 2 * math.acos(dot))
			end
			cf1 = cf1 * CFrame.new(0, perp / 2, difPara / 2)

			if not p0 then
				p0 = Instance.new("Part")
				p0.Anchored = true
				p0.CanCollide = false
				p0.CanQuery = false
				p0.CanTouch = false
				p0.CastShadow = false
				p0.TopSurface = Enum.SurfaceType.Smooth
				p0.BottomSurface = Enum.SurfaceType.Smooth
				p0.Material = Enum.Material.Glass
				p0.Size = Vector3.new(WEDGE_SIZE, WEDGE_SIZE, WEDGE_SIZE)
				p0.Transparency = 0.98
				p0.BrickColor = BrickColor.new("Institutional white")
				local mesh = Instance.new("SpecialMesh")
				mesh.MeshType = Enum.MeshType.Wedge
				mesh.Parent = p0
			end
			p0:FindFirstChildWhichIsA("SpecialMesh").Scale = Vector3.new(0, perp / WEDGE_SIZE, para / WEDGE_SIZE)
			p0.CFrame = cf0

			if not p1 then
				p1 = p0:Clone()
			end
			p1:FindFirstChildWhichIsA("SpecialMesh").Scale = Vector3.new(0, perp / WEDGE_SIZE, difPara / WEDGE_SIZE)
			p1.CFrame = cf1

			return p0, p1
		end

		local function drawQuad(v1, v2, v3, v4, parts)
			parts[1], parts[2] = drawTriangle(v1, v2, v3, parts[1], parts[2])
			parts[3], parts[4] = drawTriangle(v3, v2, v4, parts[3], parts[4])
		end

		local function updateGlass()
			local sensor, dof = realGlass.Sensor, realGlass.DoF
			local cam = workspace.CurrentCamera
			if not (realGlass.Enabled and sensor and sensor.Parent and dof and cam) or not isVisible(sensor) then
				for _, part in ipairs(realGlass.Parts) do
					part.Parent = nil
				end
				if dof then
					dof.Enabled = false
					dof.Parent = nil
				end
				return
			end

			local origin = cam:ScreenPointToRay(0, 0).Origin
			if origin.X ~= origin.X then return end -- camera not ready yet (NaN)

			if not dof.Parent then
				dof.Parent = Lighting
			end
			dof.Enabled = true

			-- ScreenPointToRay works in viewport space; GUI space is offset by the top bar inset
			local inset = Vector2.new(0, 0)
			if not HirimiGui.IgnoreGuiInset then
				local ok, topLeft = pcall(function() return GuiService:GetGuiInset() end)
				if ok then
					inset = Vector2.new(topLeft.X, topLeft.Y)
				end
			end

			local depth = math.max(1 - WEDGE_DEPTH_STEP * sensor.ZIndex, 0.2)
			local tl = sensor.AbsolutePosition + inset
			local br = tl + sensor.AbsoluteSize
			local tr = Vector2.new(br.X, tl.Y)
			local bl = Vector2.new(tl.X, br.Y)

			drawQuad(
				cam:ScreenPointToRay(tl.X, tl.Y, depth).Origin,
				cam:ScreenPointToRay(tr.X, tr.Y, depth).Origin,
				cam:ScreenPointToRay(bl.X, bl.Y, depth).Origin,
				cam:ScreenPointToRay(br.X, br.Y, depth).Origin,
				realGlass.Parts
			)
			for _, part in ipairs(realGlass.Parts) do
				if part.Parent ~= cam then
					part.Parent = cam
				end
			end
		end

		local function teardown()
			if realGlass.Conn then
				realGlass.Conn:Disconnect()
				realGlass.Conn = nil
			end
			for _, part in ipairs(realGlass.Parts) do
				part:Destroy()
			end
			realGlass.Parts = {}
			if realGlass.DoF then
				realGlass.DoF:Destroy()
				realGlass.DoF = nil
			end
			if realGlass.Sensor then
				realGlass.Sensor:Destroy()
				realGlass.Sensor = nil
			end
		end

		local function setRealGlass(enabled)
			enabled = (not not enabled) and qualityAllows()
			if enabled == realGlass.Enabled then return enabled end
			realGlass.Enabled = enabled
			if not enabled then
				teardown()
				return false
			end

			-- Transparent sensor frame that defines the rectangle to blur
			local sensor = Instance.new("Frame")
			sensor.Name = "FlurGlassSensor"
			sensor.BackgroundTransparency = 1
			sensor.BorderSizePixel = 0
			sensor.Size = UDim2.new(1, 0, 1, 0)
			sensor.ZIndex = Main.ZIndex
			sensor.Parent = Main

			local dof = Instance.new("DepthOfFieldEffect")
			dof.Name = "FlurRealGlassDoF"
			dof.FarIntensity = 0
			dof.FocusDistance = DOF_FOCUS
			dof.InFocusRadius = DOF_IN_FOCUS
			dof.NearIntensity = math.clamp(tonumber(GuiConfig.RealGlassIntensity) or 1, 0, 1)
			dof.Enabled = false

			realGlass.Sensor = sensor
			realGlass.DoF = dof
			realGlass.Conn = RunService.RenderStepped:Connect(updateGlass)
			return true
		end

		function GuiFunc:SetRealGlass(enabled)
			return setRealGlass(enabled)
		end

		function GuiFunc:GetRealGlass()
			return realGlass.Enabled
		end
	end


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
		GuiFunc:SetRealGlass(false)
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
		function api:Destroy()
			if frame.Parent then
				frame:Destroy()
			end
			return true
		end
		function api:SetTitle(text)
			local labels = {}
			for _, child in ipairs(frame:GetChildren()) do
				if child:IsA("TextLabel") then table.insert(labels, child) end
			end
			if labels[1] then
				labels[1].Text = tostring(text)
				return true
			end
			return false
		end
		function api:SetDesc(text)
			local labels = {}
			for _, child in ipairs(frame:GetChildren()) do
				if child:IsA("TextLabel") then table.insert(labels, child) end
			end
			if labels[2] then
				labels[2].Text = tostring(text)
				return true
			end
			return false
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
		ColorCycle = true,
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


	-- Base64 wrappers so a whole config fits in one copy-paste string.
	do
		local B64CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

		local function base64Encode(data)
			local out = {}
			for i = 1, #data, 3 do
				local a, b, c = string.byte(data, i, i + 2)
				local n = a * 65536 + (b or 0) * 256 + (c or 0)
				local c1 = math.floor(n / 262144) % 64
				local c2 = math.floor(n / 4096) % 64
				local c3 = math.floor(n / 64) % 64
				local c4 = n % 64
				out[#out + 1] = string.sub(B64CHARS, c1 + 1, c1 + 1)
					.. string.sub(B64CHARS, c2 + 1, c2 + 1)
					.. (b and string.sub(B64CHARS, c3 + 1, c3 + 1) or "=")
					.. (c and string.sub(B64CHARS, c4 + 1, c4 + 1) or "=")
			end
			return table.concat(out)
		end

		local function base64Decode(data)
			data = string.gsub(data, "[^%w%+/=]", "")
			local out = {}
			local n, count = 0, 0
			for i = 1, #data do
				local ch = string.sub(data, i, i)
				if ch == "=" then break end
				local v = string.find(B64CHARS, ch, 1, true)
				if v then
					n = n * 64 + (v - 1)
					count = count + 1
					if count == 4 then
						out[#out + 1] = string.char(math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256)
						n, count = 0, 0
					end
				end
			end
			if count == 2 then
				out[#out + 1] = string.char(math.floor(n / 16) % 256)
			elseif count == 3 then
				out[#out + 1] = string.char(math.floor(n / 1024) % 256, math.floor(n / 4) % 256)
			end
			return table.concat(out)
		end

		function GuiFunc:ExportConfigString()
			local json = GuiFunc:ExportConfig()
			if type(json) ~= "string" then
				return nil, "export failed"
			end
			return base64Encode(json)
		end

		function GuiFunc:ImportConfigString(str)
			if type(str) ~= "string" or str == "" then
				return false, "string required"
			end
			return GuiFunc:ImportConfig(base64Decode(str))
		end
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
	local windowTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

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
	local closing = false
	local function fadeOutTree(root, info)
	    for _, d in ipairs(root:GetDescendants()) do
	        if d:IsA("GuiObject") then
	            local goal = {BackgroundTransparency = 1}
	            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
	                goal.TextTransparency = 1
	            end
	            if d:IsA("ImageLabel") or d:IsA("ImageButton") then
	                goal.ImageTransparency = 1
	            end
	            TweenService:Create(d, info, goal):Play()
	        end
	    end
	end
	Close.Activated:Connect(function()
	    CircleClick(Close, Mouse.X, Mouse.Y)
	    if closing then return end
	    closing = true
	    local fadeInfo = TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	    fadeOutTree(Main, fadeInfo)
	    TweenService:Create(Main, fadeInfo, {BackgroundTransparency = 1}):Play()
	    local basePos = DropShadowHolder.Position
	    TweenService:Create(
	        DropShadowHolder,
	        TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
	        {Position = basePos + UDim2.new(0, 0, 0, 16)}
	    ):Play()
	    task.delay(0.3, function()
	        GuiFunc:DestroyGui()
	    end)
	end)

	-- Topbar buttons: placed left of the Min button, right-to-left in creation order.
	do
		local topbarSlots = 0
		function GuiFunc:AddTopbarButton(cfg)
			cfg = cfg or {}
			topbarSlots = topbarSlots + 1
			local slot = topbarSlots
			local btn = Instance.new("TextButton")
			btn.Name = "TopbarButton"
			btn.Text = ""
			btn.AutoButtonColor = false
			btn.AnchorPoint = Vector2.new(1, 0.5)
			btn.Position = UDim2.new(1, -(109 + 31 * (slot - 1)), 0.5, 0)
			btn.Size = UDim2.new(0, 25, 0, 25)
			btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			btn.BackgroundTransparency = 0.9990000128746033
			btn.BorderSizePixel = 0
			btn.ZIndex = 6
			btn.Parent = Top
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 6)
			corner.Parent = btn

			local icon = cfg.Icon or ""
			local glyph
			if type(icon) == "string" and icon:find("rbxassetid", 1, true) then
				glyph = Instance.new("ImageLabel")
				glyph.Image = icon
				glyph.ImageColor3 = Color3.fromRGB(230, 230, 235)
				glyph.Size = UDim2.new(0, 14, 0, 14)
			else
				glyph = Instance.new("TextLabel")
				local letter = (type(icon) == "string" and icon ~= "") and icon or string.sub(tostring(cfg.Name or "?"), 1, 1)
				glyph.Text = letter
				glyph.Font = Enum.Font.GothamBold
				glyph.TextSize = 12
				glyph.TextColor3 = Color3.fromRGB(230, 230, 235)
				glyph.Size = UDim2.new(1, 0, 1, 0)
			end
			glyph.BackgroundTransparency = 1
			glyph.BorderSizePixel = 0
			glyph.AnchorPoint = Vector2.new(0.5, 0.5)
			glyph.Position = UDim2.new(0.5, 0, 0.5, 0)
			glyph.ZIndex = 7
			glyph.Parent = btn

			local hoverInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			btn.MouseEnter:Connect(function()
				TweenService:Create(btn, hoverInfo, {BackgroundTransparency = 0.9}):Play()
			end)
			btn.MouseLeave:Connect(function()
				TweenService:Create(btn, hoverInfo, {BackgroundTransparency = 0.9990000128746033}):Play()
			end)
			btn.Activated:Connect(function()
				CircleClick(btn, Mouse.X, Mouse.Y)
				if type(cfg.Callback) == "function" then
					cfg.Callback()
				end
			end)

			local api = {}
			function api:SetVisible(visible)
				btn.Visible = not not visible
				return true
			end
			function api:SetCallback(fn)
				cfg.Callback = fn
				return true
			end
			function api:Destroy()
				btn:Destroy()
			end
			return api
		end
	end


	do
		function GuiFunc:Popup(PopupConfig)
			PopupConfig = PopupConfig or {}
			local buttons = type(PopupConfig.Buttons) == "table" and PopupConfig.Buttons or {{Title = "OK"}}
			local contentText = tostring(PopupConfig.Content or "")
			local bodyH = math.max(14, math.ceil(TextService:GetTextSize(contentText, 12, Enum.Font.Gotham, Vector2.new(232, 10000)).Y))
			local rowY = 40 + bodyH + 14
			local cardH = rowY + 32 + 14

			local overlay = Instance.new("Frame")
			overlay.Name = "PopupOverlay"
			overlay.Size = UDim2.new(1, 0, 1, 0)
			overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			overlay.BackgroundTransparency = 1
			overlay.BorderSizePixel = 0
			overlay.ZIndex = 50
			overlay.Active = true
			overlay.Parent = Main

			local card = Instance.new("Frame")
			card.Name = "PopupCard"
			card.AnchorPoint = Vector2.new(0.5, 0.5)
			card.Position = UDim2.new(0.5, 0, 0.5, 0)
			card.Size = UDim2.new(0, 260, 0, cardH)
			card.BackgroundColor3 = Theme.Background
			card.BackgroundTransparency = 0.05
			card.BorderSizePixel = 0
			card.ZIndex = 51
			card.Parent = overlay
			local cardCorner = Instance.new("UICorner")
			cardCorner.CornerRadius = UDim.new(0, 8)
			cardCorner.Parent = card
			local cardStroke = Instance.new("UIStroke")
			cardStroke.Color = Theme.Border
			cardStroke.Thickness = 1
			cardStroke.Transparency = 0.5
			cardStroke.Parent = card
			local cardScale = Instance.new("UIScale")
			cardScale.Scale = 0.94
			cardScale.Parent = card

			local heading = Instance.new("TextLabel")
			heading.Name = "PopupTitle"
			heading.BackgroundTransparency = 1
			heading.Font = Enum.Font.GothamBold
			heading.TextSize = 13
			heading.TextColor3 = Theme.Text
			heading.TextXAlignment = Enum.TextXAlignment.Left
			heading.Text = tostring(PopupConfig.Title or "Confirm")
			heading.Position = UDim2.new(0, 14, 0, 12)
			heading.Size = UDim2.new(1, -28, 0, 16)
			heading.ZIndex = 52
			heading.Parent = card

			local body = Instance.new("TextLabel")
			body.Name = "PopupContent"
			body.BackgroundTransparency = 1
			body.Font = Enum.Font.Gotham
			body.TextSize = 12
			body.TextColor3 = Theme.MutedText
			body.TextWrapped = true
			body.TextXAlignment = Enum.TextXAlignment.Left
			body.TextYAlignment = Enum.TextYAlignment.Top
			body.Text = contentText
			body.Position = UDim2.new(0, 14, 0, 36)
			body.Size = UDim2.new(1, -28, 0, bodyH)
			body.ZIndex = 52
			body.Parent = card

			local row = Instance.new("Frame")
			row.Name = "PopupButtons"
			row.BackgroundTransparency = 1
			row.BorderSizePixel = 0
			row.Position = UDim2.new(0, 14, 0, rowY)
			row.Size = UDim2.new(1, -28, 0, 32)
			row.ZIndex = 52
			row.Parent = card
			local rowLayout = Instance.new("UIListLayout")
			rowLayout.FillDirection = Enum.FillDirection.Horizontal
			rowLayout.Padding = UDim.new(0, 6)
			rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
			rowLayout.Parent = row

			local api = {}
			local closed = false
			function api:Close()
				if closed then return false end
				closed = true
				local out = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				TweenService:Create(overlay, out, {BackgroundTransparency = 1}):Play()
				TweenService:Create(cardScale, out, {Scale = 0.94}):Play()
				TweenService:Create(card, out, {BackgroundTransparency = 1}):Play()
				task.delay(0.24, function()
					overlay:Destroy()
				end)
				return true
			end

			for i, b in ipairs(buttons) do
				local primary = (b.Primary == true) or (b.Primary == nil and i == #buttons)
				local btn = Instance.new("TextButton")
				btn.Name = "PopupButton" .. i
				btn.Text = tostring(b.Title or b.Name or "OK")
				btn.Font = Enum.Font.GothamBold
				btn.TextSize = 12
				btn.AutoButtonColor = false
				btn.BorderSizePixel = 0
				btn.LayoutOrder = i
				btn.Size = UDim2.new(1 / #buttons, -6, 1, 0)
				btn.BackgroundColor3 = primary and Theme.Accent or Color3.fromRGB(255, 255, 255)
				btn.BackgroundTransparency = primary and 0 or 0.935
				btn.TextColor3 = primary and Theme.Background or Theme.Text
				btn.ZIndex = 53
				btn.Parent = row
				local btnCorner = Instance.new("UICorner")
				btnCorner.CornerRadius = UDim.new(0, 4)
				btnCorner.Parent = btn
				btn.Activated:Connect(function()
					if type(b.Callback) == "function" then
						task.spawn(b.Callback, api)
					end
					if b.Close ~= false then
						api:Close()
					end
				end)
			end

			TweenService:Create(overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.45}):Play()
			TweenService:Create(cardScale, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1}):Play()
			return api
		end
	end

	local mobileToggleBtn = nil
	local mobileToggleIcon = nil
	local mobileToggleCorner = nil
	local mobileCfg = {
		Size = 44,
		Corner = 10,
		Icon = "",
		Smooth = true,
		TweenTime = 0.32,
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
				TweenService:Create(Main, TweenInfo.new(mobileCfg.TweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
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
	if GuiConfig.RealGlass then
		GuiFunc:SetRealGlass(true)
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

	DropShadow1.Image = ""
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
	UIStroke14.Thickness = 1.2
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
	local tabSelectors = {}
	local currentTabIndex = 0
	local function setControlDragging(on)
	    HirimiGui:SetAttribute("FlurControlDragging", on and true or false)
	end

	-- Horizontal flick on the content area switches tabs. Global input, so scrolling or
	-- touch-capturing children do not block it. Sliders and color pickers set FlurControlDragging.
	do
	    local swipe = nil
	    local function isTouchLike(t)
	        return t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1
	    end
	    local function insideLayers(pos)
	        if not LayersReal.Visible then return false end
	        local tl, sz = LayersReal.AbsolutePosition, LayersReal.AbsoluteSize
	        return sz.X > 0 and sz.Y > 0 and pos.X >= tl.X and pos.X <= tl.X + sz.X and pos.Y >= tl.Y and pos.Y <= tl.Y + sz.Y
	    end
	    local function stepTab(direction)
	        local list = {}
	        for idx in pairs(tabSelectors) do table.insert(list, idx) end
	        table.sort(list)
	        local pos = nil
	        for i, idx in ipairs(list) do
	            if idx == currentTabIndex then pos = i end
	        end
	        if not pos then return end
	        local target = list[pos + direction]
	        if target and tabSelectors[target] then
	            tabSelectors[target]()
	        end
	    end

	    UserInputService.InputBegan:Connect(function(input)
	        if not isTouchLike(input.UserInputType) then return end
	        if not (HirimiGui.Enabled and DropShadowHolder.Visible) then return end
	        if not insideLayers(input.Position) then return end
	        swipe = {start = input.Position, time = os.clock(), dir = nil}
	    end)

	    UserInputService.InputChanged:Connect(function(input)
	        if not swipe or swipe.dir == "blocked" then return end
	        if HirimiGui:GetAttribute("FlurControlDragging") then
	            swipe.dir = "blocked"
	            return
	        end
	        if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
	        local d = input.Position - swipe.start
	        if not swipe.dir and (math.abs(d.X) > 12 or math.abs(d.Y) > 12) then
	            swipe.dir = (math.abs(d.X) > math.abs(d.Y) * 1.5) and "h" or "v"
	        end
	    end)

	    UserInputService.InputEnded:Connect(function(input)
	        if not isTouchLike(input.UserInputType) then return end
	        local s0 = swipe
	        swipe = nil
	        setControlDragging(false)
	        if not s0 or s0.dir ~= "h" then return end
	        local dx = input.Position.X - s0.start.X
	        local dt = math.max(os.clock() - s0.time, 0.016)
	        local velocity = dx / dt
	        if math.abs(dx) > 60 or math.abs(velocity) > 700 then
	            stepTab(dx < 0 and 1 or -1)
	        end
	    end)
	end
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
		ScrolLayers.ScrollingDirection = Enum.ScrollingDirection.Y
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
			currentTabIndex = 0
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
			UIStroke2.Thickness = 1
			UIStroke2.Transparency = 0.45
			UIStroke2.Parent = ChooseFrame

			UICorner4.Parent = ChooseFrame
		end
		local function selectTab()
		    local FrameChoose
		    for a, s in ScrollTab:GetChildren() do
		        for i, v in s:GetChildren() do
		            if v.Name == "ChooseFrame" then
		                FrameChoose = v
		                break
		            end
		        end
		    end
		    if FrameChoose == nil or Tab.LayoutOrder == currentTabIndex then return end
		    currentTabIndex = Tab.LayoutOrder

		    local tabInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		    for _, TabFrame in ScrollTab:GetChildren() do
		        if TabFrame.Name == "Tab" then
		            TweenService:Create(TabFrame, tabInfo, {BackgroundTransparency = 0.9990000128746033}):Play()
		        end
		    end
		    TweenService:Create(Tab, tabInfo, {BackgroundTransparency = 0.9200000166893005}):Play()
		    TweenService:Create(
		        FrameChoose,
		        TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		        {Position = UDim2.new(0, 2, 0, 9 + (33 * Tab.LayoutOrder))}
		    ):Play()
		    LayersPageLayout:JumpToIndex(Tab.LayoutOrder)
		    task.delay(0.08, function()
		        NameTab.Text = TabConfig.Name
		    end)

		    -- indicator stretches, then settles (chained on Completed, no fixed waits)
		    local stretch = TweenService:Create(
		        FrameChoose,
		        TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		        {Size = UDim2.new(0, 1, 0, 20)}
		    )
		    stretch:Play()
		    stretch.Completed:Connect(function()
		        TweenService:Create(
		            FrameChoose,
		            TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		            {Size = UDim2.new(0, 1, 0, 12)}
		        ):Play()
		    end)
		end
		tabSelectors[Tab.LayoutOrder] = selectTab
		TabButton.Activated:Connect(function()
		    CircleClick(TabButton, Mouse.X, Mouse.Y)
		    selectTab()
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
			SectionReal.BackgroundTransparency = 0.9990000128746033
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
			local sectionTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
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
						height = height + (v:GetAttribute("FlurTargetH") or v.Size.Y.Offset) + 3
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
				task.delay(0.3, function()
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
					task.delay(0.3, function()
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
							TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{TextColor3 = GuiConfig.Color}
						):Play()
						TweenService:Create(
							ToggleCircle,
							TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{Position = UDim2.new(0, 15, 0, 0)}
						):Play()
						TweenService:Create(
							UIStroke8,
							TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{Color = GuiConfig.Color, Transparency = 0}
						):Play()
						TweenService:Create(
							FeatureFrame2,
							TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{BackgroundColor3 = GuiConfig.Color, BackgroundTransparency = 0} 
						):Play()
					else
						TweenService:Create(
							ToggleTitle,
							TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)}
						):Play()
						TweenService:Create(
							ToggleCircle,
							TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{Position = UDim2.new(0, 0, 0, 0)}
						):Play()
						TweenService:Create(
							UIStroke8,
							TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9}
						):Play()
						TweenService:Create(
							FeatureFrame2,
							TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
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
				local KeybindFunc = {Value = KeybindConfig.Default, Listening = false, Mode = "Toggle", State = false}
local triggerState = false
local validModes = {Toggle = true, Hold = true, Always = true}
if not validModes[KeybindConfig.Mode] then KeybindConfig.Mode = "Toggle" end
KeybindFunc.Mode = KeybindConfig.Mode
local function fireTrigger(state)
    KeybindFunc.State = state
    if type(KeybindConfig.OnTrigger) == "function" then
        task.spawn(KeybindConfig.OnTrigger, state)
    end
end
function KeybindFunc:SetMode(mode)
    if not validModes[mode] then return false end
    KeybindFunc.Mode = mode
    triggerState = false
    if mode == "Always" then fireTrigger(true) end
    return true
end
function KeybindFunc:GetState()
    return KeybindFunc.State
end
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
								UserInputService.InputBegan:Connect(function(input, gp)
					if gp or KeybindFunc.Listening then return end
					if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
					local key = KeybindFunc.Value
					if typeof(key) ~= "EnumItem" or input.KeyCode ~= key then return end
					if KeybindFunc.Mode == "Toggle" then
						triggerState = not triggerState
						fireTrigger(triggerState)
					elseif KeybindFunc.Mode == "Hold" then
						triggerState = true
						fireTrigger(true)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if KeybindFunc.Mode ~= "Hold" then return end
					local key = KeybindFunc.Value
					if typeof(key) ~= "EnumItem" or input.KeyCode ~= key then return end
					triggerState = false
					fireTrigger(false)
				end)
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
				if KeybindFunc.Mode == "Always" then fireTrigger(true) end
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
					setControlDragging(true)
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
								setControlDragging(false)
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
						setControlDragging(false)
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
if DropdownConfig.Searchable then
    local FilterBox = Instance.new("TextBox")
    FilterBox.Name = "FilterBox"
    FilterBox.PlaceholderText = tostring(DropdownConfig.SearchPlaceholder or "Search options...")
    FilterBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    FilterBox.Text = ""
    FilterBox.ClearTextOnFocus = false
    FilterBox.Font = Enum.Font.Gotham
    FilterBox.TextSize = 12
    FilterBox.TextColor3 = Color3.fromRGB(235, 235, 235)
    FilterBox.TextXAlignment = Enum.TextXAlignment.Left
    FilterBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FilterBox.BackgroundTransparency = 0.935
    FilterBox.BorderSizePixel = 0
    FilterBox.LayoutOrder = -1
    FilterBox.Size = UDim2.new(1, -8, 0, 26)
    FilterBox.Parent = ScrollSelect
    local filterCorner = Instance.new("UICorner")
    filterCorner.CornerRadius = UDim.new(0, 4)
    filterCorner.Parent = FilterBox
    FilterBox:GetPropertyChangedSignal("Text"):Connect(function()
        DropdownFunc.FilterText = FilterBox.Text
        for _, child in ipairs(ScrollSelect:GetChildren()) do
            if child.Name == "Option" then
                local label = child:FindFirstChild("OptionText")
                child.Visible = DropdownFunc.FilterText == "" or (label ~= nil and string.find(string.lower(label.Text), string.lower(DropdownFunc.FilterText), 1, true) ~= nil)
            end
        end
    end)
end
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
										TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
										{Transparency = 0}
									):Play()
									TweenService:Create(
										chooseFrame,
										TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
										{Size = UDim2.new(0, 1, 0, 12)}
									):Play()
									TweenService:Create(
										Drop,
										TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
										{BackgroundTransparency = 0.935}
									):Play()
								else
									TweenService:Create(
										chooseFrame,
										TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
										{Size = UDim2.new(0, 0, 0, 0)}
									):Play()
									TweenService:Create(
										chooseStroke,
										TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
										{Transparency = 0.999}
									):Play()
									TweenService:Create(
										Drop,
										TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
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
					Option.Visible = (DropdownFunc.FilterText or "") == "" or string.find(string.lower(OptionName), string.lower(DropdownFunc.FilterText or ""), 1, true) ~= nil
				
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
					UIStroke15.Thickness = 1
					UIStroke15.Transparency = 0.6
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
					task.delay(0.3, function()
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

				local HEADER_H, PANEL_H = 46, 190
				local expanded = false
				local dragging = nil
				local hexFocused = false
				local Hue, Sat, Val = ColorConfig.Default:ToHSV()
				local Alpha = math.clamp(tonumber(ColorConfig.Alpha) or 1, 0, 1)
				local ColorFunc = {Value = ColorConfig.Default, Alpha = Alpha}

				local Row = Instance.new("Frame")
				Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Row.BackgroundTransparency = 0.935
				Row.BorderSizePixel = 0
				Row.ClipsDescendants = true
				Row.LayoutOrder = CountItem
				Row.Size = UDim2.new(1, 0, 0, HEADER_H)
				Row.Name = "ColorPicker"
				Row.Parent = SectionAdd
				local Corner = Instance.new("UICorner")
				Corner.CornerRadius = UDim.new(0, 4)
				Corner.Parent = Row

				local Header = Instance.new("TextButton")
				Header.Text = ""
				Header.AutoButtonColor = false
				Header.BackgroundTransparency = 1
				Header.Size = UDim2.new(1, 0, 0, HEADER_H)
				Header.Name = "PickerHeader"
				Header.Parent = Row

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
				Content.Font = Enum.Font.Gotham
				Content.Text = ColorConfig.Content
				Content.TextColor3 = Color3.fromRGB(160, 160, 160)
				Content.TextSize = 12
				Content.TextXAlignment = Enum.TextXAlignment.Left
				Content.BackgroundTransparency = 1
				Content.Position = UDim2.new(0, 10, 0, 24)
				Content.Size = UDim2.new(1, -70, 0, 14)
				Content.Parent = Row

				local Swatch = Instance.new("Frame")
				Swatch.Name = "Swatch"
				Swatch.BorderSizePixel = 0
				Swatch.AnchorPoint = Vector2.new(1, 0)
				Swatch.Position = UDim2.new(1, -12, 0, (HEADER_H - 28) / 2)
				Swatch.Size = UDim2.new(0, 28, 0, 28)
				Swatch.Parent = Row
				local SwatchCorner = Instance.new("UICorner")
				SwatchCorner.CornerRadius = UDim.new(0, 6)
				SwatchCorner.Parent = Swatch

				-- inline panel: grows the row downward so the section can scroll to it
				local Panel = Instance.new("Frame")
				Panel.Name = "PickerPanel"
				Panel.BackgroundTransparency = 1
				Panel.BorderSizePixel = 0
				Panel.Position = UDim2.new(0, 10, 0, HEADER_H + 6)
				Panel.Size = UDim2.new(1, -20, 0, PANEL_H - 12)
				Panel.Parent = Row

				local SV = Instance.new("Frame")
				SV.Name = "SVArea"
				SV.BorderSizePixel = 0
				SV.Size = UDim2.new(1, -24, 1, -40)
				SV.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
				SV:SetAttribute("FlurRaw", true)
				SV.Parent = Panel
				local SVCorner = Instance.new("UICorner")
				SVCorner.CornerRadius = UDim.new(0, 4)
				SVCorner.Parent = SV

				local WhiteOver = Instance.new("Frame")
				WhiteOver.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				WhiteOver.BorderSizePixel = 0
				WhiteOver.Size = UDim2.new(1, 0, 1, 0)
				WhiteOver:SetAttribute("FlurRaw", true)
				WhiteOver.Parent = SV
				local WhiteCorner = Instance.new("UICorner")
				WhiteCorner.CornerRadius = UDim.new(0, 4)
				WhiteCorner.Parent = WhiteOver
				local WhiteGrad = Instance.new("UIGradient")
				WhiteGrad.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1),
				})
				WhiteGrad:SetAttribute("FlurRaw", true)
				WhiteGrad.Parent = WhiteOver

				local BlackOver = Instance.new("Frame")
				BlackOver.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				BlackOver.BorderSizePixel = 0
				BlackOver.Size = UDim2.new(1, 0, 1, 0)
				BlackOver:SetAttribute("FlurRaw", true)
				BlackOver.Parent = SV
				local BlackCorner = Instance.new("UICorner")
				BlackCorner.CornerRadius = UDim.new(0, 4)
				BlackCorner.Parent = BlackOver
				local BlackGrad = Instance.new("UIGradient")
				BlackGrad.Rotation = 90
				BlackGrad.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 0),
				})
				BlackGrad:SetAttribute("FlurRaw", true)
				BlackGrad.Parent = BlackOver

				local SVKnob = Instance.new("Frame")
				SVKnob.Name = "SVKnob"
				SVKnob.AnchorPoint = Vector2.new(0.5, 0.5)
				SVKnob.Size = UDim2.new(0, 10, 0, 10)
				SVKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				SVKnob.BorderSizePixel = 0
				SVKnob.Parent = SV
				local SVKnobCorner = Instance.new("UICorner")
				SVKnobCorner.CornerRadius = UDim.new(1, 0)
				SVKnobCorner.Parent = SVKnob
				local SVKnobStroke = Instance.new("UIStroke")
				SVKnobStroke.Name = "KnobStroke"
				SVKnobStroke.Color = Color3.fromRGB(0, 0, 0)
				SVKnobStroke.Thickness = 1.5
				SVKnobStroke.Transparency = 0.2
				SVKnobStroke.Parent = SVKnob

				local HueBar = Instance.new("Frame")
				HueBar.Name = "HueBar"
				HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				HueBar.BorderSizePixel = 0
				HueBar.Position = UDim2.new(1, -14, 0, 0)
				HueBar.Size = UDim2.new(0, 14, 1, -40)
				HueBar:SetAttribute("FlurRaw", true)
				HueBar.Parent = Panel
				local HueCorner = Instance.new("UICorner")
				HueCorner.CornerRadius = UDim.new(0, 4)
				HueCorner.Parent = HueBar
				local HueKeys = {}
				for i = 0, 6 do
					local t = i / 6
					table.insert(HueKeys, ColorSequenceKeypoint.new(t, Color3.fromHSV(t, 1, 1)))
				end
				local HueGrad = Instance.new("UIGradient")
				HueGrad.Rotation = 90
				HueGrad.Color = ColorSequence.new(HueKeys)
				HueGrad:SetAttribute("FlurRaw", true)
				HueGrad.Parent = HueBar

				local HueKnob = Instance.new("Frame")
				HueKnob.Name = "HueKnob"
				HueKnob.AnchorPoint = Vector2.new(0.5, 0.5)
				HueKnob.Size = UDim2.new(1, 6, 0, 4)
				HueKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				HueKnob.BorderSizePixel = 0
				HueKnob.Parent = HueBar
				local HueKnobCorner = Instance.new("UICorner")
				HueKnobCorner.CornerRadius = UDim.new(1, 0)
				HueKnobCorner.Parent = HueKnob
				local HueKnobStroke = Instance.new("UIStroke")
				HueKnobStroke.Name = "KnobStroke"
				HueKnobStroke.Color = Color3.fromRGB(0, 0, 0)
				HueKnobStroke.Thickness = 1
				HueKnobStroke.Transparency = 0.2
				HueKnobStroke.Parent = HueKnob

				-- bottom row: alpha bar and hex box
				local BottomRow = Instance.new("Frame")
				BottomRow.Name = "PickerBottom"
				BottomRow.BackgroundTransparency = 1
				BottomRow.BorderSizePixel = 0
				BottomRow.Position = UDim2.new(0, 0, 1, -30)
				BottomRow.Size = UDim2.new(1, 0, 0, 30)
				BottomRow.Parent = Panel

				local AlphaBar = Instance.new("Frame")
				AlphaBar.Name = "AlphaBar"
				AlphaBar.BorderSizePixel = 0
				AlphaBar.Position = UDim2.new(0, 0, 0, 8)
				AlphaBar.Size = UDim2.new(1, -104, 0, 14)
				AlphaBar.BackgroundColor3 = Color3.fromHSV(Hue, Sat, Val)
				AlphaBar:SetAttribute("FlurRaw", true)
				AlphaBar.Parent = BottomRow
				local AlphaCorner = Instance.new("UICorner")
				AlphaCorner.CornerRadius = UDim.new(0, 4)
				AlphaCorner.Parent = AlphaBar
				local AlphaGrad = Instance.new("UIGradient")
				AlphaGrad.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 0),
				})
				AlphaGrad:SetAttribute("FlurRaw", true)
				AlphaGrad.Parent = AlphaBar

				local AlphaKnob = Instance.new("Frame")
				AlphaKnob.Name = "AlphaKnob"
				AlphaKnob.AnchorPoint = Vector2.new(0.5, 0.5)
				AlphaKnob.Size = UDim2.new(0, 4, 0, 18)
				AlphaKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				AlphaKnob.BorderSizePixel = 0
				AlphaKnob.Parent = AlphaBar
				local AlphaKnobCorner = Instance.new("UICorner")
				AlphaKnobCorner.CornerRadius = UDim.new(1, 0)
				AlphaKnobCorner.Parent = AlphaKnob
				local AlphaKnobStroke = Instance.new("UIStroke")
				AlphaKnobStroke.Name = "KnobStroke"
				AlphaKnobStroke.Color = Color3.fromRGB(0, 0, 0)
				AlphaKnobStroke.Thickness = 1
				AlphaKnobStroke.Transparency = 0.2
				AlphaKnobStroke.Parent = AlphaKnob

				local HexBox = Instance.new("TextBox")
				HexBox.Name = "Hex"
				HexBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				HexBox.BackgroundTransparency = 0.935
				HexBox.BorderSizePixel = 0
				HexBox.ClearTextOnFocus = false
				HexBox.Font = Enum.Font.Gotham
				HexBox.TextSize = 12
				HexBox.TextColor3 = Color3.fromRGB(235, 235, 235)
				HexBox.Position = UDim2.new(1, -96, 0, 2)
				HexBox.Size = UDim2.new(0, 96, 0, 26)
				HexBox.Text = ""
				HexBox.Parent = BottomRow
				local HexCorner = Instance.new("UICorner")
				HexCorner.CornerRadius = UDim.new(0, 4)
				HexCorner.Parent = HexBox

				-- transparent hit areas last, so they sit on top
				local SVHit = Instance.new("TextButton")
				SVHit.Name = "SVHit"
				SVHit.Text = ""
				SVHit.AutoButtonColor = false
				SVHit.BackgroundTransparency = 1
				SVHit.Size = UDim2.new(1, 0, 1, 0)
				SVHit.Parent = SV
				local HueHit = Instance.new("TextButton")
				HueHit.Name = "HueHit"
				HueHit.Text = ""
				HueHit.AutoButtonColor = false
				HueHit.BackgroundTransparency = 1
				HueHit.Size = UDim2.new(1, 0, 1, 0)
				HueHit.Parent = HueBar
				local AlphaHit = Instance.new("TextButton")
				AlphaHit.Name = "AlphaHit"
				AlphaHit.Text = ""
				AlphaHit.AutoButtonColor = false
				AlphaHit.BackgroundTransparency = 1
				AlphaHit.Size = UDim2.new(1, 0, 1, 0)
				AlphaHit.Parent = AlphaBar

				local function hexOf(c)
					return string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
				end

				local function refresh(notify)
					local c = Color3.fromHSV(Hue, Sat, Val)
					ColorFunc.Value = c
					ColorFunc.Alpha = Alpha
					Swatch.BackgroundColor3 = c
					Swatch.BackgroundTransparency = 1 - Alpha
					SV.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
					SVKnob.Position = UDim2.new(Sat, 0, 1 - Val, 0)
					HueKnob.Position = UDim2.new(0.5, 0, Hue, 0)
					AlphaBar.BackgroundColor3 = c
					AlphaKnob.Position = UDim2.new(Alpha, 0, 0.5, 0)
					if not hexFocused then
						HexBox.Text = hexOf(c)
					end
					if notify then
						ColorConfig.Callback(c, Alpha)
						if type(ColorConfig.Flag) == "string" then
							GuiFunc:NotifyFlagChanged("ColorPicker", resolveFlagName(ColorConfig.Flag))
						end
					end
				end

				local function setFromSV(x, y)
					local p, s = SV.AbsolutePosition, SV.AbsoluteSize
					Sat = math.clamp((x - p.X) / math.max(s.X, 1), 0, 1)
					Val = 1 - math.clamp((y - p.Y) / math.max(s.Y, 1), 0, 1)
					refresh(true)
				end

				local function setFromHue(y)
					local p, s = HueBar.AbsolutePosition, HueBar.AbsoluteSize
					Hue = math.clamp((y - p.Y) / math.max(s.Y, 1), 0, 1)
					refresh(true)
				end

				local function setFromAlpha(x)
					local p, s = AlphaBar.AbsolutePosition, AlphaBar.AbsoluteSize
					Alpha = math.clamp((x - p.X) / math.max(s.X, 1), 0, 1)
					refresh(true)
				end

				local function isPress(input)
					return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
				end

				local function isMove(input)
					return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
				end

				local function applyInput(input)
					if dragging == "sv" then
						setFromSV(input.Position.X, input.Position.Y)
					elseif dragging == "hue" then
						setFromHue(input.Position.Y)
					elseif dragging == "alpha" then
						setFromAlpha(input.Position.X)
					end
				end

				local lockedScroll = nil
				local function lockScroll(on)
					if on then
						setControlDragging(true)
						if lockedScroll then return end
						local p = Row.Parent
						while p and not p:IsA("ScrollingFrame") do
							p = p.Parent
						end
						if p and p.ScrollingEnabled then
							lockedScroll = p
							p.ScrollingEnabled = false
						end
					else
						setControlDragging(false)
						if lockedScroll then
							lockedScroll.ScrollingEnabled = true
							lockedScroll = nil
						end
					end
				end

				SVHit.InputBegan:Connect(function(input)
					if isPress(input) then
						dragging = "sv"
						lockScroll(true)
						applyInput(input)
					end
				end)
				HueHit.InputBegan:Connect(function(input)
					if isPress(input) then
						dragging = "hue"
						lockScroll(true)
						applyInput(input)
					end
				end)
				AlphaHit.InputBegan:Connect(function(input)
					if isPress(input) then
						dragging = "alpha"
						lockScroll(true)
						applyInput(input)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and isMove(input) then applyInput(input) end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if dragging and isPress(input) then
						dragging = nil
						lockScroll(false)
					end
				end)

				HexBox.Focused:Connect(function()
					hexFocused = true
				end)
				HexBox.FocusLost:Connect(function()
					hexFocused = false
					local hex = string.match(HexBox.Text, "^#?(%x%x%x%x%x%x)$")
					if hex then
						ColorFunc:Set(Color3.fromRGB(tonumber(string.sub(hex, 1, 2), 16), tonumber(string.sub(hex, 3, 4), 16), tonumber(string.sub(hex, 5, 6), 16)))
					else
						refresh(false)
					end
				end)

				local function setExpanded(v)
					expanded = v
					local target = expanded and (HEADER_H + PANEL_H) or HEADER_H
					Row:SetAttribute("FlurTargetH", target)
					TweenService:Create(Row, sectionTweenInfo, {Size = UDim2.new(1, 0, 0, target)}):Play()
					UpdateSizeSection()
				end
				Header.Activated:Connect(function()
					setExpanded(not expanded)
				end)

				function ColorFunc:Set(c)
					if typeof(c) ~= "Color3" then return false end
					Hue, Sat, Val = c:ToHSV()
					refresh(true)
					return true
				end

				function ColorFunc:SetHSV(h, s, v)
					Hue = math.clamp(tonumber(h) or Hue, 0, 1)
					Sat = math.clamp(tonumber(s) or Sat, 0, 1)
					Val = math.clamp(tonumber(v) or Val, 0, 1)
					refresh(true)
					return true
				end

				function ColorFunc:SetAlpha(a)
					Alpha = math.clamp(tonumber(a) or Alpha, 0, 1)
					refresh(true)
					return true
				end

				function ColorFunc:SetExpanded(v)
					setExpanded(not not v)
					return true
				end

				refresh(false)

				table.insert(searchIndex, {
					frame = Row,
					title = ColorConfig.Title,
					content = ColorConfig.Content,
				})
				if type(ColorConfig.Flag) == "string" and ColorConfig.Flag ~= "" then
					GuiFunc:RegisterFlag(ColorConfig.Flag, function()
						local c = ColorFunc.Value
						return {c.R, c.G, c.B, Alpha}
					end, function(value)
						if type(value) == "table" and #value >= 3 then
							if type(value[4]) == "number" then
								Alpha = math.clamp(value[4], 0, 1)
							end
							ColorFunc:Set(Color3.new(value[1], value[2], value[3]))
						end
					end, "ColorPicker")
				end
				CountItem = CountItem + 1
				return attachElementControls(ColorFunc, Row)
			end

			function Items:AddColorCycle(ColorConfig)
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
				Row.Name = "ColorCycle"
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
						GuiFunc:NotifyFlagChanged("ColorCycle", resolveFlagName(ColorConfig.Flag))
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
					end, "ColorCycle")
				end
				CountItem = CountItem + 1
				return attachElementControls(ColorFunc, Row)
			end

			function Items:AddLabel(LabelConfig)
				LabelConfig = LabelConfig or {}
				LabelConfig.Title = LabelConfig.Title or "Label"
				local LabelFunc = {}

				local Row = Instance.new("Frame")
				Row.Name = "Label"
				Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Row.BackgroundTransparency = 0.935
				Row.BorderSizePixel = 0
				Row.LayoutOrder = CountItem
				Row.Size = UDim2.new(1, 0, 0, 28)
				Row.Parent = SectionAdd
				local Corner = Instance.new("UICorner")
				Corner.CornerRadius = UDim.new(0, 4)
				Corner.Parent = Row

				local Text = Instance.new("TextLabel")
				Text.Name = "LabelText"
				Text.BackgroundTransparency = 1
				Text.Font = Enum.Font.GothamBold
				Text.TextSize = 12
				Text.TextXAlignment = Enum.TextXAlignment.Left
				Text.TextColor3 = typeof(LabelConfig.Color) == "Color3" and LabelConfig.Color or Color3.fromRGB(200, 200, 210)
				Text.Text = tostring(LabelConfig.Title)
				Text.Position = UDim2.new(0, 10, 0, 0)
				Text.Size = UDim2.new(1, -20, 1, 0)
				Text.Parent = Row

				function LabelFunc:Set(value)
					Text.Text = tostring(value)
					return true
				end
				function LabelFunc:SetColor(color)
					if typeof(color) == "Color3" then Text.TextColor3 = color end
					return true
				end

				CountItem = CountItem + 1
				return attachElementControls(LabelFunc, Row)
			end

			function Items:AddDivider()
				local Row = Instance.new("Frame")
				Row.Name = "Divider"
				Row.AnchorPoint = Vector2.new(0.5, 0)
				Row.Position = UDim2.new(0.5, 0, 0, 0)
				Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Row.BackgroundTransparency = 0.88
				Row.BorderSizePixel = 0
				Row.LayoutOrder = CountItem
				Row.Size = UDim2.new(1, -20, 0, 1)
				Row.Parent = SectionAdd
				CountItem = CountItem + 1
				return attachElementControls({}, Row)
			end

			function Items:AddTextArea(TextAreaConfig)
				TextAreaConfig = TextAreaConfig or {}
				TextAreaConfig.Title = TextAreaConfig.Title or "Text"
				TextAreaConfig.Content = TextAreaConfig.Content or ""
				TextAreaConfig.Placeholder = TextAreaConfig.Placeholder or "Type here..."
				TextAreaConfig.Callback = TextAreaConfig.Callback or function() end
				local boxH = math.max(60, tonumber(TextAreaConfig.Height) or 96)
				local TextAreaFunc = {Value = tostring(TextAreaConfig.Default or "")}

				local Row = Instance.new("Frame")
				Row.Name = "TextArea"
				Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Row.BackgroundTransparency = 0.935
				Row.BorderSizePixel = 0
				Row.LayoutOrder = CountItem
				Row.Size = UDim2.new(1, 0, 0, 44 + boxH + 10)
				Row.Parent = SectionAdd
				local Corner = Instance.new("UICorner")
				Corner.CornerRadius = UDim.new(0, 4)
				Corner.Parent = Row

				local Title = Instance.new("TextLabel")
				Title.Font = Enum.Font.GothamBold
				Title.Text = TextAreaConfig.Title
				Title.TextColor3 = Theme.Text
				Title.TextSize = 13
				Title.TextXAlignment = Enum.TextXAlignment.Left
				Title.BackgroundTransparency = 1
				Title.Position = UDim2.new(0, 10, 0, 8)
				Title.Size = UDim2.new(1, -20, 0, 14)
				Title.Parent = Row

				local Content = Instance.new("TextLabel")
				Content.Font = Enum.Font.Gotham
				Content.Text = TextAreaConfig.Content
				Content.TextColor3 = Theme.MutedText
				Content.TextSize = 12
				Content.TextXAlignment = Enum.TextXAlignment.Left
				Content.BackgroundTransparency = 1
				Content.Position = UDim2.new(0, 10, 0, 24)
				Content.Size = UDim2.new(1, -20, 0, 14)
				Content.Parent = Row

				local Box = Instance.new("Frame")
				Box.Name = "Box"
				Box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Box.BackgroundTransparency = 0.92
				Box.BorderSizePixel = 0
				Box.Position = UDim2.new(0, 10, 0, 44)
				Box.Size = UDim2.new(1, -20, 0, boxH)
				Box.Parent = Row
				local BoxCorner = Instance.new("UICorner")
				BoxCorner.CornerRadius = UDim.new(0, 4)
				BoxCorner.Parent = Box
				local BoxStroke = Instance.new("UIStroke")
				BoxStroke.Color = Theme.Text
				BoxStroke.Thickness = 1
				BoxStroke.Transparency = 1
				BoxStroke.Parent = Box

				local TextBox = Instance.new("TextBox")
				TextBox.Name = "TextBox"
				TextBox.MultiLine = true
				TextBox.TextWrapped = true
				TextBox.ClearTextOnFocus = false
				TextBox.BackgroundTransparency = 1
				TextBox.Font = Enum.Font.Gotham
				TextBox.TextSize = 12
				TextBox.TextColor3 = Theme.Text
				TextBox.PlaceholderText = TextAreaConfig.Placeholder
				TextBox.PlaceholderColor3 = Theme.MutedText
				TextBox.TextXAlignment = Enum.TextXAlignment.Left
				TextBox.TextYAlignment = Enum.TextYAlignment.Top
				TextBox.Position = UDim2.new(0, 8, 0, 6)
				TextBox.Size = UDim2.new(1, -16, 1, -12)
				TextBox.Text = TextAreaFunc.Value
				TextBox.Parent = Box

				TextBox.Focused:Connect(function()
					TweenService:Create(BoxStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Transparency = 0.6}):Play()
				end)
				TextBox.FocusLost:Connect(function()
					TweenService:Create(BoxStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
					TextAreaFunc.Value = TextBox.Text
					TextAreaConfig.Callback(TextAreaFunc.Value)
					if type(TextAreaConfig.Flag) == "string" then
						GuiFunc:NotifyFlagChanged("TextArea", resolveFlagName(TextAreaConfig.Flag))
					end
				end)

				function TextAreaFunc:Set(value)
					TextAreaFunc.Value = tostring(value or "")
					TextBox.Text = TextAreaFunc.Value
					TextAreaConfig.Callback(TextAreaFunc.Value)
					return true
				end
				function TextAreaFunc:Get()
					return TextAreaFunc.Value
				end
				function TextAreaFunc:Clear()
					return TextAreaFunc:Set("")
				end

				table.insert(searchIndex, {frame = Row, title = TextAreaConfig.Title, content = TextAreaConfig.Content})
				if type(TextAreaConfig.Flag) == "string" and TextAreaConfig.Flag ~= "" then
					GuiFunc:RegisterFlag(TextAreaConfig.Flag, function()
						return TextAreaFunc.Value
					end, function(value)
						TextAreaFunc:Set(value)
					end, "TextArea")
				end
				CountItem = CountItem + 1
				return attachElementControls(TextAreaFunc, Row)
			end

			function Items:AddProgress(ProgressConfig)
				ProgressConfig = ProgressConfig or {}
				local maxValue = math.max(1, tonumber(ProgressConfig.Max) or 100)
				local value = math.clamp(tonumber(ProgressConfig.Default) or 0, 0, maxValue)
				local barColor = typeof(ProgressConfig.Color) == "Color3" and ProgressConfig.Color or Theme.Accent
				local ProgressFunc = {Value = value}

				local Row = Instance.new("Frame")
				Row.Name = "Progress"
				Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Row.BackgroundTransparency = 0.935
				Row.BorderSizePixel = 0
				Row.LayoutOrder = CountItem
				Row.Size = UDim2.new(1, 0, 0, 46)
				Row.Parent = SectionAdd
				local Corner = Instance.new("UICorner")
				Corner.CornerRadius = UDim.new(0, 4)
				Corner.Parent = Row

				local Title = Instance.new("TextLabel")
				Title.Font = Enum.Font.GothamBold
				Title.Text = tostring(ProgressConfig.Title or "Progress")
				Title.TextColor3 = Theme.Text
				Title.TextSize = 13
				Title.TextXAlignment = Enum.TextXAlignment.Left
				Title.BackgroundTransparency = 1
				Title.Position = UDim2.new(0, 10, 0, 7)
				Title.Size = UDim2.new(1, -90, 0, 14)
				Title.Parent = Row

				local Right = Instance.new("TextLabel")
				Right.Name = "ProgressValue"
				Right.Font = Enum.Font.GothamBold
				Right.TextColor3 = Theme.MutedText
				Right.TextSize = 12
				Right.TextXAlignment = Enum.TextXAlignment.Right
				Right.BackgroundTransparency = 1
				Right.AnchorPoint = Vector2.new(1, 0)
				Right.Position = UDim2.new(1, -10, 0, 7)
				Right.Size = UDim2.new(0, 80, 0, 14)
				Right.Parent = Row

				local Track = Instance.new("Frame")
				Track.Name = "Track"
				Track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Track.BackgroundTransparency = 0.92
				Track.BorderSizePixel = 0
				Track.Position = UDim2.new(0, 10, 0, 30)
				Track.Size = UDim2.new(1, -20, 0, 6)
				Track.Parent = Row
				local TrackCorner = Instance.new("UICorner")
				TrackCorner.CornerRadius = UDim.new(1, 0)
				TrackCorner.Parent = Track

				local Fill = Instance.new("Frame")
				Fill.Name = "Fill"
				Fill.BackgroundColor3 = barColor
				Fill.BorderSizePixel = 0
				Fill.Size = UDim2.new(0, 0, 1, 0)
				Fill.Parent = Track
				local FillCorner = Instance.new("UICorner")
				FillCorner.CornerRadius = UDim.new(1, 0)
				FillCorner.Parent = Fill

				local function render(animated)
					local ratio = value / maxValue
					if animated then
						TweenService:Create(Fill, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(ratio, 0, 1, 0)}):Play()
					else
						Fill.Size = UDim2.new(ratio, 0, 1, 0)
					end
					if type(ProgressConfig.Format) == "function" then
						Right.Text = tostring(ProgressConfig.Format(value, maxValue))
					else
						Right.Text = tostring(math.floor(ratio * 100 + 0.5)) .. "%"
					end
				end

				function ProgressFunc:Set(v)
					value = math.clamp(tonumber(v) or value, 0, maxValue)
					ProgressFunc.Value = value
					render(true)
					return true
				end
				function ProgressFunc:Get()
					return value
				end
				function ProgressFunc:SetLabel(text)
					Right.Text = tostring(text)
					return true
				end
				function ProgressFunc:SetColor(color)
					if typeof(color) == "Color3" then
						Fill.BackgroundColor3 = color
					end
					return true
				end

				render(false)
				CountItem = CountItem + 1
				return attachElementControls(ProgressFunc, Row)
			end

			function Items:AddLog(LogConfig)
				LogConfig = LogConfig or {}
				local LINE_H = 15
				local lineCount = math.clamp(math.floor(tonumber(LogConfig.Lines) or 6), 2, 20)
				local stamp = LogConfig.Timestamp ~= false
				local LogFunc = {}
				local lines = {}

				local Row = Instance.new("Frame")
				Row.Name = "Log"
				Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Row.BackgroundTransparency = 0.935
				Row.BorderSizePixel = 0
				Row.LayoutOrder = CountItem
				Row.Size = UDim2.new(1, 0, 0, 34 + lineCount * LINE_H + 10)
				Row.Parent = SectionAdd
				local Corner = Instance.new("UICorner")
				Corner.CornerRadius = UDim.new(0, 4)
				Corner.Parent = Row

				local Heading = Instance.new("TextLabel")
				Heading.Font = Enum.Font.GothamBold
				Heading.Text = tostring(LogConfig.Title or "Log")
				Heading.TextColor3 = Theme.Text
				Heading.TextSize = 12
				Heading.TextXAlignment = Enum.TextXAlignment.Left
				Heading.BackgroundTransparency = 1
				Heading.Position = UDim2.new(0, 10, 0, 8)
				Heading.Size = UDim2.new(1, -80, 0, 14)
				Heading.Parent = Row

				local ClearBtn = Instance.new("TextButton")
				ClearBtn.Name = "Clear"
				ClearBtn.Text = "Clear"
				ClearBtn.Font = Enum.Font.GothamBold
				ClearBtn.TextSize = 11
				ClearBtn.TextColor3 = Theme.Text
				ClearBtn.AutoButtonColor = false
				ClearBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ClearBtn.BackgroundTransparency = 0.9
				ClearBtn.BorderSizePixel = 0
				ClearBtn.AnchorPoint = Vector2.new(1, 0)
				ClearBtn.Position = UDim2.new(1, -8, 0, 6)
				ClearBtn.Size = UDim2.new(0, 52, 0, 20)
				ClearBtn.Parent = Row
				local ClearCorner = Instance.new("UICorner")
				ClearCorner.CornerRadius = UDim.new(0, 4)
				ClearCorner.Parent = ClearBtn

				local Body = Instance.new("Frame")
				Body.Name = "LogBody"
				Body.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				Body.BackgroundTransparency = 0.8
				Body.BorderSizePixel = 0
				Body.ClipsDescendants = true
				Body.Position = UDim2.new(0, 10, 0, 30)
				Body.Size = UDim2.new(1, -20, 0, lineCount * LINE_H + 4)
				Body.Parent = Row
				local BodyCorner = Instance.new("UICorner")
				BodyCorner.CornerRadius = UDim.new(0, 4)
				BodyCorner.Parent = Body

				local function relayout()
					local n = #lines
					for i, label in ipairs(lines) do
						label.Position = UDim2.new(0, 8, 0, (lineCount - n + i - 1) * LINE_H + 2)
					end
				end

				function LogFunc:Add(text, color)
					local label = Instance.new("TextLabel")
					label.BackgroundTransparency = 1
					label.Font = Enum.Font.Code
					label.TextSize = 11
					label.TextColor3 = typeof(color) == "Color3" and color or Theme.Text
					label.TextXAlignment = Enum.TextXAlignment.Left
					label.TextTruncate = Enum.TextTruncate.AtEnd
					label.Size = UDim2.new(1, -16, 0, LINE_H)
					local prefix = stamp and ("[" .. os.date("%H:%M:%S") .. "] ") or ""
					label.Text = prefix .. tostring(text)
					label.TextTransparency = 1
					label.Parent = Body
					table.insert(lines, label)
					while #lines > lineCount do
						local old = table.remove(lines, 1)
						old:Destroy()
					end
					relayout()
					TweenService:Create(label, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
					return true
				end

				function LogFunc:Clear()
					for _, label in ipairs(lines) do
						label:Destroy()
					end
					lines = {}
					return true
				end

				ClearBtn.Activated:Connect(function()
					LogFunc:Clear()
				end)

				CountItem = CountItem + 1
				return attachElementControls(LogFunc, Row)
			end

			-- Sub-tabs: a segmented control inside a section. Pages work like Group columns.
			-- local tabs = Section:AddSubTabs({"General", "Advanced"}); tabs[1]:AddToggle{...}; tabs:Select(2)
			function Items:AddSubTabs(SubTabsConfig)
				local names = {}
				if type(SubTabsConfig) == "table" then
					for i, v in ipairs(SubTabsConfig) do
						names[i] = tostring(type(v) == "table" and (v.Name or v.Title) or v)
					end
				end
				if #names == 0 then names = {"Tab 1"} end
				local active = 1

				local Holder = Instance.new("Frame")
				Holder.Name = "SubTabs"
				Holder.BackgroundTransparency = 1
				Holder.BorderSizePixel = 0
				Holder.LayoutOrder = CountItem
				Holder.Size = UDim2.new(1, 0, 0, 44)
				Holder.Parent = SectionAdd
				CountItem = CountItem + 1

				local Bar = Instance.new("Frame")
				Bar.Name = "Bar"
				Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Bar.BackgroundTransparency = 0.935
				Bar.BorderSizePixel = 0
				Bar.Position = UDim2.new(0, 10, 0, 6)
				Bar.Size = UDim2.new(1, -20, 0, 30)
				Bar.Parent = Holder
				local BarCorner = Instance.new("UICorner")
				BarCorner.CornerRadius = UDim.new(0, 6)
				BarCorner.Parent = Bar
				local BarLayout = Instance.new("UIListLayout")
				BarLayout.FillDirection = Enum.FillDirection.Horizontal
				BarLayout.Padding = UDim.new(0, 4)
				BarLayout.SortOrder = Enum.SortOrder.LayoutOrder
				BarLayout.Parent = Bar
				local BarPad = Instance.new("UIPadding")
				BarPad.PaddingLeft = UDim.new(0, 3)
				BarPad.PaddingRight = UDim.new(0, 3)
				BarPad.PaddingTop = UDim.new(0, 3)
				BarPad.PaddingBottom = UDim.new(0, 3)
				BarPad.Parent = Bar

				local Pages = Instance.new("Frame")
				Pages.Name = "Pages"
				Pages.BackgroundTransparency = 1
				Pages.BorderSizePixel = 0
				Pages.Position = UDim2.new(0, 0, 0, 44)
				Pages.Size = UDim2.new(1, 0, 0, 0)
				Pages.Parent = Holder

				local buttons, pages, proxies = {}, {}, {}

				local function fit()
					local page = pages[active]
					local h = page and page.Layout.AbsoluteContentSize.Y or 0
					Pages.Size = UDim2.new(1, 0, 0, h)
					Holder.Size = UDim2.new(1, 0, 0, 44 + h + 8)
					UpdateSizeSection()
				end

				local function show(i)
					active = math.clamp(i, 1, #names)
					for k, page in ipairs(pages) do
						page.Frame.Visible = (k == active)
					end
					for k, b in ipairs(buttons) do
						local on = (k == active)
						TweenService:Create(b, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							BackgroundTransparency = on and 0.82 or 1,
							TextColor3 = on and Theme.Text or Theme.MutedText,
						}):Play()
					end
					task.delay(0.05, fit)
				end

				for i, name in ipairs(names) do
					local b = Instance.new("TextButton")
					b.Name = "SubTab" .. i
					b.Text = name
					b.Font = Enum.Font.GothamBold
					b.TextSize = 12
					b.TextColor3 = Theme.MutedText
					b.AutoButtonColor = false
					b.BackgroundColor3 = Theme.Accent
					b.BackgroundTransparency = 1
					b.BorderSizePixel = 0
					b.LayoutOrder = i
					b.Size = UDim2.new(1 / #names, -4, 1, 0)
					b.Parent = Bar
					local bCorner = Instance.new("UICorner")
					bCorner.CornerRadius = UDim.new(0, 5)
					bCorner.Parent = b
					b.MouseEnter:Connect(function()
						if active ~= i then
							TweenService:Create(b, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {TextColor3 = Theme.Text}):Play()
						end
					end)
					b.MouseLeave:Connect(function()
						if active ~= i then
							TweenService:Create(b, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {TextColor3 = Theme.MutedText}):Play()
						end
					end)
					b.Activated:Connect(function()
						show(i)
					end)
					buttons[i] = b

					local page = Instance.new("Frame")
					page.Name = "Page" .. i
					page.BackgroundTransparency = 1
					page.BorderSizePixel = 0
					page.Size = UDim2.new(1, 0, 1, 0)
					page.Visible = (i == 1)
					page.Parent = Pages
					local pageLayout = Instance.new("UIListLayout")
					pageLayout.Padding = UDim.new(0, 6)
					pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
					pageLayout.Parent = page
					pages[i] = {Frame = page, Layout = pageLayout}

					local proxy = {}
					for methodName, fn in pairs(Items) do
						if type(fn) == "function" and string.sub(methodName, 1, 3) == "Add" and methodName ~= "AddGroup" and methodName ~= "AddSubTabs" then
							proxy[methodName] = function(_, cfg, ...)
								local prev = SectionAdd
								SectionAdd = page
								local okCall, api = pcall(fn, Items, cfg, ...)
								SectionAdd = prev
								if not okCall then error(api, 2) end
								task.delay(0.05, fit)
								return api
							end
						end
					end
					proxies[i] = proxy
					pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
						if active == i then fit() end
					end)
				end

				function proxies:Select(i)
					show(tonumber(i) or 1)
					return true
				end

				show(1)
				return proxies
			end

			function Items:AddTag(TagConfig)
				TagConfig = TagConfig or {}
				local TagFunc = {}
				local chipCount = 0

				local Row = Instance.new("Frame")
				Row.Name = "Tags"
				Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Row.BackgroundTransparency = 0.935
				Row.BorderSizePixel = 0
				Row.LayoutOrder = CountItem
				Row.Size = UDim2.new(1, 0, 0, 54)
				Row.Parent = SectionAdd
				local Corner = Instance.new("UICorner")
				Corner.CornerRadius = UDim.new(0, 4)
				Corner.Parent = Row

				local Title = Instance.new("TextLabel")
				Title.Font = Enum.Font.GothamBold
				Title.Text = tostring(TagConfig.Title or "Tags")
				Title.TextColor3 = Theme.Text
				Title.TextSize = 13
				Title.TextXAlignment = Enum.TextXAlignment.Left
				Title.BackgroundTransparency = 1
				Title.Position = UDim2.new(0, 10, 0, 8)
				Title.Size = UDim2.new(1, -20, 0, 14)
				Title.Parent = Row

				local Chips = Instance.new("Frame")
				Chips.Name = "Chips"
				Chips.BackgroundTransparency = 1
				Chips.BorderSizePixel = 0
				Chips.Position = UDim2.new(0, 10, 0, 28)
				Chips.Size = UDim2.new(1, -20, 0, 18)
				Chips.Parent = Row
				local ChipLayout = Instance.new("UIListLayout")
				ChipLayout.FillDirection = Enum.FillDirection.Horizontal
				ChipLayout.Padding = UDim.new(0, 6)
				ChipLayout.SortOrder = Enum.SortOrder.LayoutOrder
				ChipLayout.Parent = Chips

				local function addChip(text, color)
					chipCount = chipCount + 1
					local chip = Instance.new("TextLabel")
					chip.Name = "Chip"
					chip.Font = Enum.Font.GothamBold
					chip.Text = tostring(text)
					chip.TextSize = 11
					chip.TextColor3 = typeof(color) == "Color3" and color or Theme.Text
					chip.BackgroundColor3 = typeof(color) == "Color3" and color or Theme.Accent
					chip.BackgroundTransparency = 0.82
					chip.BorderSizePixel = 0
					chip.AutomaticSize = Enum.AutomaticSize.X
					chip.Size = UDim2.new(0, 0, 1, 0)
					chip.LayoutOrder = chipCount
					chip.Parent = Chips
					local chipCorner = Instance.new("UICorner")
					chipCorner.CornerRadius = UDim.new(1, 0)
					chipCorner.Parent = chip
					local chipPad = Instance.new("UIPadding")
					chipPad.PaddingLeft = UDim.new(0, 8)
					chipPad.PaddingRight = UDim.new(0, 8)
					chipPad.Parent = chip
				end

				local function clearChips()
					for _, child in ipairs(Chips:GetChildren()) do
						if child:IsA("TextLabel") then child:Destroy() end
					end
					chipCount = 0
				end

				for _, t in ipairs(TagConfig.Tags or {}) do
					if type(t) == "table" then
						addChip(t.Text or t.Name or "", t.Color)
					else
						addChip(t, nil)
					end
				end

				function TagFunc:Set(list)
					clearChips()
					for _, t in ipairs(list or {}) do
						if type(t) == "table" then
							addChip(t.Text or t.Name or "", t.Color)
						else
							addChip(t, nil)
						end
					end
					return true
				end
				function TagFunc:Add(text, color)
					addChip(text, color)
					return true
				end

				CountItem = CountItem + 1
				return attachElementControls(TagFunc, Row)
			end

			do
				local function openExternal(url)
					local GuiService = game:GetService("GuiService")
					local okOpen = pcall(function() GuiService:OpenBrowserWindow(url) end)
					if okOpen then
						FlurioreLib:MakeNotify({Title = "Link", Content = "Opened in your browser", Delay = 2})
						return true
					end
					if type(setclipboard) == "function" then
						pcall(setclipboard, url)
						FlurioreLib:MakeNotify({Title = "Link copied", Content = url, Delay = 3})
						return true
					end
					FlurioreLib:MakeNotify({Title = "Link", Content = url, Delay = 4})
					return false
				end

				-- Card: a link card (invite, website, shop). Button runs Action, or opens Url.
				function Items:AddCard(CardConfig)
					CardConfig = CardConfig or {}
					CardConfig.Title = CardConfig.Title or "Card"
					CardConfig.Content = CardConfig.Content or ""
					local CardFunc = {}

					local Row = Instance.new("Frame")
					Row.Name = "Card"
					Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Row.BackgroundTransparency = 0.935
					Row.BorderSizePixel = 0
					Row.LayoutOrder = CountItem
					Row.Size = UDim2.new(1, 0, 0, 62)
					Row.Parent = SectionAdd
					local Corner = Instance.new("UICorner")
					Corner.CornerRadius = UDim.new(0, 4)
					Corner.Parent = Row

					local Badge = Instance.new("Frame")
					Badge.Name = "Badge"
					Badge.BackgroundColor3 = Theme.Accent
					Badge.BackgroundTransparency = 0.1
					Badge.BorderSizePixel = 0
					Badge.Position = UDim2.new(0, 10, 0, 11)
					Badge.Size = UDim2.new(0, 40, 0, 40)
					Badge.Parent = Row
					local BadgeCorner = Instance.new("UICorner")
					BadgeCorner.CornerRadius = UDim.new(0, 8)
					BadgeCorner.Parent = Badge
					if type(CardConfig.Image) == "string" and CardConfig.Image:find("rbxassetid", 1, true) then
						local icon = Instance.new("ImageLabel")
						icon.BackgroundTransparency = 1
						icon.Image = CardConfig.Image
						icon.Position = UDim2.new(0, 4, 0, 4)
						icon.Size = UDim2.new(1, -8, 1, -8)
						icon.Parent = Badge
					else
						local letter = Instance.new("TextLabel")
						letter.BackgroundTransparency = 1
						letter.Font = Enum.Font.GothamBold
						letter.TextSize = 16
						letter.TextColor3 = Theme.Background
						letter.Text = string.upper(string.sub(CardConfig.Title, 1, 1))
						letter.Size = UDim2.new(1, 0, 1, 0)
						letter.Parent = Badge
					end

					local Title = Instance.new("TextLabel")
					Title.Font = Enum.Font.GothamBold
					Title.Text = CardConfig.Title
					Title.TextColor3 = Theme.Text
					Title.TextSize = 13
					Title.TextXAlignment = Enum.TextXAlignment.Left
					Title.TextTruncate = Enum.TextTruncate.AtEnd
					Title.BackgroundTransparency = 1
					Title.Position = UDim2.new(0, 60, 0, 12)
					Title.Size = UDim2.new(1, -150, 0, 14)
					Title.Parent = Row

					local Content = Instance.new("TextLabel")
					Content.Font = Enum.Font.Gotham
					Content.Text = CardConfig.Content
					Content.TextColor3 = Theme.MutedText
					Content.TextSize = 12
					Content.TextXAlignment = Enum.TextXAlignment.Left
					Content.TextTruncate = Enum.TextTruncate.AtEnd
					Content.BackgroundTransparency = 1
					Content.Position = UDim2.new(0, 60, 0, 30)
					Content.Size = UDim2.new(1, -150, 0, 14)
					Content.Parent = Row

					local Button = Instance.new("TextButton")
					Button.Name = "CardButton"
					Button.Text = tostring(CardConfig.ButtonLabel or "Open")
					Button.Font = Enum.Font.GothamBold
					Button.TextSize = 12
					Button.TextColor3 = Theme.Background
					Button.AutoButtonColor = false
					Button.BackgroundColor3 = Theme.Accent
					Button.BackgroundTransparency = 0
					Button.BorderSizePixel = 0
					Button.AnchorPoint = Vector2.new(1, 0.5)
					Button.Position = UDim2.new(1, -10, 0.5, 0)
					Button.Size = UDim2.new(0, 80, 0, 28)
					Button.Parent = Row
					local ButtonCorner = Instance.new("UICorner")
					ButtonCorner.CornerRadius = UDim.new(0, 4)
					ButtonCorner.Parent = Button

					Button.MouseEnter:Connect(function()
						TweenService:Create(Button, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.15}):Play()
					end)
					Button.MouseLeave:Connect(function()
						TweenService:Create(Button, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
					end)
					Button.Activated:Connect(function()
						if type(CardConfig.Action) == "function" then
							local okAct, err = pcall(CardConfig.Action)
							if not okAct then warn("[AddCard] action error: " .. tostring(err)) end
						elseif type(CardConfig.Url) == "string" and CardConfig.Url ~= "" then
							openExternal(CardConfig.Url)
						end
					end)

					function CardFunc:SetTitle(text)
						Title.Text = tostring(text)
						return true
					end
					function CardFunc:SetContent(text)
						Content.Text = tostring(text)
						return true
					end

					CountItem = CountItem + 1
					return attachElementControls(CardFunc, Row)
				end
			end

			-- Viewport: previews a Model (pass an Instance). It is cloned and slowly rotated.
			do
				local RunService = game:GetService("RunService")

				function Items:AddViewport(ViewportConfig)
					ViewportConfig = ViewportConfig or {}
					local height = math.max(90, tonumber(ViewportConfig.Height) or 150)
					local ViewportFunc = {}

					local Row = Instance.new("Frame")
					Row.Name = "Viewport"
					Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Row.BackgroundTransparency = 0.935
					Row.BorderSizePixel = 0
					Row.LayoutOrder = CountItem
					Row.Size = UDim2.new(1, 0, 0, height + 12)
					Row.Parent = SectionAdd
					local Corner = Instance.new("UICorner")
					Corner.CornerRadius = UDim.new(0, 4)
					Corner.Parent = Row

					local vp = Instance.new("ViewportFrame")
					vp.Name = "Preview"
					vp.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
					vp.BackgroundTransparency = 0.1
					vp.BorderSizePixel = 0
					vp.Position = UDim2.new(0, 6, 0, 6)
					vp.Size = UDim2.new(1, -12, 1, -12)
					vp.Ambient = Color3.fromRGB(170, 170, 180)
					vp.LightColor = Color3.fromRGB(255, 255, 255)
					vp.Parent = Row
					local vpCorner = Instance.new("UICorner")
					vpCorner.CornerRadius = UDim.new(0, 4)
					vpCorner.Parent = vp

					local cam = Instance.new("Camera")
					cam.FieldOfView = 40
					cam.Parent = vp
					vp.CurrentCamera = cam

					local model = nil
					local spin = 0
					local conn = nil

					local function setModel(m)
						if model then
							model:Destroy()
							model = nil
						end
						if typeof(m) ~= "Instance" or not (m:IsA("Model") or m:IsA("BasePart")) then
							return false
						end
						model = m:Clone()
						if model:IsA("BasePart") then
							model.Anchored = true
							model.CanCollide = false
						end
						for _, d in ipairs(model:GetDescendants()) do
							if d:IsA("BasePart") then
								d.Anchored = true
								d.CanCollide = false
							end
						end
						model.Parent = vp
						return true
					end

					conn = RunService.RenderStepped:Connect(function(dt)
						if not model or not model.Parent then return end
						local cf, size
						if model:IsA("Model") then
							cf, size = model:GetBoundingBox()
						else
							cf, size = model.CFrame, model.Size
						end
						spin = spin + dt * 0.5
						local radius = math.max(size.X, size.Y, size.Z) * 1.2 + 1
						local center = cf.Position
						cam.CFrame = CFrame.lookAt(
							center + Vector3.new(math.sin(spin) * radius, size.Y * 0.25 + radius * 0.2, math.cos(spin) * radius),
							center
						)
					end)
					Row.AncestryChanged:Connect(function(_, parent)
						if not parent and conn then
							conn:Disconnect()
							conn = nil
						end
					end)

					setModel(ViewportConfig.Model)

					function ViewportFunc:SetModel(m)
						return setModel(m)
					end
					function ViewportFunc:SetHeight(h)
						Row.Size = UDim2.new(1, 0, 0, math.max(90, tonumber(h) or 150) + 12)
						return true
					end

					CountItem = CountItem + 1
					return attachElementControls(ViewportFunc, Row)
				end
			end


			-- Discord widget: live data from Discord's public endpoints.
			--   invite:  GET https://discord.com/api/v10/invites/{code}?with_counts=true   (name, icon, member and online counts)
			--   widget:  GET https://discord.com/api/guilds/{id}/widget.json              (live online members, only if the owner enabled the widget)
			-- Public and unauthenticated. Results are cached for 20 seconds, and the card refreshes at most every 30 seconds.
			do
				local discordCache = {}

				local function openExternal(url)
					local GuiService = game:GetService("GuiService")
					local okOpen = pcall(function() GuiService:OpenBrowserWindow(url) end)
					if okOpen then
						FlurioreLib:MakeNotify({Title = "Link", Content = "Opened in your browser", Delay = 2})
						return true
					end
					if type(setclipboard) == "function" then
						pcall(setclipboard, url)
						FlurioreLib:MakeNotify({Title = "Link copied", Content = url, Delay = 3})
						return true
					end
					FlurioreLib:MakeNotify({Title = "Link", Content = url, Delay = 4})
					return false
				end

				local function parseInvite(text)
					local str = tostring(text or "")
					str = string.match(str, "^%s*(.-)%s*$")
					str = (string.gsub(str, "[%?#].*$", ""))
					str = (string.gsub(str, "/+$", ""))
					return string.match(str, "([%w%-]+)$")
				end

				local function fmtNumber(n)
					local digits = tostring(math.floor(tonumber(n) or 0))
					local reversed = string.reverse(digits)
					local grouped = (string.gsub(reversed, "(%d%d%d)", "%1,"))
					local out = string.reverse(grouped)
					return (string.gsub(out, "^,", ""))
				end

				local function escapeRich(text)
					local out = string.gsub(tostring(text), "&", "&amp;")
					out = string.gsub(out, "<", "&lt;")
					out = string.gsub(out, ">", "&gt;")
					return out
				end

				local function httpJson(url)
					local reqFn = (type(request) == "function" and request) or (type(http_request) == "function" and http_request) or nil
					local body, status, retry
					if reqFn then
						local okReq, res = pcall(reqFn, {Url = url, Method = "GET", Headers = {Accept = "application/json"}})
						if not okReq or type(res) ~= "table" then return nil, "Network error" end
						body, status = res.Body, res.StatusCode
						local headers = type(res.Headers) == "table" and res.Headers or {}
						retry = tonumber(headers["retry-after"] or headers["Retry-After"])
					else
						local okGet, text = pcall(function() return game:HttpGet(url) end)
						if not okGet then return nil, "Network error" end
						body = text
					end
					if status == 429 then return nil, "Rate limited", retry or 30, 429 end
					if type(status) == "number" and status >= 400 then
						return nil, "HTTP " .. tostring(status), nil, status
					end
					local okDecode, data = pcall(function() return HttpService:JSONDecode(body) end)
					if not okDecode or type(data) ~= "table" then return nil, "Bad response" end
					return data, nil, nil, status
				end

				local function fetchInvite(code)
					local data, err, retry, status = httpJson("https://discord.com/api/v10/invites/" .. code .. "?with_counts=true&with_expiration=true")
					if not data then
						if status == 404 then return nil, "Invite not found" end
						return nil, err, retry
					end
					if type(data.guild) ~= "table" then
						return nil, tostring(data.message or "Invite not found")
					end
					return {
						code = code,
						id = tostring(data.guild.id),
						name = tostring(data.guild.name or code),
						icon = data.guild.icon,
						description = data.guild.description,
						channel = data.channel and data.channel.name,
						members = tonumber(data.approximate_member_count) or 0,
						online = tonumber(data.approximate_presence_count) or 0,
					}
				end

				local function fetchWidget(guildId)
					local data = httpJson("https://discord.com/api/guilds/" .. guildId .. "/widget.json")
					if type(data) ~= "table" then return nil end
					local names = {}
					for _, member in ipairs(data.members or {}) do
						table.insert(names, tostring(member.username or member.name or "?"))
					end
					return {presence = tonumber(data.presence_count), names = names}
				end

				local function loadIcon(info, iconImage, letter)
					if not info.icon or type(writefile) ~= "function" or type(getcustomasset) ~= "function" then return end
					local fileName = "FlurDiscord_" .. info.id .. "_" .. info.icon .. ".png"
					task.spawn(function()
						local okAsset, asset = pcall(function()
							if not (type(isfile) == "function" and isfile(fileName)) then
								writefile(fileName, game:HttpGet("https://cdn.discordapp.com/icons/" .. info.id .. "/" .. info.icon .. ".png?size=128"))
							end
							return getcustomasset(fileName)
						end)
						if okAsset and asset and iconImage.Parent then
							iconImage.Image = asset
							iconImage.Visible = true
							letter.Visible = false
						end
					end)
				end

				function Items:AddDiscord(DiscordConfig)
					DiscordConfig = DiscordConfig or {}
					local interval = math.max(30, tonumber(DiscordConfig.Refresh) or 60)
					local code = parseInvite(DiscordConfig.Invite)
					local DiscordFunc = {}
					local alive = true
					local busy = false
					local nextDelay = interval
					local lastData = nil

					local Row = Instance.new("Frame")
					Row.Name = "Discord"
					Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Row.BackgroundTransparency = 0.935
					Row.BorderSizePixel = 0
					Row.LayoutOrder = CountItem
					Row.Size = UDim2.new(1, 0, 0, 96)
					Row.Parent = SectionAdd
					local RowCorner = Instance.new("UICorner")
					RowCorner.CornerRadius = UDim.new(0, 4)
					RowCorner.Parent = Row

					local Icon = Instance.new("Frame")
					Icon.Name = "Icon"
					Icon.BackgroundColor3 = Theme.Accent
					Icon.BackgroundTransparency = 0.85
					Icon.BorderSizePixel = 0
					Icon.Position = UDim2.new(0, 12, 0, 12)
					Icon.Size = UDim2.new(0, 44, 0, 44)
					Icon.Parent = Row
					local IconCorner = Instance.new("UICorner")
					IconCorner.CornerRadius = UDim.new(0, 10)
					IconCorner.Parent = Icon

					local Letter = Instance.new("TextLabel")
					Letter.Name = "Letter"
					Letter.BackgroundTransparency = 1
					Letter.Font = Enum.Font.GothamBold
					Letter.TextSize = 18
					Letter.TextColor3 = Theme.Accent
					Letter.Text = "D"
					Letter.Size = UDim2.new(1, 0, 1, 0)
					Letter.Parent = Icon

					local IconImage = Instance.new("ImageLabel")
					IconImage.Name = "IconImage"
					IconImage.BackgroundTransparency = 1
					IconImage.Visible = false
					IconImage.Size = UDim2.new(1, 0, 1, 0)
					IconImage.Parent = Icon
					local IconImageCorner = Instance.new("UICorner")
					IconImageCorner.CornerRadius = UDim.new(0, 10)
					IconImageCorner.Parent = IconImage

					local NameLabel = Instance.new("TextLabel")
					NameLabel.Name = "ServerName"
					NameLabel.BackgroundTransparency = 1
					NameLabel.Font = Enum.Font.GothamBold
					NameLabel.TextSize = 13
					NameLabel.TextColor3 = Theme.Text
					NameLabel.TextXAlignment = Enum.TextXAlignment.Left
					NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
					NameLabel.Text = code and ("discord.gg/" .. code) or "Discord"
					NameLabel.Position = UDim2.new(0, 68, 0, 12)
					NameLabel.Size = UDim2.new(1, -176, 0, 16)
					NameLabel.Parent = Row

					local SubLabel = Instance.new("TextLabel")
					SubLabel.Name = "Subtitle"
					SubLabel.BackgroundTransparency = 1
					SubLabel.Font = Enum.Font.Gotham
					SubLabel.TextSize = 11
					SubLabel.TextColor3 = Theme.MutedText
					SubLabel.TextXAlignment = Enum.TextXAlignment.Left
					SubLabel.TextTruncate = Enum.TextTruncate.AtEnd
					SubLabel.Text = ""
					SubLabel.Position = UDim2.new(0, 68, 0, 30)
					SubLabel.Size = UDim2.new(1, -176, 0, 14)
					SubLabel.Parent = Row

					local StatsLabel = Instance.new("TextLabel")
					StatsLabel.Name = "Stats"
					StatsLabel.BackgroundTransparency = 1
					StatsLabel.Font = Enum.Font.Gotham
					StatsLabel.TextSize = 11
					StatsLabel.TextColor3 = Theme.MutedText
					StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
					StatsLabel.TextTruncate = Enum.TextTruncate.AtEnd
					StatsLabel.RichText = true
					StatsLabel.Text = "Loading..."
					StatsLabel.Position = UDim2.new(0, 68, 0, 50)
					StatsLabel.Size = UDim2.new(1, -176, 0, 14)
					StatsLabel.Parent = Row

					local LiveLabel = Instance.new("TextLabel")
					LiveLabel.Name = "Live"
					LiveLabel.BackgroundTransparency = 1
					LiveLabel.Font = Enum.Font.Gotham
					LiveLabel.TextSize = 11
					LiveLabel.TextColor3 = Theme.MutedText
					LiveLabel.TextXAlignment = Enum.TextXAlignment.Left
					LiveLabel.TextTruncate = Enum.TextTruncate.AtEnd
					LiveLabel.Visible = false
					LiveLabel.Text = ""
					LiveLabel.Position = UDim2.new(0, 12, 0, 70)
					LiveLabel.Size = UDim2.new(1, -24, 0, 14)
					LiveLabel.Parent = Row

					local JoinBtn = Instance.new("TextButton")
					JoinBtn.Name = "Join"
					JoinBtn.Text = "Join"
					JoinBtn.Font = Enum.Font.GothamBold
					JoinBtn.TextSize = 12
					JoinBtn.TextColor3 = Theme.Background
					JoinBtn.AutoButtonColor = false
					JoinBtn.BackgroundColor3 = Theme.Accent
					JoinBtn.BackgroundTransparency = 0
					JoinBtn.BorderSizePixel = 0
					JoinBtn.AnchorPoint = Vector2.new(1, 0)
					JoinBtn.Position = UDim2.new(1, -12, 0, 12)
					JoinBtn.Size = UDim2.new(0, 76, 0, 28)
					JoinBtn.Parent = Row
					local JoinCorner = Instance.new("UICorner")
					JoinCorner.CornerRadius = UDim.new(0, 4)
					JoinCorner.Parent = JoinBtn
					JoinBtn.MouseEnter:Connect(function()
						TweenService:Create(JoinBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.15}):Play()
					end)
					JoinBtn.MouseLeave:Connect(function()
						TweenService:Create(JoinBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
					end)
					JoinBtn.Activated:Connect(function()
						if code then openExternal("https://discord.gg/" .. code) end
					end)

					local function renderError(message)
						StatsLabel.Text = "Couldn't load: " .. escapeRich(message)
					end

					local function render(info, widget)
						NameLabel.Text = info.name
						local desc = string.gsub(tostring(info.description or ""), "%s+", " ")
						SubLabel.Text = (desc ~= "") and desc or ("#" .. tostring(info.channel or "general"))
						local online = (widget and widget.presence) or info.online
						StatsLabel.Text = string.format(
							'<font color="#43B581">●</font> %s online    <font color="#747F8D">●</font> %s members',
							fmtNumber(online), fmtNumber(info.members)
						)
						if widget and #widget.names > 0 then
							local shown = {}
							for i = 1, math.min(3, #widget.names) do
								table.insert(shown, widget.names[i])
							end
							local extra = #widget.names - #shown
							LiveLabel.Text = "Online now: " .. table.concat(shown, ", ") .. (extra > 0 and (" +" .. extra) or "")
							LiveLabel.Visible = true
						else
							LiveLabel.Visible = false
						end
						Letter.Text = string.upper(string.sub(info.name, 1, 1))
						loadIcon(info, IconImage, Letter)
						NameLabel.TextTransparency = 1
						TweenService:Create(NameLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
					end

					local function refresh(force)
						if not code then
							renderError("no invite set")
							return false
						end
						local entry = discordCache[code]
						if not force and entry and tick() - entry.at < 20 then
							lastData = entry.data
							render(entry.data, entry.widget)
							return true
						end
						if busy then return false end
						busy = true
						local info, err, retry = fetchInvite(code)
						local widget = nil
						if info then
							widget = fetchWidget(info.id)
						end
						busy = false
						if not alive then return false end
						if info then
							discordCache[code] = {data = info, widget = widget, at = tick()}
							lastData = info
							render(info, widget)
							nextDelay = interval
							return true
						end
						renderError(err or "unknown error")
						nextDelay = math.max(15, retry or 30)
						return false
					end

					Row.AncestryChanged:Connect(function(_, parent)
						if not parent then alive = false end
					end)

					task.spawn(function()
						refresh(false)
						while alive and Row.Parent do
							task.wait(nextDelay)
							if not alive or not Row.Parent then break end
							refresh(false)
						end
					end)

					function DiscordFunc:Refresh()
						return refresh(true)
					end
					function DiscordFunc:SetInvite(text)
						local newCode = parseInvite(text)
						if not newCode then
							renderError("invalid invite")
							return false
						end
						code = newCode
						NameLabel.Text = "discord.gg/" .. code
						task.spawn(function()
							refresh(true)
						end)
						return true
					end
					function DiscordFunc:GetData()
						return lastData
					end
					function DiscordFunc:Join()
						if code then
							return openExternal("https://discord.gg/" .. code)
						end
						return false
					end

					CountItem = CountItem + 1
					return attachElementControls(DiscordFunc, Row)
				end
			end


			-- element:OnChanged(fn) listens for every value change of that element (chainable)
			do
				local listenerTargets = {"AddToggle", "AddSlider", "AddInput", "AddDropdown", "AddKeybind", "AddColorPicker", "AddColorCycle", "AddTextArea"}
				for _, name in ipairs(listenerTargets) do
					local original = Items[name]
					if original then
						Items[name] = function(self, cfg)
							cfg = cfg or {}
							local listeners = {}
							local userCallback = cfg.Callback
							cfg.Callback = function(...)
								if type(userCallback) == "function" then userCallback(...) end
								for _, fn in ipairs(listeners) do
									task.spawn(fn, ...)
								end
							end
							local api = original(self, cfg)
							if type(api) == "table" then
								function api:OnChanged(fn)
									if type(fn) == "function" then
										table.insert(listeners, fn)
									end
									return api
								end
							end
							return api
						end
					end
				end
			end

			function Items:AddCode(CodeConfig)
				CodeConfig = CodeConfig or {}
				local CodeFunc = {}
				local codeText = tostring(CodeConfig.Code or CodeConfig.Content or "")

				local Row = Instance.new("Frame")
				Row.Name = "Code"
				Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Row.BackgroundTransparency = 0.935
				Row.BorderSizePixel = 0
				Row.LayoutOrder = CountItem
				Row.Size = UDim2.new(1, 0, 0, 40)
				Row.Parent = SectionAdd
				local Corner = Instance.new("UICorner")
				Corner.CornerRadius = UDim.new(0, 4)
				Corner.Parent = Row

				local Heading = Instance.new("TextLabel")
				Heading.Name = "CodeTitle"
				Heading.BackgroundTransparency = 1
				Heading.Font = Enum.Font.GothamBold
				Heading.TextSize = 12
				Heading.TextColor3 = Color3.fromRGB(235, 235, 235)
				Heading.TextXAlignment = Enum.TextXAlignment.Left
				Heading.Text = tostring(CodeConfig.Title or "Code")
				Heading.Position = UDim2.new(0, 10, 0, 8)
				Heading.Size = UDim2.new(1, -90, 0, 14)
				Heading.Parent = Row

				local CopyBtn = Instance.new("TextButton")
				CopyBtn.Name = "Copy"
				CopyBtn.Text = "Copy"
				CopyBtn.Font = Enum.Font.GothamBold
				CopyBtn.TextSize = 11
				CopyBtn.TextColor3 = Color3.fromRGB(235, 235, 235)
				CopyBtn.AutoButtonColor = false
				CopyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				CopyBtn.BackgroundTransparency = 0.9
				CopyBtn.BorderSizePixel = 0
				CopyBtn.AnchorPoint = Vector2.new(1, 0)
				CopyBtn.Position = UDim2.new(1, -8, 0, 6)
				CopyBtn.Size = UDim2.new(0, 64, 0, 20)
				CopyBtn.Parent = Row
				local CopyCorner = Instance.new("UICorner")
				CopyCorner.CornerRadius = UDim.new(0, 4)
				CopyCorner.Parent = CopyBtn

				local Body = Instance.new("TextLabel")
				Body.Name = "CodeBody"
				Body.BackgroundTransparency = 1
				Body.Font = Enum.Font.Code
				Body.TextSize = 12
				Body.TextColor3 = Color3.fromRGB(200, 200, 210)
				Body.TextXAlignment = Enum.TextXAlignment.Left
				Body.TextYAlignment = Enum.TextYAlignment.Top
				Body.TextWrapped = true
				Body.Position = UDim2.new(0, 10, 0, 32)
				Body.Parent = Row

				local function layoutBody()
					local bounds = TextService:GetTextSize(codeText, 12, Enum.Font.Code, Vector2.new(260, 10000))
					local h = math.max(14, math.ceil(bounds.Y))
					Body.Text = codeText
					Body.Size = UDim2.new(1, -20, 0, h)
					Row.Size = UDim2.new(1, 0, 0, 32 + h + 10)
				end
				layoutBody()

				local function copyNow()
					local ok = false
					if type(setclipboard) == "function" then
						ok = pcall(setclipboard, codeText)
					end
					CopyBtn.Text = ok and "Copied" or "No clipboard"
					task.delay(1.2, function()
						CopyBtn.Text = "Copy"
					end)
					return ok
				end
				CopyBtn.Activated:Connect(copyNow)

				function CodeFunc:Set(text)
					codeText = tostring(text)
					layoutBody()
					return true
				end
				function CodeFunc:Copy()
					return copyNow()
				end

				CountItem = CountItem + 1
				return attachElementControls(CodeFunc, Row)
			end

			function Items:AddImage(ImageConfig)
				ImageConfig = ImageConfig or {}
				local ImageFunc = {}

				local Row = Instance.new("Frame")
				Row.Name = "Image"
				Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Row.BackgroundTransparency = 0.935
				Row.BorderSizePixel = 0
				Row.LayoutOrder = CountItem
				Row.Size = UDim2.new(1, 0, 0, math.max(24, tonumber(ImageConfig.Height) or 140))
				Row.Parent = SectionAdd
				local Corner = Instance.new("UICorner")
				Corner.CornerRadius = UDim.new(0, 4)
				Corner.Parent = Row

				local Picture = Instance.new("ImageLabel")
				Picture.Name = "Picture"
				Picture.BackgroundTransparency = 1
				Picture.BorderSizePixel = 0
				Picture.ScaleType = ImageConfig.Crop and Enum.ScaleType.Crop or Enum.ScaleType.Fit
				Picture.Image = tostring(ImageConfig.Image or "")
				Picture.Position = UDim2.new(0, 8, 0, 8)
				Picture.Size = UDim2.new(1, -16, 1, -16)
				Picture.Parent = Row

				function ImageFunc:Set(id)
					Picture.Image = tostring(id)
					return true
				end
				function ImageFunc:SetHeight(h)
					Row.Size = UDim2.new(1, 0, 0, math.max(24, tonumber(h) or 140))
					return true
				end

				CountItem = CountItem + 1
				return attachElementControls(ImageFunc, Row)
			end

			function Items:AddSpace(SpaceConfig)
				local h = type(SpaceConfig) == "table" and SpaceConfig.Height or SpaceConfig
				local Row = Instance.new("Frame")
				Row.Name = "Space"
				Row.BackgroundTransparency = 1
				Row.BorderSizePixel = 0
				Row.LayoutOrder = CountItem
				Row.Size = UDim2.new(1, 0, 0, math.max(0, tonumber(h) or 8))
				Row.Parent = SectionAdd
				CountItem = CountItem + 1
				return attachElementControls({}, Row)
			end

			-- Group: returns a table of column proxies. Use group[1]:AddToggle{...}, group[2]:AddSlider{...}
			function Items:AddGroup(GroupConfig)
				GroupConfig = GroupConfig or {}
				local count = math.clamp(math.floor(tonumber(GroupConfig.Columns) or 2), 1, 4)

				local Holder = Instance.new("Frame")
				Holder.Name = "Group"
				Holder.BackgroundTransparency = 1
				Holder.BorderSizePixel = 0
				Holder.LayoutOrder = CountItem
				Holder.Size = UDim2.new(1, 0, 0, 0)
				Holder.Parent = SectionAdd
				CountItem = CountItem + 1
				local rowLayout = Instance.new("UIListLayout")
				rowLayout.FillDirection = Enum.FillDirection.Horizontal
				rowLayout.Padding = UDim.new(0, 6)
				rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
				rowLayout.Parent = Holder

				local layouts = {}
				local proxies = {}
				local function fit()
					local tallest = 0
					for _, layout in ipairs(layouts) do
						tallest = math.max(tallest, layout.AbsoluteContentSize.Y)
					end
					Holder.Size = UDim2.new(1, 0, 0, tallest)
					UpdateSizeSection()
				end

				for i = 1, count do
					local col = Instance.new("Frame")
					col.Name = "Column" .. i
					col.BackgroundTransparency = 1
					col.BorderSizePixel = 0
					col.LayoutOrder = i
					col.Size = UDim2.new(1 / count, -6 * (count - 1) / count, 0, 0)
					col.Parent = Holder
					local colLayout = Instance.new("UIListLayout")
					colLayout.Padding = UDim.new(0, 6)
					colLayout.SortOrder = Enum.SortOrder.LayoutOrder
					colLayout.Parent = col
					layouts[i] = colLayout

					local proxy = {}
					for name, fn in pairs(Items) do
						if type(fn) == "function" and string.sub(name, 1, 3) == "Add" and name ~= "AddGroup" then
							proxy[name] = function(_, cfg, ...)
								local prev = SectionAdd
								SectionAdd = col
								local okCall, api = pcall(fn, Items, cfg, ...)
								SectionAdd = prev
								if not okCall then error(api, 2) end
								task.delay(0.05, fit)
								return api
							end
						end
					end
					proxies[i] = proxy
				end
				return proxies
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
	-- intro: rise and fade in when the window is built (GuiConfig.Intro = false to skip)
	if GuiConfig.Intro ~= false and DropShadowHolder.Visible then
	    local targetT = Main.BackgroundTransparency
	    local basePos = DropShadowHolder.Position
	    Main.BackgroundTransparency = 1
	    DropShadowHolder.Position = basePos + UDim2.new(0, 0, 0, 16)
	    local introInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	    TweenService:Create(Main, introInfo, {BackgroundTransparency = targetT}):Play()
	    TweenService:Create(DropShadowHolder, introInfo, {Position = basePos}):Play()
	end
	return Tabs
end
return FlurioreLib