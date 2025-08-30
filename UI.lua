-- Fluent Renewed UI Library - Single File Bundle
-- Original: https://github.com/ActualMasterOogway/Fluent-Renewed
-- Bundled for loadstring usage

--[[
    Sử dụng:
    local Library = loadstring(game:HttpGet("URL_TO_THIS_FILE"))()
    
    local Window = Library:Window{
        Title = "My Script",
        SubTitle = "Version 1.0",
        Theme = "Dark"
    }
]]

-- === DEPENDENCIES IMPLEMENTATION ===

-- Signal Implementation (Minimal)
local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({}, Signal)
    self._connections = {}
    return self
end

function Signal:Connect(callback)
    local connection = {
        Connected = true,
        _callback = callback,
        _signal = self
    }
    
    function connection:Disconnect()
        if self.Connected then
            self.Connected = false
            local index = table.find(self._signal._connections, self)
            if index then
                table.remove(self._signal._connections, index)
            end
        end
    end
    
    table.insert(self._connections, connection)
    return connection
end

function Signal:Fire(...)
    for _, connection in pairs(self._connections) do
        if connection.Connected then
            task.spawn(connection._callback, ...)
        end
    end
end

function Signal:Wait()
    local thread = coroutine.running()
    local connection
    connection = self:Connect(function(...)
        connection:Disconnect()
        task.spawn(thread, ...)
    end)
    return coroutine.yield()
end

-- Flipper Implementation (Minimal)
local Flipper = {}

Flipper.Spring = {}
Flipper.Spring.__index = Flipper.Spring

function Flipper.Spring.new(value, options)
    options = options or {}
    return {
        frequency = options.frequency or 4,
        dampingRatio = options.dampingRatio or 1,
        _value = value
    }
end

Flipper.Instant = {}
Flipper.Instant.__index = Flipper.Instant

function Flipper.Instant.new(value)
    return { _value = value }
end

Flipper.SingleMotor = {}
Flipper.SingleMotor.__index = Flipper.SingleMotor

function Flipper.SingleMotor.new(initialValue)
    local self = setmetatable({}, Flipper.SingleMotor)
    self._value = initialValue
    self._targetValue = initialValue
    self._onStep = function() end
    return self
end

function Flipper.SingleMotor:onStep(callback)
    self._onStep = callback
end

function Flipper.SingleMotor:setGoal(goal)
    self._targetValue = goal._value
    -- Simple tween to target value
    local TweenService = game:GetService("TweenService")
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local proxy = { value = self._value }
    
    local tween = TweenService:Create(proxy, info, { value = self._targetValue })
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        self._value = proxy.value
        self._onStep(self._value)
    end)
    
    tween.Completed:Connect(function()
        connection:Disconnect()
    end)
    
    tween:Play()
end

-- Ripple Implementation (Minimal)
local Ripple = {}
function Ripple.new() return {} end

-- === THEMES ===
local Themes = {
    Names = {
        "Vynixu", "Dark", "Darker", "Light", "Aqua", "Rose"
    }
}

-- Default Dark Theme
Themes["Dark"] = {
    Accent = Color3.fromRGB(96, 205, 255),
    AcrylicMain = Color3.fromRGB(60, 60, 60),
    AcrylicBorder = Color3.fromRGB(90, 90, 90),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(40, 40, 40), Color3.fromRGB(40, 40, 40)),
    AcrylicNoise = 0.9,
    TitleBarLine = Color3.fromRGB(75, 75, 75),
    Tab = Color3.fromRGB(120, 120, 120),
    Element = Color3.fromRGB(120, 120, 120),
    ElementBorder = Color3.fromRGB(35, 35, 35),
    InElementBorder = Color3.fromRGB(90, 90, 90),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(120, 120, 120),
    ToggleToggled = Color3.fromRGB(0, 0, 0),
    SliderRail = Color3.fromRGB(120, 120, 120),
    DropdownFrame = Color3.fromRGB(160, 160, 160),
    DropdownHolder = Color3.fromRGB(45, 45, 45),
    DropdownBorder = Color3.fromRGB(35, 35, 35),
    DropdownOption = Color3.fromRGB(120, 120, 120),
    Keybind = Color3.fromRGB(120, 120, 120),
    Input = Color3.fromRGB(160, 160, 160),
    InputFocused = Color3.fromRGB(10, 10, 10),
    InputIndicator = Color3.fromRGB(150, 150, 150),
    Dialog = Color3.fromRGB(45, 45, 45),
    DialogHolder = Color3.fromRGB(35, 35, 35),
    DialogHolderLine = Color3.fromRGB(30, 30, 30),
    DialogButton = Color3.fromRGB(45, 45, 45),
    DialogButtonBorder = Color3.fromRGB(80, 80, 80),
    DialogBorder = Color3.fromRGB(70, 70, 70),
    DialogInput = Color3.fromRGB(55, 55, 55),
    DialogInputLine = Color3.fromRGB(160, 160, 160),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(170, 170, 170),
    Hover = Color3.fromRGB(120, 120, 120),
    HoverChange = 0.07
}

-- Vynixu Theme
Themes["Vynixu"] = {
    Accent = Color3.fromRGB(90, 235, 45),
    AcrylicMain = Color3.fromRGB(30, 30, 30),
    AcrylicBorder = Color3.fromRGB(60, 60, 60),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(25, 25, 25), Color3.fromRGB(15, 15, 15)),
    AcrylicNoise = 0.94,
    TitleBarLine = Color3.fromRGB(65, 65, 65),
    Tab = Color3.fromRGB(100, 100, 100),
    Element = Color3.fromRGB(70, 70, 70),
    ElementBorder = Color3.fromRGB(25, 25, 25),
    InElementBorder = Color3.fromRGB(55, 55, 55),
    ElementTransparency = 0.82,
    DropdownFrame = Color3.fromRGB(120, 120, 120),
    DropdownHolder = Color3.fromRGB(35, 35, 35),
    DropdownBorder = Color3.fromRGB(25, 25, 25),
    Dialog = Color3.fromRGB(35, 35, 35),
    DialogHolder = Color3.fromRGB(25, 25, 25),
    DialogHolderLine = Color3.fromRGB(20, 20, 20),
    DialogButton = Color3.fromRGB(35, 35, 35),
    DialogButtonBorder = Color3.fromRGB(55, 55, 55),
    DialogBorder = Color3.fromRGB(50, 50, 50),
    DialogInput = Color3.fromRGB(45, 45, 45),
    DialogInputLine = Color3.fromRGB(120, 120, 120)
}

