-- ========================================================
-- VeraXS Hub v2 - MAC ULTRA FİNAL PRO SÜRÜMÜ
-- ========================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")

-- Eski sürümlerden kalan arayüzleri temizle
if game.CoreGui:FindFirstChild("VeraMinimalGui") then
    game.CoreGui.VeraMinimalGui:Destroy()
end

-- ========================================================
-- 1. ENJEKSİYON VE ÇÖKME KORUMALI SADE ARAYÜZ
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VeraMinimalGui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 190)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0) -- Sol üste sabitleyerek ekran katmanını rahatlatır
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(175, 25, 255) -- Menü çerçevesi VeraXS Moru
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "  VeraXS Hub v2 Pro"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local AimbotEnabled = false
local TriggerbotEnabled = false
local EspEnabled = false

local function CreateMenuButton(text, positionY, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 35)
    Button.Position = UDim2.new(0, 10, 0, positionY)
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Button.TextColor3 = Color3.fromRGB(255, 85, 85)
    Button.Text = text .. " [KAPALI]"
    Button.TextSize = 12
    Button.Font = Enum.Font.SourceSansBold
    Button.BorderSizePixel = 1
    Button.BorderColor3 = Color3.fromRGB(65, 65, 65)
    Button.Parent = MainFrame
    
    local state = false
    Button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Button.BackgroundColor3 = Color3.fromRGB(45, 65, 45)
            Button.TextColor3 = Color3.fromRGB(85, 255, 85)
            Button.Text = text .. " [AÇIK]"
        else
            Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Button.TextColor3 = Color3.fromRGB(255, 85, 85)
            Button.Text = text .. " [KAPALI]"
        end
        callback(state)
    end)
end

CreateMenuButton("Auto Aim (Kesin Kilit)", 45, function(status) AimbotEnabled = status end)
CreateMenuButton("Triggerbot (Anında Sık)", 90, function(status) TriggerbotEnabled = status end)
CreateMenuButton("ESP (Kalın Duvar Arkası)", 135, function(status) 
    EspEnabled = status 
    if not status then
        for _, v in ipairs(game.CoreGui:GetChildren()) do
            if string.find(v.Name, "_VeraESP") then v:Destroy() end
        end
    end
end)

-- ========================================================
-- 2. GELİŞMİŞ HIZLI HEDEF BULUCU
-- ========================================================
local function GetClosestPlayer()
    local ClosestTarget = nil
    local ShortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            -- Mac sisteminde çökmeyi engellemek için sadece görüş alanındaki veya yakınındaki aktif hedeflere odaklanır
            local Distance = (Camera.CFrame.Position - player.Character.Head.Position).magnitude
            if Distance < ShortestDistance then
                ShortestDistance = Distance
                ClosestTarget = player
            end
        end
    end
    return ClosestTarget
end

-- ========================================================
-- 3. YÜKSEK HIZLI VE ÇÖKME KORUMALI ENJEKSİYON MOTORU
-- ========================================================
RunService.RenderStepped:Connect(function()
    
    -- [AIMBOT MOTORU] - Kesin ve Anlık Kilitlenme
    if AimbotEnabled then
        local TargetPlayer = GetClosestPlayer()
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") then
            -- Kamerayı doğrudan ve anında düşmanın kafasına odaklar (Asla sekmez)
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, TargetPlayer.Character.Head.Position)
        end
    end

    -- [TRIGGERBOT MOTORU] - Sıfır Gecikmeli Seri Atış
    if TriggerbotEnabled and Mouse.Target then
        local TargetModel = Mouse.Target:FindAncestorOfClass("Model")
        if TargetModel then
            local HitPlayer = Players:GetPlayerFromCharacter(TargetModel)
            if HitPlayer and HitPlayer ~= LocalPlayer and TargetModel:FindFirstChild("Humanoid") and TargetModel.Humanoid.Health > 0 then
                local Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if Tool then
                    Tool:Activate() -- Sıfır gecikmeyle anında mermiyi ateşler
                end
            end
        end
    end
    
    -- [ESP MOTORU] - Kalın, Belirgin ve Duvar Arkası Gösteren 2D Çerçeve
    if EspEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local RootPart = player.Character.HumanoidRootPart
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
                
                local EspFolderName = player.Name .. "_VeraESP"
                local ExistingEsp = game.CoreGui:FindFirstChild(EspFolderName)
                
                -- Duvar arkasındayken de görünmesi için OnScreen kontrolünü sadece boyutlandırmada kullanıyoruz
                if not ExistingEsp then
                    local BoxGui = Instance.new("ScreenGui")
                    BoxGui.Name = EspFolderName
                    BoxGui.Parent = game.CoreGui
                    BoxGui.ResetOnSpawn = false
                    
                    local Box = Instance.new("Frame")
                    Box.Name = "Box"
                    Box.BackgroundTransparency = 1
                    Box.BorderSizePixel = 4 -- Çizgi kalınlığı 4 piksele çıkarıldı (Çok belirgin)
                    Box.BorderColor3 = Color3.fromRGB(175, 25, 255) -- Canlı mor renk
                    Box.Parent = BoxGui
                end
                
                local BoxGui = game.CoreGui:FindFirstChild(EspFolderName)
                if BoxGui and BoxGui:FindFirstChild("Box") then
                    local Box = BoxGui.Box
                    local Distance = (Camera.CFrame.Position - RootPart.Position).magnitude
                    
                    -- Oyuncu mesafesine göre kutu boyutunu hesaplar
                    local SizeX = 2200 / Distance
                    local SizeY = 3600 / Distance
                    
                    -- Duvar arkasında olsa bile kutunun ekranda kalmasını ve takip etmesini sağlar
                    Box.Visible = true
                    Box.Size = UDim2.new(0, SizeX, 0, SizeY)
                    Box.Position = UDim2.new(0, ScreenPos.X - (SizeX / 2), 0, ScreenPos.Y - (SizeY / 2))
                end
            else
                -- Karakter öldüğünde veya oyundan çıktığında kutusunu hemen sil (Çökmeyi önleyen en kritik parça)
                local EspFolderName = player.Name .. "_VeraESP"
                if game.CoreGui:FindFirstChild(EspFolderName) then
                    game.CoreGui[EspFolderName]:Destroy()
                end
            end
        end
    end
end)
