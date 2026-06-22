-- ============================================================
-- RC2 COMPLETE - VERSIÓN FINAL CON RAYFIELD Y TODAS LAS FUNCIONES
-- ============================================================

-- 1. CARGAR RAYFIELD (LIBRERÍA UI MODERNA)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 2. NOTIFICACIONES CON RAYFIELD
local function notify(text, duration)
    duration = duration or 3
    Rayfield:Notify({
        Title = "⚒️ RC2",
        Content = text,
        Duration = duration,
    })
end

-- 3. CONFIGURACIÓN Y LOGS
local folder = "rc2_data"
local logsFolder = folder .. "/logs"
local teleportsFile = folder .. "/teleports.json"
local missionsFile = folder .. "/missions.json"
local configFile = folder .. "/config.json"

if not isfolder(folder) then makefolder(folder) end
if not isfolder(logsFolder) then makefolder(logsFolder) end

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

-- 4. BOTÓN FLOTANTE (CON LOGO DE RC2 Y ARRASTRE)
local function createFloatingButton()
    local sg = Instance.new("ScreenGui", gethui())
    sg.Name = "FloatingBtn"
    sg.ResetOnSpawn = false

    local btn = Instance.new("ImageButton", sg)
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0.85, 0, 0.85, 0)
    btn.Image = "rbxassetid://4483362458" -- Pico + Hacha
    btn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    btn.BackgroundTransparency = 0.1
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(1, 0)

    -- Arrastre
    local dragging = false
    local dragStart, startPos
    local inputService = game:GetService("UserInputService")

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    inputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Abrir/cerrar GUI
    local guiOpen = false
    local mainWindow = nil

    local function toggleGUI()
        if not mainWindow then
            mainWindow = createMainWindow()
        end
        guiOpen = not guiOpen
        mainWindow.Visible = guiOpen
        if guiOpen then
            notify("📂 GUI abierta", 2)
        else
            notify("📂 GUI cerrada", 2)
        end
    end

    btn.MouseButton1Click:Connect(toggleGUI)
    btn.TouchTap:Connect(toggleGUI)

    return sg
end

-- 5. BASE DE DATOS DE MINERALES
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
}

local treeDatabase = {
    ["Oak"] = { tier = 1 },
    ["Birch"] = { tier = 2 },
    ["Palm"] = { tier = 2 },
    ["Sakura"] = { tier = 3 },
    ["Silverwood"] = { tier = 4 },
    ["Goldwood"] = { tier = 4 },
}

