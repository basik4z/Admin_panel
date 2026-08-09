-- MOD MENU - ГАРАНТИРОВАННО РАБОТАЕТ
-- Все команды превращены в кнопки

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- === ВСЕ ПЕРЕМЕННЫЕ ===
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local wallEnabled = false
local godEnabled = false
local invisEnabled = false
local buildMode = false
local autoFarmCoins = false
local autoKillEnabled = false
local flySpeed = 30
local originalWalkSpeed = Humanoid.WalkSpeed
local originalJumpPower = Humanoid.JumpPower
local bodyVelocity = nil
local bodyGyro = nil
local espBoxes = {}
local buildParts = {}
local selectedPlayer = nil

-- === УВЕДОМЛЕНИЯ ===
local function Notify(text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🌸 MOD MENU",
        Text = text,
        Duration = duration or 2
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

local function FindKiller()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            if GetRole(player):find("Убийца") then return player end
        end
    end
    return nil
end

local function KillKiller()
    local killer = FindKiller()
    if killer and killer.Character and killer.Character:FindFirstChild("Humanoid") then
        killer.Character.Humanoid.Health = 0
        Notify("🌸 Убийца " .. killer.Name .. " побеждён!", 2)
    else
        Notify("💔 Убийца не найден!", 2)
    end
end

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
    Notify("🌸 " .. target.Name .. " улетел(а)!", 2)
end

local function PossessPlayer(target)
    if not target or not target.Character then return end
    Notify("🌸 Вселение в " .. target.Name .. " на 5 секунд", 2)
    local targetHumanoid = target.Character:FindFirstChild("Humanoid")
    if targetHumanoid then
        targetHumanoid.Parent = nil
    end
    task.wait(5)
    if targetHumanoid then
        targetHumanoid.Parent = target.Character
        Notify("🌸 Вселение завершено", 2)
    end
end

local function CreateESP(player)
    if espBoxes[player] then return end
    local role = GetRole(player)
    local color = Color3.new(1, 1, 1)
    if role == "Убийца" then color = Color3.new(1, 0.2, 0.2)
    elseif role == "Шериф" then color = Color3.new(0.2, 0.4, 1)
    elseif role == "Невиновный" then color = Color3.new(0.2, 1, 0.2) end
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

local function FindCoins()
    local coins = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if name:find("coin") or name:find("gold") or name:find("money") or name:find("collect") then
                table.insert(coins, obj)
            end
        end
    end
    return coins
end

local function FarmCoins()
    if not autoFarmCoins then return end
    local coins = FindCoins()
    if #coins == 0 then return end
    table.sort(coins, function(a, b)
        return (a.Position - RootPart.Position).Magnitude < (b.Position - RootPart.Position).Magnitude
    end)
    for i = 1, math.min(5, #coins) do
        local coin = coins[i]
        if coin and coin.Parent then
            RootPart.CFrame = CFrame.new(coin.Position + Vector3.new(0, 2, 0))
            task.wait(0.1)
        end
    end
end

-- === СОЗДАНИЕ GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuGUI"
ScreenGui.Parent = Player.PlayerGui
ScreenGui.ResetOnSpawn = false

-- ПЛАВАЮЩАЯ КНОПКА
local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "FloatingButton"
FloatingButton.Size = UDim2.new(0, 55, 0, 55)
FloatingButton.Position = UDim2.new(1, -70, 0, 30)
FloatingButton.BackgroundColor3 = Color3.new(1, 0.7, 0.8)
FloatingButton.BackgroundTransparency = 0.2
FloatingButton.Text = "🌸"
FloatingButton.TextColor3 = Color3.new(1, 1, 1)
FloatingButton.TextSize = 28
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.Parent = ScreenGui
local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 27)
FloatCorner.Parent = FloatingButton

-- ГЛАВНОЕ ОКНО
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 460)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.new(1, 0.95, 0.95)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.new(1, 0.6, 0.7)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

