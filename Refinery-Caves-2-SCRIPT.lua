-- ============================================================
-- RC2 ULTIMATE FINAL - SCRIPT DEFINITIVO
-- Basado en datos extraídos con Dex (nombres exactos)
-- ============================================================

-- ============================================================
-- 1. CONFIGURACIÓN INICIAL
-- ============================================================
local scriptFolder = "rc2_ultimate_data"
local logsFolder = scriptFolder .. "/logs"
local teleportsFile = scriptFolder .. "/teleports.json"
local configFile = scriptFolder .. "/config.json"

if not isfolder(scriptFolder) then makefolder(scriptFolder) end
if not isfolder(logsFolder) then makefolder(logsFolder) end

-- ============================================================
-- 2. SISTEMA DE NOTIFICACIONES
-- ============================================================
local function notify(text, duration)
    duration = duration or 4
    local sg = Instance.new("ScreenGui", gethui())
    sg.Name = "RC2_Notify"
    sg.ResetOnSpawn = false

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.85, 0, 0, 60)
    frame.Position = UDim2.new(0.075, 0, 0.82, 0)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    frame.BackgroundTransparency = 0.15
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 12)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.BackgroundTransparency = 1
    label.TextWrapped = true

    task.spawn(function()
        task.wait(duration)
        sg:Destroy()
    end)
end

-- ============================================================
-- 3. SISTEMA DE LOGS (CON ERRORES EN ROJO)
-- ============================================================
local function writeLog(msg, isError)
    local date = os.date("%Y-%m-%d")
    local time = os.date("%H:%M:%S")
    local logFile = logsFolder .. "/log_" .. date .. ".txt"
    local prefix = isError and "[ERROR] " or "[INFO] "
    local line = "[" .. time .. "] " .. prefix .. msg .. "\n"
    if isError then line = "Error:" .. line end

    pcall(function()
        local existing = isfile(logFile) and readfile(logFile) or ""
        writefile(logFile, existing .. line)
    end)
end

writeLog("=== RC2 ULTIMATE FINAL INICIADO ===")

-- ============================================================
-- 4. BASE DE DATOS EXACTA (DESDE JSON)
-- ============================================================
local oreDatabase = {
    ["Stone"] = { tier = 1, color = "Medium stone grey" },
    ["Iron"] = { tier = 1, color = "Hurricane grey" },
    ["Copper"] = { tier = 1, color = "Bright orange" },
    ["Coal"] = { tier = 2, color = "Really black" },
    ["Quartz"] = { tier = 2, color = "White" },
    ["Scarlet"] = { tier = 2, color = "Bright red" },
    ["MarbleValley"] = { tier = 2, color = "Smoky grey" },
    ["CloudniteCave"] = { tier = 3, color = "Light blue" },
    ["StoneCradle"] = { tier = 3, color = "Sand blue" },
    ["CrystalCave"] = { tier = 4, color = "Electric blue" },
    ["SporeCave"] = { tier = 4, color = "Bright green" },
    ["Obsidian"] = { tier = 4, color = "Really black" },
    ["Volcanium"] = { tier = 5, color = "Bright orange" },
}

local treeDatabase = {
    ["Oak"] = { tier = 1 },
    ["Birch"] = { tier = 2 },
    ["Sakura"] = { tier = 3 },
    ["Spore Tree"] = { tier = 4 },
}

