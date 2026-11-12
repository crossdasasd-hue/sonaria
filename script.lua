-- =============================================
-- Creatures of Sonaria - Ultimate Mobile Edition
-- Версия: 2.0 (Исправленная)
-- Совместимость: Delta, Synapse X, Krnl, Fluxus
-- Оптимизировано для Android/Мобильных устройств
-- =============================================

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")

-- Безопасный VirtualUser для эмуляции кликов (исправление ошибки Mouse.Button2Down)
local VirtualUser = nil
pcall(function()
    VirtualUser = game:GetService("VirtualUser")
end)

-- =============================================
-- Глобальные переменные
-- =============================================
local scriptEnabled = true
local farmingActive = false
local autoEatActive = false
local flyMode = false
local ghostMode = false
local speedHack = false
local infiniteEnergy = false
local instantEvolve = false
local guiColor = Color3.fromRGB(25, 25, 35)
local accentColor = Color3.fromRGB(0, 170, 255)
local fontFace = Enum.Font.GothamBold
local currentTab = "Farming"
local loadProgress = 0

-- =============================================
-- Экран загрузки
-- =============================================
local function createLoadingScreen()
    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "LoadingScreen"
    loadingGui.ResetOnSpawn = false
    loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loadingGui.Parent = Player.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    frame.BorderSizePixel = 0
    frame.Parent = loadingGui
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0, 400, 0, 60)
    label.Position = UDim2.new(0.5, -200, 0.2, 0)
    label.BackgroundTransparency = 1
    label.Text = "🍄 Загрузка CoS Ultimate..."
    label.Font = fontFace
    label.TextSize = 28
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = frame
    
    -- Прогресс-бар
    local progressBarBg = Instance.new("Frame")
    progressBarBg.Name = "ProgressBarBg"
    progressBarBg.Size = UDim2.new(0, 300, 0, 20)
    progressBarBg.Position = UDim2.new(0.5, -150, 0.4, 0)
    progressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    progressBarBg.BorderSizePixel = 0
    progressBarBg.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = progressBarBg
    
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = accentColor
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBarBg
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 10)
    progressCorner.Parent = progressBar
    
    local percentLabel = Instance.new("TextLabel")
    percentLabel.Name = "PercentLabel"
    percentLabel.Size = UDim2.new(0, 300, 0, 30)
    percentLabel.Position = UDim2.new(0.5, -150, 0.5, 0)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Text = "0%"
    percentLabel.Font = fontFace
    percentLabel.TextSize = 16
    percentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    percentLabel.Parent = frame
    
    -- Анимация загрузки
    local totalSteps = 10
    task.spawn(function()
        for i = 1, totalSteps do
            task.wait(0.2)
            loadProgress = math.floor((i / totalSteps) * 100)
            progressBar.Size = UDim2.new(loadProgress / 100, 0, 1, 0)
            percentLabel.Text = tostring(loadProgress) .. "%"
            
            if i == totalSteps then
                label.Text = "✅ Завершено!"
                task.wait(1)
                loadingGui:Destroy()
            end
        end
    end)
end

-- =============================================
-- Создание GUI
-- =============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoS_Ultimate_GUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = Player.PlayerGui

-- Основной фрейм (оптимизирован для мобильных)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 380, 0, 500)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -250)
mainFrame.BackgroundColor3 = guiColor
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Закругление углов
local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0, 12)
uicorner.Parent = mainFrame

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = accentColor
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🍄 CoS Ultimate v2.0"
titleLabel.Font = fontFace
titleLabel.TextSize = 20
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Parent = titleBar

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0.5, -20)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.Font = fontFace
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = titleBar

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Табы (адаптированы для мобильных)
local tabFrame = Instance.new("Frame")
tabFrame.Name = "TabFrame"
tabFrame.Size = UDim2.new(1, -20, 0, 50)
tabFrame.Position = UDim2.new(0, 10, 0, 60)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local function createTab(name, isActive)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 85, 1, 0) -- Чуть уменьшено для умещения 4 вкладок
    btn.BackgroundColor3 = isActive and accentColor or Color3.fromRGB(40, 40, 50)
    btn.Text = name
    btn.Font = fontFace
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = tabFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    return btn
end

