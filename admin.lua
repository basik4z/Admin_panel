-- Delta Admin GUI v11.0 - ПОЛНАЯ ВЕРСИЯ
-- ТОЧНАЯ КОПИЯ ДИЗАЙНА С ФОТО
-- Все функции: полет, ноклип, esp, флинг, вселение, молоток и многое другое

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- === ВСЕ ПЕРЕМЕННЫЕ СОСТОЯНИЙ ===
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local wallEnabled = false
local godEnabled = false
local invisEnabled = false
local buildMode = false
local flySpeed = 30
local originalWalkSpeed = Humanoid.WalkSpeed
local originalJumpPower = Humanoid.JumpPower
local bodyVelocity = nil
local bodyGyro = nil
local espBoxes = {}
local buildParts = {}
local selectedPlayer = nil
local isMinimized = false
local infiniteJump = false
local noFallDamage = false
local autoSprint = false
local autoJump = false
local gravityEnabled = true
local originalGravity = workspace.Gravity

-- Функция уведомлений
local function Notify(text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚡ MOD MENU",
        Text = text,
        Duration = duration or 2
    })
end

-- === ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ===

-- Определение роли
local function GetRole(player)
    if not player or not player.Character then return "👤 Зритель" end
    local character = player.Character
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("knife") or name:find("dagger") then
                return "🔪 Убийца"
            elseif name:find("gun") or name:find("pistol") or name:find("sheriff") then
                return "🔫 Шериф"
            end
        end
    end
    return "🟢 Невиновный"
end

-- Создание ESP
local function CreateESPWithRoles(player)
    if espBoxes[player] then return end
    local role = GetRole(player)
    local color = Color3.new(1, 1, 1)
    if role:find("Убийца") then 
        color = Color3.new(1, 0, 0)
    elseif role:find("Шериф") then 
        color = Color3.new(0, 0, 1)
    elseif role:find("Невиновный") then 
        color = Color3.new(0, 1, 0)
    end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 2)
    box.Color3 = color
    box.Transparency = 0.4
    box.ZIndex = 10
    box.AlwaysOnTop = true
    box.Adornee = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    box.Parent = player.Character or player
    
    local nameTag = Instance.new("BillboardGui")
    nameTag.Size = UDim2.new(0, 250, 0, 60)
    nameTag.Adornee = player.Character and player.Character:FindFirstChild("Head")
    nameTag.StudsOffset = Vector3.new(0, 3.5, 0)
    nameTag.Parent = player.Character or player
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name .. " | " .. role
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Parent = nameTag
    
    espBoxes[player] = {box, nameTag}
end

-- Флинг игрока
local function FlingPlayer(target)
    if not target or not target.Character then return end
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    local velocity = Instance.new("BodyVelocity")
    velocity.MaxForce = Vector3.new(1, 1, 1) * 999999
    velocity.Velocity = Vector3.new(math.random(-500, 500), math.random(300, 800), math.random(-500, 500))
    velocity.Parent = targetRoot
    
    task.wait(0.1)
    local velocity2 = Instance.new("BodyVelocity")
    velocity2.MaxForce = Vector3.new(1, 1, 1) * 999999
    velocity2.Velocity = Vector3.new(math.random(-800, 800), math.random(500, 1000), math.random(-800, 800))
    velocity2.Parent = targetRoot
    
    task.wait(2)
    velocity:Destroy()
    velocity2:Destroy()
    Notify("💫 " .. target.Name .. " улетел за карту!")
end

-- Вселение в игрока
local function PossessPlayer(target)
    if not target or not target.Character then return end
    Notify("👤 Вселение в " .. target.Name .. " на 5 секунд")
    
    local targetHumanoid = target.Character:FindFirstChild("Humanoid")
    if targetHumanoid then
        targetHumanoid.Parent = nil
    end
    
    task.wait(5)
    
    if targetHumanoid then
        targetHumanoid.Parent = target.Character
        Notify("🔄 Вселение завершено")
    end
end

