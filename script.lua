-- Arthur S. M. - Universal Script
-- Script com ESP (Nome + Vida), Aimbot, Fly com controle de velocidade, e NoClip.
-- Botão personalizado para abrir/fechar o menu.

-- 🧠 UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Arthur S. M.", "Ocean")

-- ⚙️ Variáveis
local FlySpeed = 50
local Flying = false
local NoClip = false
local AimbotEnabled = false
local AimPart = "Head"

-------------------------------
-- 📦 Menu Principal
local Main = Window:NewTab("Main")
local MainSection = Main:NewSection("Funções Principais")

-- ✈️ Fly
MainSection:NewToggle("Fly", "Ativar Fly", function(state)
    if state then
        StartFly()
    else
        StopFly()
    end
end)

MainSection:NewSlider("Velocidade Fly", "Ajuste a velocidade", 300, 10, function(s)
    FlySpeed = s
end)

-- 🚪 NoClip
MainSection:NewToggle("NoClip", "Atravessar paredes", function(state)
    NoClip = state
    game:GetService("RunService").Stepped:Connect(function()
        if NoClip then
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)
end)

-------------------------------
-- 🎯 Aimbot
local AimTab = Window:NewTab("Aimbot")
local AimSection = AimTab:NewSection("Aimbot")

AimSection:NewToggle("Ativar Aimbot", "Mira automática", function(state)
    AimbotEnabled = state
end)

AimSection:NewDropdown("Parte do Corpo", {"Head", "UpperTorso"}, function(option)
    AimPart = option
end)

-------------------------------
-- 👀 ESP
local EspTab = Window:NewTab("ESP")
local EspSection = EspTab:NewSection("Visual")

EspSection:NewButton("Ativar ESP", "Mostra nome e vida dos players", function()
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer then
            local Billboard = Instance.new("BillboardGui")
            Billboard.Parent = v.Character:WaitForChild("Head")
            Billboard.Size = UDim2.new(0,100,0,50)
            Billboard.Adornee = v.Character.Head
            Billboard.AlwaysOnTop = true

            local Name = Instance.new("TextLabel", Billboard)
            Name.Text = v.Name
            Name.Size = UDim2.new(1,0,0.5,0)
            Name.BackgroundTransparency = 1
            Name.TextColor3 = Color3.fromRGB(0,255,0)
            Name.TextStrokeTransparency = 0

            local Health = Instance.new("TextLabel", Billboard)
            Health.Text = "Vida: "..math.floor(v.Character.Humanoid.Health)
            Health.Size = UDim2.new(1,0,0.5,0)
            Health.Position = UDim2.new(0,0,0.5,0)
            Health.BackgroundTransparency = 1
            Health.TextColor3 = Color3.fromRGB(255,0,0)
            Health.TextStrokeTransparency = 0

            v.Character.Humanoid.HealthChanged:Connect(function()
                Health.Text = "Vida: "..math.floor(v.Character.Humanoid.Health)
            end)
        end
    end
end)

-------------------------------
-- 🖥️ Botão para Abrir/Fechar Menu
local IconID = "103669232191033"
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Parent = game.CoreGui
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -25)
ToggleButton.Image = "rbxthumb://type=Asset&id="..IconID.."&w=150&h=150"

ToggleButton.MouseButton1Click:Connect(function()
    Library:ToggleUI()
end)

-------------------------------
-- 🎯 Função Aimbot
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

RS.RenderStepped:Connect(function()
    if AimbotEnabled then
        local Closest = nil
        local ClosestDistance = math.huge
        for _,v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild(AimPart) then
                local Pos = workspace.CurrentCamera:WorldToViewportPoint(v.Character[AimPart].Position)
                local Dist = (Vector2.new(Pos.X, Pos.Y) - UIS:GetMouseLocation()).Magnitude
                if Dist < ClosestDistance then
                    ClosestDistance = Dist
                    Closest = v
                end
            end
        end

        if Closest and Closest.Character and Closest.Character:FindFirstChild(AimPart) then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, Closest.Character[AimPart].Position)
        end
    end
end)

-------------------------------
-- ✈️ Função Fly
local Movement = {F=0,B=0,L=0,R=0,U=0,D=0}
local Control = {F=0,B=0,L=0,R=0,U=0,D=0}
local BodyGyro, BodyVelocity
local Root = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")

function StartFly()
    Flying = true
    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.P = 9e4
    BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BodyGyro.CFrame = Root.CFrame
    BodyGyro.Parent = Root

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BodyVelocity.Parent = Root

    RunService = game:GetService("RunService")
    RunService.RenderStepped:Connect(function()
        if not Flying then return end
        local Camera = workspace.CurrentCamera
        BodyGyro.CFrame = Camera.CFrame

        Control.F = (Movement.F + Movement.B) * FlySpeed
        Control.R = (Movement.L + Movement.R) * FlySpeed
        Control.U = (Movement.U + Movement.D) * FlySpeed

        BodyVelocity.Velocity = ((Camera.CFrame.LookVector * Control.F) +
                                 (Camera.CFrame.RightVector * Control.R) +
                                 (Camera.CFrame.UpVector * Control.U))
    end)
end

function StopFly()
    Flying = false
    if BodyGyro then BodyGyro:Destroy() end
    if BodyVelocity then BodyVelocity:Destroy() end
end

UIS.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.W then Movement.F = 1 end
    if Input.KeyCode == Enum.KeyCode.S then Movement.B = -1 end
    if Input.KeyCode == Enum.KeyCode.A then Movement.L = -1 end
    if Input.KeyCode == Enum.KeyCode.D then Movement.R = 1 end
    if Input.KeyCode == Enum.KeyCode.Space then Movement.U = 1 end
    if Input.KeyCode == Enum.KeyCode.LeftControl then Movement.D = -1 end
end)

UIS.InputEnded:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.W then Movement.F = 0 end
    if Input.KeyCode == Enum.KeyCode.S then Movement.B = 0 end
    if Input.KeyCode == Enum.KeyCode.A then Movement.L = 0 end
    if Input.KeyCode == Enum.KeyCode.D then Movement.R = 0 end
    if Input.KeyCode == Enum.KeyCode.Space then Movement.U = 0 end
    if Input.KeyCode == Enum.KeyCode.LeftControl then Movement.D = 0 end
end)
