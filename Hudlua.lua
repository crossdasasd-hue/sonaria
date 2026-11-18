-- ==========================================
-- 🍄 CoS Auto-Farmer & Mushroom Hunter
-- Для использования в Delta Roblox
-- ==========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- ⚙️ НАСТРОЙКИ
local Settings = {
    ScanInterval = 0.5,          -- Как часто сканировать мир (секунды)
    ClickDelay = 0.3,            -- Задержка между кликами
    MaxDistance = 100,           -- Максимальная дальность поиска грибов
    DebugMode = true,            -- Показывать логи в консоли Delta
    AutoQuest = true             -- Пытаться выполнять текущий квест автоматически
}

-- Переменные состояния
local isRunning = true
local lastClickTime = 0

-- Функция логирования
function Log(msg)
    if Settings.DebugMode then
        print("[CoS Bot] " .. msg)
    end
end

-- Функция получения текущего квеста (если доступно через GUI)
function GetCurrentQuestObjective()
    -- В CoS квесты часто хранятся в ReplicatedStorage или отображаются в GUI.
    -- Здесь мы предполагаем, что мы ищем общие объекты "Mushroom".
    -- Если у тебя есть конкретный объект квеста, замени эту логику.
    return "Collect Mushrooms" 
end

-- Основная функция поиска и сбора
function FarmLoop()
    while isRunning do
        local foundTarget = false
        
        -- Получаем камеру игрока
        local camera = Workspace.CurrentCamera
        if not camera then wait(Settings.ScanInterval); continue end

        -- Создаем луч из центра экрана (или от позиции мыши)
        -- Для автоматизации лучше смотреть туда, куда смотрит камера, 
        -- или использовать Raycast от позиции камеры вперед.
        
        local rayOrigin = camera.CFrame.Position
        local rayDirection = camera.CFrame.LookVector * Settings.MaxDistance
        
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude

        -- Выполняем Raycast
        local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
        
        if result and result.Instance then
            local instance = result.Instance
            
            -- Проверяем, является ли объект грибом или частью квеста
            -- В CoS грибы могут называться по-разному: "Mushroom", "Fungus", "Item_Mushroom"
            local nameLower = instance.Name:lower()
            local isMushroom = nameLower:find("mush") or nameLower:find("fungus") or nameLower:find("shroom")
            
            -- Также можно проверить тег, если он есть
            local hasTag = instance:FindFirstChild("Tags") and instance.Tags:FindFirstChild("Mushroom")
            
            if isMushroom or hasTag then
                Log("🎯 Цель найдена: " .. instance.Name)
                
                -- Эмуляция клика левой кнопкой мыши
                Mouse.Button1Down()
                wait(Settings.ClickDelay)
                Mouse.Button1Up()
                
                Log("✅ Клик выполнен!")
                foundTarget = true
                
                -- Небольшая пауза после успешного сбора
                wait(1)
            end
        else
            -- Если луч ничего не нашел, можно медленно вращать камерой или ждать
            -- Для простоты просто ждем следующий цикл
        end
        
        wait(Settings.ScanInterval)
    end
end

-- Запуск
Log("🚀 Бот запущен! Ищем грибы...")
FarmLoop()

-- Обработчик выхода (например, по клавише End)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.End then
        isRunning = not isRunning
        if isRunning then
            Log("🟢 Бот возобновлен")
            FarmLoop()
        else
            Log("🔴 Бот остановлен")
        end
    end
end)