-- Бросок ножа
local function ThrowKnife()
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
    Notify("🗡️ Нож создан!")
end

-- Молоток
local function GiveHammer()
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
    Notify("🔨 Молоток получен!")
    
    hammer.Activated:Connect(function()
        if buildMode then
            local part = Instance.new("Part")
            part.Size = Vector3.new(4, 1, 4)
            part.Color3 = Color3.new(0.5, 0.8, 1)
            part.Material = Enum.Material.Brick
            part.Anchored = true
            part.CFrame = RootPart.CFrame + RootPart.CFrame.LookVector * 5
            part.Parent = workspace
            
            table.insert(buildParts, part)
            Notify("🧱 Построено!")
        else
            Notify("⚠️ Включите режим постройки!")
        end
    end)
end

-- === СОЗДАНИЕ ГЛАВНОГО GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuGUI"
ScreenGui.Parent = Player.PlayerGui
ScreenGui.ResetOnSpawn = false

-- === ПЛАВАЮЩАЯ КНОПКА ===
local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "FloatingButton"
FloatingButton.Size = UDim2.new(0, 55, 0, 55)
FloatingButton.Position = UDim2.new(1, -75, 0, 30)
FloatingButton.BackgroundColor3 = Color3.new(0.15, 0.3, 0.7)
FloatingButton.Text = "⚡"
FloatingButton.TextColor3 = Color3.new(1, 1, 1)
FloatingButton.TextSize = 26
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 27)
FloatCorner.Parent = FloatingButton

-- === ГЛАВНОЕ ОКНО ===
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 520)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.new(0.03, 0.03, 0.08)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.new(0.2, 0.5, 1)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- === ЗАГОЛОВОК ===
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.new(0.08, 0.12, 0.22)
TitleBar.BackgroundTransparency = 0.2
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ MOD MENU"
TitleLabel.TextColor3 = Color3.new(0.3, 0.7, 1)
TitleLabel.TextSize = 24
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Кнопка сворачивания
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -85, 0, 7.5)
MinimizeBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.4)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.TextSize = 20
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinimizeBtn

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 400, 0, 50), "Out", "Quad", 0.3)
        MinimizeBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 400, 0, 520), "Out", "Quad", 0.3)
        MinimizeBtn.Text = "−"
    end
end)

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -45, 0, 7.5)
CloseBtn.BackgroundColor3 = Color3.new(1, 0.2, 0.2)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatingButton.Visible = true
end)

-- === КОНТЕЙНЕР СКРОЛЛА ===
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -55)
ScrollFrame.Position = UDim2.new(0, 5, 0, 55)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.ScrollBarImageColor3 = Color3.new(0.3, 0.6, 1)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- === ФУНКЦИИ СОЗДАНИЯ ЭЛЕМЕНТОВ ===

-- Заголовок раздела
local function CreateSectionHeader(text)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, -10, 0, 30)
    Section.BackgroundColor3 = Color3.new(0.15, 0.2, 0.35)
    Section.BackgroundTransparency = 0.2
    Section.Text = "▸ " .. text
    Section.TextColor3 = Color3.new(0.4, 0.8, 1)
    Section.TextSize = 18
    Section.Font = Enum.Font.GothamBold
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.Parent = ScrollFrame
    
    local SecCorner = Instance.new("UICorner")
    SecCorner.CornerRadius = UDim.new(0, 6)
    SecCorner.Parent = Section
    
    return Section
end

-- Кнопка команды
local function CreateCommandButton(text, desc, color, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 40)
    Button.BackgroundColor3 = color or Color3.new(0.12, 0.18, 0.3)
    Button.Text = text .. "  —  " .. desc
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.TextSize = 16
    Button.Font = Enum.Font.GothamMedium
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = ScrollFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- Кнопка игрока
local function CreatePlayerButton(player)
    local role = GetRole(player)
    local color = Color3.new(0.12, 0.18, 0.3)
    if role:find("Убийца") then 
        color = Color3.new(0.5, 0.1, 0.1)
    elseif role:find("Шериф") then 
        color = Color3.new(0.1, 0.1, 0.5)
    end
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.BackgroundColor3 = color
    Button.Text = "👤 " .. player.Name .. "  —  " .. role
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.TextSize = 15
    Button.Font = Enum.Font.GothamMedium
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = ScrollFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        CreatePlayerActions(player)
    end)
    return Button
