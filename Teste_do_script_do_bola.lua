--[[
    Combat Library - Com Keybinds para Aim Assist, Aimbot e ESP
    Interface de combate para Roblox
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = workspace.CurrentCamera
end)

local Settings = {
	AimAssist = false,
	AimAssistKey = Enum.KeyCode.E, -- Tecla padrão para Aim Assist
	
	Aimbot = false,
	AimbotKey = Enum.KeyCode.Q,    -- Tecla padrão para Aimbot
	
	ESP = true,
	ESPKey = Enum.KeyCode.X,       -- Tecla padrão para ESP
	
	ShowTeammates = false,
	FOV = 160,
	MaxDistance = 600,       -- Distância para o ESP
	AimbotDistance = 100,    -- Distância inicial do Aimbot (10 - 200 metros)
	Smoothness = 0.25,
	AimbotSmoothness = 0.55,
	AimPart = "Head"
}

local CurrentTarget = nil

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
-- VERIFICAÇÃO DE VISIBILIDADE (RAYCAST)
--========================================================--

local function IsVisible(targetPart)
	if not targetPart or not LP.Character then return false end

	local origin = Camera.CFrame.Position
	local destination = targetPart.Position
	local direction = destination - origin

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local excludeList = {LP.Character}
	if targetPart.Parent then
		table.insert(excludeList, targetPart.Parent)
	end
	raycastParams.IgnoreWater = true
	raycastParams.FilterDescendantsInstances = excludeList

	local result = workspace:Raycast(origin, direction, raycastParams)
	return result == nil
end

--========================================================--
-- GUI PRINCIPAL
--========================================================--

local GUI = Instance.new("ScreenGui")
GUI.Name = "CombatLibrary"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.DisplayOrder = 999999
GUI.Parent = LP:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(380, 420) -- Levemente alargado para caber os botões de keybind
Main.Position = UDim2.new(0.5, -190, 0.5, -210)
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

Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

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

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

--========================================================--
-- FUNÇÃO PARA DESATIVAR TUDO E FECHAR
--========================================================--

local function ShutdownScript()
	Settings.AimAssist = false
	Settings.Aimbot = false
	Settings.ESP = false
	Settings.ShowTeammates = false

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then
			local h = plr.Character:FindFirstChild("CombatESP")
			if h then h:Destroy() end
		end
	end

	GUI:Destroy()
end

CloseBtn.MouseButton1Click:Connect(ShutdownScript)

--========================================================--
-- CONTROLE DE VISIBILIDADE (ABRIR/MINIMIZAR)
--========================================================--

local function ToggleUI()
	Main.Visible = not Main.Visible
end

MinimizeBtn.MouseButton1Click:Connect(ToggleUI)

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

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
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
-- SISTEMA DE TOGGLE COM KEYBIND
--========================================================--

local function MakeToggleWithKeybind(parent, text, y, defaultVal, defaultKey, callback, keyReferenceTable, keyName)
	-- Botão Principal de Ativar/Desativar
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -55, 0, 40)
	btn.Position = UDim2.fromOffset(4, y)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextSize = 13
	btn.Font = Enum.Font.Gotham
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	-- Botão de Definir Tecla (Keybind)
	local keyBtn = Instance.new("TextButton")
	keyBtn.Size = UDim2.new(0, 45, 0, 40)
	keyBtn.Position = UDim2.new(1, -45, 0, y)
	keyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	keyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	keyBtn.TextSize = 12
	keyBtn.Font = Enum.Font.GothamBold
	keyBtn.Text = "[" .. defaultKey.Name .. "]"
	keyBtn.Parent = parent
	Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 8)

	local value = defaultVal
	local binding = false

	local function update()
		btn.Text = text .. ": " .. (value and "ON" or "OFF")
		btn.BackgroundColor3 = value and Color3.fromRGB(35, 95, 50) or Color3.fromRGB(35, 35, 42)
		callback(value)
	end
	update()

	btn.MouseButton1Click:Connect(function()
		value = not value
		update()
	end)

	keyBtn.MouseButton1Click:Connect(function()
		binding = true
		keyBtn.Text = "[...]"
		keyBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if binding then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				Settings[keyName] = input.KeyCode
				keyBtn.Text = "[" .. input.KeyCode.Name .. "]"
				keyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
				binding = false
			end
		elseif not gp and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Settings[keyName] then
			value = not value
			update()
		end
	end)