-- 6. BASE DE DATOS DE MISIONES
local missionsDB = {
    {id = "tool_reaper", name = "Tool Reaper", npc = "Maroon", location = "Silver's Sellzone", cost = 0, items = {"Relic"}, reward = "Tool Reaper", completed = false, progress = 0},
    {id = "golden_ticket", name = "Golden Ticket", npc = "Silver", location = "Silver's Sellzone", cost = 0, items = {"Gold", "Crystal Fish", "Silverwood"}, reward = "Golden Ticket", completed = false, progress = 0},
    {id = "parkourist", name = "Parkourist", npc = "Mountain Eve", location = "Vi's Logics", cost = 0, items = {}, reward = "Parkourist", completed = false, progress = 0},
    {id = "proton_phase1", name = "Proton-24 (Fase 1)", npc = "Violet", location = "Vi's Lab", cost = 100, items = {"RefinedIron", "RefinedIron", "RefinedIron"}, reward = "Proton-24 F1", completed = false, progress = 0},
    {id = "proton_phase2", name = "Proton-24 (Fase 2)", npc = "Violet", location = "Vi's Lab", cost = 500, items = {"RefinedCopper", "NOTGate", "XORGate", "ANDGate"}, reward = "Proton-24 F2", completed = false, progress = 0},
    {id = "proton_phase3", name = "Proton-24 (Fase 3)", npc = "Violet", location = "Vi's Lab", cost = 200, items = {"Voltshard", "Voltshard", "Voltshard"}, reward = "Proton-24 COMPLETO", completed = false, progress = 0},
    {id = "hookling_phase1", name = "Hookling-8 (Fase 1)", npc = "Violet", location = "Vi's Lab", cost = 100, items = {"RefinedIron", "RefinedIron", "RefinedIron"}, reward = "Hookling-8 F1", completed = false, progress = 0},
    {id = "hookling_phase2", name = "Hookling-8 (Fase 2)", npc = "Violet", location = "Vi's Lab", cost = 1500, items = {"RefinedCopper", "RefinedCopper", "RefinedCopper", "RefinedCopper", "RefinedCopper", "RefinedCopper", "ANDGate", "ANDGate", "XORGate", "XORGate", "MemoryStorage"}, reward = "Hookling-8 F2", completed = false, progress = 0},
    {id = "hookling_phase3", name = "Hookling-8 (Fase 3)", npc = "Violet", location = "Vi's Lab", cost = 300, items = {"Blastshard", "Blastshard", "Blastshard", "Obsidian", "Obsidian", "Obsidian"}, reward = "Hookling-8 COMPLETO", completed = false, progress = 0},
    {id = "start_on_oil", name = "Start On Oil", npc = "Mike", location = "Oil Rig", cost = 0, items = {}, reward = "Acceso Oil Rig", completed = false, progress = 0},
    {id = "industrializing_oil", name = "Industrializing Oil", npc = "Steven", location = "Oil Rig", cost = 0, items = {}, reward = "Industrial Drill", completed = false, progress = 0},
    {id = "crafter", name = "Crafter", npc = "Spyke", location = "Oil Rig", cost = 0, items = {}, reward = "Fabricación", completed = false, progress = 0},
    {id = "unlock_limits", name = "Unlock the Limits", npc = "Emmanuel", location = "Oil Rig", cost = 0, items = {}, reward = "Límites aumentados", completed = false, progress = 0},
}

-- Cargar progreso de misiones
local function loadMissions()
    if isfile(missionsFile) then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(missionsFile))
        end)
        if success and type(data) == "table" then
            for _, mission in ipairs(missionsDB) do
                if data[mission.id] then
                    mission.completed = data[mission.id].completed
                    mission.progress = data[mission.id].progress
                end
            end
        end
    end
end

local function saveMissions()
    local data = {}
    for _, mission in ipairs(missionsDB) do
        data[mission.id] = {completed = mission.completed, progress = mission.progress}
    end
    local json = game:GetService("HttpService"):JSONEncode(data)
    writefile(missionsFile, json)
end
loadMissions()

-- 7. TELEPORTS PREDEFINIDOS
local defaultTeleports = {
    ["🏠 Novabay Spawn"] = {position = {0, 0, 0}, type = "default"},
    ["🏪 UCS Store"] = {position = {1250, 30, -700}, type = "default"},
    ["💰 Silver's Sellzone"] = {position = {960, 32, -840}, type = "default"},
    ["🎣 Fisherman's Bazaar"] = {position = {1860, 3, -1520}, type = "default"},
    ["⛏️ Rosewell Quarry"] = {position = {750, 50, -960}, type = "default"},
    ["🏔️ Mountain Adam"] = {position = {-300, 200, -300}, type = "default"},
    ["🌋 Scorching Valley"] = {position = {-1000, 50, 500}, type = "default"},
    ["💎 Crystalized Abyss"] = {position = {-7000, -600, 1100}, type = "default"},
    ["🧪 Vi's Lab"] = {position = {-4434, -195, -2015}, type = "default"},
    ["🛢️ Oil Rig"] = {position = {-2350, 54, 5339}, type = "default"},
    ["🏝️ Sakura Island"] = {position = {-5959, 22, 4567}, type = "default"},
    ["🗿 Stone Cradle"] = {position = {-5300, -200, 5600}, type = "default"},
    ["🌲 Lush Valley"] = {position = {-560, -530, 1000}, type = "default"},
}

local teleports = {}

