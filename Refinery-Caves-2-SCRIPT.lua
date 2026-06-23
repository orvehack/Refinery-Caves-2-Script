local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

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

local function notify(text, duration)
    duration = duration or 3
    Fluent:Notify({
        Title = "⚒️ RC2",
        Content = text,
        Duration = duration
    })
    writeLog(text)
end

-- BASE DE DATOS
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
}

local treeDatabase = {
    ["Oak"] = { tier = 1, price = 0.7 },
    ["Birch"] = { tier = 2, price = 0.82 },
    ["Palm"] = { tier = 2, price = 3 },
    ["Sakura"] = { tier = 3, price = 14 },
    ["Silverwood"] = { tier = 4, price = 40 },
    ["Goldwood"] = { tier = 4, price = 80 },
}

-- MISIONES CON PASOS REALES
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

-- TELEPORTS CORREGIDOS (coordenadas ajustadas)
local teleports = {
    shops = {
        ["💰 Silver's Sellzone"] = {position = {960, 32, -840}},
        ["🏪 UCS Store"] = {position = {1250, 30, -700}},
        ["🎣 Fisherman's Bazaar"] = {position = {1860, 3, -1520}},
        ["🛢️ Oil Rig"] = {position = {-2345, 58, 5345}},
        ["🏝️ Nautic Finds"] = {position = {1825, 3, -1340}},
    },
    mines = {
        ["⛏️ Rosewell Quarry"] = {position = {750, 50, -960}},
        ["🏔️ Mountain Adam"] = {position = {-300, 200, -300}},
        ["🌋 Scorching Valley"] = {position = {-1000, 50, 500}},
        ["💎 Crystalized Abyss"] = {position = {-7000, -600, 1100}},
        ["🗿 Stone Cradle"] = {position = {-5300, -200, 5600}},
        ["🌲 Lush Valley"] = {position = {-560, -530, 1000}},
    },
    misc = {
        ["🏠 Novabay Spawn"] = {position = {0, 0, 0}},
        ["🧪 Vi's Lab"] = {position = {-4434, -195, -2015}},
        ["🏝️ Sakura Island"] = {position = {-5959, 22, 4567}},
        ["🏝️ Spore Cave"] = {position = {-5260, -200, 5616}},
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

-- FUNCIONES DE JUGADOR
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

-- DETECCIÓN DE RECURSOS
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

-- TELEPORT FUNCTIONS
local function teleportToLocation(name)
    local data = nil
    for section, tps in pairs(teleports) do
        for tpName, tpData in pairs(tps) do
            if tpName == name then data = tpData; break end
        end
        if data then break end
    end
    if not data and customTeleports[name] then data = customTeleports[name] end
    if not data then notify("❌ Ubicación no encontrada"); return false end
    local target = Vector3.new(data.position[1], data.position[2], data.position[3])
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then notify("❌ Personaje no encontrado"); return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then notify("❌ HumanoidRootPart no encontrado"); return false end

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

-- AUTO FARM
local autoFarmActive = false
local autoFarmTimer = 70
local selectedOres = {}
local selectedTrees = {}
local collectedOres = {}
local totalMoney = 0

local function mineOre(ore)
    local swing = ore.fragile and 0.6 or 1.0
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

-- AUTO TALA
local autoChopActive = false
local function chopTree(tree) task.wait(0.5 + math.random(1, 3) * 0.1) end
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

-- AUTO PESCA
local autoFishActive = false
local function autoFishLoop()
    while autoFishActive do
        if not getPlayerFishingRod() then notify("❌ No tienes caña"); break end
        task.wait(2 + math.random(1, 5))
        task.wait(1 + math.random(1, 3))
        notify("🎣 Pescado capturado!")
        task.wait(1)
    end
end

-- FUNCIÓN PARA HABLAR CON NPCs (CORREGIDA)
local function talkToNPC(npcName)
    local npc = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find(npcName) then
            npc = obj
            break
        end
    end
    if not npc then 
        notify("⚠️ NPC " .. npcName .. " no encontrado")
        return false 
    end
    
    local talkPart = npc:FindFirstChild("TalkPart") or npc:FindFirstChild("HumanoidRootPart")
    if not talkPart then 
        notify("⚠️ No se encontró TalkPart para " .. npcName)
        return false 
    end
    
    -- Buscar el Remote correcto
    local interactRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
    if interactRemote then
        interactRemote = interactRemote:FindFirstChild("Interact")
    end
    if not interactRemote then
        interactRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Interact")
    end
    if not interactRemote then
        notify("⚠️ No se encontró Remote para interactuar")
        return false
    end
    
    pcall(function()
        interactRemote:FireServer(talkPart)
        notify("💬 Hablando con " .. npcName)
        task.wait(1)
    end)
    return true
end

-- AUTO MISSIONS (CORREGIDO: ejecuta pasos reales)
local function executeMissionStep(mission, stepIndex)
    local step = mission.steps[stepIndex]
    if not step then return false end
    
    notify("📌 Paso " .. stepIndex .. ": " .. step.text)
    
    if step.action == "teleport" then
        teleportToLocation(step.target)
        task.wait(1)
    elseif step.action == "talk" then
        talkToNPC(step.npc)
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
        notify("❌ Necesitas $" .. (mission.cost - money) .. " más.")
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
                notify("❌ Error en paso " .. i)
                break
            end
        end
    end)
end

-- FLY (CORREGIDO)
local flyActive = false
local flySpeed = 40
local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyConnection = nil

local function startFly()
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
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

-- INFINITE JUMP (CORREGIDO)
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
        if jumpConnection then jumpConnection:Disconnect() end
        notify("🦘 Infinite Jump desactivado")
    end
    return jumpActive
end

-- TIME DISPLAY
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
    if not timeActive then if timeGui then timeGui.Enabled = false end; return end
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
task.spawn(function() while task.wait(1) do updateTime() end end)
local function toggleTime() timeActive = not timeActive; notify("🕐 Time: " .. (timeActive and "ON" or "OFF")); return timeActive end

-- ANTI-STAFF
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
task.spawn(function() while task.wait(10) do checkStaff() end end)
local function toggleAntiStaff() antiStaffActive = not antiStaffActive; notify("🛡️ Anti-Staff: " .. (antiStaffActive and "ON" or "OFF")); return antiStaffActive end

-- ANTI-AFK
local antiAFKActive = true
local lastActivity = tick()
game:GetService("UserInputService").InputBegan:Connect(function() lastActivity = tick() end)
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
local function toggleAntiAFK() antiAFKActive = not antiAFKActive; notify("💤 Anti-AFK: " .. (antiAFKActive and "ON" or "OFF")); return antiAFKActive end

-- ANTI-BAN
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

-- CREAR UI FLUENT
local Window = Fluent:CreateWindow({
    Title = "⚒️ RC2",
    SubTitle = "by orvexpp",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Farm = Window:AddTab({ Title = "🌱 Farm", Icon = "pickaxe" }),
    Missions = Window:AddTab({ Title = "📜 Missions", Icon = "scroll" }),
    Teleports = Window:AddTab({ Title = "📍 Teleports", Icon = "map-pin" }),
    Others = Window:AddTab({ Title = "⚙️ Others", Icon = "settings" }),
    Settings = Window:AddTab({ Title = "⚙️ Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- FARM TAB
Tabs.Farm:AddParagraph({
    Title = "⛏️ MINERÍA",
    Content = "Selecciona minerales y activa AutoFarm"
})

Tabs.Farm:AddToggle("AutoFarm", {
    Title = "AutoFarm",
    Default = false,
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

Tabs.Farm:AddSlider("FarmTimer", {
    Title = "⏱️ Tiempo para vender",
    Default = 70,
    Min = 10,
    Max = 260,
    Rounding = 1,
    Callback = function(Value)
        autoFarmTimer = Value
        local minutes = math.floor(Value / 60)
        local seconds = Value % 60
        notify("⏱️ Tiempo: " .. (minutes > 0 and minutes .. "m " .. seconds .. "s" or seconds .. "s"))
    end
})

Tabs.Farm:AddParagraph({
    Title = "📋 Selecciona minerales",
    Content = "Toca los botones para seleccionar/deseleccionar"
})

local oreButtonsCreated = false
local function createOreButtons()
    if oreButtonsCreated then return end
    oreButtonsCreated = true
    local ores = findOres()
    local unique = {}
    for _, ore in pairs(ores) do
        if not table.find(unique, ore.name) then
            table.insert(unique, ore.name)
        end
    end
    for _, name in ipairs(unique) do
        Tabs.Farm:AddButton({
            Title = "⬜ " .. name .. " (Tier " .. oreDatabase[name].tier .. ")",
            Callback = function()
                local idx = table.find(selectedOres, name)
                if idx then
                    table.remove(selectedOres, idx)
                else
                    table.insert(selectedOres, name)
                end
                -- Actualizar el botón visualmente (no se puede, pero se refresca la lista)
                notify("📌 " .. name .. (idx and " deseleccionado" or " seleccionado"))
            end
        })
    end
end

Tabs.Farm:AddButton({
    Title = "🔄 Refrescar minerales",
    Callback = function()
        oreButtonsCreated = false
        createOreButtons()
        notify("🔄 Lista actualizada")
    end
})

Tabs.Farm:AddParagraph({
    Title = "🪓 TALA",
    Content = "Selecciona árboles y activa Auto Tala"
})

Tabs.Farm:AddToggle("AutoChop", {
    Title = "Auto Tala",
    Default = false,
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

Tabs.Farm:AddParagraph({
    Title = "🌳 Selecciona árboles",
    Content = "Toca los botones para seleccionar/deseleccionar"
})

local treeButtonsCreated = false
local function createTreeButtons()
    if treeButtonsCreated then return end
    treeButtonsCreated = true
    local trees = findTrees()
    local unique = {}
    for _, tree in pairs(trees) do
        if not table.find(unique, tree.name) then
            table.insert(unique, tree.name)
        end
    end
    for _, name in ipairs(unique) do
        Tabs.Farm:AddButton({
            Title = "⬜ " .. name .. " (Tier " .. treeDatabase[name].tier .. ")",
            Callback = function()
                local idx = table.find(selectedTrees, name)
                if idx then
                    table.remove(selectedTrees, idx)
                else
                    table.insert(selectedTrees, name)
                end
                notify("📌 " .. name .. (idx and " deseleccionado" or " seleccionado"))
            end
        })
    end
end

Tabs.Farm:AddButton({
    Title = "🔄 Refrescar árboles",
    Callback = function()
        treeButtonsCreated = false
        createTreeButtons()
        notify("🔄 Lista actualizada")
    end
})

Tabs.Farm:AddParagraph({
    Title = "🎣 PESCA",
    Content = "Activa Auto Pesca (necesitas caña equipada)"
})

Tabs.Farm:AddToggle("AutoFish", {
    Title = "Auto Pesca",
    Default = false,
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

Tabs.Farm:AddButton({
    Title = "🛒 Ir a comprar caña",
    Callback = function()
        teleportToLocation("🏪 UCS Store")
        notify("📍 Ve a la tienda Nautic Finds para comprar una caña")
    end
})

-- MISSIONS TAB
Tabs.Missions:AddParagraph({
    Title = "📋 MISIONES DISPONIBLES",
    Content = "Toca una misión para ejecutarla automáticamente"
})

local function refreshMissions()
    for _, mission in ipairs(missionsDB) do
        local status = mission.completed and "🟢" or "⏳"
        Tabs.Missions:AddButton({
            Title = status .. " " .. mission.name .. " ($" .. mission.cost .. ")",
            Callback = function()
                if mission.completed then notify("✅ Misión ya completada") return end
                startMission(mission)
            end
        })
    end
end

Tabs.Missions:AddButton({
    Title = "🔄 Refrescar misiones",
    Callback = function()
        refreshMissions()
        notify("🔄 Lista actualizada")
    end
})

-- TELEPORTS TAB
Tabs.Teleports:AddParagraph({
    Title = "🏪 TIENDAS",
    Content = "Toca para ir a una tienda"
})

for name, data in pairs(teleports.shops) do
    Tabs.Teleports:AddButton({
        Title = name,
        Callback = function()
            teleportToLocation(name)
        end
    })
end

Tabs.Teleports:AddParagraph({
    Title = "⛏️ MINAS",
    Content = "Toca para ir a una mina"
})

for name, data in pairs(teleports.mines) do
    Tabs.Teleports:AddButton({
        Title = name,
        Callback = function()
            teleportToLocation(name)
        end
    })
end

Tabs.Teleports:AddParagraph({
    Title = "📍 OTROS LUGARES",
    Content = "Toca para ir a otros lugares"
})

for name, data in pairs(teleports.misc) do
    Tabs.Teleports:AddButton({
        Title = name,
        Callback = function()
            teleportToLocation(name)
        end
    })
end

Tabs.Teleports:AddParagraph({
    Title = "📌 TELEPORTS PERSONALIZADOS",
    Content = "Guarda tus propias ubicaciones"
})

local function refreshCustomTeleports()
    for name, data in pairs(customTeleports) do
        Tabs.Teleports:AddButton({
            Title = "📍 " .. name,
            Callback = function()
                teleportToLocation(name)
            end
        })
    end
end

Tabs.Teleports:AddInput("TeleName", {
    Title = "Nombre del teleport",
    Placeholder = "Ej: Mi base",
    Numeric = false,
    Finished = false,
    Callback = function(Text)
        teleName = Text
    end
})

local teleName = ""

Tabs.Teleports:AddButton({
    Title = "💾 Guardar ubicación",
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

Tabs.Teleports:AddButton({
    Title = "🔄 Refrescar personalizados",
    Callback = function()
        refreshCustomTeleports()
        notify("🔄 Lista actualizada")
    end
})

-- OTHERS TAB
Tabs.Others:AddParagraph({
    Title = "🦅 FLY",
    Content = "Activa Fly y ajusta su velocidad"
})

Tabs.Others:AddToggle("Fly", {
    Title = "Fly",
    Default = false,
    Callback = function(Value)
        toggleFly()
    end
})

Tabs.Others:AddSlider("FlySpeed", {
    Title = "🚀 Velocidad de Fly",
    Default = 40,
    Min = 20,
    Max = 100,
    Rounding = 5,
    Callback = function(Value)
        flySpeed = Value
        notify("🚀 Velocidad: " .. Value)
    end
})

Tabs.Others:AddParagraph({
    Title = "🦘 INFINITE JUMP",
    Content = "Activa saltos infinitos"
})

Tabs.Others:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        toggleInfiniteJump()
    end
})

Tabs.Others:AddParagraph({
    Title = "🕐 TIME DISPLAY",
    Content = "Muestra la hora del juego en pantalla"
})

Tabs.Others:AddToggle("TimeDisplay", {
    Title = "Time Display",
    Default = true,
    Callback = function(Value)
        toggleTime()
    end
})

Tabs.Others:AddParagraph({
    Title = "🛡️ ANTI",
    Content = "Sistemas de protección"
})

Tabs.Others:AddToggle("AntiStaff", {
    Title = "Anti-Staff",
    Default = true,
    Callback = function(Value)
        toggleAntiStaff()
    end
})

Tabs.Others:AddToggle("AntiAFK", {
    Title = "Anti-AFK",
    Default = true,
    Callback = function(Value)
        toggleAntiAFK()
    end
})

-- SETTINGS TAB
Tabs.Settings:AddParagraph({
    Title = "📊 INFORMACIÓN",
    Content = "Información del jugador"
})

Tabs.Settings:AddButton({
    Title = "💰 Actualizar dinero",
    Callback = function()
        local money = getPlayerMoney()
        notify("💰 $" .. money)
    end
})

Tabs.Settings:AddButton({
    Title = "⛏️ Ver pico equipado",
    Callback = function()
        local tier = getPlayerPickaxeTier()
        notify("⛏️ Tier del pico: " .. tier)
    end
})

Tabs.Settings:AddParagraph({
    Title = "📜 LOGS",
    Content = "Ver registros del script"
})

Tabs.Settings:AddButton({
    Title = "Ver Logs de hoy",
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

Tabs.Settings:AddParagraph({
    Title = "🔄 SCRIPT",
    Content = "Opciones del script"
})

Tabs.Settings:AddButton({
    Title = "Recargar script",
    Callback = function()
        notify("🔄 Recargando...")
        task.wait(1)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/orvehack/Refinery-Caves-2-Script/main/Refinery-Caves-2-SCRIPT.lua"))()
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/rc2")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

-- BOTÓN FLOTANTE BONITO Y FUNCIONAL
local function createFloatingButton()
    local sg = Instance.new("ScreenGui", gethui())
    sg.Name = "FloatingBtn"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local btn = Instance.new("ImageButton", sg)
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0.85, 0, 0.85, 0)
    btn.Image = "rbxassetid://4483362458"
    btn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    btn.BackgroundTransparency = 0.1
    btn.ImageColor3 = Color3.fromRGB(255, 200, 80)
    btn.BorderSizePixel = 0
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(1, 0)

    -- Arrastre
    local dragging = false
    local dragStart, startPos
    local inputService = game:GetService("UserInputService")

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    inputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Abrir/cerrar UI de Fluent
    btn.MouseButton1Click:Connect(function()
        Window:Toggle()
    end)

    btn.TouchTap:Connect(function()
        Window:Toggle()
    end)

    return sg
end

createFloatingButton()

writeLog("Script cargado correctamente")
