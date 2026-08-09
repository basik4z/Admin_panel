-- ========================================
-- admin.lua — ПОЛЁТ ЧЕРЕЗ ДЖОЙСТИК ХОДЬБЫ
-- ========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer

-- === ОБНОВЛЯЕМЫЕ ССЫЛКИ ===
local function getChar()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function getHumanoid()
    local c = getChar()
    return c and c:FindFirstChild("Humanoid")
end

local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- === ПЕРЕМЕННЫЕ ===
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local wallEnabled = false
local godEnabled = false
local invisEnabled = false
local buildMode = false
local flySpeed = 30
local espBoxes = {}
local buildParts = {}
local selectedPlayer = nil
local bodyVelocity = nil
local bodyGyro = nil

-- === УВЕДОМЛЕНИЯ ===
local function Notify(text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "MOD MENU",
        Text = text,
        Duration = 2
    })
end

-- === ОПРЕДЕЛЕНИЕ РОЛИ ===
local function GetRole(player)
    if not player or not player.Character then return "Зритель" end
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("knife") or name:find("dagger") then return "Убийца" end
            if name:find("gun") or name:find("pistol") or name:find("sheriff") then return "Шериф" end
        end
    end
    return "Невиновный"
end

-- === ESP ===
local function CreateESP(player)
    if espBoxes[player] then return end
    local role = GetRole(player)
    local color = role == "Убийца" and Color3.new(1,0,0) or role == "Шериф" and Color3.new(0,0,1) or Color3.new(0,1,0)
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 2)
    box.Color3 = color
    box.Transparency = 0.4
    box.ZIndex = 10
    box.AlwaysOnTop = true
    box.Adornee = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    box.Parent = player.Character or player
    local tag = Instance.new("BillboardGui")
    tag.Size = UDim2.new(0, 250, 0, 60)
    tag.Adornee = player.Character and player.Character:FindFirstChild("Head")
    tag.StudsOffset = Vector3.new(0, 3.5, 0)
    tag.Parent = player.Character or player
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name .. " | " .. role
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Parent = tag
    espBoxes[player] = {box, tag}
end

-- === ФЛИНГ ===
local function FlingPlayer(target)
    if not target or not target.Character then return end
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
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
    Notify("💫 " .. target.Name .. " улетел(а)!")
end

-- === СОЗДАНИЕ GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuGUI"
ScreenGui.Parent = Player.PlayerGui
ScreenGui.ResetOnSpawn = false

-- === КНОПКА ОТКРЫТИЯ ===
local FloatingButton = Instance.new("TextButton")
FloatingButton.Size = UDim2.new(0, 55, 0, 55)
FloatingButton.Position = UDim2.new(1, -70, 0, 30)
FloatingButton.BackgroundColor3 = Color3.new(0.2, 0.3, 0.6)
FloatingButton.Text = "≡"
FloatingButton.TextColor3 = Color3.new(1, 1, 1)
FloatingButton.TextSize = 28
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 27)
FloatCorner.Parent = FloatingButton

-- === ГЛАВНОЕ ОКНО ===
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 460)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.new(0.08, 0.08, 0.12)
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.new(0.3, 0.6, 1)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

-- === ЗАГОЛОВОК ===
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.new(0.15, 0.2, 0.35)
TitleBar.BackgroundTransparency = 0.2
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ MOD MENU"
TitleLabel.TextColor3 = Color3.new(0.4, 0.8, 1)
TitleLabel.TextSize = 20
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- === КРЕСТИК ЗАКРЫТИЯ ===
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 6)
CloseBtn.BackgroundColor3 = Color3.new(1, 0.2, 0.2)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatingButton.Visible = true
end)

-- === ПЕРЕТАСКИВАНИЕ ===
local isDragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if isDragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

-- === СКРОЛЛ ===
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -55)
Scroll.Position = UDim2.new(0, 5, 0, 50)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 5
Scroll.ScrollBarImageColor3 = Color3.new(0.3, 0.6, 1)
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 4)
Layout.FillDirection = Enum.FillDirection.Vertical
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

-- === КНОПКИ ===
local function AddSection(text)
    local sec = Instance.new("TextLabel")
    sec.Size = UDim2.new(1, -10, 0, 26)
    sec.BackgroundColor3 = Color3.new(0.15, 0.2, 0.35)
    sec.BackgroundTransparency = 0.3
    sec.Text = "▸ " .. text
    sec.TextColor3 = Color3.new(0.4, 0.8, 1)
    sec.TextSize = 15
    sec.Font = Enum.Font.GothamBold
    sec.TextXAlignment = Enum.TextXAlignment.Left
    sec.Parent = Scroll
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 6)
    sc.Parent = sec
end