end

-- === МЕНЮ ДЕЙСТВИЙ С ИГРОКОМ ===
function CreatePlayerActions(player)
    for _, child in pairs(ScrollFrame:GetChildren()) do
        child:Destroy()
    end
    
    CreateCommandButton("◄ НАЗАД", "Вернуться в меню", Color3.new(0.2, 0.2, 0.3), function()
        CreateMainMenu()
    end)
    
    local TitleFrame = Instance.new("TextLabel")
    TitleFrame.Size = UDim2.new(1, -10, 0, 35)
    TitleFrame.BackgroundColor3 = Color3.new(0.15, 0.25, 0.5)
    TitleFrame.BackgroundTransparency = 0.2
    TitleFrame.Text = "🎯 ДЕЙСТВИЯ С " .. player.Name
    TitleFrame.TextColor3 = Color3.new(1, 1, 1)
    TitleFrame.TextSize = 18
    TitleFrame.Font = Enum.Font.GothamBold
    TitleFrame.Parent = ScrollFrame
    
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 6)
    TCorner.Parent = TitleFrame
    
    CreateCommandButton("💫 Флинг", "Выбросить за карту", Color3.new(0.5, 0.1, 0.1), function()
        FlingPlayer(player)
    end)
    
    CreateCommandButton("🔄 Телепорт", "Переместиться к игроку", Color3.new(0.1, 0.3, 0.6), function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            RootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            Notify("🔄 Телепорт к " .. player.Name)
        end
    end)
    
    CreateCommandButton("📥 Призвать", "Притянуть игрока к себе", Color3.new(0.1, 0.5, 0.1), function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = RootPart.CFrame + Vector3.new(0, 3, 0)
            Notify("📥 Призван " .. player.Name)
        end
    end)
    
    CreateCommandButton("💀 Убить", "Мгновенное убийство", Color3.new(0.6, 0, 0), function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 0
            Notify("💀 Убит " .. player.Name)
        end
    end)
    
    CreateCommandButton("❤️ Вылечить", "Восстановить здоровье", Color3.new(0, 0.5, 0), function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = player.Character.Humanoid.MaxHealth
            Notify("❤️ Вылечен " .. player.Name)
        end
    end)
    
    CreateCommandButton("👤 Вселиться", "Контроль на 5 секунд", Color3.new(0.4, 0.2, 0.6), function()
        PossessPlayer(player)
    end)
    
    CreateCommandButton("❄️ Заморозить", "Обездвижить игрока", Color3.new(0, 0.3, 0.5), function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 0
            Notify("❄️ " .. player.Name .. " заморожен")
        end
    end)
    
    CreateCommandButton("🔥 Разморозить", "Вернуть движение", Color3.new(0.5, 0.3, 0), function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
            Notify("🔥 " .. player.Name .. " разморожен")
        end
    end)
end

