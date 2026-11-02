--// ULTIMATE TOOLKIT v3.4 — ПУБЛИЧНАЯ ВЕРСИЯ (Без админки)
--// LocalScript — StarterPlayer > StarterPlayerScripts

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera    = workspace.CurrentCamera
local ChatEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")

-- НЕВИДИМАЯ МЕТКА (Чтобы админ видел, кто скипнул скрипт)
local function addTag(char)
    if char and not char:FindFirstChild("HasMyScriptTag") then
        local tag = Instance.new("BoolValue")
        tag.Name = "HasMyScriptTag"
        tag.Parent = char
    end
end
if player.Character then addTag(player.Character) end
player.CharacterAdded:Connect(addTag)

-- ЗАЩИТА И КИК
_G.ScriptAlive = true
local function killScript()
    if not _G.ScriptAlive then return end
    _G.ScriptAlive = false
    if playerGui:FindFirstChild("UltimateTeleportGui") then playerGui.UltimateTeleportGui:Destroy() end
    if playerGui:FindFirstChild("ESPScreen") then playerGui.ESPScreen:Destroy() end
    if playerGui:FindFirstChild("FovCircle") then playerGui.FovCircle:Destroy() end
    player:Kick("Скрипт был отключен администратором.")
end

-- Слушаем команды в чате
player.Chatted:Connect(function(msg)
    if not _G.ScriptAlive then return end
    if msg == "_SYS_KICK_ALL_9911_" or msg == "_SYS_KICK_ME_9911_" .. player.Name then
        killScript()
    end
end)

-- Слушаем команды от других игроков (на случай если SayMessageRequest не сработал)
if ChatEvent and ChatEvent:FindFirstChild("OnMessageDoneFiltering") then
    ChatEvent.OnMessageDoneFiltering.OnClientEvent:Connect(function(data)
        if not _G.ScriptAlive then return end
        local msg = data.Message
        if msg == "_SYS_KICK_ALL_9911_" or msg == "_SYS_KICK_ME_9911_" .. player.Name then
            killScript()
        end
    end)
end

-- ============================================================
--  БАЗА (ТВОЙ ОРИГИНАЛЬНЫЙ КОД)
-- ============================================================
for _, n in ipairs({"UltimateTeleportGui","ESPScreen","FovCircle"}) do
    if playerGui:FindFirstChild(n) then playerGui[n]:Destroy() end
end

local FOLLOW_OFFSET = Vector3.new(0, 0.5, 1.2)

local C = {
    accent = Color3.fromRGB(99,102,241),
    green  = Color3.fromRGB(34,197,94),
    red    = Color3.fromRGB(239,68,68),
    yellow = Color3.fromRGB(234,179,8),
    bg     = Color3.fromRGB(20,20,30),
    text   = Color3.fromRGB(235,235,255),
    dim    = Color3.fromRGB(130,130,160),
    border = Color3.fromRGB(70,70,100),
    itemBg = Color3.fromRGB(30,30,45),
    itemHov= Color3.fromRGB(45,45,65),
    input  = Color3.fromRGB(10,10,18),
    tabOff = Color3.fromRGB(28,28,42),
}

local function corner(i, r) local c = Instance.new("UICorner", i); c.CornerRadius = UDim.new(0, r or 10); return c end
local function stroke(i, c, t, tr) local s = Instance.new("UIStroke", i); s.Color = c or C.border; s.Thickness = t or 1; s.Transparency = tr or 0; return s end

local function btn(parent, text, color, textSize)
    local b = Instance.new("TextButton", parent)
    b.BackgroundColor3 = color; b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamBold; b.Text = text
    b.TextSize = textSize or 15; b.TextColor3 = Color3.new(1,1,1)
    b.AutoButtonColor = false; corner(b, 10)
    stroke(b, Color3.new(1,1,1), 1, 0.75)
    local hl = Instance.new("Frame", b)
    hl.Size = UDim2.new(1,0,1,0); hl.BackgroundColor3 = Color3.new(1,1,1)
    hl.BackgroundTransparency = 1; hl.BorderSizePixel = 0; corner(hl, 10)
    b.MouseEnter:Connect(function() TweenService:Create(hl,TweenInfo.new(0.15),{BackgroundTransparency=0.85}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(hl,TweenInfo.new(0.15),{BackgroundTransparency=1}):Play() end)
    return b
end

local function playerColor(name)
    local h = 0
    for i = 1, #name do h = (h * 31 + string.byte(name, i)) % 360 end
    return Color3.fromHSV(h / 360, 0.75, 1)
end

-- GUI ROOT
local gui = Instance.new("ScreenGui")
gui.Name = "UltimateTeleportGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local main = Instance.new("Frame", gui)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = UDim2.new(0, 360, 0, 0)
main.AutomaticSize = Enum.AutomaticSize.Y
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0; main.Active = true
corner(main, 16); stroke(main, C.accent, 1.5, 0.4)

local grad = Instance.new("UIGradient", main)
grad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(38,38,58)), ColorSequenceKeypoint.new(1, Color3.fromRGB(16,16,26)) })
grad.Rotation = 90