-- Copy missing properties from Dark theme for other themes
for themeName, themeData in pairs(Themes) do
    if themeName ~= "Names" and themeName ~= "Dark" then
        for prop, value in pairs(Themes["Dark"]) do
            if themeData[prop] == nil then
                themeData[prop] = value
            end
        end
    end
end

-- Light Theme
Themes["Light"] = {
    Accent = Color3.fromRGB(0, 122, 255),
    AcrylicMain = Color3.fromRGB(245, 245, 245),
    AcrylicBorder = Color3.fromRGB(220, 220, 220),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(245, 245, 245)),
    AcrylicNoise = 0.1,
    TitleBarLine = Color3.fromRGB(200, 200, 200),
    Tab = Color3.fromRGB(150, 150, 150),
    Element = Color3.fromRGB(235, 235, 235),
    ElementBorder = Color3.fromRGB(220, 220, 220),
    InElementBorder = Color3.fromRGB(200, 200, 200),
    ElementTransparency = 0.1,
    Text = Color3.fromRGB(50, 50, 50),
    SubText = Color3.fromRGB(120, 120, 120),
    Hover = Color3.fromRGB(225, 225, 225),
    HoverChange = -0.05
}

-- === ICONS (Minimal Set) ===
local Icons = {
    SetIcon = function(self, Image, IconName)
        -- Basic icons for common use
        local iconData = {
            ["chevron-right"] = {
                Image = "rbxassetid://9886659671",
                ImageRectSize = Vector2.new(16, 16),
                ImageRectOffset = Vector2.new(0, 0)
            },
            ["chevron-down"] = {
                Image = "rbxassetid://9886659276", 
                ImageRectSize = Vector2.new(16, 16),
                ImageRectOffset = Vector2.new(0, 0)
            },
            ["settings"] = {
                Image = "rbxassetid://9886659406",
                ImageRectSize = Vector2.new(16, 16), 
                ImageRectOffset = Vector2.new(0, 0)
            },
            ["phosphor-eye"] = {
                Image = "rbxassetid://9886659001",
                ImageRectSize = Vector2.new(16, 16),
                ImageRectOffset = Vector2.new(0, 0)
            },
            ["phosphor-eye-slash"] = {
                Image = "rbxassetid://9886659001",
                ImageRectSize = Vector2.new(16, 16),
                ImageRectOffset = Vector2.new(16, 0)
            },
            ["phosphor-users-bold"] = {
                Image = "rbxassetid://9886659001",
                ImageRectSize = Vector2.new(16, 16),
                ImageRectOffset = Vector2.new(32, 0)
            }
        }
        
        local data = iconData[IconName] or iconData["chevron-right"]
        Image.Image = data.Image
        Image.ImageRectSize = data.ImageRectSize
        Image.ImageRectOffset = data.ImageRectOffset
    end
}

-- === UTILITIES ===
local function Clone(ToClone)
    local Type = typeof(ToClone)
    if Type == "function" and (clonefunc or clonefunction) then
        return (clonefunc or clonefunction)(ToClone), true
    elseif Type == "Instance" and (cloneref or clonereference) then
        return (cloneref or clonereference)(ToClone), true
    elseif Type == "table" then
        local function deepcopy(orig, copies)
            local Copies = copies or {}
            local orig_type, copy = typeof(orig), nil
            if orig_type == 'table' then
                if Copies[orig] then
                    copy = Copies[orig]
                else    
                    copy = {}
                    Copies[orig] = copy
                    for orig_key, orig_value in next, orig, nil do
                        copy[deepcopy(orig_key, Copies)] = deepcopy(orig_value, Copies)
                    end
                    (setrawmetatable or setmetatable)(copy, deepcopy((getrawmetatable or getmetatable)(orig), Copies))
                end
            elseif orig_type == 'Instance' or orig_type == 'function' then
                copy = Clone(orig)
            else
                copy = orig
            end
            return copy
        end
        return deepcopy(ToClone), true
    else
        return ToClone, false
    end
end

-- === SERVICES ===
local MarketplaceService = Clone(game:GetService("MarketplaceService"))
local TweenService = Clone(game:GetService("TweenService"))
local Camera = Clone(game:GetService("Workspace")).CurrentCamera
local UserInputService = Clone(game:GetService("UserInputService"))
local GuiService = Clone(game:GetService("GuiService"))
local RunService = Clone(game:GetService("RunService"))

-- === CREATOR MODULE ===
local Creator = {
    Registry = {},
    Signals = {},
    TransparencyMotors = {},
    DefaultProperties = {
        ScreenGui = {
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        },
        Frame = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
        },
        ScrollingFrame = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            ScrollBarImageColor3 = Color3.new(0, 0, 0),
        },
        TextLabel = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            Font = Enum.Font.SourceSans,
            Text = "",
            TextColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            TextSize = 14,
            RichText = true,
        },
        TextButton = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            AutoButtonColor = false,
            Font = Enum.Font.SourceSans,
            Text = "",
            TextColor3 = Color3.new(0, 0, 0),
            TextSize = 14,
            RichText = true,
        },
        TextBox = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            ClearTextOnFocus = false,
            Font = Enum.Font.SourceSans,
            Text = "",
            TextColor3 = Color3.new(0, 0, 0),
            TextSize = 14,
            RichText = true,
        },
        ImageLabel = {
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
        },
        ImageButton = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            AutoButtonColor = false,
        },
        CanvasGroup = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
        }
    },
    Theme = {
        Updating = false,
        Updated = Signal.new()
    }
}

local currentTheme = "Dark"

