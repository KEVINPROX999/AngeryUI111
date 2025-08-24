--[[
	Angeryy05 Window Component
	Modern window with advanced features
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

return function(config, parent, library)
	local Creator = library.Utilities.Creator
	local Tween = library.Utilities.Tween
	local Icons = library.Utilities.Icons
	local Themes = library.Utilities.Themes
	local Signal = library.Utilities.Signal
	
	-- Window object
	local Window = {
		Title = config.Title,
		SubTitle = config.SubTitle,
		Size = config.Size,
		MinSize = config.MinSize,
		Position = config.Position,
		Resizable = config.Resizable,
		Minimizable = config.Minimizable,
		
		-- States
		Minimized = false,
		Maximized = false,
		Dragging = false,
		Resizing = false,
		
		-- Events
		OnMinimize = Signal.new(),
		OnMaximize = Signal.new(),
		OnResize = Signal.new(),
		OnMove = Signal.new(),
		OnClose = Signal.new(),
		
		-- Tabs
		Tabs = {},
		CurrentTab = nil,
		TabCount = 0
	}
	
	-- Get theme
	local theme = Themes.GetTheme(config.Theme or library.CurrentTheme)
	
	-- Create main window frame
	local WindowFrame = Creator.New("Frame", {
		Name = "Angeryy05Window",
		Size = config.Size,
		Position = config.Position,
		AnchorPoint = config.AnchorPoint,
		BackgroundColor3 = theme.WindowBackground,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = parent
	})
	
	-- Window corner
	local WindowCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, library.GlobalCornerRadius),
		Parent = WindowFrame
	})
	
	-- Window border
	local WindowBorder = Creator.New("UIStroke", {
		Color = theme.WindowBorder,
		Thickness = 1,
		Parent = WindowFrame
	})
	
	-- Drop shadow
	local Shadow = Creator.New("ImageLabel", {
		Name = "Shadow",
		Size = UDim2.new(1, 20, 1, 20),
		Position = UDim2.fromOffset(-10, -10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://6014261993",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.8,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		ZIndex = -1,
		Parent = WindowFrame
	})
	
	-- Title bar
	local TitleBar = Creator.New("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.fromOffset(0, 0),
		BackgroundColor3 = theme.TitleBar,
		BorderSizePixel = 0,
		Parent = WindowFrame
	})
	
	local TitleBarCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, library.GlobalCornerRadius),
		Parent = TitleBar
	})
	
	-- Title bar bottom border
	local TitleBarLine = Creator.New("Frame", {
		Name = "TitleBarLine",
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = theme.TitleBarLine,
		BorderSizePixel = 0,
		Parent = TitleBar
	})
	
	-- Window icon
	local WindowIcon = Creator.New("ImageLabel", {
		Name = "WindowIcon",
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.fromOffset(12, 10),
		BackgroundTransparency = 1,
		Image = config.Icon and Icons.Get(config.Icon) or Icons.Get("home"),
		ImageColor3 = theme.Text,
		Parent = TitleBar
	})
	
	-- Window title
	local WindowTitle = Creator.New("TextLabel", {
		Name = "WindowTitle",
		Size = UDim2.new(1, -120, 1, 0),
		Position = UDim2.fromOffset(40, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = config.Title,
		TextColor3 = theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TitleBar
	})
	
	-- Window subtitle
	local WindowSubTitle = Creator.New("TextLabel", {
		Name = "WindowSubTitle",
		Size = UDim2.new(1, -120, 1, 0),
		Position = UDim2.fromOffset(40, 15),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = config.SubTitle,
		TextColor3 = theme.TextSecondary,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TitleBar
	})
	
	-- Window controls
	local ControlsFrame = Creator.New("Frame", {
		Name = "Controls",
		Size = UDim2.fromOffset(80, 30),
		Position = UDim2.new(1, -85, 0, 5),
		BackgroundTransparency = 1,
		Parent = TitleBar
	})
	
	-- Minimize button
	local MinimizeButton = Creator.CreateButton({
		Name = "Minimize",
		Size = UDim2.fromOffset(25, 25),
		Position = UDim2.fromOffset(0, 0),
		BackgroundColor3 = theme.Button,
		Text = "",
		CornerRadius = 6,
		Parent = ControlsFrame
	})
	
	local MinimizeIcon = Creator.New("ImageLabel", {
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = Icons.Get("minimize"),
		ImageColor3 = theme.Text,
		Parent = MinimizeButton
	})
	
	-- Close button
	local CloseButton = Creator.CreateButton({
		Name = "Close",
		Size = UDim2.fromOffset(25, 25),
		Position = UDim2.fromOffset(30, 0),
		BackgroundColor3 = theme.Error,
		Text = "",
		CornerRadius = 6,
		Parent = ControlsFrame
	})
	
	local CloseIcon = Creator.New("ImageLabel", {
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = Icons.Get("x"),
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		Parent = CloseButton
	})
	
	-- Tab container
	local TabContainer = Creator.New("Frame", {
		Name = "TabContainer",
		Size = UDim2.new(0, 200, 1, -40),
		Position = UDim2.fromOffset(0, 40),
		BackgroundColor3 = theme.BackgroundSecondary,
		BorderSizePixel = 0,
		Parent = WindowFrame
	})
	
	local TabContainerCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 0),
		Parent = TabContainer
	})
	
	-- Tab list
	local TabList = Creator.New("ScrollingFrame", {
		Name = "TabList",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme.Accent,
		CanvasSize = UDim2.fromOffset(0, 0),
		Parent = TabContainer
	})
	
	local TabListLayout = Creator.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = TabList
	})
	
	-- Content container
	local ContentContainer = Creator.New("Frame", {
		Name = "ContentContainer",
		Size = UDim2.new(1, -200, 1, -40),
		Position = UDim2.fromOffset(200, 40),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = WindowFrame
	})
	
	local ContentCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 0),
		Parent = ContentContainer
	})
	
	-- Window dragging
	local dragging = false
	local dragInput = nil
	local mousePos = nil
	local framePos = nil
	
	local function updateInput(input)
		local delta = input.Position - mousePos
		WindowFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
	end
	
	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			framePos = WindowFrame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	TitleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			updateInput(input)
		end
	end)
	
	-- Window functions
	function Window:CreateTab(tabConfig)
		tabConfig = tabConfig or {}
		
		local Tab = require(script.Parent.Tab)(tabConfig, TabList, ContentContainer, Window, library)
		
		Window.TabCount = Window.TabCount + 1
		table.insert(Window.Tabs, Tab)
		
		-- Update tab list canvas size
		TabList.CanvasSize = UDim2.fromOffset(0, TabListLayout.AbsoluteContentSize.Y)
		
		-- Set as current tab if first tab
		if Window.TabCount == 1 then
			Tab:Activate()
			Window.CurrentTab = Tab
		end
		
		return Tab
	end
	
	function Window:SetTitle(title)
		Window.Title = title
		WindowTitle.Text = title
	end
	
	function Window:SetSubTitle(subtitle)
		Window.SubTitle = subtitle
		WindowSubTitle.Text = subtitle
	end
	
	function Window:Minimize()
		if not Window.Minimized then
			Window.Minimized = true
			Tween:Smooth(WindowFrame, 0.3, {
				Size = UDim2.new(Window.Size.X.Scale, Window.Size.X.Offset, 0, 40)
			})
			Window.OnMinimize:Fire(true)
		else
			Window.Minimized = false
			Tween:Smooth(WindowFrame, 0.3, {
				Size = Window.Size
			})
			Window.OnMinimize:Fire(false)
		end
	end
	
	function Window:Close()
		Window.OnClose:Fire()
		Tween:Smooth(WindowFrame, 0.3, {
			Size = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 1
		}, function()
			WindowFrame:Destroy()
		end)
	end
	
	function Window:Destroy()
		Window:Close()
	end
	
	-- Button connections
	MinimizeButton.MouseButton1Click:Connect(function()
		Window:Minimize()
	end)
	
	CloseButton.MouseButton1Click:Connect(function()
		Window:Close()
	end)
	
	-- Store references
	Window.Frame = WindowFrame
	Window.TitleBar = TitleBar
	Window.TabContainer = TabContainer
	Window.ContentContainer = ContentContainer
	
	return Window
end
