local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

-- Prevent multiple instances
if CoreGui:FindFirstChild("OverfloodUI") then
    CoreGui.OverfloodUI:Destroy()
end

-- ================================
-- CONFIG SYSTEM
-- ================================
local ConfigFolder = "overflood_configs"
local AutoloadFile = ConfigFolder .. "/autoload.txt"

if makefolder and not isfolder(ConfigFolder) then
    makefolder(ConfigFolder)
end

local OverfloodSettings = {
    SilentAim = false,
    ShowFOV = true,
    Fov = 150,
    ESP = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPHealth = true,
    ESPDistance = true,
    WalkSpeed = 16,
    Triggerbot = false,
    NightMode = false,
    CustomTime = false,
    TimeOfDay = 12,
    Fullbright = false,
    RemoveFog = false,
    XRay = false,
    NoSky = false,
    UnlockAll = false,
}

local UIStateUpdaters = {}
local SelectedConfig = ""

local function GetConfigs()
    local configs = {}
    if listfiles then
        local success, files = pcall(function() return listfiles(ConfigFolder) end)
        if success and files then
            for _, file in ipairs(files) do
                if file:sub(-5) == ".json" then
                    local name = file:match("([^/\\]+)%.json$")
                    if name then table.insert(configs, name) end
                end
            end
        end
    end
    return configs
end

local function SaveConfig(name)
    if writefile and name ~= "" then
        local json = HttpService:JSONEncode(OverfloodSettings)
        writefile(ConfigFolder .. "/" .. name .. ".json", json)
    end
end

local function UpdateAllUI()
    for flag, updaterFunc in pairs(UIStateUpdaters) do
        if OverfloodSettings[flag] ~= nil then
            updaterFunc(OverfloodSettings[flag])
        end
    end
end

local function LoadConfig(name)
    if readfile and isfile and isfile(ConfigFolder .. "/" .. name .. ".json") then
        local data = readfile(ConfigFolder .. "/" .. name .. ".json")
        local success, decoded = pcall(function() return HttpService:JSONDecode(data) end)
        if success then
            for k, v in pairs(decoded) do
                OverfloodSettings[k] = v
            end
            UpdateAllUI()
            print("[overflood] Loaded: " .. name)
        end
    end
end

local function DeleteConfig(name)
    if delfile and isfile and isfile(ConfigFolder .. "/" .. name .. ".json") then
        delfile(ConfigFolder .. "/" .. name .. ".json")
    end
end

local function GetAutoload()
    if isfile and isfile(AutoloadFile) and readfile then 
        return readfile(AutoloadFile) 
    end
    return "none"
end

local function SetAutoload(name)
    if writefile and name ~= "" then writefile(AutoloadFile, name) end
end

local function RemoveAutoload()
    if delfile and isfile and isfile(AutoloadFile) then delfile(AutoloadFile) end
end

-- ================================
-- FOV CIRCLE
-- ================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = OverfloodSettings.ShowFOV
FOVCircle.Radius = OverfloodSettings.Fov
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- ================================
-- SILENT AIM (From message.txt - EXACT METHOD)
-- ================================
local phem1 = {}
local phem2 = {}

