--[[
	Angeryy05 UI Library
	Modern, feature-rich UI library for Roblox
	
	Created by: Angeryy05
	Version: 1.0.0
]]

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Load modules from GitHub
local function loadModule(path)
	local url = "https://raw.githubusercontent.com/KEVINPROX999/AngeryUI111/main/" .. path
	local success, result = pcall(function()
		return loadstring(game:HttpGet(url))()
	end)
	if success then
		return result
	else
		warn("Failed to load module:", path, result)
		return {}
	end
end

-- Load all required modules
local Signal = loadModule("Src/Packages/Signal.luau")
local Tween = loadModule("Src/Packages/Tween.luau")
local Icons = loadModule("Src/Modules/Icons.luau")

-- Simple theme system
local Themes = {
	Names = {"Angeryy05Dark", "Angeryy05Light", "CyberPunk", "Gradient", "Minimalist"},
	Current = "Angeryy05Dark",
	
	GetTheme = function(name)
		name = name or Themes.Current
		-- Load theme from GitHub
		return loadModule("Src/Themes/" .. name .. ".luau")
	end,
	
	SetTheme = function(name)
		if table.find(Themes.Names, name) then
			Themes.Current = name
			return true
		end
		return false
	end
}

-- Simple Creator system
local Creator = {
	Registry = {},
	Connections = {},
	
	New = function(className, properties)
		local instance = Instance.new(className)
		
		-- Default properties
		local defaults = {
			Frame = {BorderSizePixel = 0},
			TextLabel = {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				RichText = true
			},
			TextButton = {
				AutoButtonColor = false,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				RichText = true
			},
			UICorner = {CornerRadius = UDim.new(0, 8)},
			UIStroke = {Thickness = 1}
		}
		
		-- Apply defaults
		if defaults[className] then
			for prop, value in pairs(defaults[className]) do
				instance[prop] = value
			end
		end
		
		-- Apply custom properties
		if properties then
			for prop, value in pairs(properties) do
				if prop == "Parent" then
					continue -- Set parent last
				elseif prop:sub(1, 2) == "On" and instance[prop:sub(3)] then
					local connection = instance[prop:sub(3)]:Connect(value)
					table.insert(Creator.Connections, connection)
				else
					instance[prop] = value
				end
			end
			
			if properties.Parent then
				instance.Parent = properties.Parent
			end
		end
		
		table.insert(Creator.Registry, instance)
		return instance
	end,
	
	CreateButton = function(properties)
		local button = Creator.New("TextButton", properties)
		local corner = Creator.New("UICorner", {
			CornerRadius = UDim.new(0, properties.CornerRadius or 8),
			Parent = button
		})
		return button
	end,
	
	Disconnect = function()
		for _, connection in ipairs(Creator.Connections) do
			if connection.Connected then
				connection:Disconnect()
			end
		end
		table.clear(Creator.Connections)
		table.clear(Creator.Registry)
	end
}

-- Constants
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Get proper GUI parent
local function GetGUIParent()
	local success, result = pcall(function()
		return gethui and gethui() or get_hidden_ui and get_hidden_ui()
	end)
	
	if success and result then
		return result
	end
	
	success, result = pcall(function()
		CoreGui:GetFullName()
		return CoreGui
	end)
	
	if success and result then
		return result
	end
	
	return LocalPlayer:WaitForChild("PlayerGui")
end

-- Main ScreenGui container
local MainGui = Creator.New("ScreenGui", {
	Name = "Angeryy05_" .. HttpService:GenerateGUID(false):sub(1, 8),
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	Parent = GetGUIParent()
})

-- Main Library
local Angeryy05 = {
	Version = "1.0.0",
	Author = "Angeryy05",
	
	-- Core properties
	WindowCount = 0,
	OpenWindows = {},
	Options = {},
	Themes = Themes.Names,
	
	-- Events
	OnUnload = Signal.new(),
	ThemeChanged = Signal.new(),
	WindowCreated = Signal.new(),
	
	-- Settings
	CurrentTheme = "Angeryy05Dark",
	UseModernAnimations = true,
	GlobalCornerRadius = 12,
	AnimationSpeed = 0.3,
	
	-- Utilities
	Utilities = {
		Creator = Creator,
		Icons = Icons,
		Themes = Themes,
		Tween = Tween,
		Signal = Signal
	},
	
	-- Internal
	Connections = {},
	Loaded = true,
	Unloaded = false
}

