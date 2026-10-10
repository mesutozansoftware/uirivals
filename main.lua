-- ========================================================
-- VeraXS Hub v2 - MAC ÇÖKME ENGELLİ SAĞ ORTA SABİT SÜRÜM
-- Menüyü Açıp Kapatmak / Gizlemek İçin Klavyeden "H" Tuşuna Basın!
-- ========================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Eski hatalı sürümleri tamamen temizle
if game.CoreGui:FindFirstChild("VeraMinimalGui") then
    game.CoreGui.VeraMinimalGui:Destroy()
end

-- ========================================================
-- 1. SAĞ ORTAYA SABİTLENMİŞ ARAYÜZ (GUI)
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VeraMinimalGui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Ana Menü Kutusu (Sağ Ortaya Sabitlendi, Çökmeyi Önlemek İçin Sürükleme Kapatıldı)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 190)
-- AnchorPoint'i (0.5, 0.5) yaparak dikeyde tam ortaladık
MainFrame.AnchorPoint = Vector2.new(1, 0.5) 
-- Ekranın sağ kenarına (X: 0.98) ve dikey ortasına (Y: 0.5) yerleştirildi
MainFrame.Position = UDim2.new(0.98, 0, 0.5, 0) 
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(175, 25, 255) -- VeraXS Moru
MainFrame.Active = false -- Sürükleme kilitli (Çökmeyi önleyen ana ayar)
MainFrame.Draggable = false
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

-- Başlık ve Bilgilendirme
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "  VeraXS Hub v2 [H tuşu]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 11
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- KLAVYE İLE GİZLEME MOTORU ("H" Tuşu Kontrolü)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    if input.KeyCode == Enum.KeyCode.H then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

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
-- 3. HİLE MOTORU MERKEZİ DÖNGÜSÜ
-- ========================================================
RunService.RenderStepped:Connect(function()
    
    -- [AIMBOT MOTORU]
    if AimbotEnabled then
        local TargetPlayer = GetClosestPlayer()
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, TargetPlayer.Character.Head.Position)
        end
    end

    -- [TRIGGERBOT MOTORU]
    if TriggerbotEnabled and Mouse.Target then
        local TargetModel = Mouse.Target:FindAncestorOfClass("Model")
        if TargetModel then
            local HitPlayer = Players:GetPlayerFromCharacter(TargetModel)
            if HitPlayer and HitPlayer ~= LocalPlayer and TargetModel:FindFirstChild("Humanoid") and TargetModel.Humanoid.Health > 0 then
                local Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if Tool then
                    Tool:Activate()
                end
            end
        end
    end
    
    -- [ESP MOTORU]
    if EspEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local RootPart = player.Character.HumanoidRootPart
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
                
                local EspFolderName = player.Name .. "_VeraESP"
                local ExistingEsp = game.CoreGui:FindFirstChild(EspFolderName)
                
                if not ExistingEsp then
                    local BoxGui = Instance.new("ScreenGui")
                    BoxGui.Name = EspFolderName
                    BoxGui.Parent = game.CoreGui
                    BoxGui.ResetOnSpawn = false
                    
                    local Box = Instance.new("Frame")
                    Box.Name = "Box"
                    Box.BackgroundTransparency = 1
                    Box.BorderSizePixel = 4
                    Box.BorderColor3 = Color3.fromRGB(175, 25, 255)
                    Box.Parent = BoxGui
                end
                
                local BoxGui = game.CoreGui:FindFirstChild(EspFolderName)
                if BoxGui and BoxGui:FindFirstChild("Box") then
                    local Box = BoxGui.Box
                    local Distance = (Camera.CFrame.Position - RootPart.Position).magnitude
                    
                    local SizeX = 2200 / Distance
                    local SizeY = 3600 / Distance
                    
                    Box.Visible = true
                    Box.Size = UDim2.new(0, SizeX, 0, SizeY)
                    Box.Position = UDim2.new(0, ScreenPos.X - (SizeX / 2), 0, ScreenPos.Y - (SizeY / 2))
                end
            else
                local EspFolderName = player.Name .. "_VeraESP"
                if game.CoreGui:FindFirstChild("VeraMinimalGui") and game.CoreGui:FindFirstChild(EspFolderName) then
                    game.CoreGui[EspFolderName]:Destroy()
                end
            end
        end
    end
end)
