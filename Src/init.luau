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

-- Modules
local Root = script
local Components = Root.Components
local Elements = Root.Elements
local Modules = Root.Modules
local Themes = Root.Themes

local Creator = require(Modules.Creator)
local Icons = require(Modules.Icons)
local ThemeManager = require(Themes)
local Signal = require(Root.Packages.Signal)
local Tween = require(Root.Packages.Tween)

-- Constants
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Main Library
local Angeryy05 = {
	Version = "1.0.0",
	Author = "Angeryy05",
	
	-- Core properties
	WindowCount = 0,
	OpenWindows = {},
	Options = {},
	Themes = ThemeManager.Names,
	
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
		Themes = ThemeManager,
		Tween = Tween,
		Signal = Signal
	},
	
	-- Internal
	Connections = {},
	Loaded = true,
	Unloaded = false
}

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

-- Utility functions
function Angeryy05.Utilities:GetScreenSize()
	return Camera.ViewportSize
end

function Angeryy05.Utilities:ScaleSize(size, baseResolution)
	baseResolution = baseResolution or Vector2.new(1920, 1080)
	local screenSize = self:GetScreenSize()
	local scaleX = screenSize.X / baseResolution.X
	local scaleY = screenSize.Y / baseResolution.Y
	local scale = math.min(scaleX, scaleY)
	
	return UDim2.fromOffset(size.X.Offset * scale, size.Y.Offset * scale)
end

function Angeryy05.Utilities:Lerp(a, b, t)
	return a + (b - a) * t
end

function Angeryy05.Utilities:GetThemeColor(colorName)
	local theme = ThemeManager.GetTheme(Angeryy05.CurrentTheme)
	return theme[colorName] or Color3.fromRGB(255, 255, 255)
end

function Angeryy05.Utilities:CreateRipple(button, rippleColor)
	rippleColor = rippleColor or Color3.fromRGB(255, 255, 255)
	
	button.ClipsDescendants = true
	
	local function createRipple(x, y)
		local ripple = Creator.New("Frame", {
			Name = "Ripple",
			Size = UDim2.fromOffset(0, 0),
			Position = UDim2.fromOffset(x, y),
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
		
		Tween:Create(ripple, 0.6, {
			Size = UDim2.fromOffset(size, size),
			Position = UDim2.fromOffset(x - size/2, y - size/2),
			BackgroundTransparency = 1
		}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
		
		task.wait(0.6)
		ripple:Destroy()
	end
	
	button.MouseButton1Down:Connect(function()
		local x = Mouse.X - button.AbsolutePosition.X
		local y = Mouse.Y - button.AbsolutePosition.Y
		task.spawn(createRipple, x, y)
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
	
	-- Validate config
	assert(typeof(config) == "table", "Config must be a table")
	
	-- Default configuration
	local windowConfig = {
		Title = config.Title or "Angeryy05 Window",
		SubTitle = config.SubTitle or "Modern UI Library",
		Size = config.Size or UDim2.fromOffset(600, 400),
		MinSize = config.MinSize or Vector2.new(400, 300),
		Resizable = config.Resizable ~= false,
		Minimizable = config.Minimizable ~= false,
		Theme = config.Theme or Angeryy05.CurrentTheme,
		Icon = config.Icon,
		Position = config.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = config.AnchorPoint or Vector2.new(0.5, 0.5)
	}
	
	-- Create window
	local Window = require(Components.Window)(windowConfig, MainGui, Angeryy05)
	
	-- Update library state
	Angeryy05.WindowCount = Angeryy05.WindowCount + 1
	table.insert(Angeryy05.OpenWindows, Window)
	
	-- Set theme
	self:SetTheme(windowConfig.Theme)
	
	-- Fire event
	Angeryy05.WindowCreated:Fire(Window)
	
	return Window
end

-- Theme management
function Angeryy05:SetTheme(themeName)
	if table.find(self.Themes, themeName) then
		self.CurrentTheme = themeName
		ThemeManager.SetTheme(themeName)
		Creator.UpdateTheme()
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

-- Notification system
function Angeryy05:Notify(config)
	config = config or {}
	
	local notification = require(Components.Notification)(config, MainGui, Angeryy05)
	return notification
end

-- Destroy library
function Angeryy05:Destroy()
	if not self.Unloaded then
		self.Unloaded = true
		self.Loaded = false
		
		-- Fire unload event
		self.OnUnload:Fire()
		
		-- Disconnect all connections
		for _, connection in ipairs(self.Connections) do
			if connection.Connected then
				connection:Disconnect()
			end
		end
		
		-- Destroy all windows
		for _, window in ipairs(self.OpenWindows) do
			if window.Destroy then
				window:Destroy()
			end
		end
		
		-- Cleanup creator
		Creator.Disconnect()
		
		-- Destroy main GUI with animation
		Tween:Create(MainGui, 0.5, {
			BackgroundTransparency = 1
		}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		
		task.wait(0.5)
		MainGui:Destroy()
	end
end

-- Initialize theme
Angeryy05:SetTheme(Angeryy05.CurrentTheme)

return Angeryy05