function phem1:get_closest_player()
    local phem3 = cloneref(game:GetService('Players'))
    local phem4 = cloneref(game:GetService('Workspace'))
    local phem5 = cloneref(game:GetService('ReplicatedFirst'))
    local phem6 = cloneref(game:GetService('ReplicatedStorage'))
    local phem7 = phem3.LocalPlayer
    local phem8 = phem4.CurrentCamera
    local phem9 = require(game.FindFirstChild(phem5, 'neuron', true))
    local phem10 = require(game.FindFirstChild(phem6, 'States', true))
    local phem11 = game.GetChildren(game.FindFirstChild(phem4, 'Entities', true))
    local phem12 = OverfloodSettings.Fov
    phem1.target = nil
    local phem13 = {}
    for _, phem14 in phem3:GetPlayers() do
        if phem14 == phem7 then continue end
        local phem15 = phem9:get_character(phem14)
        if phem15 then table.insert(phem13, { char = phem15 }) end
    end
    for _, phem16 in phem11 do
        table.insert(phem13, { char = phem16 })
    end
    local phem17 = Vector2.new((phem8.ViewportSize.X / 2), (phem8.ViewportSize.Y / 2))
    for _, phem18 in phem13 do
        local phem19 = phem18.char
        if phem10:GetStateValue(phem19, 'Dead', false) then continue end
        local phem20 = game.FindFirstChild(phem19, 'HitboxHead')
        if not phem20 then continue end
        local phem21, phem22 = phem8:WorldToViewportPoint(phem20.Position)
        if not phem22 then continue end
        local phem23 = (Vector2.new(phem21.X, phem21.Y) - phem17).Magnitude
        if phem23 < phem12 then
            phem12 = phem23
            phem1.target = phem20.Position
        end
    end
end

local phem24 = cloneref(game:GetService('RunService'))
phem24.PreRender:Connect(function()
    phem1:get_closest_player()
end)

local phem25 = false
local phem26 = cloneref(game:GetService('Workspace')).CurrentCamera
local phem27 = cloneref(game:GetService('ReplicatedFirst'))
local phem28 = cloneref(game:GetService('ReplicatedStorage'))
local phem29 = require(game.FindFirstChild(phem27, 'GenerateCommand', true))
local phem30 = require(game.FindFirstChild(phem28, 'CameraHandler', true))
local phem31 = require(game.FindFirstChild(phem28, 'Effects', true))
local phem32

local phem33; phem33 = hookfunction(phem29.GetCameraAngles, newlclosure(function(...)
    if not phem30.firstPerson then return phem33(...) end
    local phem34 = (phem32 or phem30.currentRotation)
    return phem34.X, phem34.Y
end))

local phem35; phem35 = hookfunction(phem31.Identify, newlclosure(function(self, phem36, ...)
    local phem37 = (select(4, ...))
    if OverfloodSettings.SilentAim and phem1.target and phem36 == 'Shot' and phem37.origin and phem37.hitPos then
        phem37.hitPos = (phem37.origin + (phem1.target - phem26.CFrame.p).Unit * (phem37.hitPos - phem37.origin).Magnitude)
    end
    return phem35(self, phem36, ...)
end))

phem24:BindToRenderStep('SilentAim', (math.huge - math.huge), function()
    if not phem30.firstPerson or not phem1.target then return end
    if OverfloodSettings.SilentAim then
        phem32 = phem30.currentRotation
        local phem38 = (phem1.target - phem26.CFrame.p).Unit
        phem30.currentRotation = vector.create(math.asin(phem38.Y), math.atan2(-phem38.X, -phem38.Z), 0)
    end
end)

phem24:BindToRenderStep('ResetAim', 101, function()
    if phem32 and phem30.firstPerson then
        phem30.currentRotation = phem32
        phem32 = nil
    end
end)

-- ================================
-- TRIGGERBOT
-- ================================
local function Triggerbot()
    if not OverfloodSettings.Triggerbot then return end
    if not phem1.target then return end
    
    local Camera = cloneref(game:GetService('Workspace')).CurrentCamera
    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(phem1.target)
    if not OnScreen then return end
    
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - ScreenCenter).Magnitude
    
    if Distance < 12 then
        mouse1press()
        mouse1release()
    end
end

-- ================================
-- ESP SYSTEM
-- ================================
local ESPCache = {}

local function ClearESP(character)
    if ESPCache[character] then
        if ESPCache[character].Box then ESPCache[character].Box:Remove() end
        if ESPCache[character].Text then ESPCache[character].Text:Remove() end
        if ESPCache[character].Health then ESPCache[character].Health:Remove() end
        if ESPCache[character].HealthBg then ESPCache[character].HealthBg:Remove() end
        if ESPCache[character].Distance then ESPCache[character].Distance:Remove() end
        ESPCache[character] = nil
    end
