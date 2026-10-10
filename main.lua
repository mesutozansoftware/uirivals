-- ========================================================
-- VeraXS Hub v4.0 - EVRENSEL FARE KİLİTLİ STABİL MOTHERSCRIPT
-- Windows, Android ve Mac üzerinde %100 Çalışır
-- ========================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local TargetGuiParent = game:GetService("CoreGui")
if not pcall(function() local a = game.CoreGui.Name end) then
    TargetGuiParent = LocalPlayer:WaitForChild("PlayerGui")
end

if TargetGuiParent:FindFirstChild("VeraCrossGui") then
    TargetGuiParent.VeraCrossGui:Destroy()
end

-- SAF ARAYÜZ KURULUMU
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VeraCrossGui"
ScreenGui.Parent = TargetGuiParent
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 150)
MainFrame.AnchorPoint = Vector2.new(1, 0.5) 
MainFrame.Position = UDim2.new(0.98, 0, 0.5, 0) 
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(175, 25, 255)
MainFrame.Active = false
MainFrame.Draggable = false
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "  VeraXS Hub v4 [H Tuşu]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    if input.KeyCode == Enum.KeyCode.H then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

local AimbotEnabled = false
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
CreateMenuButton("ESP (Tüm Cihazlar)", 90, function(status) 
    EspEnabled = status 
    if not status then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("VeraHighlight") then
                player.Character.VeraHighlight:Destroy()
            end
        end
    end
end)

-- DUVAR KONTROLÜ
local function IsVisible(targetPart)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return false end
    local Origin = Camera.CFrame.Position
    local Direction = (targetPart.Position - Origin)
    local RaycastParamsArgs = RaycastParams.new()
    RaycastParamsArgs.FilterInstanceTable = {LocalPlayer.Character, Camera}
    RaycastParamsArgs.FilterType = Enum.RaycastFilterType.Exclude
    RaycastParamsArgs.IgnoreWater = true
    local Result = workspace:Raycast(Origin, Direction, RaycastParamsArgs)
    if Result == nil or Result.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return false
end

-- EKRANDAKİ EN YAKIN HEDEFİ BULUCU (TİTREMEYİ ÖNLER)
local function GetClosestPlayerToMouse()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return nil end
    local ClosestTarget = nil
    local ShortestDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if IsVisible(player.Character.Head) then
                -- Düşmanın kafasının ekrandaki 2D pozisyonunu alır
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                if OnScreen then
                    -- Farenin imlecine en yakın olan oyuncuyu hesaplar
                    local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).magnitude
                    if Distance < ShortestDistance then
                        ShortestDistance = Distance
                        ClosestTarget = player
                    end
                end
            end
        end
    end
    return ClosestTarget
end

-- ANA MOTOR DÖNGÜSÜ
RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character then return end
    
    -- Geliştirilmiş Çapraz Platform Uyumlu Aimbot
    if AimbotEnabled then
        local TargetPlayer = GetClosestPlayerToMouse()
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") then
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPlayer.Character.Head.Position)
            if OnScreen then
                -- Mac/PC/Android executor'ların ortak desteklediği fare sinyal simülasyonu
                if sethiddenproperty or (syn and syn.mousemove) then
                    -- Eğer gelişmiş bir executor ise pürüzsüz fare kaydırması yapar
                    local mousemove = (syn and syn.mousemove) or mousemove
                    mousemove(ScreenPos.X, ScreenPos.Y)
                else
                    -- Standart executorlar için kamerayı sarsmadan hedefe doğrudan odaklar
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, TargetPlayer.Character.Head.Position)
                end
            end
        end
    end
    
    -- ESP ÇALIŞMA MANTIĞI
    if EspEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local Char = player.Character
                if not Char:FindFirstChild("VeraHighlight") then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Name = "VeraHighlight"
                    Highlight.FillColor = Color3.fromRGB(175, 25, 255)
                    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    Highlight.FillTransparency = 0.35
                    Highlight.OutlineTransparency = 0
                    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    Highlight.Parent = Char
                end
            else
                if player.Character and player.Character:FindFirstChild("VeraHighlight") then
                    player.Character.VeraHighlight:Destroy()
                end
            end
        end
    end
end)