-- Utility functions
function Angeryy05.Utilities:GetScreenSize()
	return Camera.ViewportSize
end

function Angeryy05.Utilities:CreateRipple(button, rippleColor)
	rippleColor = rippleColor or Color3.fromRGB(255, 255, 255)
	
	button.ClipsDescendants = true
	
	button.MouseButton1Down:Connect(function()
		local ripple = Creator.New("Frame", {
			Name = "Ripple",
			Size = UDim2.fromOffset(0, 0),
			Position = UDim2.fromOffset(Mouse.X - button.AbsolutePosition.X, Mouse.Y - button.AbsolutePosition.Y),
			BackgroundColor3 = rippleColor,
			BorderSizePixel = 0,
			BackgroundTransparency = 0.5,
			Parent = button
		})
		
		Creator.New("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = ripple
		})
		
		local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
		
		TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
			Size = UDim2.fromOffset(size, size),
			Position = UDim2.fromOffset((Mouse.X - button.AbsolutePosition.X) - size/2, (Mouse.Y - button.AbsolutePosition.Y) - size/2),
			BackgroundTransparency = 1
		}):Play()
		
		task.wait(0.6)
		ripple:Destroy()
	end)
end

-- Safe callback execution
function Angeryy05:SafeCallback(callback, ...)
	if typeof(callback) == "function" then
		local success, result = pcall(callback, ...)
		if not success then
			warn("Angeryy05 Callback Error:", result)
		end
		return success, result
	end
	return false, "Invalid callback"
end

