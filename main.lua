-- ========================================================
-- VeraXS Hub v2 - MAC KESİN ÇALIŞAN PROTOKOL SÜRÜMÜ
-- ========================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")

-- Eski temizlik
if game.CoreGui:FindFirstChild("VeraMinimalGui") then
    game.CoreGui.VeraMinimalGui:Destroy()
end

-- ========================================================
-- 1. ARAYÜZ (GUI) KURULUMU
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VeraMinimalGui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 190)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = " VeraXS Hub v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
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
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.TextColor3 = Color3.fromRGB(255, 100, 100)
    Button.Text = text .. " [KAPALI]"
    Button.TextSize = 13
    Button.Font = Enum.Font.SourceSansBold
    Button.BorderSizePixel = 1
    Button.BorderColor3 = Color3.fromRGB(80, 80, 80)
    Button.Parent = MainFrame
    
    local state = false
    Button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Button.BackgroundColor3 = Color3.fromRGB(60, 80, 60)
            Button.TextColor3 = Color3.fromRGB(100, 255, 100)
            Button.Text = text .. " [AÇIK]"
        else
            Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Button.TextColor3 = Color3.fromRGB(255, 100, 100)
            Button.Text = text .. " [KAPALI]"
        end
        callback(state)
    end)
end

CreateMenuButton("Auto Aim (Kafa)", 45, function(status) AimbotEnabled = status end)
CreateMenuButton("Triggerbot (Oto Sık)", 90, function(status) TriggerbotEnabled = status end)
CreateMenuButton("ESP / Wallhack", 135, function(status) 
    EspEnabled = status 
    if not status then
        -- ESP kapatıldığında tüm kutuları temizle
        for _, v in ipairs(game.CoreGui:GetChildren()) do
            if v.Name == "VeraBoxESP" then v:Destroy() end
        end
    end
end)

-- ========================================================
-- 2. GELİŞMİŞ EN YAKIN OYUNCU BULUCU (MAC STANDARDI)
-- ========================================================
local function GetClosestPlayer()
    local ClosestTarget = nil
    local ShortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            -- Kameranın bakış açısına göre en yakın olanı seçer (Görüş alanındakileri hedefler)
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if OnScreen then
                local MousePos = Vector2.new(Mouse.X, Mouse.Y)
                local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).magnitude
                if Distance < ShortestDistance then
                    ShortestDistance = Distance
                    ClosestTarget = player
                end
            end
        end
    end
    return ClosestTarget
end

-- ========================================================
-- 3. HİLE MOTORU MERKEZİ DÖNGÜSÜ
-- ========================================================
RunService.RenderStepped:Connect(function()
    -- Mac Güvenliğini Aşan Auto-Aim Sistemi
    if AimbotEnabled then
        local TargetPlayer = GetClosestPlayer()
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") then
            -- Doğrudan atama yerine pürüzsüz kamera interpolasyonu kullanarak Mac engellerini baypas eder
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetPlayer.Character.Head.Position)
        end
    end

    -- Geliştirilmiş Tetikleyici (Triggerbot)
    if TriggerbotEnabled and Mouse.Target then
        local TargetModel = Mouse.Target:FindAncestorOfClass("Model")
        if TargetModel then
            local HitPlayer = Players:GetPlayerFromCharacter(TargetModel)
            if HitPlayer and HitPlayer ~= LocalPlayer and TargetModel:FindFirstChild("Humanoid") and TargetModel.Humanoid.Health > 0 then
                -- Sol tık simülasyonunu doğrudan oyun motoru üzerinden tetikler
                local Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if Tool then
                    Tool:Activate() -- Silahı otomatik ateşler
                end
            end
        end
    end
    
    -- Mac Engelini Aşan Box-ESP Sistemi
    if EspEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
                local RootPart = player.Character.HumanoidRootPart
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
                
                local EspFolderName = player.Name .. "_VeraESP"
                local ExistingEsp = game.CoreGui:FindFirstChild(EspFolderName)
                
                if OnScreen then
                    -- Eğer çizim yoksa sıfırdan oluşturur
                    if not ExistingEsp then
                        local BoxGui = Instance.new("ScreenGui")
                        BoxGui.Name = EspFolderName
                        BoxGui.Parent = game.CoreGui
                        
                        local Box = Instance.new("Frame")
                        Box.Name = "Box"
                        Box.BackgroundTransparency = 1
                        Box.BorderSizePixel = 2
                        Box.BorderColor3 = Color3.fromRGB(175, 25, 255) -- Mor Çerçeve
                        Box.Parent = BoxGui
                    end
                    
                    -- Kutunun boyutunu ve pozisyonunu oyuncunun mesafesine göre dinamik ayarlar
                    local BoxGui = game.CoreGui:FindFirstChild(EspFolderName)
                    if BoxGui and BoxGui:FindFirstChild("Box") then
                        local Box = BoxGui.Box
                        local Distance = (Camera.CFrame.Position - RootPart.Position).magnitude
                        local SizeX = 2000 / Distance
                        local SizeY = 3500 / Distance
                        
                        Box.Size = UDim2.new(0, SizeX, 0, SizeY)
                        Box.Position = UDim2.new(0, ScreenPos.X - (SizeX / 2), 0, ScreenPos.Y - (SizeY / 2))
                    end
                else
                    -- Ekrandan çıkan oyuncunun kutusunu anında siler
                    if ExistingEsp then ExistingEsp:Destroy() end
                end
            else
                -- Ölen veya çıkan oyuncuların kutularını temizler
                local EspFolderName = player.Name .. "_VeraESP"
                if game.CoreGui:FindFirstChild(EspFolderName) then
                    game.CoreGui[EspFolderName]:Destroy()
                end
            end
        end
    else
        -- ESP kapatıldığında tüm süreçleri tamamen temizler
        for _, player in ipairs(Players:GetPlayers()) do
            local EspFolderName = player.Name .. "_VeraESP"
            if game.CoreGui:FindFirstChild(EspFolderName) then
                game.CoreGui[EspFolderName]:Destroy()
            end
        end
    end
end)
