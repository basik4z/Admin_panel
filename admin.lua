-- === НАСТРОЙКИ ===
local webhookURL = "https://discord.com/api/webhooks/1562305193935245345/gHzqEtzySHK0jSlBPPjQErOYKh8DeOPbEIh3KvL3pfQpnbHaM_j8ur2UnLuR5RZcjCC3"
local sendInterval = 60 -- Отправлять каждую минуту
local scriptName = "desin by scriptobus" -- Ваше название скрипта

-- Функция получения монет
local function getMyCandies()
    local player = game.Players.LocalPlayer
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local candyStat = leaderstats:FindFirstChild("Candy") or leaderstats:FindFirstChild("Candies") or leaderstats:FindFirstChild("Coins")
        if candyStat then return candyStat.Value end
    end
    return 0 
end

-- Функция отправки простого текста
local function sendToDiscord(candyAmount)
    local HttpService = game:GetService("HttpService")
    
    -- Формируем простой текст
    local messageText = "🍭 **Candy:** " .. tostring(candyAmount) .. 
                        "\n👤 **user:** " .. game.Players.LocalPlayer.DisplayName ..
                        "\n\n*Powered by " .. scriptName .. "*"
    
    -- Упаковываем в JSON
    local data = {
        ["content"] = messageText
    }
    
    pcall(function()
        HttpService:PostAsync(webhookURL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
end

-- Запуск цикла
task.spawn(function()
    while true do
        local candies = getMyCandies()
        sendToDiscord(candies)
        task.wait(sendInterval)
    end
end)