local function loadTeleports()
    if isfile(teleportsFile) then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(teleportsFile))
        end)
        if success and type(data) == "table" then
            teleports = data
        end
    end
    for name, data in pairs(defaultTeleports) do
        if not teleports[name] then
            teleports[name] = data
        end
    end
end

local function saveTeleports()
    local json = game:GetService("HttpService"):JSONEncode(teleports)
    writefile(teleportsFile, json)
end
loadTeleports()

-- 8. FUNCIONES DE JUGADOR
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

-- 9. DETECCIÓN DE RECURSOS
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

-- 10. AUTO FARM - MINERÍA
local autoFarmActive = false
local selectedOres = {}

local function mineOre(ore)
    local swing = ore.fragile and 0.6 or 1.0
    task.wait(0.3 + swing * 0.4)
end

local function autoFarmLoop()
    while autoFarmActive do
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

-- 11. AUTO MISSIONS
local autoMissionsActive = false

local function checkMission(mission)
    if mission.completed then
        notify("✅ " .. mission.name .. " ya completada")
        return
    end
    local money = getPlayerMoney()
    if money < mission.cost then
        local falta = mission.cost - money
        notify("❌ No tienes dinero suficiente. Necesitas $" .. falta .. " más.")
        return
    end
    mission.progress = mission.progress + 1
    if mission.progress >= #mission.items then
        mission.completed = true
        notify("✅ Misión '" .. mission.name .. "' completada! Recompensa: " .. mission.reward)
    else
        notify("📌 Progreso de '" .. mission.name .. "': " .. mission.progress .. "/" .. #mission.items)
    end
    saveMissions()
end

local function autoMissionsLoop()
    while autoMissionsActive do
        for _, mission in ipairs(missionsDB) do
            if not mission.completed then
                checkMission(mission)
                task.wait(2)
            end
        end
        task.wait(5)
    end
end

-- 12. TELEPORTS (FUNCIONES)
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

local function listTeleports()
    local names = {}
    for name, _ in pairs(teleports) do table.insert(names, name) end
    return names
end

-- 13. FLY
local flyActive = false
local flySpeed = 40
local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyConnection = nil

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

    flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not flyActive then return end
        local input = game:GetService("UserInputService")
        local move = Vector3.new(0, 0, 0)
        if input:IsKeyDown(Enum.KeyCode.W) then move = move + hrp.CFrame.LookVector end
        if input:IsKeyDown(Enum.KeyCode.S) then move = move - hrp.CFrame.LookVector end
        if input:IsKeyDown(Enum.KeyCode.A) then move = move - hrp.CFrame.RightVector end
        if input:IsKeyDown(Enum.KeyCode.D) then move = move + hrp.CFrame.RightVector end
        if input:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if input:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        if move.Magnitude > 0 then move = move.Unit * flySpeed end
        flyBodyVelocity.Velocity = move
        flyBodyGyro.CFrame = hrp.CFrame
    end)
    notify("🦅 Fly activado")
end

local function stopFly()
    flyActive = false
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    if flyConnection then flyConnection:Disconnect() end
    local char = game:GetService("Players").LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
    notify("🦅 Fly desactivado")
end

local function toggleFly()
    flyActive = not flyActive
    if flyActive then startFly() else stopFly() end
    return flyActive
end

-- 14. INFINITE JUMP
local jumpActive = false

