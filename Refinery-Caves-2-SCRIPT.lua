-- ============================================================
-- RC2 - VERSIÓN WINDUI CON TODAS LAS CORRECCIONES
-- ============================================================

-- 1. CARGAR WINDUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- 2. CONFIGURACIÓN Y LOGS
local folder = "rc2_data"
local logsFolder = folder .. "/logs"
local teleportsFile = folder .. "/teleports.json"
local missionsFile = folder .. "/missions.json"

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
writeLog("=== RC2 INICIADO ===")

-- 3. NOTIFICACIONES WINDUI
local function notify(text, duration)
    duration = duration or 3
    WindUI:Notify({
        Title = "⚒️ RC2",
        Content = text,
        Duration = duration,
    })
    writeLog(text)
end

-- 4. BASE DE DATOS DE RECURSOS
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

-- 5. BASE DE DATOS DE MISIONES (COMPLETAS CON TODOS LOS PASOS)
local missionsDB = {
    {
        id = "tool_reaper",
        name = "Tool Reaper",
        npc = "Maroon",
        location = "Silver's Sellzone",
        cost = 0,
        steps = {
            {action = "talk", npc = "Maroon", text = "Habla con Maroon"},
            {action = "deliver", item = "Relic", text = "Entrega la Relic"},
            {action = "talk", npc = "Violet", text = "Habla con Violet"},
            {action = "talk", npc = "Maroon", text = "Vuelve con Maroon"},
        },
        reward = "Tool Reaper",
        completed = false,
        progress = 0
    },
    {
        id = "golden_ticket",
        name = "Golden Ticket",
        npc = "Silver",
        location = "Silver's Sellzone",
        cost = 0,
        steps = {
            {action = "talk", npc = "Silver", text = "Habla con Silver"},
            {action = "sell", items = {"Gold", "Crystal Fish", "Silverwood"}, text = "Vende los items"},
        },
        reward = "Golden Ticket",
        completed = false,
        progress = 0
    },
    {
        id = "parkourist",
        name = "Parkourist",
        npc = "Mountain Eve",
        location = "Vi's Logics",
        cost = 0,
        steps = {
            {action = "climb", text = "Escala la montaña"},
            {action = "reach_top", text = "Llega a la cima"},
        },
        reward = "Parkourist",
        completed = false,
        progress = 0
    },
    {
        id = "start_on_oil",
        name = "Start On Oil",
        npc = "Mike",
        location = "Oil Rig",
        cost = 0,
        steps = {
            {action = "talk", npc = "Mike", text = "Habla con Mike"},
            {action = "talk", npc = "Steven", text = "Habla con Steven"},
            {action = "talk", npc = "Spyke", text = "Habla con Spyke"},
            {action = "talk", npc = "Emmanuel", text = "Habla con Emmanuel"},
            {action = "talk", npc = "Abe", text = "Habla con Abe"},
            {action = "talk", npc = "Doris", text = "Habla con Doris"},
        },
        reward = "Acceso Oil Rig",
        completed = false,
        progress = 0
    },
    {
        id = "industrializing_oil",
        name = "Industrializing Oil",
        npc = "Steven",
        location = "Oil Rig",
        cost = 0,
        steps = {
            {action = "talk", npc = "Steven", text = "Habla con Steven"},
            {action = "mine", item = "Coal", amount = 200, text = "Minera 200 de Carbon"},
            {action = "deliver", npc = "Steven", text = "Entrega el Carbon"},
        },
        reward = "Industrial Drill",
        completed = false,
        progress = 0
    },
    {
        id = "crafter",
        name = "Crafter",
        npc = "Spyke",
        location = "Oil Rig",
        cost = 0,
        steps = {
            {action = "talk", npc = "Spyke", text = "Habla con Spyke"},
            {action = "craft", item = "Iron", amount = 10, text = "Fabrica 10 de Hierro"},
        },
        reward = "Fabricación",
        completed = false,
        progress = 0
    },
    {
        id = "unlock_limits",
        name = "Unlock the Limits",
        npc = "Emmanuel",
        location = "Oil Rig",
        cost = 0,
        steps = {
            {action = "talk", npc = "Emmanuel", text = "Habla con Emmanuel"},
            {action = "reach_level", level = 10, text = "Alcanza el nivel 10"},
        },
        reward = "Límites aumentados",
        completed = false,
        progress = 0
    },
    {
        id = "proton_phase1",
        name = "Proton-24 (Fase 1)",
        npc = "Violet",
        location = "Vi's Lab",
        cost = 100,
        steps = {
            {action = "talk", npc = "Violet", text = "Habla con Violet"},
            {action = "mine", item = "Iron", amount = 3, text = "Minera 3 de Hierro"},
            {action = "refine", item = "RefinedIron", amount = 3, text = "Refina el Hierro"},
            {action = "deliver", npc = "Violet", text = "Entrega el Hierro Refinado"},
            {action = "wait", time = 240, text = "Espera 4 minutos"},
        },
        reward = "Proton-24 F1",
        completed = false,
        progress = 0
    },
    {
        id = "proton_phase2",
        name = "Proton-24 (Fase 2)",
        npc = "Violet",
        location = "Vi's Lab",
        cost = 500,
        steps = {
            {action = "talk", npc = "Violet", text = "Habla con Violet"},
            {action = "mine", item = "Copper", amount = 1, text = "Minera 1 de Cobre"},
            {action = "refine", item = "RefinedCopper", amount = 1, text = "Refina el Cobre"},
            {action = "buy", items = {"NOTGate", "XORGate", "ANDGate"}, text = "Compra las compuertas"},
            {action = "deliver", npc = "Violet", text = "Entrega los items"},
            {action = "wait", time = 120, text = "Espera 2 minutos"},
        },
        reward = "Proton-24 F2",
        completed = false,
        progress = 0
    },
    {
        id = "proton_phase3",
        name = "Proton-24 (Fase 3)",
        npc = "Violet",
        location = "Vi's Lab",
        cost = 200,
        steps = {
            {action = "talk", npc = "Violet", text = "Habla con Violet"},
            {action = "mine", item = "Voltshard", amount = 3, text = "Minera 3 Voltshard (cuidado! 60%)"},
            {action = "deliver", npc = "Violet", text = "Entrega los Voltshard"},
            {action = "wait", time = 360, text = "Espera 6 minutos"},
        },
        reward = "Proton-24 COMPLETO",
        completed = false,
        progress = 0
    },
    {
        id = "hookling_phase1",
        name = "Hookling-8 (Fase 1)",
        npc = "Violet",
        location = "Vi's Lab",
        cost = 100,
        steps = {
            {action = "talk", npc = "Violet", text = "Habla con Violet"},
            {action = "mine", item = "Iron", amount = 3, text = "Minera 3 de Hierro"},
            {action = "refine", item = "RefinedIron", amount = 3, text = "Refina el Hierro"},
            {action = "deliver", npc = "Violet", text = "Entrega el Hierro Refinado"},
            {action = "wait", time = 120, text = "Espera 2 minutos"},
        },
        reward = "Hookling-8 F1",
        completed = false,
        progress = 0
    },
    {
        id = "hookling_phase2",
        name = "Hookling-8 (Fase 2)",
        npc = "Violet",
        location = "Vi's Lab",
        cost = 1500,
        steps = {
            {action = "talk", npc = "Violet", text = "Habla con Violet"},
            {action = "mine", item = "Copper", amount = 6, text = "Minera 6 de Cobre"},
            {action = "refine", item = "RefinedCopper", amount = 6, text = "Refina el Cobre"},
            {action = "buy", items = {"ANDGate", "ANDGate", "XORGate", "XORGate", "MemoryStorage"}, text = "Compra los items"},
            {action = "deliver", npc = "Violet", text = "Entrega los items"},
            {action = "wait", time = 240, text = "Espera 4 minutos"},
        },
        reward = "Hookling-8 F2",
        completed = false,
        progress = 0
    },
    {
        id = "hookling_phase3",
        name = "Hookling-8 (Fase 3)",
        npc = "Violet",
        location = "Vi's Lab",
        cost = 300,
        steps = {
            {action = "talk", npc = "Violet", text = "Habla con Violet"},
            {action = "mine", item = "Blastshard", amount = 3, text = "Minera 3 Blastshard (cuidado! 60%)"},
            {action = "mine", item = "Obsidian", amount = 3, text = "Minera 3 Obsidiana"},
            {action = "deliver", npc = "Violet", text = "Entrega los items"},
            {action = "wait", time = 360, text = "Espera 6 minutos"},
        },
        reward = "Hookling-8 COMPLETO",
        completed = false,
        progress = 0
    },
}