end

local function UpdateESP()
    local PlayersService = cloneref(game:GetService('Players'))
    local WorkspaceService = cloneref(game:GetService('Workspace'))
    local ReplicatedFirstService = cloneref(game:GetService('ReplicatedFirst'))
    local ReplicatedStorageService = cloneref(game:GetService('ReplicatedStorage'))
    
    local LocalPlayer = PlayersService.LocalPlayer
    local Camera = WorkspaceService.CurrentCamera
    
    local NeuronModule = require(game.FindFirstChild(ReplicatedFirstService, 'neuron', true))
    local StatesModule = require(game.FindFirstChild(ReplicatedStorageService, 'States', true))
    local EntitiesFolder = game.GetChildren(game.FindFirstChild(WorkspaceService, 'Entities', true))
    
    local PotentialTargets = {}
    local RenderedThisFrame = {}
    
    for _, Player in PlayersService:GetPlayers() do
        if Player == LocalPlayer then continue end
        local Character = NeuronModule:get_character(Player)
        if Character then 
            table.insert(PotentialTargets, { char = Character, name = Player.Name }) 
        end
    end
    
    for _, Entity in EntitiesFolder do
        table.insert(PotentialTargets, { char = Entity, name = Entity.Name })
    end
    
    local ScreenCenter = Vector2.new((Camera.ViewportSize.X / 2), (Camera.ViewportSize.Y / 2))
    
    -- Update FOV Circle
    FOVCircle.Position = ScreenCenter
    FOVCircle.Radius = OverfloodSettings.Fov
    FOVCircle.Visible = OverfloodSettings.ShowFOV
    
    for _, TargetObj in PotentialTargets do
        local Character = TargetObj.char
        local TargetName = TargetObj.name
        
        local IsDead = StatesModule:GetStateValue(Character, 'Dead', false)
        if IsDead then 
            ClearESP(Character)
            continue 
        end
        
        local Head = game.FindFirstChild(Character, 'HitboxHead')
        local Root = game.FindFirstChild(Character, 'HumanoidRootPart') or game.FindFirstChild(Character, 'LowerTorso')
        
        if not Head then 
            ClearESP(Character)
            continue 
        end
        
        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Head.Position)
        local Distance = (Head.Position - Camera.CFrame.Position).Magnitude
        
        if OverfloodSettings.ESP and OnScreen and Root then
            RenderedThisFrame[Character] = true
            
            local RootPos, RootOnScreen = Camera:WorldToViewportPoint(Root.Position)
            local HeadPos = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
            local LegPos = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0))
            
            local BoxHeight = math.abs(HeadPos.Y - LegPos.Y)
            local BoxWidth = BoxHeight * 0.6
            
            if not ESPCache[Character] then
                ESPCache[Character] = {
                    Box = Drawing.new("Square"),
                    Text = Drawing.new("Text"),
                    Health = Drawing.new("Square"),
                    HealthBg = Drawing.new("Square"),
                    Distance = Drawing.new("Text")
                }
            end
            
            local Visuals = ESPCache[Character]
            
            -- ESP Box
            if OverfloodSettings.ESPBoxes then
                Visuals.Box.Visible = true
                Visuals.Box.Size = Vector2.new(BoxWidth, BoxHeight)
                Visuals.Box.Position = Vector2.new(RootPos.X - (BoxWidth / 2), HeadPos.Y)
                Visuals.Box.Color = Color3.fromRGB(255, 255, 255)
                Visuals.Box.Thickness = 1
                Visuals.Box.Filled = false
            else
                Visuals.Box.Visible = false
            end
            
            -- ESP Name
            if OverfloodSettings.ESPNames then
                Visuals.Text.Visible = true
                Visuals.Text.Text = TargetName
                Visuals.Text.Size = 14
                Visuals.Text.Center = true
                Visuals.Text.Outline = true
                Visuals.Text.Position = Vector2.new(RootPos.X, HeadPos.Y - 18)
                Visuals.Text.Color = Color3.fromRGB(255, 255, 255)
            else
                Visuals.Text.Visible = false
            end
            
            -- ESP Health Bar
            if OverfloodSettings.ESPHealth then
                local hum = Character:FindFirstChildWhichIsA("Humanoid")
                local hp = hum and hum.Health or 100
                local maxHp = hum and hum.MaxHealth or 100
                local pct = math.clamp(hp / maxHp, 0, 1)
                local healthColor = pct > 0.5 and Color3.fromRGB(50, 255, 50) or pct > 0.25 and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(255, 50, 50)
                
                Visuals.HealthBg.Visible = true
                Visuals.HealthBg.Size = Vector2.new(BoxWidth + 2, 4)
                Visuals.HealthBg.Position = Vector2.new(RootPos.X - (BoxWidth / 2) - 1, HeadPos.Y + BoxHeight + 4)
                Visuals.HealthBg.Color = Color3.fromRGB(30, 30, 30)
                Visuals.HealthBg.Filled = true
                Visuals.HealthBg.Thickness = 0
                
                Visuals.Health.Visible = true
                Visuals.Health.Size = Vector2.new(BoxWidth * pct, 4)
                Visuals.Health.Position = Vector2.new(RootPos.X - (BoxWidth / 2) + 1, HeadPos.Y + BoxHeight + 4)
                Visuals.Health.Color = healthColor
                Visuals.Health.Filled = true
                Visuals.Health.Thickness = 0
            else
                if Visuals.HealthBg then Visuals.HealthBg.Visible = false end
                if Visuals.Health then Visuals.Health.Visible = false end
            end
            
            -- ESP Distance
            if OverfloodSettings.ESPDistance then
                Visuals.Distance.Visible = true
                Visuals.Distance.Text = math.floor(Distance) .. "m"
                Visuals.Distance.Size = 12
                Visuals.Distance.Center = true
                Visuals.Distance.Outline = true
                Visuals.Distance.Position = Vector2.new(RootPos.X, HeadPos.Y + BoxHeight + 20)
                Visuals.Distance.Color = Color3.fromRGB(200, 200, 200)
            else
                Visuals.Distance.Visible = false
            end
        else
            ClearESP(Character)
        end
    end
    
    for CachedChar, _ in pairs(ESPCache) do
        if not RenderedThisFrame[CachedChar] then
            ClearESP(CachedChar)
        end
    end
