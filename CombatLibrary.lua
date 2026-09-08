--[[
    Combat Library
    Interface de combate para Roblox

    Arquivo principal do projeto.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = workspace.CurrentCamera
end)

local Settings = {
	AimAssist = false,
	Aimbot = false,
	ESP = true,
	ShowTeammates = false,
	AutoShoot = false,
	FireRate = 0.12,          -- tempo entre tiros (menor = mais rápido)
	FOV = 160,
	MaxDistance = 600,
	Smoothness = 0.25,
	AimbotSmoothness = 0.55,
	AimPart = "Head"
}

local CurrentTarget = nil
local LastShot = 0

--========================================================--
-- DETECÇÃO DE TIME
--========================================================--

local function IsEnemy(player)
	if player == LP then return false end
	if LP.Team == nil or player.Team == nil then return true end
	return LP.Team ~= player.Team
end

local function IsTeammate(player)
	if player == LP then return false end
	if LP.Team and player.Team then
		return LP.Team == player.Team
	end
	return false
end

--========================================================--
-- FUNÇÃO DE ATIRAR
--========================================================--

local function Shoot()
	local character = LP.Character
	if not character then return end

	local tool = character:FindFirstChildOfClass("Tool")
	if tool then
		tool:Activate()
	else
		-- Alternativa caso não tenha Tool
		pcall(function()
			VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
			task.wait(0.03)
			VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
		end)
	end
end

--========================================================--
-- GUI PRINCIPAL
--========================================================--

local GUI = Instance.new("ScreenGui")
GUI.Name = "CombatLibrary"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = LP:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(350, 420)
Main.Position = UDim2.new(0.5, -175, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = GUI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = Main

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(55, 55, 65)
UIStroke.Thickness = 1.5
UIStroke.Parent = Main

-- Título
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -95, 1, 0)
Title.Position = UDim2.fromOffset(14, 0)
Title.BackgroundTransparency = 1
Title.Text = "Combat Library"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Botão Minimizar
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.fromOffset(34, 34)
MinimizeBtn.Position = UDim2.new(1, -78, 0, 6)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.TextSize = 24
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinimizeBtn

-- Botão Fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(34, 34)
CloseBtn.Position = UDim2.new(1, -38, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextSize = 22
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Botão minimizado
local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.fromOffset(58, 58)
MiniBtn.Position = UDim2.new(0, 18, 0.5, -29)
MiniBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
MiniBtn.Text = "CL"
MiniBtn.TextColor3 = Color3.new(1,1,1)
MiniBtn.TextSize = 17
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.Visible = false
MiniBtn.Parent = GUI

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(1, 0)
MiniCorner.Parent = MiniBtn

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Color3.fromRGB(90, 90, 110)
MiniStroke.Thickness = 2
MiniStroke.Parent = MiniBtn

local isMinimized = false
local ShootBtn

local function ToggleMin()
	isMinimized = not isMinimized
	Main.Visible = not isMinimized
	MiniBtn.Visible = isMinimized
	ShootBtn.Visible = not isMinimized
end
MinimizeBtn.MouseButton1Click:Connect(ToggleMin)
MiniBtn.MouseButton1Click:Connect(ToggleMin)
CloseBtn.MouseButton1Click:Connect(function()
	Main.Visible = false
	MiniBtn.Visible = true
	ShootBtn.Visible = false
	isMinimized = true
end)

--========================================================--
-- BOTÃO DE ATIRAR MANUAL
--========================================================--

ShootBtn = Instance.new("TextButton")
ShootBtn.Name = "ShootButton"
ShootBtn.Size = UDim2.fromOffset(90, 90)
ShootBtn.Position = UDim2.new(1, -110, 1, -140)
ShootBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
ShootBtn.Text = "ATIRAR"
ShootBtn.TextColor3 = Color3.new(1,1,1)
ShootBtn.TextSize = 16
ShootBtn.Font = Enum.Font.GothamBold
ShootBtn.Parent = GUI

local ShootCorner = Instance.new("UICorner")
ShootCorner.CornerRadius = UDim.new(1, 0)
ShootCorner.Parent = ShootBtn

local ShootStroke = Instance.new("UIStroke")
ShootStroke.Color = Color3.fromRGB(255, 80, 80)
ShootStroke.Thickness = 3
ShootStroke.Parent = ShootBtn

local function UpdateShootButton()
	if CurrentTarget then
		ShootBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 60)
		ShootStroke.Color = Color3.fromRGB(80, 255, 100)
	else
		ShootBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
		ShootStroke.Color = Color3.fromRGB(255, 80, 80)
	end
end

ShootBtn.MouseButton1Click:Connect(Shoot)

--========================================================--
-- ABAS
--========================================================--

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 95, 1, -55)
TabBar.Position = UDim2.fromOffset(8, 52)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -115, 1, -55)
Content.Position = UDim2.fromOffset(108, 52)
Content.BackgroundTransparency = 1
Content.Parent = Main