local function AddButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 36)
    btn.BackgroundColor3 = color or Color3.new(0.2, 0.3, 0.5)
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 15
    btn.TextXAlignment = Enum.TextXAlignment.Left
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
    frame.Size = UDim2.new(1, -10, 0, 36)
    frame.BackgroundColor3 = Color3.new(0.2, 0.3, 0.5)
    frame.Parent = Scroll
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 55, 0, 28)
    toggle.Position = UDim2.new(1, -63, 0.5, -14)
    toggle.BackgroundColor3 = Color3.new(0.4, 0.4, 0.5)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.TextSize = 13
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = frame
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 14)
    tc.Parent = toggle
    
    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.new(0, 0.8, 0) or Color3.new(0.4, 0.4, 0.5)
        toggle.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

-- === СОЗДАНИЕ МЕНЮ ===
local function BuildMenu()
    -- Очищаем старые кнопки
    for _, child in pairs(Scroll:GetChildren()) do
        child:Destroy()
    end
    
    AddSection("ПЕРЕМЕЩЕНИЕ")
    
    -- ПОЛЁТ (управление через джойстик ходьбы)
    AddToggle("✈️ Fly", function(state)
        flyEnabled = state
        if flyEnabled then
            local root = getRoot()
            if not root then return end
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = root
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 100000
            bodyGyro.Parent = root
            Notify("✈️ Полет включён")
        else
            if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
            if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
            Notify("❌ Полет выключен")
        end
    end)
    
    AddToggle("🔮 Noclip", function(state)
        noclipEnabled = state
        Notify(noclipEnabled and "🔮 Ноклип включён" or "❌ Ноклип выключен")
    end)
    
    AddToggle("🧱 Wall Walk", function(state)
        wallEnabled = state
        local humanoid = getHumanoid()
        if not humanoid then return end
        if wallEnabled then
            humanoid.WalkSpeed = 35
            humanoid.JumpPower = 50
            Notify("🧱 Хождение по стенам включено")
        else
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            Notify("❌ Хождение по стенам выключено")
        end
    end)
    
    AddButton("🏃 Speed 50", Color3.new(0.2, 0.4, 0.2), function()
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 50
            Notify("🏃 Скорость: 50")
        end
    end)
    
    AddSection("ESP")
    AddToggle("👁️ ESP ON/OFF", function(state)
        espEnabled = state
        if espEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player then CreateESP(player) end
            end
            Notify("👁️ ESP включён")
        else
            for player, objects in pairs(espBoxes) do
                for _, obj in pairs(objects) do obj:Destroy() end
            end
            espBoxes = {}
            Notify("❌ ESP выключен")
        end
    end)
    
    AddSection("ИГРОКИ")
    
    local function ShowPlayerList()
        for _, child in pairs(Scroll:GetChildren()) do
            child:Destroy()
        end
        AddSection("ВЫБЕРИТЕ ИГРОКА")
        AddButton("◀ НАЗАД", Color3.new(0.3, 0.3, 0.4), BuildMenu)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                local role = GetRole(player)
                AddButton("👤 " .. player.Name .. " — " .. role, Color3.new(0.15, 0.25, 0.5), function()
                    selectedPlayer = player
                    Notify("✅ Выбран: " .. player.Name)
                end)
            end
        end
    end
    
    AddButton("👥 Список игроков", Color3.new(0.15, 0.3, 0.6), ShowPlayerList)
    
    AddSection("ДЕЙСТВИЯ")
    
    AddButton("💫 Fling", Color3.new(0.5, 0.1, 0.1), function()
        if selectedPlayer then FlingPlayer(selectedPlayer) else Notify("⚠️ Выберите игрока") end
    end)
    
    AddButton("🔄 Teleport", Color3.new(0.1, 0.3, 0.6), function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = getRoot()
            if root then
                root.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                Notify("🔄 Телепорт к " .. selectedPlayer.Name)
            end
        else
            Notify("⚠️ Выберите игрока")
        end
    end)
    
    AddButton("📥 Bring", Color3.new(0.1, 0.5, 0.1), function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = getRoot()
            if root then
                selectedPlayer.Character.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0, 3, 0)
                Notify("📥 Призван " .. selectedPlayer.Name)
            end
        else
            Notify("⚠️ Выберите игрока")
        end
    end)
    
    AddButton("❤️ Heal", Color3.new(0, 0.6, 0), function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
            selectedPlayer.Character.Humanoid.Health = selectedPlayer.Character.Humanoid.MaxHealth
            Notify("❤️ Вылечен " .. selectedPlayer.Name)
        else
            Notify("⚠️ Выберите игрока")
        end
    end)
    
    AddButton("💀 Kill", Color3.new(0.6, 0, 0), function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
            selectedPlayer.Character.Humanoid.Health = 0
            Notify("💀 Убит " .. selectedPlayer.Name)
        else
            Notify("⚠️ Выберите игрока")
        end
    end)
    
    AddSection("ПРЕДМЕТЫ")
    
    AddButton("🗡️ Throw", Color3.new(0.4, 0.4, 0.5), function()
        local c = getChar()
        if not c then return end
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
        weld.Part1 = c:FindFirstChild("RightHand") or c:FindFirstChild("Torso")
        weld.Parent = handle
        knife.Parent = Player.Backpack
        Notify("🗡️ Нож создан")
    end)
    
    AddButton("🔨 Hammer", Color3.new(0.5, 0.4, 0.1), function()
        local c = getChar()
        if not c then return end
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
        weld.Part1 = c:FindFirstChild("RightHand") or c:FindFirstChild("Torso")
        weld.Parent = handle
        hammer.Parent = Player.Backpack
        Notify("🔨 Молоток получен")
    end)
    
    AddSection("СТРОЙКА")
    
    AddToggle("🔨 Build ON/OFF", function(state)
        buildMode = state
        Notify(buildMode and "🔨 Режим постройки включён" or "❌ Режим постройки выключен")
    end)
    
    AddButton("🧹 Clear", Color3.new(0.3, 0.3, 0.3), function()
        for _, part in pairs(buildParts) do
            part:Destroy()
        end
        buildParts = {}
        Notify("🧹 Постройки очищены")
    end)
    
    AddSection("ДОПОЛНИТЕЛЬНО")
    
    AddButton("📊 Roles", Color3.new(0.2, 0.2, 0.5), function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                Notify(player.Name .. ": " .. GetRole(player), 1.5)
            end
        end
    end)
    
    AddButton("❓ Help", Color3.new(0.2, 0.2, 0.3), function()
        Notify("⚡ Все функции в меню! Нажимайте кнопки.", 4)
    end)
    
    -- Информация внизу
    local InfoFrame = Instance.new("Frame")
    InfoFrame.Size = UDim2.new(1, -10, 0, 40)
    InfoFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    InfoFrame.Parent = Scroll
    local InfoCorner = Instance.new("UICorner")
    InfoCorner.CornerRadius = UDim.new(0, 6)
    InfoCorner.Parent = InfoFrame
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, 0, 1, 0)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "📌 Добро пожаловать в MOD MENU!\n   Нажмите на кнопку для действия."
    InfoLabel.TextColor3 = Color3.new(0.6, 0.6, 0.8)
    InfoLabel.TextSize = 13
    InfoLabel.Font = Enum.Font.GothamMedium
    InfoLabel.TextWrapped = true
    InfoLabel.Parent = InfoFrame