end

-- ================================
-- WORLD VISUALS
-- ================================
local skyInstance = nil

local function UpdateWorldVisuals()
    -- Night Mode
    if OverfloodSettings.NightMode then
        Lighting.ClockTime = 0
        Lighting.Brightness = 0.5
        Lighting.Ambient = Color3.fromRGB(40, 40, 80)
        Lighting.FogEnd = 99999
    end
    
    -- Custom Time
    if OverfloodSettings.CustomTime then
        Lighting.ClockTime = OverfloodSettings.TimeOfDay
    end
    
    -- Fullbright
    if OverfloodSettings.Fullbright then
        Lighting.Brightness = 10
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.GlobalShadows = true
    end
    
    -- Remove Fog
    if OverfloodSettings.RemoveFog then
        Lighting.FogEnd = 999999
    end
    
    -- X-Ray
    if OverfloodSettings.XRay then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                pcall(function() 
                    v.LocalTransparencyModifier = 0.8 
                end)
            end
        end
    end
    
    -- No Sky
    if OverfloodSettings.NoSky then
        local s = Lighting:FindFirstChildOfClass("Sky")
        if s then 
            skyInstance = s
            s:Destroy() 
        end
    else
        if skyInstance and not Lighting:FindFirstChildOfClass("Sky") then
            skyInstance:Clone().Parent = Lighting
            skyInstance = nil
        end
    end
end

-- ================================
-- UNLOCK ALL
-- ================================
local unlockAllHooked = false

