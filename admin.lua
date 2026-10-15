_G.LitEnergyFarm = true -- Чтобы выключить, замените true на false и перезапустите

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Функция поиска фабрики (Тайкуна) игрока
local function getMyTycoon()
    if workspace:FindFirstChild("Tycoons") then
        return workspace.Tycoons:FindFirstChild(LocalPlayer.Name .. "'s Tycoon") 
            or workspace.Tycoons:FindFirstChild(LocalPlayer.Name)
    end
    return nil
end

-- 1. СБОР ДЕНЕГ (Персонаж быстро прыгает по монетам)
task.spawn(function()
    while _G.LitEnergyFarm do
        task.wait(0.4)
        pcall(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            for _, v in pairs(workspace:GetChildren()) do
                -- Проверяем капли, деньги или объекты с зоной касания
                if v.Name == "CashPickup" or v.Name == "MoneyDrop" or v:FindFirstChild("TouchInterest") then
                    hrp.CFrame = v.CFrame + Vector3.new(0, 1, 0)
                    task.wait(0.1)
                end
            end
        end)
    end
end)

-- 2. ПОКУПКА КНОПОК И УЛУЧШЕНИЙ
task.spawn(function()
    while _G.LitEnergyFarm do
        task.wait(0.6)
        pcall(function()
            local tycoon = getMyTycoon()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not tycoon or not hrp then return end
            
            if tycoon:FindFirstChild("Buttons") then
                for _, button in pairs(tycoon.Buttons:GetChildren()) do
                    -- Находим верхнюю часть кнопки, на которую нужно наступить
                    local part = button:FindFirstChild("Head") or button:FindFirstChild("TouchPad") or button:FindFirstChild("Part")
                    if part and part.Transparency < 1 then
                        -- Встаем прямо на кнопку, чтобы игра засчитала покупку
                        hrp.CFrame = part.CFrame + Vector3.new(0, 1, 0)
                        task.wait(0.3)
                    end
                end
            end
        end)
    end
end)

print("[LIT ENERGY] Новый скрипт запущен!")
