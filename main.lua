-- ========================================================
-- VeraXS Hub v5.0 - YALNIZCA MAC & ANDROID ÖZEL STABİL SÜRÜM
-- Windows Desteği Tamamen Kaldırılmıştır.
-- Menüyü Gizlemek/Açmak İçin Klavyeden "H" Tuşuna Basın!
-- ========================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- Mac ve Android için en kararlı GUI Ebeveynini Seçme Protokolü
local TargetGuiParent = game:GetService("CoreGui")
if not pcall(function() local a = game.CoreGui.Name end) then
    TargetGuiParent = LocalPlayer:WaitForChild("PlayerGui")
end

if TargetGuiParent:FindFirstChild("VeraCrossGui") then
    TargetGuiParent.VeraCrossGui:Destroy()
end

-- ========================================================
-- 1. ARAYÜZ (GUI) KURULUMU (SAĞ ORTA SABİT)
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VeraCrossGui"
ScreenGui.Parent = TargetGuiParent
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 190)
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
Title.Text = "  VeraXS Hub v5 [Mac & Mobile]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Mac klavyeleri için H tuşu gizleme özelliği
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    if input.KeyCode == Enum.KeyCode.H then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

local AimbotEnabled = false
local TriggerbotEnabled = false
local EspEnabled = false
local HoldingRightClick = false

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

CreateMenuButton("Auto Aim (Sağ Tık Kilit)", 45, function(status) AimbotEnabled = status end)
CreateMenuButton("Triggerbot (Mac/Android)", 90, function(status) TriggerbotEnabled = status end)
CreateMenuButton("ESP (Duvar Arkası Mor)", 135, function(status) 
    EspEnabled = status 
    if not status then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("VeraHighlight") then
                player.Character.VeraHighlight:Destroy()
            end
        end
    end
end)

-- Mac/PC için mouse sağ tık durumunu izleme
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        HoldingRightClick = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        HoldingRightClick = false
    end
end)

-- ========================================================
-- 2. DUVAR & ENGEL KONTROLÜ (RAYCAST)
-- ========================================================
local function IsVisible(targetPart)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return false end
    local Origin = Camera.CFrame.Position
    local Direction = (targetPart.Position - Origin)
    local RaycastParamsArgs = RaycastParams.new()
    RaycastParamsArgs.FilterInstanceTable = {LocalPlayer.Character, Camera}
    RaycastParamsArgs.FilterType = Enum.RaycastFilterType.Exclude
    local Result = workspace:Raycast(Origin, Direction, RaycastParamsArgs)
    if Result == nil or Result.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return false
end

-- ========================================================
-- 3. HEDEF BULUCU (LOBİ KORUMALI)
-- ========================================================
local function GetClosestPlayer()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return nil end
    local ClosestTarget = nil
    local ShortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if IsVisible(player.Character.Head) then
                local Distance = (Camera.CFrame.Position - player.Character.Head.Position).magnitude
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
-- 4. MERKEZİ MOTOR DÖNGÜSÜ (RENDERSTEPPED)
-- ========================================================
RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character then return end
    
    -- [AIMBOT MOTORU] - Sağ Tık Basılı Tutulunca Tetiklenir (Mobilde Süreklidir)
    -- Android cihazlarda sağ tık olmadığı için mobilde dokunulduğu an otomatik nişan alır
    local IsMobile = UserInputService.TouchEnabled
    if AimbotEnabled and (HoldingRightClick or IsMobile) then
        local TargetPlayer = GetClosestPlayer()
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, TargetPlayer.Character.Head.Position)
        end
    end
    
    -- [ESP MOTORU] - Kararlı Mor Vurgu Çizgileri
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

-- ========================================================
-- 5. MAC & ANDROID UYUMLU TRIGGERBOT (SABİT DÖNGÜ)
-- ========================================================
task.spawn(function()
    while true do
        task.wait(0.03) -- İşlemciyi yormayan çökme korumalı bekleme süresi
        
        if LocalPlayer.Character and TriggerbotEnabled and Mouse.Target then
            local TargetModel = Mouse.Target:FindAncestorOfClass("Model")
            if TargetModel then
                local HitPlayer = Players:GetPlayerFromCharacter(TargetModel)
                if HitPlayer and HitPlayer ~= LocalPlayer and TargetModel:FindFirstChild("Humanoid") and TargetModel.Humanoid.Health > 0 and IsVisible(Mouse.Target) then
                    
                    -- Mac (Opiumware/Solara) ve Android (Delta vb.) için en kararlı sanal dokunuş motoru
                    if VirtualUser then
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(0, 0))
                    end
                    
                    -- Mac/Android ortak entegrasyonu: Oyun içi araç aktivasyonu
                    local Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if Tool then
                        Tool:Activate()
                    end
                end
            end
        end
    end
end)