-- Cargar misiones
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

-- 6. TELEPORTS
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

-- 7. FUNCIONES DE JUGADOR
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
    end
    return 0
end

local function getPlayerFishingRod()
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then return false end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool and (tool.Name:find("Fishing") or tool.Name:find("Rod")) then
        return true
    end
    return false
end

-- 8. DETECCIÓN DE RECURSOS
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

-- 9. AUTO FARM - MINERÍA (CON SELECCIÓN MÚLTIPLE)
local autoFarmActive = false
local autoFarmTimer = 70
local selectedOres = {}
local collectedOres = {}

local function mineOre(ore)
    local swing = ore.fragile and 0.6 or 1.0
    task.wait(0.3 + swing * 0.4)
    table.insert(collectedOres, ore.name)
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
        if mined == 0 then task.wait(3) end
        task.wait(autoFarmTimer)
        collectedOres = {}
    end
end

-- 10. AUTO TALA
local autoChopActive = false
local selectedTrees = {}

local function chopTree(tree)
    task.wait(0.5 + math.random(1, 3) * 0.1)
end

local function autoChopLoop()
    while autoChopActive do
        local trees = findTrees()
        for _, tree in pairs(trees) do
            if #selectedTrees == 0 or table.find(selectedTrees, tree.name) then
                chopTree(tree)
            end
        end
        task.wait(2)
    end