function setupUnlockAll()
    if not OverfloodSettings.UnlockAll then
        if unlockAllHooked then
            unlockAllHooked = false
        end
        return
    end
    
    local InventoryHandler = require(game.FindFirstChild(ReplicatedStorage, 'Modules', true):FindFirstChild('Handlers', true):FindFirstChild('InventoryHandler', true))
    if not InventoryHandler then return end
    
    unlockAllHooked = true

    local oldOwnsItem = InventoryHandler.OwnsItem
    local oldOwnsSkin = InventoryHandler.OwnsSkin
    local oldOwnsWrap = InventoryHandler.OwnsWrap
    local oldOwnsCharm = InventoryHandler.OwnsCharm
    local oldOwnsFinisher = InventoryHandler.OwnsFinisher

    InventoryHandler.OwnsItem = function(self, id)
        if OverfloodSettings.UnlockAll then return true end
        return oldOwnsItem(self, id)
    end

    InventoryHandler.OwnsSkin = function(self, weapon, skin)
        if OverfloodSettings.UnlockAll then return true end
        return oldOwnsSkin(self, weapon, skin)
    end

    InventoryHandler.OwnsWrap = function(self, weapon, wrap)
        if OverfloodSettings.UnlockAll then return true end
        return oldOwnsWrap(self, weapon, wrap)
    end

    InventoryHandler.OwnsCharm = function(self, weapon, charm)
        if OverfloodSettings.UnlockAll then return true end
        return oldOwnsCharm(self, weapon, charm)
    end

    InventoryHandler.OwnsFinisher = function(self, weapon, fin)
        if OverfloodSettings.UnlockAll then return true end
        return oldOwnsFinisher(self, weapon, fin)
    end
end

-- ================================
-- UI CREATION
-- ================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OverfloodUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999

-- Loading Screen
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LoadingFrame.Parent = ScreenGui

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 1, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "this script was made by undeviated on discord"
LoadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
LoadingText.Font = Enum.Font.RobotoMono
LoadingText.TextSize = 20
LoadingText.Parent = LoadingFrame

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(40, 40, 40)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 0, 30)
TitleLabel.Position = UDim2.new(0, 10, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "overflood"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.RobotoMono
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 0, 35)
Divider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 130, 1, -36)
TabContainer.Position = UDim2.new(0, 0, 0, 36)
TabContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local TabDivider = Instance.new("Frame")
TabDivider.Size = UDim2.new(0, 1, 1, -36)
TabDivider.Position = UDim2.new(0, 130, 0, 36)
TabDivider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TabDivider.BorderSizePixel = 0
TabDivider.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -131, 1, -36)
ContentContainer.Position = UDim2.new(0, 131, 0, 36)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.02, 0, 0.15, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
ToggleButton.Text = "O"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.RobotoMono
ToggleButton.TextSize = 18
ToggleButton.Visible = false
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(40, 40, 40)
ToggleStroke.Parent = ToggleButton

-- ================================
-- TAB SYSTEM
-- ================================
local tabs = {"Combat", "Visuals", "World", "Settings"}
local tabFrames = {}

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabContainer

for i, tabName in ipairs(tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TabButton.BackgroundTransparency = (i == 1) and 0 or 1
    TabButton.Text = tabName
    TabButton.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    TabButton.Font = Enum.Font.RobotoMono
    TabButton.TextSize = 14
    TabButton.BorderSizePixel = 0
    TabButton.LayoutOrder = i
    TabButton.Parent = TabContainer

    local PageFrame = Instance.new("ScrollingFrame")
    PageFrame.Size = UDim2.new(1, -20, 1, -20)
    PageFrame.Position = UDim2.new(0, 10, 0, 10)
    PageFrame.BackgroundTransparency = 1
    PageFrame.ScrollBarThickness = 2
    PageFrame.Visible = (i == 1)
    PageFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    PageFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    PageFrame.Parent = ContentContainer
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Parent = PageFrame
    
    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 5)
    PagePadding.PaddingBottom = UDim.new(0, 5)
    PagePadding.PaddingRight = UDim.new(0, 5)
    PagePadding.Parent = PageFrame

    tabFrames[tabName] = {Button = TabButton, Frame = PageFrame}

    TabButton.MouseButton1Click:Connect(function()
        for name, data in pairs(tabFrames) do
            data.Frame.Visible = (name == tabName)
            data.Button.BackgroundTransparency = (name == tabName) and 0 or 1
            data.Button.TextColor3 = (name == tabName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
        end
    end)
end

-- ================================
-- UI COMPONENTS
-- ================================
local ElementOrder = 0
local function GetNextOrder() ElementOrder = ElementOrder + 1; return ElementOrder end

local function CreateToggle(text, flag, parent)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 0, 28)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ToggleBtn.BorderColor3 = Color3.fromRGB(50, 50, 50)
    ToggleBtn.Text = " [ ] " .. text
    ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleBtn.Font = Enum.Font.RobotoMono
    ToggleBtn.TextSize = 13
    ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
    ToggleBtn.LayoutOrder = GetNextOrder()
    ToggleBtn.Parent = parent
    
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, 5)
    UIPadding.Parent = ToggleBtn
    
    local function UpdateVisual(state)
        OverfloodSettings[flag] = state
        if state then
            ToggleBtn.Text = "[x] " .. text
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            ToggleBtn.Text = "[ ] " .. text
            ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end

    ToggleBtn.MouseButton1Click:Connect(function()
        UpdateVisual(not OverfloodSettings[flag])
    end)
    
    UIStateUpdaters[flag] = UpdateVisual
    UpdateVisual(OverfloodSettings[flag])
end

local function CreateSlider(text, flag, min, max, parent)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 45)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.LayoutOrder = GetNextOrder()
    SliderFrame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(OverfloodSettings[flag])
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.RobotoMono
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    
    local BarBg = Instance.new("TextButton")
    BarBg.Size = UDim2.new(1, 0, 0, 20)
    BarBg.Position = UDim2.new(0, 0, 0, 20)
    BarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    BarBg.BorderColor3 = Color3.fromRGB(50, 50, 50)
    BarBg.Text = ""
    BarBg.AutoButtonColor = false
    BarBg.Parent = SliderFrame
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Fill.BorderSizePixel = 0
    Fill.Parent = BarBg

    local function UpdateVisual(val)
        val = math.clamp(val, min, max)
        OverfloodSettings[flag] = val
        Label.Text = text .. ": " .. tostring(val)
        local percent = (val - min) / (max - min)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
    end
    
    local dragging = false
    BarBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = true 
            local percent = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
            UpdateVisual(math.floor(min + (max - min) * percent))
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percent = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
            UpdateVisual(math.floor(min + (max - min) * percent))
        end
    end)
    
    UIStateUpdaters[flag] = UpdateVisual
    UpdateVisual(OverfloodSettings[flag])
end

-- ================================
-- POPULATING TABS
-- ================================

-- COMBAT TAB
local CombatPage = tabFrames["Combat"].Frame
CreateToggle("Silent Aim", "SilentAim", CombatPage)
CreateToggle("Triggerbot", "Triggerbot", CombatPage)
CreateToggle("Show FOV", "ShowFOV", CombatPage)
CreateSlider("FOV Size", "Fov", 10, 360, CombatPage)

-- VISUALS TAB
local VisualsPage = tabFrames["Visuals"].Frame
CreateToggle("ESP", "ESP", VisualsPage)
CreateToggle("ESP Boxes", "ESPBoxes", VisualsPage)
CreateToggle("ESP Names", "ESPNames", VisualsPage)
CreateToggle("ESP Health", "ESPHealth", VisualsPage)
CreateToggle("ESP Distance", "ESPDistance", VisualsPage)