-- Window creation
function Angeryy05:CreateWindow(config)
	config = config or {}
	
	-- Get theme
	local theme = Themes.GetTheme(config.Theme or Angeryy05.CurrentTheme)
	
	-- Create main window frame
	local WindowFrame = Creator.New("Frame", {
		Name = "Angeryy05Window",
		Size = config.Size or UDim2.fromOffset(600, 400),
		Position = config.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = config.AnchorPoint or Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.WindowBackground,
		Parent = MainGui
	})
	
	local WindowCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 12),
		Parent = WindowFrame
	})
	
	local WindowBorder = Creator.New("UIStroke", {
		Color = theme.WindowBorder,
		Thickness = 1,
		Parent = WindowFrame
	})
	
	-- Title bar
	local TitleBar = Creator.New("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = theme.TitleBar,
		Parent = WindowFrame
	})
	
	local TitleBarCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 12),
		Parent = TitleBar
	})
	
	-- Window title
	local WindowTitle = Creator.New("TextLabel", {
		Name = "WindowTitle",
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.fromOffset(15, 0),
		Text = config.Title or "Angeryy05 Window",
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TitleBar
	})
	
	-- Close button
	local CloseButton = Creator.CreateButton({
		Name = "CloseButton",
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.new(1, -35, 0, 5),
		BackgroundColor3 = theme.Error,
		Text = "×",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		Parent = TitleBar
	})
	
	-- Content area
	local ContentArea = Creator.New("Frame", {
		Name = "ContentArea",
		Size = UDim2.new(1, -20, 1, -60),
		Position = UDim2.fromOffset(10, 50),
		BackgroundColor3 = theme.Background,
		Parent = WindowFrame
	})
	
	local ContentCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = ContentArea
	})
	
	-- Tab container
	local TabContainer = Creator.New("Frame", {
		Name = "TabContainer",
		Size = UDim2.new(0, 180, 1, 0),
		BackgroundColor3 = theme.BackgroundSecondary,
		Parent = ContentArea
	})
	
	local TabContainerCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = TabContainer
	})
	
	-- Tab list
	local TabList = Creator.New("ScrollingFrame", {
		Name = "TabList",
		Size = UDim2.new(1, 0, 1, -10),
		Position = UDim2.fromOffset(0, 5),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.fromOffset(0, 0),
		Parent = TabContainer
	})
	
	local TabListLayout = Creator.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 5),
		Parent = TabList
	})
	
	-- Content container
	local TabContentContainer = Creator.New("Frame", {
		Name = "TabContentContainer",
		Size = UDim2.new(1, -190, 1, 0),
		Position = UDim2.fromOffset(190, 0),
		BackgroundTransparency = 1,
		Parent = ContentArea
	})
	
	-- Window object
	local Window = {
		Title = config.Title or "Angeryy05 Window",
		Frame = WindowFrame,
		TitleBar = TitleBar,
		ContentArea = ContentArea,
		TabContainer = TabContainer,
		TabContentContainer = TabContentContainer,
		Tabs = {},
		CurrentTab = nil
	}
	
	-- Window dragging
	local dragging = false
	local dragInput = nil
	local mousePos = nil
	local framePos = nil
	
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
			local delta = input.Position - mousePos
			WindowFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
		end
	end)
	
	-- Close button
	CloseButton.MouseButton1Click:Connect(function()
		TweenService:Create(WindowFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Size = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 1
		}):Play()
		task.wait(0.3)
		WindowFrame:Destroy()
	end)
	
	-- Tab creation
	function Window:CreateTab(tabConfig)
		tabConfig = tabConfig or {}
		
		local theme = Themes.GetTheme(Angeryy05.CurrentTheme)
		
		-- Create tab button
		local TabButton = Creator.CreateButton({
			Name = "TabButton",
			Size = UDim2.new(1, -10, 0, 35),
			BackgroundColor3 = theme.Tab,
			Text = tabConfig.Title or "Tab",
			TextColor3 = theme.TabText,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			Parent = TabList
		})
		
		-- Create tab content
		local TabContent = Creator.New("ScrollingFrame", {
			Name = "TabContent",
			Size = UDim2.new(1, -10, 1, -10),
			Position = UDim2.fromOffset(5, 5),
			BackgroundTransparency = 1,
			ScrollBarThickness = 4,
			CanvasSize = UDim2.fromOffset(0, 0),
			Visible = false,
			Parent = TabContentContainer
		})
		
		local TabContentLayout = Creator.New("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 8),
			Parent = TabContent
		})
		
		-- Tab object
		local Tab = {
			Title = tabConfig.Title or "Tab",
			Button = TabButton,
			Content = TabContent,
			Active = false,
			Elements = {}
		}
		
		-- Tab activation
		function Tab:Activate()
			-- Deactivate other tabs
			for _, otherTab in pairs(Window.Tabs) do
				if otherTab ~= Tab then
					otherTab.Active = false
					otherTab.Content.Visible = false
					TweenService:Create(otherTab.Button, TweenInfo.new(0.2), {
						BackgroundColor3 = theme.Tab
					}):Play()
				end
			end
			
			Tab.Active = true
			Tab.Content.Visible = true
			Window.CurrentTab = Tab
			
			TweenService:Create(TabButton, TweenInfo.new(0.2), {
				BackgroundColor3 = theme.TabActive
			}):Play()
		end
		
		-- Tab click
		TabButton.MouseButton1Click:Connect(function()
			Tab:Activate()
		end)
		
		-- Element creation
		function Tab:CreateButton(buttonConfig)
			buttonConfig = buttonConfig or {}
			
			local ButtonFrame = Creator.CreateButton({
				Name = "ButtonFrame",
				Size = UDim2.new(1, 0, 0, 45),
				BackgroundColor3 = theme.Button,
				Text = buttonConfig.Title or "Button",
				TextColor3 = theme.Text,
				Font = Enum.Font.GothamMedium,
				Parent = TabContent
			})
			
			if buttonConfig.Callback then
				ButtonFrame.MouseButton1Click:Connect(function()
					Angeryy05:SafeCallback(buttonConfig.Callback)
				end)
			end
			
			-- Update canvas size
			TabContent.CanvasSize = UDim2.fromOffset(0, TabContentLayout.AbsoluteContentSize.Y)
			
			return {
				Frame = ButtonFrame,
				SetTitle = function(self, title)
					ButtonFrame.Text = title
				end
			}
		end
		
		function Tab:CreateToggle(toggleConfig)
			toggleConfig = toggleConfig or {}
			
			local ToggleFrame = Creator.New("Frame", {
				Name = "ToggleFrame",
				Size = UDim2.new(1, 0, 0, 45),
				BackgroundColor3 = theme.Element,
				Parent = TabContent
			})
			
			local ToggleCorner = Creator.New("UICorner", {
				CornerRadius = UDim.new(0, 8),
				Parent = ToggleFrame
			})
			
			local ToggleTitle = Creator.New("TextLabel", {
				Size = UDim2.new(1, -60, 1, 0),
				Position = UDim2.fromOffset(10, 0),
				Text = toggleConfig.Title or "Toggle",
				TextColor3 = theme.Text,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = ToggleFrame
			})
			
			local ToggleSwitch = Creator.New("Frame", {
				Size = UDim2.fromOffset(40, 20),
				Position = UDim2.new(1, -50, 0.5, -10),
				BackgroundColor3 = theme.Toggle,
				Parent = ToggleFrame
			})
			
			local ToggleSwitchCorner = Creator.New("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = ToggleSwitch
			})
			
			local ToggleSlider = Creator.New("Frame", {
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.fromOffset(2, 2),
				BackgroundColor3 = theme.ToggleSlider,
				Parent = ToggleSwitch
			})
			
			local ToggleSliderCorner = Creator.New("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = ToggleSlider
			})
			
			local Toggle = {
				Value = toggleConfig.Default or false,
				Callback = toggleConfig.Callback
			}
			
			function Toggle:SetValue(value)
				Toggle.Value = value
				
				if value then
					TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {
						BackgroundColor3 = theme.ToggleActive
					}):Play()
					TweenService:Create(ToggleSlider, TweenInfo.new(0.2), {
						Position = UDim2.fromOffset(22, 2)
					}):Play()
				else
					TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {
						BackgroundColor3 = theme.Toggle
					}):Play()
					TweenService:Create(ToggleSlider, TweenInfo.new(0.2), {
						Position = UDim2.fromOffset(2, 2)
					}):Play()
				end
				
				if Toggle.Callback then
					Angeryy05:SafeCallback(Toggle.Callback, value)
				end
			end
			
			function Toggle:GetValue()
				return Toggle.Value
			end
			
			-- Initial state
			Toggle:SetValue(Toggle.Value)
			
			-- Click handler
			ToggleFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Toggle:SetValue(not Toggle.Value)
				end
			end)
			
			-- Update canvas size
			TabContent.CanvasSize = UDim2.fromOffset(0, TabContentLayout.AbsoluteContentSize.Y)
			
			return Toggle
		end
		
		function Tab:CreateParagraph(paragraphConfig)
			paragraphConfig = paragraphConfig or {}
			
			local ParagraphFrame = Creator.New("Frame", {
				Name = "ParagraphFrame",
				Size = UDim2.new(1, 0, 0, 60),
				BackgroundColor3 = theme.Element,
				Parent = TabContent
			})
			
			local ParagraphCorner = Creator.New("UICorner", {
				CornerRadius = UDim.new(0, 8),
				Parent = ParagraphFrame
			})
			
			if paragraphConfig.Title then
				local ParagraphTitle = Creator.New("TextLabel", {
					Size = UDim2.new(1, -20, 0, 20),
					Position = UDim2.fromOffset(10, 5),
					Text = paragraphConfig.Title,
					TextColor3 = theme.Text,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = ParagraphFrame
				})
			end
			
			local ParagraphContent = Creator.New("TextLabel", {
				Size = UDim2.new(1, -20, 0, 30),
				Position = UDim2.fromOffset(10, paragraphConfig.Title and 25 or 10),
				Text = paragraphConfig.Content or "Paragraph content",
				TextColor3 = theme.TextSecondary,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				Parent = ParagraphFrame
			})
			
			-- Update canvas size
			TabContent.CanvasSize = UDim2.fromOffset(0, TabContentLayout.AbsoluteContentSize.Y)
			
			return {
				Frame = ParagraphFrame,
				SetContent = function(self, content)
					ParagraphContent.Text = content
				end
			}
		end
		
		-- Update canvas size when layout changes
		TabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabContent.CanvasSize = UDim2.fromOffset(0, TabContentLayout.AbsoluteContentSize.Y)
		end)
		
		-- Add to window
		table.insert(Window.Tabs, Tab)
		
		-- Auto-activate first tab
		if #Window.Tabs == 1 then
			Tab:Activate()
		end
		
		-- Update tab list canvas
		TabList.CanvasSize = UDim2.fromOffset(0, TabListLayout.AbsoluteContentSize.Y)
		
		return Tab
	end
	
	-- Window functions
	function Window:SetTitle(title)
		Window.Title = title
		WindowTitle.Text = title
	end
	
	function Window:Close()
		WindowFrame:Destroy()
	end
	
	-- Add to library
	Angeryy05.WindowCount = Angeryy05.WindowCount + 1
	table.insert(Angeryy05.OpenWindows, Window)
	Angeryy05.WindowCreated:Fire(Window)
	
	return Window