end

-- Criando os Toggles com Keybinds nas abas corretas
MakeToggleWithKeybind(CombatPage, "Aim Assist", 4, false, Enum.KeyCode.E, function(v) 
	Settings.AimAssist = v 
end, Settings, "AimAssistKey")

MakeToggleWithKeybind(CombatPage, "Aimbot", 48, false, Enum.KeyCode.Q, function(v) 
	Settings.Aimbot = v 
end, Settings, "AimbotKey")

-- FOV Button
local FOVBtn = Instance.new("TextButton")
FOVBtn.Size = UDim2.new(1, -8, 0, 36)
FOVBtn.Position = UDim2.fromOffset(4, 96)
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
-- SLIDER DE DISTÂNCIA DO AIMBOT (10 - 200m)
--========================================================--

local AimDistLabel = Instance.new("TextLabel")
AimDistLabel.Size = UDim2.new(1, -8, 0, 20)
AimDistLabel.Position = UDim2.fromOffset(4, 138)
AimDistLabel.BackgroundTransparency = 1
AimDistLabel.Text = "Aimbot Max Dist: 100m"
AimDistLabel.TextColor3 = Color3.new(1,1,1)
AimDistLabel.TextSize = 13
AimDistLabel.Font = Enum.Font.Gotham
AimDistLabel.TextXAlignment = Enum.TextXAlignment.Left
AimDistLabel.Parent = CombatPage

local AimDistBg = Instance.new("Frame")
AimDistBg.Size = UDim2.new(1, -8, 0, 16)
AimDistBg.Position = UDim2.fromOffset(4, 162)
AimDistBg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
AimDistBg.BorderSizePixel = 0
AimDistBg.Parent = CombatPage
Instance.new("UICorner", AimDistBg).CornerRadius = UDim.new(0, 8)

local AimDistFill = Instance.new("Frame")
AimDistFill.Size = UDim2.new((100 - 10) / 190, 0, 1, 0)
AimDistFill.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
AimDistFill.BorderSizePixel = 0
AimDistFill.Parent = AimDistBg
Instance.new("UICorner", AimDistFill).CornerRadius = UDim.new(0, 8)

local AimDistBtn = Instance.new("TextButton")
AimDistBtn.Size = UDim2.new(0, 20, 0, 20)
AimDistBtn.Position = UDim2.new(AimDistFill.Size.X.Scale, -10, 0.5, -10)
AimDistBtn.BackgroundColor3 = Color3.new(1,1,1)
AimDistBtn.Text = ""
AimDistBtn.Parent = AimDistBg
Instance.new("UICorner", AimDistBtn).CornerRadius = UDim.new(1, 0)

local slidingAimDist = false

local function UpdateAimDistSlider(inputPos)
	local relative = math.clamp((inputPos.X - AimDistBg.AbsolutePosition.X) / AimDistBg.AbsoluteSize.X, 0, 1)
	AimDistFill.Size = UDim2.new(relative, 0, 1, 0)
	AimDistBtn.Position = UDim2.new(relative, -10, 0.5, -10)

	Settings.AimbotDistance = math.floor(10 + relative * 190)
	AimDistLabel.Text = "Aimbot Max Dist: " .. Settings.AimbotDistance .. "m"
end

AimDistBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		slidingAimDist = true
	end
end)

AimDistBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		slidingAimDist = true
		UpdateAimDistSlider(input.Position)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if slidingAimDist and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		UpdateAimDistSlider(input.Position)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		slidingAimDist = false
	end
end)

--========================================================--
-- ESP PAGE
--========================================================--

