-- ============================================================
-- RC2 STABLE - VERSIÓN QUE FUNCIONA EN DELTA
-- ============================================================

-- 1. FUNCIÓN DE NOTIFICACIÓN (CON ESTILO)
local function notify(text, duration)
    duration = duration or 3
    local sg = Instance.new("ScreenGui", gethui())
    sg.Name = "Notify"
    sg.ResetOnSpawn = false
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.8, 0, 0, 50)
    frame.Position = UDim2.new(0.1, 0, 0.8, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
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

-- 2. CREAR BOTÓN FLOTANTE (USANDO UserInputService)
local function createFloatingButton()
    local sg = Instance.new("ScreenGui", gethui())
    sg.Name = "FloatingBtn"
    sg.ResetOnSpawn = false

    local btn = Instance.new("ImageButton", sg)
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0.85, 0, 0.85, 0)
    btn.Image = "rbxassetid://6031091779"
    btn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    btn.BackgroundTransparency = 0.1
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(1, 0)

    -- Variables para arrastre
    local dragging = false
    local dragStart, startPos
    local inputService = game:GetService("UserInputService")

    -- ARRASTRE: Usando UserInputService (FUNCIONA EN DELTA)
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

    -- ABRIR GUI: Usando TouchTap o MouseButton1Click
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

    -- También para táctil
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

-- 3. GUI PRINCIPAL
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
    frame.Size = UDim2.new(0.9, 0, 0.7, 0)
    frame.Position = UDim2.new(0.05, 0, 0.15, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 22, 35)
    frame.BackgroundTransparency = 0.1
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 16)

    -- Título
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "⚙️ RC2 STABLE"
    title.TextColor3 = Color3.fromRGB(255, 200, 80)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1

    -- Info
    local infoLabel = Instance.new("TextLabel", frame)
    infoLabel.Size = UDim2.new(0.9, 0, 0, 40)
    infoLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
    infoLabel.Text = "✅ Script cargado correctamente"
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextScaled = true
    infoLabel.BackgroundTransparency = 1

    local infoLabel2 = Instance.new("TextLabel", frame)
    infoLabel2.Size = UDim2.new(0.9, 0, 0, 40)
    infoLabel2.Position = UDim2.new(0.05, 0, 0.3, 0)
    infoLabel2.Text = "📁 Datos guardados en: rc2_data"
    infoLabel2.TextColor3 = Color3.fromRGB(150, 150, 150)
    infoLabel2.TextScaled = true
    infoLabel2.BackgroundTransparency = 1

    -- Botón de acción: Guardar ubicación
    local saveBtn = Instance.new("TextButton", frame)
    saveBtn.Size = UDim2.new(0.4, 0, 0, 45)
    saveBtn.Position = UDim2.new(0.05, 0, 0.5, 0)
    saveBtn.Text = "💾 Guardar ubicación"
    saveBtn.TextScaled = true
    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    local cornerBtn = Instance.new("UICorner", saveBtn)
    cornerBtn.CornerRadius = UDim.new(0, 10)
    saveBtn.TouchTap:Connect(function()
        local char = game:GetService("Players").LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            local data = {position = {pos.X, pos.Y, pos.Z}, time = os.date("%H:%M:%S")}
            local json = game:GetService("HttpService"):JSONEncode(data)
            if not isfolder("rc2_data") then makefolder("rc2_data") end
            writefile("rc2_data/last_pos.json", json)
            notify("📍 Ubicación guardada", 2)
        else
            notify("❌ Personaje no encontrado", 2)
        end
    end)

    -- Botón de acción: Ir a ubicación guardada
    local goBtn = Instance.new("TextButton", frame)
    goBtn.Size = UDim2.new(0.4, 0, 0, 45)
    goBtn.Position = UDim2.new(0.55, 0, 0.5, 0)
    goBtn.Text = "📍 Ir a ubicación"
    goBtn.TextScaled = true
    goBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    local cornerBtn2 = Instance.new("UICorner", goBtn)
    cornerBtn2.CornerRadius = UDim.new(0, 10)
    goBtn.TouchTap:Connect(function()
        local file = "rc2_data/last_pos.json"
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

    -- Botón cerrar
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

-- 4. INICIALIZACIÓN
notify("🚀 RC2 STABLE cargado", 3)
createFloatingButton()
notify("📌 Toca el botón flotante", 3)

print("✅ RC2 STABLE cargado correctamente")
