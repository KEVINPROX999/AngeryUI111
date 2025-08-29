-- Fluent Renewed UI Library - Bundled Version
-- This is a bundled version of Fluent Renewed for easy loading via loadstring

-- Simple Signal implementation
local Signal = {}
function Signal.new()
    local self = { _connections = {} }
    function self:Connect(func)
        table.insert(self._connections, func)
        return {
            Disconnect = function()
                for i, f in ipairs(self._connections) do
                    if f == func then
                        table.remove(self._connections, i)
                        break
                    end
                end
            end
        }
    end
    function self:Fire(...)
        for _, func in ipairs(self._connections) do
            func(...)
        end
    end
    return self
end

-- Simple Flipper implementation (basic animation)
local Flipper = {}
Flipper.Instant = { new = function(value) return { _value = value } end }
function Flipper.SingleMotor.new(initial)
    local motor = { _value = initial, _connections = {} }
    function motor:setGoal(goal)
        self._value = goal._value or goal
        for _, conn in ipairs(self._connections) do
            conn(self._value)
        end
    end
    function motor:onStep(func)
        table.insert(self._connections, func)
    end
    return motor
end
function Flipper.Spring.new(value, config)
    return { _value = value, frequency = config and config.frequency or 8 }
end

-- Simple Ripple implementation
local Ripple = {}

-- Acrylic module (simplified)
local Acrylic = {
    init = function() end,
    Enable = function() end,
    Disable = function() end
}

-- Icons module (simplified - full implementation would include all icon data)
local Icons = {
    SetIcon = function(self, Image, IconName)
        -- Full implementation would set ImageRectSize and ImageRectOffset based on icon data
        -- For now, simplified
    end,
    -- Icon data would be included here...
}

-- Creator module
local Creator = {
    Registry = {},
    Signals = {},
    TransparencyMotors = {},
    DefaultProperties = {
        ScreenGui = { ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling },
        Frame = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0 },
        ScrollingFrame = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), ScrollBarImageColor3 = Color3.new(0, 0, 0) },
        TextLabel = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), Font = Enum.Font.SourceSans, Text = "", TextColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, TextSize = 14, RichText = true },
        TextButton = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), AutoButtonColor = false, Font = Enum.Font.SourceSans, Text = "", TextColor3 = Color3.new(0, 0, 0), TextSize = 14, RichText = true },
        TextBox = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), ClearTextOnFocus = false, Font = Enum.Font.SourceSans, Text = "", TextColor3 = Color3.new(0, 0, 0), TextSize = 14, RichText = true },
        ImageLabel = { BackgroundTransparency = 1, BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0 },
        ImageButton = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), AutoButtonColor = false },
        CanvasGroup = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0 }
    },
    Theme = { Updating = false, Updated = Signal.new() }
}