-- WORLD TAB
local WorldPage = tabFrames["World"].Frame
CreateToggle("Night Mode", "NightMode", WorldPage)
CreateToggle("Custom Time", "CustomTime", WorldPage)
CreateSlider("Time Of Day", "TimeOfDay", 0, 24, WorldPage)
CreateToggle("Fullbright", "Fullbright", WorldPage)
CreateToggle("Remove Fog", "RemoveFog", WorldPage)
CreateToggle("X-Ray", "XRay", WorldPage)
CreateToggle("No Sky", "NoSky", WorldPage)
CreateToggle("Unlock All", "UnlockAll", WorldPage)

-- ================================
-- SETTINGS TAB
-- ================================
local SettingsPage = tabFrames["Settings"].Frame

local function CreateLabel(text, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.RobotoMono
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = GetNextOrder()
    lbl.Parent = parent
    return lbl
end

local ConfigTitle = CreateLabel("Configuration", SettingsPage)
ConfigTitle.TextXAlignment = Enum.TextXAlignment.Center

CreateLabel("Config name", SettingsPage)

local ConfigNameInput = Instance.new("TextBox")
ConfigNameInput.Size = UDim2.new(1, 0, 0, 30)
ConfigNameInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ConfigNameInput.BorderColor3 = Color3.fromRGB(50, 50, 50)
ConfigNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfigNameInput.Font = Enum.Font.RobotoMono
ConfigNameInput.TextSize = 13
ConfigNameInput.Text = ""
ConfigNameInput.PlaceholderText = "Enter config name..."
ConfigNameInput.TextXAlignment = Enum.TextXAlignment.Left
ConfigNameInput.LayoutOrder = GetNextOrder()
ConfigNameInput.Parent = SettingsPage

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 5)
UIPadding.Parent = ConfigNameInput

CreateLabel("Config list", SettingsPage)

local ConfigListBtn = Instance.new("TextButton")
ConfigListBtn.Size = UDim2.new(1, 0, 0, 30)
ConfigListBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ConfigListBtn.BorderColor3 = Color3.fromRGB(50, 50, 50)
ConfigListBtn.Text = " select config  >"
ConfigListBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ConfigListBtn.Font = Enum.Font.RobotoMono
ConfigListBtn.TextSize = 13
ConfigListBtn.TextXAlignment = Enum.TextXAlignment.Left
ConfigListBtn.LayoutOrder = GetNextOrder()
ConfigListBtn.Parent = SettingsPage

local DropdownFrame = Instance.new("ScrollingFrame")
DropdownFrame.Size = UDim2.new(1, 0, 0, 100)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
DropdownFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
DropdownFrame.ScrollBarThickness = 4
DropdownFrame.Visible = false
DropdownFrame.LayoutOrder = GetNextOrder()
DropdownFrame.Parent = SettingsPage

local DropdownLayout = Instance.new("UIListLayout")
DropdownLayout.Parent = DropdownFrame

local function RefreshDropdown()
    for _, child in ipairs(DropdownFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local configs = GetConfigs()
    for _, cfg in ipairs(configs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 25)
        btn.BackgroundTransparency = 1
        btn.Text = " " .. cfg
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.RobotoMono
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = DropdownFrame
        
        btn.MouseButton1Click:Connect(function()
            SelectedConfig = cfg
            ConfigListBtn.Text = " " .. cfg .. "  >"
            ConfigNameInput.Text = cfg
            DropdownFrame.Visible = false
        end)
    end
    DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, #configs * 25)
end

ConfigListBtn.MouseButton1Click:Connect(function()
    DropdownFrame.Visible = not DropdownFrame.Visible
    if DropdownFrame.Visible then RefreshDropdown() end
end)

local function CreateButtonRow(text1, text2)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 30)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = GetNextOrder()
    Row.Parent = SettingsPage
    
    local B1 = Instance.new("TextButton")
    B1.Size = UDim2.new(0.5, -2, 1, 0)
    B1.Position = UDim2.new(0, 0, 0, 0)
    B1.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    B1.BorderColor3 = Color3.fromRGB(50, 50, 50)
    B1.Text = text1
    B1.TextColor3 = Color3.fromRGB(200, 200, 200)
    B1.Font = Enum.Font.RobotoMono
    B1.TextSize = 13
    B1.Parent = Row
    
    local B2 = nil
    if text2 then
        B2 = B1:Clone()
        B2.Position = UDim2.new(0.5, 2, 0, 0)
        B2.Text = text2
        B2.Parent = Row
    else
        B1.Size = UDim2.new(1, 0, 1, 0)
    end
    return B1, B2
