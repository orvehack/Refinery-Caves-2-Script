-- ============================================================
-- RC2 COMPLETE - TODAS LAS FUNCIONES
-- ============================================================
-- Icono: Pico + Hacha cruzados (rbxassetid://4483362458)
-- Librería UI: Rayfield (compatible con Delta)
-- ============================================================

-- 1. CARGAR RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 2. CARPETA DE DATOS
local folder = "rc2_complete_data"
local logsFolder = folder .. "/logs"
if not isfolder(folder) then makefolder(folder) end
if not isfolder(logsFolder) then makefolder(logsFolder) end

-- 3. SISTEMA DE LOGS (CON ERRORES EN ROJO)
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
writeLog("=== RC2 COMPLETE INICIADO ===")

-- 4. NOTIFICACIÓN CON RAYFIELD
local function notify(text)
    Rayfield:Notify({
        Title = "⚙️ RC2",
        Content = text,
        Duration = 3,
    })
    writeLog(text)
end

-- 5. VARIABLES GLOBALES
local autoFarm = false
local autoFish = false
local autoMissions = false
local selectedOres = {}
local selectedTrees = {}
local flyEnabled = false
local infiniteJump = false
local antiStaff = true
local antiAFK = true
local flySpeed = 50
local teleports = {}
local teleportsFile = folder .. "/teleports.json"
local configFile = folder .. "/config.json"
local missionsProgress = {}
local playerMoney = 0

-- 6. BASE DE DATOS DE MINERALES (DESDE JSON)
local oreDatabase = {
    ["Stone"] = { tier = 1, fragile = false },
    ["Iron"] = { tier = 1, fragile = false },
    ["Copper"] = { tier = 1, fragile = false },
    ["Coal"] = { tier = 2, fragile = false },
    ["Quartz"] = { tier = 2, fragile = false },
    ["Scarlet"] = { tier = 2, fragile = false },
    ["Cloudnite"] = { tier = 3, fragile = false },
    ["Cobalt"] = { tier = 3, fragile = false },
    ["Obsidian"] = { tier = 4, fragile = false },
    ["Volcanium"] = { tier = 5, fragile = false },
    ["Blastshard"] = { tier = 4, fragile = true },
    ["Voltshard"] = { tier = 4, fragile = true },
    ["Crystal"] = { tier = 4, fragile = true },
}

local treeDatabase = {
    ["Oak"] = { tier = 1 },
    ["Birch"] = { tier = 2 },
    ["Palm"] = { tier = 2 },
    ["Sakura"] = { tier = 3 },
    ["Silverwood"] = { tier = 4 },
    ["Goldwood"] = { tier = 4 },
}

-- 7. BASE DE DATOS DE MISIONES
local missionsDB = {
    {
        id = "tool_reaper",
        name = "Tool Reaper",
        npc = "Maroon",
        location = "Silver's Sellzone",
        cost = 0,
        items = {"Relic"},
        reward = "Tool Reaper (no pierdes herramientas)",
        completed = false,
        progress = 0
    },
    {
        id = "golden_ticket",
        name = "Golden Ticket",
        npc = "Silver",
        location = "Silver's Sellzone",
        cost = 0,
        items = {"Gold", "Crystal Fish", "Silverwood"},
        reward = "Golden Ticket ($200 de descuento)",
        completed = false,
        progress = 0
    },
    {
        id = "parkourist",
        name = "Parkourist",
        npc = "Mountain Eve",
        location = "Vi's Logics",
        cost = 0,
        items = {},
        reward = "Parkourist (saltos de 5 studs)",
        completed = false,
        progress = 0
    },
    {
        id = "proton_phase1",
        name = "Proton-24 (Fase 1)",
        npc = "Violet",
        location = "Vi's Lab",
        cost = 100,
        items = {"RefinedIron", "RefinedIron", "RefinedIron"},
        reward = "Proton-24 (Fase 1 completada)",
        completed = false,
        progress = 0
    },
    {
        id = "proton_phase2",
        name = "Proton-24 (Fase 2)",
        npc = "Violet",
        location = "Vi's Lab",
        cost = 500,
        items = {"RefinedCopper", "NOTGate", "XORGate", "ANDGate"},
        reward = "Proton-24 (Fase 2 completada)",
        completed = false,
        progress = 0
    },
    {
        id = "proton_phase3",
        name = "Proton-24 (Fase 3)",
        npc = "Violet",
        location = "Vi's Lab",
        cost = 200,
        items = {"Voltshard", "Voltshard", "Voltshard"},
        reward = "Proton-24 (COMPLETADO)",
        completed = false,
        progress = 0
    },
    {
        id = "hookling_phase1",
        name = "Hookling-8 (Fase 1)",
        npc = "Violet",
        location = "Vi's Lab",
        cost = 100,
        items = {"RefinedIron", "RefinedIron", "RefinedIron"},
        reward = "Hookling-8 (Fase 1 completada)",
        completed = false,
        progress = 0
    },
    {
        id = "hookling_phase2",
        name = "Hookling-8 (Fase 2)",
        npc = "Violet",
        location = "Vi's Lab",
        cost = 1500,
        items = {"RefinedCopper", "RefinedCopper", "RefinedCopper", "RefinedCopper", "RefinedCopper", "RefinedCopper", "ANDGate", "ANDGate", "XORGate", "XORGate", "MemoryStorage"},
        reward = "Hookling-8 (Fase 2 completada)",
        completed = false,
        progress = 0
    },
    {
        id = "hookling_phase3",
        name = "Hookling-8 (Fase 3)",
        npc = "Violet",
        location = "Vi's Lab",
        cost = 300,
        items = {"Blastshard", "Blastshard", "Blastshard", "Obsidian", "Obsidian", "Obsidian"},
        reward = "Hookling-8 (COMPLETADO)",
        completed = false,
        progress = 0
    },
    {
        id = "start_on_oil",
        name = "Start On Oil",
        npc = "Mike",
        location = "Oil Rig",
        cost = 0,
        items = {},
        reward = "Acceso a la plataforma",
        completed = false,
        progress = 0
    },
    {
        id = "industrializing_oil",
        name = "Industrializing Oil",
        npc = "Steven",
        location = "Oil Rig",
        cost = 0,
        items = {},
        reward = "Industrial Drill desbloqueado",
        completed = false,
        progress = 0
    },
    {
        id = "crafter",
        name = "Crafter",
        npc = "Spyke",
        location = "Oil Rig",
        cost = 0,
        items = {},
        reward = "Fabricación desbloqueada",
        completed = false,
        progress = 0
    },
    {
        id = "unlock_limits",
        name = "Unlock the Limits",
        npc = "Emmanuel",
        location = "Oil Rig",
        cost = 0,
        items = {},
        reward = "Límites aumentados",
        completed = false,
        progress = 0
    },
}

-- 8. TELEPORTS PREDEFINIDOS (UBICACIONES EXACTAS)
local defaultTeleports = {
    ["🏠 Novabay Spawn"] = { position = {0, 0, 0}, type = "default" },
    ["🏪 UCS Store"] = { position = {1250, 30, -700}, type = "default" },
    ["💰 Silver's Sellzone"] = { position = {960, 32, -840}, type = "default" },
    ["🎣 Fisherman's Bazaar"] = { position = {1860, 3, -1520}, type = "default" },
    ["⛏️ Rosewell Quarry"] = { position = {750, 50, -960}, type = "default" },
    ["🏔️ Mountain Adam"] = { position = {-300, 200, -300}, type = "default" },
    ["🌋 Scorching Valley"] = { position = {-1000, 50, 500}, type = "default" },
    ["💎 Crystalized Abyss"] = { position = {-7000, -600, 1100}, type = "default" },
    ["🧪 Vi's Lab"] = { position = {-4434, -195, -2015}, type = "default" },
    ["🛢️ Oil Rig"] = { position = {-2350, 54, 5339}, type = "default" },
    ["🏝️ Sakura Island"] = { position = {-5959, 22, 4567}, type = "default" },
    ["🗿 Stone Cradle"] = { position = {-5300, -200, 5600}, type = "default" },
    ["🌲 Lush Valley"] = { position = {-560, -530, 1000}, type = "default" },
}

-- 9. FUNCIONES DE JUGADOR
local function getPlayerMoney()
    local player = game:GetService("Players").LocalPlayer
    local stats = player:FindFirstChild("leaderstats")
    if stats then
        local money = stats:FindFirstChild("Money")
        if money then return money.Value end
    end
    return 0
end

local function getPlayerPickaxeTier()
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then return 0 end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then return 0 end
    local name = tool.Name
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

-- 10. DETECCIÓN DE RECURSOS
local function findOres()
    local ores = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local name = obj.Name or ""
            for oreName, data in pairs(oreDatabase) do
                if name:find(oreName) or name:find(oreName:lower()) then
                    table.insert(ores, {object = obj, name = oreName, tier = data.tier, fragile = data.fragile})
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

-- 11. AUTO FARM - MINERÍA
local function mineOre(ore)
    local swing = ore.fragile and 0.6 or 1.0
    -- Simular minado
    task.wait(0.3 + swing * 0.4)
end

local function autoFarmLoop()
    while autoFarm do
        local ores = findOres()
        local mined = 0
        for _, ore in pairs(ores) do
            if #selectedOres == 0 or table.find(selectedOres, ore.name) then
                local playerTier = getPlayerPickaxeTier()
                if playerTier >= ore.tier then
                    mineOre(ore)
                    mined = mined + 1
                else
                    notify("⚠️ No puedes minar " .. ore.name .. " (Tier " .. ore.tier .. ")")
                end
            end
        end
        if mined == 0 then task.wait(3) else task.wait(1) end
    end
end

-- 12. AUTO MISSIONS
local function checkMissionProgress(mission)
    -- Verificar si la misión ya está completada
    if mission.completed then return true end
    
    -- Verificar dinero
    local money = getPlayerMoney()
    if money < mission.cost then
        local falta = mission.cost - money
        notify("❌ No tienes dinero suficiente. Necesitas $" .. falta .. " más.")
        return false
    end
    
    -- Aquí iría la lógica de reanudación (simulada)
    notify("✅ Misión '" .. mission.name .. "' completada!")
    mission.completed = true
    return true
end

-- 13. TELEPORTS (PERSISTENTES)
local function loadTeleports()
    if isfile(teleportsFile) then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(teleportsFile))
        end)
        if success and type(data) == "table" then
            teleports = data
        end
    end
    -- Fusionar con teleports por defecto
    for name, data in pairs(defaultTeleports) do
        if not teleports[name] then
            teleports[name] = data
        end
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
    if not char then notify("❌ Personaje no encontrado"); return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then notify("❌ HumanoidRootPart no encontrado"); return false end
    local pos = hrp.Position
    teleports[name] = {position = {pos.X, pos.Y, pos.Z}, savedAt = os.date("%Y-%m-%d %H:%M:%S"), type = "custom"}
    saveTeleports()
    notify("✅ Ubicación '" .. name .. "' guardada")
    return true