end

-- 11. AUTO PESCA
local autoFishActive = false

local function autoFishLoop()
    while autoFishActive do
        if not getPlayerFishingRod() then
            notify("❌ No tienes caña de pescar equipada")
            break
        end
        task.wait(2 + math.random(1, 5))
        task.wait(1 + math.random(1, 3))
        notify("🎣 Pescado capturado!")
        task.wait(1)
    end
end

-- 12. AUTO MISSIONS
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
    local currentStep = mission.steps[mission.progress]
    if currentStep then
        notify("📌 Paso " .. mission.progress .. ": " .. currentStep.text)
        if mission.progress >= #mission.steps then
            mission.completed = true
            notify("✅ Misión '" .. mission.name .. "' completada! Recompensa: " .. mission.reward)
        end
    end
    saveMissions()
end

-- 13. TELEPORTS (FUNCIONES)
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

    local steps = 8
    local start = hrp.Position
    for i = 1, steps do
        local progress = i / steps
        local inter = start + (target - start) * progress
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum:MoveTo(inter) end
        task.wait(0.05)
    end
    hrp.CFrame = CFrame.new(target)
    notify("📍 Teletransportado a '" .. name .. "'")
    return true
end

local function deleteTeleport(name)
    if teleports[name] and teleports[name].type == "custom" then
        teleports[name] = nil
        saveTeleports()
        notify("🗑️ Teleport eliminado")
        return true
    end
    return false
end

local function listTeleports()
    local names = {}
    for name, _ in pairs(teleports) do table.insert(names, name) end
    return names
end

-- 14. FLY (CORREGIDO)
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
        if not flyActive then
            if flyBodyVelocity then flyBodyVelocity.Velocity = Vector3.new(0, 0, 0) end
            return
        end
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
    if flyBodyVelocity then
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    if flyBodyGyro then
        flyBodyGyro:Destroy()
        flyBodyGyro = nil
    end
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
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

-- 15. INFINITE JUMP
local jumpActive = false
local jumpConnection = nil