end

-- Notification system
function Angeryy05:Notify(config)
	config = config or {}
	
	local theme = Themes.GetTheme(Angeryy05.CurrentTheme)
	
	-- Type colors
	local typeColors = {
		info = theme.Info,
		success = theme.Success,
		warning = theme.Warning,
		error = theme.Error
	}
	
	-- Create notification
	local NotificationFrame = Creator.New("Frame", {
		Name = "Notification",
		Size = UDim2.fromOffset(300, 70),
		Position = UDim2.new(1, -320, 0, 20),
		BackgroundColor3 = theme.Notification,
		Parent = MainGui
	})
	
	local NotificationCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = NotificationFrame
	})
	
	local NotificationBorder = Creator.New("UIStroke", {
		Color = theme.NotificationBorder,
		Thickness = 1,
		Parent = NotificationFrame
	})
	
	-- Accent bar
	local AccentBar = Creator.New("Frame", {
		Size = UDim2.new(0, 4, 1, 0),
		BackgroundColor3 = typeColors[config.Type] or theme.Info,
		Parent = NotificationFrame
	})
	
	local AccentBarCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 2),
		Parent = AccentBar
	})
	
	-- Title
	local NotificationTitle = Creator.New("TextLabel", {
		Size = UDim2.new(1, -50, 0, 20),
		Position = UDim2.fromOffset(15, 10),
		Text = config.Title or "Notification",
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = NotificationFrame
	})
	
	-- Content
	local NotificationContent = Creator.New("TextLabel", {
		Size = UDim2.new(1, -50, 0, 30),
		Position = UDim2.fromOffset(15, 30),
		Text = config.Content or "Notification content",
		TextColor3 = theme.TextSecondary,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = NotificationFrame
	})
	
	-- Close button
	local CloseButton = Creator.CreateButton({
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(1, -25, 0, 5),
		BackgroundColor3 = Color3.fromRGB(255, 60, 60),
		Text = "×",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 12,
		Parent = NotificationFrame
	})
	
	-- Animate in
	NotificationFrame.Position = UDim2.new(1, 20, 0, 20)
	TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = UDim2.new(1, -320, 0, 20)
	}):Play()
	
	-- Auto close
	local function closeNotification()
		TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Position = UDim2.new(1, 20, 0, 20),
			BackgroundTransparency = 1
		}):Play()
		task.wait(0.3)
		NotificationFrame:Destroy()
	end
	
	CloseButton.MouseButton1Click:Connect(closeNotification)
	
	if config.Duration then
		task.delay(config.Duration, closeNotification)
	end
	
	return {
		Frame = NotificationFrame,
		Close = closeNotification
	}
end

-- Theme management
function Angeryy05:SetTheme(themeName)
	if table.find(self.Themes, themeName) then
		self.CurrentTheme = themeName
		Themes.SetTheme(themeName)
		self.ThemeChanged:Fire(themeName)
		return true
	end
	return false
end

function Angeryy05:GetTheme()
	return self.CurrentTheme
end

function Angeryy05:GetAvailableThemes()
	return self.Themes
end

-- Destroy library
function Angeryy05:Destroy()
	if not self.Unloaded then
		self.Unloaded = true
		self.Loaded = false
		
		self.OnUnload:Fire()
		
		Creator.Disconnect()
		
		TweenService:Create(MainGui, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1
		}):Play()
		
		task.wait(0.5)
		MainGui:Destroy()
	end
end

-- Initialize
Angeryy05:SetTheme(Angeryy05.CurrentTheme)

return Angeryy05
