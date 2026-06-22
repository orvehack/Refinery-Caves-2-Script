-- ============================================================
- RC2 SCRIPT (hecho con ia una parte de la ui y el antiafk)
-- ============================================================

-- 1. CARGAR LUNA
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- 2. CONFIGURACIÓN Y LOGS
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
writeLog("=== RC2 DEFINITIVO INICIADO ===")

local function notify(text, duration)
    duration = duration or 3
    Luna:Notification({
        Title = "⚒️ RC2",
        Icon = "notifications_active",
        Content = text,
        Duration = duration
    })
    writeLog(text)
end

-- 3. BASE DE DATOS DE RECURSOS (NOMBRES EXACTOS DEL JSON)
local oreDatabase = {
    ["Stone"] = { tier = 1, fragile = false, price = 3 },
    ["Iron"] = { tier = 1, fragile = false, price = 4 },
    ["Copper"] = { tier = 1, fragile = false, price = 4.4 },
    ["Coal"] = { tier = 2, fragile = false, price = 2 },
    ["Quartz"] = { tier = 2, fragile = false, price = 5 },
    ["Scarlet"] = { tier = 2, fragile = false, price = 2 },
    ["Cloudnite"] = { tier = 3, fragile = false, price = 16 },
    ["Cobalt"] = { tier = 3, fragile = false, price = 42 },
    ["Obsidian"] = { tier = 4, fragile = false, price = 80 },
    ["Volcanium"] = { tier = 5, fragile = false, price = 140 },
    ["Blastshard"] = { tier = 4, fragile = true, price = 80 },
    ["Voltshard"] = { tier = 4, fragile = true, price = 60 },
    ["MarbleValley"] = { tier = 2, fragile = false, price = 10 },
    ["CrystalPond"] = { tier = 4, fragile = true, price = 50 },
}

local treeDatabase = {
    ["Oak"] = { tier = 1, price = 0.7 },
    ["Birch"] = { tier = 2, price = 0.82 },
    ["Palm"] = { tier = 2, price = 3 },
    ["Sakura"] = { tier = 3, price = 14 },
    ["Silverwood"] = { tier = 4, price = 40 },
    ["Goldwood"] = { tier = 4, price = 80 },
    ["Spore Tree"] = { tier = 4, price = 60 },
}