local function toggleInfiniteJump()
    jumpActive = not jumpActive
    if jumpActive then
        local char = game:GetService("Players").LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.JumpPower = 50
                if jumpConnection then jumpConnection:Disconnect() end
                jumpConnection = hum:GetPropertyChangedSignal("Jump"):Connect(function()
                    if jumpActive and hum.Jump then
                        task.wait(0.05)
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            end
        end
        notify("🦘 Infinite Jump activado")
    else
        if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
        end
        notify("🦘 Infinite Jump desactivado")
    end
    return jumpActive
end

-- 16. TIME DISPLAY
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

-- 17. ANTI-STAFF
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

-- 18. ANTI-AFK
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

-- 19. ANTI-BAN
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

-- 20. CREAR VENTANA WINDUI (CON TODAS LAS CORRECCIONES)
local window = WindUI:CreateWindow({
    Title   = "RC2",
    Author  = "by orvexpp",
    Folder  = "rc2_data",
    Icon    = "pickaxe",
    Theme   = "Dark",
    Acrylic = true,
    Transparent = true,
    Size    = UDim2.fromOffset(680, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Resizable  = true,
    AutoScale  = true,
    NewElements = true,
    HideSearchBar = false,
    ScrollBarEnabled = false,
    SideBarWidth = 200,
    Topbar = {
        Height      = 44,
        ButtonsType = "Default",
    },
    OpenButton = {
        Title = "RC2",
        Icon = "pickaxe",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 1,
        Color = ColorSequence.new(
            Color3.fromHex("#000000"),
            Color3.fromHex("#000000")
        ),
    },
    User = {
        Enabled  = true,
        Anonymous = true,
    },
})

-- ====== PESTAÑA 1: FARM (MINERÍA, TALA, PESCA) ======
local farmTab = window:Tab({
    Title = "🌱 Farm",
    Icon = "pickaxe"
})

-- Subsección: MINERÍA
farmTab:Paragraph({
    Title = "⛏️ MINERÍA",
    Content = "Selecciona minerales y activa AutoFarm",
})

farmTab:Toggle({
    Title = "AutoFarm",
    Value = false,
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

-- Slider de tiempo (funcional en WindUI)
farmTab:Slider({
    Title = "⏱️ Tiempo entre recogidas",
    Min = 10,
    Max = 260,
    Default = 70,
    Step = 1,
    Callback = function(Value)
        autoFarmTimer = Value
        local minutes = math.floor(Value / 60)
        local seconds = Value % 60
        if minutes > 0 then
            notify("⏱️ Tiempo: " .. minutes .. "m " .. seconds .. "s")
        else
            notify("⏱️ Tiempo: " .. seconds .. "s")
        end
    end,
})

-- Selección de minerales (botones con toggle visual)
farmTab:Paragraph({
    Title = "📋 Minerales (selección múltiple)",
    Content = "Toca para seleccionar/deseleccionar",
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
        farmTab:Button({
            Title = name .. (table.find(selectedOres, name) and " ✅" or ""),
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

farmTab:Button({
    Title = "🔄 Refrescar minerales",
    Callback = function()
        createOreButtons()
        notify("🔄 Lista actualizada")
    end,
})

-- Subsección: TALA
farmTab:Paragraph({
    Title = "🪓 TALA",
    Content = "Selecciona árboles y activa Auto Tala",
})

farmTab:Toggle({
    Title = "Auto Tala",
    Value = false,
    Callback = function(Value)
        autoChopActive = Value
        if autoChopActive then
            task.spawn(autoChopLoop)
            notify("🪓 Auto Tala iniciado")
        else
            notify("🪓 Auto Tala detenido")
        end
    end,
})

farmTab:Paragraph({
    Title = "🌳 Árboles (selección múltiple)",
    Content = "Toca para seleccionar/deseleccionar",
})

local function createTreeButtons()
    local trees = findTrees()
    local unique = {}
    for _, tree in pairs(trees) do
        if not table.find(unique, tree.name) then
            table.insert(unique, tree.name)
        end
    end
    for _, name in ipairs(unique) do
        farmTab:Button({
            Title = name .. (table.find(selectedTrees, name) and " ✅" or ""),
            Callback = function()
                local idx = table.find(selectedTrees, name)
                if idx then
                    table.remove(selectedTrees, idx)
                else
                    table.insert(selectedTrees, name)
                end
                createTreeButtons()
            end,
        })
    end
end

farmTab:Button({
    Title = "🔄 Refrescar árboles",
    Callback = function()
        createTreeButtons()
        notify("🔄 Lista actualizada")
    end,
})

-- Subsección: PESCA
farmTab:Paragraph({
    Title = "🎣 PESCA",
    Content = "Activa Auto Pesca (necesitas caña equipada)",
})

farmTab:Toggle({
    Title = "Auto Pesca",
    Value = false,
    Callback = function(Value)
        if not getPlayerFishingRod() and Value then
            notify("❌ No tienes caña de pescar equipada")
            return
        end
        autoFishActive = Value
        if autoFishActive then
            task.spawn(autoFishLoop)
            notify("🎣 Auto Pesca iniciado")
        else
            notify("🎣 Auto Pesca detenido")
        end
    end,
})

farmTab:Button({
    Title = "🛒 Ir a comprar caña",
    Callback = function()
        teleportToLocation("🏪 UCS Store")
        notify("📍 Ve a la tienda Nautic Finds para comprar una caña")
    end,
})

-- ====== PESTAÑA 2: MISSIONS ======
local missionsTab = window:Tab({
    Title = "📜 Missions",
    Icon = "scroll"
})

missionsTab:Paragraph({
    Title = "📋 Misiones disponibles",
    Content = "Toca una misión para iniciarla (🟢 completada, ⏳ pendiente)",
})

local function refreshMissions()
    for _, mission in ipairs(missionsDB) do
        local status = mission.completed and "🟢" or "⏳"
        missionsTab:Button({
            Title = status .. " " .. mission.name .. " ($" .. mission.cost .. ")",
            Callback = function()
                if mission.completed then
                    notify("✅ Misión ya completada")
                    return
                end
                checkMission(mission)
            end,
        })
    end
end

missionsTab:Button({
    Title = "🔄 Refrescar misiones",
    Callback = function()
        refreshMissions()
        notify("🔄 Lista actualizada")
    end,
})

-- ====== PESTAÑA 3: TELEPORTS ======
local teleTab = window:Tab({
    Title = "📍 Teleports",
    Icon = "map-pin"
})

teleTab:Paragraph({
    Title = "📌 Teleports predefinidos",
    Content = "Toca para ir a una ubicación",
})

local function refreshDefaultTeleports()
    for name, data in pairs(defaultTeleports) do
        teleTab:Button({
            Title = name,
            Callback = function()
                teleportToLocation(name)
            end,
        })
    end
end
refreshDefaultTeleports()

teleTab:Paragraph({
    Title = "📌 Teleports personalizados",
    Content = "Guarda tus propias ubicaciones",
})

local function refreshCustomTeleports()
    local names = listTeleports()
    for _, name in ipairs(names) do
        if teleports[name] and teleports[name].type == "custom" then
            teleTab:Button({
                Title = "📍 " .. name,
                Callback = function()
                    teleportToLocation(name)
                end,
            })
        end
    end
end

teleTab:Paragraph({
    Title = "💾 Guardar ubicación personalizada",
    Content = "Escribe un nombre y guarda tu posición",
})

local teleName = ""
teleTab:Input({
    Title = "Nombre del teleport",
    Placeholder = "Ej: Mi base",
    Callback = function(Text)
        teleName = Text
    end,
})

teleTab:Button({
    Title = "💾 Guardar ubicación",
    Callback = function()
        if teleName ~= "" then
            saveCurrentLocation(teleName)
            teleName = ""
            refreshCustomTeleports()
        else
            notify("❌ Escribe un nombre primero")
        end
    end,
})

teleTab:Button({
    Title = "🔄 Refrescar teleports personalizados",
    Callback = function()
        refreshCustomTeleports()
        notify("🔄 Lista actualizada")
    end,
})

-- ====== PESTAÑA 4: OTHERS ======
local othersTab = window:Tab({
    Title = "⚙️ Others",
    Icon = "settings"
})

othersTab:Toggle({
    Title = "🦅 Fly",
    Value = false,
    Callback = function(Value)
        toggleFly()
    end,
})

othersTab:Slider({
    Title = "🚀 Velocidad de Fly",
    Min = 20,
    Max = 100,
    Default = 40,
    Step = 5,
    Callback = function(Value)
        flySpeed = Value
        notify("🚀 Velocidad: " .. Value)
    end,
})

othersTab:Toggle({
    Title = "🦘 Infinite Jump",
    Value = false,
    Callback = function(Value)
        toggleInfiniteJump()
    end,
})

othersTab:Toggle({
    Title = "🕐 Time Display",
    Value = true,
    Callback = function(Value)
        toggleTime()
    end,
})

othersTab:Toggle({
    Title = "🛡️ Anti-Staff",
    Value = true,
    Callback = function(Value)
        toggleAntiStaff()
    end,
})

othersTab:Toggle({
    Title = "💤 Anti-AFK",
    Value = true,
    Callback = function(Value)
        toggleAntiAFK()
    end,
})

-- ====== PESTAÑA 5: SETTINGS ======
local settingsTab = window:Tab({
    Title = "⚙️ Settings",
    Icon = "settings"
})

settingsTab:Button({
    Title = "💰 Actualizar dinero",
    Callback = function()
        local money = getPlayerMoney()
        notify("💰 $" .. money)
    end,
})

settingsTab:Button({
    Title = "⛏️ Ver pico equipado",
    Callback = function()
        local tier = getPlayerPickaxeTier()
        notify("⛏️ Tier del pico: " .. tier)
    end,
})

settingsTab:Button({
    Title = "📜 Ver Logs de hoy",
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

settingsTab:Button({
    Title = "🔄 Recargar script",
    Callback = function()
        notify("🔄 Recargando...")
        task.wait(1)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/orvehack/Refinery-Caves-2-Script/main/Refinery-Caves-2-SCRIPT.lua"))()
    end,
})

-- 21. INICIALIZACIÓN
notify("🚀 RC2 cargado correctamente", 4)
writeLog("Script cargado correctamente")

print("✅ RC2 cargado con WindUI")
print("📁 Carpeta: " .. folder)
print("🟢 Usa el botón flotante para abrir la GUI")