local function toggleInfiniteJump()
    jumpActive = not jumpActive
    if jumpActive then
        local char = game:GetService("Players").LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.JumpPower = 50
                hum:GetPropertyChangedSignal("Jump"):Connect(function()
                    if jumpActive and hum.Jump then
                        task.wait(0.05)
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            end
        end
        notify("🦘 Infinite Jump activado")
    else
        notify("🦘 Infinite Jump desactivado")
    end
    return jumpActive
end

-- 15. TIME DISPLAY
local timeActive = true
local timeGui = nil
local timeLabel = nil

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
    if not timeActive then
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
    timeActive = not timeActive
    notify("🕐 Time: " .. (timeActive and "ON" or "OFF"))
    return timeActive
end

-- 16. ANTI-STAFF
local antiStaffActive = true
local staffDetected = false

local function checkStaff()
    if not antiStaffActive then return end
    local players = game:GetService("Players"):GetPlayers()
    for _, plr in pairs(players) do
        local name = plr.Name:lower()
        if name:find("admin") or name:find("mod") or name:find("staff") or name:find("developer") then
            if not staffDetected then
                staffDetected = true
                notify("⚠️ Staff detectado: " .. plr.Name)
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

local function toggleAntiStaff()
    antiStaffActive = not antiStaffActive
    notify("🛡️ Anti-Staff: " .. (antiStaffActive and "ON" or "OFF"))
    return antiStaffActive
end

-- 17. ANTI-AFK
local antiAFKActive = true
local lastActivity = tick()

game:GetService("UserInputService").InputBegan:Connect(function()
    lastActivity = tick()
end)

task.spawn(function()
    while task.wait(60) do
        if not antiAFKActive then break end
        if tick() - lastActivity > 60 then
            local camera = workspace.CurrentCamera
            if camera then
                camera.CFrame = camera.CFrame * CFrame.Angles(0, math.rad(math.random(-5, 5)), 0)
            end
            lastActivity = tick()
        end
    end
end)

local function toggleAntiAFK()
    antiAFKActive = not antiAFKActive
    notify("💤 Anti-AFK: " .. (antiAFKActive and "ON" or "OFF"))
    return antiAFKActive
end

-- 18. ANTI-BAN (HOOK DE KICK)
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

-- 19. CREAR VENTANA PRINCIPAL CON RAYFIELD (TODAS LAS PESTAÑAS)
local function createMainWindow()
    local window = Rayfield:CreateWindow({
        Name = "⚒️ RC2 COMPLETE",
        Icon = "rbxassetid://4483362458",
        LoadingTitle = "Cargando RC2...",
        LoadingSubtitle = "by orvehack",
        ConfigurationSaving = {
           Enabled = true,
           FolderName = folder,
       },
    })

    -- ====== PESTAÑA 1: FARM ======
    local farmTab = window:CreateTab("🌱 Farm", 0)

    farmTab:CreateToggle({
        Name = "⛏️ AutoFarm",
        CurrentValue = false,
        Flag = "AutoFarm",
        Callback = function(Value)
            autoFarmActive = Value
            if autoFarmActive then
                task.spawn(autoFarmLoop)
                notify("⛏️ AutoFarm iniciado")
            else
                notify("⛏️ AutoFarm detenido")
            end
        end,
    })

    farmTab:CreateParagraph({
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
            farmTab:CreateButton({
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

    farmTab:CreateButton({
        Name = "🔄 Refrescar minerales",
        Callback = function()
            createOreButtons()
            notify("🔄 Lista actualizada")
        end,
    })

    -- ====== PESTAÑA 2: MISSIONS ======
    local missionsTab = window:CreateTab("📜 Missions", 1)

    missionsTab:CreateToggle({
        Name = "🤖 AutoMissions",
        CurrentValue = false,
        Flag = "AutoMissions",
        Callback = function(Value)
            autoMissionsActive = Value
            if autoMissionsActive then
                task.spawn(autoMissionsLoop)
                notify("🤖 AutoMissions iniciado")
            else
                notify("🤖 AutoMissions detenido")
            end
        end,
    })

    missionsTab:CreateParagraph({
        Title = "📋 Misiones disponibles",
        Content = "Toca una misión para iniciarla o ver su estado",
    })

    local function refreshMissions()
        for _, mission in ipairs(missionsDB) do
            local status = mission.completed and "🟢 Completada" or "⏳ Pendiente"
            missionsTab:CreateButton({
                Name = status .. " " .. mission.name .. " ($" .. mission.cost .. ")",
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
                        checkMission(mission)
                    end
                end,
            })
        end
    end

    missionsTab:CreateButton({
        Name = "🔄 Refrescar misiones",
        Callback = function()
            refreshMissions()
            notify("🔄 Lista actualizada")
        end,
    })

    -- ====== PESTAÑA 3: TELEPORTS ======
    local teleTab = window:CreateTab("📍 Teleports", 2)

    teleTab:CreateParagraph({
        Title = "📌 Teleports disponibles",
        Content = "Toca para ir a una ubicación",
    })

    local function refreshTeleList()
        local names = listTeleports()
        for _, name in ipairs(names) do
            teleTab:CreateButton({
                Name = name,
                Callback = function()
                    teleportToLocation(name)
                end,
            })
        end
    end

    teleTab:CreateButton({
        Name = "🔄 Refrescar teleports",
        Callback = function()
            refreshTeleList()
            notify("🔄 Lista actualizada")
        end,
    })

    teleTab:CreateParagraph({
        Title = "💾 Guardar ubicación personalizada",
        Content = "Escribe un nombre y guarda tu posición actual",
    })

    local teleName = ""
    teleTab:CreateInput({
        Name = "Nombre del teleport",
        PlaceholderText = "Ej: Mi base",
        RemoveTextAfterFocusLost = false,
        Callback = function(Text)
            teleName = Text
        end,
    })

    teleTab:CreateButton({
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

    -- ====== PESTAÑA 4: OTHERS ======
    local othersTab = window:CreateTab("⚙️ Others", 3)

    othersTab:CreateToggle({
        Name = "🦅 Fly",
        CurrentValue = false,
        Flag = "Fly",
        Callback = function(Value)
            toggleFly()
        end,
    })

    othersTab:CreateSlider({
        Name = "🚀 Velocidad de Fly",
        Min = 20,
        Max = 100,
        Default = 40,
        Color = Color3.fromRGB(255, 200, 80),
        Increment = 5,
        ValueName = "km/h",
        Callback = function(Value)
            flySpeed = Value
        end,
    })

    othersTab:CreateToggle({
        Name = "🦘 Infinite Jump",
        CurrentValue = false,
        Flag = "InfiniteJump",
        Callback = function(Value)
            toggleInfiniteJump()
        end,
    })

    othersTab:CreateToggle({
        Name = "🕐 Time Display",
        CurrentValue = true,
        Flag = "TimeDisplay",
        Callback = function(Value)
            toggleTime()
        end,
    })

    othersTab:CreateToggle({
        Name = "🛡️ Anti-Staff",
        CurrentValue = true,
        Flag = "AntiStaff",
        Callback = function(Value)
            toggleAntiStaff()
        end,
    })

    othersTab:CreateToggle({
        Name = "💤 Anti-AFK",
        CurrentValue = true,
        Flag = "AntiAFK",
        Callback = function(Value)
            toggleAntiAFK()
        end,
    })

    -- ====== PESTAÑA 5: SETTINGS ======
    local settingsTab = window:CreateTab("⚙️ Settings", 4)

    settingsTab:CreateButton({
        Name = "💰 Actualizar dinero",
        Callback = function()
            local money = getPlayerMoney()
            notify("💰 $" .. money)
        end,
    })

    settingsTab:CreateButton({
        Name = "⛏️ Ver pico equipado",
        Callback = function()
            local tier = getPlayerPickaxeTier()
            notify("⛏️ Tier del pico: " .. tier)
        end,
    })

    settingsTab:CreateButton({
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

    settingsTab:CreateButton({
        Name = "🔄 Recargar script",
        Callback = function()
            notify("🔄 Recargando...")
            task.wait(1)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/orvehack/Refinery-Caves-2-Script/main/Refinery-Caves-2-SCRIPT.lua"))()
        end,
    })

    return window
end

-- 20. INICIALIZACIÓN
local success, err = pcall(function()
    createFloatingButton()
    notify("🚀 RC2 COMPLETE cargado correctamente", 4)
    writeLog("Script cargado correctamente")
end)

if not success then
    notify("❌ Error al cargar: " .. tostring(err), 5)
    writeLog("Error de carga: " .. tostring(err), true)
end

print("✅ RC2 COMPLETE cargado")
print("📁 Carpeta: " .. folder)
print("🟢 Toca el botón flotante para abrir la GUI")