function Creator.AddSignal(RBXSignal, Function)
    Creator.Signals[#Creator.Signals+1] = RBXSignal:Connect(Function)
end

function Creator.Disconnect()
    for Idx = #Creator.Signals, 1, -1 do
        local Connection = table.remove(Creator.Signals, Idx)
        if Connection then
            Connection:Disconnect()
        end
    end
end

function Creator.GetThemeProperty(Property)
    if Themes[currentTheme][Property] then
        return Themes[currentTheme][Property]
    end
    return Themes["Dark"][Property]
end

function Creator.UpdateTheme(RegistryIndex)
    if Creator.Theme.Updating then
        Creator.Theme.Updated:Wait()
    end

    Creator.Theme.Updating = true

    local Count = 0

    if typeof(RegistryIndex) == "Instance" and Creator.Registry[RegistryIndex] then
        for Property, ColorIdx in next, Creator.Registry[RegistryIndex].Properties do
            Count += 1
            if Count % 135 == 0 then
                task.wait()
            end
            RegistryIndex[Property] = Creator.GetThemeProperty(ColorIdx)
        end
    else
        for _, Object in next, Creator.Registry do
            Count += 1
            if Count % 135 == 0 then
                task.wait()
            end
            for Property, ColorIdx in next, Object.Properties do
                Count += 1
                if Count % 135 == 0 then
                    task.wait()
                end
                Object.Object[Property] = Creator.GetThemeProperty(ColorIdx)
            end
        end
    end    

    for Idx, Motor in next, Creator.TransparencyMotors do
        if Idx % 135 == 0 then
            task.wait()
        end
        Motor:setGoal(Flipper.Instant.new(Creator.GetThemeProperty("ElementTransparency")))
    end

    Creator.Theme.Updating = false
    Creator.Theme.Updated:Fire()
end

function Creator.AddThemeObject(Object, Properties)
    local Idx = #Creator.Registry + 1
    local Data = {
        Object = Object,
        Properties = Properties,
        Idx = Idx,
    }

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

    -- Default properties
    for Name, Value in next, Creator.DefaultProperties[Name] or {} do
        Object[Name] = Value
    end

    -- Properties
    for Name, Value in next, Properties or {} do
        if Name ~= "ThemeTag" then
            Object[Name] = Value
        end
    end

    -- Children
    for _, Child in next, Children or {} do
        Child.Parent = Object
    end

    -- Apply theme
    if typeof(Properties) == "table" and Properties.ThemeTag then
        Creator.AddThemeObject(Object, Properties.ThemeTag)
    end

    return Object
end

function Creator.SpringMotor(Initial, Instance, Prop, IgnoreDialogCheck, ResetOnThemeChange)
    IgnoreDialogCheck = IgnoreDialogCheck or false
    ResetOnThemeChange = ResetOnThemeChange or false
    local Motor = Flipper.SingleMotor.new(Initial)
    Motor:onStep(function(value)
        Instance[Prop] = value
    end)

    if ResetOnThemeChange then
        Creator.TransparencyMotors[#Creator.TransparencyMotors + 1] = Motor
    end

    local function SetValue(Value, Ignore)
        Ignore = Ignore or false
        if not IgnoreDialogCheck then
            if not Ignore then
                if Prop == "BackgroundTransparency" and Library and Library.DialogOpen then
                    return
                end
            end
        end
        Motor:setGoal(Flipper.Spring.new(Value, { frequency = 8 }))
    end

    return Motor, SetValue
end

-- === ACRYLIC MODULE ===
local Acrylic = {
    AcrylicBlur = {},
    CreateAcrylic = {},
    AcrylicPaint = function()
        return {
            Model = Creator.New("Frame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Transparency = 1
            }),
            Frame = {
                Background = Creator.New("Frame", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 0.35
                })
            }
        }
    end,
}

function Acrylic.init()
    local baseEffect = Instance.new("DepthOfFieldEffect")
    baseEffect.FarIntensity = 0
    baseEffect.InFocusRadius = 0.1
    baseEffect.NearIntensity = 1

    local depthOfFieldDefaults = {}

    function Acrylic.Enable()
        for _, effect in next, depthOfFieldDefaults do
            effect.Enabled = false
        end
        baseEffect.Parent = game:GetService("Lighting")
    end

    function Acrylic.Disable()
        for _, effect in next, depthOfFieldDefaults do
            effect.Enabled = effect.enabled
        end
        baseEffect.Parent = nil
    end

    local function registerDefaults()
        local function register(object)
            if object:IsA("DepthOfFieldEffect") then
                depthOfFieldDefaults[object] = { enabled = object.Enabled }
            end
        end

        for _, child in next, game:GetService("Lighting"):GetChildren() do
            register(child)
        end

        if game:GetService("Workspace").CurrentCamera then
            for _, child in next, game:GetService("Workspace").CurrentCamera:GetChildren() do
                register(child)
            end
        end
    end

    registerDefaults()
    Acrylic.Enable()
end

-- === BASE CONTAINER ===
local New = Creator.New

local BaseContainer = New("ScreenGui", {
    Name = "Fluent Renewed Base GUI"
})

BaseContainer.Parent = (function()
    local success, result = pcall(function()
        return (gethui or get_hidden_ui)()
    end)

    if success and result then
        return result
    end

    success, result = pcall(function()
        local CoreGui = game:GetService("CoreGui")
        CoreGui:GetFullName()
        return CoreGui
    end)

    if success and result then
        return result
    end

    success, result = pcall(function()
        return (game:IsLoaded() or game.Loaded:Wait() or true) and game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 10)
    end)

    if success and result then
        return result
    end

    success, result = pcall(function()
        local StarterGui = game:GetService("StarterGui")
        StarterGui:GetFullName()
        return StarterGui
    end)

    if success and result then
        return result
    end

    return error("Seriously bad engine. Can't find a place to store the GUI. Robust code can't help this much incompetence.", 0)
end)()

-- === SHARED TABLE ===
local SharedTable = shared or _G or (getgenv and getgenv()) or getfenv(1)
SharedTable.FluentRenewed = SharedTable.FluentRenewed or {}

-- === NOTIFICATION MODULE ===
local Notification = {}

function Notification:Init(GUI)
    Notification.Holder = New("Frame", {
        Position = UDim2.new(1, -30, 1, -30),
        Size = UDim2.new(0, 310, 1, -30),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Parent = GUI,
    }, {
        New("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 20),
        }),
    })
end

