-- Menu Completo Arthur S. M.
-- Funções: ESP + Aimbot + Fly + NoClip + Menu Toggle com Ícone

-- Biblioteca do Menu
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Arthur S. M.", "Midnight")

------------------------------------------------------
-- 🔫 Aimbot
------------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local AimbotEnabled = false
local AimPart = "Head"

local AimbotTab = Window:NewTab("Aimbot")
local AimbotSection = AimbotTab:NewSection("Aimbot Settings")

AimbotSection:NewToggle("Enable Aimbot", "Ativa o Aimbot", function(v)
    AimbotEnabled = v
end)

AimbotSection:NewDropdown("Aim Part", "Seleciona Head ou Chest", {"Head", "HumanoidRootPart"}, function(v)
    AimPart = v
end)

function GetClosestTarget()
    local maxDist, closest = math.huge, nil
    for _,v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(AimPart) then
            local pos, visible = Camera:WorldToViewportPoint(v.Character[AimPart].Position)
            if visible then
                local dist = (Vector2.new(pos.X,pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < maxDist then
                    maxDist = dist
                    closest = v.Character[AimPart]
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = GetClosestTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

------------------------------------------------------
-- 👀 ESP (Nome + Vida)
------------------------------------------------------
local ESPEnabled = false
local NameESP = true
local HealthESP = true

local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "ESPFolder"

local VisualsTab = Window:NewTab("Visuals")
local VisualsSection = VisualsTab:NewSection("ESP Settings")

VisualsSection:NewToggle("Enable ESP", "Ativa o ESP", function(v)
    ESPEnabled = v
end)

VisualsSection:NewToggle("Show Name", "Mostrar Nome", function(v)
    NameESP = v
end)

VisualsSection:NewToggle("Show Health", "Mostrar Vida", function(v)
    HealthESP = v
end)

function CreateESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if ESPFolder:FindFirstChild(player.Name) then return end

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = player.Name
    Billboard.Adornee = player.Character.HumanoidRootPart
    Billboard.Size = UDim2.new(0,120,0,50)
    Billboard.AlwaysOnTop = true
    Billboard.Parent = ESPFolder

    local NameLabel = Instance.new("TextLabel", Billboard)
    NameLabel.Size = UDim2.new(1,0,0.5,0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = NameESP and player.Name or ""
    NameLabel.TextColor3 = Color3.fromRGB(255,255,255)
    NameLabel.TextStrokeTransparency = 0
    NameLabel.Font = Enum.Font.SourceSansBold
    NameLabel.TextScaled = true

    local HealthLabel = Instance.new("TextLabel", Billboard)
    HealthLabel.Size = UDim2.new(1,0,0.5,0)
    HealthLabel.Position = UDim2.new(0,0,0.5,0)
    HealthLabel.BackgroundTransparency = 1
    HealthLabel.TextColor3 = Color3.fromRGB(0,255,0)
    HealthLabel.TextStrokeTransparency = 0
    HealthLabel.Font = Enum.Font.SourceSansBold
    HealthLabel.TextScaled = true

    coroutine.wrap(function()
        while Billboard.Parent and player.Character and player.Character:FindFirstChild("Humanoid") do
            NameLabel.Text = NameESP and player.Name or ""
            if HealthESP then
                local hp = player.Character.Humanoid.Health
                local maxHp = player.Character.Humanoid.MaxHealth
                HealthLabel.Text = string.format("HP: %.0f/%.0f", hp, maxHp)
            else
                HealthLabel.Text = ""
            end
            wait(0.3)
        end
        if Billboard.Parent then Billboard:Destroy() end
    end)()
end

function UpdateESP()
    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESP(player)
            end
        end
    else
        ESPFolder:ClearAllChildren()
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        if ESPEnabled then
            CreateESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    local esp = ESPFolder:FindFirstChild(player.Name)
    if esp then esp:Destroy() end
end)

RunService.RenderStepped:Connect(function()
    UpdateESP()
end)

------------------------------------------------------
-- 🦅 Fly + 🚪 NoClip
------------------------------------------------------
local UserInput = game:GetService("UserInputService")
local FlyEnabled = false
local NoClipEnabled = false
local FlySpeed = 50

local bodyGyro, bodyVelocity = nil, nil
local root = nil

local FunctionTab = Window:NewTab("Functions")
local FunctionSection = FunctionTab:NewSection("Fly & Noclip")

FunctionSection:NewToggle("Enable Fly", "Ativa o Fly", function(v)
    FlyEnabled = v
end)

FunctionSection:NewSlider("Fly Speed", "Velocidade do Fly", 200, 10, function(v)
    FlySpeed = v
end)

FunctionSection:NewToggle("Enable NoClip", "Ativa o Noclip", function(v)
    NoClipEnabled = v
end)

function EnableFly()
    root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    bodyGyro = Instance.new("BodyGyro", root)
    bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bodyGyro.P = 9e4
    bodyGyro.CFrame = root.CFrame

    bodyVelocity = Instance.new("BodyVelocity", root)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
end

function DisableFly()
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
end

local Movement = {Forward=0,Right=0,Up=0}

UserInput.InputBegan:Connect(function(input)
    if FlyEnabled then
        if input.KeyCode == Enum.KeyCode.W then Movement.Forward = 1 end
        if input.KeyCode == Enum.KeyCode.S then Movement.Forward = -1 end
        if input.KeyCode == Enum.KeyCode.A then Movement.Right = -1 end
        if input.KeyCode == Enum.KeyCode.D then Movement.Right = 1 end
        if input.KeyCode == Enum.KeyCode.Space then Movement.Up = 1 end
        if input.KeyCode == Enum.KeyCode.LeftShift then Movement.Up = -1 end
    end
end)

UserInput.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then Movement.Forward = 0 end
    if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then Movement.Right = 0 end
    if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift then Movement.Up = 0 end
end)

RunService.RenderStepped:Connect(function()
    if FlyEnabled then
        if not bodyGyro or not bodyVelocity then
            EnableFly()
        end
        local camera = workspace.CurrentCamera
        local move = (camera.CFrame.LookVector * Movement.Forward + camera.CFrame.RightVector * Movement.Right + Vector3.new(0,1,0) * Movement.Up) * FlySpeed
        bodyVelocity.Velocity = move
        bodyGyro.CFrame = camera.CFrame
    else
        DisableFly()
    end
end)

RunService.Stepped:Connect(function()
    if NoClipEnabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

------------------------------------------------------
-- 🔘 Botão com Ícone para Abrir/Fechar o Menu
------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
local OpenButton = Instance.new("ImageButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ToggleMenu"

OpenButton.Name = "OpenButton"
OpenButton.Parent = ScreenGui
OpenButton.BackgroundTransparency = 1
OpenButton.Position = UDim2.new(0, 10, 0, 10)
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Image = "rbxassetid://103669232191033"

local menuOpen = true

OpenButton.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    for _,v in pairs(game.CoreGui:GetChildren()) do
        if v.Name == "KavoUI" then
            v.Enabled = menuOpen
        end
    end
end)