local function CreateTab(name, y)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -6, 0, 40)
	btn.Position = UDim2.fromOffset(3, y)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	btn.Text = name
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextSize = 14
	btn.Font = Enum.Font.Gotham
	btn.Parent = TabBar

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn
	return btn
end

local CombatTab = CreateTab("Combat", 6)
local ESPTab = CreateTab("ESP", 52)
local SettingsTab = CreateTab("Info", 98)

local CombatPage = Instance.new("Frame")
CombatPage.Size = UDim2.fromScale(1,1)
CombatPage.BackgroundTransparency = 1
CombatPage.Parent = Content

local ESPPage = Instance.new("Frame")
ESPPage.Size = UDim2.fromScale(1,1)
ESPPage.BackgroundTransparency = 1
ESPPage.Visible = false
ESPPage.Parent = Content

local SettingsPage = Instance.new("Frame")
SettingsPage.Size = UDim2.fromScale(1,1)
SettingsPage.BackgroundTransparency = 1
SettingsPage.Visible = false
SettingsPage.Parent = Content

local function ShowPage(page)
	CombatPage.Visible = false
	ESPPage.Visible = false
	SettingsPage.Visible = false
	page.Visible = true
end

CombatTab.MouseButton1Click:Connect(function() ShowPage(CombatPage) end)
ESPTab.MouseButton1Click:Connect(function() ShowPage(ESPPage) end)
SettingsTab.MouseButton1Click:Connect(function() ShowPage(SettingsPage) end)

--========================================================--
-- TOGGLE
--========================================================--

local function MakeToggle(parent, text, y, default, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -8, 0, 40)
	btn.Position = UDim2.fromOffset(4, y)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextSize = 13
	btn.Font = Enum.Font.Gotham
	btn.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	local value = default
	local function update()
		btn.Text = text .. ": " .. (value and "ON" or "OFF")
		btn.BackgroundColor3 = value and Color3.fromRGB(35, 95, 50) or Color3.fromRGB(35, 35, 42)
	end
	update()

	btn.MouseButton1Click:Connect(function()
		value = not value
		update()
		callback(value)
	end)
end

-- Combat Page
MakeToggle(CombatPage, "Aim Assist", 4, false, function(v) Settings.AimAssist = v end)
MakeToggle(CombatPage, "Aimbot", 48, false, function(v) Settings.Aimbot = v end)
MakeToggle(CombatPage, "Auto Shoot", 92, false, function(v) Settings.AutoShoot = v end)

-- FOV
local FOVBtn = Instance.new("TextButton")
FOVBtn.Size = UDim2.new(1, -8, 0, 36)
FOVBtn.Position = UDim2.fromOffset(4, 140)
FOVBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
FOVBtn.Text = "FOV: 160"
FOVBtn.TextColor3 = Color3.new(1,1,1)
FOVBtn.TextSize = 13
FOVBtn.Font = Enum.Font.Gotham
FOVBtn.Parent = CombatPage
Instance.new("UICorner", FOVBtn).CornerRadius = UDim.new(0, 8)

FOVBtn.MouseButton1Click:Connect(function()
	Settings.FOV = Settings.FOV + 20
	if Settings.FOV > 300 then Settings.FOV = 80 end
	FOVBtn.Text = "FOV: " .. Settings.FOV
end)