function Notification:New(Config)
    local NewNotification = {
        Closed = false,
    }

    Config.Title = Config.Title or "Title"
    Config.Content = Config.Content or "Content"
    Config.SubContent = Config.SubContent or ""
    Config.Duration = Config.Duration or nil

    NewNotification.Frame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Parent = Notification.Holder,
        ThemeTag = {
            BackgroundColor3 = "Dialog"
        }
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 8)
        }),
        New("UIStroke", {
            Transparency = 0.5,
            ThemeTag = {
                Color = "DialogBorder"
            }
        }),
        New("TextLabel", {
            Position = UDim2.new(0, 14, 0, 17),
            Size = UDim2.new(1, -28, 0, 20),
            Text = Config.Title,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextSize = 14,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            ThemeTag = {
                TextColor3 = "Text"
            }
        }),
        New("TextLabel", {
            Position = UDim2.new(0, 14, 0, 40),
            Size = UDim2.new(1, -28, 0, 26),
            Text = Config.Content,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 12,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            TextWrapped = true,
            ThemeTag = {
                TextColor3 = "SubText"
            }
        })
    })

    if Config.Duration then
        task.wait(Config.Duration)
        if NewNotification.Frame then
            NewNotification.Frame:Destroy()
        end
    end

    return NewNotification
end

Notification:Init(BaseContainer)

-- === ELEMENT COMPONENT ===
local function CreateElement(Title, Desc, Parent, Hover, Config)
    local Element = {
        CreatedAt = tick()
    }

    Config = typeof(Config) == "table" and Config or {}

    Element.TitleLabel = New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Text = Title,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 13,
        TextXAlignment = Config.TitleAlignment or Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        ThemeTag = {
            TextColor3 = "Text",
        },
    })

    Element.DescLabel = New("TextLabel", {
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
        ThemeTag = {
            TextColor3 = "SubText",
        },
    })

    Element.LabelHolder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -28, 0, 0),
    }, {
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
        }),
        Element.TitleLabel,
        Element.DescLabel,
    })

    local ElementBorder = New("UIStroke", {
        Color = Color3.fromRGB(70, 70, 70),
        Transparency = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        ThemeTag = {
            Color = "ElementBorder",
        },
    })

    Element.Frame = New("TextButton", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Text = "",
        ThemeTag = {
            BackgroundColor3 = "Element",
        },
        Parent = Parent,
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
        ElementBorder,
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
        }),
        Element.LabelHolder
    })

    local ElementMotor, ElementTransparency = Creator.SpringMotor(Creator.GetThemeProperty("ElementTransparency"), Element.Frame, "BackgroundTransparency", false, true)

    function Element:SetTitle(NewTitle)
        Element.TitleLabel.Text = NewTitle
    end

    function Element:SetDesc(NewDesc)
        Element.DescLabel.Text = NewDesc
    end

    function Element:Destroy()
        Element.Frame:Destroy()
    end

    if Hover then
        Creator.AddSignal(Element.Frame.MouseEnter, function()
            ElementTransparency(Creator.GetThemeProperty("ElementTransparency") - Creator.GetThemeProperty("HoverChange"))
        end)

        Creator.AddSignal(Element.Frame.MouseLeave, function()
            ElementTransparency(Creator.GetThemeProperty("ElementTransparency"))
        end)
    end

    return Element
end

-- === MAIN LIBRARY ===
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
    UIContainer = BaseContainer.Parent,
    Utilities = {
        Themes = Themes,
        Shared = SharedTable,
        Creator = Creator,
        Icons = Icons
    },
    Connections = Creator.Signals,
    Unloaded = false,
    Loaded = true,

    Theme = "Dark",
    DialogOpen = false,
    UseAcrylic = false,
    Acrylic = false,
    Transparency = true,
    MinimizeKey = Enum.KeyCode.LeftControl,

    GUI = BaseContainer
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
    local x, y, CurrentSize = X / 1920, Y / 1080, Camera.ViewportSize
    return CurrentSize.X * x, CurrentSize.Y * y
end

function Library.Utilities:Truncate(number, decimals, round)
    local shift = 10 ^ (typeof(decimals) == "number" and math.max(decimals, 0) or 0)

    if round then
        return math.round(number * shift) // 1 / shift
    else
        return number * shift // 1 / shift
    end
end

function Library.Utilities:Round(Number, Factor)
    return Library.Utilities:Truncate(Number, Factor, true)
end

function Library.Utilities:GetIcon(Name)
    return Name ~= "SetIcon" and Icons[Name] or nil
end

function Library.Utilities:Prettify(ToPrettify)
    if typeof(ToPrettify) == "EnumItem" then
        return ({ToPrettify.Name:gsub("(%l)(%u)", "%1 %2")})[1]
    elseif typeof(ToPrettify) == "string" then
        return ({ToPrettify:gsub("(%l)(%u)", "%1 %2")})[1]
    elseif typeof(ToPrettify) == "number" then
        return Library.Utilities:Round(ToPrettify, 2)
    else
        return tostring(ToPrettify)
    end
end

function Library.Utilities:Clone(ToClone)
    return Clone(ToClone)
end

function Library.Utilities:GetOS()
    local OSName = "Unknown"
    
    if GuiService:IsTenFootInterface() then
        local L2Button_Name = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonL2)
        OSName = if L2Button_Name == "ButtonLT" then "Xbox" elseif L2Button_Name == "ButtonL2" then "PlayStation" else "Console"
    elseif GuiService.IsWindows then
        OSName = "Windows"
    elseif version():find("^0.") == 1 then
        OSName = "macOS"
    elseif version():find("^2.") == 1 then
        OSName = UserInputService.VREnabled and "MetaHorizon" or "Mobile"
    end

    return OSName
end

-- === ELEMENTS ===
local Elements = {}
Elements.__index = Elements

-- Button Element
local ButtonElement = {}
ButtonElement.__index = ButtonElement
ButtonElement.__type = "Button"