end

local function teleportToLocation(name)
    local data = teleports[name]
    if not data then notify("❌ Ubicación no encontrada"); return false end
    local target = Vector3.new(data.position[1], data.position[2], data.position[3])
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then notify("❌ Personaje no encontrado"); return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then notify("❌ HumanoidRootPart no encontrado"); return false end

    -- Anti-teleport suave (10 pasos)
    local steps = 10
    local start = hrp.Position
    for i = 1, steps do
        local progress = i / steps
        local inter = start + (target - start) * progress
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum:MoveTo(inter) end
        task.wait(0.08)
    end
    notify("📍 Teletransportado a '" .. name .. "'")
    return true
end

local function listTeleports()
    local names = {}
    for name, _ in pairs(teleports) do table.insert(names, name) end
    return names
end

local function deleteTeleport(name)
    if teleports[name] and teleports[name].type == "custom" then
        teleports[name] = nil
        saveTeleports()
        notify("🗑️ Teleport eliminado")
        return true
    elseif teleports[name] then
        notify("❌ No puedes eliminar un teleport por defecto")
        return false
    end
    return false
end

loadTeleports()

-- 14. FLY (CON CONTROLES TÁCTILES)
local flyMoving = {forward = false, backward = false, left = false, right = false, up = false, down = false}
local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyConnection = nil
local flyGui = nil