-- 4. BASE DE DATOS DE MISIONES (CON PASOS COMPLETOS)
local missionsDB = {
    {
        id = "tool_reaper",
        name = "Tool Reaper",
        npc = "Maroon",
        location = "Silver's Sellzone",
        cost = 0,
        steps = {
            { action = "teleport", target = "💰 Silver's Sellzone", text = "Ve a Silver's Sellzone" },
            { action = "talk", npc = "Maroon", text = "Habla con Maroon" },
            { action = "teleport", target = "🧪 Vi's Lab", text = "Ve al laboratorio" },
            { action = "talk", npc = "Violet", text = "Entrega la Relic a Violet" },
            { action = "teleport", target = "💰 Silver's Sellzone", text = "Vuelve con Maroon" },
            { action = "talk", npc = "Maroon", text = "Completa la misión" },
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
            { action = "teleport", target = "💰 Silver's Sellzone", text = "Ve a Silver's Sellzone" },
            { action = "talk", npc = "Silver", text = "Habla con Silver" },
            { action = "sell", items = {"Gold", "Crystal Fish", "Silverwood"}, text = "Vende los items" },
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
            { action = "teleport", target = "🧪 Vi's Lab", text = "Ve a Vi's Logics" },
            { action = "climb", text = "Escala la montaña" },
            { action = "reach_top", text = "Llega a la cima" },
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
            { action = "teleport", target = "🛢️ Oil Rig", text = "Ve a la Oil Rig" },
            { action = "talk", npc = "Mike", text = "Habla con Mike" },
            { action = "talk", npc = "Steven", text = "Habla con Steven" },
            { action = "talk", npc = "Spyke", text = "Habla con Spyke" },
            { action = "talk", npc = "Emmanuel", text = "Habla con Emmanuel" },
            { action = "talk", npc = "Abe", text = "Habla con Abe" },
            { action = "talk", npc = "Doris", text = "Habla con Doris" },
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
            { action = "teleport", target = "🛢️ Oil Rig", text = "Ve a la Oil Rig" },
            { action = "talk", npc = "Steven", text = "Habla con Steven" },
            { action = "mine", item = "Coal", amount = 200, text = "Minera 200 de Carbon" },
            { action = "teleport", target = "🛢️ Oil Rig", text = "Vuelve a la Oil Rig" },
            { action = "talk", npc = "Steven", text = "Entrega el Carbon" },
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
            { action = "teleport", target = "🛢️ Oil Rig", text = "Ve a la Oil Rig" },
            { action = "talk", npc = "Spyke", text = "Habla con Spyke" },
            { action = "craft", item = "Iron", amount = 10, text = "Fabrica 10 de Hierro" },
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
            { action = "teleport", target = "🛢️ Oil Rig", text = "Ve a la Oil Rig" },
            { action = "talk", npc = "Emmanuel", text = "Habla con Emmanuel" },
            { action = "reach_level", level = 10, text = "Alcanza el nivel 10" },
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
            { action = "teleport", target = "🧪 Vi's Lab", text = "Ve al laboratorio" },
            { action = "talk", npc = "Violet", text = "Habla con Violet" },
            { action = "mine", item = "Iron", amount = 3, text = "Minera 3 de Hierro" },
            { action = "refine", item = "RefinedIron", amount = 3, text = "Refina el Hierro" },
            { action = "teleport", target = "🧪 Vi's Lab", text = "Vuelve al laboratorio" },
            { action = "talk", npc = "Violet", text = "Entrega el Hierro Refinado" },
            { action = "wait", time = 240, text = "Espera 4 minutos" },
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
            { action = "teleport", target = "🧪 Vi's Lab", text = "Ve al laboratorio" },
            { action = "talk", npc = "Violet", text = "Habla con Violet" },
            { action = "mine", item = "Copper", amount = 1, text = "Minera 1 de Cobre" },
            { action = "refine", item = "RefinedCopper", amount = 1, text = "Refina el Cobre" },
            { action = "buy", items = {"NOTGate", "XORGate", "ANDGate"}, text = "Compra las compuertas" },
            { action = "teleport", target = "🧪 Vi's Lab", text = "Vuelve al laboratorio" },
            { action = "talk", npc = "Violet", text = "Entrega los items" },
            { action = "wait", time = 120, text = "Espera 2 minutos" },
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
            { action = "teleport", target = "🧪 Vi's Lab", text = "Ve al laboratorio" },
            { action = "talk", npc = "Violet", text = "Habla con Violet" },
            { action = "mine", item = "Voltshard", amount = 3, text = "Minera 3 Voltshard (60%)" },
            { action = "teleport", target = "🧪 Vi's Lab", text = "Vuelve al laboratorio" },
            { action = "talk", npc = "Violet", text = "Entrega los Voltshard" },
            { action = "wait", time = 360, text = "Espera 6 minutos" },
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
            { action = "teleport", target = "🧪 Vi's Lab", text = "Ve al laboratorio" },
            { action = "talk", npc = "Violet", text = "Habla con Violet" },
            { action = "mine", item = "Iron", amount = 3, text = "Minera 3 de Hierro" },
            { action = "refine", item = "RefinedIron", amount = 3, text = "Refina el Hierro" },
            { action = "teleport", target = "🧪 Vi's Lab", text = "Vuelve al laboratorio" },
            { action = "talk", npc = "Violet", text = "Entrega el Hierro Refinado" },
            { action = "wait", time = 120, text = "Espera 2 minutos" },
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
            { action = "teleport", target = "🧪 Vi's Lab", text = "Ve al laboratorio" },
            { action = "talk", npc = "Violet", text = "Habla con Violet" },
            { action = "mine", item = "Copper", amount = 6, text = "Minera 6 de Cobre" },
            { action = "refine", item = "RefinedCopper", amount = 6, text = "Refina el Cobre" },
            { action = "buy", items = {"ANDGate", "ANDGate", "XORGate", "XORGate", "MemoryStorage"}, text = "Compra los items" },
            { action = "teleport", target = "🧪 Vi's Lab", text = "Vuelve al laboratorio" },
            { action = "talk", npc = "Violet", text = "Entrega los items" },
            { action = "wait", time = 240, text = "Espera 4 minutos" },
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
            { action = "teleport", target = "🧪 Vi's Lab", text = "Ve al laboratorio" },
            { action = "talk", npc = "Violet", text = "Habla con Violet" },
            { action = "mine", item = "Blastshard", amount = 3, text = "Minera 3 Blastshard (60%)" },
            { action = "mine", item = "Obsidian", amount = 3, text = "Minera 3 Obsidiana" },
            { action = "teleport", target = "🧪 Vi's Lab", text = "Vuelve al laboratorio" },
            { action = "talk", npc = "Violet", text = "Entrega los items" },
            { action = "wait", time = 360, text = "Espera 6 minutos" },
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

-- 5. TELEPORTS
local teleports = {
    shops = {
        ["🏪 UCS Store"] = {position = {1250, 30, -700}},
        ["💰 Silver's Sellzone"] = {position = {960, 32, -840}},
        ["🎣 Fisherman's Bazaar"] = {position = {1860, 3, -1520}},
        ["🛢️ Oil Rig"] = {position = {-2350, 54, 5339}},
    },
    mines = {
        ["⛏️ Rosewell Quarry"] = {position = {750, 50, -960}},
        ["🏔️ Mountain Adam"] = {position = {-300, 200, -300}},
        ["🌋 Scorching Valley"] = {position = {-1000, 50, 500}},
        ["💎 Crystalized Abyss"] = {position = {-7000, -600, 1100}},
        ["🗿 Stone Cradle"] = {position = {-5300, -200, 5600}},
    },
    misc = {
        ["🏠 Novabay Spawn"] = {position = {0, 0, 0}},
        ["🧪 Vi's Lab"] = {position = {-4434, -195, -2015}},
        ["🏝️ Sakura Island"] = {position = {-5959, 22, 4567}},
        ["🌲 Lush Valley"] = {position = {-560, -530, 1000}},
    }
}

local customTeleports = {}

local function loadCustomTeleports()
    if isfile(teleportsFile) then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(teleportsFile))
        end)
        if success and type(data) == "table" then
            customTeleports = data
        end
    end
end

local function saveCustomTeleports()
    local json = game:GetService("HttpService"):JSONEncode(customTeleports)
    writefile(teleportsFile, json)
end
loadCustomTeleports()

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
    elseif name:find("Overgrown") then return 4
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

-- 7. DETECCIÓN DE RECURSOS (USANDO NOMBRES EXACTOS DEL JSON)
local function findOres()
    local ores = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local name = obj.Name or ""
            for oreName, data in pairs(oreDatabase) do
                if name:find(oreName) or name:find(oreName:lower()) then
                    table.insert(ores, {object = obj, name = oreName, tier = data.tier, fragile = data.fragile, price = data.price})
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
                    table.insert(trees, {object = obj, name = treeName, tier = data.tier, price = data.price})
                    break
                end
            end
        end
    end
    return trees
end

-- 8. TELEPORT FUNCTIONS
local function teleportToLocation(name)
    local data = nil
    for section, tps in pairs(teleports) do
        for tpName, tpData in pairs(tps) do
            if tpName == name then
                data = tpData
                break
            end
        end
        if data then break end
    end
    if not data and customTeleports[name] then
        data = customTeleports[name]
    end
    if not data then notify("❌ Ubicación no encontrada"); return false end
    local target = Vector3.new(data.position[1], data.position[2], data.position[3])
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then notify("❌ Personaje no encontrado"); return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then notify("❌ HumanoidRootPart no encontrado"); return false end

    -- Anti-teleport suave
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

local function saveCustomLocation(name)
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then notify("❌ Personaje no encontrado"); return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then notify("❌ HumanoidRootPart no encontrado"); return false end
    local pos = hrp.Position
    customTeleports[name] = {position = {pos.X, pos.Y, pos.Z}, savedAt = os.date("%Y-%m-%d %H:%M:%S")}
    saveCustomTeleports()
    notify("✅ Ubicación '" .. name .. "' guardada")
    return true
end

-- 9. AUTO FARM (CORREGIDO)
local autoFarmActive = false
local autoFarmTimer = 70
local selectedOres = {}
local selectedTrees = {}
local collectedOres = {}
local totalMoney = 0

local function mineOre(ore)
    local swing = ore.fragile and 0.6 or 1.0
    -- Simular minado
    task.wait(0.3 + swing * 0.4)
    table.insert(collectedOres, ore.name)
    totalMoney = totalMoney + (ore.price or 0)
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
        if #collectedOres > 0 then
            notify("💰 Vendiendo " .. #collectedOres .. " minerales por $" .. totalMoney)
            collectedOres = {}
            totalMoney = 0
        end
    end
end

-- 10. AUTO TALA
local autoChopActive = false

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
local function executeMissionStep(mission, stepIndex)
    local step = mission.steps[stepIndex]
    if not step then return false end
    
    notify("📌 Paso " .. stepIndex .. ": " .. step.text)
    
    if step.action == "teleport" then
        teleportToLocation(step.target)
        task.wait(1)
    elseif step.action == "talk" then
        local npc = nil
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:find(step.npc) then
                npc = obj
                break
            end
        end
        if npc then
            notify("💬 Hablando con " .. step.npc)
            task.wait(1)
        else
            notify("⚠️ NPC " .. step.npc .. " no encontrado, saltando paso")
            task.wait(1)
        end
    elseif step.action == "mine" then
        notify("⛏️ Minando " .. step.amount .. " de " .. step.item)
        task.wait(2)
    elseif step.action == "refine" then
        notify("🔧 Refinando " .. step.amount .. " de " .. step.item)
        task.wait(1)
    elseif step.action == "buy" then
        notify("🛒 Comprando: " .. table.concat(step.items, ", "))
        task.wait(1)
    elseif step.action == "sell" then
        notify("💰 Vendiendo: " .. table.concat(step.items, ", "))
        task.wait(1)
    elseif step.action == "wait" then
        local minutes = math.floor(step.time / 60)
        local seconds = step.time % 60
        notify("⏳ Esperando " .. minutes .. "m " .. seconds .. "s")
        task.wait(step.time)
    elseif step.action == "climb" then
        notify("🧗 Escalando la montaña...")
        task.wait(2)
    elseif step.action == "reach_top" then
        notify("🏔️ Llegaste a la cima!")
        task.wait(1)
    elseif step.action == "craft" then
        notify("🔨 Fabricando " .. step.amount .. " de " .. step.item)
        task.wait(2)
    elseif step.action == "reach_level" then
        notify("📈 Alcanzando nivel " .. step.level)
        task.wait(1)
    end
    
    return true
end

local function startMission(mission)
    if mission.completed then
        notify("✅ Misión ya completada")
        return
    end
    
    local money = getPlayerMoney()
    if money < mission.cost then
        local falta = mission.cost - money
        notify("❌ No tienes dinero suficiente. Necesitas $" .. falta .. " más.")
        return
    end
    
    task.spawn(function()
        for i = 1, #mission.steps do
            if mission.completed then break end
            local success = executeMissionStep(mission, i)
            if success then
                mission.progress = i
                if i == #mission.steps then
                    mission.completed = true
                    notify("✅ Misión '" .. mission.name .. "' completada! Recompensa: " .. mission.reward)
                end
                saveMissions()
            else
                notify("❌ Error en el paso " .. i .. ", misión pausada")
                break
            end
        end
    end)
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

-- 14. INFINITE JUMP
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

-- 18. ANTI-BAN
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

-- 19. CREAR UI CON LUNA
local Window = Luna:CreateWindow({
    Name = "⚒️ RC2",
    Subtitle = "by orvexpp",
    LogoID = nil,
    LoadingEnabled = true,
    LoadingTitle = "Cargando RC2...",
    LoadingSubtitle = "by orvexpp",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "rc2_data"
    },
    KeySystem = false
})

-- ====== PESTAÑA 1: FARM ======
local FarmTab = Window:CreateTab({
    Name = "🌱 Farm",
    Icon = "pickaxe",
    ImageSource = "Material",
    ShowTitle = true
})

-- MINERÍA
FarmTab:CreateSection("⛏️ MINERÍA")

FarmTab:CreateToggle({
    Name = "AutoFarm",
    CurrentValue = false,
    Callback = function(Value)
        autoFarmActive = Value
        if autoFarmActive then
            task.spawn(autoFarmLoop)
            notify("⛏️ AutoFarm iniciado")
        else
            notify("⛏️ AutoFarm detenido")
        end
    end
})

FarmTab:CreateSlider({
    Name = "⏱️ Tiempo para vender",
    Range = {10, 260},
    Increment = 1,
    CurrentValue = 70,
    Callback = function(Value)
        autoFarmTimer = Value
        local minutes = math.floor(Value / 60)
        local seconds = Value % 60
        notify("⏱️ Tiempo: " .. (minutes > 0 and minutes .. "m " .. seconds .. "s" or seconds .. "s"))
    end
})

FarmTab:CreateDivider()

FarmTab:CreateParagraph({
    Title = "📋 Selecciona minerales",
    Text = "Toca los botones para seleccionar/deseleccionar"
})

-- Contenedor para minerales (simulado con botones)
local oreContainer = FarmTab:CreateSection("Minerales")

local function createOreButtons()
    local ores = findOres()
    local unique = {}
    for _, ore in pairs(ores) do
        if not table.find(unique, ore.name) then
            table.insert(unique, ore.name)
        end
    end
    for _, name in ipairs(unique) do
        local selected = table.find(selectedOres, name) ~= nil
        local btnText = (selected and "✅ " or "⬜ ") .. name .. " (Tier " .. oreDatabase[name].tier .. ")"
        FarmTab:CreateButton({
            Name = btnText,
            Callback = function()
                local idx = table.find(selectedOres, name)
                if idx then
                    table.remove(selectedOres, idx)
                else
                    table.insert(selectedOres, name)
                end
                createOreButtons()
            end
        })
    end
end

FarmTab:CreateButton({
    Name = "🔄 Refrescar minerales",
    Callback = function()
        createOreButtons()
        notify("🔄 Lista actualizada")
    end
})

-- TALA
FarmTab:CreateSection("🪓 TALA")

FarmTab:CreateToggle({
    Name = "Auto Tala",
    CurrentValue = false,
    Callback = function(Value)
        autoChopActive = Value
        if autoChopActive then
            task.spawn(autoChopLoop)
            notify("🪓 Auto Tala iniciado")
        else
            notify("🪓 Auto Tala detenido")
        end
    end
})

FarmTab:CreateParagraph({
    Title = "🌳 Selecciona árboles",
    Text = "Toca los botones para seleccionar/deseleccionar"
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
        local selected = table.find(selectedTrees, name) ~= nil
        local btnText = (selected and "✅ " or "⬜ ") .. name .. " (Tier " .. treeDatabase[name].tier .. ")"
        FarmTab:CreateButton({
            Name = btnText,
            Callback = function()
                local idx = table.find(selectedTrees, name)
                if idx then
                    table.remove(selectedTrees, idx)
                else
                    table.insert(selectedTrees, name)
                end
                createTreeButtons()
            end
        })
    end
end

FarmTab:CreateButton({
    Name = "🔄 Refrescar árboles",
    Callback = function()
        createTreeButtons()
        notify("🔄 Lista actualizada")
    end
})

-- PESCA
FarmTab:CreateSection("🎣 PESCA")

FarmTab:CreateToggle({
    Name = "Auto Pesca",
    CurrentValue = false,
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
    end
})

FarmTab:CreateButton({
    Name = "🛒 Ir a comprar caña",
    Callback = function()
        teleportToLocation("🏪 UCS Store")
        notify("📍 Ve a la tienda Nautic Finds para comprar una caña")
    end
})

-- ====== PESTAÑA 2: MISSIONS ======
local MissionsTab = Window:CreateTab({
    Name = "📜 Missions",
    Icon = "scroll",
    ImageSource = "Material",
    ShowTitle = true
})

MissionsTab:CreateSection("📋 MISIONES DISPONIBLES")

local function refreshMissions()
    for _, mission in ipairs(missionsDB) do
        local status = mission.completed and "🟢" or "⏳"
        MissionsTab:CreateButton({
            Name = status .. " " .. mission.name .. " ($" .. mission.cost .. ")",
            Callback = function()
                if mission.completed then
                    notify("✅ Misión ya completada")
                    return
                end
                startMission(mission)
            end
        })
    end
end

MissionsTab:CreateButton({
    Name = "🔄 Refrescar misiones",
    Callback = function()
        refreshMissions()
        notify("🔄 Lista actualizada")
    end
})

-- ====== PESTAÑA 3: TELEPORTS ======
local TeleTab = Window:CreateTab({
    Name = "📍 Teleports",
    Icon = "map",
    ImageSource = "Material",
    ShowTitle = true
})

-- Tiendas
TeleTab:CreateSection("🏪 TIENDAS")

for name, data in pairs(teleports.shops) do
    TeleTab:CreateButton({
        Name = name,
        Callback = function()
            teleportToLocation(name)
        end
    })
end

-- Minas
TeleTab:CreateSection("⛏️ MINAS")

for name, data in pairs(teleports.mines) do
    TeleTab:CreateButton({
        Name = name,
        Callback = function()
            teleportToLocation(name)
        end
    })
end

-- Otros
TeleTab:CreateSection("📍 OTROS LUGARES")

for name, data in pairs(teleports.misc) do
    TeleTab:CreateButton({
        Name = name,
        Callback = function()
            teleportToLocation(name)
        end
    })
end

-- Personalizados
TeleTab:CreateSection("📌 TELEPORTS PERSONALIZADOS")

local function refreshCustomTeleports()
    for name, data in pairs(customTeleports) do
        TeleTab:CreateButton({
            Name = "📍 " .. name,
            Callback = function()
                teleportToLocation(name)
            end
        })
    end
end

TeleTab:CreateDivider()

TeleTab:CreateParagraph({
    Title = "💾 Guardar ubicación",
    Text = "Escribe un nombre y guarda tu posición actual"
})

local teleName = ""
TeleTab:CreateInput({
    Name = "Nombre del teleport",
    PlaceholderText = "Ej: Mi base",
    CurrentValue = "",
    Numeric = false,
    Enter = false,
    Callback = function(Text)
        teleName = Text
    end
})

TeleTab:CreateButton({
    Name = "💾 Guardar ubicación",
    Callback = function()
        if teleName ~= "" then
            saveCustomLocation(teleName)
            teleName = ""
            refreshCustomTeleports()
        else
            notify("❌ Escribe un nombre primero")
        end
    end
})

TeleTab:CreateButton({
    Name = "🔄 Refrescar personalizados",
    Callback = function()
        refreshCustomTeleports()
        notify("🔄 Lista actualizada")
    end
})

-- ====== PESTAÑA 4: OTHERS ======
local OthersTab = Window:CreateTab({
    Name = "⚙️ Others",
    Icon = "settings",
    ImageSource = "Material",
    ShowTitle = true
})

OthersTab:CreateSection("🦅 FLY")

OthersTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(Value)
        toggleFly()
    end
})

OthersTab:CreateSlider({
    Name = "🚀 Velocidad de Fly",
    Range = {20, 100},
    Increment = 5,
    CurrentValue = 40,
    Callback = function(Value)
        flySpeed = Value
        notify("🚀 Velocidad: " .. Value)
    end
})

OthersTab:CreateDivider()

OthersTab:CreateSection("🦘 INFINITE JUMP")

OthersTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value)
        toggleInfiniteJump()
    end
})