--========================================================--
-- SLIDER DE FIRE RATE (VELOCIDADE DO TIRO AUTOMÁTICO)
--========================================================--

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, -8, 0, 22)
SliderLabel.Position = UDim2.fromOffset(4, 185)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Fire Rate: 0.12s"
SliderLabel.TextColor3 = Color3.new(1,1,1)
SliderLabel.TextSize = 13
SliderLabel.Font = Enum.Font.Gotham
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = CombatPage

local SliderBg = Instance.new("Frame")
SliderBg.Size = UDim2.new(1, -8, 0, 18)
SliderBg.Position = UDim2.fromOffset(4, 210)
SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
SliderBg.BorderSizePixel = 0
SliderBg.Parent = CombatPage
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(0, 9)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.35, 0, 1, 0) -- valor inicial
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBg
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 9)

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(0, 22, 0, 22)
SliderBtn.Position = UDim2.new(0.35, -11, 0.5, -11)
SliderBtn.BackgroundColor3 = Color3.new(1,1,1)
SliderBtn.Text = ""
SliderBtn.Parent = SliderBg
Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)

-- Lógica do Slider
local sliding = false

local function UpdateSlider(inputPos)
	local relative = math.clamp((inputPos.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
	SliderFill.Size = UDim2.new(relative, 0, 1, 0)
	SliderBtn.Position = UDim2.new(relative, -11, 0.5, -11)

	-- Converte para FireRate (0.05 = muito rápido | 0.40 = lento)
	Settings.FireRate = 0.05 + (1 - relative) * 0.35
	SliderLabel.Text = "Fire Rate: " .. string.format("%.2f", Settings.FireRate) .. "s"
end

SliderBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		sliding = true
	end
end)

SliderBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		sliding = true
		UpdateSlider(input.Position)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		UpdateSlider(input.Position)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		sliding = false
	end
end)

-- ESP Page
MakeToggle(ESPPage, "ESP", 4, true, function(v)
	Settings.ESP = v
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then
			local h = plr.Character:FindFirstChild("CombatESP")
			if h then
				if IsEnemy(plr) then
					h.Enabled = v
				elseif IsTeammate(plr) then
					h.Enabled = v and Settings.ShowTeammates
				else
					h.Enabled = false
				end
			end
		end
	end
end)

MakeToggle(ESPPage, "Show Teammates", 48, false, function(v)
	Settings.ShowTeammates = v
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and IsTeammate(plr) then
			local h = plr.Character:FindFirstChild("CombatESP")
			if h then h.Enabled = Settings.ESP and v end
		end
	end
end)

local DistBtn = Instance.new("TextButton")
DistBtn.Size = UDim2.new(1, -8, 0, 36)
DistBtn.Position = UDim2.fromOffset(4, 96)
DistBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
DistBtn.Text = "Distance: 600"
DistBtn.TextColor3 = Color3.new(1,1,1)
DistBtn.TextSize = 13
DistBtn.Font = Enum.Font.Gotham
DistBtn.Parent = ESPPage
Instance.new("UICorner", DistBtn).CornerRadius = UDim.new(0, 8)

DistBtn.MouseButton1Click:Connect(function()
	Settings.MaxDistance = Settings.MaxDistance + 100
	if Settings.MaxDistance > 1200 then Settings.MaxDistance = 200 end
	DistBtn.Text = "Distance: " .. Settings.MaxDistance
end)

-- Info
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -8, 1, -10)
Info.Position = UDim2.fromOffset(4, 6)
Info.BackgroundTransparency = 1
Info.Text = "TIRO AUTOMÁTICO\n\n• Ative Auto Shoot\n• Ajuste a barra de Fire Rate\n• Quanto mais pra direita = mais rápido\n\nBotão verde = alvo travado\nBotão vermelho = sem alvo"
Info.TextColor3 = Color3.new(1,1,1)
Info.TextSize = 13
Info.Font = Enum.Font.Gotham
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextYAlignment = Enum.TextYAlignment.Top
Info.Parent = SettingsPage

--========================================================--
-- ESP
--========================================================--