function ButtonElement:New(Config)
    assert(Config.Title, "Button - Missing Title")
    Config.Callback = Config.Callback or function() end

    local ButtonFrame = CreateElement(Config.Title, Config.Description, self.Container, true)

    local ButtonIco = New("ImageLabel", {
        Size = UDim2.fromOffset(16, 16),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        BackgroundTransparency = 1,
        Parent = ButtonFrame.Frame,
        ThemeTag = {
            ImageColor3 = "Text",
        }
    })

    Icons:SetIcon(ButtonIco, "chevron-right")

    Creator.AddSignal(ButtonFrame.Frame.MouseButton1Click, function()
        if typeof(Config.Callback) == "function" then
            Library:SafeCallback(Config.Callback, Config.Value)
        end
    end)

    ButtonFrame.Instance = ButtonFrame

    return ButtonFrame
end

-- Toggle Element
local ToggleElement = {}
ToggleElement.__index = ToggleElement
ToggleElement.__type = "Toggle"

function ToggleElement:New(Idx, Config)
    assert(Config.Title, "Toggle - Missing Title")

    local Toggle = {
        Value = Config.Default or Config.Value or false,
        Callback = Config.Callback or function(Value) end,
        Type = "Toggle",
    }

    local ToggleFrame = CreateElement(Config.Title, Config.Description, self.Container, true)
    ToggleFrame.DescLabel.Size = UDim2.new(1, -54, 0, 14)

    Toggle.SetTitle = ToggleFrame.SetTitle
    Toggle.SetDesc = ToggleFrame.SetDesc

    local ToggleCircle = New("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, 2, 0.5, 0),
        Image = "http://www.roblox.com/asset/?id=12266946128",
        ImageTransparency = 0.5,
        ThemeTag = {
            ImageColor3 = "ToggleSlider",
        },
    })

    local ToggleBorder = New("UIStroke", {
        Transparency = 0.5,
        ThemeTag = {
            Color = "ToggleSlider",
        },
    })

    local ToggleSlider = New("Frame", {
        Size = UDim2.fromOffset(36, 18),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Parent = ToggleFrame.Frame,
        BackgroundTransparency = 1,
        ThemeTag = {
            BackgroundColor3 = "Accent",
        },
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 9),
        }),
        ToggleBorder,
        ToggleCircle,
    })

    function Toggle:OnChanged(Func)
        Toggle.Changed = Func
        Library:SafeCallback(Func, Toggle.Value, Toggle.Value)
    end

    function Toggle:SetValue(Value)
        Value = not not Value

        rawset(Toggle, "Value", Value)

        Creator.OverrideTag(ToggleBorder, { Color = Toggle.Value and "Accent" or "ToggleSlider" })
        Creator.OverrideTag(ToggleCircle, { ImageColor3 = Toggle.Value and "ToggleToggled" or "ToggleSlider" })

        ToggleCircle:TweenPosition(
            UDim2.new(0, Toggle.Value and 19 or 2, 0.5, 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quint,
            .25,
            true
        )

        TweenService:Create(
            ToggleSlider,
            TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { BackgroundTransparency = Toggle.Value and 0 or 1 }
        ):Play()

        ToggleCircle.ImageTransparency = Toggle.Value and 0 or 0.5

        if typeof(Toggle.Callback) == "function" then
            Library:SafeCallback(Toggle.Callback, Toggle.Value)
        end
        if typeof(Toggle.Changed) == "function" then
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end
    end

    function Toggle:Destroy()
        ToggleFrame:Destroy()
        Library.Options[Idx] = nil
    end

    Creator.AddSignal(ToggleFrame.Frame.MouseButton1Click, function()
        Toggle:SetValue(not Toggle.Value)
    end)

    Toggle:SetValue(Toggle.Value)

    Library.Options[Idx] = Toggle
    Toggle.Instance = ToggleFrame

    return setmetatable(Toggle, {
        __newindex = function(self, index, newvalue)
            if index == "Value" then
                task.spawn(Toggle.SetValue, Toggle, newvalue)
            end
            rawset(self, index, newvalue)
        end
    })
end

-- Slider Element
local SliderElement = {}
SliderElement.__index = SliderElement
SliderElement.__type = "Slider"

function SliderElement:New(Idx, Config)
    assert(Config.Max, "Slider - Missing maximum value.")

    local Slider = {
        Value = nil,
        Min = typeof(Config.Min) == "number" and Config.Min or 0,
        Max = Config.Max,
        Rounding = typeof(Config.Rounding) == "number" and Config.Rounding or 0,
        Callback = typeof(Config.Callback) == "function" and Config.Callback or function(Value, OldValue) end,
        Changed = Config.Changed or function() end,
        Type = "Slider"
    }

    local Dragging = false

    local SliderFrame = CreateElement(Config.Title or "Slider", Config.Description, self.Container, false)
    SliderFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

    Slider.SetTitle = SliderFrame.SetTitle
    Slider.SetDesc = SliderFrame.SetDesc

    local SliderDot = New("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, -7, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Image = "http://www.roblox.com/asset/?id=12266946128",
        ThemeTag = {
            ImageColor3 = "Accent",
        }
    })

    local SliderRail = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(7, 0),
        Size = UDim2.new(1, -14, 1, 0)
    }, {
        SliderDot,
    })

    local SliderTrack = New("Frame", {
        Size = UDim2.new(1, -140, 0, 6),
        Position = UDim2.new(1, -130, 0.5, -3),
        BackgroundColor3 = Color3.fromRGB(120, 120, 120),
        Parent = SliderFrame.Frame,
        ThemeTag = {
            BackgroundColor3 = "SliderRail",
        },
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 3),
        }),
        SliderRail,
    })

    local SliderLabel = New("TextLabel", {
        Size = UDim2.fromOffset(50, 14),
        Position = UDim2.new(1, -70, 0.5, -7),
        Text = tostring(Slider.Min),
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 12,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1,
        Parent = SliderFrame.Frame,
        ThemeTag = {
            TextColor3 = "Text"
        }
    })

    function Slider:OnChanged(Func)
        Slider.Changed = Func
        Library:SafeCallback(Func, Slider.Value, Slider.Value)
    end

    function Slider:SetValue(Value)
        local OldValue = Slider.Value

        Value = math.clamp(Value, Slider.Min, Slider.Max)
        Value = Library.Utilities:Round(Value, Slider.Rounding)

        rawset(Slider, "Value", Value)

        SliderLabel.Text = tostring(Value)

        local Percent = (Value - Slider.Min) / (Slider.Max - Slider.Min)
        SliderDot.Position = UDim2.new(Percent, -7, 0.5, 0)

        if typeof(Slider.Callback) == "function" then
            Library:SafeCallback(Slider.Callback, Value, OldValue)
        end
        if typeof(Slider.Changed) == "function" then
            Library:SafeCallback(Slider.Changed, Value, OldValue)
        end
    end

    function Slider:Destroy()
        SliderFrame:Destroy()
        Library.Options[Idx] = nil
    end

    Creator.AddSignal(SliderTrack.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true

            local function UpdateSlider()
                local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
                local Percent = math.clamp((Mouse.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                local Value = Slider.Min + (Slider.Max - Slider.Min) * Percent
                Slider:SetValue(Value)
            end

            UpdateSlider()

            local MoveConnection
            local ReleaseConnection

            MoveConnection = UserInputService.InputChanged:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    UpdateSlider()
                end
            end)

            ReleaseConnection = UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                    MoveConnection:Disconnect()
                    ReleaseConnection:Disconnect()
                end
            end)
        end
    end)

    Slider:SetValue(Config.Default or Config.Value or Slider.Min)

    Library.Options[Idx] = Slider
    Slider.Instance = SliderFrame

    return setmetatable(Slider, {
        __newindex = function(self, index, newvalue)
            if index == "Value" then
                task.spawn(Slider.SetValue, Slider, newvalue)
            end
            rawset(self, index, newvalue)
        end
    })