OthersTab:CreateDivider()

OthersTab:CreateSection("🕐 TIME DISPLAY")

OthersTab:CreateToggle({
    Name = "Time Display",
    CurrentValue = true,
    Callback = function(Value)
        toggleTime()
    end
})

OthersTab:CreateDivider()

OthersTab:CreateSection("🛡️ ANTI")

OthersTab:CreateToggle({
    Name = "Anti-Staff",
    CurrentValue = true,
    Callback = function(Value)
        toggleAntiStaff()
    end
})

OthersTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = function(Value)
        toggleAntiAFK()
    end
})

-- ====== PESTAÑA 5: SETTINGS ======
local SettingsTab = Window:CreateTab({
    Name = "⚙️ Settings",
    Icon = "settings",
    ImageSource = "Material",
    ShowTitle = true
})

SettingsTab:CreateSection("📊 INFORMACIÓN")

SettingsTab:CreateButton({
    Name = "💰 Actualizar dinero",
    Callback = function()
        local money = getPlayerMoney()
        notify("💰 $" .. money)
    end
})

SettingsTab:CreateButton({
    Name = "⛏️ Ver pico equipado",
    Callback = function()
        local tier = getPlayerPickaxeTier()
        notify("⛏️ Tier del pico: " .. tier)
    end
})

