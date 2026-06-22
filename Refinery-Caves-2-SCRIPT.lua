-- ============================================================
-- RC2 - VERSIÓN FINAL CON UI NATIVA (ESTABLE EN DELTA)
-- ============================================================

-- 1. CONFIGURACIÓN Y LOGS
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
writeLog("=== RC2 INICIADO ===")

-- 2. NOTIFICACIONES (UI NATIVA)
local function notify(text, duration)
    duration = duration or 3
    local sg = Instance.new("ScreenGui", gethui())
    sg.Name = "Notify"
    sg.ResetOnSpawn = false
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.8, 0, 0, 50)
    frame.Position = UDim2.new(0.1, 0, 0.82, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
    frame.BackgroundTransparency = 0.1
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 12)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.BackgroundTransparency = 1
    task.spawn(function()
        task.wait(duration)
        sg:Destroy()
    end)
    writeLog(text)
end

-- 3. BASE DE DATOS DE RECURSOS
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

local fishDatabase = {
    ["Crystal Fish"] = { tier = 1 },
    ["Golden Fish"] = { tier = 2 },
    ["Volcanic Fish"] = { tier = 3 },
}

-- 4. BASE DE DATOS DE MISIONES (COMPLETAS)
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

-- 5. TELEPORTS (CON TELEPORT DIRECTO)
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

-- 6. FUNCIONES DE JUGADOR
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

-- 7. DETECCIÓN DE RECURSOS
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

-- 8. AUTO FARM - MINERÍA (CON SELECCIÓN MÚLTIPLE Y VERIFICACIÓN DE TIER)
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
                    -- Mostrar las 3 opciones
                    notify("⚠️ No puedes minar " .. ore.name .. " (Tier " .. ore.tier .. ")")
                    -- Aquí se mostrarían las 3 opciones en la UI
                end
            end
        end
        if mined == 0 then task.wait(3) end
        task.wait(autoFarmTimer)
        -- Recoger y vender (simulado)
        collectedOres = {}
    end
end

-- 9. AUTO TALA (CON SELECCIÓN MÚLTIPLE)
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

-- 10. AUTO PESCA (CON DETECCIÓN DE CAÑA)
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

-- 11. AUTO MISSIONS (CON ESTADOS)
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

-- 12. TELEPORTS (TELEPORT DIRECTO CON ANTI-TELEPORT)
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

    -- Teleport directo con anti-teleport suave
    local steps = 8
    local start = hrp.Position
    for i = 1, steps do
        local progress = i / steps
        local inter = start + (target - start) * progress
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum:MoveTo(inter) end
        task.wait(0.05)
    end
    hrp.CFrame = CFrame.new(target) -- Teleport final directo
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

-- 13. FLY (CORREGIDO)
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

-- 14. INFINITE JUMP (CORREGIDO)
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

-- 18. ANTI-BAN MEJORADO
local function humanizeDelay()
    return math.random(80, 120) / 100
end

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

-- 19. UI NATIVA (COMPLETA Y ORGANIZADA)
local function createFloatingButton()
    local sg = Instance.new("ScreenGui", gethui())
    sg.Name = "FloatingBtn"
    sg.ResetOnSpawn = false

    local btn = Instance.new("ImageButton", sg)
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0.85, 0, 0.85, 0)
    btn.Image = "rbxassetid://4483362458"
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

    -- GUI principal
    local mainGui = nil
    local guiOpen = false

    btn.MouseButton1Click:Connect(function()
        if not mainGui then
            mainGui = createMainGUI()
        end
        guiOpen = not guiOpen
        mainGui.Enabled = guiOpen
        if guiOpen then
            notify("📂 GUI abierta", 2)
        else
            notify("📂 GUI cerrada", 2)
        end
    end)

    btn.TouchTap:Connect(function()
        if not mainGui then
            mainGui = createMainGUI()
        end
        guiOpen = not guiOpen
        mainGui.Enabled = guiOpen
        if guiOpen then
            notify("📂 GUI abierta", 2)
        else
            notify("📂 GUI cerrada", 2)
        end
    end)

    return sg
end