local function SetupESP(plr)
	if plr == LP then return end

	local function onChar(char)
		task.wait(0.6)
		local old = char:FindFirstChild("CombatESP")
		if old then old:Destroy() end

		local hl = Instance.new("Highlight")
		hl.Name = "CombatESP"
		hl.FillTransparency = 0.55
		hl.OutlineTransparency = 0

		if IsEnemy(plr) then
			hl.FillColor = Color3.fromRGB(255, 50, 50)
			hl.OutlineColor = Color3.fromRGB(255, 130, 130)
			hl.Enabled = Settings.ESP
		elseif IsTeammate(plr) then
			hl.FillColor = Color3.fromRGB(50, 200, 80)
			hl.OutlineColor = Color3.fromRGB(120, 255, 150)
			hl.Enabled = Settings.ESP and Settings.ShowTeammates
		else
			hl.Enabled = false
		end
		hl.Parent = char
	end

	if plr.Character then onChar(plr.Character) end
	plr.CharacterAdded:Connect(onChar)
	plr:GetPropertyChangedSignal("Team"):Connect(function()
		if plr.Character then onChar(plr.Character) end
	end)
end

for _, p in ipairs(Players:GetPlayers()) do SetupESP(p) end
Players.PlayerAdded:Connect(SetupESP)

--========================================================--
-- FOV
--========================================================--

local FOV = Instance.new("Frame")
FOV.Size = UDim2.fromOffset(320, 320)
FOV.AnchorPoint = Vector2.new(0.5, 0.5)
FOV.Position = UDim2.fromScale(0.5, 0.5)
FOV.BackgroundTransparency = 1
FOV.Visible = false
FOV.Parent = GUI

Instance.new("UICorner", FOV).CornerRadius = UDim.new(1, 0)
local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 2
FOVStroke.Transparency = 0.4
FOVStroke.Color = Color3.new(1,1,1)
FOVStroke.Parent = FOV

--========================================================--
-- GET CLOSEST
--========================================================--

local function GetClosest()
	local closest = nil
	local shortest = Settings.FOV
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and IsEnemy(plr) and plr.Character then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			local part = plr.Character:FindFirstChild(Settings.AimPart)
			local root = plr.Character:FindFirstChild("HumanoidRootPart")

			if hum and part and root and hum.Health > 0 then
				local dist = (Camera.CFrame.Position - root.Position).Magnitude
				if dist <= Settings.MaxDistance then
					local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
					if onScreen and pos.Z > 0 then
						local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
						if screenDist < shortest then
							shortest = screenDist
							closest = part
						end
					end
				end
			end
		end
	end
	return closest
end

--========================================================--
-- LOOP PRINCIPAL
--========================================================--

RunService.RenderStepped:Connect(function()
	local size = Settings.FOV * 2
	FOV.Size = UDim2.fromOffset(size, size)
	FOV.Visible = (Settings.AimAssist or Settings.Aimbot)

	if Settings.Aimbot or Settings.AimAssist then
		local target = GetClosest()
		CurrentTarget = target

		if target then
			local smoothness = Settings.Aimbot and Settings.AimbotSmoothness or Settings.Smoothness

			if Settings.Aimbot then
				local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
				local pos = Camera:WorldToViewportPoint(target.Position)
				local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
				if screenDist < 40 then
					smoothness = math.clamp(smoothness + 0.25, 0.1, 0.95)
				end
			end

			local lookAt = CFrame.lookAt(Camera.CFrame.Position, target.Position)
			Camera.CFrame = Camera.CFrame:Lerp(lookAt, smoothness)

			-- TIRO AUTOMÁTICO
			if Settings.AutoShoot then
				local now = tick()
				if now - LastShot >= Settings.FireRate then
					LastShot = now
					Shoot()
				end
			end
		end
	else
		CurrentTarget = nil
	end

	UpdateShootButton()
end)

--========================================================--
-- ARRASTAR
--========================================================--

local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
	end
end)

TitleBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Arrastar MiniBtn
local miniDrag = false
local miniStart, miniPos

MiniBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		miniDrag = true
		miniStart = input.Position
		miniPos = MiniBtn.Position
	end
end)

MiniBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		miniDrag = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if miniDrag and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = input.Position - miniStart
		MiniBtn.Position = UDim2.new(miniPos.X.Scale, miniPos.X.Offset + delta.X, miniPos.Y.Scale, miniPos.Y.Offset + delta.Y)
	end
end)

print("[Combat Library] Auto Shoot + Slider carregado!")
