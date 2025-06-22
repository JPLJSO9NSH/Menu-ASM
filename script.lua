-- Script Universal Roblox (Mobile/PC) - Fly, NoClip, ESP + Vida/Nome, Aimbot com menu na tela
-- Pra usar: cole no executor (ex: Arceus X) e rode em qualquer jogo

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Estados
local ESPEnabled = false
local AimbotEnabled = false
local FlyEnabled = false
local NoClipEnabled = false
local AimPart = "Head" -- "Head" ou "HumanoidRootPart"

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "UniversalMenu"

local function CreateButton(name, pos, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Text = text
    btn.Size = UDim2.new(0, 120, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = ScreenGui
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    return btn
end

-- ESP Folder
local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "ESPFolder"

-- Função para criar ESP em um jogador
local function CreateESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if ESPFolder:FindFirstChild(player.Name) then return end

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = player.Name
    Billboard.Adornee = player.Character.HumanoidRootPart
    Billboard.Size = UDim2.new(0, 120, 0, 40)
    Billboard.AlwaysOnTop = true
    Billboard.Parent = ESPFolder

    local NameLabel = Instance.new("TextLabel", Billboard)
    NameLabel.Size = UDim2.new(1,0,0.5,0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = player.Name
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

    -- Atualizar vida
    coroutine.wrap(function()
        while Billboard.Parent and player.Character and player.Character:FindFirstChild("Humanoid") do
            local hp = player.Character.Humanoid.Health
            local maxHp = player.Character.Humanoid.MaxHealth
            HealthLabel.Text = string.format("HP: %.0f/%.0f", hp, maxHp)
            wait(0.3)
        end
        if Billboard.Parent then Billboard:Destroy() end
    end)()
end

local function RemoveESP(player)
    local esp = ESPFolder:FindFirstChild(player.Name)
    if esp then esp:Destroy() end
end

local function UpdateESP()
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
    RemoveESP(player)
end)

-- Aimbot
local function GetClosestTarget()
    local closestPart = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) then
            local part = player.Character[AimPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestPart = part
                end
            end
        end
    end

    return closestPart
end

-- Fly / NoClip Variables
local bodyVelocity, bodyGyro
local humanoid = nil
local rootPart = nil

local function EnableFly()
    if not LocalPlayer.Character then return end
    humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart or not humanoid then return end

    bodyVelocity = Instance.new("BodyVelocity", rootPart)
    bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
    bodyVelocity.Velocity = Vector3.new(0,0,0)

    bodyGyro = Instance.new("BodyGyro", rootPart)
    bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
    bodyGyro.CFrame = rootPart.CFrame
end

local function DisableFly()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end

-- NoClip
local function SetNoClip(state)
    if not LocalPlayer.Character then return end
    for _, part in pairs(LocalPlayer.Character:GetChildren()) do
        if part:IsA("BasePart") and part.CanCollide ~= (not state) then
            part.CanCollide = not state
        end
    end
end

-- Movimentação Fly
local moveVector = Vector3.new(0,0,0)
UserInputService.InputBegan:Connect(function(input)
    if FlyEnabled then
        if input.KeyCode == Enum.KeyCode.W then
            moveVector = Vector3.new(0,0,-1)
        elseif input.KeyCode == Enum.KeyCode.S then
            moveVector = Vector3.new(0,0,1)
        elseif input.KeyCode == Enum.KeyCode.A then
            moveVector = Vector3.new(-1,0,0)
        elseif input.KeyCode == Enum.KeyCode.D then
            moveVector = Vector3.new(1,0,0)
        elseif input.KeyCode == Enum.KeyCode.Space then
            moveVector = Vector3.new(0,1,0)
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            moveVector = Vector3.new(0,-1,0)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if FlyEnabled then
        if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift then
            moveVector = Vector3.new(0,0,0)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if FlyEnabled and bodyVelocity and bodyGyro and rootPart then
        local cameraCFrame = workspace.CurrentCamera.CFrame
        local direction = (cameraCFrame.LookVector * moveVector.Z) + (cameraCFrame.RightVector * moveVector.X) + (Vector3.new(0,1,0) * moveVector.Y)
        bodyVelocity.Velocity = direction * 50
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    end
end)

-- NoClip loop
RunService.Stepped:Connect(function()
    if NoClipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = GetClosestTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- Botões menu
local btnESP = CreateButton("btnESP", UDim2.new(0,10,0,10), "ESP: OFF")
local btnAimbot = CreateButton("btnAimbot", UDim2.new(0,10,0,55), "Aimbot: OFF")
local btnAimPart = CreateButton("btnAimPart", UDim2.new(0,10,0,100), "Aim: Head")
local btnFly = CreateButton("btnFly", UDim2.new(0,10,0,145), "Fly: OFF")
local btnNoClip = CreateButton("btnNoClip", UDim2.new(0,10,0,190), "NoClip: OFF")

btnESP.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    UpdateESP()
    btnESP.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
end)

btnAimbot.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    btnAimbot.Text = AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)

btnAimPart.MouseButton1Click:Connect(function()
    if AimPart == "Head" then
        AimPart = "HumanoidRootPart"
        btnAimPart.Text = "Aim: Chest"
    else
        AimPart = "Head"
        btnAimPart.Text = "Aim: Head"
    end
end)

btnFly.MouseButton1Click:Connect(function()
    FlyEnabled = not FlyEnabled
    if FlyEnabled then
        EnableFly()
        btnFly.Text = "Fly: ON"
    else
        DisableFly()
        btnFly.Text = "Fly: OFF"
    end
end)

btnNoClip.MouseButton1Click:Connect(function()
    NoClipEnabled = not NoClipEnabled
    SetNoClip(NoClipEnabled)
    btnNoClip.Text = NoClipEnabled and "NoClip: ON" or "NoClip: OFF"
end)

print("Menu Script carregado! Use os botões no canto superior esquerdo para ativar/desativar as funções.")