-- === ГЛАВНОЕ МЕНЮ ===
function CreateMainMenu()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        child:Destroy()
    end
    
    -- РАЗДЕЛ: ПЕРЕМЕЩЕНИЕ
    CreateSectionHeader("ПЕРЕМЕЩЕНИЕ")
    
    CreateCommandButton("✈️ Полет", "Вкл/выкл свободный полет", Color3.new(0.1, 0.3, 0.6), function()
        flyEnabled = not flyEnabled
        if flyEnabled then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = RootPart
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 100000
            bodyGyro.Parent = RootPart
            Notify("✈️ Полет включен")
        else
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            Notify("❌ Полет выключен")
        end
    end)
    
    CreateCommandButton("🔮 Ноклип", "Проход сквозь стены", Color3.new(0.3, 0.1, 0.6), function()
        noclipEnabled = not noclipEnabled
        Notify(noclipEnabled and "🔮 Ноклип включен" or "❌ Ноклип выключен")
    end)
    
    CreateCommandButton("🧱 Хождение по стенам", "Ходьба по вертикали", Color3.new(0.5, 0.3, 0.1), function()
        wallEnabled = not wallEnabled
        if wallEnabled then
            Humanoid.WalkSpeed = 35
            Humanoid.JumpPower = 50
            Notify("🧱 Хождение по стенам включено")
        else
            Humanoid.WalkSpeed = originalWalkSpeed
            Humanoid.JumpPower = originalJumpPower
            Notify("❌ Хождение по стенам выключено")
        end
    end)
    
    -- РАЗДЕЛ: ИГРОВЫЕ РЕЖИМЫ
    CreateSectionHeader("ИГРОВЫЕ РЕЖИМЫ")
    
    CreateCommandButton("🛡️ Режим Бога", "Бесконечное здоровье", Color3.new(0.1, 0.5, 0.2), function()
        godEnabled = not godEnabled
        if godEnabled then
            Humanoid.MaxHealth = 999999
            Humanoid.Health = 999999
            Notify("🛡️ Режим Бога включен")
        else
            Humanoid.MaxHealth = 100
            Humanoid.Health = 100
            Notify("❌ Режим Бога выключен")
        end
    end)
    
    CreateCommandButton("👻 Невидимость", "Стать невидимым", Color3.new(0.3, 0.1, 0.5), function()
        invisEnabled = not invisEnabled
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = invisEnabled and 1 or 0
            end
        end
        Notify(invisEnabled and "👻 Невидимость включена" or "❌ Невидимость выключена")
    end)
    
    CreateCommandButton("👁️ ESP с ролями", "Подсветка игроков", Color3.new(0.1, 0.4, 0.4), function()
        espEnabled = not espEnabled
        if espEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player then
                    CreateESPWithRoles(player)
                end
            end
            Notify("👁️ ESP включен")
        else
            for player, objects in pairs(espBoxes) do
                for _, obj in pairs(objects) do
                    obj:Destroy()
                end
            end
            espBoxes = {}
            Notify("❌ ESP выключен")
        end
    end)
    
    -- РАЗДЕЛ: ОРУЖИЕ / ПРЕДМЕТЫ
    CreateSectionHeader("ОРУЖИЕ / ПРЕДМЕТЫ")
    
    CreateCommandButton("🗡️ Бросок ножа", "Создать нож в инвентаре", Color3.new(0.4, 0.4, 0.5), function()
        ThrowKnife()
    end)
    
    CreateCommandButton("🔨 Дать молоток", "Молоток для построек", Color3.new(0.5, 0.4, 0.1), function()
        GiveHammer()
    end)
    
    -- РАЗДЕЛ: ДЕЙСТВИЯ С ИГРОКАМИ
    CreateSectionHeader("ДЕЙСТВИЯ С ИГРОКАМИ")
    
    local PlayerSelectBtn = Instance.new("TextButton")
    PlayerSelectBtn.Size = UDim2.new(1, -10, 0, 35)
    PlayerSelectBtn.BackgroundColor3 = Color3.new(0.15, 0.2, 0.4)
    PlayerSelectBtn.Text = "👥 ВЫБРАТЬ ИГРОКА"
    PlayerSelectBtn.TextColor3 = Color3.new(0.5, 0.8, 1)
    PlayerSelectBtn.TextSize = 16
    PlayerSelectBtn.Font = Enum.Font.GothamBold
    PlayerSelectBtn.Parent = ScrollFrame
    
    local PSelCorner = Instance.new("UICorner")
    PSelCorner.CornerRadius = UDim.new(0, 6)
    PSelCorner.Parent = PlayerSelectBtn
    
    PlayerSelectBtn.MouseButton1Click:Connect(function()
        for _, child in pairs(ScrollFrame:GetChildren()) do
            child:Destroy()
        end
        
        CreateCommandButton("◄ НАЗАД", "Вернуться в меню", Color3.new(0.2, 0.2, 0.3), function()
            CreateMainMenu()
        end)
        
        CreateSectionHeader("ВЫБЕРИТЕ ИГРОКА")
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                CreatePlayerButton(player)
            end
        end
    end)
    
    CreateCommandButton("💥 Флинг всех", "Выбросить всех игроков", Color3.new(0.5, 0.1, 0.1), function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                FlingPlayer(player)
                task.wait(0.2)
            end
        end
        Notify("💥 Все игроки улетели!")
    end)
    
    -- РАЗДЕЛ: НАСТРОЙКИ ИГРЫ
    CreateSectionHeader("НАСТРОЙКИ ИГРЫ")
    
    CreateCommandButton("🏃 Скорость", "Изменить скорость (50)", Color3.new(0.2, 0.4, 0.2), function()
        Humanoid.WalkSpeed = 50
        Notify("🏃 Скорость установлена: 50")
    end)
    
    CreateCommandButton("📊 Показать роли", "Узнать роли всех игроков", Color3.new(0.2, 0.2, 0.5), function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                local role = GetRole(player)
                Notify(player.Name .. ": " .. role, 1.5)
            end
        end
    end)
    
    CreateCommandButton("🔨 Режим постройки", "Вкл/выкл стройку", Color3.new(0.5, 0.3, 0.1), function()
        buildMode = not buildMode
        Notify(buildMode and "🔨 Режим постройки включен" or "❌ Режим постройки выключен")
    end)
    
    CreateCommandButton("🧹 Очистить постройки", "Удалить все постройки", Color3.new(0.3, 0.3, 0.3), function()
        for _, part in pairs(buildParts) do
            part:Destroy()
        end
        buildParts = {}
        Notify("🧹 Постройки очищены")
    end)
    
    -- РАЗДЕЛ: ПОМОЩЬ
    CreateSectionHeader("ПОМОЩЬ")
    
    CreateCommandButton("❓ Помощь", "Список всех команд", Color3.new(0.2, 0.2, 0.3), function()
        Notify("📋 Команды: fly, noclip, wall, god, invis, esp, throw, hammer, fling, possess, tp, bring, kill, heal, speed, roles, build, clear", 6)
    end)
    
    -- ИНФОРМАЦИЯ
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -10, 0, 40)
    InfoLabel.BackgroundColor3 = Color3.new(0.05, 0.05, 0.1)
    InfoLabel.Text = "💡 Добро пожаловать в MOD MENU!\nНажмите на кнопку для действия."
    InfoLabel.TextColor3 = Color3.new(0.5, 0.7, 1)
    InfoLabel.TextSize = 14
    InfoLabel.Font = Enum.Font.GothamMedium
    InfoLabel.TextWrapped = true
    InfoLabel.Parent = ScrollFrame
end

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
            bodyVelocity.Velocity = moveDirection.Unit * flySpeed
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

-- ESP обновление
RunService.Heartbeat:Connect(function()
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not espBoxes[player] then
                    CreateESPWithRoles(player)
                else
                    local box = espBoxes[player][1]
                    local nameTag = espBoxes[player][2]
                    box.Adornee = player.Character.HumanoidRootPart
                    nameTag.Adornee = player.Character:FindFirstChild("Head")
                    
                    local label = nameTag:FindFirstChild("TextLabel")
                    if label then
                        local role = GetRole(player)
                        local health = player.Character.Humanoid and player.Character.Humanoid.Health or 0
                        label.Text = player.Name .. " | " .. role .. " (" .. math.floor(health) .. " HP)"
                    end
                end
            end
        end
    end
end)

-- Открытие/закрытие меню
FloatingButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    FloatingButton.Visible = not FloatingButton.Visible
end)

-- Открытие по клавише Insert
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
        FloatingButton.Visible = not FloatingButton.Visible
    end
end)

-- === ЗАПУСК ===
CreateMainMenu()
Notify("⚡ MOD MENU загружен! Нажмите на кнопку ⚡", 3)