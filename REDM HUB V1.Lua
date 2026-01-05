-- 🔴 REDM HUB | FINAL VERSION
-- Organized • No Key • Full Systems
----------------------------------------------------

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Teams = game:GetService("Teams")
local VU = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")

local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

----------------------------------------------------
-- UI ANIMATION
----------------------------------------------------
local Blur = Instance.new("BlurEffect", Lighting)
Blur.Size = 0
TS:Create(Blur, TweenInfo.new(0.6), {Size = 16}):Play()

Rayfield:Notify({
	Title = "REDM HUB",
	Content = "Loaded successfully",
	Duration = 4
})

----------------------------------------------------
-- WINDOW
----------------------------------------------------
local Window = Rayfield:CreateWindow({
	Name = "🔴 REDM HUB",
	LoadingTitle = "REDM HUB",
	LoadingSubtitle = "Final Organized Version",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "REDM",
		FileName = "Config"
	}
})

----------------------------------------------------
-- TABS (REDUZIDAS)
----------------------------------------------------
local HomeTab    = Window:CreateTab("🏠 Home", 4483362458)
local CombatTab  = Window:CreateTab("🎯 Combat", 4483362458)
local ESPTab     = Window:CreateTab("👁 ESP", 4483362458)
local PlayerTab  = Window:CreateTab("🧍 Player", 4483362458)
local TPTab      = Window:CreateTab("📍 Teleport", 4483362458)
local VisualTab  = Window:CreateTab("🎨 Visual & Misc", 4483362458)

----------------------------------------------------
-- HOME
----------------------------------------------------
HomeTab:CreateParagraph({
	Title = "REDM HUB",
	Content = "Combat • ESP • Teleport • Player\nOptimized & Clean UI"
})

----------------------------------------------------
-- PLAYER TAB
----------------------------------------------------
local noclip = false

PlayerTab:CreateSlider({
	Name = "WalkSpeed",
	Range = {16, 200},
	Increment = 1,
	CurrentValue = 16,
	Callback = function(v)
		LP.Character.Humanoid.WalkSpeed = v
	end
})

PlayerTab:CreateSlider({
	Name = "JumpPower",
	Range = {50, 200},
	Increment = 5,
	CurrentValue = 50,
	Callback = function(v)
		LP.Character.Humanoid.JumpPower = v
	end
})

PlayerTab:CreateToggle({
	Name = "Noclip",
	Callback = function(v) noclip = v end
})

RS.Stepped:Connect(function()
	if noclip and LP.Character then
		for _,p in ipairs(LP.Character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end
end)

PlayerTab:CreateToggle({
	Name = "Anti AFK",
	Callback = function(v)
		if v then
			LP.Idled:Connect(function()
				VU:Button2Down(Vector2.new(0,0), Cam.CFrame)
				task.wait(1)
				VU:Button2Up(Vector2.new(0,0), Cam.CFrame)
			end)
		end
	end
})

----------------------------------------------------
-- COMBAT (AIMBOT + FOV)
----------------------------------------------------
_G.AimbotEnabled = false
_G.TeamCheck = false
_G.AimPart = "Head"
_G.Smooth = 0.08
local Holding = false

local FOV = Drawing.new("Circle")
FOV.Visible = false
FOV.Color = Color3.fromRGB(255,0,0)
FOV.Thickness = 2
FOV.Radius = 150

local function Closest()
	local best, dist = nil, math.huge
	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then

			if _G.TeamCheck and p.Team == LP.Team then continue end

			local pos, on = Cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
			if on then
				local m = UIS:GetMouseLocation()
				local d = (Vector2.new(m.X,m.Y)-Vector2.new(pos.X,pos.Y)).Magnitude
				if d < dist and d <= FOV.Radius then
					dist = d
					best = p
				end
			end
		end
	end
	return best
end

UIS.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton2 then Holding = true end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton2 then Holding = false end
end)

RS.RenderStepped:Connect(function()
	local m = UIS:GetMouseLocation()
	FOV.Position = Vector2.new(m.X,m.Y)

	if not _G.AimbotEnabled or not Holding then return end
	local t = Closest()
	if t and t.Character and t.Character:FindFirstChild(_G.AimPart) then
		TS:Create(Cam, TweenInfo.new(_G.Smooth),
			{CFrame = CFrame.new(Cam.CFrame.Position, t.Character[_G.AimPart].Position)}
		):Play()
	end
end)

