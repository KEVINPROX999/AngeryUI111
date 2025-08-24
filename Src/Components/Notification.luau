--[[
	Angeryy05 Notification Component
	Modern notification system with animations
]]

return function(config, parent, library)
	local Creator = library.Utilities.Creator
	local Tween = library.Utilities.Tween
	local Icons = library.Utilities.Icons
	local Themes = library.Utilities.Themes
	local Signal = library.Utilities.Signal
	
	-- Notification configuration
	config = config or {}
	local notificationConfig = {
		Title = config.Title or "Notification",
		Content = config.Content or "This is a notification",
		Duration = config.Duration or 5,
		Type = config.Type or "info", -- info, success, warning, error
		Icon = config.Icon,
		Position = config.Position or "TopRight"
	}
	
	-- Get theme
	local theme = Themes.GetTheme(library.CurrentTheme)
	
	-- Notification colors based on type
	local typeColors = {
		info = theme.Info,
		success = theme.Success,
		warning = theme.Warning,
		error = theme.Error
	}
	
	local typeIcons = {
		info = "info",
		success = "check",
		warning = "alert-triangle",
		error = "x"
	}
	
	-- Create notification container
	local NotificationContainer = Creator.New("Frame", {
		Name = "NotificationContainer",
		Size = UDim2.fromOffset(350, 80),
		Position = UDim2.new(1, -370, 0, 20),
		BackgroundColor3 = theme.Notification,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = parent
	})
	
	local NotificationCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 12),
		Parent = NotificationContainer
	})
	
	local NotificationBorder = Creator.New("UIStroke", {
		Color = theme.NotificationBorder,
		Thickness = 1,
		Parent = NotificationContainer
	})
	
	-- Accent bar
	local AccentBar = Creator.New("Frame", {
		Name = "AccentBar",
		Size = UDim2.new(0, 4, 1, 0),
		Position = UDim2.fromOffset(0, 0),
		BackgroundColor3 = typeColors[notificationConfig.Type],
		BorderSizePixel = 0,
		Parent = NotificationContainer
	})
	
	local AccentBarCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 2),
		Parent = AccentBar
	})
	
	-- Notification icon
	local NotificationIcon = Creator.New("ImageLabel", {
		Name = "NotificationIcon",
		Size = UDim2.fromOffset(24, 24),
		Position = UDim2.fromOffset(16, 16),
		BackgroundTransparency = 1,
		Image = Icons.Get(notificationConfig.Icon or typeIcons[notificationConfig.Type]),
		ImageColor3 = typeColors[notificationConfig.Type],
		Parent = NotificationContainer
	})
	
	-- Notification title
	local NotificationTitle = Creator.New("TextLabel", {
		Name = "NotificationTitle",
		Size = UDim2.new(1, -80, 0, 20),
		Position = UDim2.fromOffset(50, 12),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = notificationConfig.Title,
		TextColor3 = theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = NotificationContainer
	})
	
	-- Notification content
	local NotificationContent = Creator.New("TextLabel", {
		Name = "NotificationContent",
		Size = UDim2.new(1, -80, 0, 40),
		Position = UDim2.fromOffset(50, 32),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = notificationConfig.Content,
		TextColor3 = theme.TextSecondary,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Parent = NotificationContainer
	})
	
	-- Close button
	local CloseButton = Creator.New("TextButton", {
		Name = "CloseButton",
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(1, -30, 0, 10),
		BackgroundTransparency = 1,
		Text = "",
		Parent = NotificationContainer
	})
	
	local CloseIcon = Creator.New("ImageLabel", {
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = Icons.Get("x"),
		ImageColor3 = theme.TextMuted,
		Parent = CloseButton
	})
	
	-- Progress bar (if duration is set)
	local ProgressBar = nil
	if notificationConfig.Duration then
		ProgressBar = Creator.New("Frame", {
			Name = "ProgressBar",
			Size = UDim2.new(1, 0, 0, 2),
			Position = UDim2.new(0, 0, 1, -2),
			BackgroundColor3 = typeColors[notificationConfig.Type],
			BorderSizePixel = 0,
			Parent = NotificationContainer
		})
		
		local ProgressBarCorner = Creator.New("UICorner", {
			CornerRadius = UDim.new(0, 1),
			Parent = ProgressBar
		})
	end
	
	-- Notification object
	local Notification = {
		Title = notificationConfig.Title,
		Content = notificationConfig.Content,
		Duration = notificationConfig.Duration,
		Type = notificationConfig.Type,
		
		-- Events
		OnClose = Signal.new(),
		
		-- Internal
		Frame = NotificationContainer,
		Closed = false
	}
	
	-- Animation in
	NotificationContainer.Position = UDim2.new(1, 20, 0, 20)
	NotificationContainer.BackgroundTransparency = 1
	
	Tween:Spring(NotificationContainer, 0.5, {
		Position = UDim2.new(1, -370, 0, 20),
		BackgroundTransparency = 0
	})
	
	-- Progress bar animation
	if ProgressBar and notificationConfig.Duration then
		Tween:Create(ProgressBar, notificationConfig.Duration, {
			Size = UDim2.new(0, 0, 0, 2)
		}, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	end
	
	-- Auto close
	local autoCloseConnection = nil
	if notificationConfig.Duration then
		autoCloseConnection = task.delay(notificationConfig.Duration, function()
			Notification:Close()
		end)
	end
	
	-- Functions
	function Notification:Close()
		if not Notification.Closed then
			Notification.Closed = true
			
			-- Cancel auto close
			if autoCloseConnection then
				task.cancel(autoCloseConnection)
			end
			
			-- Animation out
			Tween:Smooth(NotificationContainer, 0.3, {
				Position = UDim2.new(1, 20, 0, 20),
				BackgroundTransparency = 1
			}, function()
				NotificationContainer:Destroy()
			end)
			
			Notification.OnClose:Fire()
		end
	end
	
	function Notification:SetTitle(title)
		Notification.Title = title
		NotificationTitle.Text = title
	end
	
	function Notification:SetContent(content)
		Notification.Content = content
		NotificationContent.Text = content
	end
	
	-- Close button handler
	CloseButton.MouseButton1Click:Connect(function()
		Notification:Close()
	end)
	
	-- Hover effects
	CloseButton.MouseEnter:Connect(function()
		Tween:Smooth(CloseIcon, 0.2, {
			ImageColor3 = theme.Text
		})
	end)
	
	CloseButton.MouseLeave:Connect(function()
		Tween:Smooth(CloseIcon, 0.2, {
			ImageColor3 = theme.TextMuted
		})
	end)
	
	return Notification
end