end

-- Input Element
local InputElement = {}
InputElement.__index = InputElement
InputElement.__type = "Input"

function InputElement:New(Idx, Config)
    local Input = {
        Value = Config.Default or Config.Value or "",
        Numeric = Config.Numeric or false,
        Finished = Config.Finished or false,
        ClearOnFocusLost = Config.ClearOnFocusLost or false,
        Callback = Config.Callback or function(Value) end,
        Changed = Config.Changed or function() end,
        Type = "Input"
    }

    local InputFrame = CreateElement(Config.Title or "Input", Config.Description, self.Container, false)

    local InputBox = New("TextBox", {
        Size = UDim2.new(1, -140, 0, 30),
        Position = UDim2.new(1, -130, 0.5, -15),
        BackgroundColor3 = Color3.fromRGB(160, 160, 160),
        BackgroundTransparency = 0.9,
        Text = Input.Value,
        PlaceholderText = Config.Placeholder or "",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 12,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        Parent = InputFrame.Frame,
        ThemeTag = {
            BackgroundColor3 = "Input",
            TextColor3 = "Text"
        }
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 5)
        }),
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8)
        }),
        New("UIStroke", {
            Transparency = 0.5,
            ThemeTag = {
                Color = "InElementBorder"
            }
        })
    })

    Input.SetTitle = InputFrame.SetTitle
    Input.SetDesc = InputFrame.SetDesc

    function Input:OnChanged(Func)
        Input.Changed = Func
        Library:SafeCallback(Func, Input.Value, Input.Value)
    end

    function Input:SetValue(Value)
        Value = tostring(Value)

        if Input.Numeric then
            Value = Value:gsub("[^%d%.%-]", "")
        end

        rawset(Input, "Value", Value)
        InputBox.Text = Value

        if typeof(Input.Changed) == "function" then
            Library:SafeCallback(Input.Changed, Value)
        end
    end

    function Input:Destroy()
        InputFrame:Destroy()
        Library.Options[Idx] = nil
    end

    if Input.Finished then
        Creator.AddSignal(InputBox.FocusLost, function(enterPressed)
            if enterPressed or not Input.ClearOnFocusLost then
                Input:SetValue(InputBox.Text)
                if typeof(Input.Callback) == "function" then
                    Library:SafeCallback(Input.Callback, Input.Value)
                end
            elseif Input.ClearOnFocusLost then
                InputBox.Text = Input.Value
            end
        end)
    else
        Creator.AddSignal(InputBox:GetPropertyChangedSignal("Text"), function()
            Input:SetValue(InputBox.Text)
            if typeof(Input.Callback) == "function" then
                Library:SafeCallback(Input.Callback, Input.Value)
            end
        end)
    end

    Library.Options[Idx] = Input
    Input.Instance = InputFrame

    return setmetatable(Input, {
        __newindex = function(self, index, newvalue)
            if index == "Value" then
                task.spawn(Input.SetValue, Input, newvalue)
            end
            rawset(self, index, newvalue)
        end
    })
end

-- Paragraph Element
local ParagraphElement = {}
ParagraphElement.__index = ParagraphElement
ParagraphElement.__type = "Paragraph"

function ParagraphElement:New(Idx, Config)
    local Paragraph = {
        Value = Config.Content or "",
        Type = "Paragraph"
    }

    local ParagraphFrame = CreateElement(Config.Title or "Paragraph", "", self.Container, false, Config)
    ParagraphFrame.DescLabel.Text = Paragraph.Value
    ParagraphFrame.DescLabel.Size = UDim2.new(1, -20, 0, 0)
    ParagraphFrame.DescLabel.AutomaticSize = Enum.AutomaticSize.Y

    Paragraph.SetTitle = ParagraphFrame.SetTitle
    Paragraph.SetDesc = ParagraphFrame.SetDesc

    function Paragraph:SetValue(Value)
        Paragraph.Value = tostring(Value)
        ParagraphFrame.DescLabel.Text = Paragraph.Value
    end

    function Paragraph:Destroy()
        ParagraphFrame:Destroy()
    end

    return Paragraph
end

-- Elements Registration
Elements.CreateButton = function(self, Idx, Config)
    ButtonElement.Container = self.Container
    ButtonElement.Type = self.Type
    ButtonElement.ScrollFrame = self.ScrollFrame
    ButtonElement.Library = Library
    return ButtonElement:New(Config)
end

Elements.CreateToggle = function(self, Idx, Config)
    ToggleElement.Container = self.Container
    ToggleElement.Type = self.Type
    ToggleElement.ScrollFrame = self.ScrollFrame
    ToggleElement.Library = Library
    return ToggleElement:New(Idx, Config)
end

Elements.CreateSlider = function(self, Idx, Config)
    SliderElement.Container = self.Container
    SliderElement.Type = self.Type
    SliderElement.ScrollFrame = self.ScrollFrame
    SliderElement.Library = Library
    return SliderElement:New(Idx, Config)