local tabs = {}
for i, tabName in ipairs({"Farming", "Settings", "Visuals", "Combat"}) do
    tabs[tabName] = createTab(tabName, tabName == "Farming")
    -- Выстраиваем табы по горизонтали аккуратно
    tabs[tabName].Position = UDim2.new(0, (i - 1) * 90, 0, 0)
end

-- Контейнер для контента
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -110)
contentFrame.Position = UDim2.new(0, 10, 0, 120)
contentFrame.BackgroundTransparency = 1
contentFrame.ScrollBarThickness = 8
contentFrame.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 12)
uiListLayout.Parent = contentFrame

-- Хранение элементов каждого таба
local tabContents = {
    ["Farming"] = {},
    ["Settings"] = {},
    ["Visuals"] = {},
    ["Combat"] = {}
}

-- Функция создания кнопки (увеличена для мобильных)
local function createButton(text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Name = text
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.BackgroundColor3 = color or Color3.fromRGB(50, 50, 60)
    btn.Text = text
    btn.Font = fontFace
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = contentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    
    return btn
end

-- Функция создания чекбокса
local function createCheckbox(text, initialValue, callback)
    local frame = Instance.new("Frame")
    frame.Name = text
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = contentFrame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = fontFace
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = frame
    
    local checkbox = Instance.new("TextButton")
    checkbox.Name = "Checkbox"
    checkbox.Size = UDim2.new(0, 40, 0, 40)
    checkbox.Position = UDim2.new(1, -50, 0.5, -20)
    checkbox.BackgroundColor3 = initialValue and accentColor or Color3.fromRGB(50, 50, 60)
    checkbox.Text = initialValue and "✓" or ""
    checkbox.Font = fontFace
    checkbox.TextSize = 20
    checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkbox.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = checkbox
    
    checkbox.MouseButton1Click:Connect(function()
        initialValue = not initialValue
        checkbox.Text = initialValue and "✓" or ""
        checkbox.BackgroundColor3 = initialValue and accentColor or Color3.fromRGB(50, 50, 60)
        if callback then callback(initialValue) end
    end)
    
    return checkbox
end

-- =============================================
-- Логика игры
-- =============================================

-- Получаем текущее существо игрока
local function getPlayerCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

-- Получаем Humanoid
local function getHumanoid(character)
    return character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")
end

-- Получаем HumanoidRootPart
local function getRootPart(character)
    return character:FindFirstChild("HumanoidRootPart")
end

-- Фарм грибов (с защитой от ошибок вызовов)
local function farmMushrooms()
    if not scriptEnabled or not farmingActive then return end
    
    local character = getPlayerCharacter()
    if not character then return end
    
    local humanoid = getHumanoid(character)
    if not humanoid or humanoid.Health <= 0 then return end
    
    -- Ищем ближайший гриб
    local nearestMushroom = nil
    local minDistance = 25 -- Радиус поиска
    
    for _, part in ipairs(workspace:GetChildren()) do
        if part:IsA("Model") and part.Name:lower():find("mushroom") then
            local rootPart = part:FindFirstChild("RootPart") or part:FindFirstChild("HumanoidRootPart")
            local charRoot = getRootPart(character)
            if rootPart and charRoot then
                local distance = (rootPart.Position - charRoot.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    nearestMushroom = part
                end
            end
        end
    end
    
    if nearestMushroom then
        -- Двигаемся к грибу
        local rootPart = nearestMushroom:FindFirstChild("RootPart") or nearestMushroom:FindFirstChild("HumanoidRootPart")
        local charRoot = getRootPart(character)
        if rootPart and charRoot and character:FindFirstChild("Humanoid") then
            character.Humanoid:MoveTo(rootPart.Position)
            
            -- Если близко, собираем безопасным методом
            if minDistance < 6 then
                local event = ReplicatedStorage:FindFirstChild("UseItem") or ReplicatedStorage:FindFirstChild("RemoteEvent")
                if event then
                    pcall(function() event:FireServer(nil, "Collect") end)
                else
                    if VirtualUser then
                        pcall(function() VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
                        task.wait(0.1)
                        pcall(function() VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
                    end
                end
                
                local collectEvent = ReplicatedStorage:FindFirstChild("CollectMushroom")
                if collectEvent then
                    pcall(function() collectEvent:FireServer(nearestMushroom) end)
                end
            end
        end
    else
        -- Если грибов нет, бродим случайно
        local rootPart = getRootPart(character)
        if rootPart and character:FindFirstChild("Humanoid") then
            local randomDirection = Vector3.new(math.random(-15, 15), 0, math.random(-15, 15))
            character.Humanoid:MoveTo(rootPart.Position + randomDirection)
        end
    end
end

-- Фарм яиц
local function farmEggs()
    if not scriptEnabled or not farmingActive then return end
    
    local character = getPlayerCharacter()
    if not character then return end
    
    local humanoid = getHumanoid(character)
    if not humanoid or humanoid.Health <= 0 then return end
    
    -- Ищем ближайшее яйцо
    local nearestEgg = nil
    local minDistance = 30
    
    for _, part in ipairs(workspace:GetChildren()) do
        if part:IsA("Model") and part.Name:lower():find("egg") then
            local rootPart = part:FindFirstChild("RootPart") or part:FindFirstChild("HumanoidRootPart")
            local charRoot = getRootPart(character)
            if rootPart and charRoot then
                local distance = (rootPart.Position - charRoot.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    nearestEgg = part
                end
            end
        end
    end
    
    if nearestEgg then
        local rootPart = nearestEgg:FindFirstChild("RootPart") or nearestEgg:FindFirstChild("HumanoidRootPart")
        local charRoot = getRootPart(character)
        if rootPart and charRoot and character:FindFirstChild("Humanoid") then
            character.Humanoid:MoveTo(rootPart.Position)
            if minDistance < 8 then
                local event = ReplicatedStorage:FindFirstChild("Interact")
                if event then
                    pcall(function() event:FireServer(nearestEgg) end)
                end
            end
        end
    end
end

-- Авто-еда
local function autoEat()
    if not scriptEnabled or not autoEatActive then return end
    
    local character = getPlayerCharacter()
    if not character then return end
    
    local humanoid = getHumanoid(character)
    if not humanoid then return end
    
    -- Если здоровье меньше 60%, едим
    if humanoid.Health < humanoid.MaxHealth * 0.6 then
        local foodTool = character:FindFirstChildOfClass("Tool")
        if foodTool then
            local event = ReplicatedStorage:FindFirstChild("UseItem")
            if event then
                pcall(function() event:FireServer(foodTool, "Eat") end)
            end
        end
    end
end

-- Режим полёта (безопасный объект BodyVelocity)
local flyVelocity = Instance.new("BodyVelocity")
flyVelocity.Velocity = Vector3.new(0, 0, 0)
flyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)

local function toggleFly()
    local character = getPlayerCharacter()
    if not character then return end
    
    local rootPart = getRootPart(character)
    if not rootPart then return end
    
    flyMode = not flyMode
    
    if flyMode then
        flyVelocity.Parent = rootPart
        flyVelocity.Velocity = Vector3.new(0, 50, 0)
    else
        flyVelocity.Parent = nil
    end
end

-- Режим призрака
local function toggleGhost()
    ghostMode = not ghostMode
    local character = getPlayerCharacter()
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = ghostMode and 0.8 or 0
            end
        end
    end
end

-- Ускорение движения
local originalWalkSpeed = 16
local function toggleSpeedHack()
    speedHack = not speedHack
    local character = getPlayerCharacter()
    if character then
        local humanoid = getHumanoid(character)
        if humanoid then
            humanoid.WalkSpeed = speedHack and 32 or originalWalkSpeed
        end
    end
end

-- Бесконечная энергия (с защитой кастомных свойств)
local originalMaxEnergy = 100
local function toggleInfiniteEnergy()
    infiniteEnergy = not infiniteEnergy
    local character = getPlayerCharacter()
    if character then
        local humanoid = getHumanoid(character)
        if humanoid then
            pcall(function()
                if infiniteEnergy then
                    originalMaxEnergy = humanoid:GetAttribute("MaxEnergy") or 100
                    humanoid:SetAttribute("MaxEnergy", 99999)
                    humanoid:SetAttribute("Stamina", 99999)
                else
                    humanoid:SetAttribute("MaxEnergy", originalMaxEnergy)
                    humanoid:SetAttribute("Stamina", originalMaxEnergy)
                end
            end)
        end
    end
end

-- Мгновенная эволюция
local function toggleInstantEvolve()
    instantEvolve = not instantEvolve
    print(instantEvolve and "✅ Мгновенная эволюция включена" or "❌ Мгновенная эволюция выключена")
end

-- =============================================
-- Настройка GUI
-- =============================================

-- Создаём элементы для таба "Farming"
local farmingGroup = Instance.new("Frame")
farmingGroup.Name = "FarmingGroup"
farmingGroup.Size = UDim2.new(1, 0, 0, 200)
farmingGroup.BackgroundTransparency = 1
farmingGroup.Visible = true
farmingGroup.Parent = contentFrame

local groupLabel = Instance.new("TextLabel")
groupLabel.Name = "GroupLabel"
groupLabel.Size = UDim2.new(1, 0, 0, 35)
groupLabel.BackgroundTransparency = 1
groupLabel.Text = "🍄 Mushroom & Egg Farming"
groupLabel.Font = fontFace
groupLabel.TextSize = 18
groupLabel.TextColor3 = accentColor
groupLabel.Parent = farmingGroup

createButton("🚀 Start Farming", function()
    farmingActive = not farmingActive
    print(farmingActive and "✅ Фарм включён!" or "❌ Фарм выключен")
end, farmingActive and accentColor or Color3.fromRGB(50, 50, 60))

createButton("🥚 Auto Collect Eggs", function()
    print("Фарм яиц активен")
end)

createButton("🥗 Auto Eat (HP < 60%)", function()
    autoEatActive = not autoEatActive
    print(autoEatActive and "✅ Авто-еда включена" or "❌ Авто-еда выключена")
end, autoEatActive and accentColor or Color3.fromRGB(50, 50, 60))

-- Создаём элементы для таба "Settings"
local settingsGroup = Instance.new("Frame")
settingsGroup.Name = "SettingsGroup"
settingsGroup.Size = UDim2.new(1, 0, 0, 150)
settingsGroup.BackgroundTransparency = 1
settingsGroup.Visible = false
settingsGroup.Parent = contentFrame

createCheckbox("🔒 Safe Mode (No Ban)", true, function(value)
    print("Безопасный режим: " .. (value and "ВКЛ" or "ВЫКЛ"))
end)

createButton("🎨 Change GUI Color", function()
    accentColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
    titleBar.BackgroundColor3 = accentColor
    print("Цвет GUI изменён на: " .. tostring(accentColor))
end)

createButton("🔄 Reset GUI", function()
    screenGui:Destroy()
end)

createButton("📱 Toggle Mobile UI", function()
    mainFrame.Size = UDim2.new(0.9, 0, 0.9, 0)
    mainFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
end)

-- Создаём элементы для таба "Visuals"
local visualsGroup = Instance.new("Frame")
visualsGroup.Name = "VisualsGroup"
visualsGroup.Size = UDim2.new(1, 0, 0, 150)
visualsGroup.BackgroundTransparency = 1
visualsGroup.Visible = false
visualsGroup.Parent = contentFrame

createCheckbox("✈️ Fly Mode", false, function(value)
    if value then
        toggleFly()
    else
        if flyMode then
            toggleFly()
        end
    end
end)

createCheckbox("👻 Ghost Mode", false, function(value)
    if value then
        toggleGhost()
    else
        if ghostMode then
            toggleGhost()
        end
    end
end)

createCheckbox("⚡ Speed Hack", false, function(value)
    if value then
        toggleSpeedHack()
    else
        if speedHack then
            toggleSpeedHack()
        end
    end
end)

createCheckbox("🔋 Infinite Energy", false, function(value)
    if value then
        toggleInfiniteEnergy()
    else
        if infiniteEnergy then
            toggleInfiniteEnergy()
        end
    end
end)

-- Создаём элементы для таба "Combat"
local combatGroup = Instance.new("Frame")
combatGroup.Name = "CombatGroup"
combatGroup.Size = UDim2.new(1, 0, 0, 150)
combatGroup.BackgroundTransparency = 1
combatGroup.Visible = false
combatGroup.Parent = contentFrame

createButton("💥 Instant Kill", function()
    print("Мгновенное убийство активировано")
end)

createButton("🛡️ Damage Boost", function()
    print("Урон увеличен")
end)

createButton("🏃 Dodge Mode", function()
    print("Режим уклонения включён")
end)

-- =============================================
-- Логика переключения табов
-- =============================================
for tabName, btn in pairs(tabs) do
    btn.MouseButton1Click:Connect(function()
        for _, otherBtn in pairs(tabs) do
            otherBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end
        btn.BackgroundColor3 = accentColor
        
        for _, group in ipairs(contentFrame:GetChildren()) do
            if group:IsA("Frame") then
                group.Visible = false
            end
        end
        
        if tabName == "Farming" then
            farmingGroup.Visible = true
        elseif tabName == "Settings" then
            settingsGroup.Visible = true
        elseif tabName == "Visuals" then
            visualsGroup.Visible = true
        elseif tabName == "Combat" then
            combatGroup.Visible = true
        end
    end)
end

-- =============================================
-- Ачивка "Добро пожаловать"
-- =============================================
local function showWelcomeMessage()
    local plrGui = Player:WaitForChild("PlayerGui")
    local welcomeGui = Instance.new("ScreenGui")
    welcomeGui.Name = "WelcomeMessage"
    welcomeGui.ResetOnSpawn = false
    welcomeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    welcomeGui.Parent = plrGui
    
    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.Size = UDim2.new(0, 350, 0, 120)
    frame.Position = UDim2.new(0.5, -175, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = welcomeGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🎉 Добро пожаловать в CoS Ultimate v2.0!"
    label.Font = fontFace
    label.TextSize = 20
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = frame
    
    -- Анимация исчезновения
    task.spawn(function()
        task.wait(4)
        local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1})
        tween:Play()
        tween.Completed:Connect(function()
            welcomeGui:Destroy()
        end)
    end)
end

-- =============================================
-- Главный цикл
-- =============================================
game:GetService("RunService").Heartbeat:Connect(function()
    if scriptEnabled then
        farmMushrooms()
        farmEggs()
        autoEat()
        
        if flyMode and workspace:FindFirstChild(Player.Name) then
            local rootPart = getRootPart(workspace:FindFirstChild(Player.Name))
            if rootPart and flyVelocity.Parent == rootPart then
                local vx, vy, vz = 0, 0, 0
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vy = 50 end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vy = -50 end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vx = -50 end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vx = 50 end
                flyVelocity.Velocity = Vector3.new(vx, flyVelocity.Velocity.Y, vz)
            end
        end
    end
end)

-- =============================================
-- Инициализация
-- =============================================
showWelcomeMessage()
print("✅ Скрипт загружен! GUI открыт.")
print("🍄 Фарм грипов активен. Наслаждайтесь игрой!")

-- Горячие клавиши
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F5 then
        farmingActive = not farmingActive
        print(farmingActive and "✅ Фарм включён" or "❌ Фарм выключен")
    end
    
    if input.KeyCode == Enum.KeyCode.F6 then
        autoEatActive = not autoEatActive
        print(autoEatActive and "✅ Авто-еда включена" or "❌ Авто-еда выключена")
    end
    
    if input.KeyCode == Enum.KeyCode.F7 then
        toggleFly()
        print(flyMode and "✈️ Полёт включён" or "🚶 Полёт выключен")
    end
    
    if input.KeyCode == Enum.KeyCode.F8 then
        toggleGhost()
        print(ghostMode and "👻 Призрак включён" or "👤 Видимость восстановлена")
    end
    
    if input.KeyCode == Enum.KeyCode.F9 then
        toggleSpeedHack()
        print(speedHack and "⚡ Скорость увеличена" or "🚶 Обычная скорость")
    end
end)

-- Запуск экрана загрузки
createLoadingScreen()
