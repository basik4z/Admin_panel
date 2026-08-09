-- MOD MENU - РАБОЧАЯ ВЕРСИЯ
-- ВСЕ КОМАНДЫ В ВИДЕ КНОПОК

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- === ПЕРЕМЕННЫЕ ===
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local wallEnabled = false
local godEnabled = false
local invisEnabled = false
local buildMode = false
local bodyVelocity = nil
local bodyGyro = nil
local espBoxes = {}
local buildParts = {}

-- === УВЕДОМЛЕНИЯ ===
local function Notify(text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "MOD MENU",
        Text = text,
        Duration = duration or 2
    })
end

-- === ФУНКЦИЯ СОЗДАНИЯ КНОПОК ===
local function CreateButtons()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ModMenuGUI"
    ScreenGui.Parent = Player.PlayerGui
    ScreenGui.ResetOnSpawn = false
    
    -- Фон
    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.new(0, 0, 0)
    Background.BackgroundTransparency = 0.5
    Background.Parent = ScreenGui
    
    -- Окно
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.new(0.3, 0.6, 1)
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
    Title.Text = "MOD MENU"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    -- Скролл для кнопок
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -10, 1, -50)
    Scroll.Position = UDim2.new(0, 5, 0, 45)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
    Scroll.ScrollBarThickness = 5
    Scroll.Parent = MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 5)
    Layout.FillDirection = Enum.FillDirection.Vertical
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Scroll
    
    -- === СОЗДАНИЕ КНОПОК ===
    local function AddButton(text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.BackgroundColor3 = color or Color3.new(0.2, 0.3, 0.5)
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamMedium
        btn.Parent = Scroll
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    local function AddToggle(text, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 35)
        frame.BackgroundColor3 = Color3.new(0.2, 0.3, 0.5)
        frame.Parent = Scroll
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.GothamMedium
        label.Parent = frame
        
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 50, 0, 25)
        toggle.Position = UDim2.new(1, -55, 0.5, -12.5)
        toggle.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        toggle.Text = "OFF"
        toggle.TextColor3 = Color3.new(1, 1, 1)
        toggle.TextSize = 13
        toggle.Font = Enum.Font.GothamBold
        toggle.Parent = frame
        
        local tcorner = Instance.new("UICorner")
        tcorner.CornerRadius = UDim.new(0, 4)
        tcorner.Parent = toggle
        
        local state = false
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.BackgroundColor3 = state and Color3.new(0, 0.8, 0) or Color3.new(0.5, 0.5, 0.5)
            toggle.Text = state and "ON" or "OFF"
            callback(state)
        end)
    end
    
    -- === ВСЕ КНОПКИ ===
    AddToggle("✈️ Полет", function(state)
        flyEnabled = state
        if flyEnabled then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = RootPart
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 100000
            bodyGyro.Parent = RootPart
            Notify("Полет включен", 2)
        else
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            Notify("Полет выключен", 2)
        end
    end)
    
    AddToggle("🔮 Ноклип", function(state)
        noclipEnabled = state
        Notify(noclipEnabled and "Ноклип включен" or "Ноклип выключен", 2)
    end)
    
    AddToggle("🧱 Хождение по стенам", function(state)
        wallEnabled = state
        Notify(wallEnabled and "Хождение по стенам включено" or "Хождение по стенам выключено", 2)
    end)
    
    AddToggle("🛡️ Режим Бога", function(state)
        godEnabled = state
        if godEnabled then
            Humanoid.MaxHealth = 999999
            Humanoid.Health = 999999
            Notify("Режим Бога включен", 2)
        else
            Humanoid.MaxHealth = 100
            Humanoid.Health = 100
            Notify("Режим Бога выключен", 2)
        end
    end)
    
    AddToggle("👻 Невидимость", function(state)
        invisEnabled = state
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = invisEnabled and 1 or 0
            end
        end
        Notify(invisEnabled and "Невидимость включена" or "Невидимость выключена", 2)
    end)
    
    AddButton("🗡️ Бросок ножа", Color3.new(0.4, 0.4, 0.5), function()
        local knife = Instance.new("Tool")
        knife.Name = "Knife"
        knife.RequiresHandle = true
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(0.5, 0.1, 0.1)
        handle.Color3 = Color3.new(0.8, 0.8, 0.9)
        handle.Material = Enum.Material.Metal
        handle.Parent = knife
        local weld = Instance.new("Weld")
        weld.Part0 = handle
        weld.Part1 = Character:FindFirstChild("RightHand") or Character:FindFirstChild("Torso")
        weld.Parent = handle
        knife.Parent = Player.Backpack
        Notify("Нож создан", 2)
    end)
    
    AddButton("🔨 Дать молоток", Color3.new(0.5, 0.4, 0.1), function()
        local hammer = Instance.new("Tool")
        hammer.Name = "Hammer"
        hammer.RequiresHandle = true
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(1, 0.5, 0.5)
        handle.Color3 = Color3.new(0.8, 0.6, 0.2)
        handle.Material = Enum.Material.Wood
        handle.Parent = hammer
        local weld = Instance.new("Weld")
        weld.Part0 = handle
        weld.Part1 = Character:FindFirstChild("RightHand") or Character:FindFirstChild("Torso")
        weld.Parent = handle
        hammer.Parent = Player.Backpack
        Notify("Молоток получен", 2)
    end)
    
    AddButton("💥 Флинг всех", Color3.new(0.6, 0.1, 0.1), function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                local vel = Instance.new("BodyVelocity")
                vel.MaxForce = Vector3.new(1, 1, 1) * 999999
                vel.Velocity = Vector3.new(math.random(-500, 500), math.random(300, 800), math.random(-500, 500))
                vel.Parent = root
                task.wait(0.1)
                local vel2 = Instance.new("BodyVelocity")
                vel2.MaxForce = Vector3.new(1, 1, 1) * 999999
                vel2.Velocity = Vector3.new(math.random(-800, 800), math.random(500, 1000), math.random(-800, 800))
                vel2.Parent = root
                task.wait(2)
                vel:Destroy()
                vel2:Destroy()
            end
        end
        Notify("Все игроки улетели!", 2)
    end)
    
    AddButton("👥 Список игроков", Color3.new(0.2, 0.3, 0.6), function()
        local msg = "Игроки на сервере:\n"
        for _, player in pairs(Players:GetPlayers()) do
            msg = msg .. player.Name .. "\n"
        end
        Notify(msg, 5)
    end)
    
    -- Информация
    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1, -10, 0, 40)
    Info.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    Info.Text = "🌸 Добро пожаловать в MOD MENU!\nНажмите на кнопку для действия."
    Info.TextColor3 = Color3.new(0.7, 0.7, 0.8)
    Info.TextSize = 13
    Info.Font = Enum.Font.GothamMedium
    Info.TextWrapped = true
    Info.Parent = Scroll
    
    return MainFrame, Background