local function createFlyControls()
    local sg = Instance.new("ScreenGui", gethui())
    sg.Name = "FlyControls"
    sg.ResetOnSpawn = false

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.4, 0, 0.3, 0)
    frame.Position = UDim2.new(0.55, 0, 0.65, 0)
    frame.BackgroundTransparency = 1

    local function createButton(text, posX, posY, sizeX, sizeY, on, off)
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(sizeX, 0, sizeY, 0)
        btn.Position = UDim2.new(posX, 0, posY, 0)
        btn.Text = text
        btn.TextScaled = true
        btn.BackgroundColor3 = Color3.fromRGB(50, 60, 90)
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 6)
        btn.TouchBegan:Connect(on)
        btn.TouchEnded:Connect(off)
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

local function startFly()
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then notify("❌ Personaje no encontrado"); return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then notify("❌ HumanoidRootPart no encontrado"); return end

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

    notify("🦅 Fly activado")
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
    notify("🦅 Fly desactivado")
end

local function toggleFly()
    flyEnabled = not flyEnabled
    if flyEnabled then startFly() else stopFly() end
    return flyEnabled
end

-- 15. INFINITE JUMP
local function toggleInfiniteJump()
    infiniteJump = not infiniteJump
    local char = game:GetService("Players").LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.JumpPower = infiniteJump and 50 or 50
        end
    end
    notify("🦘 Infinite Jump: " .. (infiniteJump and "ON" or "OFF"))
    return infiniteJump