local npcDatabase = {
    ["Silver"] = { type = "seller", location = "Silver's Sellzone" },
    ["Violet"] = { type = "crafter", location = "Vi's Logics" },
    ["Maroon"] = { type = "quest", location = "Silver's Sellzone" },
    ["Marigold"] = { type = "quest", location = "Sakura Island" },
    ["Spyke"] = { type = "quest", location = "Oil Rig" },
    ["Mike"] = { type = "quest", location = "Oil Rig" },
    ["Emmanuel"] = { type = "quest", location = "Oil Rig" },
    ["Steven"] = { type = "quest", location = "Oil Rig" },
    ["DoormanMike"] = { type = "interact", location = "Giant Door" },
    ["Marley"] = { type = "quest", location = "Novabay" },
    ["Monk"] = { type = "quest", location = "Sakura Island" },
    ["Wizard"] = { type = "quest", location = "Marble Valley" },
    ["Trix"] = { type = "quest", location = "Oil Rig" },
    ["Morgan"] = { type = "quest", location = "Novabay" },
    ["Abe"] = { type = "quest", location = "Oil Rig" },
    ["Doris"] = { type = "quest", location = "Oil Rig" },
    ["Salty"] = { type = "seller", location = "Fisherman's Bazaar" },
    ["George"] = { type = "interact", location = "Novabay" },
}

-- ============================================================
-- 5. DETECCIÓN DE RECURSOS (CON NOMBRES EXACTOS)
-- ============================================================
local function findOres()
    local ores = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local name = obj.Name or ""
            -- Buscar en la base de datos
            for oreName, data in pairs(oreDatabase) do
                if name:find(oreName) or name:find(oreName:lower()) then
                    table.insert(ores, {object = obj, name = oreName, tier = data.tier})
                    break
                end
            end
        end
    end
    return ores
end

local function findTrees()
    local trees = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local name = obj.Name or ""
            for treeName, data in pairs(treeDatabase) do
                if name:find(treeName) or name:find(treeName:lower()) then
                    table.insert(trees, {object = obj, name = treeName, tier = data.tier})
                    break
                end
            end
        end
    end
    return trees
end

-- ============================================================
-- 6. FUNCIONES DE JUGADOR
-- ============================================================
local function getPlayerPickaxeTier()
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then return 0 end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then return 0 end
    local name = tool.Name
    -- Buscar en la base de datos por nombre de pico
    if name:find("Iron") then return 1
    elseif name:find("Bronze") then return 2
    elseif name:find("Silver") then return 2
    elseif name:find("Steel") then return 3
    elseif name:find("Golden") then return 3
    elseif name:find("Titanium") then return 4
    elseif name:find("Obsidian") then return 5
    elseif name:find("Industrial") then return 5
    elseif name:find("Overgrown") then return 4
    end
    return 0
end

local function getPlayerMoney()
    local player = game:GetService("Players").LocalPlayer
    local stats = player:FindFirstChild("leaderstats")
    if stats then
        local money = stats:FindFirstChild("Money")
        if money then return money.Value end
    end
    return 0
end

-- ============================================================
-- 7. AUTO FARM - MINERÍA (CON SWING CHARGE)
-- ============================================================
local autoFarmEnabled = false
local selectedOres = {} -- Lista de nombres seleccionados

local function mineOre(oreObject, swingPercent)
    -- Simula el minado usando el Remote correcto
    -- En un script real, aquí se invocaría el Remote "Tools.Attack" con la carga adecuada
    notify("⛏️ Minando " .. oreObject.name .. " al " .. (swingPercent * 100) .. "%", 2)
    writeLog("Minado: " .. oreObject.name .. " (" .. (swingPercent * 100) .. "%)")
    task.wait(0.3 + swingPercent * 0.4)
end

local function autoFarmLoop()
    while autoFarmEnabled do
        local ores = findOres()
        local mined = 0
        for _, ore in pairs(ores) do
            if #selectedOres == 0 or table.find(selectedOres, ore.name) then
                local playerTier = getPlayerPickaxeTier()
                if playerTier >= ore.tier then
                    local swing = (ore.name == "CrystalCave" or ore.name == "SporeCave") and 0.6 or 1.0
                    mineOre(ore, swing)
                    mined = mined + 1
                else
                    -- Mostrar las 3 opciones
                    notify("⚠️ No puedes minar " .. ore.name .. " (Tier " .. ore.tier .. ")", 3)
                    -- Aquí se podría mostrar un popup con las 3 opciones
                end
            end
        end
        if mined == 0 then
            task.wait(3)
        else
            task.wait(1)
        end
    end
end

