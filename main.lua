-- ==========================================
-- VeraXS Hub v2 - TAMAMEN LOCAL SÜRÜM
-- Hiçbir GitHub veya internet bağımlılığı yoktur.
-- ==========================================

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

-- Orion Arayüz Motoru (Gömülü / Local)
local OrionLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Default = {
			Main = Color3.fromRGB(25, 25, 25),
			Second = Color3.fromRGB(32, 32, 32),
			Stroke = Color3.fromRGB(60, 60, 60),
			Divider = Color3.fromRGB(60, 60, 60),
			Text = Color3.fromRGB(240, 240, 240),
			TextDark = Color3.fromRGB(150, 150, 150)
		}
	},
	SelectedTheme = "Default",
	Folder = "VeraXSTest",
	SaveCfg = false
}

-- UI Kurulum Fonksiyonları
local Orion = Instance.new("ScreenGui")
Orion.Name = "VeraXSHub_Gui"
if syn then syn.protect_gui(Orion) Orion.Parent = game.CoreGui else Orion.Parent = gethui() or game.CoreGui end

function OrionLib:IsRunning()
	return Orion.Parent ~= nil
end

local function AddConnection(Signal, Function)
	if (not OrionLib:IsRunning()) then return end
	local SignalConnect = Signal:Connect(Function)
	table.insert(OrionLib.Connections, SignalConnect)
	return SignalConnect
end

local function MakeDraggable(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		AddConnection(DragPoint.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position
				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
				end)
			end
		end)
		AddConnection(DragPoint.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = Input end
		end)
		AddConnection(UserInputService.InputChanged, function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				Main.Position  = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
			end
		end)
	end)
end

-- Temel UI Elemanı Oluşturucular
local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do Object[i] = v end
	for i, v in next, Children or {} do v.Parent = Object end
	return Object
end

-- Sürüklenebilir Taşınabilir Arayüz Penceresi Oluşturma (Görsel Tasarım)
local MainFrame = Create("Frame", {
	Name = "MainFrame",
	BackgroundColor3 = OrionLib.Themes.Default.Main,
	Position = UDim2.new(0.3, 0, 0.3, 0),
	Size = UDim2.new(0, 450, 0, 300),
	Parent = Orion
})
Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = MainFrame })
Create("UIStroke", { Color = OrionLib.Themes.Default.Stroke, Thickness = 1, Parent = MainFrame })

-- Taşımak için Üst Çubuk (Title Bar)
local TopBar = Create("Frame", {
	Name = "TopBar",
	BackgroundColor3 = OrionLib.Themes.Default.Second,
	Size = UDim2.new(1, 0, 0, 40),
	Parent = MainFrame
})
Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = TopBar })
MakeDraggable(TopBar, MainFrame)

local Title = Create("TextLabel", {
	Text = "VeraXS Hub v2 (Local)",
	TextColor3 = OrionLib.Themes.Default.Text,
	TextSize = 16,
	Font = Enum.Font.SourceSansBold,
	Position = UDim2.new(0, 15, 0, 0),
	Size = UDim2.new(0, 200, 1, 0),
	BackgroundTransparency = 1,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = TopBar
})

-- Kapatma Butonu
local CloseButton = Create("TextButton", {
	Text = "X",
	TextColor3 = Color3.fromRGB(255, 100, 100),
	TextSize = 16,
	Font = Enum.Font.SourceSansBold,
	Position = UDim2.new(1, -35, 0, 5),
	Size = UDim2.new(0, 30, 0, 30),
	BackgroundTransparency = 1,
	Parent = TopBar
})
CloseButton.MouseButton1Click:Connect(function() Orion:Destroy() end)

-- İçerik Listesi Paneli
local ContentFrame = Create("ScrollingFrame", {
	Position = UDim2.new(0, 10, 0, 50),
	Size = UDim2.new(1, -20, 1, -60),
	BackgroundTransparency = 1,
	CanvasSize = UDim2.new(0, 0, 0, 400),
	ScrollBarThickness = 4,
	Parent = MainFrame
})
Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = ContentFrame })