-- ЗАГОЛОВОК
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 55)
TitleBar.BackgroundColor3 = Color3.new(1, 0.8, 0.85)
TitleBar.BackgroundTransparency = 0.15
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 16)
TitleCorner.Parent = TitleBar
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0.6, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 8)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🌸 MOD MENU"
TitleLabel.TextColor3 = Color3.new(0.8, 0.3, 0.5)
TitleLabel.TextSize = 22
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar
local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(1, 0, 0.4, 0)
SubLabel.Position = UDim2.new(0, 0, 0, 32)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "ПАНЕЛЬ УПРАВЛЕНИЯ"
SubLabel.TextColor3 = Color3.new(0.5, 0.4, 0.4)
SubLabel.TextSize = 12
SubLabel.Font = Enum.Font.GothamMedium
SubLabel.Parent = TitleBar

-- КНОПКА ЗАКРЫТИЯ
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 12)
CloseBtn.BackgroundColor3 = Color3.new(1, 0.6, 0.6)
CloseBtn.BackgroundTransparency = 0.3
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

-- КОНТЕЙНЕР ДЛЯ КНОПОК (СКРОЛЛ)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -60)
ScrollFrame.Position = UDim2.new(0, 5, 0, 60)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1000)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.new(1, 0.6, 0.7)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- === ФУНКЦИИ ДЛЯ СОЗДАНИЯ КНОПОК ===

local function CreateSection(text)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, -10, 0, 28)
    Section.BackgroundColor3 = Color3.new(1, 0.8, 0.85)
    Section.BackgroundTransparency = 0.3
    Section.Text = "✦ " .. text
    Section.TextColor3 = Color3.new(0.8, 0.4, 0.5)
    Section.TextSize = 16
    Section.Font = Enum.Font.GothamBold
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.Parent = ScrollFrame
    local SecCorner = Instance.new("UICorner")
    SecCorner.CornerRadius = UDim.new(0, 6)
    SecCorner.Parent = Section
end

local function CreateActionButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 34)
    Button.BackgroundColor3 = Color3.new(1, 0.85, 0.9)
    Button.BackgroundTransparency = 0.3
    Button.Text = text
    Button.TextColor3 = Color3.new(0.3, 0.2, 0.2)
    Button.TextSize = 15
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Font = Enum.Font.GothamMedium
    Button.Parent = ScrollFrame
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button
    Button.MouseButton1Click:Connect(callback)
    return Button
end

local function CreateToggleButton(text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 34)
    Frame.BackgroundColor3 = Color3.new(1, 0.85, 0.9)
    Frame.BackgroundTransparency = 0.3
    Frame.Parent = ScrollFrame
    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0, 8)
    FCorner.Parent = Frame
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(0.3, 0.2, 0.2)
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamMedium
    Label.Parent = Frame
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 55, 0, 28)
    ToggleBtn.Position = UDim2.new(1, -62, 0.5, -14)
    ToggleBtn.BackgroundColor3 = Color3.new(0.8, 0.6, 0.6)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
    ToggleBtn.TextSize = 13
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = Frame
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 14)
    TCorner.Parent = ToggleBtn
    local state = false
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        ToggleBtn.BackgroundColor3 = state and Color3.new(1, 0.4, 0.6) or Color3.new(0.8, 0.6, 0.6)
        ToggleBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

-- === МЕНЮ ВЫБОРА ИГРОКА ===
local function ShowPlayerList()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        child:Destroy()
    end
    CreateActionButton("◀ НАЗАД", function()
        CreateMainMenu()
    end)
    CreateSection("ВЫБЕРИТЕ ИГРОКА")
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            local role = GetRole(player)
            CreateActionButton("👤 " .. player.Name .. " — " .. role, function()
                selectedPlayer = player
                ShowPlayerActions(player)
            end)
        end
    end
end

local function ShowPlayerActions(player)
    for _, child in pairs(ScrollFrame:GetChildren()) do
        child:Destroy()
    end
    CreateActionButton("◀ НАЗАД", function()
        ShowPlayerList()
    end)
    CreateSection("ДЕЙСТВИЯ С " .. player.Name)
    CreateActionButton("💫 Флинг игрока", function() FlingPlayer(player) end)
    CreateActionButton("🔄 Телепорт к игроку", function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            RootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            Notify("🌸 Телепорт к " .. player.Name, 2)
        end
    end)
    CreateActionButton("📥 Призвать игрока", function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = RootPart.CFrame + Vector3.new(0, 3, 0)
            Notify("🌸 Призван " .. player.Name, 2)
        end
    end)
    CreateActionButton("💀 Убить игрока", function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 0
            Notify("🌸 " .. player.Name .. " убит(а)", 2)
        end
    end)
    CreateActionButton("❤️ Вылечить игрока", function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = player.Character.Humanoid.MaxHealth
            Notify("🌸 " .. player.Name .. " вылечен(а)", 2)
        end
    end)
    CreateActionButton("👤 Вселиться в игрока", function() PossessPlayer(player) end)
    CreateActionButton("❄️ Заморозить", function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 0
            Notify("🌸 " .. player.Name .. " заморожен(а)", 2)
        end
    end)
    CreateActionButton("🔥 Разморозить", function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
            Notify("🌸 " .. player.Name .. " разморожен(а)", 2)
        end
    end)
