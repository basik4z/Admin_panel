-- Создаем интерфейс
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")
local TitleBar = Instance.new("Frame")
local TitleText = Instance.new("TextLabel")
local MinimizeButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local WebhookBox = Instance.new("TextBox")
local IntervalBox = Instance.new("TextBox")
local StartButton = Instance.new("TextButton")
local StatusText = Instance.new("TextLabel")
local MiniButton = Instance.new("TextButton")

ScreenGui.Name = "ScriptobusUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Главное окно
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -160)
MainFrame.Size = UDim2.new(0, 320, 0, 320)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local UICorner_Main = Instance.new("UICorner")
UICorner_Main.CornerRadius = UDim.new(0, 15)
UICorner_Main.Parent = MainFrame

-- КРАСИВЫЙ СИНИЙ ГРАДИЕНТ (Наш "анимешный" фон)
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 120, 255)),   -- Ярко-синий
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(100, 200, 255)), -- Небесно-голубой
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(200, 240, 255))  -- Светло-голубой (как облака)
}
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

-- Верхняя панель (прозрачное стекло)
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BackgroundTransparency = 0.8 -- Сильная прозрачность (эффект стекла)
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BorderSizePixel = 0

local UICorner_Title = Instance.new("UICorner")
UICorner_Title.CornerRadius = UDim.new(0, 15)
UICorner_Title.Parent = TitleBar

-- Текст заголовка
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "Tracer name Scriptobus"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextStrokeTransparency = 0.5 -- Легкая тень для текста

-- Кнопка свернуть
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TitleBar
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
MinimizeButton.Position = UDim2.new(1, -70, 0, 7)
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3 false

.fromRGB(255, 255,local 255)
MinimizeButton.TextSize = 20 UIC

local UICorner_Min = Instance.new("UICorner")
UICorner_Min.CornerRadius = UDim.new(0, 15)
UICorner_Min.Parent = MinimizeButton

-- Кнопка закрыть
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Position = UDim2.new(1, -35, 0, 7)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14

local UICorner_Close = Instance.new("UICorner")
UICorner_Close.CornerRadius = UDim.new(0, 15)
UICorner_Close.Parent = CloseButton

-- Поле Webhook
WebhookBox.Name = "WebhookBox"
WebhookBox.Parent = MainFrame
WebhookBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
WebhookBox.BackgroundTransparency = 0.3
WebhookBox.Position = UDim2.new(0, 15, 0, 65)
WebhookBox.Size = UDim2.new(1, -30, 0, 40)
WebhookBox.Font = Enum.Font.Gotham
WebhookBox.PlaceholderText = "Вставьте ссылку Webhook сюда..."
WebhookBox.Text = ""
WebhookBox.TextColor3 = Color3.fromRGB(0, 0, 0)
WebhookBox.PlaceholderColor3 = Color3.fromRGB(50, 50, 50)
WebhookBox.TextSize = 14
WebhookBox.TextXAlignment = Enum.TextXAlignment.Left
WebhookBox.ClearTextOnFocus =orner_Webhook = Instance.new("UICorner")
UICorner_Webhook.CornerRadius = UDim.new(0, 8)
UICorner_Webhook.Parent = WebhookBox

-- Поле Интервал
IntervalBox.Name = "IntervalBox"
IntervalBox.Parent = MainFrame
IntervalBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
IntervalBox.BackgroundTransparency = 0.3
IntervalBox.Position = UDim2.new(0, 15, 0, 120)
IntervalBox.Size = UDim2.new(1, -30, 0, 40)
IntervalBox.Font = Enum.Font.Gotham
IntervalBox.PlaceholderText = "Интервал (в секундах)"
IntervalBox.Text = "60"
IntervalBox.TextColor3 = Color3.fromRGB(0, 0, 0)
IntervalBox.PlaceholderColor3 = Color3.fromRGB(50, 50, 50)
IntervalBox.TextSize = 14
IntervalBox.ClearTextOnFocus = false

local UICorner_Interval = Instance.new("UICorner")
UICorner_Interval.CornerRadius = UDim.new(0, 8)
UICorner_Interval.Parent = IntervalBox

-- Кнопка старта
StartButton.Name = "StartButton"
StartButton.Parent = MainFrame
StartButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
StartButton.BackgroundTransparency = 0.1 -- Почти непрозрачная
StartButton.Position = UDim2.new(0, 15, 0, 180)
StartButton.Size = UDim2.new(1, -30, 0, 45)
StartButton.Font = Enum.Font.GothamBold
StartButton.Text = "Запустить трекер"
StartButton.TextColor3 = Color3.fromRGB(0, 100, 200) -- Синий текст на белой кнопке
StartButton.TextSize = 16

local UICorner_Start = Instance.new("UICorner")
UICorner_Start.CornerRadius = UDim.new(0, 8)
UICorner_Start.Parent = StartButton

-- Статус
StatusText.Name = "StatusText"
StatusText.Parent = MainFrame
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 15, 0, 240)
StatusText.Size = UDim2.new(1, -30, 0, 40)
StatusText.Font = Enum.Font.GothamBold
StatusText.Text = "Ожидание запуска..."
StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusText.TextSize = 14
StatusText.TextStrokeTransparency = 0.5

-- Маленькая кнопка
MiniButton.Name = "MiniButton"
MiniButton.Parent = ScreenGui
MiniButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
MiniButton.Position = UDim2.new(0, 20, 0, 20)
MiniButton.Size = UDim2.new(0, 120, 0, 40)
MiniButton.Font = Enum.Font.GothamBold
MiniButton.Text = "Scriptobus"
MiniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniButton.TextSize = 14
MiniButton.Visible = false

local UICorner_Mini = Instance.new("UICorner")
UICorner_Mini.CornerRadius = UDim.new(0, 10)
UICorner_Mini.Parent = MiniButton

-- Логика работы
local running = false

local function getMyCandies()
    local player = game.Players.LocalPlayer
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local candyStat = leaderstats:FindFirstChild("Candy") or leaderstats:FindFirstChild("Candies") or leaderstats:FindFirstChild("Coins")
        if candyStat then return candyStat.Value end
    end
    return 0 
end

local function startTracker()
    if running then return end
    running = true
    
    local webhook = WebhookBox.Text
    local interval = tonumber(IntervalBox.Text) or 60
    
    if webhook == "" then
        StatusText.Text = "Ошибка: Вставьте ссылку!"
        StatusText.TextColor3 = Color3.fromRGB(255, 50, 50)
        running = false
        return
    end

    StatusText.Text = "Трекер запущен!"
    StatusText.TextColor3 = Color3.fromRGB(50, 255, 50)
    StartButton.Text = "Работает..."
    StartButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    task.spawn(function()
        while running do
            local candies = getMyCandies()
            local HttpService = game:GetService("HttpService")
            
            local messageText = "🍭 **Candy:** " .. tostring(candies) .. 
                                "\n👤 **user:** " .. game.Players.LocalPlayer.DisplayName ..
                                "\n\n*Powered by Scriptobus*"
            
            local data = { ["content"] = messageText }
            
            pcall(function()
                HttpService:PostAsync(webhook, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
            end)
            
            task.wait(interval)
        end
    end)
end

StartButton.MouseButton1Click:Connect(startTracker)

MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniButton.Visible = true
end)

MiniButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MiniButton.Visible = false
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniButton.Visible = false
end)