-- Buton ve Toggle Arayüz Yapıcıları
local function AddLocalToggle(Text, Callback)
	local Enabled = false
	local ToggleFrame = Create("Frame", { BackgroundColor3 = OrionLib.Themes.Default.Second, Size = UDim2.new(1, 0, 0, 40), Parent = ContentFrame })
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ToggleFrame })
	
	local Label = Create("TextLabel", { Text = Text, TextColor3 = OrionLib.Themes.Default.Text, TextSize = 14, Font = Enum.Font.SourceSans, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0, 250, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleFrame })
	local StatusIndicator = Create("TextButton", { Text = "KAPALI", TextColor3 = Color3.fromRGB(255, 100, 100), TextSize = 12, Font = Enum.Font.SourceSansBold, Position = UDim2.new(1, -80, 0, 7), Size = UDim2.new(0, 70, 0, 26), BackgroundColor3 = OrionLib.Themes.Default.Main, Parent = ToggleFrame })
	Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = StatusIndicator })
	
	StatusIndicator.MouseButton1Click:Connect(function()
		Enabled = not Enabled
		if Enabled then
			StatusIndicator.Text = "AÇIK"
			StatusIndicator.TextColor3 = Color3.fromRGB(100, 255, 100)
		else
			StatusIndicator.Text = "KAPALI"
			StatusIndicator.TextColor3 = Color3.fromRGB(255, 100, 100)
		end
		Callback(Enabled)
	end)
end

local function AddLocalButton(Text, Callback)
	local ButtonFrame = Create("TextButton", { Text = Text, TextColor3 = OrionLib.Themes.Default.Text, TextSize = 14, Font = Enum.Font.SourceSansBold, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = OrionLib.Themes.Default.Second, Parent = ContentFrame })
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ButtonFrame })
	ButtonFrame.MouseButton1Click:Connect(Callback)
end

-- ==========================================
-- HİLE MOTORLARI VE AKTİF ÖZELLİKLER
-- ==========================================

local AimbotEnabled = false
local TriggerbotEnabled = false

-- 1. Auto Aim Kontrolü
AddLocalToggle("Auto Aim (Otomatik Kafaya Kilitleme)", function(Value)
	AimbotEnabled = Value
end)

-- 2. Triggerbot Kontrolü
AddLocalToggle("Triggerbot (Otomatik Sıkma)", function(Value)
	TriggerbotEnabled = Value
end)

-- En yakın oyuncuyu bulan optimizasyonlu yerel fonksiyon
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

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

-- Gerçek Zamanlı Ana Döngü (Mac Uyumlu)
RunService.RenderStepped:Connect(function()
	if AimbotEnabled then
		local TargetPlayer = GetClosestPlayer()
		if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") then
			Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, TargetPlayer.Character.Head.Position)
		end
	end

	if TriggerbotEnabled and Mouse.Target then
		local TargetModel = Mouse.Target:FindAncestorOfClass("Model")
		if TargetModel then
			local HitPlayer = Players:GetPlayerFromCharacter(TargetModel)
			if HitPlayer and HitPlayer ~= LocalPlayer and TargetModel:FindFirstChild("Humanoid") and TargetModel.Humanoid.Health > 0 then
				if mouse1press and mouse1release then
					mouse1press()
					task.wait(0.02)
					mouse1release()
				end
			end
		end
	end
end)

-- 3. Bozulmayan ESP Butonu
AddLocalButton("ESP / Wallhack Aktif Et (Bozulmaz Fix)", function()
	local function ApplyESP(player)
		if player == LocalPlayer then return end
		
		local function OnCharacterAdded(character)
			if not character then return end
			if character:FindFirstChild("VeraHighlight") then character.VeraHighlight:Destroy() end
			
			local Highlight = Instance.new("Highlight")
			Highlight.Name = "VeraHighlight"
			Highlight.FillColor = Color3.fromRGB(175, 25, 255)
			Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			Highlight.FillTransparency = 0.4
			Highlight.OutlineTransparency = 0
			Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			Highlight.Parent = character
		end

		if player.Character then OnCharacterAdded(player.Character) end
		player.CharacterAdded:Connect(OnCharacterAdded)
	end

	for _, player in ipairs(Players:GetPlayers()) do ApplyESP(player) end
	Players.PlayerAdded:Connect(ApplyESP)
end)