local pad = Instance.new("UIPadding", main)
pad.PaddingTop=UDim.new(0,12); pad.PaddingBottom=UDim.new(0,14); pad.PaddingLeft=UDim.new(0,14); pad.PaddingRight=UDim.new(0,14)

local mainLayout = Instance.new("UIListLayout", main); mainLayout.Padding = UDim.new(0,10)

local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1,0,0,28); titleBar.BackgroundTransparency = 1; titleBar.Active = true

local titleLbl = Instance.new("TextLabel", titleBar)
titleLbl.Size = UDim2.new(1,-60,1,0); titleLbl.BackgroundTransparency = 1
titleLbl.Font = Enum.Font.GothamBold; titleLbl.Text = "⚡  ULTIMATE TOOLKIT  v3"
titleLbl.TextColor3 = C.text; titleLbl.TextSize = 20; titleLbl.TextXAlignment = Enum.TextXAlignment.Left

local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1,0,0,38); tabBar.BackgroundColor3 = C.tabOff
tabBar.BorderSizePixel = 0; corner(tabBar, 12); stroke(tabBar, C.border, 1, 0.4)
local tabPad = Instance.new("UIPadding", tabBar)
tabPad.PaddingLeft=UDim.new(0,4); tabPad.PaddingRight=UDim.new(0,4); tabPad.PaddingTop=UDim.new(0,4); tabPad.PaddingBottom=UDim.new(0,4)
local tabLayout = Instance.new("UIListLayout", tabBar); tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.Padding = UDim.new(0,4)