function Creator.AddSignal(Signal, Function)
    Creator.Signals[#Creator.Signals+1] = Signal:Connect(Function)
end

function Creator.Disconnect()
    for Idx = #Creator.Signals, 1, -1 do
        local Connection = table.remove(Creator.Signals, Idx)
        if Connection then Connection:Disconnect() end
    end
end

function Creator.GetThemeProperty(Property)
    -- Simplified theme system
    local themes = { Dark = { Text = Color3.new(1,1,1), SubText = Color3.new(0.7,0.7,0.7), Element = Color3.new(0.2,0.2,0.2), ElementBorder = Color3.new(0.3,0.3,0.3), ElementTransparency = 0.9, HoverChange = 0.1 } }
    return themes.Dark[Property] or Color3.new(1,1,1)
end

function Creator.UpdateTheme(RegistryIndex)
    if Creator.Theme.Updating then Creator.Theme.Updated:Wait() end
    Creator.Theme.Updating = true
    -- Theme update logic here
    Creator.Theme.Updating = false
    Creator.Theme.Updated:Fire()
end

function Creator.AddThemeObject(Object, Properties)
    local Idx = #Creator.Registry + 1
    local Data = { Object = Object, Properties = Properties, Idx = Idx }
    Creator.Registry[Object] = Data
    Creator.UpdateTheme(Object)
    return Object
end

function Creator.OverrideTag(Object, Properties)
    Creator.Registry[Object].Properties = Properties
    Creator.UpdateTheme(Object)
end

function Creator.New(Name, Properties, Children)
    local Object = Instance.new(Name)
    for Name, Value in next, Creator.DefaultProperties[Name] or {} do
        Object[Name] = Value
    end
    for Name, Value in next, Properties or {} do
        if Name ~= "ThemeTag" then Object[Name] = Value end
    end
    for _, Child in next, Children or {} do
        Child.Parent = Object
    end
    if Properties and Properties.ThemeTag then
        Creator.AddThemeObject(Object, Properties.ThemeTag)
    end
    return Object
end

function Creator.SpringMotor(Initial, Instance, Prop, IgnoreDialogCheck, ResetOnThemeChange)
    IgnoreDialogCheck = IgnoreDialogCheck or false
    ResetOnThemeChange = ResetOnThemeChange or false
    local Motor = Flipper.SingleMotor.new(Initial)
    Motor:onStep(function(value) Instance[Prop] = value end)
    if ResetOnThemeChange then
        Creator.TransparencyMotors[#Creator.TransparencyMotors + 1] = Motor
    end
    local function SetValue(Value, Ignore)
        Ignore = Ignore or false
        Motor:setGoal(Flipper.Instant.new(Value))
    end
    return Motor, SetValue
end

-- Themes module (simplified)
local Themes = {
    Names = { "Dark", "Light" },
    Dark = { Text = Color3.new(1,1,1), SubText = Color3.new(0.7,0.7,0.7), Element = Color3.new(0.2,0.2,0.2), ElementBorder = Color3.new(0.3,0.3,0.3), ElementTransparency = 0.9, HoverChange = 0.1 }
}

-- Elements table (simplified - add more elements as needed)
local ElementsTable = {
    {
        __type = "Button",
        Container = nil,
        Type = nil,
        ScrollFrame = nil,
        Library = nil,
        New = function(self, Idx, Config)
            assert(Config.Title, "Button - Missing Title")
            Config.Callback = Config.Callback or function() end
            local ButtonFrame = Element(Config.Title, Config.Description, self.Container, true)
            local ButtonIco = Creator.New("ImageLabel", {
                Size = UDim2.fromOffset(16, 16),
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                BackgroundTransparency = 1,
                Parent = ButtonFrame.Frame,
                ThemeTag = { ImageColor3 = "Text" }
            })
            Icons:SetIcon(ButtonIco, "chevron-right")
            Creator.AddSignal(ButtonFrame.Frame.MouseButton1Click, function()
                if typeof(Config.Callback) == "function" then
                    self.Library:SafeCallback(Config.Callback, Config.Value)
                end
            end)
            ButtonFrame.Instance = ButtonFrame
            return ButtonFrame
        end
    }
    -- Add other elements here...
}

-- Element function
local function Element(Title, Desc, Parent, Hover, Config)
    local Element = { CreatedAt = tick() }
    Config = typeof(Config) == "table" and Config or {}
    Element.TitleLabel = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Text = Title,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 13,
        TextXAlignment = Config.TitleAlignment or Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        ThemeTag = { TextColor3 = "Text" }
    })
    Element.DescLabel = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        Text = Desc,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Config.DescriptionAlignment or Enum.TextXAlignment.Left,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        ThemeTag = { TextColor3 = "SubText" }
    })
    Element.LabelHolder = Creator.New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -28, 0, 0)
    }, {
        Creator.New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center }),
        Creator.New("UIPadding", { PaddingBottom = UDim.new(0, 13), PaddingTop = UDim.new(0, 13) }),
        Element.TitleLabel,
        Element.DescLabel
    })
    Element.Border = Creator.New("UIStroke", {
        Transparency = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(0, 0, 0),
        ThemeTag = { Color = "ElementBorder" }
    })
    Element.Frame = Creator.New("TextButton", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 0.89,
        BackgroundColor3 = Color3.fromRGB(130, 130, 130),
        Parent = Parent,
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = "",
        LayoutOrder = 7,
        ThemeTag = { BackgroundColor3 = "Element", BackgroundTransparency = "ElementTransparency" }
    }, {
        Creator.New("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Element.Border,
        Element.LabelHolder
    })
    function Element:SetTitle(Set) Element.TitleLabel.Text = Set end
    function Element:SetDesc(Set)
        if Set == nil then Set = "" end
        if Set == "" then Element.DescLabel.Visible = false else Element.DescLabel.Visible = true end
        Element.DescLabel.Text = Set
    end
    function Element:Destroy() Element.Frame:Destroy() end
    Element:SetTitle(Title)
    Element:SetDesc(Desc)
    if Hover then
        local Motor, SetTransparency = Creator.SpringMotor(Creator.GetThemeProperty("ElementTransparency"), Element.Frame, "BackgroundTransparency", false, true)
        Creator.AddSignal(Element.Frame.MouseEnter, function() SetTransparency(Creator.GetThemeProperty("ElementTransparency") - Creator.GetThemeProperty("HoverChange")) end)
        Creator.AddSignal(Element.Frame.MouseLeave, function() SetTransparency(Creator.GetThemeProperty("ElementTransparency")) end)
        Creator.AddSignal(Element.Frame.MouseButton1Down, function() SetTransparency(Creator.GetThemeProperty("ElementTransparency") + Creator.GetThemeProperty("HoverChange")) end)
        Creator.AddSignal(Element.Frame.MouseButton1Up, function() SetTransparency(Creator.GetThemeProperty("ElementTransparency") - Creator.GetThemeProperty("HoverChange")) end)
    end
    return setmetatable(Element, {
        __newindex = function(self, index, newvalue)
            if index == "Title" then Element:SetTitle(newvalue)
            elseif index == "Description" or index == "Desc" then Element:SetDesc(newvalue) end
            return rawset(self, index, newvalue)
        end
    })