end

-- === ЛОГИКА ПОЛЁТА (через джойстик ходьбы) ===
RunService.Heartbeat:Connect(function()
    if not flyEnabled then return end
    local root = getRoot()
    if not root then return end
    if not bodyVelocity or not bodyGyro then return end
    
    -- Получаем направление движения из джойстика
    local humanoid = getHumanoid()
    if not humanoid then return end
    
    -- Движение вперёд/назад/влево/вправо из джойстика
    local moveDirection = humanoid.MoveDirection
    if moveDirection.Magnitude > 0 then
        -- Используем MoveDirection от джойстика
        bodyVelocity.Velocity = moveDirection * flySpeed
        bodyGyro.CFrame = root.CFrame
    else
        -- Если джойстик не двигается, зависаем на месте
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyGyro.CFrame = root.CFrame
    end
    
    -- Вверх/вниз через кнопки (для телефона)
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        bodyVelocity.Velocity = Vector3.new(0, flySpeed, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        bodyVelocity.Velocity = Vector3.new(0, -flySpeed, 0)
    end
end)

-- === НОКЛИП ===
RunService.Heartbeat:Connect(function()
    local c = getChar()
    if not c then return end
    for _, part in pairs(c:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noclipEnabled
        end
    end
end)

-- === ESP ===
RunService.Heartbeat:Connect(function()
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not espBoxes[player] then
                    CreateESP(player)
                end
            end
        end
    end
end)

-- === ОБНОВЛЕНИЕ ESP ===
Players.PlayerRemoving:Connect(function(player)
    if espBoxes[player] then
        for _, obj in pairs(espBoxes[player]) do obj:Destroy() end
        espBoxes[player] = nil
    end
end)

-- === ОТКРЫТИЕ/ЗАКРЫТИЕ ===
FloatingButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    FloatingButton.Visible = not FloatingButton.Visible
end)

-- === ЗАПУСК ===
BuildMenu()
Notify("⚡ MOD MENU загружен! Нажмите ≡", 3)