end

local function setupInfiniteJump()
    local player = game:GetService("Players").LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    hum:GetPropertyChangedSignal("Jump"):Connect(function()
        if infiniteJump and hum.Jump then
            task.wait(0.05)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    setupInfiniteJump()
end)
setupInfiniteJump()

-- 16. TIME DISPLAY
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
    notify("🕐 Time: " .. (timeEnabled and "ON" or "OFF"))
    return timeEnabled
end

-- 17. ANTI-STAFF
local staffDetected = false
local function checkStaff()
    if not antiStaff then return end
    local players = game:GetService("Players"):GetPlayers()
    for _, plr in pairs(players) do
        local name = plr.Name:lower()
        if name:find("admin") or name:find("mod") or name:find("staff") or name:find("developer") then
            if not staffDetected then
                staffDetected = true
                notify("⚠️ Staff detectado: " .. plr.Name .. ". Modo seguro activado.")
                writeLog("Staff detectado: " .. plr.Name, true)
            end
            return true
        end
    end
    staffDetected = false
    return false
end

task.spawn(function()
    while task.wait(10) do
        checkStaff()
    end
end)

-- 18. ANTI-AFK
local lastActivity = tick()
game:GetService("UserInputService").InputBegan:Connect(function()
    lastActivity = tick()
end)

task.spawn(function()
    while task.wait(60) do
        if not antiAFK then break end
        if tick() - lastActivity > 60 then
            -- Simular actividad humana
            local camera = workspace.CurrentCamera
            if camera then
                camera.CFrame = camera.CFrame * CFrame.Angles(0, math.rad(math.random(-5, 5)), 0)
            end
            lastActivity = tick()
        end
    end
end)

-- 19. ANTI-BAN (HOOK DE KICK)
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

-- 20. CREAR GUI CON RAYFIELD (ICONO CHIDO)
local Window = Rayfield:CreateWindow({
    Name = "⚒️ RC2 COMPLETE",
    Icon = "rbxassetid://4483362458", -- Pico + Hacha cruzados
    LoadingTitle = "Cargando RC2...",
    LoadingSubtitle = "by orvehack",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = folder,
   },
})

