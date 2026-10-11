-- Cargar librería de interfaz (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Keep Hub 🥚",
   LoadingTitle = "Cargando Keep Hub...",
   LoadingSubtitle = "Delta Executor Edition",
   Theme = "Ocean", -- Tema personalizado en tonos azul cielo y gris
   ConfigurationSaving = { Enabled = false }
})

-- Servicios
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Variables de Estado
local AutoCollect = false
local AutoFarmWalk = false
local AutoFarmTP = false
local CollectDelay = 0.25
local MaxDistance = 30
local AntiAFK = true
local Noclip = false
local InfiniteJump = false
local ESPEnabled = false
local ESPHighlights = {}

-- --- BOTÓN FLOTANTE MÓVIL (AZUL CIELO Y GRIS) ---
local ScreenGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

ScreenGui.Name = "KeepHubGui"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 72) -- Gris Oscuro
ToggleBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Text = "KH"
ToggleBtn.TextColor3 = Color3.fromRGB(135, 206, 235) -- Azul Cielo
ToggleBtn.TextSize = 22.000
ToggleBtn.Active = true
ToggleBtn.Draggable = true

UICorner.CornerRadius = UDim.new(0, 25)
UICorner.Parent = ToggleBtn

UIStroke.Parent = ToggleBtn
UIStroke.Color = Color3.fromRGB(135, 206, 235) -- Borde Azul Cielo
UIStroke.Thickness = 2

ToggleBtn.MouseButton1Click:Connect(function()
    Rayfield:Toggle()
end)

-- --- PESTAÑA 1: AUTO FARM ---
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

FarmTab:CreateToggle({
   Name = "Auto-Farm por Teletransporte (Rápido)",
   CurrentValue = false,
   Callback = function(Value)
      AutoFarmTP = Value
   end,
})

FarmTab:CreateToggle({
   Name = "Auto-Farm Caminando (Seguro)",
   CurrentValue = false,
   Callback = function(Value)
      AutoFarmWalk = Value
   end,
})

FarmTab:CreateToggle({
   Name = "Auto-Recolectar Cerca",
   CurrentValue = false,
   Callback = function(Value)
      AutoCollect = Value
   end,
})

FarmTab:CreateSlider({
   Name = "Velocidad de Recolección (Segundos)",
   Range = {0.1, 1},
   Increment = 0.05,
   Suffix = "s",
   CurrentValue = 0.25,
   Callback = function(Value)
      CollectDelay = Value
   end,
})

-- --- PESTAÑA 2: VISUALES (ESP) ---
local VisualTab = Window:CreateTab("Visuales (ESP)", 4483362458)

local function applyESP()
   for _, hl in pairs(ESPHighlights) do
      if hl then hl:Destroy() end
   end
   ESPHighlights = {}

   if not ESPEnabled then return end

   for _, obj in ipairs(Workspace:GetDescendants()) do
      if obj:IsA("BasePart") and obj.Parent then
         local name = string.lower(obj.Parent.Name)
         if string.find(name, "egg") or string.find(name, "huevo") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "KeepHubESP"
            highlight.Adornee = obj.Parent
            highlight.FillColor = Color3.fromRGB(135, 206, 235) -- Azul Cielo
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.3
            highlight.Parent = obj.Parent
            table.insert(ESPHighlights, highlight)
         end
      end
   end
end

VisualTab:CreateToggle({
   Name = "Ver Huevos a través de Paredes (ESP)",
   CurrentValue = false,
   Callback = function(Value)
      ESPEnabled = Value
      applyESP()
   end,
})

VisualTab:CreateButton({
   Name = "🔄 Actualizar Marcadores ESP",
   Callback = function()
      applyESP()
   end,
})

-- --- PESTAÑA 3: MOVIMIENTO Y PERSONAJE ---
local PlayerTab = Window:CreateTab("Movimiento", 4483362458)

PlayerTab:CreateSlider({
   Name = "Velocidad de Caminado (WalkSpeed)",
   Range = {16, 150},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Callback = function(Value)
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

PlayerTab:CreateToggle({
   Name = "Atravesar Paredes (Noclip)",
   CurrentValue = false,
   Callback = function(Value)
      Noclip = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "Salto Infinito (Inf Jump)",
   CurrentValue = false,
   Callback = function(Value)
      InfiniteJump = Value
   end,
})

-- --- PESTAÑA 4: SERVIDOR Y OPTIMIZACIÓN ---
local ServerTab = Window:CreateTab("Servidor & Red", 4483362458)

ServerTab:CreateButton({
   Name = "⚡ Modo Rendimiento (FPS Booster)",
   Callback = function()
      for _, v in pairs(Workspace:GetDescendants()) do
         if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
         elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
         end
      end
   end,
})

ServerTab:CreateButton({
   Name = "🔀 Cambiar de Servidor (Server Hop)",
   Callback = function()
      local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
      for _, server in ipairs(servers) do
         if server.playing < server.maxPlayers and server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
            break
         end
      end
   end,
})

ServerTab:CreateButton({
   Name = "🔄 Reconectar al Mismo Servidor",
   Callback = function()
      TeleportService:Teleport(game.PlaceId, LocalPlayer)
   end,
})

-- --- BUCLES Y EVENTOS EN SEGUNDO PLANO ---

-- 1. Auto Farm por TP
task.spawn(function()
   while true do
      if AutoFarmTP then
         pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
               for _, obj in ipairs(Workspace:GetDescendants()) do
                  if not AutoFarmTP then break end
                  if obj:IsA("ProximityPrompt") and obj.Parent and obj.Parent:IsA("BasePart") then
                     local name = string.lower(obj.Parent.Name)
                     if string.find(name, "egg") or string.find(name, "huevo") then
                        char.HumanoidRootPart.CFrame = obj.Parent.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.1)
                        fireproximityprompt(obj)
                        task.wait(CollectDelay)
                     end
                  end
               end
            end
         end)
      end
      task.wait(0.3)
   end
end)

-- 2. Noclip
RunService.Stepped:Connect(function()
   if Noclip and LocalPlayer.Character then
      for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
         if part:IsA("BasePart") then
            part.CanCollide = false
         end
      end
   end
end)

-- 3. Salto Infinito
UserInputService.JumpRequest:Connect(function()
   if InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
      LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
   end
end)

-- 4. Anti-AFK
LocalPlayer.Idled:Connect(function()
   if AntiAFK then
      VirtualUser:CaptureController()
      VirtualUser:ClickButton2(Vector2.new())
   end
end)

-- Notificación de carga
Rayfield:Notify({
   Title = "Keep Hub Cargado 🥚",
   Content = "¡El script se inició correctamente!",
   Duration = 5,
   Image = 4483362458,
})