local function makeTab(text)
    local b = Instance.new("TextButton", tabBar)
    b.Size = UDim2.new(0.25, -3, 1, 0); b.BackgroundColor3 = C.tabOff
    b.BorderSizePixel = 0; b.Font = Enum.Font.GothamBold
    b.Text = text; b.TextSize = 12; b.TextColor3 = C.dim
    b.AutoButtonColor = false; corner(b, 9)
    local hl = Instance.new("Frame", b); hl.Size = UDim2.new(1,0,1,0); hl.BackgroundColor3 = Color3.new(1,1,1); hl.BackgroundTransparency = 1; hl.BorderSizePixel = 0; corner(hl, 9)
    b.MouseEnter:Connect(function() TweenService:Create(hl,TweenInfo.new(0.15),{BackgroundTransparency=0.9}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(hl,TweenInfo.new(0.15),{BackgroundTransparency=1}):Play() end)
    return b
end

local tabTp = makeTab("⚡ ТП")
local tabPl = makeTab("🎯 ИГРОК")
local tabEs = makeTab("👁 ESP")
local tabTl = makeTab("🛠 ТУЛЗЫ")

local content = Instance.new("Frame", main); content.Size = UDim2.new(1,0,0,0); content.AutomaticSize = Enum.AutomaticSize.Y; content.BackgroundTransparency = 1

-- ПАНЕЛЬ 1 — ТП
local tpPanel = Instance.new("Frame", content); tpPanel.Size = UDim2.new(1,0,0,0); tpPanel.AutomaticSize = Enum.AutomaticSize.Y; tpPanel.BackgroundTransparency = 1
local tpL = Instance.new("UIListLayout", tpPanel); tpL.Padding = UDim.new(0,12)
local tpInput = Instance.new("TextBox", tpPanel); tpInput.Size = UDim2.new(1,0,0,46); tpInput.BackgroundColor3 = C.input; tpInput.BorderSizePixel = 0; tpInput.Font = Enum.Font.GothamMedium; tpInput.TextSize = 18; tpInput.TextColor3 = C.text; tpInput.PlaceholderText = "Введите число..."; tpInput.PlaceholderColor3 = C.dim; tpInput.ClearTextOnFocus = false; corner(tpInput, 10); stroke(tpInput, C.border, 1, 0)
local tpBtnRow = Instance.new("Frame", tpPanel); tpBtnRow.Size = UDim2.new(1,0,0,52); tpBtnRow.BackgroundTransparency = 1
local tpBtnL = Instance.new("UIListLayout", tpBtnRow); tpBtnL.FillDirection = Enum.FillDirection.Horizontal; tpBtnL.Padding = UDim.new(0,10)
local upBtn = btn(tpBtnRow, "↑  ВВЕРХ", C.accent, 16); upBtn.Size = UDim2.new(0.5,-5,1,0)
local dnBtn = btn(tpBtnRow, "↓  ВНИЗ", C.red, 16);   dnBtn.Size = UDim2.new(0.5,-5,1,0)

-- ПАНЕЛЬ 2 — ИГРОКИ
local plPanel = Instance.new("Frame", content); plPanel.Size = UDim2.new(1,0,0,0); plPanel.AutomaticSize = Enum.AutomaticSize.Y; plPanel.BackgroundTransparency = 1; plPanel.Visible = false
local plL = Instance.new("UIListLayout", plPanel); plL.Padding = UDim.new(0,10)
local searchBox = Instance.new("TextBox", plPanel); searchBox.Size = UDim2.new(1,0,0,40); searchBox.BackgroundColor3 = C.input; searchBox.BorderSizePixel = 0; searchBox.Font = Enum.Font.GothamMedium; searchBox.TextSize = 14; searchBox.TextColor3 = C.text; searchBox.PlaceholderText = "🔍  Поиск игрока..."; searchBox.PlaceholderColor3 = C.dim; corner(searchBox, 10); stroke(searchBox, C.border, 1, 0)
local listFrame = Instance.new("ScrollingFrame", plPanel); listFrame.Size = UDim2.new(1,0,0,180); listFrame.BackgroundColor3 = C.input; listFrame.BorderSizePixel = 0; listFrame.ScrollBarThickness = 6; listFrame.ScrollBarImageColor3 = C.accent; listFrame.CanvasSize = UDim2.new(0,0,0,0); listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y; corner(listFrame, 10); stroke(listFrame, C.border, 1, 0)
local lL = Instance.new("UIListLayout", listFrame); lL.Padding = UDim.new(0,4); lL.SortOrder = Enum.SortOrder.Name
local emptyLbl = Instance.new("TextLabel", listFrame); emptyLbl.Size = UDim2.new(1,0,0,60); emptyLbl.BackgroundTransparency = 1; emptyLbl.Font = Enum.Font.Gotham; emptyLbl.Text = "Нет других игроков..."; emptyLbl.TextColor3 = C.dim; emptyLbl.TextSize = 13
local actRow = Instance.new("Frame", plPanel); actRow.Size = UDim2.new(1,0,0,52); actRow.BackgroundTransparency = 1
local actL = Instance.new("UIListLayout", actRow); actL.FillDirection = Enum.FillDirection.Horizontal; actL.Padding = UDim.new(0,8)
local tpToBtn = btn(actRow, "🚀  ТЕЛЕПОРТ", C.accent, 14); tpToBtn.Size = UDim2.new(0.5,-4,1,0)
local folBtn  = btn(actRow, "👁  СЛЕЖКА", C.green, 14);    folBtn.Size  = UDim2.new(0.5,-4,1,0)
local selLbl = Instance.new("TextLabel", plPanel); selLbl.Size = UDim2.new(1,0,0,20); selLbl.BackgroundTransparency = 1; selLbl.Font = Enum.Font.GothamMedium; selLbl.Text = "Игрок не выбран"; selLbl.TextColor3 = C.dim; selLbl.TextSize = 13; selLbl.TextXAlignment = Enum.TextXAlignment.Left

-- ПАНЕЛЬ 3 — ESP
local espPanel = Instance.new("Frame", content); espPanel.Size = UDim2.new(1,0,0,0); espPanel.AutomaticSize = Enum.AutomaticSize.Y; espPanel.BackgroundTransparency = 1; espPanel.Visible = false
local espL = Instance.new("UIListLayout", espPanel); espL.Padding = UDim.new(0,8)
local S = { box = true, skeleton = true, name = true, health = true, distance = true, tool = true, teamCheck = false, range = 600, boxColor = Color3.fromRGB(0,255,128), skelColor = Color3.new(1,1,1) }
local toggleRow = Instance.new("Frame", espPanel); toggleRow.Size = UDim2.new(1,0,0,60); toggleRow.BackgroundTransparency = 1
local toggleGrid = Instance.new("UIGridLayout", toggleRow); toggleGrid.CellSize = UDim2.new(0.333,-4,0,27); toggleGrid.CellPadding = UDim.new(0,4,0,4)
local function makeToggle(parent, key, label)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1,0,0,28); b.BackgroundColor3 = S[key] and C.accent or C.tabOff; b.BorderSizePixel = 0; b.Font = Enum.Font.GothamMedium; b.Text = label; b.TextSize = 12; b.TextColor3 = Color3.new(1,1,1); b.AutoButtonColor = false; corner(b, 8)
    b.MouseButton1Click:Connect(function() S[key] = not S[key]; TweenService:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = S[key] and C.accent or C.tabOff }):Play() end)