end

Elements.CreateInput = function(self, Idx, Config)
    InputElement.Container = self.Container
    InputElement.Type = self.Type
    InputElement.ScrollFrame = self.ScrollFrame
    InputElement.Library = Library
    return InputElement:New(Idx, Config)
end

Elements.CreateParagraph = function(self, Idx, Config)
    ParagraphElement.Container = self.Container
    ParagraphElement.Type = self.Type
    ParagraphElement.ScrollFrame = self.ScrollFrame
    ParagraphElement.Library = Library
    return ParagraphElement:New(Idx, Config)
end

Elements.AddButton = Elements.CreateButton
Elements.AddToggle = Elements.CreateToggle
Elements.AddSlider = Elements.CreateSlider
Elements.AddInput = Elements.CreateInput
Elements.AddParagraph = Elements.CreateParagraph

Elements.Button = Elements.CreateButton
Elements.Toggle = Elements.CreateToggle
Elements.Slider = Elements.CreateSlider
Elements.Input = Elements.CreateInput
Elements.Paragraph = Elements.CreateParagraph

Library.Elements = Elements

-- === WINDOW CREATION ===
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
    Library.Theme = if typeof(Config.Theme) == "string" then Config.Theme else "Dark"

    if Config.Acrylic then
        Acrylic.init()
    end

    local Window = {
        Minimized = false,
        OnMinimized = Signal.new(),
        PostMinimized = Signal.new(),
        Maximized = false,
        OnMaximized = Signal.new(),
        PostMaximized = Signal.new(),
        Size = Config.Size,
        MinSize = Config.MinSize,
        CurrentPos = 0,
        TabWidth = 0,
        Position = UDim2.fromOffset(
            Camera.ViewportSize.X / 2 - Config.Size.X.Offset / 2,
            Camera.ViewportSize.Y / 2 - Config.Size.Y.Offset / 2
        ),
        Tabs = {},
        SelectedTab = nil
    }

    Window.AcrylicPaint = Acrylic.AcrylicPaint()
    Window.TabWidth = Config.TabWidth or 160

    -- Main Window Frame
    Window.Root = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = Config.Size or UDim2.fromOffset(580, 460),
        Parent = BaseContainer,
        ThemeTag = {
            BackgroundColor3 = "AcrylicMain"
        }
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 8)
        }),
        New("UIStroke", {
            Color = Color3.fromRGB(90, 90, 90),
            Transparency = 0.5,
            ThemeTag = {
                Color = "AcrylicBorder"
            }
        })
    })

    -- Title Bar
    Window.TitleBar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = Window.Root
    }, {
        New("TextLabel", {
            Position = UDim2.fromOffset(15, 0),
            Size = UDim2.new(0, 200, 1, 0),
            Text = Config.Title or "Fluent Renewed",
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextSize = 14,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            ThemeTag = {
                TextColor3 = "Text"
            }
        }),
        New("TextLabel", {
            Position = UDim2.fromOffset(15, 17),
            Size = UDim2.new(0, 200, 0, 20),
            Text = Config.SubTitle or "Made with Fluent Renewed",
            TextColor3 = Color3.fromRGB(170, 170, 170),
            TextSize = 11,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            ThemeTag = {
                TextColor3 = "SubText"
            }
        })
    })

    -- Tab Container
    Window.TabContainer = New("ScrollingFrame", {
        Position = UDim2.fromOffset(0, 40),
        Size = UDim2.new(0, Window.TabWidth, 1, -40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = Window.Root
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 5),
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        New("UIPadding", {
            PaddingTop = UDim.new(0, 10)
        })
    })

    -- Content Container
    Window.ContentContainer = New("Frame", {
        Position = UDim2.fromOffset(Window.TabWidth, 40),
        Size = UDim2.new(1, -Window.TabWidth, 1, -40),
        BackgroundTransparency = 1,
        Parent = Window.Root
    })

    -- Tab Creation Function
    function Window:Tab(Config)
        local Tab = {
            Title = Config.Title or "Tab",
            Icon = Config.Icon,
            Window = Window,
            Elements = {}
        }

        -- Tab Button
        Tab.Button = New("TextButton", {
            Size = UDim2.new(1, -10, 0, 35),
            BackgroundColor3 = Color3.fromRGB(120, 120, 120),
            BackgroundTransparency = 0.87,
            Text = "",
            Parent = Window.TabContainer,
            ThemeTag = {
                BackgroundColor3 = "Tab"
            }
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0, 6)
            }),
            New("TextLabel", {
                Position = UDim2.fromOffset(10, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Text = Tab.Title,
                TextColor3 = Color3.fromRGB(240, 240, 240),
                TextSize = 13,
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                ThemeTag = {
                    TextColor3 = "Text"
                }
            })
        })

        -- Tab Content
        Tab.Content = New("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ScrollBarThickness = 0,
            Parent = Window.ContentContainer,
            Visible = false
        }, {
            New("UIListLayout", {
                Padding = UDim.new(0, 8),
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            New("UIPadding", {
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10)
            })
        })

        -- Tab Element Methods
        setmetatable(Tab, {
            __index = function(self, key)
                return Elements[key] and function(_, ...)
                    local element = setmetatable({
                        Container = Tab.Content,
                        Type = "Tab",
                        ScrollFrame = Tab.Content,
                        Library = Library
                    }, Elements)
                    return element[key](element, ...)
                end
            end
        })

        -- Tab Selection
        Creator.AddSignal(Tab.Button.MouseButton1Click, function()
            Window:SelectTab(Tab)
        end)

        Window.Tabs[#Window.Tabs + 1] = Tab

        if #Window.Tabs == 1 then
            Window:SelectTab(Tab)
        end

        return Tab
    end

    function Window:CreateTab(Config)
        return Window:Tab(Config)
    end

    function Window:SelectTab(TabToSelect)
        local Tab = typeof(TabToSelect) == "number" and Window.Tabs[TabToSelect] or TabToSelect

        if Tab and Tab ~= Window.SelectedTab then
            -- Hide current tab
            if Window.SelectedTab then
                Window.SelectedTab.Content.Visible = false
                TweenService:Create(Window.SelectedTab.Button, TweenInfo.new(0.2), {
                    BackgroundTransparency = Creator.GetThemeProperty("ElementTransparency")
                }):Play()
            end

            -- Show new tab
            Window.SelectedTab = Tab
            Tab.Content.Visible = true
            TweenService:Create(Tab.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = Creator.GetThemeProperty("ElementTransparency") - 0.15
            }):Play()
        end
    end

    -- Dialog Function
    function Window:Dialog(Config)
        Library.DialogOpen = true
        local Dialog = {
            Buttons = 0,
            Closing = Signal.new(),
            Closed = Signal.new()
        }

        Dialog.TintFrame = New("TextButton", {
            Text = "",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.5,
            Parent = Window.Root,
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0, 8),
            }),
        })

        Dialog.Main = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(400, 200),
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            Parent = Dialog.TintFrame,
            ThemeTag = {
                BackgroundColor3 = "Dialog"
            }
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0, 8)
            }),
            New("UIStroke", {
                Color = Color3.fromRGB(70, 70, 70),
                Transparency = 0.5,
                ThemeTag = {
                    Color = "DialogBorder"
                }
            }),
            New("TextLabel", {
                Position = UDim2.fromOffset(20, 20),
                Size = UDim2.new(1, -40, 0, 25),
                Text = Config.Title or "Dialog",
                TextColor3 = Color3.fromRGB(240, 240, 240),
                TextSize = 16,
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                ThemeTag = {
                    TextColor3 = "Text"
                }
            }),
            New("TextLabel", {
                Position = UDim2.fromOffset(20, 55),
                Size = UDim2.new(1, -40, 0, 100),
                Text = Config.Content or "Dialog content",
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 13,
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                BackgroundTransparency = 1,
                ThemeTag = {
                    TextColor3 = "SubText"
                }
            })
        })

        -- Buttons
        local ButtonHolder = New("Frame", {
            Position = UDim2.new(0, 20, 1, -50),
            Size = UDim2.new(1, -40, 0, 30),
            BackgroundTransparency = 1,
            Parent = Dialog.Main
        }, {
            New("UIListLayout", {
                Padding = UDim.new(0, 10),
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
        })

        function Dialog:Close()
            Library.DialogOpen = false
            Dialog.Closing:Fire()
            Dialog.TintFrame:Destroy()
            Dialog.Closed:Fire()
        end

        for _, ButtonConfig in pairs(Config.Buttons or {}) do
            local Button = New("TextButton", {
                Size = UDim2.fromOffset(80, 30),
                BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                Text = ButtonConfig.Title or "Button",
                TextColor3 = Color3.fromRGB(240, 240, 240),
                TextSize = 12,
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
                Parent = ButtonHolder,
                ThemeTag = {
                    BackgroundColor3 = "DialogButton",
                    TextColor3 = "Text"
                }
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0, 5)
                }),
                New("UIStroke", {
                    Color = Color3.fromRGB(80, 80, 80),
                    Transparency = 0.5,
                    ThemeTag = {
                        Color = "DialogButtonBorder"
                    }
                })
            })

            Creator.AddSignal(Button.MouseButton1Click, function()
                if ButtonConfig.Callback then
                    Library:SafeCallback(ButtonConfig.Callback)
                end
                Dialog:Close()
            end)
        end

        return Dialog
    end

    BaseContainer.Name = `FluentRenewed_{Config.Title}`
    Library.CreatedWindow = Window
    Library:SetTheme(Library.Theme)

    return Window