CombatTab:CreateToggle({Name="Aimbot", Callback=function(v) _G.AimbotEnabled=v end})
CombatTab:CreateToggle({Name="Team Check", Callback=function(v) _G.TeamCheck=v end})
CombatTab:CreateToggle({Name="FOV Circle", Callback=function(v) FOV.Visible=v end})
CombatTab:CreateSlider({
	Name="FOV Size", Range={50,400}, Increment=5, CurrentValue=150,
	Callback=function(v) FOV.Radius=v end
})
CombatTab:CreateSlider({
	Name="Smooth", Range={0,0.3}, Increment=0.01, CurrentValue=0.08,
	Callback=function(v) _G.Smooth=v end
})

----------------------------------------------------
-- ESP TAB (COMPLETO)
----------------------------------------------------
local espOn = false
local espPlayer, espTeam = nil, nil

local function clearESP(c)
	if not c then return end
	for _,v in ipairs({"ESP_H","ESP_BOX"}) do
		if c:FindFirstChild(v) then c[v]:Destroy() end
	end
end

local function applyESP(p)
	if not espOn or p==LP or not p.Character then return end
	if espPlayer and p~=espPlayer then return end
	if espTeam and p.Team~=espTeam then return end

	if not p.Character:FindFirstChild("ESP_H") then
		local h=Instance.new("Highlight",p.Character)
		h.Name="ESP_H"
		h.FillTransparency=0.5
		h.FillColor=p.Team and p.Team.TeamColor.Color or Color3.fromRGB(255,0,0)
	end

	if not p.Character:FindFirstChild("ESP_BOX") then
		local b=Instance.new("SelectionBox",p.Character)
		b.Name="ESP_BOX"
		b.Adornee=p.Character
		b.LineThickness=0.05
	end
end

ESPTab:CreateToggle({
	Name="ESP Players",
	Callback=function(v)
		espOn=v
		if not v then
			for _,p in ipairs(Players:GetPlayers()) do clearESP(p.Character) end
		end
	end
})

ESPTab:CreateDropdown({
	Name="ESP Player",
	Options=(function()
		local t={}
		for _,p in ipairs(Players:GetPlayers()) do
			if p~=LP then table.insert(t,p.Name) end
		end
		return t
	end)(),
	Callback=function(v) espPlayer=Players:FindFirstChild(v[1]) end
})

ESPTab:CreateDropdown({
	Name="ESP Team",
	Options=(function()
		local t={}
		for _,tm in ipairs(Teams:GetChildren()) do table.insert(t,tm.Name) end
		return t
	end)(),
	Callback=function(v) espTeam=Teams:FindFirstChild(v[1]) end
})

RS.Stepped:Connect(function()
	if espOn then
		for _,p in ipairs(Players:GetPlayers()) do applyESP(p) end
	end
end)

----------------------------------------------------
-- TELEPORT (MULTI SAVE)
----------------------------------------------------
local savedTPs = {}
local tpDropdown

local function refreshTP()
	if tpDropdown then
		tpDropdown:Set(savedTPs)
	end
end

tpDropdown = TPTab:CreateDropdown({
	Name="Saved Locations",
	Options=savedTPs,
	Callback=function(v)
		local cf = _G.TPLocations[v[1]]
		if cf then LP.Character.HumanoidRootPart.CFrame = cf end
	end
})

_G.TPLocations = {}

TPTab:CreateButton({
	Name="Save Current Location",
	Callback=function()
		local name = "Spot "..tostring(#savedTPs+1)
		_G.TPLocations[name] = LP.Character.HumanoidRootPart.CFrame
		table.insert(savedTPs,name)
		refreshTP()
	end
})

TPTab:CreateButton({
	Name="Delete All Locations",
	Callback=function()
		savedTPs={}
		_G.TPLocations={}
		refreshTP()
	end
})

----------------------------------------------------
-- VISUAL & MISC
----------------------------------------------------
VisualTab:CreateToggle({
	Name="FullBright",
	Callback=function(v)
		if v then
			Lighting.Brightness=5
			Lighting.ClockTime=14
			Lighting.FogEnd=1e6
		end
	end
})

VisualTab:CreateButton({
	Name="Rejoin Server",
	Callback=function()
		TeleportService:Teleport(game.PlaceId, LP)
	end
})