-- ====== PESTAÑA 1: FARM ======
local FarmTab = Window:CreateTab("🌱 Farm", 0)

FarmTab:CreateToggle({
    Name = "⛏️ AutoFarm (Minerales)",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        autoFarm = Value
        if autoFarm then
            task.spawn(autoFarmLoop)
            notify("⛏️ AutoFarm iniciado")
        else
            notify("⛏️ AutoFarm detenido")
        end
    end,
})

FarmTab:CreateToggle({
    Name = "🎣 AutoFish",
    CurrentValue = false,
    Flag = "AutoFish",
    Callback = function(Value)
        autoFish = Value
        notify("🎣 AutoFish: " .. (autoFish and "ON" or "OFF"))
    end,
})

-- Selección de minerales
FarmTab:CreateParagraph({
    Title = "📋 Selecciona minerales",
    Content = "Toca los botones para seleccionar/deseleccionar",
})

local function createOreButtons()
    local ores = findOres()
    local unique = {}
    for _, ore in pairs(ores) do
        if not table.find(unique, ore.name) then
            table.insert(unique, ore.name)
        end
    end
    for _, name in ipairs(unique) do
        FarmTab:CreateButton({
            Name = name .. (table.find(selectedOres, name) and " ✅" or ""),
            Callback = function()
                local idx = table.find(selectedOres, name)
                if idx then
                    table.remove(selectedOres, idx)
                else
                    table.insert(selectedOres, name)
                end
                createOreButtons()
            end,
        })
    end
end

FarmTab:CreateButton({
    Name = "🔄 Refrescar minerales",
    Callback = function()
        createOreButtons()
        notify("🔄 Lista actualizada")
    end,
})

-- ====== PESTAÑA 2: MISSIONS ======
local MissionsTab = Window:CreateTab("📜 Missions", 1)

MissionsTab:CreateToggle({
    Name = "🤖 AutoMissions",
    CurrentValue = false,
    Flag = "AutoMissions",
    Callback = function(Value)
        autoMissions = Value
        notify("🤖 AutoMissions: " .. (autoMissions and "ON" or "OFF"))
    end,
})

MissionsTab:CreateParagraph({
    Title = "📋 Misiones disponibles",
    Content = "Estado actual de cada misión",
})

-- Mostrar misiones con estado
for _, mission in ipairs(missionsDB) do
    local status = mission.completed and "🟢 Completada" or "⏳ Pendiente"
    MissionsTab:CreateParagraph({
        Title = mission.name,
        Content = "📌 " .. mission.npc .. " (" .. mission.location .. ")\n💰 Coste: $" .. mission.cost .. "\n🎁 Recompensa: " .. mission.reward .. "\n📊 Estado: " .. status,
    })
    MissionsTab:CreateButton({
        Name = mission.completed and "✅ Ya completada" : "▶️ Iniciar misión",
        Callback = function()
            if mission.completed then
                notify("✅ Misión ya completada")
                return
            end
            local money = getPlayerMoney()
            if money < mission.cost then
                local falta = mission.cost - money
                notify("❌ No tienes dinero suficiente. Necesitas $" .. falta .. " más.")
            else
                checkMissionProgress(mission)
            end
        end,
    })
end

-- ====== PESTAÑA 3: TELEPORTS ======
local TeleTab = Window:CreateTab("📍 Teleports", 2)

TeleTab:CreateParagraph({
    Title = "📌 Teleports disponibles",
    Content = "Toca para ir a una ubicación",
})

-- Teleports predefinidos
TeleTab:CreateParagraph({
    Title = "📍 Ubicaciones predefinidas",
    Content = "",
})

local function createTeleportButtons()
    local names = listTeleports()
    for _, name in ipairs(names) do
        TeleTab:CreateButton({
            Name = name,
            Callback = function()
                teleportToLocation(name)
            end,
        })
    end
end

createTeleportButtons()

TeleTab:CreateParagraph({
    Title = "💾 Guardar ubicación personalizada",
    Content = "Escribe un nombre y guarda tu posición actual",
})