end

function Library:AddWindow(Config)
    return Library:Window(Config)
end

function Library:CreateWindow(Config)
    return Library:Window(Config)
end

function Library:SetTheme(Name)
    if Library.CreatedWindow and table.find(Library.Themes, Name) then
        Library.Theme = Name
        currentTheme = Name
        Creator.UpdateTheme()
        Library.ThemeChanged:Fire(Name)
    end
end

function Library:Destroy()
    if Library.CreatedWindow then
        Library.Unloaded = true
        Library.Loaded = false

        Library.OnUnload:Fire(tick())

        if Library.UseAcrylic then
            Library.CreatedWindow.AcrylicPaint.Model:Destroy()
        end

        Creator.Disconnect()

        for i,v in next, Library.Connections do
            local type = typeof(v)

            if type == "RBXScriptConnection" and v.Connected then
                v:Disconnect()
            end
        end

        local info, tweenProps, doTween = TweenInfo.new(2 / 3, Enum.EasingStyle.Quint), {}, false

        local function IsA(obj, class)
            local isClass = obj:IsA(class)

            if isClass then
                doTween = true
            end

            return isClass
        end

        for i,v in next, Library.GUI:GetDescendants() do
            table.clear(tweenProps)

            if IsA(v, "GuiObject") then
                tweenProps.BackgroundTransparency = 1
            end

            if IsA(v, "ScrollingFrame") then
                tweenProps.ScrollBarImageTransparency = 1        
            end

            if IsA(v, "TextLabel") or IsA(v, "TextBox") then
                tweenProps.TextStrokeTransparency = 1
                tweenProps.TextTransparency = 1
            end

            if IsA(v, "UIStroke") then
                tweenProps.Transparency = 1
            end

            if IsA(v, "ImageLabel") or IsA(v, "ImageButton") then
                tweenProps.ImageTransparency = 1
            end

            if doTween then
                doTween = false
                TweenService:Create(v, info, tweenProps):Play()
            end
        end

        task.delay(info.Time, function()
            Library.GUI:Destroy()
            Library.PostUnload:Fire(tick())
        end)
    end
end

function Library:ToggleAcrylic(Value)
    if Library.CreatedWindow then
        if Library.UseAcrylic then
            Library.Acrylic = Value
            Library.CreatedWindow.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
            if Value then
                Acrylic.Enable()
            else
                Acrylic.Disable()
            end
        end
    end
end

function Library:ToggleTransparency(Value)
    if Library.CreatedWindow then
        Library.CreatedWindow.AcrylicPaint.Frame.Background.BackgroundTransparency = Value and 0.35 or 0
    end
end

function Library:Notify(Config)
    return Notification:New(Config)
end

-- Set current theme and initialize
currentTheme = Library.Theme

return Library