MakeToggleWithKeybind(ESPPage, "ESP", 4, true, Enum.KeyCode.X, function(v)
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
end, Settings, "ESPKey")

-- Toggle comum para Show Teammates
local TeamToggleBtn = Instance.new("TextButton")
TeamToggleBtn.Size = UDim2.new(1, -8, 0, 40)
TeamToggleBtn.Position = UDim2.fromOffset(4, 48)
TeamToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
TeamToggleBtn.TextColor3 = Color3.new(1,1,1)
TeamToggleBtn.TextSize = 13
TeamToggleBtn.Font = Enum.Font.Gotham
TeamToggleBtn.Parent = ESPPage
Instance.new("UICorner", TeamToggleBtn).CornerRadius = UDim.new(0, 8)

local showTeamVal = false
local function updateTeamBtn()
	TeamToggleBtn.Text = "Show Teammates: " .. (showTeamVal and "ON" or "OFF")
	TeamToggleBtn.BackgroundColor3 = showTeamVal and Color3.fromRGB(35, 95, 50) or Color3.fromRGB(35, 35, 42)
end
updateTeamBtn()

TeamToggleBtn.MouseButton1Click:Connect(function()
	showTeamVal = not showTeamVal
	Settings.ShowTeammates = showTeamVal
	updateTeamBtn()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and IsTeammate(plr) then
			local h = plr.Character:FindFirstChild("CombatESP")
			if h then h.Enabled = Settings.ESP and showTeamVal end
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

-- Info Page
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -8, 1, -10)
Info.Position = UDim2.fromOffset(4, 6)
Info.BackgroundTransparency = 1
Info.Text = "COMBAT LIBRARY\n\n• Suporte a Keybinds por botão ao lado.\n• Pressione a tecla na aba para remapear.\n\nPressione 'J' para ocultar/exibir o painel."
Info.TextColor3 = Color3.new(1,1,1)
Info.TextSize = 13
Info.Font = Enum.Font.Gotham
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextYAlignment = Enum.TextYAlignment.Top
Info.Parent = SettingsPage

--========================================================--
-- ESP ROBUSTO (PERSISTENTE APÓS ROUND/RESPAWN)
--========================================================--

local function SetupESP(plr)
	if plr == LP then return end

	local function applyHighlight(char)
		task.wait(0.4)
		if not char or not char.Parent or not Settings.ESP then return end

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

	if plr.Character then
		applyHighlight(plr.Character)
	end

	plr.CharacterAdded:Connect(function(newChar)
		applyHighlight(newChar)
	end)

	plr:GetPropertyChangedSignal("Team"):Connect(function()
		if plr.Character then
			applyHighlight(plr.Character)
		end
	end)
end

for _, p in ipairs(Players:GetPlayers()) do SetupESP(p) end
Players.PlayerAdded:Connect(SetupESP)

--========================================================--
-- FOV CIRCLE
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
-- GET CLOSEST TARGET (USANDO A DISTÂNCIA DO AIMBOT)
--========================================================--

local function GetClosest()
	local closest = nil
	local shortest = Settings.FOV
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character and LP.Character and plr.Character ~= LP.Character then
			if IsEnemy(plr) then
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				local part = plr.Character:FindFirstChild(Settings.AimPart)
				local root = plr.Character:FindFirstChild("HumanoidRootPart")

				if hum and part and root and hum.Health > 0 then
					local dist = (Camera.CFrame.Position - root.Position).Magnitude
					if dist <= Settings.AimbotDistance then
						local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
						if onScreen and pos.Z > 0 and IsVisible(part) then
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

	local target = GetClosest()
	CurrentTarget = target

	if (Settings.Aimbot or Settings.AimAssist) and target then
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
	end
end)

--========================================================--
-- TECLA DE ATALHO (J) - ABRE E MINIMIZA O PAINEL
--========================================================--

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.J then
		ToggleUI()
	end
end)

--========================================================--
-- DRAG SYSTEM (MOVER JANELA)
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

print("[Combat Library] Sistema de Keybinds adicionado com sucesso!")