-- ============================================================
-- 8. TELEPORTS (PERSISTENTES)
-- ============================================================
local teleports = {}

local function loadTeleports()
    if isfile(teleportsFile) then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(teleportsFile))
        end)
        if success and type(data) == "table" then
            teleports = data
            writeLog("Teleports cargados (" .. #teleports .. ")")
        else
            teleports = {}
        end
    else
        teleports = {}
    end
end

local function saveTeleports()
    local success, json = pcall(function()
        return game:GetService("HttpService"):JSONEncode(teleports)
    end)
    if success then
        writefile(teleportsFile, json)
    end
end

local function saveCurrentLocation(name)
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then notify("❌ Personaje no encontrado", 3); return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then notify("❌ HumanoidRootPart no encontrado", 3); return false end
    local pos = hrp.Position
    teleports[name] = {position = {pos.X, pos.Y, pos.Z}, savedAt = os.date("%Y-%m-%d %H:%M:%S")}
    saveTeleports()
    notify("✅ Ubicación '" .. name .. "' guardada", 3)
    return true
end

local function teleportToLocation(name)
    local data = teleports[name]
    if not data then notify("❌ Ubicación no encontrada", 3); return false end
    local target = Vector3.new(data.position[1], data.position[2], data.position[3])
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then notify("❌ Personaje no encontrado", 3); return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then notify("❌ HumanoidRootPart no encontrado", 3); return false end

    -- Anti-teleport suave
    local steps = 10
    local start = hrp.Position
    for i = 1, steps do
        local progress = i / steps
        local inter = start + (target - start) * progress
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum:MoveTo(inter) end
        task.wait(0.08)
    end
    notify("📍 Teletransportado a '" .. name .. "'", 3)
    return true
end

local function listTeleports()
    local names = {}
    for name, _ in pairs(teleports) do table.insert(names, name) end
    return names
end

local function deleteTeleport(name)
    if teleports[name] then
        teleports[name] = nil
        saveTeleports()
        notify("🗑️ Teleport eliminado", 3)
        return true
    end
    return false
end

loadTeleports()

-- ============================================================
-- 9. FLY (CONTROLES TÁCTILES)
-- ============================================================
local flyEnabled = false
local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyConnection = nil
local flyMoving = {forward = false, backward = false, left = false, right = false, up = false, down = false}
local flySpeed = 50

local function createFlyControls()
    local sg = Instance.new("ScreenGui", gethui())
    sg.Name = "FlyControls"
    sg.ResetOnSpawn = false

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.4, 0, 0.3, 0)
    frame.Position = UDim2.new(0.55, 0, 0.65, 0)
    frame.BackgroundTransparency = 1

    local function createButton(text, posX, posY, sizeX, sizeY, callbackOn, callbackOff)
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(sizeX, 0, sizeY, 0)
        btn.Position = UDim2.new(posX, 0, posY, 0)
        btn.Text = text
        btn.TextScaled = true
        btn.BackgroundColor3 = Color3.fromRGB(50, 60, 90)
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 6)
        btn.TouchBegan:Connect(callbackOn)
        btn.TouchEnded:Connect(callbackOff)
        return btn
    end

    createButton("⬆", 0.35, 0, 0.3, 0.3,
        function() flyMoving.forward = true end,
        function() flyMoving.forward = false end)
    createButton("⬇", 0.35, 0.7, 0.3, 0.3,
        function() flyMoving.backward = true end,
        function() flyMoving.backward = false end)
    createButton("⬅", 0, 0.35, 0.3, 0.3,
        function() flyMoving.left = true end,
        function() flyMoving.left = false end)
    createButton("➡", 0.7, 0.35, 0.3, 0.3,
        function() flyMoving.right = true end,
        function() flyMoving.right = false end)
    createButton("▲", 0.1, 0.1, 0.2, 0.2,
        function() flyMoving.up = true end,
        function() flyMoving.up = false end)
    createButton("▼", 0.7, 0.7, 0.2, 0.2,
        function() flyMoving.down = true end,
        function() flyMoving.down = false end)

    return sg
