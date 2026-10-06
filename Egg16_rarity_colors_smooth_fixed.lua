--[[
    MOCHICLUB EGG VIEWER
    COMPACT LANDSCAPE EGG UI WITH EGG & VISUAL TABS (RED GLOW THEME)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- REMOVE OLD UI
--==================================================

local old = PlayerGui:FindFirstChild("EggViewerUI")
if old then old:Destroy() end

local oldToggle = PlayerGui:FindFirstChild("EggViewerToggleUI")
if oldToggle then oldToggle:Destroy() end

local oldStats = PlayerGui:FindFirstChild("EggViewerStatsUI")
if oldStats then oldStats:Destroy() end

--==================================================
-- SAFE REQUIRE
--==================================================

local function SafeRequire(path)
    local current = ReplicatedStorage

    for _, name in ipairs(path) do
        current = current:WaitForChild(name, 10)

        if not current then
            return nil
        end
    end

    local ok, result = pcall(require, current)

    if ok then
        return result
    end

    return nil
end

--==================================================
-- MODULES
--==================================================

local EggState =
    SafeRequire({
        "Client",
        "EggState"
    })

local Assets =
    SafeRequire({
        "Data",
        "Assets"
    })

local EggRecords =
    SafeRequire({
        "Shared",
        "Util",
        "EggRecords"
    })

local Mutations =
    SafeRequire({
        "Shared",
        "Modules",
        "Mutations"
    })

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EggViewerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = PlayerGui

--==================================================
-- FLOATING STATS BOX
--==================================================

local StatsGui = Instance.new("ScreenGui")
StatsGui.Name = "EggViewerStatsUI"
StatsGui.ResetOnSpawn = false
StatsGui.IgnoreGuiInset = true
StatsGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling
StatsGui.DisplayOrder = 999998
StatsGui.Parent = PlayerGui

local StatsBox = Instance.new("Frame")
StatsBox.Name = "StatsBox"
StatsBox.Size =
    UDim2.fromOffset(130, 26)
StatsBox.Position =
    UDim2.new(0.5, -65, 0, 10)
StatsBox.BackgroundColor3 =
    Color3.fromRGB(30, 30, 35)
StatsBox.BackgroundTransparency = 0.5
StatsBox.BorderSizePixel = 0
StatsBox.Visible = false
StatsBox.Parent = StatsGui

local StatsBoxCorner =
    Instance.new("UICorner")

StatsBoxCorner.CornerRadius =
    UDim.new(0, 5)

StatsBoxCorner.Parent =
    StatsBox

local StatsBoxStroke =
    Instance.new("UIStroke")

StatsBoxStroke.Thickness = 1.5
StatsBoxStroke.Color =
    Color3.fromRGB(255, 50, 50)
StatsBoxStroke.Transparency = 0.2
StatsBoxStroke.Parent = StatsBox

local PingIcon =
    Instance.new("ImageLabel")

PingIcon.Name = "PingIcon"
PingIcon.Size =
    UDim2.fromOffset(14, 14)

PingIcon.Position =
    UDim2.new(0, 6, 0.5, -7)

PingIcon.BackgroundTransparency = 1
PingIcon.Image =
    "rbxassetid://11419714892"

PingIcon.ImageColor3 =
    Color3.fromRGB(255, 100, 100)

PingIcon.Parent = StatsBox

local PingLabel =
    Instance.new("TextLabel")

PingLabel.Name = "PingLabel"
PingLabel.Size =
    UDim2.fromOffset(50, 20)

PingLabel.Position =
    UDim2.new(0, 22, 0.5, -10)

PingLabel.BackgroundTransparency = 1
PingLabel.Text = "0ms"

PingLabel.TextColor3 =
    Color3.fromRGB(255, 180, 180)

PingLabel.Font =
    Enum.Font.GothamBold

PingLabel.TextSize = 9

PingLabel.TextXAlignment =
    Enum.TextXAlignment.Left

PingLabel.Parent = StatsBox

local Divider =
    Instance.new("Frame")

Divider.Size =
    UDim2.fromOffset(1, 14)

Divider.Position =
    UDim2.new(0.5, -0.5, 0.5, -7)

Divider.BackgroundColor3 =
    Color3.fromRGB(255, 50, 50)

Divider.BackgroundTransparency = 0.4
Divider.BorderSizePixel = 0
Divider.Parent = StatsBox

local FpsIcon =
    Instance.new("ImageLabel")

FpsIcon.Name = "FpsIcon"
FpsIcon.Size =
    UDim2.fromOffset(14, 14)

FpsIcon.Position =
    UDim2.new(0.5, 8, 0.5, -7)

FpsIcon.BackgroundTransparency = 1
FpsIcon.Image =
    "rbxassetid://11419708779"

FpsIcon.ImageColor3 =
    Color3.fromRGB(255, 100, 100)

FpsIcon.Parent = StatsBox

local FpsLabel =
    Instance.new("TextLabel")

FpsLabel.Name = "FpsLabel"
FpsLabel.Size =
    UDim2.fromOffset(50, 20)

FpsLabel.Position =
    UDim2.new(0.5, 24, 0.5, -10)

FpsLabel.BackgroundTransparency = 1
FpsLabel.Text = "0 FPS"

FpsLabel.TextColor3 =
    Color3.fromRGB(255, 180, 180)

FpsLabel.Font =
    Enum.Font.GothamBold

FpsLabel.TextSize = 9

FpsLabel.TextXAlignment =
    Enum.TextXAlignment.Left

FpsLabel.Parent = StatsBox

--==================================================
-- STATS DRAG
--==================================================

local statsDragging = false
local statsDragStart
local statsStartPos

StatsBox.InputBegan:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            statsDragging = true
            statsDragStart = input.Position
            statsStartPos = StatsBox.Position

            input.Changed:Connect(
                function()

                    if input.UserInputState ==
                        Enum.UserInputState.End then

                        statsDragging = false
                    end
                end
            )
        end
    end
)

UserInputService.InputChanged:Connect(
    function(input)

        if not statsDragging then
            return
        end

        if input.UserInputType ~=
            Enum.UserInputType.MouseMovement
            and input.UserInputType ~=
            Enum.UserInputType.Touch then

            return
        end

        local delta =
            input.Position - statsDragStart

        StatsBox.Position =
            UDim2.new(
                statsStartPos.X.Scale,
                statsStartPos.X.Offset
                    + delta.X,

                statsStartPos.Y.Scale,
                statsStartPos.Y.Offset
                    + delta.Y
            )
    end
)

--==================================================
-- FPS & PING
--==================================================

local lastTick = tick()
local frameCount = 0

RunService.RenderStepped:Connect(
    function()

        frameCount += 1

        local currentTick = tick()

        if currentTick - lastTick >= 0.5 then

            local fps =
                math.round(
                    frameCount
                    / (currentTick - lastTick)
                )

            if StatsBox.Visible then

                FpsLabel.Text =
                    fps .. " FPS"

                local pingVal = 0

                pcall(
                    function()
                        pingVal =
                            math.round(
                                LocalPlayer:
                                GetNetworkPing()
                                * 1000
                            )
                    end
                )

                PingLabel.Text =
                    pingVal .. "ms"
            end

            frameCount = 0
            lastTick = currentTick
        end
    end
)

--==================================================
-- TOGGLE / LOGO
--==================================================

local ToggleGui =
    Instance.new("ScreenGui")

ToggleGui.Name =
    "EggViewerToggleUI"

ToggleGui.ResetOnSpawn = false
ToggleGui.IgnoreGuiInset = true

ToggleGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

ToggleGui.DisplayOrder = 1000000
ToggleGui.Parent = PlayerGui

local ToggleButton =
    Instance.new("ImageButton")

ToggleButton.Name =
    "ToggleButton"

ToggleButton.Size =
    UDim2.fromOffset(45, 45)

ToggleButton.Position =
    UDim2.new(1, -60, 0.5, -155)

ToggleButton.BackgroundTransparency = 0.2

ToggleButton.BackgroundColor3 =
    Color3.fromRGB(35, 35, 40)

ToggleButton.Image =
    "rbxassetid://134755717495073"

ToggleButton.ScaleType =
    Enum.ScaleType.Stretch

ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = ToggleGui

local ToggleCorner =
    Instance.new("UICorner")

ToggleCorner.CornerRadius =
    UDim.new(0, 6)

ToggleCorner.Parent =
    ToggleButton

local ToggleStroke =
    Instance.new("UIStroke")

ToggleStroke.Thickness = 2
ToggleStroke.Color =
    Color3.fromRGB(255, 30, 30)

ToggleStroke.Parent =
    ToggleButton

--==================================================
-- MAIN FRAME
--==================================================

local Main =
    Instance.new("Frame")

Main.Name = "EggPanel"

Main.Size =
    UDim2.fromOffset(300, 310)

Main.Position =
    UDim2.new(
        1,
        -315,
        0.5,
        -155
    )

Main.BackgroundColor3 =
    Color3.fromRGB(35, 35, 40)

Main.BackgroundTransparency = 0.35
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner =
    Instance.new("UICorner")

MainCorner.CornerRadius =
    UDim.new(0, 8)

MainCorner.Parent = Main

local MainStroke =
    Instance.new("UIStroke")

MainStroke.Thickness = 2
MainStroke.Color =
    Color3.fromRGB(255, 40, 40)

MainStroke.Transparency = 0.1
MainStroke.Parent = Main

--==================================================
-- WALLPAPER
--==================================================

local Wallpaper =
    Instance.new("ImageLabel")

Wallpaper.Name =
    "Wallpaper"

Wallpaper.AnchorPoint =
    Vector2.new(0, 0)

Wallpaper.Position =
    UDim2.fromOffset(0, 0)

Wallpaper.Size =
    UDim2.new(1, 0, 1, 0)

Wallpaper.BackgroundTransparency = 1
Wallpaper.BorderSizePixel = 0

Wallpaper.Image =
    "rbxassetid://101941202704989"

Wallpaper.ScaleType =
    Enum.ScaleType.Crop

Wallpaper.ClipsDescendants = true
Wallpaper.ZIndex = 0
Wallpaper.Parent = Main

local WallpaperCorner =
    Instance.new("UICorner")

WallpaperCorner.CornerRadius =
    UDim.new(0, 8)

WallpaperCorner.Parent =
    Wallpaper

--==================================================
-- HEADER
--==================================================

local Header =
    Instance.new("Frame")

Header.Name = "Header"

Header.Size =
    UDim2.new(1, 0, 0, 32)

Header.BackgroundColor3 =
    Color3.fromRGB(220, 30, 30)

Header.BackgroundTransparency = 0.1
Header.BorderSizePixel = 0
Header.ZIndex = 2
Header.Parent = Main

local HeaderCorner =
    Instance.new("UICorner")

HeaderCorner.CornerRadius =
    UDim.new(0, 8)

HeaderCorner.Parent =
    Header

local HeaderCover =
    Instance.new("Frame")

HeaderCover.Size =
    UDim2.new(1, 0, 0, 8)

HeaderCover.Position =
    UDim2.new(0, 0, 1, -8)

HeaderCover.BackgroundColor3 =
    Header.BackgroundColor3

HeaderCover.BackgroundTransparency = 0.1
HeaderCover.BorderSizePixel = 0
HeaderCover.ZIndex = 2
HeaderCover.Parent = Header

--==================================================
-- TITLE
--==================================================

local Title =
    Instance.new("TextLabel")

Title.Name = "Title"

Title.Size =
    UDim2.new(1, -16, 1, 0)

Title.Position =
    UDim2.fromOffset(9, 0)

Title.BackgroundTransparency = 1
Title.Text = "MochiClub"

Title.TextColor3 =
    Color3.new(1, 1, 1)

Title.Font =
    Enum.Font.GothamBold

Title.TextSize = 13

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.TextYAlignment =
    Enum.TextYAlignment.Center

Title.ZIndex = 3
Title.Parent = Header

--==================================================
-- TAB BAR
--==================================================

local TabBar =
    Instance.new("Frame")

TabBar.Name = "TabBar"

TabBar.Size =
    UDim2.new(1, -10, 0, 22)

TabBar.Position =
    UDim2.fromOffset(5, 35)

TabBar.BackgroundTransparency = 1
TabBar.ZIndex = 2
TabBar.Parent = Main

local EggTabButton =
    Instance.new("TextButton")

EggTabButton.Name = "EggTab"

EggTabButton.Size =
    UDim2.new(0.5, -2, 1, 0)

EggTabButton.BackgroundColor3 =
    Color3.fromRGB(230, 40, 40)

EggTabButton.BackgroundTransparency = 0.2
EggTabButton.BorderSizePixel = 0
EggTabButton.Text = "Egg"

EggTabButton.TextColor3 =
    Color3.new(1, 1, 1)

EggTabButton.Font =
    Enum.Font.GothamBold

EggTabButton.TextSize = 9
EggTabButton.ZIndex = 2
EggTabButton.Parent = TabBar

local EggTabCorner =
    Instance.new("UICorner")

EggTabCorner.CornerRadius =
    UDim.new(0, 4)

EggTabCorner.Parent =
    EggTabButton

local VisualTabButton =
    Instance.new("TextButton")

VisualTabButton.Name =
    "VisualTab"

VisualTabButton.Size =
    UDim2.new(0.5, -2, 1, 0)

VisualTabButton.Position =
    UDim2.new(0.5, 2, 0, 0)

VisualTabButton.BackgroundColor3 =
    Color3.fromRGB(52, 52, 60)

VisualTabButton.BackgroundTransparency = 0.2
VisualTabButton.BorderSizePixel = 0
VisualTabButton.Text = "Visual"

VisualTabButton.TextColor3 =
    Color3.fromRGB(205, 205, 210)

VisualTabButton.Font =
    Enum.Font.GothamBold

VisualTabButton.TextSize = 9
VisualTabButton.ZIndex = 2
VisualTabButton.Parent = TabBar

local VisualTabCorner =
    Instance.new("UICorner")

VisualTabCorner.CornerRadius =
    UDim.new(0, 4)

VisualTabCorner.Parent =
    VisualTabButton

--==================================================
-- STATUS & SORT
--==================================================

local Status =
    Instance.new("TextLabel")

Status.Name = "Status"

Status.Size =
    UDim2.new(1, -14, 0, 16)

Status.Position =
    UDim2.fromOffset(7, 58)

Status.BackgroundTransparency = 1
Status.Text = ""

Status.TextColor3 =
    Color3.fromRGB(210, 210, 210)

Status.Font =
    Enum.Font.Gotham

Status.TextSize = 9

Status.TextXAlignment =
    Enum.TextXAlignment.Left

Status.ZIndex = 2
Status.Parent = Main

local SortMode = "Value"

local SortModes = {
    "Value",
    "Rarity",
    "Weight"
}

local SortButtons = {}

local SortBar =
    Instance.new("Frame")

SortBar.Name = "SortBar"

SortBar.Size =
    UDim2.new(1, -10, 0, 24)

SortBar.Position =
    UDim2.fromOffset(5, 75)

SortBar.BackgroundTransparency = 1
SortBar.BorderSizePixel = 0
SortBar.ZIndex = 2
SortBar.Parent = Main

local SortLayout =
    Instance.new("UIListLayout")

SortLayout.FillDirection =
    Enum.FillDirection.Horizontal

SortLayout.HorizontalAlignment =
    Enum.HorizontalAlignment.Left

SortLayout.VerticalAlignment =
    Enum.VerticalAlignment.Center

SortLayout.Padding =
    UDim.new(0, 4)

SortLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

SortLayout.Parent = SortBar

for index, mode in ipairs(SortModes) do

    local Button =
        Instance.new("TextButton")

    Button.Name =
        "Sort" .. mode

    Button.Size =
        UDim2.fromOffset(88, 21)

    Button.BackgroundColor3 =
        mode == SortMode
        and Color3.fromRGB(230, 40, 40)
        or Color3.fromRGB(52, 52, 60)

    Button.BackgroundTransparency = 0.2
    Button.TextColor3 =
        Color3.new(1, 1, 1)

    Button.Font =
        Enum.Font.GothamBold

    Button.TextSize = 8

    Button.Text =
        "Sort: " .. mode

    Button.BorderSizePixel = 0
    Button.AutoButtonColor = true
    Button.LayoutOrder = index
    Button.ZIndex = 2
    Button.Parent = SortBar

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(0, 4)

    Corner.Parent = Button

    SortButtons[mode] = Button
end

--==================================================
-- RARITY FILTER BAR
--==================================================

local RarityFilters = {
    "All",
    "Divine",
    "Eternal",
    "Secret",
    "Cosmic",
    "Mythic",
    "Legendary",
    "Epic",
    "Rare",
    "Uncommon",
    "Common"
}

local SelectedRarity = "All"

local RarityBar =
    Instance.new("ScrollingFrame")

RarityBar.Name =
    "RarityFilters"

RarityBar.Size =
    UDim2.new(1, -10, 0, 28)

RarityBar.Position =
    UDim2.fromOffset(5, 101)

RarityBar.BackgroundColor3 =
    Color3.fromRGB(28, 28, 33)

RarityBar.BackgroundTransparency = 0.4
RarityBar.BorderSizePixel = 0
RarityBar.ScrollBarThickness = 2
RarityBar.ScrollBarImageTransparency = 0.15

RarityBar.ScrollingDirection =
    Enum.ScrollingDirection.X

RarityBar.CanvasSize =
    UDim2.new(0, 0, 0, 0)

RarityBar.AutomaticCanvasSize =
    Enum.AutomaticSize.X

RarityBar.ZIndex = 2
RarityBar.Parent = Main

local RarityBarCorner =
    Instance.new("UICorner")

RarityBarCorner.CornerRadius =
    UDim.new(0, 5)

RarityBarCorner.Parent =
    RarityBar

local RarityPadding =
    Instance.new("UIPadding")

RarityPadding.PaddingLeft =
    UDim.new(0, 3)

RarityPadding.PaddingRight =
    UDim.new(0, 3)

RarityPadding.PaddingTop =
    UDim.new(0, 2)

RarityPadding.PaddingBottom =
    UDim.new(0, 2)

RarityPadding.Parent =
    RarityBar

local RarityLayout =
    Instance.new("UIListLayout")

RarityLayout.FillDirection =
    Enum.FillDirection.Horizontal

RarityLayout.HorizontalAlignment =
    Enum.HorizontalAlignment.Left

RarityLayout.VerticalAlignment =
    Enum.VerticalAlignment.Center

RarityLayout.Padding =
    UDim.new(0, 3)

RarityLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

RarityLayout.Parent =
    RarityBar

local RarityButtons = {}

local function NormalizeRarity(rarity)
    local key = string.lower(string.gsub(string.gsub(tostring(rarity or ""), "^%s+", ""), "%s+$", ""))

    local aliases = {
        ["all"] = "All",
        ["divine"] = "Divine",
        ["eternal"] = "Eternal",
        ["secret"] = "Secret",
        ["cosmic"] = "Cosmic",
        ["mythic"] = "Mythic",
        ["legendary"] = "Legendary",
        ["epic"] = "Epic",
        ["rare"] = "Rare",
        ["uncommon"] = "Uncommon",
        ["common"] = "Common"
    }

    return aliases[key] or tostring(rarity or "")
end

local RarityColors = {
    All = Color3.fromRGB(230, 40, 40),
    Divine = Color3.fromRGB(255, 215, 70),
    Eternal = Color3.fromRGB(255, 110, 210),
    Secret = Color3.fromRGB(0, 0, 0),
    -- Cosmic is blue/violet, not pink/red.
    Cosmic = Color3.fromRGB(105, 95, 255),
    Mythic = Color3.fromRGB(255, 80, 100),
    Legendary = Color3.fromRGB(255, 165, 60),
    Epic = Color3.fromRGB(180, 80, 255),
    Rare = Color3.fromRGB(70, 160, 255),
    Uncommon = Color3.fromRGB(80, 210, 130),
    Common = Color3.fromRGB(170, 170, 180)
}

local function GetRarityColor(rarity)
    local normalized = NormalizeRarity(rarity)
    return RarityColors[normalized] or Color3.fromRGB(70, 70, 78)
end

-- Creates a subtle rarity-tinted card without adding extra UI objects.
-- This is intentionally cheap so refreshing/animating many cards stays smooth.
local function GetRarityCardBackground(rarity)
    local color = GetRarityColor(rarity)
    local normalized = NormalizeRarity(rarity)

    if normalized == "Secret" then
        return Color3.fromRGB(18, 18, 20)
    end

    return Color3.new(
        0.72 * 0.16 + color.R * 0.16,
        0.72 * 0.16 + color.G * 0.16,
        0.78 * 0.16 + color.B * 0.16
    )
end

local function ApplyRarityCardTheme(card, rarity)
    if not card then
        return
    end

    local normalized = NormalizeRarity(rarity)
    local color = GetRarityColor(normalized)

    if card.Rarity then
        card.Rarity.TextColor3 = color

        if normalized == "Secret" then
            -- Keep the actual rarity color black while preserving readability.
            card.Rarity.TextStrokeColor3 = Color3.new(1, 1, 1)
            card.Rarity.TextStrokeTransparency = 0.35
        else
            card.Rarity.TextStrokeTransparency = 1
        end
    end

    if card.Frame then
        card.Frame.BackgroundColor3 = GetRarityCardBackground(normalized)
    end

    if card.RarityStroke then
        -- The outline/glow always follows the actual rarity.
        card.RarityStroke.Color = color
        card.RarityStroke.Transparency = normalized == "Secret" and 0.08 or 0.16
    end

    if card.BoxStroke then
        card.BoxStroke.Color = color
        card.BoxStroke.Transparency = normalized == "Secret" and 0.15 or 0.25
    end
end

for index, rarity in ipairs(
    RarityFilters
) do

    local Button =
        Instance.new("TextButton")

    Button.Name =
        rarity .. "Filter"

    Button.Size =
        UDim2.fromOffset(
            math.max(
                40,
                #rarity * 5 + 10
            ),
            21
        )

    Button.BackgroundColor3 =
        rarity == "All"
        and GetRarityColor(rarity)
        or Color3.fromRGB(
            52,
            52,
            60
        )

    Button.BackgroundTransparency = 0.2
    Button.BorderSizePixel = 0
    Button.Text = rarity

    Button.TextColor3 =
        Color3.new(1, 1, 1)

    Button.Font =
        Enum.Font.GothamBold

    Button.TextSize = 8
    Button.AutoButtonColor = true
    Button.LayoutOrder = index
    Button.ZIndex = 2
    Button.Parent = RarityBar

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(0, 4)

    Corner.Parent = Button

    RarityButtons[rarity] =
        Button
end

--==================================================
-- VISUAL TAB
--==================================================

local VisualContainer =
    Instance.new("ScrollingFrame")

VisualContainer.Name =
    "VisualContainer"

VisualContainer.Size =
    UDim2.new(1, -10, 1, -75)

VisualContainer.Position =
    UDim2.fromOffset(5, 65)

VisualContainer.BackgroundTransparency = 1
VisualContainer.BorderSizePixel = 0
VisualContainer.ScrollBarThickness = 3
VisualContainer.ScrollBarImageTransparency = 0.2

VisualContainer.CanvasSize =
    UDim2.new(0, 0, 0, 0)

VisualContainer.AutomaticCanvasSize =
    Enum.AutomaticSize.Y

VisualContainer.Visible = false
VisualContainer.ZIndex = 2
VisualContainer.Parent = Main

local VisualLayout =
    Instance.new("UIListLayout")

VisualLayout.Padding =
    UDim.new(0, 6)

VisualLayout.HorizontalAlignment =
    Enum.HorizontalAlignment.Center

VisualLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

VisualLayout.Parent =
    VisualContainer

local VisualPadding =
    Instance.new("UIPadding")

VisualPadding.PaddingTop =
    UDim.new(0, 5)

VisualPadding.PaddingBottom =
    UDim.new(0, 5)

VisualPadding.PaddingLeft =
    UDim.new(0, 2)

VisualPadding.PaddingRight =
    UDim.new(0, 2)

VisualPadding.Parent =
    VisualContainer

local function CreateFeatureRow(
    nameLeft,
    callbackLeft,
    nameRight,
    callbackRight,
    orderIndex
)

    local Row =
        Instance.new("Frame")

    Row.Name =
        "FeatureRow_" .. orderIndex

    Row.Size =
        UDim2.new(1, -4, 0, 42)

    Row.BackgroundTransparency = 1
    Row.LayoutOrder = orderIndex
    Row.ZIndex = 2
    Row.Parent = VisualContainer

    if nameLeft then

        local LeftBox =
            Instance.new("Frame")

        LeftBox.Name = "LeftBox"

        LeftBox.Size =
            UDim2.new(
                0.5,
                -3,
                1,
                0
            )

        LeftBox.BackgroundColor3 =
            Color3.fromRGB(
                48,
                48,
                54
            )

        LeftBox.BackgroundTransparency = 0.3
        LeftBox.BorderSizePixel = 0
        LeftBox.ZIndex = 2
        LeftBox.Parent = Row

        local LC =
            Instance.new("UICorner")

        LC.CornerRadius =
            UDim.new(0, 6)

        LC.Parent = LeftBox

        local LS =
            Instance.new("UIStroke")

        LS.Thickness = 1
        LS.Color =
            Color3.fromRGB(
                255,
                60,
                60
            )

        LS.Transparency = 0.3
        LS.Parent = LeftBox

        local LText =
            Instance.new("TextLabel")

        LText.Size =
            UDim2.new(
                1,
                -45,
                1,
                0
            )

        LText.Position =
            UDim2.fromOffset(6, 0)

        LText.BackgroundTransparency = 1
        LText.Text = nameLeft

        LText.TextColor3 =
            Color3.new(1, 1, 1)

        LText.Font =
            Enum.Font.GothamBold

        LText.TextSize = 8

        LText.TextXAlignment =
            Enum.TextXAlignment.Left

        LText.ZIndex = 3
        LText.Parent = LeftBox

        local LBtn =
            Instance.new("TextButton")

        LBtn.Size =
            UDim2.fromOffset(
                36,
                20
            )

        LBtn.Position =
            UDim2.new(
                1,
                -41,
                0.5,
                -10
            )

        LBtn.BackgroundColor3 =
            Color3.fromRGB(
                60,
                60,
                70
            )

        LBtn.BackgroundTransparency = 0.2
        LBtn.BorderSizePixel = 0
        LBtn.Text = "OFF"

        LBtn.TextColor3 =
            Color3.fromRGB(
                255,
                80,
                80
            )

        LBtn.Font =
            Enum.Font.GothamBold

        LBtn.TextSize = 8
        LBtn.ZIndex = 3
        LBtn.Parent = LeftBox

        local LBtnC =
            Instance.new("UICorner")

        LBtnC.CornerRadius =
            UDim.new(0, 4)

        LBtnC.Parent = LBtn

        local lState = false

        LBtn.Activated:Connect(
            function()

                lState =
                    not lState

                if lState then

                    LBtn.Text = "ON"

                    LBtn.TextColor3 =
                        Color3.fromRGB(
                            80,
                            255,
                            90
                        )

                    LBtn.BackgroundColor3 =
                        Color3.fromRGB(
                            40,
                            120,
                            50
                        )

                else

                    LBtn.Text = "OFF"

                    LBtn.TextColor3 =
                        Color3.fromRGB(
                            255,
                            80,
                            80
                        )

                    LBtn.BackgroundColor3 =
                        Color3.fromRGB(
                            60,
                            60,
                            70
                        )
                end

                if callbackLeft then
                    pcall(
                        callbackLeft,
                        lState
                    )
                end
            end
        )
    end

    if nameRight then

        local RightBox =
            Instance.new("Frame")

        RightBox.Name = "RightBox"

        RightBox.Size =
            UDim2.new(
                0.5,
                -3,
                1,
                0
            )

        RightBox.Position =
            UDim2.new(
                0.5,
                3,
                0,
                0
            )

        RightBox.BackgroundColor3 =
            Color3.fromRGB(
                48,
                48,
                54
            )

        RightBox.BackgroundTransparency = 0.3
        RightBox.BorderSizePixel = 0
        RightBox.ZIndex = 2
        RightBox.Parent = Row

        local RC =
            Instance.new("UICorner")

        RC.CornerRadius =
            UDim.new(0, 6)

        RC.Parent = RightBox

        local RS =
            Instance.new("UIStroke")

        RS.Thickness = 1

        RS.Color =
            Color3.fromRGB(
                255,
                60,
                60
            )

        RS.Transparency = 0.3
        RS.Parent = RightBox

        local RText =
            Instance.new("TextLabel")

        RText.Size =
            UDim2.new(
                1,
                -45,
                1,
                0
            )

        RText.Position =
            UDim2.fromOffset(6, 0)

        RText.BackgroundTransparency = 1
        RText.Text = nameRight

        RText.TextColor3 =
            Color3.new(1, 1, 1)

        RText.Font =
            Enum.Font.GothamBold

        RText.TextSize = 8

        RText.TextXAlignment =
            Enum.TextXAlignment.Left

        RText.ZIndex = 3
        RText.Parent = RightBox

        local RBtn =
            Instance.new("TextButton")

        RBtn.Size =
            UDim2.fromOffset(
                36,
                20
            )

        RBtn.Position =
            UDim2.new(
                1,
                -41,
                0.5,
                -10
            )

        RBtn.BackgroundColor3 =
            Color3.fromRGB(
                60,
                60,
                70
            )

        RBtn.BackgroundTransparency = 0.2
        RBtn.BorderSizePixel = 0
        RBtn.Text = "OFF"

        RBtn.TextColor3 =
            Color3.fromRGB(
                255,
                80,
                80
            )

        RBtn.Font =
            Enum.Font.GothamBold

        RBtn.TextSize = 8
        RBtn.ZIndex = 3
        RBtn.Parent = RightBox

        local RBtnC =
            Instance.new("UICorner")

        RBtnC.CornerRadius =
            UDim.new(0, 4)

        RBtnC.Parent = RBtn

        local rState = false

        RBtn.Activated:Connect(
            function()

                rState =
                    not rState

                if rState then

                    RBtn.Text = "ON"

                    RBtn.TextColor3 =
                        Color3.fromRGB(
                            80,
                            255,
                            90
                        )

                    RBtn.BackgroundColor3 =
                        Color3.fromRGB(
                            40,
                            120,
                            50
                        )

                else

                    RBtn.Text = "OFF"

                    RBtn.TextColor3 =
                        Color3.fromRGB(
                            255,
                            80,
                            80
                        )

                    RBtn.BackgroundColor3 =
                        Color3.fromRGB(
                            60,
                            60,
                            70
                        )
                end

                if callbackRight then
                    pcall(
                        callbackRight,
                        rState
                    )
                end
            end
        )
    end
end

--==================================================
-- VISUAL FEATURES LOGIC
--==================================================

local originalSettings = {}

local function ToggleFpsBoost(state)

    if state then

        originalSettings.GlobalShadows =
            Lighting.GlobalShadows

        originalSettings.Brightness =
            Lighting.Brightness

        Lighting.GlobalShadows = false
        Lighting.Brightness = 2

        for _, v in ipairs(
            workspace:GetDescendants()
        ) do

            if v:IsA("BasePart") then

                v.Material =
                    Enum.Material.SmoothPlastic

                v.Reflectance = 0

            elseif v:IsA("Texture")
                or v:IsA("Decal") then

                v.Transparency = 1

            elseif v:IsA("ParticleEmitter")
                or v:IsA("Trail")
                or v:IsA("Fire")
                or v:IsA("Smoke")
                or v:IsA("Sparkles") then

                v.Enabled = false
            end
        end

    else

        Lighting.GlobalShadows =
            originalSettings.GlobalShadows
            or true

        Lighting.Brightness =
            originalSettings.Brightness
            or 1
    end
end

local antiRagdollConn

local function ToggleAntiRagdoll(state)

    if state then

        antiRagdollConn =
            RunService.Heartbeat:Connect(
                function()

                    local char =
                        LocalPlayer.Character

                    if char then

                        local humanoid =
                            char:FindFirstChildOfClass(
                                "Humanoid"
                            )

                        if humanoid
                            and (
                                humanoid:GetState()
                                ==
                                Enum.HumanoidStateType.Ragdoll
                                or
                                humanoid:GetState()
                                ==
                                Enum.HumanoidStateType.FallingDown
                            ) then

                            humanoid:ChangeState(
                                Enum.HumanoidStateType.GettingUp
                            )
                        end
                    end
                end
            )

    else

        if antiRagdollConn then

            antiRagdollConn:Disconnect()
            antiRagdollConn = nil
        end
    end
end

local function ToggleAntiGuard(state)
    print(
        "Anti Guard:",
        state
    )
end

local function ToggleAntiTrap(state)
    print(
        "Anti Trap:",
        state
    )
end

local function ToggleFpsPingDisplay(state)
    StatsBox.Visible = state
end

CreateFeatureRow(
    "Anti Guard",
    ToggleAntiGuard,
    "Fps Boost",
    ToggleFpsBoost,
    1
)

CreateFeatureRow(
    "Anti Trap",
    ToggleAntiTrap,
    "Anti Ragdoll",
    ToggleAntiRagdoll,
    2
)

CreateFeatureRow(
    "FPS & Ping",
    ToggleFpsPingDisplay,
    nil,
    nil,
    3
)

--==================================================
-- SCROLL LIST
--==================================================

local Scrolling =
    Instance.new("ScrollingFrame")

Scrolling.Name = "EggList"

Scrolling.Size =
    UDim2.new(
        1,
        -10,
        1,
        -168
    )

Scrolling.Position =
    UDim2.fromOffset(5, 133)

Scrolling.BackgroundTransparency = 1
Scrolling.BorderSizePixel = 0
Scrolling.ScrollBarThickness = 3
Scrolling.ScrollBarImageTransparency = 0.2

Scrolling.CanvasSize =
    UDim2.new()

Scrolling.AutomaticCanvasSize =
    Enum.AutomaticSize.Y

Scrolling.ZIndex = 2
Scrolling.Parent = Main

local Padding =
    Instance.new("UIPadding")

Padding.PaddingLeft =
    UDim.new(0, 2)

Padding.PaddingRight =
    UDim.new(0, 2)

Padding.PaddingTop =
    UDim.new(0, 2)

Padding.PaddingBottom =
    UDim.new(0, 2)

Padding.Parent = Scrolling

local Layout =
    Instance.new("UIListLayout")

Layout.Padding =
    UDim.new(0, 3)

Layout.SortOrder =
    Enum.SortOrder.LayoutOrder

Layout.Parent = Scrolling

--==================================================
-- BOTTOM BAR
--==================================================

local BottomBar =
    Instance.new("Frame")

BottomBar.Name = "BottomBar"

BottomBar.Size =
    UDim2.new(
        1,
        -10,
        0,
        26
    )

BottomBar.Position =
    UDim2.new(
        0,
        5,
        1,
        -30
    )

BottomBar.BackgroundTransparency = 1
BottomBar.ZIndex = 2
BottomBar.Parent = Main

local BottomLayout =
    Instance.new("UIListLayout")

BottomLayout.FillDirection =
    Enum.FillDirection.Horizontal

BottomLayout.HorizontalAlignment =
    Enum.HorizontalAlignment.Center

BottomLayout.VerticalAlignment =
    Enum.VerticalAlignment.Center

BottomLayout.Padding =
    UDim.new(0, 6)

BottomLayout.Parent = BottomBar

local RefreshButton =
    Instance.new("TextButton")

RefreshButton.Name =
    "RefreshButton"

RefreshButton.Size =
    UDim2.new(
        0.5,
        -3,
        1,
        0
    )

RefreshButton.BackgroundColor3 =
    Color3.fromRGB(
        60,
        120,
        200
    )

RefreshButton.BackgroundTransparency = 0.2
RefreshButton.BorderSizePixel = 0
RefreshButton.Text = "Refresh"

RefreshButton.TextColor3 =
    Color3.new(1, 1, 1)

RefreshButton.Font =
    Enum.Font.GothamBold

RefreshButton.TextSize = 9
RefreshButton.ZIndex = 2
RefreshButton.Parent = BottomBar

local RefreshCorner =
    Instance.new("UICorner")

RefreshCorner.CornerRadius =
    UDim.new(0, 5)

RefreshCorner.Parent =
    RefreshButton

local StealButton =
    Instance.new("TextButton")

StealButton.Name =
    "StealButton"

StealButton.Size =
    UDim2.new(
        0.5,
        -3,
        1,
        0
    )

StealButton.BackgroundColor3 =
    Color3.fromRGB(
        230,
        40,
        40
    )

StealButton.BackgroundTransparency = 0.2
StealButton.BorderSizePixel = 0
StealButton.Text = "Steal"

StealButton.TextColor3 =
    Color3.new(1, 1, 1)

StealButton.Font =
    Enum.Font.GothamBold

StealButton.TextSize = 9
StealButton.ZIndex = 2
StealButton.Parent = BottomBar

local StealCorner =
    Instance.new("UICorner")

StealCorner.CornerRadius =
    UDim.new(0, 5)

StealCorner.Parent =
    StealButton

--==================================================
-- UTILS & CALCULATIONS
--==================================================

local function FormatNumber(n)

    n = tonumber(n) or 0

    local suffixes = {
        "",
        "K",
        "M",
        "B",
        "T",
        "Qa",
        "Qi"
    }

    local index = 1

    while math.abs(n) >= 1000
        and index < #suffixes do

        n = n / 1000
        index += 1
    end

    if index == 1 then
        return string.format(
            "%.0f",
            n
        )
    end

    return string.format(
        "%.2f",
        n
    ) .. suffixes[index]
end

local function FormatMoney(n)
    return "$"
        .. FormatNumber(n)
        .. "/s"
end

local function FormatWeight(n)

    n = tonumber(n) or 0

    if n >= 1000 then
        return string.format(
            "%.0f Kg",
            n
        )
    end

    return string.format(
        "%.2f Kg",
        n
    )
end

local function GetIcon(icon)

    if icon == nil then
        return ""
    end

    local value =
        tostring(icon)

    if value == "" then
        return ""
    end

    if string.find(
        value,
        "rbxassetid://",
        1,
        true
    ) then

        return value
    end

    local id =
        string.match(
            value,
            "%d+"
        )

    if id then
        return "rbxassetid://" .. id
    end

    return value
end

local Directory =
    type(Assets) == "table"
    and Assets.Directory
    or nil

local function GetAsset(category)

    if type(Directory) ~= "table" then
        return nil
    end

    return Directory[
        tostring(category)
    ]
end

local function GetRarityInfo(category)

    local asset =
        GetAsset(category)

    if not asset
        or type(asset.Rarity) ~= "table" then

        return {
            Name = "Unknown",
            Number = 0
        }
    end

    local rarity =
        asset.Rarity

    return {
        Name = tostring(
            rarity.DisplayName
            or rarity._id
            or "Unknown"
        ),

        Number =
            tonumber(
                rarity.RarityNumber
                or rarity.Rank
                or 0
            )
            or 0
    }
end

local function MutationMultiplier(record)

    if type(Mutations) == "table"
        and type(Mutations.EarningsFor)
            == "function" then

        local ok, result =
            pcall(
                Mutations.EarningsFor,
                type(record.Mutations)
                    == "table"
                    and record.Mutations
                    or {}
            )

        if ok
            and type(result)
                == "number" then

            return result
        end
    end

    return 1
end

local function CalculateValue(
    record,
    asset
)

    if not asset then
        return 0
    end

    local scale =
        tonumber(
            record.AssetScale
        )
        or 1

    local scaleMultiplier =
        scale > 5
        and (
            (scale / 5) ^ 1.2
            * 19.637875755794113
        )
        or (
            scale ^ 1.85
        )

    return
        (
            tonumber(
                asset.EarningRate
            )
            or 0
        )
        * scaleMultiplier
        * MutationMultiplier(record)
end

local function GetWeight(
    category,
    scale
)

    if type(EggRecords)
        == "table"
        and type(
            EggRecords.WeightKgForScale
        ) == "function" then

        local ok, result =
            pcall(
                EggRecords.WeightKgForScale,
                category,
                scale
            )

        if ok
            and tonumber(result) then

            return tonumber(result)
        end
    end

    return 0
end

local function ReadEggs()

    if type(EggState)
        ~= "table"
        or type(
            EggState.ReadFieldEggs
        ) ~= "function" then

        return {}
    end

    local ok, result =
        pcall(
            EggState.ReadFieldEggs
        )

    if not ok
        or type(result)
            ~= "table"
        or type(result.Records)
            ~= "table" then

        return {}
    end

    return result.Records
end

local function BuildEggData()

    local records =
        ReadEggs()

    local output = {}

    for _, record in pairs(
        records
    ) do

        if type(record)
            == "table"
            and type(
                record.AssetCategory
            ) == "string" then

            local category =
                record.AssetCategory

            local asset =
                GetAsset(category)

            if asset then

                local rarity =
                    GetRarityInfo(
                        category
                    )

                local scale =
                    tonumber(
                        record.AssetScale
                    )
                    or 1

                table.insert(
                    output,
                    {
                        Record = record,

                        Uid = tostring(
                            record.Uid
                            or ""
                        ),

                        Category =
                            category,

                        Name =
                            tostring(
                                asset.DisplayName
                                or category
                            ),

                        Icon =
                            GetIcon(
                                asset.Icon
                            ),

                        Rarity =
                            rarity.Name,

                        RarityNumber =
                            rarity.Number,

                        Value =
                            CalculateValue(
                                record,
                                asset
                            ),

                        Weight =
                            GetWeight(
                                category,
                                scale
                            ),

                        Scale = scale,

                        Mutation =
                            tostring(
                                record.BaseMutation
                                or ""
                            )
                    }
                )
            end
        end
    end

    return output
end

local function SortEggs(list)

    table.sort(
        list,
        function(a, b)

            if SortMode == "Value" then

                return a.Value >
                    b.Value

            elseif SortMode == "Rarity" then

                return
                    a.RarityNumber
                    ~= b.RarityNumber
                    and
                    a.RarityNumber
                    >
                    b.RarityNumber
                    or
                    a.Name < b.Name

            elseif SortMode == "Weight" then

                return a.Weight >
                    b.Weight
            end

            return a.Value >
                b.Value
        end
    )
end

--==================================================
-- EGG CARDS
--==================================================

local Cards = {}

-- Movement cancellation state. Incremented whenever an Egg selection changes.
local StealSelectionToken = 0
local StealRunning = false
local StealRunId = 0

local function CreateEggCard(
    data,
    index
)

    local Card =
        Instance.new("Frame")

    Card.Name =
        "Egg_" .. index

    Card.Size =
        UDim2.new(
            1,
            -4,
            0,
            52
        )

    Card.BackgroundColor3 =
        Color3.fromRGB(
            48,
            48,
            54
        )

    Card.BackgroundTransparency = 0.3
    Card.BorderSizePixel = 0
    Card.LayoutOrder = index
    Card.ZIndex = 2
    Card.Parent = Scrolling

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(0, 6)

    Corner.Parent = Card

    local Stroke =
        Instance.new("UIStroke")

    Stroke.Thickness = 1

    Stroke.Color =
        Color3.fromRGB(
            90,
            90,
            100
        )

    Stroke.Transparency = 0.3
    Stroke.Parent = Card

    local CheckBox =
        Instance.new("TextButton")

    CheckBox.Name =
        "CheckBox"

    CheckBox.Size =
        UDim2.fromOffset(
            20,
            20
        )

    CheckBox.Position =
        UDim2.fromOffset(
            5,
            16
        )

    CheckBox.BackgroundColor3 =
        Color3.fromRGB(
            60,
            60,
            70
        )

    CheckBox.BackgroundTransparency = 0.2
    CheckBox.BorderSizePixel = 0
    CheckBox.Text = ""
    CheckBox.AutoButtonColor = true
    CheckBox.ZIndex = 3
    CheckBox.Parent = Card

    local BoxCorner =
        Instance.new("UICorner")

    BoxCorner.CornerRadius =
        UDim.new(0, 4)

    BoxCorner.Parent =
        CheckBox

    local BoxStroke =
        Instance.new("UIStroke")

    BoxStroke.Thickness = 1

    BoxStroke.Color =
        Color3.fromRGB(
            90,
            90,
            100
        )

    BoxStroke.Parent =
        CheckBox

    local CheckLabel =
        Instance.new("TextLabel")

    CheckLabel.Name =
        "CheckMark"

    CheckLabel.Size =
        UDim2.new(1, 0, 1, 0)

    CheckLabel.BackgroundTransparency = 1
    CheckLabel.Text = ""

    CheckLabel.TextColor3 =
        Color3.fromRGB(
            80,
            255,
            90
        )

    CheckLabel.Font =
        Enum.Font.GothamBold

    CheckLabel.TextSize = 14
    CheckLabel.ZIndex = 3
    CheckLabel.Parent = CheckBox

    local isChecked = false

    CheckBox.Activated:Connect(
        function()

            isChecked =
                not isChecked

            -- Any selection change invalidates the current Steal target.
            StealSelectionToken =
                StealSelectionToken + 1

            if not isChecked and StealRunning then
                StealRunning = false
            end

            if isChecked then

                CheckLabel.Text = "✓"

                CheckBox.BackgroundColor3 =
                    Color3.fromRGB(
                        40,
                        120,
                        50
                    )

            else

                CheckLabel.Text = ""

                CheckBox.BackgroundColor3 =
                    Color3.fromRGB(
                        60,
                        60,
                        70
                    )
            end

            if Cards[index] then
                Cards[index].IsSelected =
                    isChecked
            end
        end
    )

    local Icon =
        Instance.new("ImageLabel")

    Icon.Name = "EggIcon"

    Icon.Size =
        UDim2.fromOffset(
            38,
            38
        )

    Icon.Position =
        UDim2.fromOffset(
            28,
            7
        )

    Icon.BackgroundTransparency = 1

    Icon.ScaleType =
        Enum.ScaleType.Fit

    Icon.ZIndex = 3
    Icon.Parent = Card

    local Name =
        Instance.new("TextLabel")

    Name.Name = "Name"

    Name.Size =
        UDim2.new(
            1,
            -125,
            0,
            14
        )

    Name.Position =
        UDim2.fromOffset(
            70,
            4
        )

    Name.BackgroundTransparency = 1
    Name.TextColor3 =
        Color3.new(1, 1, 1)

    Name.Font =
        Enum.Font.GothamBold

    Name.TextSize = 10

    Name.TextXAlignment =
        Enum.TextXAlignment.Left

    Name.TextTruncate =
        Enum.TextTruncate.AtEnd

    Name.ZIndex = 3
    Name.Parent = Card

    local Rarity =
        Instance.new("TextLabel")

    Rarity.Name = "Rarity"

    Rarity.Size =
        UDim2.new(
            1,
            -125,
            0,
            12
        )

    Rarity.Position =
        UDim2.fromOffset(
            70,
            17
        )

    Rarity.BackgroundTransparency = 1

    -- Rarity color is driven by the actual rarity.
    -- This keeps the pet/egg card color identical to
    -- the rarity filter palette above.
    Rarity.TextColor3 =
        GetRarityColor(
            data.Rarity
        )

    -- Secret is intentionally black.  A small white
    -- stroke keeps black text readable over dark cards
    -- without changing the actual rarity color.
    if string.lower(
        tostring(data.Rarity or "")
    ) == "secret" then

        Rarity.TextStrokeColor3 =
            Color3.new(1, 1, 1)

        Rarity.TextStrokeTransparency = 0.35

    else

        Rarity.TextStrokeTransparency = 1
    end

    Rarity.Font =
        Enum.Font.GothamBold

    Rarity.TextSize = 7

    Rarity.TextXAlignment =
        Enum.TextXAlignment.Left

    Rarity.ZIndex = 3
    Rarity.Parent = Card

    local Value =
        Instance.new("TextLabel")

    Value.Name = "Value"

    Value.Size =
        UDim2.new(
            1,
            -125,
            0,
            12
        )

    Value.Position =
        UDim2.fromOffset(
            70,
            29
        )

    Value.BackgroundTransparency = 1

    Value.TextColor3 =
        Color3.fromRGB(
            80,
            255,
            90
        )

    Value.Font =
        Enum.Font.GothamBold

    Value.TextSize = 7

    Value.TextXAlignment =
        Enum.TextXAlignment.Left

    Value.ZIndex = 3
    Value.Parent = Card

    local Weight =
        Instance.new("TextLabel")

    Weight.Name = "Weight"

    Weight.Size =
        UDim2.fromOffset(
            60,
            13
        )

    Weight.Position =
        UDim2.new(
            1,
            -65,
            0,
            15
        )

    Weight.BackgroundTransparency = 1

    Weight.TextColor3 =
        Color3.fromRGB(
            80,
            180,
            255
        )

    Weight.Font =
        Enum.Font.GothamBold

    Weight.TextSize = 7

    Weight.TextXAlignment =
        Enum.TextXAlignment.Right

    Weight.ZIndex = 3
    Weight.Parent = Card

    local Scale =
        Instance.new("TextLabel")

    Scale.Name = "Scale"

    Scale.Size =
        UDim2.fromOffset(
            60,
            12
        )

    Scale.Position =
        UDim2.new(
            1,
            -65,
            0,
            28
        )

    Scale.BackgroundTransparency = 1

    Scale.TextColor3 =
        Color3.fromRGB(
            180,
            180,
            190
        )

    Scale.Font =
        Enum.Font.Gotham

    Scale.TextSize = 7

    Scale.TextXAlignment =
        Enum.TextXAlignment.Right

    Scale.ZIndex = 3
    Scale.Parent = Card

    local Mutation =
        Instance.new("TextLabel")

    Mutation.Name = "Mutation"

    Mutation.Size =
        UDim2.new(
            1,
            -125,
            0,
            10
        )

    Mutation.Position =
        UDim2.fromOffset(
            70,
            41
        )

    Mutation.BackgroundTransparency = 1

    Mutation.TextColor3 =
        Color3.fromRGB(
            255,
            180,
            80
        )

    Mutation.Font =
        Enum.Font.GothamBold

    Mutation.TextSize = 6

    Mutation.TextXAlignment =
        Enum.TextXAlignment.Left

    Mutation.ZIndex = 3
    Mutation.Parent = Card

    Cards[index] = {

        Frame = Card,

        CheckBox = CheckBox,

        CheckLabel = CheckLabel,

        Icon = Icon,

        Name = Name,

        Rarity = Rarity,

        Value = Value,

        Weight = Weight,

        Scale = Scale,

        Mutation = Mutation,

        RarityStroke = Stroke,

        BoxStroke = BoxStroke,

        BaseX = 28,

        BaseY = 7,

        Phase =
            (index % 10)
            * 0.35,

        CurrentData = nil,

        IsSelected = false
    }

    return Cards[index]
end

local function UpdateCard(
    card,
    data,
    index
)

    card.Frame.LayoutOrder =
        index

    card.Icon.Image =
        data.Icon or ""

    card.Name.Text =
        data.Name

    card.Rarity.Text =
        string.upper(
            NormalizeRarity(data.Rarity)
        )

    -- Always re-apply the rarity visuals on every refresh.
    -- Cards are reused by index, so without this a Secret card could
    -- keep the previous card's Divine/Eternal/etc. color.
    ApplyRarityCardTheme(
        card,
        data.Rarity
    )

    card.Value.Text =
        FormatMoney(
            data.Value
        )

    card.Weight.Text =
        FormatWeight(
            data.Weight
        )

    card.Scale.Text =
        string.format(
            "x%.2f",
            data.Scale
        )

    card.Mutation.Text =
        data.Mutation ~= ""
        and string.upper(
            data.Mutation
        )
        or ""

    card.CurrentData =
        data
end

local function MatchesFilter(data)

    if SelectedRarity == "All" then
        return true
    end

    if not data then
        return false
    end

    return
        NormalizeRarity(data.Rarity)
        ==
        NormalizeRarity(SelectedRarity)
end

local function UpdateFilterButtons()

    for rarity, button in pairs(
        RarityButtons
    ) do

        button.BackgroundColor3 =
            (
                rarity
                == SelectedRarity
            )
            and GetRarityColor(
                rarity
            )
            or Color3.fromRGB(
                52,
                52,
                60
            )

        button.TextColor3 =
            (
                rarity
                == SelectedRarity
            )
            and Color3.new(
                1,
                1,
                1
            )
            or Color3.fromRGB(
                205,
                205,
                210
            )
    end
end

local function UpdateSortButtons()

    for mode, button in pairs(
        SortButtons
    ) do

        button.BackgroundColor3 =
            (
                mode
                == SortMode
            )
            and Color3.fromRGB(
                230,
                40,
                40
            )
            or Color3.fromRGB(
                52,
                52,
                60
            )

        button.TextColor3 =
            (
                mode
                == SortMode
            )
            and Color3.new(
                1,
                1,
                1
            )
            or Color3.fromRGB(
                205,
                205,
                210
            )
    end
end

local CurrentTab = "Egg"

local function ApplyFilter()

    for _, card in pairs(
        Cards
    ) do

        card.Frame.Visible =
            (
                CurrentTab ~= "Visual"
                and card.CurrentData
                and MatchesFilter(
                    card.CurrentData
                )
            )
            and true
            or false
    end
end

for rarity, button in pairs(
    RarityButtons
) do

    button.Activated:Connect(
        function()

            SelectedRarity =
                rarity

            UpdateFilterButtons()
            ApplyFilter()
        end
    )
end

for mode, button in pairs(
    SortButtons
) do

    button.Activated:Connect(
        function()

            SortMode = mode

            UpdateSortButtons()

            Refresh()
        end
    )
end

--==================================================
-- TAB SWITCHING
--==================================================

EggTabButton.Activated:Connect(
    function()

        CurrentTab = "Egg"

        EggTabButton.BackgroundColor3 =
            Color3.fromRGB(
                230,
                40,
                40
            )

        EggTabButton.TextColor3 =
            Color3.new(1, 1, 1)

        VisualTabButton.BackgroundColor3 =
            Color3.fromRGB(
                52,
                52,
                60
            )

        VisualTabButton.TextColor3 =
            Color3.fromRGB(
                205,
                205,
                210
            )

        SortBar.Visible = true
        RarityBar.Visible = true
        Scrolling.Visible = true
        BottomBar.Visible = true
        VisualContainer.Visible = false

        ApplyFilter()
    end
)

VisualTabButton.Activated:Connect(
    function()

        CurrentTab = "Visual"

        VisualTabButton.BackgroundColor3 =
            Color3.fromRGB(
                230,
                40,
                40
            )

        VisualTabButton.TextColor3 =
            Color3.new(1, 1, 1)

        EggTabButton.BackgroundColor3 =
            Color3.fromRGB(
                52,
                52,
                60
            )

        EggTabButton.TextColor3 =
            Color3.fromRGB(
                205,
                205,
                210
            )

        SortBar.Visible = false
        RarityBar.Visible = false
        Scrolling.Visible = false
        BottomBar.Visible = false
        VisualContainer.Visible = true

        ApplyFilter()
    end
)

--==================================================
-- REFRESH
--==================================================

local Refreshing = false

function Refresh()

    if Refreshing then
        return
    end

    Refreshing = true

    -- IMPORTANT:
    -- Preserve selection by Egg UID,
    -- not by card index.

    local selectedUids = {}

    for _, card in ipairs(
        Cards
    ) do

        if card.IsSelected
            and card.CurrentData then

            local uid =
                tostring(
                    card.CurrentData.Uid
                    or ""
                )

            if uid ~= "" then
                selectedUids[uid] = true
            end
        end
    end

    local newData =
        BuildEggData()

    SortEggs(newData)

    for index, data in ipairs(
        newData
    ) do

        local card =
            Cards[index]

        if not card then

            card =
                CreateEggCard(
                    data,
                    index
                )
        end

        UpdateCard(
            card,
            data,
            index
        )

        local uid =
            tostring(
                data.Uid
                or ""
            )

        local selected =
            selectedUids[uid]
            == true

        card.IsSelected =
            selected

        if card.CheckLabel then

            card.CheckLabel.Text =
                selected
                and "✓"
                or ""
        end

        if card.CheckBox then

            card.CheckBox.BackgroundColor3 =
                selected

                and Color3.fromRGB(
                    40,
                    120,
                    50
                )

                or Color3.fromRGB(
                    60,
                    60,
                    70
                )
        end

        card.Frame.Visible =
            CurrentTab ~= "Visual"
            and MatchesFilter(
                data
            )
    end

    for index =
        #newData + 1,
        #Cards do

        if Cards[index] then

            Cards[index].Frame.Visible =
                false

            Cards[index].CurrentData =
                nil

            Cards[index].IsSelected =
                false

            if Cards[index].CheckLabel then

                Cards[index].CheckLabel.Text =
                    ""
            end

            if Cards[index].CheckBox then

                Cards[index].CheckBox.BackgroundColor3 =
                    Color3.fromRGB(
                        60,
                        60,
                        70
                    )
            end
        end
    end

    Refreshing = false
end

RefreshButton.Activated:Connect(
    Refresh
)

--==================================================
--==================================================
-- STEAL / MOVEMENT LOGIC
-- ONE CLICK + DIRECT EGG MOVEMENT
--==================================================

local StealRunning = false

-- Distansya kung saan titigil sa Egg.
local StealStopDistance = 2.75

-- Movement uses the game's CURRENT Humanoid.WalkSpeed.
-- WalkSpeed is never changed by this script.

-- Gaano kadalas mag-check ng live Egg position.
local StealUpdateRate = 0.02

--==================================================
-- CHARACTER
--==================================================

local function GetCharacterParts()

    local character =
        LocalPlayer.Character

    if not character
        or not character.Parent then

        return nil, nil, nil
    end

    local humanoid =
        character:FindFirstChildOfClass(
            "Humanoid"
        )

    local rootPart =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not humanoid
        or not rootPart
        or humanoid.Health <= 0 then

        return nil, nil, nil
    end

    return character,
        humanoid,
        rootPart
end

--==================================================
-- OBJECT POSITION
--==================================================

local function GetObjectPosition(
    object
)

    if not object then
        return nil
    end

    local ok, position =
        pcall(
            function()

                if object:IsA(
                    "BasePart"
                ) then

                    return object.Position
                end

                if object:IsA(
                    "Model"
                ) then

                    return object:
                        GetPivot()
                        .Position
                end

                local part =
                    object:
                    FindFirstChildWhichIsA(
                        "BasePart",
                        true
                    )

                if part then
                    return part.Position
                end

                return nil
            end
        )

    if ok
        and typeof(position)
            == "Vector3" then

        return position
    end

    return nil
end

--==================================================
-- FIND THE ACTUAL EGG OBJECT
--==================================================

local function FindEggObject(
    target
)

    if not target then
        return nil
    end

    local data =
        target.Data
        or target.CurrentData
        or target

    local record =
        data
        and data.Record

    if not record then
        return nil
    end

    local directObjects = {
        record.Model,
        record.Part,
        record.Instance,
        record.Object,
        record.Egg,
        record.Root,
        record.RootPart
    }

    for _, object in ipairs(
        directObjects
    ) do

        if object
            and object.Parent then

            if GetObjectPosition(
                object
            ) then

                return object
            end
        end
    end

    local uid =
        tostring(
            data.Uid
            or ""
        )

    --==================================================
    -- EXACT UID LOOKUP
    --==================================================

    if uid ~= "" then

        local ok, object =
            pcall(
                function()

                    return workspace:
                        FindFirstChild(
                            uid,
                            true
                        )
                end
            )

        if ok
            and object
            and GetObjectPosition(
                object
            ) then

            return object
        end
    end

    --==================================================
    -- UID / ATTRIBUTE SCAN
    --==================================================

    if uid ~= "" then

        local found = nil

        pcall(
            function()

                for _, object in ipairs(
                    workspace:GetDescendants()
                ) do

                    if object.Name == uid
                        and GetObjectPosition(
                            object
                        ) then

                        found = object
                        break
                    end

                    local objectUid

                    pcall(
                        function()

                            objectUid =
                                object:GetAttribute(
                                    "Uid"
                                )

                            if objectUid == nil then

                                objectUid =
                                    object:GetAttribute(
                                        "UID"
                                    )
                            end

                            if objectUid == nil then

                                objectUid =
                                    object:GetAttribute(
                                        "EggUid"
                                    )
                            end
                        end
                    )

                    if objectUid ~= nil
                        and tostring(
                            objectUid
                        ) == uid
                        and GetObjectPosition(
                            object
                        ) then

                        found = object
                        break
                    end
                end
            end
        )

        if found then
            return found
        end
    end

    return nil
end

--==================================================
-- FALLBACK EGG POSITION
--==================================================

local function GetEggTargetPosition(
    target
)

    local object =
        FindEggObject(
            target
        )

    if object then

        local position =
            GetObjectPosition(
                object
            )

        if position then
            return position
        end
    end

    local data =
        target
        and (
            target.Data
            or target.CurrentData
            or target
        )

    local record =
        data
        and data.Record

    if record
        and type(
            record.GetPosition
        )
        == "function" then

        local ok, position =
            pcall(
                function()

                    return record:
                        GetPosition()
                end
            )

        if ok then

            if typeof(position)
                == "Vector3" then

                return position

            elseif typeof(position)
                == "CFrame" then

                return position.Position
            end
        end
    end

    return nil
end

--==================================================
-- INSTANT EGG PICKUP
--==================================================

local Workspace = game:GetService("Workspace")

-- Every CarryAreaEgg is instant when the player manually taps it.
-- This does NOT automatically collect every egg.
local function SetupEggPrompt(obj)
    if obj
        and obj:IsA("ProximityPrompt")
        and obj.Name == "CarryAreaEgg" then

        pcall(function()
            obj.HoldDuration = 0
            -- Do not require the camera/crosshair to be looking at the prompt.
            obj.RequiresLineOfSight = false
            obj.Enabled = true
        end)
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    SetupEggPrompt(obj)
end

Workspace.DescendantAdded:Connect(function(obj)
    SetupEggPrompt(obj)
end)

--==================================================
-- SELECTED EGG -> EXACT PROMPT ONLY
--==================================================
-- The game can have MANY "Egg Steal" prompts on screen at once.
-- Therefore we NEVER choose an Egg just because it is nearby.
-- We first bind the prompt to the SAME physical Egg using UID/name/
-- hierarchy, and only use distance as a final guarded fallback.

local function GetPromptWorldPosition(prompt)
    if not prompt or not prompt.Parent then
        return nil
    end

    local parent = prompt.Parent

    if parent:IsA("BasePart") then
        return parent.Position
    end

    if parent:IsA("Attachment") and parent.Parent then
        if parent.Parent:IsA("BasePart") then
            return parent.Parent.Position
        end
    end

    return GetObjectPosition(parent)
end

local function IsCarryPrompt(obj)
    return obj
        and obj.Parent
        and obj:IsA("ProximityPrompt")
        and obj.Name == "CarryAreaEgg"
        and obj.Enabled
end

local function GetSelectedEggUid(targetObject)
    if not targetObject then
        return ""
    end

    local target = targetObject
    local data = nil

    -- targetObject is normally the physical Egg object, but keep the
    -- record available when the caller passed the data table instead.
    if type(targetObject) == "table" then
        data = targetObject.Data
            or targetObject.CurrentData
            or targetObject
    end

    if type(data) == "table" then
        local uid = data.Uid
        if uid ~= nil and tostring(uid) ~= "" then
            return tostring(uid)
        end

        local record = data.Record
        if type(record) == "table" and record.Uid ~= nil then
            return tostring(record.Uid)
        end
    end

    -- Physical Egg attributes.
    local uid
    pcall(function()
        uid = target:GetAttribute("Uid")
        if uid == nil then uid = target:GetAttribute("UID") end
        if uid == nil then uid = target:GetAttribute("EggUid") end
        if uid == nil then uid = target:GetAttribute("EggUID") end
    end)

    return uid ~= nil and tostring(uid) or ""
end

local function GetTargetDataUid(targetObject)
    -- targetObject may actually be the data wrapper in our movement code.
    if type(targetObject) ~= "table" then
        return GetSelectedEggUid(targetObject)
    end

    local data = targetObject.Data
        or targetObject.CurrentData
        or targetObject

    if type(data) ~= "table" then
        return ""
    end

    local uid = data.Uid
    if uid == nil and type(data.Record) == "table" then
        uid = data.Record.Uid
    end

    return uid ~= nil and tostring(uid) or ""
end

local function ReadObjectUid(object)
    if not object then
        return ""
    end

    local uid
    pcall(function()
        uid = object:GetAttribute("Uid")
        if uid == nil then uid = object:GetAttribute("UID") end
        if uid == nil then uid = object:GetAttribute("EggUid") end
        if uid == nil then uid = object:GetAttribute("EggUID") end
    end)

    return uid ~= nil and tostring(uid) or ""
end

local function HasUidInAncestry(instance, uid)
    if not instance or uid == "" then
        return false
    end

    local current = instance
    while current and current ~= Workspace do
        if current.Name == uid then
            return true
        end

        if ReadObjectUid(current) == uid then
            return true
        end

        current = current.Parent
    end

    return false
end

local function IsInsideOrSameTree(a, b)
    if not a or not b then
        return false
    end

    if a == b then
        return true
    end

    local ok = false
    pcall(function()
        ok = a:IsDescendantOf(b) or b:IsDescendantOf(a)
    end)
    return ok
end

local function FindSelectedEggPrompt(targetObject, targetPosition)
    local selectedUid = GetTargetDataUid(targetObject)
    local candidates = {}

    local function add(prompt, score)
        if not IsCarryPrompt(prompt) then
            return
        end

        local pos = GetPromptWorldPosition(prompt)
        if not pos then
            return
        end

        table.insert(candidates, {
            Prompt = prompt,
            Score = score,
            Distance = targetPosition
                and (pos - targetPosition).Magnitude
                or math.huge
        })
    end

    --==================================================
    -- 1. PROMPT INSIDE THE EXACT PHYSICAL EGG
    --==================================================
    if targetObject and typeof(targetObject) ~= "table" then
        add(targetObject, 100000)

        for _, obj in ipairs(targetObject:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                add(obj, 100000)
            end
        end
    end

    --==================================================
    -- 2. UID MATCH: THE MOST IMPORTANT CHECK
    --==================================================
    -- This prevents another nearby "Egg Steal" prompt from being chosen.
    if selectedUid ~= "" then
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if IsCarryPrompt(prompt) then
                if HasUidInAncestry(prompt, selectedUid) then
                    add(prompt, 90000)
                end
            end
        end
    end

    --==================================================
    -- 3. SAME PHYSICAL TREE AS THE SELECTED EGG
    --==================================================
    if targetObject and typeof(targetObject) ~= "table" then
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if IsCarryPrompt(prompt) then
                if IsInsideOrSameTree(prompt, targetObject) then
                    add(prompt, 80000)
                end
            end
        end
    end

    --==================================================
    -- 4. PROMPT ON THE SAME PARENT/ROOT AS THE SELECTED EGG
    --==================================================
    if targetObject and typeof(targetObject) ~= "table" then
        local targetParent = targetObject.Parent
        if targetParent then
            for _, prompt in ipairs(targetParent:GetDescendants()) do
                if IsCarryPrompt(prompt) then
                    add(prompt, 70000)
                end
            end
        end
    end

    --==================================================
    -- 5. SELECTED-EGG POSITION MATCH (NO CAMERA REQUIRED)
    --==================================================
    -- If the game's prompt is stored beside the Egg instead of inside
    -- its model, identity/hierarchy matching above may not find it.
    -- In that case, match the prompt to the SELECTED EGG'S own world
    -- position, never to the camera and never to the player's facing.
    -- This is intentionally allowed even when several Egg Steal prompts
    -- are nearby: the closest prompt to the selected Egg wins.
    if #candidates == 0 and targetPosition then
        local nearest = nil
        local nearestDistance = math.huge

        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if IsCarryPrompt(prompt) then
                local pos = GetPromptWorldPosition(prompt)
                if pos then
                    local distance = (pos - targetPosition).Magnitude
                    if distance <= 6 and distance < nearestDistance then
                        nearestDistance = distance
                        nearest = prompt
                    end
                end
            end
        end

        if nearest then
            add(nearest, 50000 - nearestDistance)
        end
    end

    if #candidates == 0 then
        return nil
    end

    table.sort(candidates, function(a, b)
        if a.Score ~= b.Score then
            return a.Score > b.Score
        end
        return a.Distance < b.Distance
    end)

    return candidates[1].Prompt
end

--==================================================
-- RELIABLE EXACT-PROMPT TRIGGER
--==================================================
-- Re-resolve the SAME selected Egg while the player is in pickup range.
-- We never cycle through other Eggs just because the first prompt missed.

local function TriggerEggPrompt(prompt)
    if not IsCarryPrompt(prompt) then
        return false
    end

    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
    end)

    -- Prefer the executor's direct ProximityPrompt trigger when available.
    -- This does not depend on the camera/crosshair being over the prompt.
    if type(fireproximityprompt) == "function" then
        local directOk = pcall(function()
            fireproximityprompt(prompt)
        end)
        if directOk then
            return true
        end
    end

    -- Native fallback.
    local ok = pcall(function()
        prompt:InputHoldBegin()
        task.defer(function()
            if prompt and prompt.Parent then
                pcall(function()
                    prompt:InputHoldEnd()
                end)
            end
        end)
    end)

    return ok
end

local function CollectSelectedEgg(targetObject, targetPosition)
    local deadline = os.clock() + 0.45
    local lastPrompt = nil

    while os.clock() < deadline do
        local prompt = FindSelectedEggPrompt(
            targetObject,
            targetPosition
        )

        if prompt then
            lastPrompt = prompt

            -- Multiple short attempts against the SAME selected Egg.
            TriggerEggPrompt(prompt)
            task.wait(0.025)

            -- If the selected prompt disappears or is disabled, the game
            -- has accepted the pickup.
            if not prompt.Parent or not prompt.Enabled then
                return true
            end
        end

        task.wait(0.025)
    end

    -- Final attempt, still only against the selected Egg.
    if lastPrompt and lastPrompt.Parent and lastPrompt.Enabled then
        TriggerEggPrompt(lastPrompt)
    end

    return lastPrompt ~= nil
end

--==================================================
-- HARD STOP
--==================================================

local function HardStopCharacter(
    humanoid,
    rootPart
)

    if not humanoid
        or not rootPart then

        return
    end

    pcall(
        function()

            humanoid:Move(
                Vector3.zero,
                false
            )
        end
    )

    pcall(
        function()

            humanoid:MoveTo(
                rootPart.Position
            )
        end
    )

    pcall(
        function()

            rootPart.AssemblyLinearVelocity =
                Vector3.zero

            rootPart.AssemblyAngularVelocity =
                Vector3.zero
        end
    )
end

--==================================================
-- MOVE DIRECTLY TO ONE SELECTED EGG
--==================================================

local function MoveToEgg(
    target,
    selectionToken
)

    local character,
        humanoid,
        rootPart =
        GetCharacterParts()

    if not character then
        return false
    end

    -- Resolve the selected Egg once.
    local targetObject =
        FindEggObject(
            target
        )

    local targetPosition

    if targetObject then
        targetPosition =
            GetObjectPosition(
                targetObject
            )
    end

    if not targetPosition then
        targetPosition =
            GetEggTargetPosition(
                target
            )
    end

    if not targetPosition then
        warn(
            "[MochiClub Steal] Could not find selected Egg position"
        )
        return false
    end

    local lastUpdate = 0

    while StealRunning
        and selectionToken == StealSelectionToken do

        character,
        humanoid,
        rootPart =
            GetCharacterParts()

        if not character then
            return false
        end

        -- If the Egg was cancelled/unselected, immediately stop.
        if selectionToken ~= StealSelectionToken then
            break
        end

        -- Always use the live position of the SAME selected Egg.
        if targetObject
            and targetObject.Parent then

            local livePosition =
                GetObjectPosition(
                    targetObject
                )

            if livePosition then
                targetPosition =
                    livePosition
            end
        end

        local targetXZ =
            Vector3.new(
                targetPosition.X,
                rootPart.Position.Y,
                targetPosition.Z
            )

        local current =
            Vector3.new(
                rootPart.Position.X,
                rootPart.Position.Y,
                rootPart.Position.Z
            )

        local offset =
            targetXZ
            - current

        local distance =
            offset.Magnitude

        --==================================================
        -- EXACT STOP
        --==================================================

        if distance <=
            StealStopDistance then

            -- We have reached the selected Egg.
            -- Automatically collect it now; no tap/click is required.
            HardStopCharacter(
                humanoid,
                rootPart
            )

            CollectSelectedEgg(
                targetObject,
                targetPosition
            )

            return true
        end

        --==================================================
        -- PHYSICS MOVEMENT AT REAL GAME SPEED
        --==================================================

        local now =
            os.clock()

        if now - lastUpdate
            >= StealUpdateRate then

            local direction =
                offset.Unit

            -- Read the real game WalkSpeed every update so any
            -- game speed modifier is respected automatically.
            local gameSpeed = 0

            pcall(
                function()
                    gameSpeed =
                        math.max(
                            tonumber(
                                humanoid.WalkSpeed
                            )
                            or 0,
                            0
                        )
                end
            )

            if gameSpeed > 0 then

                local currentVelocity =
                    rootPart.AssemblyLinearVelocity

                -- Move through physics at the current game speed.
                -- This does NOT set CFrame and does NOT change WalkSpeed.
                pcall(
                    function()

                        rootPart.AssemblyLinearVelocity =
                            Vector3.new(
                                direction.X
                                    * gameSpeed,
                                currentVelocity.Y,
                                direction.Z
                                    * gameSpeed
                            )

                        rootPart.AssemblyAngularVelocity =
                            Vector3.zero
                    end
                )
            end

            lastUpdate = now
        end

        RunService.Heartbeat:Wait()
    end

    -- Cancellation: immediately release our movement control.
    -- The game's own WalkSpeed remains untouched.
    HardStopCharacter(
        humanoid,
        rootPart
    )

    return false
end

--==================================================
-- STEAL BUTTON
-- ONE CLICK = RUN ALL SELECTED EGGS
--==================================================

StealButton.Activated:Connect(
    function()

        if StealRunning then
            return
        end

        local selectedEggs = {}

        for _, card in ipairs(
            Cards
        ) do

            if card.IsSelected
                and card.CurrentData
                and card.CurrentData.Record then

                table.insert(
                    selectedEggs,
                    {
                        Data =
                            card.CurrentData,

                        Uid =
                            tostring(
                                card.CurrentData.Uid
                                or ""
                            ),

                        Category =
                            tostring(
                                card.CurrentData.Category
                                or ""
                            )
                    }
                )
            end
        end

        if #selectedEggs == 0 then
            return
        end

        -- Snapshot the current selection state. If the user cancels
        -- the selected Egg, this token changes and this run dies immediately.
        local selectionToken =
            StealSelectionToken

        StealRunId =
            StealRunId + 1

        local thisRunId =
            StealRunId

        StealRunning = true

        StealButton.Text =
            "Stealing..."

        task.spawn(
            function()

                local ok, err =
                    pcall(
                        function()

                            for _, target in ipairs(
                                selectedEggs
                            ) do

                                if not StealRunning
                                    or selectionToken ~= StealSelectionToken then
                                    break
                                end

                                local reached =
                                    MoveToEgg(
                                        target,
                                        selectionToken
                                    )

                                if not reached then
                                    break
                                end
                            end
                        end
                    )

                if not ok then

                    warn(
                        "[MochiClub Steal] "
                        .. tostring(err)
                    )
                end

                local character,
                    humanoid,
                    rootPart =
                    GetCharacterParts()

                if thisRunId == StealRunId then
                    HardStopCharacter(
                        humanoid,
                        rootPart
                    )
                end

                if thisRunId == StealRunId then
                    StealRunning = false
                end

                if thisRunId == StealRunId
                    and StealButton
                    and StealButton.Parent then

                    StealButton.Text =
                        "Steal"
                end
            end
        )
    end
)

-- TOGGLE UI
--==================================================

local uiVisible = true

ToggleButton.Activated:Connect(
    function()

        uiVisible =
            not uiVisible

        Main.Visible =
            uiVisible
    end
)

--==================================================
-- DRAGGING FOR MAIN
--==================================================

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            dragging = true

            dragStart =
                input.Position

            startPosition =
                Main.Position

            input.Changed:Connect(
                function()

                    if input.UserInputState ==
                        Enum.UserInputState.End then

                        dragging = false
                    end
                end
            )
        end
    end
)