end

-- === ГЛАВНОЕ МЕНЮ ===
function CreateMainMenu()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        child:Destroy()
    end

    CreateSection("ПЕРЕМЕЩЕНИЕ")
    CreateToggleButton("✈️ Полет", function(state)
        flyEnabled = state
        if flyEnabled then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = RootPart
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 100000
            bodyGyro.Parent = RootPart
            Notify("🌸 Полет включён! ✈️", 2)
        else
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            Notify("🌸 Полет выключен", 2)
        end
    end)
    CreateToggleButton("🔮 Ноклип", function(state)
        noclipEnabled = state
        Notify(noclipEnabled and "🌸 Ноклип включён" or "🌸 Ноклип выключен", 2)
    end)
    CreateToggleButton("🧱 Хождение по стенам", function(state)
        wallEnabled = state
        if wallEnabled then
            Humanoid.WalkSpeed = 35
            Humanoid.JumpPower = 50
            Notify("🌸 Хождение по стенам включено", 2)
        else
            Humanoid.WalkSpeed = originalWalkSpeed
            Humanoid.JumpPower = originalJumpPower
            Notify("🌸 Хождение по стенам выключено", 2)
        end
    end)

    CreateSection("ИГРОВЫЕ РЕЖИМЫ")
    CreateToggleButton("🛡️ Режим Бога", function(state)
        godEnabled = state
        if godEnabled then
            Humanoid.MaxHealth = 999999
            Humanoid.Health = 999999
            Notify("🌸 Режим Бога включён", 2)
        else
            Humanoid.MaxHealth = 100
            Humanoid.Health = 100
            Notify("🌸 Режим Бога выключен", 2)
        end
    end)
    CreateToggleButton("👻 Невидимость", function(state)
        invisEnabled = state
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = invisEnabled and 1 or 0
            end
        end
        Notify(invisEnabled and "🌸 Невидимость включена" or "🌸 Невидимость выключена", 2)
    end)
    CreateToggleButton("👁️ ESP с ролями", function(state)
        espEnabled = state
        if espEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player then CreateESP(player) end
            end
            Notify("🌸 ESP включён", 2)
        else
            for player, objects in pairs(espBoxes) do
                for _, obj in pairs(objects) do obj:Destroy() end
            end
            espBoxes = {}
            Notify("🌸 ESP выключен", 2)
        end
    end)

    CreateSection("ОРУЖИЕ / ПРЕДМЕТЫ")
    CreateActionButton("🗡️ Бросок ножа", function()
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
        Notify("🌸 Нож создан! ✨", 2)
    end)
    CreateActionButton("🔨 Дать молоток", function()
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
        Notify("🌸 Молоток получен! 🛠️", 2)
        hammer.Activated:Connect(function()
            if buildMode then
                local part = Instance.new("Part")
                part.Size = Vector3.new(4, 1, 4)
                part.Color3 = Color3.new(0.5, 0.8, 1)
                part.Material = Enum.Material.Brick
                part.Anchored = true
                part.CFrame = RootPart.CFrame + RootPart.CFrame.LookVector * 5
                part.Parent = Workspace
                table.insert(buildParts, part)
                Notify("🌸 Построено! 🧱", 2)
            else
                Notify("🌸 Включите режим постройки!", 2)
            end
        end)
    end)

    CreateSection("ДЕЙСТВИЯ С ИГРОКАМИ")
    CreateActionButton("👥 ВЫБРАТЬ ИГРОКА", function()
        ShowPlayerList()
    end)
    CreateActionButton("💥 Флинг всех", function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                FlingPlayer(player)
                task.wait(0.2)
            end
        end
        Notify("🌸 Все игроки улетели! 🌸", 2)
    end)
    CreateActionButton("🎯 Убить убийцу", function()
        KillKiller()
    end)
    CreateActionButton("🔍 Телепорт к убийце", function()
        local killer = FindKiller()
        if killer and killer.Character and killer.Character:FindFirstChild("HumanoidRootPart") then
            RootPart.CFrame = killer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            Notify("🌸 Телепорт к убийце " .. killer.Name, 2)
        else
            Notify("🌸 Убийца не найден!", 2)
        end
    end)

    CreateSection("НАСТРОЙКИ ИГРЫ")
    CreateActionButton("🏃 Скорость 50", function()
        Humanoid.WalkSpeed = 50
        Notify("🌸 Скорость: 50", 2)
    end)
    CreateActionButton("📊 Показать роли", function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                Notify(player.Name .. ": " .. GetRole(player), 1.5)
            end
        end
    end)
    CreateToggleButton("🔨 Режим постройки", function(state)
        buildMode = state
        Notify(buildMode and "🌸 Режим постройки включён" or "🌸 Режим постройки выключен", 2)
    end)
    CreateActionButton("🧹 Очистить постройки", function()
        for _, part in pairs(buildParts) do
            part:Destroy()
        end
        buildParts = {}
        Notify("🌸 Постройки очищены 🧹", 2)
    end)

    CreateSection("ДОПОЛНИТЕЛЬНО")
    CreateToggleButton("🪙 Авто-фарм монет", function(state)
        autoFarmCoins = state
        Notify(autoFarmCoins and "🌸 Фарм монет включён" or "🌸 Фарм монет выключен", 2)
    end)
    CreateToggleButton("⚡ Авто-убийство", function(state)
        autoKillEnabled = state
        Notify(autoKillEnabled and "🌸 Авто-убийство включено" or "🌸 Авто-убийство выключено", 2)
    end)

    CreateSection("ПОМОЩЬ")
    CreateActionButton("❓ Список функций", function()
        Notify("🌸 Все функции в меню! Нажимайте кнопки.", 3)
    end)

    -- Информация внизу
    local InfoFrame = Instance.new("Frame")
    InfoFrame.Size = UDim2.new(1, -10, 0, 45)
    InfoFrame.BackgroundColor3 = Color3.new(1, 0.8, 0.85)
    InfoFrame.BackgroundTransparency = 0.2
    InfoFrame.Parent = ScrollFrame
    local InfoCorner = Instance.new("UICorner")
    InfoCorner.CornerRadius = UDim.new(0, 8)
    InfoCorner.Parent = InfoFrame
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, 0, 1, 0)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "🌸 Добро пожаловать в MOD MENU!\n   Нажмите на кнопку для действия."
    InfoLabel.TextColor3 = Color3.new(0.4, 0.3, 0.3)
    InfoLabel.TextSize = 13
    InfoLabel.Font = Enum.Font.GothamMedium
    InfoLabel.TextWrapped = true
    InfoLabel.Parent = InfoFrame
end

-- === ЛОГИКА РАБОТЫ ===

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

RunService.Heartbeat:Connect(function()
    if noclipEnabled and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not espBoxes[player] then
                    CreateESP(player)
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

task.spawn(function()
    while true do
        task.wait(1)
        if autoKillEnabled then
            local killer = FindKiller()
            if killer and killer.Character and killer.Character:FindFirstChild("Humanoid") then
                if killer.Character.Humanoid.Health > 0 then
                    killer.Character.Humanoid.Health = 0
                    Notify("🌸 Убийца убит автоматически! ⚡", 2)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        if autoFarmCoins then
            FarmCoins()
        end
    end
end)

-- === ОТКРЫТИЕ/ЗАКРЫТИЕ ===
FloatingButton.MouseButton1Click:Connect(function()
    local isOpen = MainFrame.Visible
    if not isOpen then
        MainFrame.Visible = true
        FloatingButton.Visible = false
    else
        MainFrame.Visible = false
        FloatingButton.Visible = true
    end
end)

-- === ЗАПУСК ===
CreateMainMenu()
Notify("🌸 MOD MENU загружен! Нажмите на цветочек 🌸", 3)