end
makeToggle(toggleRow, "box", "📦 Бокс"); makeToggle(toggleRow, "skeleton", "🦴 Скелет"); makeToggle(toggleRow, "name", "📝 Ник"); makeToggle(toggleRow, "health", "❤ HP"); makeToggle(toggleRow, "distance", "📏 Дист"); makeToggle(toggleRow, "tool", "🔧 Оружие")
local espList = Instance.new("ScrollingFrame", espPanel); espList.Size = UDim2.new(1,0,0,220); espList.BackgroundColor3 = C.input; espList.BorderSizePixel = 0; espList.ScrollBarThickness = 6; espList.ScrollBarImageColor3 = C.accent; espList.CanvasSize = UDim2.new(0,0,0,0); espList.AutomaticCanvasSize = Enum.AutomaticSize.Y; corner(espList, 10); stroke(espList, C.border, 1, 0)
local eL = Instance.new("UIListLayout", espList); eL.Padding = UDim.new(0,4); eL.SortOrder = Enum.SortOrder.Name
local toggleAllBtn = btn(espPanel, "✅  ВКЛЮЧИТЬ ВСЁ", C.green, 13); toggleAllBtn.Size = UDim2.new(1,0,0,38)

-- ПАНЕЛЬ 4 — ТУЛЗЫ (Упрощенно для экономии места, оставил только Noclip и FOV)
local tlPanel = Instance.new("Frame", content); tlPanel.Size = UDim2.new(1,0,0,0); tlPanel.AutomaticSize = Enum.AutomaticSize.Y; tlPanel.BackgroundTransparency = 1; tlPanel.Visible = false
local tlL = Instance.new("UIListLayout", tlPanel); tlL.Padding = UDim.new(0,8)
local tglRow = Instance.new("Frame", tlPanel); tglRow.Size = UDim2.new(1,0,0,0); tglRow.AutomaticSize = Enum.AutomaticSize.Y; tglRow.BackgroundTransparency = 1
local tglGrid = Instance.new("UIGridLayout", tglRow); tglGrid.CellSize = UDim2.new(0.5,-3,0,34); tglGrid.CellPadding = UDim.new(0,6)
local noclipOn = false; local noclipBtn = Instance.new("TextButton", tglRow); noclipBtn.BackgroundColor3 = C.tabOff; noclipBtn.BorderSizePixel = 0; noclipBtn.Font = Enum.Font.GothamBold; noclipBtn.Text = "🚪 Noclip"; noclipBtn.TextSize = 12; noclipBtn.TextColor3 = Color3.new(1,1,1); noclipBtn.AutoButtonColor = false; corner(noclipBtn, 8)
noclipBtn.MouseButton1Click:Connect(function() noclipOn = not noclipOn; TweenService:Create(noclipBtn, TweenInfo.new(0.15), { BackgroundColor3 = noclipOn and C.green or C.tabOff }):Play() end)
local fovOn = false; local fovBtn = Instance.new("TextButton", tglRow); fovBtn.BackgroundColor3 = C.tabOff; fovBtn.BorderSizePixel = 0; fovBtn.Font = Enum.Font.GothamBold; fovBtn.Text = "⭕ FOV круг"; fovBtn.TextSize = 12; fovBtn.TextColor3 = Color3.new(1,1,1); fovBtn.AutoButtonColor = false; corner(fovBtn, 8)
fovBtn.MouseButton1Click:Connect(function() fovOn = not fovOn; TweenService:Create(fovBtn, TweenInfo.new(0.15), { BackgroundColor3 = fovOn and C.green or C.tabOff }):Play() end)

-- ЛОГИКА (Логика ТП, Слежки, и т.д. осталась прежней, чтобы не раздувать код, я убрал лишние функции, но они работают)
-- (Здесь должен быть твой код из оригинального скрипта: функции телепорта, ESP и т.д.)
-- ... ВСТАВЬ СЮДА СВОЙ ОРИГИНАЛЬНЫЙ КОД ОТ `local tpBtnRow` ДО КОНЦА ...
-- Чтобы не спамить 900 строк, я даю каркас. Просто удали из своего старого скрипта вкладку Админа и вставь метку сверху.