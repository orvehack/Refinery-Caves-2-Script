-- ============================================================
-- RC2 LITE - VERSIÓN ESTABLE PARA DELTA
-- ============================================================

-- 1. CONFIGURACIÓN DE CARPETAS
local folder = "rc2_data"
if not isfolder(folder) then makefolder(folder) end

-- 2. NOTIFICACIONES SIMPLES Y BONITAS
local function notify(text, duration)
    duration = duration or 3
    local sg = Instance.new("ScreenGui", gethui())
    sg.Name = "Notify"
    sg.ResetOnSpawn = false
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.8, 0, 0, 50)
    frame.Position = UDim2.new(0.1, 0, 0.8, 0)
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
end

-- 3. BOTÓN FLOTANTE (MOVIBLE Y CON ESTILO)
local function createFloatingButton()
    local sg = Instance.new("ScreenGui", gethui())
    sg.Name = "FloatingBtn"
    sg.ResetOnSpawn = false

    local btn = Instance.new("ImageButton", sg)
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0.85, 0, 0.85, 0)
    btn.Image = "rbxassetid://6031091779" -- Icono de engranaje bonito
    btn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    btn.BackgroundTransparency = 0.1
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(1, 0)

    -- Hacer el botón arrastrable (táctil)
    local dragging = false
    local dragStart, startPos
    btn.TouchBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    btn.TouchMoved:Connect(function(input)
        if dragging then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    btn.TouchEnded:Connect(function() dragging = false end)

    -- Al presionar, abrir la GUI (si no está abierta)
    local mainGui = nil
    local guiOpen = false

    btn.TouchTap:Connect(function()
        if not mainGui then
            mainGui = createMainGUI(btn)
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

-- 4. GUI PRINCIPAL (SENCILLA, CON PESTAÑAS)
local function createMainGUI(floatingBtn)
    local sg = Instance.new("ScreenGui", gethui())
    sg.Name = "MainGUI"
    sg.ResetOnSpawn = false
    sg.Enabled = false

    -- Fondo semi-transparente
    local backdrop = Instance.new("Frame", sg)
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.5
    backdrop.Active = true
    backdrop.TouchTap:Connect(function()
        sg.Enabled = false
        notify("GUI cerrada", 2)
    end)

    -- Ventana principal
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.9, 0, 0.8, 0)
    frame.Position = UDim2.new(0.05, 0, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 22, 35)
    frame.BackgroundTransparency = 0.1
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 16)

    -- Título
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "⚙️ RC2 LITE"
    title.TextColor3 = Color3.fromRGB(255, 200, 80)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1

    -- Pestañas
    local tabFrame = Instance.new("Frame", frame)
    tabFrame.Size = UDim2.new(1, 0, 0, 40)
    tabFrame.Position = UDim2.new(0, 0, 0, 45)
    tabFrame.BackgroundTransparency = 1

    local tabs = {}
    local contents = {}

    local function createTab(name, content)
        local btn = Instance.new("TextButton", tabFrame)
        btn.Size = UDim2.new(0.33, 0, 1, 0)
        btn.Position = UDim2.new(#tabs * 0.33, 0, 0, 0)
        btn.Text = name
        btn.TextScaled = true
        btn.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
        btn.BackgroundTransparency = 0.2
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 8)
        table.insert(tabs, btn)
        return btn
    end

    -- Contenido
    local contentFrame = Instance.new("ScrollingFrame", frame)
    contentFrame.Size = UDim2.new(1, 0, 1, -100)
    contentFrame.Position = UDim2.new(0, 0, 0, 90)
    contentFrame.BackgroundTransparency = 1
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
    contentFrame.ScrollBarThickness = 6

    -- Pestaña 1: Información
    local infoContent = Instance.new("Frame", contentFrame)
    infoContent.Size = UDim2.new(1, 0, 1, 0)
    infoContent.BackgroundTransparency = 1
    infoContent.Visible = true

    local infoLabel = Instance.new("TextLabel", infoContent)
    infoLabel.Size = UDim2.new(0.9, 0, 0, 30)
    infoLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
    infoLabel.Text = "🔍 Script cargado correctamente"
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextScaled = true
    infoLabel.BackgroundTransparency = 1

    local infoLabel2 = Instance.new("TextLabel", infoContent)
    infoLabel2.Size = UDim2.new(0.9, 0, 0, 30)
    infoLabel2.Position = UDim2.new(0.05, 0, 0.15, 0)
    infoLabel2.Text = "📁 Carpeta: " .. folder
    infoLabel2.TextColor3 = Color3.fromRGB(150, 150, 150)
    infoLabel2.TextScaled = true
    infoLabel2.BackgroundTransparency = 1

    local infoLabel3 = Instance.new("TextLabel", infoContent)
    infoLabel3.Size = UDim2.new(0.9, 0, 0, 30)
    infoLabel3.Position = UDim2.new(0.05, 0, 0.25, 0)
    infoLabel3.Text = "🕐 Hora del juego: " .. tostring(game:GetService("Lighting").TimeOfDay or "desconocida")
    infoLabel3.TextColor3 = Color3.fromRGB(150, 150, 150)
    infoLabel3.TextScaled = true
    infoLabel3.BackgroundTransparency = 1

    -- Pestaña 2: Acciones rápidas
    local actionsContent = Instance.new("Frame", contentFrame)
    actionsContent.Size = UDim2.new(1, 0, 1, 0)
    actionsContent.BackgroundTransparency = 1
    actionsContent.Visible = false

    local function createActionButton(text, color, callback)
        local btn = Instance.new("TextButton", actionsContent)
        btn.Size = UDim2.new(0.8, 0, 0, 45)
        btn.Position = UDim2.new(0.1, 0, #actionsContent:GetChildren() * 0.06 + 0.05, 0)
        btn.Text = text
        btn.TextScaled = true
        btn.BackgroundColor3 = color or Color3.fromRGB(50, 70, 100)
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 10)
        btn.TouchTap:Connect(callback)
        return btn
    end

    createActionButton("📌 Guardar ubicación", Color3.fromRGB(0, 150, 100), function()
        local char = game:GetService("Players").LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            local data = {position = {pos.X, pos.Y, pos.Z}, time = os.date("%H:%M:%S")}
            local json = game:GetService("HttpService"):JSONEncode(data)
            writefile(folder .. "/last_pos.json", json)
            notify("📍 Ubicación guardada", 2)
        else
            notify("❌ Personaje no encontrado", 2)
        end
    end)

    createActionButton("📍 Ir a última ubicación", Color3.fromRGB(0, 120, 200), function()
        local file = folder .. "/last_pos.json"
        if isfile(file) then
            local json = readfile(file)
            local data = game:GetService("HttpService"):JSONDecode(json)
            local target = Vector3.new(data.position[1], data.position[2], data.position[3])
            local char = game:GetService("Players").LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local steps = 8
                local start = hrp.Position
                for i = 1, steps do
                    local progress = i / steps
                    local inter = start + (target - start) * progress
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then hum:MoveTo(inter) end
                    task.wait(0.08)
                end
                notify("📍 Teletransportado", 2)
            else
                notify("❌ Personaje no encontrado", 2)
            end
        else
            notify("❌ No hay ubicación guardada", 2)
        end
    end)

    createActionButton("🔄 Recargar script", Color3.fromRGB(200, 150, 50), function()
        notify("🔄 Recargando...", 2)
        task.wait(0.5)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/orvehack/Refinery-Caves-2-Script/main/RC2_Lite.lua"))()
    end)

    -- Cambio de pestañas
    local function switchTab(tab, content)
        for _, t in ipairs(tabs) do
            t.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
        end
        tab.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        infoContent.Visible = (content == infoContent)
        actionsContent.Visible = (content == actionsContent)
    end

    local tab1 = createTab("Info", infoContent)
    local tab2 = createTab("Acciones", actionsContent)

    tab1.TouchTap:Connect(function() switchTab(tab1, infoContent) end)
    tab2.TouchTap:Connect(function() switchTab(tab2, actionsContent) end)

    -- Cerrar la GUI con el botón X
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

-- 5. INICIALIZACIÓN
notify("🚀 RC2 LITE cargado", 3)
createFloatingButton()
notify("📌 Toca el engranaje para abrir la GUI", 3)

print("✅ RC2 LITE cargado correctamente")
print("📁 Carpeta: " .. folder)