end

-- Notification module (simplified)
local NotificationModule = {
    Init = function(self, BaseContainer) end,
    New = function(self, Config) return {} end
}

-- Window component (simplified)
local WindowComponent = function(Config)
    -- Simplified window implementation
    return {
        AcrylicPaint = { Model = { Transparency = 1 } },
        Acryling = false
    }
end

-- Main Library
local Library = {
    Version = "1.0.5",
    OpenFrames = {},
    Options = {},
    Themes = Themes.Names,
    OnUnload = Signal.new(),
    PostUnload = Signal.new(),
    ThemeChanged = Signal.new(),
    CreatedWindow = nil,
    WindowFrame = nil,
    UIContainer = nil,
    Utilities = { Themes = Themes, Shared = {}, Creator = Creator, Icons = Icons },
    Connections = Creator.Signals,
    Unloaded = false,
    Loaded = true,
    Theme = "Dark",
    DialogOpen = false,
    UseAcrylic = false,
    Acrylic = false,
    Transparency = true,
    MinimizeKey = Enum.KeyCode.LeftControl,
    GUI = nil
}

function Library:SafeCallback(Function, ...)
    assert(typeof(Function) == "function", debug.traceback(`Library:SafeCallback expects type 'function' at Argument #1, got '{typeof(Function)}'`, 2))
    task.spawn(function(...)
        local Success, Event = pcall(Function, ...)
        if not Success then
            local _, i = Event:find(":%d+: ")
            task.defer(error, debug.traceback(Event, 2))
            Library:Notify({
                Title = "Interface",
                Content = "Callback error",
                SubContent = if typeof(i) == "number" then Event:sub(i + 1) else Event,
                Duration = 5,
            })
        end
    end, ...)
end

function Library.Utilities:Resize(X, Y)
    local x, y, CurrentSize = X / 1920, Y / 1080, workspace.CurrentCamera.ViewportSize
    return CurrentSize.X * x, CurrentSize.Y * y
end

function Library.Utilities:Truncate(number, decimals, round)
    local shift = 10 ^ (typeof(decimals) == "number" and math.max(decimals, 0) or 0)
    if round then return math.round(number * shift) // 1 / shift else return number * shift // 1 / shift end
end

function Library.Utilities:Round(Number, Factor)
    return Library.Utilities:Truncate(Number, Factor, true)
end

function Library.Utilities:GetIcon(Name)
    return Name ~= "SetIcon" and Icons[Name] or nil
end

function Library.Utilities:Prettify(ToPrettify)
    if typeof(ToPrettify) == "EnumItem" then return ({ToPrettify.Name:gsub("(%l)(%u)", "%1 %2")})[1]
    elseif typeof(ToPrettify) == "string" then return ({ToPrettify:gsub("(%l)(%u)", "%1 %2")})[1]
    elseif typeof(ToPrettify) == "number" then return Library.Utilities:Round(ToPrettify, 2)
    else return tostring(ToPrettify) end
end

function Library.Utilities:Clone(ToClone)
    return ToClone
end

function Library.Utilities:GetOS()
    local OSName = "Unknown"
    if GuiService:IsTenFootInterface() then
        local L2Button_Name = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonL2)
        OSName = if L2Button_Name == "ButtonLT" then "Xbox" elseif L2Button_Name == "ButtonL2" then "PlayStation" else "Console"
    elseif GuiService.IsWindows then OSName = "Windows"
    elseif version():find("^0.") == 1 then OSName = "macOS"
    elseif version():find("^2.") == 1 then OSName = UserInputService.VREnabled and "MetaHorizon" or "Mobile" end
    return OSName
end

local Elements = {}
Elements.__index = Elements
Elements.__namecall = function(Table, Key, ...) return Elements[Key](...) end