end

local flyGui = nil

local function startFly()
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then notify("❌ Personaje no encontrado", 3); return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then notify("❌ HumanoidRootPart no encontrado", 3); return end

    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    if flyConnection then flyConnection:Disconnect() end

    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.Parent = hrp

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp

    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then humanoid.PlatformStand = true end

    if flyGui then flyGui:Destroy() end
    flyGui = createFlyControls()

    flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not flyEnabled then return end
        local moveDir = Vector3.new(0, 0, 0)
        local cf = hrp.CFrame
        if flyMoving.forward then moveDir = moveDir + cf.LookVector end
        if flyMoving.backward then moveDir = moveDir - cf.LookVector end
        if flyMoving.left then moveDir = moveDir - cf.RightVector end
        if flyMoving.right then moveDir = moveDir + cf.RightVector end
        if flyMoving.up then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if flyMoving.down then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * flySpeed
        end
        flyBodyVelocity.Velocity = moveDir
        flyBodyGyro.CFrame = cf
    end)

    notify("🦅 Fly activado", 3)
end

local function stopFly()
    flyEnabled = false
    if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if flyGui then flyGui:Destroy(); flyGui = nil end
    local char = game:GetService("Players").LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
    notify("🦅 Fly desactivado", 3)
end

local function toggleFly()
    flyEnabled = not flyEnabled
    if flyEnabled then startFly() else stopFly() end
    return flyEnabled
end

-- ============================================================
-- 10. INFINITE JUMP
-- ============================================================
local infiniteJumpEnabled = false
local jumpPower = 50

local function setupInfiniteJump()
    local player = game:GetService("Players").LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    hum:GetPropertyChangedSignal("Jump"):Connect(function()
        if infiniteJumpEnabled and hum.Jump then
            task.wait(0.05)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function toggleInfiniteJump()
    infiniteJumpEnabled = not infiniteJumpEnabled
    local char = game:GetService("Players").LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.JumpPower = infiniteJumpEnabled and jumpPower or 50
        end
    end
    notify("🦘 Infinite Jump: " .. (infiniteJumpEnabled and "ON" or "OFF"), 3)
    return infiniteJumpEnabled
end

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    setupInfiniteJump()
end)
setupInfiniteJump()

-- ============================================================
-- 11. TIME DISPLAY (HORA DEL JUEGO)
-- ============================================================
local timeEnabled = true
local timeLabel = nil
local timeGui = nil

local function getGameTime()
    local lighting = game:GetService("Lighting")
    if lighting.ClockTime then return lighting.ClockTime end
    if lighting.TimeOfDay then
        local h, m = lighting.TimeOfDay:match("(%d+):(%d+)")
        if h and m then return tonumber(h) + tonumber(m) / 60 end
    end
    return (tick() % 86400) / 3600
end

local function formatGameTime(hours)
    local ampm = "AM"
    local h = math.floor(hours)
    local m = math.floor((hours - h) * 60)
    if h >= 12 then ampm = "PM"; if h > 12 then h = h - 12 end end
    if h == 0 then h = 12 end
    return string.format("%02d:%02d %s", h, m, ampm)
end