end

-- === СОЗДАНИЕ ПЛАВАЮЩЕЙ КНОПКИ ===
local MainFrame, Background = CreateButtons()
MainFrame.Visible = false
Background.Visible = false

local FloatingButton = Instance.new("TextButton")
FloatingButton.Size = UDim2.new(0, 55, 0, 55)
FloatingButton.Position = UDim2.new(1, -70, 0, 30)
FloatingButton.BackgroundColor3 = Color3.new(0.2, 0.3, 0.6)
FloatingButton.Text = "≡"
FloatingButton.TextColor3 = Color3.new(1, 1, 1)
FloatingButton.TextSize = 28
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.Parent = Player.PlayerGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 27)
FloatCorner.Parent = FloatingButton

FloatingButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    Background.Visible = not Background.Visible
end)

-- === ЛОГИКА РАБОТЫ ===

-- Полет
RunService.Heartbeat:Connect(function()
    if flyEnabled and bodyVelocity and bodyGyro then
        local moveDirection = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + RootPart.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - RootPart.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - RootPart.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + RootPart.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
        
        if moveDirection.Magnitude > 0 then
            bodyVelocity.Velocity = moveDirection.Unit * 30
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        bodyGyro.CFrame = RootPart.CFrame
    end
end)

-- Ноклип
RunService.Heartbeat:Connect(function()
    if noclipEnabled and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

Notify("MOD MENU загружен! Нажмите ≡", 3)