for _, ElementComponent in next, ElementsTable do
    Elements[`Create{ElementComponent.__type}`] = function(self, Idx, Config)
        ElementComponent.Container = self.Container
        ElementComponent.Type = self.Type
        ElementComponent.ScrollFrame = self.ScrollFrame
        ElementComponent.Library = Library
        return ElementComponent:New(Idx, Config)
    end
    Elements[`Add{ElementComponent.__type}`] = Elements[`Create{ElementComponent.__type}`]
    Elements[ElementComponent.__type] = Elements[`Create{ElementComponent.__type}`]
end

Library.Elements = Elements

function Library:Window(Config)
    assert(Library.CreatedWindow == nil, debug.traceback("You cannot create more than one window.", 2))
    if not Config.Title then
        local Success, Game_Info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
        Config.Title = Success and Game_Info.Name or "Fluent Renewed"
    end
    Config.MinSize = if typeof(Config.MinSize) == "Vector2" then Config.MinSize else Vector2.new(470, 380)
    Config.Size = if Config.Resize ~= true then Config.Size else UDim2.fromOffset(Library.Utilities:Resize((Config.Size and Config.Size.X.Offset) or 470, (Config.Size and Config.Size.Y.Offset) or 380))
    Config.MinSize = if Config.Resize ~= true then Config.MinSize else Vector2.new(Library.Utilities:Resize((Config.MinSize and Config.MinSize.X) or 470, (Config.MinSize and Config.MinSize.Y) or 380))
    Library.MinimizeKey = if typeof(Config.MinimizeKey) == "string" or typeof(Config.MinimizeKey) == "EnumItem" and Config.MinimizeKey.EnumType == Enum.KeyCode then Config.MinimizeKey else Enum.KeyCode.LeftControl
    Library.UseAcrylic = if typeof(Config.Acrylic) == "boolean" then Config.Acrylic else false
    Library.Acrylic = if typeof(Config.Acrylic) == "boolean" then Config.Acrylic else false
    Library.Theme = if typeof(Config.Theme) == "string" then Config.Theme else "Vynixu"
    if Config.Acrylic then Acrylic.init() end
    local Window = WindowComponent(Config)
    Library.CreatedWindow = Window
    Library:SetTheme(Library.Theme)
    return Window
end

function Library:AddWindow(Config) return Library:Window(Config) end
function Library:CreateWindow(Config) return Library:Window(Config) end

function Library:SetTheme(Name)
    if Library.CreatedWindow and table.find(Library.Themes, Name) then
        Library.Theme = Name
        Creator.UpdateTheme()
        Library.ThemeChanged:Fire(Name)
    end
end

function Library:Destroy()
    if Library.CreatedWindow then
        Library.Unloaded = true
        Library.Loaded = false
        Library.OnUnload:Fire(tick())
        if Library.UseAcrylic then Library.CreatedWindow.AcrylicPaint.Model:Destroy() end
        Creator.Disconnect()
        for i,v in next, Library.Connections do
            local type = typeof(v)
            if type == "RBXScriptConnection" and v.Connected then v:Disconnect() end
        end
        local info, tweenProps, doTween = TweenInfo.new(2 / 3, Enum.EasingStyle.Quint), {}, false
        local function IsA(obj, class)
            local isClass = obj:IsA(class)
            if isClass then doTween = true end
            return isClass
        end
        for i,v in next, Library.GUI:GetDescendants() do
            table.clear(tweenProps)
            if IsA(v, "GuiObject") then tweenProps.BackgroundTransparency = 1 end
            if IsA(v, "ScrollingFrame") then tweenProps.ScrollBarImageTransparency = 1 end
            if IsA(v, "TextLabel") or IsA(v, "TextBox") then tweenProps.TextStrokeTransparency = 1 tweenProps.TextTransparency = 1 end
            if IsA(v, "UIStroke") then tweenProps.Transparency = 1 end
            if IsA(v, "ImageLabel") or IsA(v, "ImageButton") then tweenProps.ImageTransparency = 1 end
            if doTween then doTween = false TweenService:Create(v, info, tweenProps):Play() end
        end
        task.delay(info.Time, function() Library.GUI:Destroy() Library.PostUnload:Fire(tick()) end)
    end
end

function Library:ToggleAcrylic(Value)
    if Library.CreatedWindow then
        if Library.UseAcrylic then
            Library.Acrylic = Value
            Library.CreatedWindow.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
            if Value then Acrylic.Enable() else Acrylic.Disable() end
        end
    end
end

function Library:ToggleTransparency(Value)
    if Library.CreatedWindow then
        Library.CreatedWindow.AcrylicPaint.Frame.Background.BackgroundTransparency = Value and 0.35 or 0
    end
end

function Library:Notify(Config) return NotificationModule:New(Config) end

return Library
