--[[
	Angeryy05 Paragraph Element
	Simple text display element
]]

return function(config, parent, tab, library)
	local Creator = library.Utilities.Creator
	local Tween = library.Utilities.Tween
	local Themes = library.Utilities.Themes
	
	-- Paragraph configuration
	config = config or {}
	local paragraphConfig = {
		Title = config.Title,
		Content = config.Content or "Paragraph content",
		TitleAlignment = config.TitleAlignment or Enum.TextXAlignment.Left,
		ContentAlignment = config.ContentAlignment or Enum.TextXAlignment.Left
	}
	
	-- Get theme
	local theme = Themes.GetTheme(library.CurrentTheme)
	
	-- Calculate height based on content
	local titleHeight = paragraphConfig.Title and 25 or 0
	local contentLines = math.ceil(#paragraphConfig.Content / 50) -- Rough estimation
	local contentHeight = math.max(contentLines * 16, 20)
	local totalHeight = titleHeight + contentHeight + 20
	
	-- Create paragraph container
	local ParagraphContainer = Creator.New("Frame", {
		Name = "ParagraphContainer",
		Size = UDim2.new(1, -20, 0, totalHeight),
		BackgroundColor3 = theme.Element,
		BorderSizePixel = 0,
		Parent = parent
	})
	
	local ParagraphCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 10),
		Parent = ParagraphContainer
	})
	
	local ParagraphBorder = Creator.New("UIStroke", {
		Color = theme.ElementBorder,
		Thickness = 1,
		Transparency = 0.7,
		Parent = ParagraphContainer
	})
	
	-- Paragraph title (if provided)
	local ParagraphTitle = nil
	if paragraphConfig.Title then
		ParagraphTitle = Creator.New("TextLabel", {
			Name = "ParagraphTitle",
			Size = UDim2.new(1, -30, 0, 20),
			Position = UDim2.fromOffset(15, 10),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = paragraphConfig.Title,
			TextColor3 = theme.Text,
			TextSize = 14,
			TextXAlignment = paragraphConfig.TitleAlignment,
			TextYAlignment = Enum.TextYAlignment.Center,
			Parent = ParagraphContainer
		})
	end
	
	-- Paragraph content
	local ParagraphContent = Creator.New("TextLabel", {
		Name = "ParagraphContent",
		Size = UDim2.new(1, -30, 0, contentHeight),
		Position = UDim2.fromOffset(15, titleHeight + 10),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = paragraphConfig.Content,
		TextColor3 = theme.TextSecondary,
		TextSize = 13,
		TextXAlignment = paragraphConfig.ContentAlignment,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Parent = ParagraphContainer
	})
	
	-- Paragraph object
	local Paragraph = {
		Title = paragraphConfig.Title,
		Content = paragraphConfig.Content,
		
		-- Internal
		Frame = ParagraphContainer,
		TitleLabel = ParagraphTitle,
		ContentLabel = ParagraphContent
	}
	
	-- Functions
	function Paragraph:SetTitle(title)
		Paragraph.Title = title
		if ParagraphTitle then
			ParagraphTitle.Text = title
		end
	end
	
	function Paragraph:SetContent(content)
		Paragraph.Content = content
		ParagraphContent.Text = content
		
		-- Recalculate height
		local newContentLines = math.ceil(#content / 50)
		local newContentHeight = math.max(newContentLines * 16, 20)
		local newTotalHeight = (Paragraph.Title and 25 or 0) + newContentHeight + 20
		
		-- Animate size change
		Tween:Smooth(ParagraphContainer, 0.3, {
			Size = UDim2.new(1, -20, 0, newTotalHeight)
		})
		
		Tween:Smooth(ParagraphContent, 0.3, {
			Size = UDim2.new(1, -30, 0, newContentHeight)
		})
	end
	
	function Paragraph:SetTitleAlignment(alignment)
		if ParagraphTitle then
			ParagraphTitle.TextXAlignment = alignment
		end
	end
	
	function Paragraph:SetContentAlignment(alignment)
		ParagraphContent.TextXAlignment = alignment
	end
	
	-- Hover effect
	ParagraphContainer.MouseEnter:Connect(function()
		Tween:Smooth(ParagraphContainer, 0.15, {
			BackgroundColor3 = theme.ElementHover
		})
		Tween:Smooth(ParagraphBorder, 0.15, {
			Transparency = 0.4
		})
	end)
	
	ParagraphContainer.MouseLeave:Connect(function()
		Tween:Smooth(ParagraphContainer, 0.15, {
			BackgroundColor3 = theme.Element
		})
		Tween:Smooth(ParagraphBorder, 0.15, {
			Transparency = 0.7
		})
	end)
	
	return Paragraph
end