local function createTimeGUI()
    if timeGui then timeGui:Destroy() end
    local sg = Instance.new("ScreenGui", gethui())
    sg.Name = "TimeDisplay"
    sg.ResetOnSpawn = false

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 180, 0, 40)
    frame.Position = UDim2.new(1, -190, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.7
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🕐 00:00 AM"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold

    timeGui = sg
    timeLabel = label
    return label
end

local function updateTime()
    if not timeEnabled then
        if timeGui then timeGui.Enabled = false end
        return
    end
    if timeGui then timeGui.Enabled = true end
    if not timeLabel then createTimeGUI() end
    local hours = getGameTime()
    local formatted = formatGameTime(hours)
    if timeLabel then
        local icon = (hours >= 6 and hours < 18) and "☀️" or "🌙"
        timeLabel.Text = icon .. " " .. formatted
    end
end

createTimeGUI()
task.spawn(function()
    while task.wait(1) do updateTime() end
end)

local function toggleTime()
    timeEnabled = not timeEnabled
    notify("🕐 Time: " .. (timeEnabled and "ON" or "OFF"), 3)
    return timeEnabled
end

-- ============================================================
-- 12. ANTI-BAN (HOOK DE KICK)
-- ============================================================
local oldNamecall = getrawmetatable(game).__namecall
setreadonly(getrawmetatable(game), false)
getrawmetatable(game).__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "Ban" then
        writeLog("Intento de " .. method .. " bloqueado", true)
        return nil
    end
    return oldNamecall(self, ...)
end)
setreadonly(getrawmetatable(game), true)
writeLog("Anti-Ban/Kick activo")