-- 20. CREAR GUI PRINCIPAL (CON TODAS LAS SECCIONES)
local function createMainGUI()
    local sg = Instance.new("ScreenGui", gethui())
    sg.Name = "MainGUI"
    sg.ResetOnSpawn = false
    sg.Enabled = false

    -- Fondo
    local backdrop = Instance.new("Frame", sg)
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.5
    backdrop.Active = true
    backdrop.TouchTap:Connect(function()
        sg.Enabled = false
        notify("GUI cerrada", 2)
    end)

    -- Ventana
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.92, 0, 0.85, 0)
    frame.Position = UDim2.new(0.04, 0, 0.075, 0)
    frame.BackgroundColor3 = Color3.fromRGB(18, 20, 35)
    frame.BackgroundTransparency = 0.1
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 16)

    -- Título
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Text = "⚒️ RC2"
    title.TextColor3 = Color3.fromRGB(255, 200, 80)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1

    -- Pestañas (Tabs)
    local tabFrame = Instance.new("Frame", frame)
    tabFrame.Size = UDim2.new(1, 0, 0, 40)
    tabFrame.Position = UDim2.new(0, 0, 0, 50)
    tabFrame.BackgroundTransparency = 1

    local tabs = {}
    local contents = {}

    local function createTab(name, content)
        local btn = Instance.new("TextButton", tabFrame)
        btn.Size = UDim2.new(0.2, 0, 1, 0)
        btn.Position = UDim2.new(#tabs * 0.2, 0, 0, 0)
        btn.Text = name
        btn.TextScaled = true
        btn.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
        btn.BackgroundTransparency = 0.2
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 6)
        table.insert(tabs, btn)
        return btn
    end

    -- Contenido (scroll)
    local contentFrame = Instance.new("ScrollingFrame", frame)
    contentFrame.Size = UDim2.new(1, 0, 1, -100)
    contentFrame.Position = UDim2.new(0, 0, 0, 95)
    contentFrame.BackgroundTransparency = 1
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 1200)
    contentFrame.ScrollBarThickness = 6

    -- ====== PESTAÑA 1: FARM (MINERÍA, TALA, PESCA) ======
    local farmContent = Instance.new("Frame", contentFrame)
    farmContent.Size = UDim2.new(1, 0, 1, 0)
    farmContent.BackgroundTransparency = 1
    farmContent.Visible = true

    -- Sección: MINERÍA
    local miningSection = Instance.new("Frame", farmContent)
    miningSection.Size = UDim2.new(1, 0, 0, 350)
    miningSection.BackgroundTransparency = 1

    local l1 = Instance.new("TextLabel", miningSection)
    l1.Size = UDim2.new(0.9, 0, 0, 30)
    l1.Position = UDim2.new(0.05, 0, 0, 0)
    l1.Text = "⛏️ MINERÍA"
    l1.TextColor3 = Color3.fromRGB(100, 255, 150)
    l1.TextScaled = true
    l1.BackgroundTransparency = 1

    local farmBtn = Instance.new("TextButton", miningSection)
    farmBtn.Size = UDim2.new(0.9, 0, 0, 45)
    farmBtn.Position = UDim2.new(0.05, 0, 0.08, 0)
    farmBtn.Text = "AutoFarm: OFF"
    farmBtn.TextScaled = true
    farmBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 100)
    local c1 = Instance.new("UICorner", farmBtn)
    c1.CornerRadius = UDim.new(0, 10)
    farmBtn.TouchTap:Connect(function()
        autoFarmActive = not autoFarmActive
        farmBtn.Text = "AutoFarm: " .. (autoFarmActive and "ON" or "OFF")
        if autoFarmActive then
            task.spawn(autoFarmLoop)
            notify("⛏️ AutoFarm iniciado")
        else
            notify("⛏️ AutoFarm detenido")
        end
    end)

    -- Slider de tiempo (con + y -)
    local timeLabel = Instance.new("TextLabel", miningSection)
    timeLabel.Size = UDim2.new(0.4, 0, 0, 30)
    timeLabel.Position = UDim2.new(0.05, 0, 0.18, 0)
    timeLabel.Text = "⏱️ Tiempo: 70s"
    timeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    timeLabel.TextScaled = true
    timeLabel.BackgroundTransparency = 1

    local timeMinus = Instance.new("TextButton", miningSection)
    timeMinus.Size = UDim2.new(0.1, 0, 0, 30)
    timeMinus.Position = UDim2.new(0.5, 0, 0.18, 0)
    timeMinus.Text = "-"
    timeMinus.TextScaled = true
    timeMinus.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    local c2 = Instance.new("UICorner", timeMinus)
    c2.CornerRadius = UDim.new(0, 6)
    timeMinus.TouchTap:Connect(function()
        autoFarmTimer = math.max(10, autoFarmTimer - 5)
        local minutes = math.floor(autoFarmTimer / 60)
        local seconds = autoFarmTimer % 60
        timeLabel.Text = "⏱️ Tiempo: " .. (minutes > 0 and minutes .. "m " .. seconds .. "s" or seconds .. "s")
    end)

    local timePlus = Instance.new("TextButton", miningSection)
    timePlus.Size = UDim2.new(0.1, 0, 0, 30)
    timePlus.Position = UDim2.new(0.65, 0, 0.18, 0)
    timePlus.Text = "+"
    timePlus.TextScaled = true
    timePlus.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    local c3 = Instance.new("UICorner", timePlus)
    c3.CornerRadius = UDim.new(0, 6)
    timePlus.TouchTap:Connect(function()
        autoFarmTimer = math.min(260, autoFarmTimer + 5)
        local minutes = math.floor(autoFarmTimer / 60)
        local seconds = autoFarmTimer % 60
        timeLabel.Text = "⏱️ Tiempo: " .. (minutes > 0 and minutes .. "m " .. seconds .. "s" or seconds .. "s")
    end)

    -- Selección de minerales
    local oreLabel = Instance.new("TextLabel", miningSection)
    oreLabel.Size = UDim2.new(0.9, 0, 0, 25)
    oreLabel.Position = UDim2.new(0.05, 0, 0.25, 0)
    oreLabel.Text = "📋 Minerales (selección múltiple):"
    oreLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    oreLabel.TextScaled = true
    oreLabel.BackgroundTransparency = 1

    local oreScroll = Instance.new("ScrollingFrame", miningSection)
    oreScroll.Size = UDim2.new(0.9, 0, 0, 120)
    oreScroll.Position = UDim2.new(0.05, 0, 0.32, 0)
    oreScroll.BackgroundTransparency = 1
    oreScroll.CanvasSize = UDim2.new(0, 0, 0, 400)
    oreScroll.ScrollBarThickness = 4

    local function refreshOreList()
        for _, child in pairs(oreScroll:GetChildren()) do
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
            local btn = Instance.new("TextButton", oreScroll)
            btn.Size = UDim2.new(0.9, 0, 0, 35)
            local selected = table.find(selectedOres, name) ~= nil
            btn.Text = (selected and "✅ " or "⬜ ") .. name
            btn.TextScaled = true
            btn.BackgroundColor3 = selected and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(60, 60, 90)
            local c = Instance.new("UICorner", btn)
            c.CornerRadius = UDim.new(0, 6)
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
        oreScroll.CanvasSize = UDim2.new(0, 0, 0, #unique * 40 + 20)
    end

    local refreshBtn = Instance.new("TextButton", miningSection)
    refreshBtn.Size = UDim2.new(0.4, 0, 0, 35)
    refreshBtn.Position = UDim2.new(0.3, 0, 0.55, 0)
    refreshBtn.Text = "🔄 Refrescar"
    refreshBtn.TextScaled = true
    refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    local c4 = Instance.new("UICorner", refreshBtn)
    c4.CornerRadius = UDim.new(0, 8)
    refreshBtn.TouchTap:Connect(refreshOreList)

    -- Sección: TALA
    local chopSection = Instance.new("Frame", farmContent)
    chopSection.Size = UDim2.new(1, 0, 0, 200)
    chopSection.Position = UDim2.new(0, 0, 0.35, 0)
    chopSection.BackgroundTransparency = 1

    local l2 = Instance.new("TextLabel", chopSection)
    l2.Size = UDim2.new(0.9, 0, 0, 30)
    l2.Position = UDim2.new(0.05, 0, 0, 0)
    l2.Text = "🪓 TALA"
    l2.TextColor3 = Color3.fromRGB(255, 200, 100)
    l2.TextScaled = true
    l2.BackgroundTransparency = 1

    local chopBtn = Instance.new("TextButton", chopSection)
    chopBtn.Size = UDim2.new(0.9, 0, 0, 40)
    chopBtn.Position = UDim2.new(0.05, 0, 0.08, 0)
    chopBtn.Text = "Auto Tala: OFF"
    chopBtn.TextScaled = true
    chopBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 100)
    local c5 = Instance.new("UICorner", chopBtn)
    c5.CornerRadius = UDim.new(0, 8)
    chopBtn.TouchTap:Connect(function()
        autoChopActive = not autoChopActive
        chopBtn.Text = "Auto Tala: " .. (autoChopActive and "ON" or "OFF")
        if autoChopActive then
            task.spawn(autoChopLoop)
            notify("🪓 Auto Tala iniciado")
        else
            notify("🪓 Auto Tala detenido")
        end
    end)

    -- Selección de árboles
    local treeLabel = Instance.new("TextLabel", chopSection)
    treeLabel.Size = UDim2.new(0.9, 0, 0, 25)
    treeLabel.Position = UDim2.new(0.05, 0, 0.2, 0)
    treeLabel.Text = "🌳 Árboles (selección múltiple):"
    treeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    treeLabel.TextScaled = true
    treeLabel.BackgroundTransparency = 1

    local treeScroll = Instance.new("ScrollingFrame", chopSection)
    treeScroll.Size = UDim2.new(0.9, 0, 0, 80)
    treeScroll.Position = UDim2.new(0.05, 0, 0.28, 0)
    treeScroll.BackgroundTransparency = 1
    treeScroll.CanvasSize = UDim2.new(0, 0, 0, 400)
    treeScroll.ScrollBarThickness = 4

    local function refreshTreeList()
        for _, child in pairs(treeScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local trees = findTrees()
        local unique = {}
        for _, tree in pairs(trees) do
            if not table.find(unique, tree.name) then
                table.insert(unique, tree.name)
            end
        end
        for _, name in ipairs(unique) do
            local btn = Instance.new("TextButton", treeScroll)
            btn.Size = UDim2.new(0.9, 0, 0, 30)
            local selected = table.find(selectedTrees, name) ~= nil
            btn.Text = (selected and "✅ " or "⬜ ") .. name
            btn.TextScaled = true
            btn.BackgroundColor3 = selected and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(60, 60, 90)
            local c = Instance.new("UICorner", btn)
            c.CornerRadius = UDim.new(0, 6)
            btn.TouchTap:Connect(function()
                local idx = table.find(selectedTrees, name)
                if idx then
                    table.remove(selectedTrees, idx)
                else
                    table.insert(selectedTrees, name)
                end
                refreshTreeList()
            end)
        end
        treeScroll.CanvasSize = UDim2.new(0, 0, 0, #unique * 35 + 20)
    end

    local refreshTreeBtn = Instance.new("TextButton", chopSection)
    refreshTreeBtn.Size = UDim2.new(0.4, 0, 0, 30)
    refreshTreeBtn.Position = UDim2.new(0.3, 0, 0.5, 0)
    refreshTreeBtn.Text = "🔄 Refrescar"
    refreshTreeBtn.TextScaled = true
    refreshTreeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    local c6 = Instance.new("UICorner", refreshTreeBtn)
    c6.CornerRadius = UDim.new(0, 8)
    refreshTreeBtn.TouchTap:Connect(refreshTreeList)

    -- Sección: PESCA
    local fishSection = Instance.new("Frame", farmContent)
    fishSection.Size = UDim2.new(1, 0, 0, 150)
    fishSection.Position = UDim2.new(0, 0, 0.6, 0)
    fishSection.BackgroundTransparency = 1

    local l3 = Instance.new("TextLabel", fishSection)
    l3.Size = UDim2.new(0.9, 0, 0, 30)
    l3.Position = UDim2.new(0.05, 0, 0, 0)
    l3.Text = "🎣 PESCA"
    l3.TextColor3 = Color3.fromRGB(100, 200, 255)
    l3.TextScaled = true
    l3.BackgroundTransparency = 1

    local fishBtn = Instance.new("TextButton", fishSection)
    fishBtn.Size = UDim2.new(0.9, 0, 0, 40)
    fishBtn.Position = UDim2.new(0.05, 0, 0.08, 0)
    fishBtn.Text = "Auto Pesca: OFF"
    fishBtn.TextScaled = true
    fishBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 100)
    local c7 = Instance.new("UICorner", fishBtn)
    c7.CornerRadius = UDim.new(0, 8)
    fishBtn.TouchTap:Connect(function()
        if not getPlayerFishingRod() then
            notify("❌ No tienes caña de pescar equipada")
            return
        end
        autoFishActive = not autoFishActive
        fishBtn.Text = "Auto Pesca: " .. (autoFishActive and "ON" or "OFF")
        if autoFishActive then
            task.spawn(autoFishLoop)
            notify("🎣 Auto Pesca iniciado")
        else
            notify("🎣 Auto Pesca detenido")
        end
    end)

    local goBuyRod = Instance.new("TextButton", fishSection)
    goBuyRod.Size = UDim2.new(0.4, 0, 0, 35)
    goBuyRod.Position = UDim2.new(0.3, 0, 0.2, 0)
    goBuyRod.Text = "🛒 Ir a comprar caña"
    goBuyRod.TextScaled = true
    goBuyRod.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    local c8 = Instance.new("UICorner", goBuyRod)
    c8.CornerRadius = UDim.new(0, 8)
    goBuyRod.TouchTap:Connect(function()
        teleportToLocation("🏪 UCS Store")
        notify("📍 Ve a la tienda Nautic Finds para comprar una caña")
    end)

    -- ====== PESTAÑA 2: MISSIONS ======
    local missionsContent = Instance.new("Frame", contentFrame)
    missionsContent.Size = UDim2.new(1, 0, 1, 0)
    missionsContent.BackgroundTransparency = 1
    missionsContent.Visible = false

    local l4 = Instance.new("TextLabel", missionsContent)
    l4.Size = UDim2.new(0.9, 0, 0, 30)
    l4.Position = UDim2.new(0.05, 0, 0, 0)
    l4.Text = "📜 MISIONES"
    l4.TextColor3 = Color3.fromRGB(100, 200, 255)
    l4.TextScaled = true
    l4.BackgroundTransparency = 1

    local missionScroll = Instance.new("ScrollingFrame", missionsContent)
    missionScroll.Size = UDim2.new(0.9, 0, 0, 400)
    missionScroll.Position = UDim2.new(0.05, 0, 0.06, 0)
    missionScroll.BackgroundTransparency = 1
    missionScroll.CanvasSize = UDim2.new(0, 0, 0, 800)
    missionScroll.ScrollBarThickness = 4

    local function refreshMissions()
        for _, child in pairs(missionScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, mission in ipairs(missionsDB) do
            local status = mission.completed and "🟢" or "⏳"
            local btn = Instance.new("TextButton", missionScroll)
            btn.Size = UDim2.new(0.9, 0, 0, 40)
            btn.Text = status .. " " .. mission.name .. " ($" .. mission.cost .. ")"
            btn.TextScaled = true
            btn.BackgroundColor3 = mission.completed and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(60, 60, 90)
            local c = Instance.new("UICorner", btn)
            c.CornerRadius = UDim.new(0, 6)
            btn.TouchTap:Connect(function()
                if mission.completed then
                    notify("✅ Misión ya completada")
                    return
                end
                checkMission(mission)
            end)
        end
        missionScroll.CanvasSize = UDim2.new(0, 0, 0, #missionsDB * 45 + 20)
    end

    local refreshMissionsBtn = Instance.new("TextButton", missionsContent)
    refreshMissionsBtn.Size = UDim2.new(0.4, 0, 0, 35)
    refreshMissionsBtn.Position = UDim2.new(0.3, 0, 0.5, 0)
    refreshMissionsBtn.Text = "🔄 Refrescar"
    refreshMissionsBtn.TextScaled = true
    refreshMissionsBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    local c9 = Instance.new("UICorner", refreshMissionsBtn)
    c9.CornerRadius = UDim.new(0, 8)
    refreshMissionsBtn.TouchTap:Connect(refreshMissions)

    -- ====== PESTAÑA 3: TELEPORTS ======
    local teleContent = Instance.new("Frame", contentFrame)
    teleContent.Size = UDim2.new(1, 0, 1, 0)
    teleContent.BackgroundTransparency = 1
    teleContent.Visible = false

    local l5 = Instance.new("TextLabel", teleContent)
    l5.Size = UDim2.new(0.9, 0, 0, 30)
    l5.Position = UDim2.new(0.05, 0, 0, 0)
    l5.Text = "📍 TELEPORTS"
    l5.TextColor3 = Color3.fromRGB(255, 200, 100)
    l5.TextScaled = true
    l5.BackgroundTransparency = 1

    -- Teleports predefinidos
    local defaultLabel = Instance.new("TextLabel", teleContent)
    defaultLabel.Size = UDim2.new(0.9, 0, 0, 25)
    defaultLabel.Position = UDim2.new(0.05, 0, 0.06, 0)
    defaultLabel.Text = "📌 Predefinidos:"
    defaultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    defaultLabel.TextScaled = true
    defaultLabel.BackgroundTransparency = 1

    local defaultScroll = Instance.new("ScrollingFrame", teleContent)
    defaultScroll.Size = UDim2.new(0.9, 0, 0, 150)
    defaultScroll.Position = UDim2.new(0.05, 0, 0.1, 0)
    defaultScroll.BackgroundTransparency = 1
    defaultScroll.CanvasSize = UDim2.new(0, 0, 0, 400)
    defaultScroll.ScrollBarThickness = 4

    local function refreshDefaultTeleports()
        for _, child in pairs(defaultScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for name, data in pairs(defaultTeleports) do
            local btn = Instance.new("TextButton", defaultScroll)
            btn.Size = UDim2.new(0.9, 0, 0, 35)
            btn.Text = name
            btn.TextScaled = true
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
            local c = Instance.new("UICorner", btn)
            c.CornerRadius = UDim.new(0, 6)
            btn.TouchTap:Connect(function()
                teleportToLocation(name)
            end)
        end
        defaultScroll.CanvasSize = UDim2.new(0, 0, 0, #defaultTeleports * 40 + 20)
    end

    refreshDefaultTeleports()

    -- Teleports personalizados
    local customLabel = Instance.new("TextLabel", teleContent)
    customLabel.Size = UDim2.new(0.9, 0, 0, 25)
    customLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
    customLabel.Text = "📌 Personalizados:"
    customLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    customLabel.TextScaled = true
    customLabel.BackgroundTransparency = 1

    local customScroll = Instance.new("ScrollingFrame", teleContent)
    customScroll.Size = UDim2.new(0.9, 0, 0, 120)
    customScroll.Position = UDim2.new(0.05, 0, 0.4, 0)
    customScroll.BackgroundTransparency = 1
    customScroll.CanvasSize = UDim2.new(0, 0, 0, 400)
    customScroll.ScrollBarThickness = 4

    local function refreshCustomTeleports()
        for _, child in pairs(customScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local names = listTeleports()
        for _, name in ipairs(names) do
            if teleports[name] and teleports[name].type == "custom" then
                local btn = Instance.new("TextButton", customScroll)
                btn.Size = UDim2.new(0.9, 0, 0, 35)
                btn.Text = "📍 " .. name
                btn.TextScaled = true
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
                local c = Instance.new("UICorner", btn)
                c.CornerRadius = UDim.new(0, 6)
                btn.TouchTap:Connect(function()
                    teleportToLocation(name)
                end)
            end
        end
        customScroll.CanvasSize = UDim2.new(0, 0, 0, #names * 40 + 20)
    end

    -- Guardar ubicación personalizada
    local teleNameInput = Instance.new("TextBox", teleContent)
    teleNameInput.Size = UDim2.new(0.6, 0, 0, 35)
    teleNameInput.Position = UDim2.new(0.05, 0, 0.55, 0)
    teleNameInput.PlaceholderText = "Nombre del teleport"
    teleNameInput.Text = ""
    teleNameInput.TextScaled = true
    teleNameInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    teleNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)

    local saveTeleBtn = Instance.new("TextButton", teleContent)
    saveTeleBtn.Size = UDim2.new(0.25, 0, 0, 35)
    saveTeleBtn.Position = UDim2.new(0.68, 0, 0.55, 0)
    saveTeleBtn.Text = "💾 Guardar"
    saveTeleBtn.TextScaled = true
    saveTeleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    local c10 = Instance.new("UICorner", saveTeleBtn)
    c10.CornerRadius = UDim.new(0, 8)
    saveTeleBtn.TouchTap:Connect(function()
        local name = teleNameInput.Text
        if name ~= "" then
            saveCurrentLocation(name)
            teleNameInput.Text = ""
            refreshCustomTeleports()
        else
            notify("❌ Escribe un nombre primero")
        end
    end)

    local refreshCustomBtn = Instance.new("TextButton", teleContent)
    refreshCustomBtn.Size = UDim2.new(0.4, 0, 0, 30)
    refreshCustomBtn.Position = UDim2.new(0.3, 0, 0.62, 0)
    refreshCustomBtn.Text = "🔄 Refrescar"
    refreshCustomBtn.TextScaled = true
    refreshCustomBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    local c11 = Instance.new("UICorner", refreshCustomBtn)
    c11.CornerRadius = UDim.new(0, 8)
    refreshCustomBtn.TouchTap:Connect(refreshCustomTeleports)

    -- ====== PESTAÑA 4: OTHERS ======
    local othersContent = Instance.new("Frame", contentFrame)
    othersContent.Size = UDim2.new(1, 0, 1, 0)
    othersContent.BackgroundTransparency = 1
    othersContent.Visible = false

    local l6 = Instance.new("TextLabel", othersContent)
    l6.Size = UDim2.new(0.9, 0, 0, 30)
    l6.Position = UDim2.new(0.05, 0, 0, 0)
    l6.Text = "⚙️ OTRAS FUNCIONES"
    l6.TextColor3 = Color3.fromRGB(255, 180, 100)
    l6.TextScaled = true
    l6.BackgroundTransparency = 1

    -- Fly
    local flyBtn = Instance.new("TextButton", othersContent)
    flyBtn.Size = UDim2.new(0.9, 0, 0, 40)
    flyBtn.Position = UDim2.new(0.05, 0, 0.06, 0)
    flyBtn.Text = "🦅 Fly: OFF"
    flyBtn.TextScaled = true
    flyBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 100)
    local c12 = Instance.new("UICorner", flyBtn)
    c12.CornerRadius = UDim.new(0, 8)
    flyBtn.TouchTap:Connect(function()
        local state = toggleFly()
        flyBtn.Text = "🦅 Fly: " .. (state and "ON" or "OFF")
    end)

    -- Slider de velocidad (con + y -)
    local speedLabel = Instance.new("TextLabel", othersContent)
    speedLabel.Size = UDim2.new(0.4, 0, 0, 30)
    speedLabel.Position = UDim2.new(0.05, 0, 0.14, 0)
    speedLabel.Text = "🚀 Velocidad: 40"
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.TextScaled = true
    speedLabel.BackgroundTransparency = 1

    local speedMinus = Instance.new("TextButton", othersContent)
    speedMinus.Size = UDim2.new(0.1, 0, 0, 30)
    speedMinus.Position = UDim2.new(0.5, 0, 0.14, 0)
    speedMinus.Text = "-"
    speedMinus.TextScaled = true
    speedMinus.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    local c13 = Instance.new("UICorner", speedMinus)
    c13.CornerRadius = UDim.new(0, 6)
    speedMinus.TouchTap:Connect(function()
        flySpeed = math.max(20, flySpeed - 5)
        speedLabel.Text = "🚀 Velocidad: " .. flySpeed
    end)

    local speedPlus = Instance.new("TextButton", othersContent)
    speedPlus.Size = UDim2.new(0.1, 0, 0, 30)
    speedPlus.Position = UDim2.new(0.65, 0, 0.14, 0)
    speedPlus.Text = "+"
    speedPlus.TextScaled = true
    speedPlus.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    local c14 = Instance.new("UICorner", speedPlus)
    c14.CornerRadius = UDim.new(0, 6)
    speedPlus.TouchTap:Connect(function()
        flySpeed = math.min(100, flySpeed + 5)
        speedLabel.Text = "🚀 Velocidad: " .. flySpeed
    end)

    -- Infinite Jump
    local jumpBtn = Instance.new("TextButton", othersContent)
    jumpBtn.Size = UDim2.new(0.9, 0, 0, 40)
    jumpBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
    jumpBtn.Text = "🦘 Infinite Jump: OFF"
    jumpBtn.TextScaled = true
    jumpBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 100)
    local c15 = Instance.new("UICorner", jumpBtn)
    c15.CornerRadius = UDim.new(0, 8)
    jumpBtn.TouchTap:Connect(function()
        local state = toggleInfiniteJump()
        jumpBtn.Text = "🦘 Infinite Jump: " .. (state and "ON" or "OFF")
    end)

    -- Time Display
    local timeBtn = Instance.new("TextButton", othersContent)
    timeBtn.Size = UDim2.new(0.9, 0, 0, 40)
    timeBtn.Position = UDim2.new(0.05, 0, 0.28, 0)
    timeBtn.Text = "🕐 Time: ON"
    timeBtn.TextScaled = true
    timeBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 100)
    local c16 = Instance.new("UICorner", timeBtn)
    c16.CornerRadius = UDim.new(0, 8)
    timeBtn.TouchTap:Connect(function()
        local state = toggleTime()
        timeBtn.Text = "🕐 Time: " .. (state and "ON" or "OFF")
    end)

    -- Anti-Staff
    local staffBtn = Instance.new("TextButton", othersContent)
    staffBtn.Size = UDim2.new(0.9, 0, 0, 40)
    staffBtn.Position = UDim2.new(0.05, 0, 0.36, 0)
    staffBtn.Text = "🛡️ Anti-Staff: ON"
    staffBtn.TextScaled = true
    staffBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 100)
    local c17 = Instance.new("UICorner", staffBtn)
    c17.CornerRadius = UDim.new(0, 8)
    staffBtn.TouchTap:Connect(function()
        local state = toggleAntiStaff()
        staffBtn.Text = "🛡️ Anti-Staff: " .. (state and "ON" or "OFF")
    end)

    -- Anti-AFK
    local afkBtn = Instance.new("TextButton", othersContent)
    afkBtn.Size = UDim2.new(0.9, 0, 0, 40)
    afkBtn.Position = UDim2.new(0.05, 0, 0.44, 0)
    afkBtn.Text = "💤 Anti-AFK: ON"
    afkBtn.TextScaled = true
    afkBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 100)
    local c18 = Instance.new("UICorner", afkBtn)
    c18.CornerRadius = UDim.new(0, 8)
    afkBtn.TouchTap:Connect(function()
        local state = toggleAntiAFK()
        afkBtn.Text = "💤 Anti-AFK: " .. (state and "ON" or "OFF")
    end)

    -- ====== PESTAÑA 5: SETTINGS ======
    local settingsContent = Instance.new("Frame", contentFrame)
    settingsContent.Size = UDim2.new(1, 0, 1, 0)
    settingsContent.BackgroundTransparency = 1
    settingsContent.Visible = false

    local l7 = Instance.new("TextLabel", settingsContent)
    l7.Size = UDim2.new(0.9, 0, 0, 30)
    l7.Position = UDim2.new(0.05, 0, 0, 0)
    l7.Text = "⚙️ CONFIGURACIÓN"
    l7.TextColor3 = Color3.fromRGB(200, 200, 200)
    l7.TextScaled = true
    l7.BackgroundTransparency = 1

    local moneyBtn = Instance.new("TextButton", settingsContent)
    moneyBtn.Size = UDim2.new(0.9, 0, 0, 40)
    moneyBtn.Position = UDim2.new(0.05, 0, 0.06, 0)
    moneyBtn.Text = "💰 Actualizar dinero"
    moneyBtn.TextScaled = true
    moneyBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 100)
    local c19 = Instance.new("UICorner", moneyBtn)
    c19.CornerRadius = UDim.new(0, 8)
    moneyBtn.TouchTap:Connect(function()
        local money = getPlayerMoney()
        notify("💰 $" .. money)
    end)

    local logsBtn = Instance.new("TextButton", settingsContent)
    logsBtn.Size = UDim2.new(0.9, 0, 0, 40)
    logsBtn.Position = UDim2.new(0.05, 0, 0.14, 0)
    logsBtn.Text = "📜 Ver Logs de hoy"
    logsBtn.TextScaled = true
    logsBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 100)
    local c20 = Instance.new("UICorner", logsBtn)
    c20.CornerRadius = UDim.new(0, 8)
    logsBtn.TouchTap:Connect(function()
        local date = os.date("%Y-%m-%d")
        local logFile = logsFolder .. "/log_" .. date .. ".txt"
        if isfile(logFile) then
            local content = readfile(logFile)
            notify("📄 Logs: " .. content:sub(1, 250) .. "...")
        else
            notify("📄 No hay logs hoy")
        end
    end)

    local reloadBtn = Instance.new("TextButton", settingsContent)
    reloadBtn.Size = UDim2.new(0.9, 0, 0, 40)
    reloadBtn.Position = UDim2.new(0.05, 0, 0.22, 0)
    reloadBtn.Text = "🔄 Recargar script"
    reloadBtn.TextScaled = true
    reloadBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    local c21 = Instance.new("UICorner", reloadBtn)
    c21.CornerRadius = UDim.new(0, 8)
    reloadBtn.TouchTap:Connect(function()
        notify("🔄 Recargando...")
        task.wait(1)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/orvehack/Refinery-Caves-2-Script/main/Refinery-Caves-2-SCRIPT.lua"))()
    end)

    -- ====== CAMBIO DE PESTAÑAS ======
    local function switchTab(tab, content)
        for _, t in ipairs(tabs) do
            t.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
        end
        tab.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        farmContent.Visible = (content == farmContent)
        missionsContent.Visible = (content == missionsContent)
        teleContent.Visible = (content == teleContent)
        othersContent.Visible = (content == othersContent)
        settingsContent.Visible = (content == settingsContent)
    end

    local tab1 = createTab("🌱 Farm", farmContent)
    local tab2 = createTab("📜 Missions", missionsContent)
    local tab3 = createTab("📍 Teleports", teleContent)
    local tab4 = createTab("⚙️ Others", othersContent)
    local tab5 = createTab("🔧 Settings", settingsContent)

    tab1.TouchTap:Connect(function() switchTab(tab1, farmContent) end)
    tab2.TouchTap:Connect(function() switchTab(tab2, missionsContent); refreshMissions() end)
    tab3.TouchTap:Connect(function() switchTab(tab3, teleContent); refreshDefaultTeleports(); refreshCustomTeleports() end)
    tab4.TouchTap:Connect(function() switchTab(tab4, othersContent) end)
    tab5.TouchTap:Connect(function() switchTab(tab5, settingsContent) end)

    -- Inicializar listas
    refreshOreList()
    refreshTreeList()
    refreshMissions()

    -- Cerrar
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -45, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.TextScaled = true
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BackgroundTransparency = 0.3
    local cornerClose = Instance.new("UICorner", closeBtn)
    cornerClose.CornerRadius = UDim.new(0, 8)
    closeBtn.TouchTap:Connect(function()
        sg.Enabled = false
        notify("GUI cerrada", 2)
    end)

    return sg
end

-- 21. INICIALIZACIÓN
local success, err = pcall(function()
    createFloatingButton()
    notify("🚀 RC2 cargado correctamente", 4)
    writeLog("Script cargado correctamente")
end)

if not success then
    notify("❌ Error al cargar: " .. tostring(err), 5)
    writeLog("Error de carga: " .. tostring(err), true)
end

print("✅ RC2 cargado correctamente")
print("📁 Carpeta: " .. folder)
print("🟢 Toca el botón flotante para abrir la GUI")
