--[[
	Angeryy05 Tab Component
	Modern tab system with smooth animations
]]

return function(config, tabListParent, contentParent, window, library)
	local Creator = library.Utilities.Creator
	local Tween = library.Utilities.Tween
	local Icons = library.Utilities.Icons
	local Themes = library.Utilities.Themes
	local Signal = library.Utilities.Signal
	
	-- Tab object
	local Tab = {
		Title = config.Title or "Tab",
		Icon = config.Icon,
		Active = false,
		
		-- Events
		OnActivate = Signal.new(),
		OnDeactivate = Signal.new(),
		
		-- Elements
		Elements = {},
		ElementCount = 0
	}
	
	-- Get theme
	local theme = Themes.GetTheme(library.CurrentTheme)
	
	-- Create tab button
	local TabButton = Creator.New("TextButton", {
		Name = "TabButton",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = theme.Tab,
		BorderSizePixel = 0,
		Text = "",
		Parent = tabListParent
	})
	
	local TabButtonCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = TabButton
	})
	
	-- Tab content frame
	local TabContent = Creator.New("Frame", {
		Name = "TabContent_" .. Tab.Title,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = contentParent
	})
	
	-- Tab scroll frame
	local TabScrollFrame = Creator.New("ScrollingFrame", {
		Name = "TabScrollFrame",
		Size = UDim2.new(1, -20, 1, -20),
		Position = UDim2.fromOffset(10, 10),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme.Accent,
		CanvasSize = UDim2.fromOffset(0, 0),
		Parent = TabContent
	})
	
	local TabScrollLayout = Creator.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = TabScrollFrame
	})
	
	-- Tab icon
	if Tab.Icon then
		local TabIcon = Creator.New("ImageLabel", {
			Name = "TabIcon",
			Size = UDim2.fromOffset(20, 20),
			Position = UDim2.fromOffset(12, 10),
			BackgroundTransparency = 1,
			Image = Icons.Get(Tab.Icon),
			ImageColor3 = theme.TabText,
			Parent = TabButton
		})
	end
	
	-- Tab title
	local TabTitle = Creator.New("TextLabel", {
		Name = "TabTitle",
		Size = UDim2.new(1, Tab.Icon and -40 or -20, 1, 0),
		Position = UDim2.fromOffset(Tab.Icon and 40 or 10, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = Tab.Title,
		TextColor3 = theme.TabText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TabButton
	})
	
	-- Tab activation indicator
	local TabIndicator = Creator.New("Frame", {
		Name = "TabIndicator",
		Size = UDim2.new(0, 3, 1, -8),
		Position = UDim2.fromOffset(-3, 4),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Parent = TabButton
	})
	
	local TabIndicatorCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = TabIndicator
	})
	
	-- Tab functions
	function Tab:Activate()
		if not Tab.Active then
			-- Deactivate other tabs
			for _, otherTab in ipairs(window.Tabs) do
				if otherTab ~= Tab and otherTab.Active then
					otherTab:Deactivate()
				end
			end
			
			Tab.Active = true
			window.CurrentTab = Tab
			
			-- Update visual state
			Tween:Smooth(TabButton, 0.2, {
				BackgroundColor3 = theme.TabActive
			})
			
			Tween:Smooth(TabTitle, 0.2, {
				TextColor3 = theme.TabTextActive
			})
			
			if TabButton:FindFirstChild("TabIcon") then
				Tween:Smooth(TabButton.TabIcon, 0.2, {
					ImageColor3 = theme.TabTextActive
				})
			end
			
			Tween:Smooth(TabIndicator, 0.2, {
				BackgroundTransparency = 0
			})
			
			-- Show content
			TabContent.Visible = true
			
			Tab.OnActivate:Fire()
		end
	end
	
	function Tab:Deactivate()
		if Tab.Active then
			Tab.Active = false
			
			-- Update visual state
			Tween:Smooth(TabButton, 0.2, {
				BackgroundColor3 = theme.Tab
			})
			
			Tween:Smooth(TabTitle, 0.2, {
				TextColor3 = theme.TabText
			})
			
			if TabButton:FindFirstChild("TabIcon") then
				Tween:Smooth(TabButton.TabIcon, 0.2, {
					ImageColor3 = theme.TabText
				})
			end
			
			Tween:Smooth(TabIndicator, 0.2, {
				BackgroundTransparency = 1
			})
			
			-- Hide content
			TabContent.Visible = false
			
			Tab.OnDeactivate:Fire()
		end
	end
	
	-- Add hover effects
	TabButton.MouseEnter:Connect(function()
		if not Tab.Active then
			Tween:Smooth(TabButton, 0.15, {
				BackgroundColor3 = theme.TabHover
			})
		end
	end)
	
	TabButton.MouseLeave:Connect(function()
		if not Tab.Active then
			Tween:Smooth(TabButton, 0.15, {
				BackgroundColor3 = theme.Tab
			})
		end
	end)
	
	-- Tab click handler
	TabButton.MouseButton1Click:Connect(function()
		Tab:Activate()
	end)
	
	-- Element creation functions
	function Tab:CreateButton(config)
		local Button = require(script.Parent.Parent.Elements.Button)(config, TabScrollFrame, Tab, library)
		
		Tab.ElementCount = Tab.ElementCount + 1
		table.insert(Tab.Elements, Button)
		
		-- Update canvas size
		TabScrollFrame.CanvasSize = UDim2.fromOffset(0, TabScrollLayout.AbsoluteContentSize.Y)
		
		return Button
	end
	
	function Tab:CreateToggle(config)
		local Toggle = require(script.Parent.Parent.Elements.Toggle)(config, TabScrollFrame, Tab, library)
		
		Tab.ElementCount = Tab.ElementCount + 1
		table.insert(Tab.Elements, Toggle)
		
		-- Update canvas size
		TabScrollFrame.CanvasSize = UDim2.fromOffset(0, TabScrollLayout.AbsoluteContentSize.Y)
		
		return Toggle
	end
	
	function Tab:CreateSlider(config)
		local Slider = require(script.Parent.Parent.Elements.Slider)(config, TabScrollFrame, Tab, library)
		
		Tab.ElementCount = Tab.ElementCount + 1
		table.insert(Tab.Elements, Slider)
		
		-- Update canvas size
		TabScrollFrame.CanvasSize = UDim2.fromOffset(0, TabScrollLayout.AbsoluteContentSize.Y)
		
		return Slider
	end
	
	function Tab:CreateDropdown(config)
		local Dropdown = require(script.Parent.Parent.Elements.Dropdown)(config, TabScrollFrame, Tab, library)
		
		Tab.ElementCount = Tab.ElementCount + 1
		table.insert(Tab.Elements, Dropdown)
		
		-- Update canvas size
		TabScrollFrame.CanvasSize = UDim2.fromOffset(0, TabScrollLayout.AbsoluteContentSize.Y)
		
		return Dropdown
	end
	
	function Tab:CreateInput(config)
		local Input = require(script.Parent.Parent.Elements.Input)(config, TabScrollFrame, Tab, library)
		
		Tab.ElementCount = Tab.ElementCount + 1
		table.insert(Tab.Elements, Input)
		
		-- Update canvas size
		TabScrollFrame.CanvasSize = UDim2.fromOffset(0, TabScrollLayout.AbsoluteContentSize.Y)
		
		return Input
	end
	
	function Tab:CreateParagraph(config)
		local Paragraph = require(script.Parent.Parent.Elements.Paragraph)(config, TabScrollFrame, Tab, library)
		
		Tab.ElementCount = Tab.ElementCount + 1
		table.insert(Tab.Elements, Paragraph)
		
		-- Update canvas size
		TabScrollFrame.CanvasSize = UDim2.fromOffset(0, TabScrollLayout.AbsoluteContentSize.Y)
		
		return Paragraph
	end
	
	-- Update canvas size when layout changes
	TabScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabScrollFrame.CanvasSize = UDim2.fromOffset(0, TabScrollLayout.AbsoluteContentSize.Y)
	end)
	
	-- Store references
	Tab.Button = TabButton
	Tab.Content = TabContent
	Tab.ScrollFrame = TabScrollFrame
	
	return Tab
end