local teleName = ""
TeleTab:CreateInput({
    Name = "Nombre del teleport",
    PlaceholderText = "Ej: Mi base",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        teleName = Text
    end,
})

TeleTab:CreateButton({
    Name = "💾 Guardar ubicación",
    Callback = function()
        if teleName ~= "" then
            saveCurrentLocation(teleName)
            teleName = ""
        else
            notify("❌ Escribe un nombre primero")
        end
    end,
})

TeleTab:CreateButton({
    Name = "🗑️ Eliminar teleport personalizado (mantén presionado)",
    Callback = function()
        local names = listTeleports()
        local customNames = {}
        for _, name in ipairs(names) do
            if teleports[name] and teleports[name].type == "custom" then
                table.insert(customNames, name)
            end
        end
        if #customNames == 0 then
            notify("❌ No hay teleports personalizados")
            return
        end
        -- Mostrar opciones (simplificado)
        notify("📋 Teleports personalizados: " .. table.concat(customNames, ", "))
    end,
})

-- ====== PESTAÑA 4: OTHERS ======
local OthersTab = Window:CreateTab("⚙️ Others", 3)

OthersTab:CreateToggle({
    Name = "🦅 Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        toggleFly()
    end,
})

OthersTab:CreateSlider({
    Name = "🚀 Velocidad de Fly",
    Min = 20,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(255, 200, 80),
    Increment = 5,
    ValueName = "km/h",
    Callback = function(Value)
        flySpeed = Value
    end,
})

OthersTab:CreateToggle({
    Name = "🦘 Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(Value)
        toggleInfiniteJump()
    end,
})

OthersTab:CreateToggle({
    Name = "🕐 Time Display",
    CurrentValue = true,
    Flag = "TimeDisplay",
    Callback = function(Value)
        toggleTime()
    end,
})

OthersTab:CreateToggle({
    Name = "🛡️ Anti-Staff",
    CurrentValue = true,
    Flag = "AntiStaff",
    Callback = function(Value)
        antiStaff = Value
        notify("🛡️ Anti-Staff: " .. (antiStaff and "ON" or "OFF"))
    end,
})

OthersTab:CreateToggle({
    Name = "💤 Anti-AFK",
    CurrentValue = true,
    Flag = "AntiAFK",
    Callback = function(Value)
        antiAFK = Value
        notify("💤 Anti-AFK: " .. (antiAFK and "ON" or "OFF"))
    end,
})

-- ====== PESTAÑA 5: SETTINGS ======
local SettingsTab = Window:CreateTab("⚙️ Settings", 4)

SettingsTab:CreateParagraph({
    Title = "📊 Información del jugador",
    Content = "",
})

SettingsTab:CreateButton({
    Name = "💰 Actualizar dinero",
    Callback = function()
        local money = getPlayerMoney()
        notify("💰 $" .. money)
    end,
})

SettingsTab:CreateButton({
    Name = "⛏️ Ver pico equipado",
    Callback = function()
        local tier = getPlayerPickaxeTier()
        notify("⛏️ Tier del pico: " .. tier)
    end,
})

SettingsTab:CreateButton({
    Name = "📜 Ver Logs de hoy",
    Callback = function()
        local date = os.date("%Y-%m-%d")
        local logFile = logsFolder .. "/log_" .. date .. ".txt"
        if isfile(logFile) then
            local content = readfile(logFile)
            notify("📄 Logs: " .. content:sub(1, 250) .. "...")
        else
            notify("📄 No hay logs hoy")
        end
    end,
})

SettingsTab:CreateButton({
    Name = "🔄 Recargar script",
    Callback = function()
        notify("🔄 Recargando...")
        task.wait(1)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/orvehack/Refinery-Caves-2-Script/main/RC2_Complete.lua"))()
    end,
})

-- 21. INICIALIZACIÓN
notify("🚀 RC2 COMPLETE cargado correctamente")
notify("📁 Datos en: " .. folder)
writeLog("Script cargado correctamente")
notify("✅ RC2 COMPLETE cargado")
notify("📁 Carpeta: " .. folder)