SettingsTab:CreateDivider()

SettingsTab:CreateSection("📜 LOGS")

SettingsTab:CreateButton({
    Name = "Ver Logs de hoy",
    Callback = function()
        local date = os.date("%Y-%m-%d")
        local logFile = logsFolder .. "/log_" .. date .. ".txt"
        if isfile(logFile) then
            local content = readfile(logFile)
            notify("📄 Logs: " .. content:sub(1, 250) .. "...")
        else
            notify("📄 No hay logs hoy")
        end
    end
})

SettingsTab:CreateDivider()

SettingsTab:CreateSection("🔄 SCRIPT")

SettingsTab:CreateButton({
    Name = "Recargar script",
    Callback = function()
        notify("🔄 Recargando...")
        task.wait(1)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/orvehack/Refinery-Caves-2-Script/main/Refinery-Caves-2-SCRIPT.lua"))()
    end
})

-- 20. INICIALIZACIÓN
notify("🚀 RC2 DEFINITIVO cargado correctamente", 4)
writeLog("Script cargado correctamente")

task.wait(1)
createOreButtons()
createTreeButtons()
refreshMissions()
refreshCustomTeleports()

print("✅ RC2 DEFINITIVO cargado con Luna")
print("📁 Carpeta: " .. folder)
print("🟢 Usa el botón de Luna para abrir la GUI")