UserInputService.InputChanged:Connect(
    function(input)

        if not dragging then
            return
        end

        if input.UserInputType ~=
            Enum.UserInputType.MouseMovement
            and input.UserInputType ~=
            Enum.UserInputType.Touch then

            return
        end

        local delta =
            input.Position
            - dragStart

        Main.Position =
            UDim2.new(
                startPosition.X.Scale,

                startPosition.X.Offset
                    + delta.X,

                startPosition.Y.Scale,

                startPosition.Y.Offset
                    + delta.Y
            )
    end
)

--==================================================
-- DRAGGING FOR TOGGLE BUTTON
--==================================================

local toggleDragging = false
local toggleDragStart
local toggleStartPosition

ToggleButton.InputBegan:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            toggleDragging = true

            toggleDragStart =
                input.Position

            toggleStartPosition =
                ToggleButton.Position

            input.Changed:Connect(
                function()

                    if input.UserInputState ==
                        Enum.UserInputState.End then

                        toggleDragging = false
                    end
                end
            )
        end
    end
)

UserInputService.InputChanged:Connect(
    function(input)

        if not toggleDragging then
            return
        end

        if input.UserInputType ~=
            Enum.UserInputType.MouseMovement
            and input.UserInputType ~=
            Enum.UserInputType.Touch then

            return
        end

        local delta =
            input.Position
            - toggleDragStart

        ToggleButton.Position =
            UDim2.new(
                toggleStartPosition.X.Scale,

                toggleStartPosition.X.Offset
                    + delta.X,

                toggleStartPosition.Y.Scale,

                toggleStartPosition.Y.Offset
                    + delta.Y
            )
    end
)

--==================================================
-- EGG ICON ANIMATION
--==================================================

task.spawn(function()
    while ScreenGui.Parent do
        if CurrentTab ~= "Visual" then
            local t = os.clock()

            for _, card in ipairs(Cards) do
                if card.Frame.Visible
                    and card.Icon.Visible
                    and card.Icon.Image ~= "" then

                    local wave = math.sin(t * 2 + card.Phase)

                    card.Icon.Position = UDim2.fromOffset(
                        card.BaseX,
                        card.BaseY + wave * 2
                    )

                    card.Icon.Rotation = wave * 2.5
                end
            end
        end

        -- 30 updates/sec is smooth enough for this tiny motion and avoids
        -- spending a RenderStepped callback every frame on every card.
        task.wait(1 / 30)
    end
end)

--==================================================
-- INITIALIZE
--==================================================

UpdateFilterButtons()
UpdateSortButtons()

Refresh()

--==================================================
-- AUTO REFRESH
--==================================================

task.spawn(
    function()

        while ScreenGui.Parent do

            task.wait(2)

            if ScreenGui.Parent and not StealRunning then
                Refresh()
            end
        end
    end
)