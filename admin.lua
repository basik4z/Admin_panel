-- [[ ПОЛНЫЙ ЦИКЛ: АВТО-СБОР + АВТО-СКУПКА + АВТО-РЕБЕРХ ]] --

_G.LitEnergyFarm = true -- Флаг работы скрипта (поменяйте на false, чтобы остановить)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Функция безопасного поиска вашего Тайкуна
local function getMyTycoon()
    if workspace:FindFirstChild("Tycoons") then
        return workspace.Tycoons:FindFirstChild(LocalPlayer.Name .. "'s Tycoon") 
            or workspace.Tycoons:FindFirstChild(LocalPlayer.Name)
    end
    return nil
end

-- 1. ЦИКЛ АВТО-СБОРА ДЕНЕГ (Телепортация к сборщикам/каплям)
task.spawn(function()
    while _G.LitEnergyFarm do
        task.wait(0.3) -- Пауза между сборами, чтобы не кикнуло за флуд
        pcall(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            -- Ищем капли/монеты на карте
            for _, v in pairs(workspace:GetChildren()) do
                if v.Name == "CashPickup" or v.Name == "MoneyDrop" or v:FindFirstChild("TouchInterest") then
                    -- ТП прямо на деньги для мгновенного сбора
                    hrp.CFrame = v.CFrame
                    firetouchinterest(hrp, v, 0)
                    firetouchinterest(hrp, v, 1)
                    task.wait(0.05)
                end
            end
        end)
    end
end)

-- 2. ЦИКЛ АВТО-ПОКУПКИ И АВТО-РЕБЕРХА (До максимума)
task.spawn(function()
    while _G.LitEnergyFarm do
        task.wait(0.5)
        pcall(function()
            local tycoon = getMyTycoon()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not tycoon or not hrp then return end
            
            local boughtAnything = false
            
            -- Проверяем кнопки улучшения/покупки
            if tycoon:FindFirstChild("Buttons") then
                for _, button in pairs(tycoon.Buttons:GetChildren()) do
                    -- Проверяем, доступна ли кнопка (не прозрачная)
                    if button:FindFirstChild("Head") and button.Head.Transparency == 0 then
                        -- Телепортируемся к кнопке и нажимаем её
                        hrp.CFrame = button.Head.CFrame
                        firetouchinterest(hrp, button.Head, 0)
                        firetouchinterest(hrp, button.Head, 1)
                        boughtAnything = true
                        task.wait(0.2) -- Небольшая задержка, чтобы деньги успели списаться
                    end
                end
            end
            
            -- 3. ЕСЛИ ВСЕ КУПЛЕНО (Достигнут максимум) -> ДЕЛАЕМ ПЕРЕРОЖДЕНИЕ
            if not boughtAnything then
                -- Если доступных кнопок для покупки больше нет, шлем сигнал на Rebirth
                if ReplicatedStorage:FindFirstChild("Remotes") then
                    if ReplicatedStorage.Remotes:FindFirstChild("Rebirth") then
                        ReplicatedStorage.Remotes.Rebirth:FireServer()
                    elseif ReplicatedStorage.Remotes:FindFirstChild("TriggerRebirth") then
                        ReplicatedStorage.Remotes.TriggerRebirth:FireServer()
                    end
                end
                print("[LIT ENERGY] Достигнут максимум! Авто-перерождение выполнено.")
                task.wait(2) -- Пауза, чтобы игра успела обнулить тайкун
            end
        end)
    end
end)

print("[LIT ENERGY] Полный бесконечный скрипт запущен!")