end

local CreateBtn, LoadBtn = CreateButtonRow("Create config", "Load config")
local OverwriteBtn, DeleteBtn = CreateButtonRow("Overwrite config", "Delete config")
local RefreshBtn = CreateButtonRow("Refresh list", nil)
local SetAutoBtn, RemAutoBtn = CreateButtonRow("Set autoload", "Remove autoload")

local AutoloadLabel = CreateLabel("Current autoload config:\n" .. GetAutoload(), SettingsPage)
AutoloadLabel.Size = UDim2.new(1, 0, 0, 32)

CreateBtn.MouseButton1Click:Connect(function() SaveConfig(ConfigNameInput.Text); RefreshDropdown() end)
LoadBtn.MouseButton1Click:Connect(function() LoadConfig(ConfigNameInput.Text) end)
OverwriteBtn.MouseButton1Click:Connect(function() SaveConfig(ConfigNameInput.Text) end)
DeleteBtn.MouseButton1Click:Connect(function() DeleteConfig(ConfigNameInput.Text); RefreshDropdown() end)
RefreshBtn.MouseButton1Click:Connect(RefreshDropdown)
SetAutoBtn.MouseButton1Click:Connect(function() SetAutoload(ConfigNameInput.Text); AutoloadLabel.Text = "Current autoload config:\n" .. GetAutoload() end)
RemAutoBtn.MouseButton1Click:Connect(function() RemoveAutoload(); AutoloadLabel.Text = "Current autoload config:\n" .. GetAutoload() end)

-- Initial Auto-load check
local autoloadName = GetAutoload()
if autoloadName ~= "none" then
    LoadConfig(autoloadName)
end

-- ================================
-- DRAGGING AND TOGGLE LOGIC
-- ================================
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

TitleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Button Dragging logic
local btnDragging, btnDragInput, btnDragStart, btnStartPos
local function updateBtnDrag(input)
    local delta = input.Position - btnDragStart
    ToggleButton.Position = UDim2.new(
        btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
        btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
    )
end

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true
        btnDragStart = input.Position
        btnStartPos = ToggleButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                btnDragging = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        btnDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == btnDragInput and btnDragging then
        updateBtnDrag(input)
    end
end)

-- Toggle UI visibility logic
local isUIVisible = false
local function ToggleUI()
    isUIVisible = not isUIVisible
    MainFrame.Visible = isUIVisible
end

ToggleButton.MouseButton1Click:Connect(function()
    if not btnDragging then ToggleUI() end
end)

-- ================================
-- MAIN LOOPS
-- ================================
RunService.PreRender:Connect(function()
    -- Silent Aim targeting is handled by phem1:get_closest_player() which runs on PreRender
    UpdateESP()
    UpdateWorldVisuals()
    Triggerbot()
end)

-- ================================
-- LOADING ANIMATION
-- ================================
task.spawn(function()
    task.wait(2) 
    
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(LoadingText, tweenInfo, {TextTransparency = 1}):Play()
    
    task.wait(1) 
    TweenService:Create(LoadingFrame, tweenInfo, {BackgroundTransparency = 1}):Play()
    
    task.wait(1) 
    LoadingFrame:Destroy()
    
    ToggleButton.Visible = true
    ToggleUI() 
end)

-- ================================
-- INITIALIZE
-- ================================
print("Overflood Loaded Successfully!")
print("Made by Undeviated")
print("Press O button or click the toggle button")

while wait(1) do end