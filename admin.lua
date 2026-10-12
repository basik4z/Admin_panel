-- ==========================================
-- YARHM STYLE MENU — Murder Mystery 2
-- Адаптировано для телефона (Delta)
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local espBoxes = {}

-- === ПЕРЕМЕННЫЕ ===
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local autoKillEnabled = false
local autoFarmEnabled = false
local flySpeed = 50
local bodyVelocity, bodyGyro

-- === ССЫЛКИ ===
local function getChar() return Player.Character end
local function getHumanoid() return getChar() and getChar():FindFirstChildOfClass("Humanoid") end
local function getRoot() return getChar() and getChar():FindFirstChild("HumanoidRootPart") end

-- === ОПРЕДЕЛЕНИЕ РОЛИ (БЕЗОПАСНО) ===
local function GetRole(target)
    if not target or not target.Character then return "Innocent" end
    
    -- Проверка в руках
    for _, tool in pairs(target.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("knife") or name:find("dagger") then return "Murderer" end
            if name:find("gun") or name:find("pistol") or name:find("sheriff") then return "Sheriff" end
        end
    end
    
    -- Проверка в рюкзаке (безопасно)
    local backpack = target:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("knife") or name:find("dagger") then return "Murderer" end
                if name:find("gun") or name:find("pistol") or name:find("sheriff") then return "Sheriff" end
            end
        end
    end
    
    return "Innocent"
end

-- === ESP ===
local function RemoveESP(target)
    if espBoxes[target] then
        if espBoxes[target].box then espBoxes[target].box:Destroy() end
        if espBoxes[target].tag then espBoxes[target].tag:Destroy() end
        espBoxes[target] = nil
    end
end

local function CreateESP(target)
    if not espEnabled or target == Player then return end
    RemoveESP(target)
    if not target.Character then return end
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    local head = target.Character:FindFirstChild("Head")
    if not root or not head then return end
    
    local role = GetRole(target)
    local color = role == "Murderer" and Color3.fromRGB(255, 50, 50)
              or role == "Sheriff" and Color3.fromRGB(50, 150, 255)
              or Color3.fromRGB(50, 255, 50)
    
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 2)
    box.Color3 = color
    box.Transparency = 0.5
    box.ZIndex = 10
    box.AlwaysOnTop = true
    box.Adornee = root
    box.Parent = target.Character
    
    local tag = Instance.new("BillboardGui")
    tag.Size = UDim2.new(0, 200, 0, 50)
    tag.Adornee = head
    tag.StudsOffset = Vector3.new(0, 3, 0)
    tag.AlwaysOnTop = true
    tag.Parent = target.Character
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = target.DisplayName .. " [" .. role .. "]"
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.2
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Parent = tag
    
    espBoxes[target] = {box = box, tag = tag}
end

RunService.Heartbeat:Connect(function()
    if espEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then CreateESP(p) else RemoveESP(p) end
        end
    else
        for p, _ in pairs(espBoxes) do RemoveESP(p) end
    end
end)

-- === NOCLIP ===
RunService.Stepped:Connect(function()
    if noclipEnabled and getChar() then
        for _, part in pairs(getChar():GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- === FLY (ЧЕРЕЗ ДЖОЙСТИК) ===
local function startFlight()
    flyEnabled = true
    local root = getRoot()
    local hum = getHumanoid()
    if not root or not hum then return end
    
    hum.PlatformStand = true
    bodyVelocity = Instance.new("BodyVelocity", root)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    
    bodyGyro = Instance.new("BodyGyro", root)
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    
    task.spawn(function()
        while flyEnabled and getRoot() do
            local cam = workspace.CurrentCamera
            local hum2 = getHumanoid()
            local moveDir = hum2 and hum2.MoveDirection or Vector3.new()
            
            -- Прыжок = вверх
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            
            bodyVelocity.Velocity = moveDir * flySpeed
            bodyGyro.CFrame = cam.CFrame
            task.wait()
        end
    end)
end

local function stopFlight()
    flyEnabled = false
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    local hum = getHumanoid()
    if hum then hum.PlatformStand = false end
end

-- === АВТО-ФАРМ МОНЕТ ===
task.spawn(function()
    while true do
        task.wait(0.5)
        if autoFarmEnabled and getRoot() then
            local container = Workspace:FindFirstChild("Normal") and Workspace.Normal:FindFirstChild("CoinContainer")
            if container then
                for _, coin in pairs(container:GetChildren()) do
                    if coin:IsA("BasePart") then
                        getRoot().CFrame = coin.CFrame
                        task.wait(0.2)
                        if not autoFarmEnabled then break end
                    end
                end
            end
        end
    end
end)

-- === АВТО-КИЛЛ ===
task.spawn(function()
    while true do
        task.wait(0.3)
        if autoKillEnabled and GetRole(Player) == "Murderer" then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if GetRole(p) ~= "Murderer" then
                        getRoot().CFrame = p.Character.HumanoidRootPart.CFrame
                        task.wait(0.1)
                    end
                end
            end
        end
    end
end)

-- === ФЛИНГ (отдельная функция) ===
local function Fling(target)
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
end

-- ==========================================
-- GUI (PlayerGui — работает в Delta)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YARHM_MM2"
ScreenGui.Parent = Player.PlayerGui
ScreenGui.ResetOnSpawn = false

-- Плавающая кнопка
local FloatingButton = Instance.new("TextButton")
FloatingButton.Size = UDim2.new(0, 55, 0, 55)
FloatingButton.Position = UDim2.new(1, -70, 0, 30)
FloatingButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
FloatingButton.Text = "≡"
FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingButton.TextSize = 28
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.Parent = ScreenGui

local FC = Instance.new("UICorner", FloatingButton)
FC.CornerRadius = UDim.new(0, 27)

local FS = Instance.new("UIStroke", FloatingButton)
FS.Color = Color3.fromRGB(150, 150, 150)
FS.Thickness = 2

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MC = Instance.new("UICorner", MainFrame)
MC.CornerRadius = UDim.new(0, 8)

local MStroke = Instance.new("UIStroke", MainFrame)
MStroke.Color = Color3.fromRGB(80, 80, 80)
MStroke.Thickness = 2

-- Верхний бар
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TBCorner = Instance.new("UICorner", TopBar)
TBCorner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "YARHM"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Крестик
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 60, 0, 32)
CloseBtn.Position = UDim2.new(1, -68, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local CC = Instance.new("UICorner", CloseBtn)
CC.CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatingButton.Visible = true
end)

-- Скролл с кнопками
local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -65)
Container.Position = UDim2.new(0, 10, 0, 55)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.ScrollBarThickness = 4
Container.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
Container.Parent = MainFrame

