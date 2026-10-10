-- ========================================================
-- VeraXS Hub v3 - WINDOWS, ANDROID & MAC UYUMLU MULTI SÜRÜM
-- Menüyü Gizlemek/Açmak İçin Klavyeden "H" Tuşuna Basın!
-- ========================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- Tüm platformlarda eski arayüz kalıntılarını güvenle temizleme
local TargetGuiParent = game:GetService("CoreGui")
if not pcall(function() local a = game.CoreGui.Name end) then
    TargetGuiParent = LocalPlayer:WaitForChild("PlayerGui")
end

if TargetGuiParent:FindFirstChild("VeraCrossGui") then
    TargetGuiParent.VeraCrossGui:Destroy()
end

-- ========================================================
-- 1. SAĞ ORTA SABİT EVRENSEL ARAYÜZ (GUI)
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VeraCrossGui"
ScreenGui.Parent = TargetGuiParent
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 190)
MainFrame.AnchorPoint = Vector2.new(1, 0.5) 
MainFrame.Position = UDim2.new(0.98, 0, 0.5, 0) -- Sağ orta sabit
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(175, 25, 255) -- VeraXS Moru
MainFrame.Active = false
MainFrame.Draggable = false
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "  VeraXS Hub v3 [H Tuşu]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- PC'ler için H tuşu ile gizleme özelliği
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
CreateMenuButton("ESP (Tüm Cihazlar)", 135, function(status) 
    EspEnabled = status 
    if not status then
        -- ESP kapatıldığında tüm haritadaki morlukları temizler
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("VeraHighlight") then
                player.Character.VeraHighlight:Destroy()
            end
        end
    end
end)

-- ========================================================
-- 2. DÜNYA GENELİ EN YAKIN HEDEF BULUCU
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
-- 3. EVRENSEL ÇAPRAZ PLATFORM HİLE DÖNGÜSÜ
-- ========================================================
RunService.RenderStepped:Connect(function()
    
    -- [AIMBOT] - Çalışan Kilit Sistemi Korundu
    if AimbotEnabled then
        local TargetPlayer = GetClosestPlayer()
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, TargetPlayer.Character.Head.Position)
        end
    end

    -- [EVRENSEL TRIGGERBOT] - Windows, Mobil ve Mac Hibrit Ateşleyici
    if TriggerbotEnabled and Mouse.Target then
        local TargetModel = Mouse.Target:FindAncestorOfClass("Model")
        if TargetModel then
            local HitPlayer = Players:GetPlayerFromCharacter(TargetModel)
            if HitPlayer and HitPlayer ~= LocalPlayer and TargetModel:FindFirstChild("Humanoid") and TargetModel.Humanoid.Health > 0 then
                -- Cihaz türüne göre en hızlı ateş etme metodunu seçer
                if mouse1press and mouse1release then
                    -- Windows & Bazı Güçlü Executorlar İçin Hızlı Tıklama
                    mouse1press()
                    task.wait(0.01)
                    mouse1release()
                elseif VirtualUser then
                    -- Android ve Mac Emulator Sinyali ile Hızlı Tıklama
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(0, 0))
                end
                
                -- Yedekleme Güvenliği: Eğer ikisi de çalışmazsa silahı oyun içinden tetikler
                local Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if Tool then
                    Tool:Activate()
                end
            end
        end
    end
    
    -- [EVRENSEL GÜÇLÜ ESP] - Duvar Arkası Kalın Belirgin Highlight
    if EspEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local Char = player.Character
                if not Char:FindFirstChild("VeraHighlight") then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Name = "VeraHighlight"
                    Highlight.FillColor = Color3.fromRGB(175, 25, 255) -- Neon Canlı Mor
                    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Parlak Beyaz
                    Highlight.FillTransparency = 0.35 -- Çok daha belirgin opaklık
                    Highlight.OutlineTransparency = 0
                    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Kesin Duvar Arkası Gösterimi
                    Highlight.Parent = Char
                end
            else
                -- Ölenlerin veya çıkanların mor çizgilerini temizle
                if player.Character and player.Character:FindFirstChild("VeraHighlight") then
                    player.Character.VeraHighlight:Destroy()
                end
            end
        end
    end
end)
