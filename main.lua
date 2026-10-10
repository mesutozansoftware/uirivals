-- ========================================================
-- VeraXS Hub v2 - MAC İÇİN ULTRA HAFİF MİNİMALİST MENÜ
-- ========================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- Eski hatalı GUI yapılarını temizle
if game.CoreGui:FindFirstChild("VeraMinimalGui") then
    game.CoreGui.VeraMinimalGui:Destroy()
end

-- ========================================================
-- 1. MAC DOSTU TEMEL ARAYÜZ (GUI) KURULUMU
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VeraMinimalGui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Ana Pencere Kartı (Ekranın ortasında sade gri bir kutu)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 190)
MainFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
MainFrame.Active = true
MainFrame.Draggable = true -- Mac Touchpad ile sürüklenebilir
MainFrame.Parent = ScreenGui

-- Başlık
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = " VeraXS Hub v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Durum Değişkenleri
local AimbotEnabled = false
local TriggerbotEnabled = false
local EspEnabled = false

-- Buton Yapıcı Yardımcı Fonksiyon
local function CreateMenuButton(text, positionY, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 35)
    Button.Position = UDim2.new(0, 10, 0, positionY)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.TextColor3 = Color3.fromRGB(255, 100, 100) -- Başlangıçta kırmızı (KAPALI)
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

-- ========================================================
-- 2. MENÜ BUTONLARININ TANIMLANMASI
-- ========================================================

CreateMenuButton("Auto Aim (Kafa)", 45, function(status)
    AimbotEnabled = status
end)

CreateMenuButton("Triggerbot (Oto Sık)", 90, function(status)
    TriggerbotEnabled = status
end)

CreateMenuButton("ESP / Wallhack", 135, function(status)
    EspEnabled = status
    -- ESP kapatıldıysa ekrandaki çizgileri temizle
    if not status then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "VeraHighlight" then v:Destroy() end
        end
    end
end)

-- ========================================================
-- 3. EN YAKIN OYUNCU BULUCU VE HİLE MOTORU
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

-- Mac'in işlemcisini yormayan, saniyede 30 kez dönen güvenli ana döngü
task.spawn(function()
    while true do
        task.wait(0.03)
        
        -- Aimbot Çalışma Mantığı
        if AimbotEnabled then
            local TargetPlayer = GetClosestPlayer()
            if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, TargetPlayer.Character.Head.Position)
            end
        end

        -- Triggerbot Çalışma Mantığı
        if TriggerbotEnabled and Mouse.Target then
            local TargetModel = Mouse.Target:FindAncestorOfClass("Model")
            if TargetModel then
                local HitPlayer = Players:GetPlayerFromCharacter(TargetModel)
                if HitPlayer and HitPlayer ~= LocalPlayer and TargetModel:FindFirstChild("Humanoid") and TargetModel.Humanoid.Health > 0 then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(0, 0))
                end
            end
        end
        
        -- ESP Dinamik Yenileme Mantığı
        if EspEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if not player.Character:FindFirstChild("VeraHighlight") then
                        local Highlight = Instance.new("Highlight")
                        Highlight.Name = "VeraHighlight"
                        Highlight.FillColor = Color3.fromRGB(175, 25, 255)
                        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        Highlight.FillTransparency = 0.4
                        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        Highlight.Parent = player.Character
                    end
                end
            end
        end
    end
end)