local UIGrid = Instance.new("UIGridLayout", Container)
UIGrid.CellSize = UDim2.new(0, 220, 0, 50)
UIGrid.CellPadding = UDim2.new(0, 10, 0, 10)
UIGrid.SortOrder = Enum.SortOrder.LayoutOrder

Container:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, UIGrid.AbsoluteContentSize.Y + 10)
end)

-- Создание toggle-кнопки
local function CreateToggle(name, default, callback)
    local state = default
    local Button = Instance.new("TextButton", Container)
    Button.BackgroundColor3 = state and Color3.fromRGB(40, 120, 75) or Color3.fromRGB(30, 30, 40)
    Button.Text = name .. ": " .. (state and "ON" or "OFF")
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 14
    Button.TextWrapped = true
    
    local corner = Instance.new("UICorner", Button)
    corner.CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", Button)
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Thickness = 1
    
    Button.MouseButton1Click:Connect(function()
        state = not state
        Button.BackgroundColor3 = state and Color3.fromRGB(40, 120, 75) or Color3.fromRGB(30, 30, 40)
        Button.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

-- Создание обычной кнопки
local function CreateButton(name, callback)
    local Button = Instance.new("TextButton", Container)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 14
    Button.TextWrapped = true
    
    local corner = Instance.new("UICorner", Button)
    corner.CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", Button)
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Thickness = 1
    
    Button.MouseButton1Click:Connect(callback)
end

-- === РЕГИСТРАЦИЯ ФУНКЦИЙ ===
CreateToggle("Полет", false, function(v)
    if v then startFlight() else stopFlight() end
end)

CreateToggle("Проход сквозь стены", false, function(v)
    noclipEnabled = v
end)

CreateToggle("ESP игроков", false, function(v)
    espEnabled = v
end)

CreateToggle("Авто-фарм монет", false, function(v)
    autoFarmEnabled = v
end)

CreateToggle("Авто-убийство (мафия)", false, function(v)
    autoKillEnabled = v
end)

-- === КНОПКИ-ДЕЙСТВИЯ (как на фото) ===
CreateButton("Fling Murderer", function()
    local m = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and GetRole(p) == "Murderer" then m = p break end
    end
    if m then Fling(m) end
end)

CreateButton("Fling Sheriff", function()
    local s = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and GetRole(p) == "Sheriff" then s = p break end
    end
    if s then Fling(s) end
end)

CreateButton("Teleport to map", function()
    local root = getRoot()
    if root then root.CFrame = CFrame.new(0, 50, 0) end
end)

CreateButton("Teleport to lobby", function()
    local root = getRoot()
    if root then root.CFrame = CFrame.new(0, 200, 0) end
end)

CreateButton("Send roles to chat", function()
    local m, s = nil, nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            local r = GetRole(p)
            if r == "Murderer" then m = p.Name end
            if r == "Sheriff" then s = p.Name end
        end
    end
    local msg = "Murderer: " .. (m or "?") .. " | Sheriff: " .. (s or "?")
    game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {Text = msg})
end)

CreateButton("Copy murderer username", function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and GetRole(p) == "Murderer" then
            if setclipboard then setclipboard(p.Name) end
            return
        end
    end
end)

CreateButton("Copy sheriff username", function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and GetRole(p) == "Sheriff" then
            if setclipboard then setclipboard(p.Name) end
            return
        end
    end
end)

-- === ПЕРЕТАСКИВАНИЕ (МЫШЬ + ПАЛЕЦ) ===
local dragging, dragStart, startPos = false, nil, nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TopBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- === ОТКРЫТИЕ / ЗАКРЫТИЕ ===
FloatingButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FloatingButton.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        FloatingButton.Visible = not MainFrame.Visible
    end
end)

print("YARHM Menu загружен! Нажми на кнопку ≡")