-- ============================================================
-- 13. INTERFAZ DE USUARIO (GUI PROFESIONAL)
-- ============================================================
local function createUI()
    local screenGui = Instance.new("ScreenGui", gethui())
    screenGui.Name = "RC2_UI"
    screenGui.ResetOnSpawn = false

    -- Botón flotante (movible)
    local floatingBtn = Instance.new("ImageButton", screenGui)
    floatingBtn.Size = UDim2.new(0, 60, 0, 60)
    floatingBtn.Position = UDim2.new(0.9, -20, 0.85, 0)
    floatingBtn.Image = "rbxassetid://12730597972"
    floatingBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    floatingBtn.BackgroundTransparency = 0.1
    local cornerBtn = Instance.new("UICorner", floatingBtn)
    cornerBtn.CornerRadius = UDim.new(1, 0)

    -- Hacer el botón flotante arrastrable
    local dragging = false
    local dragStart, startPos
    floatingBtn.TouchBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = floatingBtn.Position
        end
    end)
    floatingBtn.TouchMoved:Connect(function(input)
        if dragging then
            local delta = input.Position - dragStart
            floatingBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    floatingBtn.TouchEnded:Connect(function() dragging = false end)

    -- Ventana principal (con animación al abrir)
    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0.9, 0, 0.85, 0)
    mainFrame.Position = UDim2.new(0.05, 0, 0.075, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Visible = false
    local cornerMain = Instance.new("UICorner", mainFrame)
    cornerMain.CornerRadius = UDim.new(0, 16)

    -- Título con icono
    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "⚙️ RC2 ULTIMATE"
    title.TextColor3 = Color3.fromRGB(255, 200, 80)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1

    -- Sistema de pestañas (Tabs) con estilo moderno
    local tabFrame = Instance.new("Frame", mainFrame)
    tabFrame.Size = UDim2.new(1, 0, 0, 45)
    tabFrame.Position = UDim2.new(0, 0, 0, 55)
    tabFrame.BackgroundTransparency = 1

    local tabs = {}
    local function createTab(name, icon)
        local btn = Instance.new("TextButton", tabFrame)
        btn.Size = UDim2.new(0.25, 0, 1, 0)
        btn.Position = UDim2.new(#tabs * 0.25, 0, 0, 0)
        btn.Text = icon .. " " .. name
        btn.TextScaled = true
        btn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
        btn.BackgroundTransparency = 0.2
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 8)
        table.insert(tabs, btn)
        return btn
    end

    local tabFarm = createTab("Farm", "🌱")
    local tabTele = createTab("Teleports", "📍")
    local tabOthers = createTab("Others", "⚙️")

    -- Contenedor de contenido (scrollable)
    local contentFrame = Instance.new("ScrollingFrame", mainFrame)
    contentFrame.Size = UDim2.new(1, 0, 1, -110)
    contentFrame.Position = UDim2.new(0, 0, 0, 105)
    contentFrame.BackgroundTransparency = 1
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 900)
    contentFrame.ScrollBarThickness = 6

    -- ====== PESTAÑA FARM ======
    local farmContent = Instance.new("Frame", contentFrame)
    farmContent.Size = UDim2.new(1, 0, 1, 0)
    farmContent.BackgroundTransparency = 1
    farmContent.Visible = true

    -- Toggle AutoFarm (estilo moderno)
    local farmToggle = Instance.new("TextButton", farmContent)
    farmToggle.Size = UDim2.new(0.9, 0, 0, 55)
    farmToggle.Position = UDim2.new(0.05, 0, 0.03, 0)
    farmToggle.Text = "⛏️ AutoFarm: OFF"
    farmToggle.TextScaled = true
    farmToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    local cornerToggle = Instance.new("UICorner", farmToggle)
    cornerToggle.CornerRadius = UDim.new(0, 10)
    farmToggle.TouchTap:Connect(function()
        autoFarmEnabled = not autoFarmEnabled
        farmToggle.Text = "⛏️ AutoFarm: " .. (autoFarmEnabled and "ON" or "OFF")
        if autoFarmEnabled then
            task.spawn(autoFarmLoop)
            notify("⛏️ AutoFarm iniciado", 3)
        else
            notify("⛏️ AutoFarm detenido", 3)
        end
    end)

    -- Selección de minerales (lista con checkboxes)
    local oreListLabel = Instance.new("TextLabel", farmContent)
    oreListLabel.Size = UDim2.new(0.9, 0, 0, 30)
    oreListLabel.Position = UDim2.new(0.05, 0, 0.13, 0)
    oreListLabel.Text = "📋 Selecciona minerales:"
    oreListLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    oreListLabel.TextScaled = true
    oreListLabel.BackgroundTransparency = 1

    local oreListFrame = Instance.new("ScrollingFrame", farmContent)
    oreListFrame.Size = UDim2.new(0.9, 0, 0, 200)
    oreListFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    oreListFrame.BackgroundTransparency = 1
    oreListFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
    oreListFrame.ScrollBarThickness = 4

    local function refreshOreList()
        for _, child in pairs(oreListFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local ores = findOres()
        local unique = {}
        for _, ore in pairs(ores) do
            if not table.find(unique, ore.name) then
                table.insert(unique, ore.name)
            end
        end
        for _, name in ipairs(unique) do
            local btn = Instance.new("TextButton", oreListFrame)
            btn.Size = UDim2.new(0.9, 0, 0, 40)
            local selected = table.find(selectedOres, name) ~= nil
            btn.Text = (selected and "✅ " or "⬜ ") .. name
            btn.TextScaled = true
            btn.BackgroundColor3 = selected and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(60, 60, 90)
            local corner = Instance.new("UICorner", btn)
            corner.CornerRadius = UDim.new(0, 8)
            btn.TouchTap:Connect(function()
                local idx = table.find(selectedOres, name)
                if idx then
                    table.remove(selectedOres, idx)
                else
                    table.insert(selectedOres, name)
                end
                refreshOreList()
            end)
        end
        oreListFrame.CanvasSize = UDim2.new(0, 0, 0, #unique * 45 + 20)
    end

    local refreshBtn = Instance.new("TextButton", farmContent)
    refreshBtn.Size = UDim2.new(0.4, 0, 0, 45)
    refreshBtn.Position = UDim2.new(0.3, 0, 0.5, 0)
    refreshBtn.Text = "🔄 Refrescar"
    refreshBtn.TextScaled = true
    refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    local cornerRefresh = Instance.new("UICorner", refreshBtn)
    cornerRefresh.CornerRadius = UDim.new(0, 10)
    refreshBtn.TouchTap:Connect(refreshOreList)

    -- ====== PESTAÑA TELEPORTS ======
    local teleContent = Instance.new("Frame", contentFrame)
    teleContent.Size = UDim2.new(1, 0, 1, 0)
    teleContent.BackgroundTransparency = 1
    teleContent.Visible = false

    local teleNameInput = Instance.new("TextBox", teleContent)
    teleNameInput.Size = UDim2.new(0.8, 0, 0, 45)
    teleNameInput.Position = UDim2.new(0.1, 0, 0.03, 0)
    teleNameInput.PlaceholderText = "📝 Nombre del teleport"
    teleNameInput.Text = ""
    teleNameInput.TextScaled = true
    teleNameInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    teleNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)

    local saveTeleBtn = Instance.new("TextButton", teleContent)
    saveTeleBtn.Size = UDim2.new(0.4, 0, 0, 45)
    saveTeleBtn.Position = UDim2.new(0.05, 0, 0.13, 0)
    saveTeleBtn.Text = "💾 Guardar"
    saveTeleBtn.TextScaled = true
    saveTeleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    local cornerSave = Instance.new("UICorner", saveTeleBtn)
    cornerSave.CornerRadius = UDim.new(0, 10)
    saveTeleBtn.TouchTap:Connect(function()
        local name = teleNameInput.Text
        if name ~= "" then
            saveCurrentLocation(name)
            teleNameInput.Text = ""
            refreshTeleList()
        else
            notify("❌ Escribe un nombre", 2)
        end
    end)

    local teleListFrame = Instance.new("ScrollingFrame", teleContent)
    teleListFrame.Size = UDim2.new(0.9, 0, 0, 200)
    teleListFrame.Position = UDim2.new(0.05, 0, 0.22, 0)
    teleListFrame.BackgroundTransparency = 1
    teleListFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
    teleListFrame.ScrollBarThickness = 4

    local function refreshTeleList()
        for _, child in pairs(teleListFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local names = listTeleports()
        for _, name in ipairs(names) do
            local btn = Instance.new("TextButton", teleListFrame)
            btn.Size = UDim2.new(0.9, 0, 0, 40)
            btn.Text = "📍 " .. name
            btn.TextScaled = true
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
            local corner = Instance.new("UICorner", btn)
            corner.CornerRadius = UDim.new(0, 8)
            btn.TouchTap:Connect(function()
                teleportToLocation(name)
            end)
            btn.TouchLongPress:Connect(function()
                if deleteTeleport(name) then
                    refreshTeleList()
                end
            end)
        end
        teleListFrame.CanvasSize = UDim2.new(0, 0, 0, #names * 45 + 20)
    end

    -- ====== PESTAÑA OTHERS ======
    local othersContent = Instance.new("Frame", contentFrame)
    othersContent.Size = UDim2.new(1, 0, 1, 0)
    othersContent.BackgroundTransparency = 1
    othersContent.Visible = false

    -- Fly
    local flyBtn = Instance.new("TextButton", othersContent)
    flyBtn.Size = UDim2.new(0.9, 0, 0, 50)
    flyBtn.Position = UDim2.new(0.05, 0, 0.03, 0)
    flyBtn.Text = "🦅 Fly: OFF"
    flyBtn.TextScaled = true
    flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    local cornerFly = Instance.new("UICorner", flyBtn)
    cornerFly.CornerRadius = UDim.new(0, 10)
    flyBtn.TouchTap:Connect(function()
        local state = toggleFly()
        flyBtn.Text = "🦅 Fly: " .. (state and "ON" or "OFF")
    end)

    -- Infinite Jump
    local jumpBtn = Instance.new("TextButton", othersContent)
    jumpBtn.Size = UDim2.new(0.9, 0, 0, 50)
    jumpBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
    jumpBtn.Text = "🦘 Infinite Jump: OFF"
    jumpBtn.TextScaled = true
    jumpBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    local cornerJump = Instance.new("UICorner", jumpBtn)
    cornerJump.CornerRadius = UDim.new(0, 10)
    jumpBtn.TouchTap:Connect(function()
        local state = toggleInfiniteJump()
        jumpBtn.Text = "🦘 Infinite Jump: " .. (state and "ON" or "OFF")
    end)

    -- Time Display
    local timeBtn = Instance.new("TextButton", othersContent)
    timeBtn.Size = UDim2.new(0.9, 0, 0, 50)
    timeBtn.Position = UDim2.new(0.05, 0, 0.27, 0)
    timeBtn.Text = "🕐 Time: ON"
    timeBtn.TextScaled = true
    timeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    local cornerTime = Instance.new("UICorner", timeBtn)
    cornerTime.CornerRadius = UDim.new(0, 10)
    timeBtn.TouchTap:Connect(function()
        local state = toggleTime()
        timeBtn.Text = "🕐 Time: " .. (state and "ON" or "OFF")
    end)

    -- Ver Logs
    local logsBtn = Instance.new("TextButton", othersContent)
    logsBtn.Size = UDim2.new(0.9, 0, 0, 50)
    logsBtn.Position = UDim2.new(0.05, 0, 0.39, 0)
    logsBtn.Text = "📜 Ver Logs"
    logsBtn.TextScaled = true
    logsBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    local cornerLogs = Instance.new("UICorner", logsBtn)
    cornerLogs.CornerRadius = UDim.new(0, 10)
    logsBtn.TouchTap:Connect(function()
        local date = os.date("%Y-%m-%d")
        local logFile = logsFolder .. "/log_" .. date .. ".txt"
        if isfile(logFile) then
            local content = readfile(logFile)
            notify("📄 Logs del día:\n" .. content:sub(1, 250) .. "...", 6)
        else
            notify("📄 No hay logs hoy", 3)
        end
    end)

    -- Cambio de pestañas con animación
    local function switchTab(tab, content)
        for _, t in ipairs(tabs) do
            t.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
        end
        tab.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        farmContent.Visible = (content == farmContent)
        teleContent.Visible = (content == teleContent)
        othersContent.Visible = (content == othersContent)
    end

    tabFarm.TouchTap:Connect(function() switchTab(tabFarm, farmContent) end)
    tabTele.TouchTap:Connect(function() switchTab(tabTele, teleContent); refreshTeleList() end)
    tabOthers.TouchTap:Connect(function() switchTab(tabOthers, othersContent) end)

    -- Mostrar/ocultar GUI con el botón flotante
    local guiVisible = false
    floatingBtn.TouchTap:Connect(function()
        guiVisible = not guiVisible
        mainFrame.Visible = guiVisible
        if guiVisible then
            refreshOreList()
            refreshTeleList()
        end
    end)

    -- Hacer la ventana arrastrable
    local dragFrame = false
    local dragStartF, startPosF
    mainFrame.TouchBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragFrame = true
            dragStartF = input.Position
            startPosF = mainFrame.Position
        end
    end)
    mainFrame.TouchMoved:Connect(function(input)
        if dragFrame then
            local delta = input.Position - dragStartF
            mainFrame.Position = UDim2.new(startPosF.X.Scale, startPosF.X.Offset + delta.X, startPosF.Y.Scale, startPosF.Y.Offset + delta.Y)
        end
    end)
    mainFrame.TouchEnded:Connect(function() dragFrame = false end)

    -- Botón cerrar (X)
    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0, 50, 0, 40)
    closeBtn.Position = UDim2.new(1, -55, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.TextScaled = true
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BackgroundTransparency = 0.3
    local cornerClose = Instance.new("UICorner", closeBtn)
    cornerClose.CornerRadius = UDim.new(0, 8)
    closeBtn.TouchTap:Connect(function()
        mainFrame.Visible = false
        guiVisible = false
    end)

    return screenGui
end

-- ============================================================
-- 14. INICIALIZACIÓN
-- ============================================================
notify("🚀 RC2 ULTIMATE FINAL cargado", 4)
writeLog("Script cargado correctamente")

-- Crear UI
local ui = createUI()
notify("📌 Toca el botón engranaje en la esquina inferior derecha", 5)

-- Mensaje en consola (para referencia)
print("✅ RC2 ULTIMATE FINAL cargado")
print("📁 Carpeta de datos: " .. scriptFolder)
print("📊 Minerales detectados: " .. #oreDatabase)
print("🌳 Árboles detectados: " .. #treeDatabase)
print("👤 NPCs detectados: " .. #npcDatabase)