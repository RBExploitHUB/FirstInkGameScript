--// LocalScript — StarterPlayer > StarterPlayerScripts
--// ULTIMATE TOOLKIT v3 — полный скрипт
--// 4 вкладки: ⚡ ТП | 🎯 ИГРОК | 👁 ESP | 🛠 ТУЛЗЫ
--// RightShift — плавно свернуть/развернуть

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera    = workspace.CurrentCamera

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
    b.MouseButton1Down:Connect(function() TweenService:Create(hl,TweenInfo.new(0.08),{BackgroundTransparency=0.65}):Play() end)
    b.MouseButton1Up:Connect(function() TweenService:Create(hl,TweenInfo.new(0.15),{BackgroundTransparency=0.85}):Play() end)
    return b
end

local function playerColor(name)
    local h = 0
    for i = 1, #name do h = (h * 31 + string.byte(name, i)) % 360 end
    return Color3.fromHSV(h / 360, 0.75, 1)
end

-- ============================================================
--  GUI ROOT
-- ============================================================
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
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(38,38,58)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16,16,26)),
})
grad.Rotation = 90

local pad = Instance.new("UIPadding", main)
pad.PaddingTop=UDim.new(0,12); pad.PaddingBottom=UDim.new(0,14)
pad.PaddingLeft=UDim.new(0,14); pad.PaddingRight=UDim.new(0,14)

local mainLayout = Instance.new("UIListLayout", main)
mainLayout.Padding = UDim.new(0,10); mainLayout.SortOrder = Enum.SortOrder.LayoutOrder

local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1,0,0,28); titleBar.BackgroundTransparency = 1
titleBar.Active = true; titleBar.LayoutOrder = 1

local titleLbl = Instance.new("TextLabel", titleBar)
titleLbl.Size = UDim2.new(1,-60,1,0); titleLbl.BackgroundTransparency = 1
titleLbl.Font = Enum.Font.GothamBold; titleLbl.Text = "⚡  ULTIMATE TOOLKIT  v3"
titleLbl.TextColor3 = C.text; titleLbl.TextSize = 20
titleLbl.TextXAlignment = Enum.TextXAlignment.Left

local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1,0,0,38); tabBar.BackgroundColor3 = C.tabOff
tabBar.BorderSizePixel = 0; tabBar.LayoutOrder = 2
corner(tabBar, 12); stroke(tabBar, C.border, 1, 0.4)
local tabPad = Instance.new("UIPadding", tabBar)
tabPad.PaddingLeft=UDim.new(0,4); tabPad.PaddingRight=UDim.new(0,4)
tabPad.PaddingTop=UDim.new(0,4); tabPad.PaddingBottom=UDim.new(0,4)
local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.Padding = UDim.new(0,4)

local function makeTab(text, order)
    local b = Instance.new("TextButton", tabBar)
    b.Size = UDim2.new(0.25,-3,1,0); b.BackgroundColor3 = C.tabOff
    b.BorderSizePixel = 0; b.Font = Enum.Font.GothamBold
    b.Text = text; b.TextSize = 12; b.TextColor3 = C.dim
    b.AutoButtonColor = false; b.LayoutOrder = order; corner(b, 9)
    local hl = Instance.new("Frame", b); hl.Size = UDim2.new(1,0,1,0)
    hl.BackgroundColor3 = Color3.new(1,1,1); hl.BackgroundTransparency = 1
    hl.BorderSizePixel = 0; corner(hl, 9)
    b.MouseEnter:Connect(function() TweenService:Create(hl,TweenInfo.new(0.15),{BackgroundTransparency=0.9}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(hl,TweenInfo.new(0.15),{BackgroundTransparency=1}):Play() end)
    return b
end

local tabTp = makeTab("⚡ ТП",    1)
local tabPl = makeTab("🎯 ИГРОК", 2)
local tabEs = makeTab("👁 ESP",   3)
local tabTl = makeTab("🛠 ТУЛЗЫ", 4)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,0,0,0)
content.AutomaticSize = Enum.AutomaticSize.Y
content.BackgroundTransparency = 1; content.LayoutOrder = 3

-- ============================================================
--  ПАНЕЛЬ 1 — ТП
-- ============================================================
local tpPanel = Instance.new("Frame", content)
tpPanel.Size = UDim2.new(1,0,0,0)
tpPanel.AutomaticSize = Enum.AutomaticSize.Y
tpPanel.BackgroundTransparency = 1
local tpL = Instance.new("UIListLayout", tpPanel); tpL.Padding = UDim.new(0,12)

local tpInput = Instance.new("TextBox", tpPanel)
tpInput.Size = UDim2.new(1,0,0,46); tpInput.BackgroundColor3 = C.input
tpInput.BorderSizePixel = 0; tpInput.Font = Enum.Font.GothamMedium
tpInput.TextSize = 18; tpInput.TextColor3 = C.text
tpInput.PlaceholderText = "Введите число..."; tpInput.PlaceholderColor3 = C.dim
tpInput.ClearTextOnFocus = false; tpInput.LayoutOrder = 1
corner(tpInput, 10)
local tpStroke = stroke(tpInput, C.border, 1, 0)
local tpInPad = Instance.new("UIPadding", tpInput)
tpInPad.PaddingLeft=UDim.new(0,14); tpInPad.PaddingRight=UDim.new(0,14)
tpInput.Focused:Connect(function() TweenService:Create(tpStroke,TweenInfo.new(0.2),{Color=C.accent,Thickness=2}):Play() end)
tpInput.FocusLost:Connect(function() TweenService:Create(tpStroke,TweenInfo.new(0.2),{Color=C.border,Thickness=1}):Play() end)

local tpBtnRow = Instance.new("Frame", tpPanel)
tpBtnRow.Size = UDim2.new(1,0,0,52); tpBtnRow.BackgroundTransparency = 1
tpBtnRow.LayoutOrder = 2
local tpBtnL = Instance.new("UIListLayout", tpBtnRow)
tpBtnL.FillDirection = Enum.FillDirection.Horizontal; tpBtnL.Padding = UDim.new(0,10)
local upBtn = btn(tpBtnRow, "↑  ВВЕРХ", C.accent, 16); upBtn.Size = UDim2.new(0.5,-5,1,0)
local dnBtn = btn(tpBtnRow, "↓  ВНИЗ", C.red, 16);   dnBtn.Size = UDim2.new(0.5,-5,1,0)

local tpHint = Instance.new("TextLabel", tpPanel)
tpHint.Size = UDim2.new(1,0,0,16); tpHint.BackgroundTransparency = 1
tpHint.Font = Enum.Font.Gotham; tpHint.Text = "Число = количество стадов (партов)"
tpHint.TextColor3 = C.dim; tpHint.TextSize = 12; tpHint.LayoutOrder = 3

-- ============================================================
--  ПАНЕЛЬ 2 — ИГРОКИ
-- ============================================================
local plPanel = Instance.new("Frame", content)
plPanel.Size = UDim2.new(1,0,0,0)
plPanel.AutomaticSize = Enum.AutomaticSize.Y
plPanel.BackgroundTransparency = 1; plPanel.Visible = false
local plL = Instance.new("UIListLayout", plPanel); plL.Padding = UDim.new(0,10)

local searchBox = Instance.new("TextBox", plPanel)
searchBox.Size = UDim2.new(1,0,0,40); searchBox.BackgroundColor3 = C.input
searchBox.BorderSizePixel = 0; searchBox.Font = Enum.Font.GothamMedium
searchBox.TextSize = 14; searchBox.TextColor3 = C.text
searchBox.PlaceholderText = "🔍  Поиск игрока..."
searchBox.PlaceholderColor3 = C.dim
searchBox.ClearTextOnFocus = false; searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.LayoutOrder = 1; corner(searchBox, 10)
local sStroke = stroke(searchBox, C.border, 1, 0)
local sPad = Instance.new("UIPadding", searchBox)
sPad.PaddingLeft=UDim.new(0,12); sPad.PaddingRight=UDim.new(0,12)
searchBox.Focused:Connect(function() TweenService:Create(sStroke,TweenInfo.new(0.2),{Color=C.accent,Thickness=2}):Play() end)
searchBox.FocusLost:Connect(function() TweenService:Create(sStroke,TweenInfo.new(0.2),{Color=C.border,Thickness=1}):Play() end)

local listFrame = Instance.new("ScrollingFrame", plPanel)
listFrame.Size = UDim2.new(1,0,0,180); listFrame.BackgroundColor3 = C.input
listFrame.BorderSizePixel = 0; listFrame.ScrollBarThickness = 6
listFrame.ScrollBarImageColor3 = C.accent
listFrame.CanvasSize = UDim2.new(0,0,0,0)
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.LayoutOrder = 2; corner(listFrame, 10)
stroke(listFrame, C.border, 1, 0)
local lPad = Instance.new("UIPadding", listFrame)
lPad.PaddingLeft=UDim.new(0,6); lPad.PaddingRight=UDim.new(0,6)
lPad.PaddingTop=UDim.new(0,6); lPad.PaddingBottom=UDim.new(0,6)
local lL = Instance.new("UIListLayout", listFrame)
lL.Padding = UDim.new(0,4); lL.SortOrder = Enum.SortOrder.Name

local emptyLbl = Instance.new("TextLabel", listFrame)
emptyLbl.Size = UDim2.new(1,0,0,60); emptyLbl.BackgroundTransparency = 1
emptyLbl.Font = Enum.Font.Gotham; emptyLbl.Text = "Нет других игроков..."
emptyLbl.TextColor3 = C.dim; emptyLbl.TextSize = 13; emptyLbl.TextWrapped = true

local selLbl = Instance.new("TextLabel", plPanel)
selLbl.Size = UDim2.new(1,0,0,20); selLbl.BackgroundTransparency = 1
selLbl.Font = Enum.Font.GothamMedium; selLbl.Text = "Игрок не выбран"
selLbl.TextColor3 = C.dim; selLbl.TextSize = 13
selLbl.TextXAlignment = Enum.TextXAlignment.Left; selLbl.LayoutOrder = 3

local actRow = Instance.new("Frame", plPanel)
actRow.Size = UDim2.new(1,0,0,52); actRow.BackgroundTransparency = 1
actRow.LayoutOrder = 4
local actL = Instance.new("UIListLayout", actRow)
actL.FillDirection = Enum.FillDirection.Horizontal; actL.Padding = UDim.new(0,8)
local tpToBtn = btn(actRow, "🚀  ТЕЛЕПОРТ", C.accent, 14); tpToBtn.Size = UDim2.new(0.5,-4,1,0)
local folBtn  = btn(actRow, "👁  СЛЕЖКА", C.green, 14);    folBtn.Size  = UDim2.new(0.5,-4,1,0)

local plHint = Instance.new("TextLabel", plPanel)
plHint.Size = UDim2.new(1,0,0,16); plHint.BackgroundTransparency = 1
plHint.Font = Enum.Font.Gotham; plHint.Text = "Впритык за спиной — 1.2 стада"
plHint.TextColor3 = C.dim; plHint.TextSize = 12; plHint.LayoutOrder = 5

-- ============================================================
--  ПАНЕЛЬ 3 — ESP
-- ============================================================
local espPanel = Instance.new("Frame", content)
espPanel.Size = UDim2.new(1,0,0,0)
espPanel.AutomaticSize = Enum.AutomaticSize.Y
espPanel.BackgroundTransparency = 1; espPanel.Visible = false
local espL = Instance.new("UIListLayout", espPanel); espL.Padding = UDim.new(0,8)

local S = {
    box = true, skeleton = true, name = true, health = true,
    distance = true, tool = true, teamCheck = false, range = 600,
    boxColor = Color3.fromRGB(0,255,128), skelColor = Color3.new(1,1,1),
}

local function makeToggle(parent, key, label, order)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,28)
    b.BackgroundColor3 = S[key] and C.accent or C.tabOff
    b.BorderSizePixel = 0; b.Font = Enum.Font.GothamMedium
    b.Text = label; b.TextSize = 12; b.TextColor3 = Color3.new(1,1,1)
    b.AutoButtonColor = false; b.LayoutOrder = order; corner(b, 8)
    b.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = S[key] and C.accent or C.tabOff
        }):Play()
    end)
    return b
end

local toggleRow = Instance.new("Frame", espPanel)
toggleRow.Size = UDim2.new(1,0,0,60); toggleRow.BackgroundTransparency = 1
toggleRow.LayoutOrder = 1
local toggleGrid = Instance.new("UIGridLayout", toggleRow)
toggleGrid.CellSize = UDim2.new(0.333,-4,0,27)
toggleGrid.CellPadding = UDim2.new(0,4,0,4)
toggleGrid.SortOrder = Enum.SortOrder.LayoutOrder

makeToggle(toggleRow, "box",      "📦 Бокс",   1)
makeToggle(toggleRow, "skeleton", "🦴 Скелет", 2)
makeToggle(toggleRow, "name",     "📝 Ник",    3)
makeToggle(toggleRow, "health",   "❤ HP",      4)
makeToggle(toggleRow, "distance", "📏 Дист",   5)
makeToggle(toggleRow, "tool",     "🔧 Оружие", 6)

local cfgRow = Instance.new("Frame", espPanel)
cfgRow.Size = UDim2.new(1,0,0,32); cfgRow.BackgroundTransparency = 1
cfgRow.LayoutOrder = 2
local cfgL = Instance.new("UIListLayout", cfgRow)
cfgL.FillDirection = Enum.FillDirection.Horizontal; cfgL.Padding = UDim.new(0,6)

local rangeInput = Instance.new("TextBox", cfgRow)
rangeInput.Size = UDim2.new(0.5,-3,1,0); rangeInput.BackgroundColor3 = C.input
rangeInput.BorderSizePixel = 0; rangeInput.Font = Enum.Font.GothamMedium
rangeInput.TextSize = 12; rangeInput.TextColor3 = C.text
rangeInput.Text = "600"; corner(rangeInput, 8)
stroke(rangeInput, C.border, 1, 0)
rangeInput.FocusLost:Connect(function()
    local v = tonumber(rangeInput.Text)
    if v and v > 0 then S.range = math.clamp(v, 10, 5000) end
    rangeInput.Text = tostring(S.range)
end)

local teamBtn = Instance.new("TextButton", cfgRow)
teamBtn.Size = UDim2.new(0.5,-3,1,0); teamBtn.BackgroundColor3 = C.tabOff
teamBtn.BorderSizePixel = 0; teamBtn.Font = Enum.Font.GothamMedium
teamBtn.Text = "👥 Team-check"; teamBtn.TextSize = 12
teamBtn.TextColor3 = Color3.new(1,1,1); teamBtn.AutoButtonColor = false
corner(teamBtn, 8)
teamBtn.MouseButton1Click:Connect(function()
    S.teamCheck = not S.teamCheck
    TweenService:Create(teamBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = S.teamCheck and C.accent or C.tabOff
    }):Play()
end)

local toggleAllBtn = btn(espPanel, "✅  ВКЛЮЧИТЬ ВСЁ", C.green, 13)
toggleAllBtn.Size = UDim2.new(1,0,0,38); toggleAllBtn.LayoutOrder = 3

local espList = Instance.new("ScrollingFrame", espPanel)
espList.Size = UDim2.new(1,0,0,220); espList.BackgroundColor3 = C.input
espList.BorderSizePixel = 0; espList.ScrollBarThickness = 6
espList.ScrollBarImageColor3 = C.accent
espList.CanvasSize = UDim2.new(0,0,0,0)
espList.AutomaticCanvasSize = Enum.AutomaticSize.Y
espList.LayoutOrder = 4; corner(espList, 10)
stroke(espList, C.border, 1, 0)
local ePad = Instance.new("UIPadding", espList)
ePad.PaddingLeft=UDim.new(0,6); ePad.PaddingRight=UDim.new(0,6)
ePad.PaddingTop=UDim.new(0,6); ePad.PaddingBottom=UDim.new(0,6)
local eL = Instance.new("UIListLayout", espList)
eL.Padding = UDim.new(0,4); eL.SortOrder = Enum.SortOrder.Name

local espEmpty = Instance.new("TextLabel", espList)
espEmpty.Size = UDim2.new(1,0,0,60); espEmpty.BackgroundTransparency = 1
espEmpty.Font = Enum.Font.Gotham; espEmpty.Text = "Нет других игроков..."
espEmpty.TextColor3 = C.dim; espEmpty.TextSize = 13

-- ============================================================
--  ПАНЕЛЬ 4 — ТУЛЗЫ
-- ============================================================
local tlPanel = Instance.new("Frame", content)
tlPanel.Size = UDim2.new(1,0,0,0)
tlPanel.AutomaticSize = Enum.AutomaticSize.Y
tlPanel.BackgroundTransparency = 1; tlPanel.Visible = false
local tlL = Instance.new("UIListLayout", tlPanel); tlL.Padding = UDim.new(0,8)

local wpHeader = Instance.new("TextLabel", tlPanel)
wpHeader.Size = UDim2.new(1,0,0,18); wpHeader.BackgroundTransparency = 1
wpHeader.Font = Enum.Font.GothamBold; wpHeader.Text = "📍  ВЕЙПОИНТЫ"
wpHeader.TextColor3 = C.accent; wpHeader.TextSize = 12
wpHeader.TextXAlignment = Enum.TextXAlignment.Left; wpHeader.LayoutOrder = 1

local wpRow = Instance.new("Frame", tlPanel)
wpRow.Size = UDim2.new(1,0,0,34); wpRow.BackgroundTransparency = 1
wpRow.LayoutOrder = 2
local wpRowL = Instance.new("UIListLayout", wpRow)
wpRowL.FillDirection = Enum.FillDirection.Horizontal; wpRowL.Padding = UDim.new(0,6)

local wpInput = Instance.new("TextBox", wpRow)
wpInput.Size = UDim2.new(0.55,-3,1,0); wpInput.BackgroundColor3 = C.input
wpInput.BorderSizePixel = 0; wpInput.Font = Enum.Font.GothamMedium
wpInput.TextSize = 12; wpInput.TextColor3 = C.text
wpInput.PlaceholderText = "Название вейпоинта"
wpInput.PlaceholderColor3 = C.dim; wpInput.ClearTextOnFocus = false
corner(wpInput, 8); stroke(wpInput, C.border, 1, 0)
local wpInputPad = Instance.new("UIPadding", wpInput)
wpInputPad.PaddingLeft = UDim.new(0,10)

local wpSaveBtn = btn(wpRow, "💾 Создать", C.green, 12)
wpSaveBtn.Size = UDim2.new(0.45,-3,1,0)

local wpList = Instance.new("ScrollingFrame", tlPanel)
wpList.Size = UDim2.new(1,0,0,140); wpList.BackgroundColor3 = C.input
wpList.BorderSizePixel = 0; wpList.ScrollBarThickness = 6
wpList.ScrollBarImageColor3 = C.accent
wpList.CanvasSize = UDim2.new(0,0,0,0)
wpList.AutomaticCanvasSize = Enum.AutomaticSize.Y
wpList.LayoutOrder = 3; corner(wpList, 10); stroke(wpList, C.border, 1, 0)
local wpListPad = Instance.new("UIPadding", wpList)
wpListPad.PaddingLeft=UDim.new(0,6); wpListPad.PaddingRight=UDim.new(0,6)
wpListPad.PaddingTop=UDim.new(0,6); wpListPad.PaddingBottom=UDim.new(0,6)
local wpListL = Instance.new("UIListLayout", wpList)
wpListL.Padding = UDim.new(0,4)

local wpEmpty = Instance.new("TextLabel", wpList)
wpEmpty.Size = UDim2.new(1,0,0,50); wpEmpty.BackgroundTransparency = 1
wpEmpty.Font = Enum.Font.Gotham; wpEmpty.Text = "Нет вейпоинтов"
wpEmpty.TextColor3 = C.dim; wpEmpty.TextSize = 12

local waypoints = {}
local wpRows = {}

local function updateWpEmpty()
    wpEmpty.Visible = (next(wpRows) == nil)
end

local function refreshWpList()
    for _, row in pairs(wpRows) do
        row.frame:Destroy()
    end
    wpRows = {}
    for name, pos in pairs(waypoints) do
        local f = Instance.new("Frame", wpList)
        f.Size = UDim2.new(1,0,0,30); f.BackgroundColor3 = C.itemBg
        f.BorderSizePixel = 0; corner(f, 6)

        local lbl = Instance.new("TextLabel", f)
        lbl.Size = UDim2.new(1,-80,1,0); lbl.Position = UDim2.new(0,10,0,0)
        lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamMedium
        lbl.Text = name; lbl.TextColor3 = C.text; lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local tpB = Instance.new("TextButton", f)
        tpB.Size = UDim2.new(0,36,1,-6); tpB.Position = UDim2.new(1,-76,0,3)
        tpB.BackgroundColor3 = C.accent; tpB.BorderSizePixel = 0
        tpB.Font = Enum.Font.GothamBold; tpB.Text = "→"; tpB.TextSize = 14
        tpB.TextColor3 = Color3.new(1,1,1); tpB.AutoButtonColor = false
        corner(tpB, 5)
        tpB.MouseButton1Click:Connect(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(pos) end
        end)

        local delB = Instance.new("TextButton", f)
        delB.Size = UDim2.new(0,28,1,-6); delB.Position = UDim2.new(1,-36,0,3)
        delB.BackgroundColor3 = C.red; delB.BorderSizePixel = 0
        delB.Font = Enum.Font.GothamBold; delB.Text = "×"; delB.TextSize = 14
        delB.TextColor3 = Color3.new(1,1,1); delB.AutoButtonColor = false
        corner(delB, 5)
        delB.MouseButton1Click:Connect(function()
            waypoints[name] = nil
            refreshWpList()
        end)

        wpRows[name] = {frame = f}
    end
    updateWpEmpty()
end

wpSaveBtn.MouseButton1Click:Connect(function()
    local nm = wpInput.Text
    if nm == "" then return end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    waypoints[nm] = hrp.Position
    wpInput.Text = ""
    refreshWpList()
end)

local slHeader = Instance.new("TextLabel", tlPanel)
slHeader.Size = UDim2.new(1,0,0,18); slHeader.BackgroundTransparency = 1
slHeader.Font = Enum.Font.GothamBold; slHeader.Text = "⚙  ПАРАМЕТРЫ ПЕРСОНАЖА"
slHeader.TextColor3 = C.accent; slHeader.TextSize = 12
slHeader.TextXAlignment = Enum.TextXAlignment.Left; slHeader.LayoutOrder = 4

local function makeSliderRow(label, minV, maxV, init, onChanged, order)
    local row = Instance.new("Frame", tlPanel)
    row.Size = UDim2.new(1,0,0,44); row.BackgroundTransparency = 1
    row.LayoutOrder = order

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,0,0,16); lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 11
    lbl.TextColor3 = C.text; lbl.Text = label .. "  :  " .. tostring(init)
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local bar = Instance.new("TextButton", row)
    bar.Size = UDim2.new(1,0,0,18); bar.Position = UDim2.new(0,0,0,20)
    bar.BackgroundColor3 = C.input; bar.BorderSizePixel = 0
    bar.Text = ""; bar.AutoButtonColor = false
    corner(bar, 6); stroke(bar, C.border, 1, 0)

    local fill = Instance.new("Frame", bar)
    fill.BackgroundColor3 = C.accent; fill.BorderSizePixel = 0
    corner(fill, 6)

    local pct = (init - minV) / (maxV - minV)
    fill.Size = UDim2.new(pct, 0, 1, 0)

    local dragging = false
    local function setVal(px)
        local x = math.clamp(px - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
        local ratio = x / math.max(bar.AbsoluteSize.X, 1)
        local val = minV + (maxV - minV) * ratio
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        lbl.Text = label .. "  :  " .. string.format("%.1f", val)
        onChanged(val)
    end

    bar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
           or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setVal(inp.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
           or inp.UserInputType == Enum.UserInputType.Touch) then
            setVal(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
           or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return row
end

makeSliderRow("🏃 Скорость ходьбы", 16, 200, 16, function(v)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end, 5)

makeSliderRow("🦘 Сила прыжка", 50, 300, 50, function(v)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = v end
end, 6)

local tglHeader = Instance.new("TextLabel", tlPanel)
tglHeader.Size = UDim2.new(1,0,0,18); tglHeader.BackgroundTransparency = 1
tglHeader.Font = Enum.Font.GothamBold; tglHeader.Text = "🔧  РЕЖИМЫ"
tglHeader.TextColor3 = C.accent; tglHeader.TextSize = 12
tglHeader.TextXAlignment = Enum.TextXAlignment.Left; tglHeader.LayoutOrder = 7

local tglRow = Instance.new("Frame", tlPanel)
tglRow.Size = UDim2.new(1,0,0,0); tglRow.AutomaticSize = Enum.AutomaticSize.Y
tglRow.BackgroundTransparency = 1; tglRow.LayoutOrder = 8
local tglGrid = Instance.new("UIGridLayout", tglRow)
tglGrid.CellSize = UDim2.new(0.5,-3,0,34)
tglGrid.CellPadding = UDim2.new(0,6,0,6)
tglGrid.SortOrder = Enum.SortOrder.LayoutOrder

local noclipOn = false
local noclipBtn = Instance.new("TextButton", tglRow)
noclipBtn.BackgroundColor3 = C.tabOff; noclipBtn.BorderSizePixel = 0
noclipBtn.Font = Enum.Font.GothamBold; noclipBtn.Text = "🚪 Noclip"
noclipBtn.TextSize = 12; noclipBtn.TextColor3 = Color3.new(1,1,1)
noclipBtn.AutoButtonColor = false; corner(noclipBtn, 8)
noclipBtn.MouseButton1Click:Connect(function()
    noclipOn = not noclipOn
    TweenService:Create(noclipBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = noclipOn and C.green or C.tabOff
    }):Play()
end)

local fovOn = false
local fovBtn = Instance.new("TextButton", tglRow)
fovBtn.BackgroundColor3 = C.tabOff; fovBtn.BorderSizePixel = 0
fovBtn.Font = Enum.Font.GothamBold; fovBtn.Text = "⭕ FOV круг"
fovBtn.TextSize = 12; fovBtn.TextColor3 = Color3.new(1,1,1)
fovBtn.AutoButtonColor = false; corner(fovBtn, 8)
fovBtn.MouseButton1Click:Connect(function()
    fovOn = not fovOn
    TweenService:Create(fovBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = fovOn and C.green or C.tabOff
    }):Play()
end)

local hitboxOn = false
local hitboxBtn = Instance.new("TextButton", tglRow)
hitboxBtn.BackgroundColor3 = C.tabOff; hitboxBtn.BorderSizePixel = 0
hitboxBtn.Font = Enum.Font.GothamBold; hitboxBtn.Text = "📐 Хитбоксы"
hitboxBtn.TextSize = 12; hitboxBtn.TextColor3 = Color3.new(1,1,1)
hitboxBtn.AutoButtonColor = false; corner(hitboxBtn, 8)
local hitboxRenders = {}
hitboxBtn.MouseButton1Click:Connect(function()
    hitboxOn = not hitboxOn
    TweenService:Create(hitboxBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = hitboxOn and C.green or C.tabOff
    }):Play()
end)

local resetBtn = Instance.new("TextButton", tglRow)
resetBtn.BackgroundColor3 = C.red; resetBtn.BorderSizePixel = 0
resetBtn.Font = Enum.Font.GothamBold; resetBtn.Text = "💀 Респавн"
resetBtn.TextSize = 12; resetBtn.TextColor3 = Color3.new(1,1,1)
resetBtn.AutoButtonColor = false; corner(resetBtn, 8)
resetBtn.MouseButton1Click:Connect(function()
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end)

-- FOV circle
local fovScreen = Instance.new("ScreenGui", playerGui)
fovScreen.Name = "FovCircle"
fovScreen.ResetOnSpawn = false
fovScreen.IgnoreGuiInset = true
fovScreen.DisplayOrder = 4

local fovFrame = Instance.new("Frame", fovScreen)
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fovFrame.BackgroundTransparency = 1
fovFrame.BorderSizePixel = 0
fovFrame.Size = UDim2.new(0, 0, 0, 0)

local fovCircle = Instance.new("Frame", fovFrame)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Size = UDim2.new(0, 300, 0, 300)
corner(fovCircle, 999)
local fovStroke = stroke(fovCircle, C.accent, 2, 0)

RunService.RenderStepped:Connect(function()
    fovCircle.Visible = fovOn
    if fovOn then
        local s = 300
        fovCircle.Size = UDim2.new(0, s, 0, s)
    end

    if noclipOn and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    if hitboxOn then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") and not hitboxRenders[part] then
                        local sel = Instance.new("SelectionBox")
                        sel.Adornee = part
                        sel.Color3 = C.red
                        sel.LineThickness = 0.02
                        sel.Parent = part
                        hitboxRenders[part] = sel
                    end
                end
            end
        end
    else
        for part, h in pairs(hitboxRenders) do
            if h and h.Parent then h:Destroy() end
            hitboxRenders[part] = nil
        end
    end
end)

-- ============================================================
--  ПЕРЕКЛЮЧЕНИЕ ТАБОВ
-- ============================================================
local tabMap = {
    tp = {b = tabTp, p = tpPanel},
    pl = {b = tabPl, p = plPanel},
    es = {b = tabEs, p = espPanel},
    tl = {b = tabTl, p = tlPanel},
}
local function setTab(name)
    for k, t in pairs(tabMap) do
        t.p.Visible = (k == name)
        TweenService:Create(t.b, TweenInfo.new(0.2), {
            BackgroundColor3 = (k == name) and C.accent or C.tabOff
        }):Play()
        t.b.TextColor3 = (k == name) and Color3.new(1,1,1) or C.dim
    end
end
tabTp.MouseButton1Click:Connect(function() setTab("tp") end)
tabPl.MouseButton1Click:Connect(function() setTab("pl") end)
tabEs.MouseButton1Click:Connect(function() setTab("es") end)
tabTl.MouseButton1Click:Connect(function() setTab("tl") end)

-- ============================================================
--  ТЕЛЕПОРТ ВВЕРХ/ВНИЗ
-- ============================================================
local function flashErr(msg)
    tpInput.Text = ""; tpInput.PlaceholderText = msg
    tpInput.PlaceholderColor3 = C.red
    TweenService:Create(tpStroke, TweenInfo.new(0.15), {Color=C.red, Thickness=2}):Play()
    task.delay(1.6, function()
        tpInput.PlaceholderText = "Введите число..."
        tpInput.PlaceholderColor3 = C.dim
        TweenService:Create(tpStroke, TweenInfo.new(0.2), {Color=C.border, Thickness=1}):Play()
    end)
end

local function tpV(dir)
    local v = tonumber(tpInput.Text)
    if not v or v <= 0 then flashErr("❌ Введи число больше 0") return end
    v = math.clamp(v, 1, 10000)
    local c = player.Character
    if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart")
    if not h then return end
    h.CFrame = h.CFrame + Vector3.new(0, v * dir, 0)
end
upBtn.MouseButton1Click:Connect(function() tpV(1) end)
dnBtn.MouseButton1Click:Connect(function() tpV(-1) end)

-- ============================================================
--  ИГРОКИ
-- ============================================================
local playerButtons = {}
local selectedPlayer = nil
local following = false
local followConn = nil
local stopFollow
local filter = ""

local function getHRP(c) return c and c:FindFirstChild("HumanoidRootPart") end

local function updateEmpty()
    local t, v = 0, 0
    for _, b in pairs(playerButtons) do t += 1; if b.Visible then v += 1 end end
    if t == 0 then emptyLbl.Text = "Нет других игроков..."; emptyLbl.Visible = true
    elseif v == 0 then emptyLbl.Text = "Не найдено: \""..filter.."\""; emptyLbl.Visible = true
    else emptyLbl.Visible = false end
end

local function updateHL()
    for p, b in pairs(playerButtons) do
        TweenService:Create(b, TweenInfo.new(0.2), {
            BackgroundColor3 = (p == selectedPlayer) and C.accent or C.itemBg
        }):Play()
    end
end

local function selectPlayer(p)
    selectedPlayer = p
    if p then
        selLbl.Text = "Выбран: "..p.DisplayName.."  (@"..p.Name..")"
        selLbl.TextColor3 = C.text
    else
        selLbl.Text = "Игрок не выбран"; selLbl.TextColor3 = C.dim
    end
    updateHL()
end

local function matches(p)
    if filter == "" then return true end
    return p.Name:lower():find(filter,1,true) ~= nil
        or p.DisplayName:lower():find(filter,1,true) ~= nil
end

local function removeP(p)
    if playerButtons[p] then playerButtons[p]:Destroy(); playerButtons[p] = nil end
    if selectedPlayer == p then selectPlayer(nil); if stopFollow then stopFollow() end end
    updateEmpty()
end

local function addP(p)
    if p == player or playerButtons[p] then return end
    local b = Instance.new("TextButton", listFrame)
    b.Size = UDim2.new(1,0,0,36); b.BackgroundColor3 = C.itemBg
    b.BorderSizePixel = 0; b.Font = Enum.Font.GothamMedium
    b.TextSize = 14; b.TextColor3 = C.text
    b.Text = p.DisplayName.."  (@"..p.Name..")"
    b.TextXAlignment = Enum.TextXAlignment.Left; b.AutoButtonColor = false
    corner(b, 8)
    local pp = Instance.new("UIPadding", b); pp.PaddingLeft = UDim.new(0,10)
    b.MouseEnter:Connect(function()
        if p ~= selectedPlayer then TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=C.itemHov}):Play() end
    end)
    b.MouseLeave:Connect(function()
        if p ~= selectedPlayer then TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=C.itemBg}):Play() end
    end)
    b.MouseButton1Click:Connect(function() selectPlayer(p) end)
    b.Visible = matches(p)
    playerButtons[p] = b
    updateEmpty()
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    filter = searchBox.Text:lower():gsub("^%s+",""):gsub("%s+$","")
    for p, b in pairs(playerButtons) do b.Visible = matches(p) end
    updateEmpty()
end)

local function warnNoSel()
    selLbl.Text = "⚠ Сначала выбери игрока!"; selLbl.TextColor3 = C.red
    task.delay(1.5, function()
        if not selectedPlayer then selLbl.Text = "Игрок не выбран"; selLbl.TextColor3 = C.dim end
    end)
end

local function tpToSel()
    if not selectedPlayer then warnNoSel() return end
    local th = getHRP(selectedPlayer.Character)
    local mh = getHRP(player.Character)
    if not th or not mh then return end
    mh.CFrame = th.CFrame * CFrame.new(FOLLOW_OFFSET)
end

stopFollow = function()
    following = false
    if followConn then followConn:Disconnect(); followConn = nil end
    folBtn.Text = "👁  СЛЕЖКА"
    TweenService:Create(folBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.green}):Play()
end

local function startFollow()
    if not selectedPlayer then warnNoSel() return end
    if following then return end
    following = true
    folBtn.Text = "⏹  СТОП"
    TweenService:Create(folBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.red}):Play()
    followConn = RunService.Heartbeat:Connect(function()
        if not following or not selectedPlayer then return end
        local th = getHRP(selectedPlayer.Character)
        local mh = getHRP(player.Character)
        if not th or not mh then return end
        mh.CFrame = th.CFrame * CFrame.new(FOLLOW_OFFSET)
    end)
end

tpToBtn.MouseButton1Click:Connect(tpToSel)
folBtn.MouseButton1Click:Connect(function()
    if following then stopFollow() else startFollow() end
end)

-- ============================================================
--  ESP СИСТЕМА
-- ============================================================
local espScreen = Instance.new("ScreenGui")
espScreen.Name = "ESPScreen"
espScreen.ResetOnSpawn = false
espScreen.IgnoreGuiInset = true
espScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
espScreen.DisplayOrder = 5
espScreen.Parent = playerGui

local SKEL = {
    {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"},
}

local espEnabled = {}
local renders = {}

local function getJoints(char)
    local j = {}
    for _, n in ipairs({"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand",
                        "RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot",
                        "RightUpperLeg","RightLowerLeg","RightFoot"}) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then j[n] = p end
    end
    return j
end

local function project(pos)
    local sp, on = camera:WorldToViewportPoint(pos)
    if sp.Z <= 0 then return nil end
    return Vector2.new(sp.X, sp.Y), on
end

local function createRender(p)
    local box = Instance.new("Frame", espScreen)
    box.AnchorPoint = Vector2.new(0.5, 0)
    box.BackgroundTransparency = 1; box.BorderSizePixel = 0
    box.Visible = false
    local bs = Instance.new("UIStroke", box)
    bs.Thickness = 1.5; bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    bs.Color = S.boxColor

    local skel = {}
    for i = 1, #SKEL do
        local ln = Instance.new("Frame", espScreen)
        ln.AnchorPoint = Vector2.new(0.5, 0.5)
        ln.BackgroundColor3 = S.skelColor; ln.BorderSizePixel = 0
        ln.Size = UDim2.new(0,0,0,1); ln.Visible = false
        skel[i] = ln
    end

    local bb = Instance.new("BillboardGui", playerGui)
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 220, 0, 70)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.Enabled = false

    local nameLbl = Instance.new("TextLabel", bb)
    nameLbl.Size = UDim2.new(1,0,0,18); nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 13
    nameLbl.TextColor3 = playerColor(p.Name); nameLbl.TextStrokeTransparency = 0.4

    local hpBg = Instance.new("Frame", bb)
    hpBg.Size = UDim2.new(0.7,0,0,5); hpBg.Position = UDim2.new(0.15,0,0,20)
    hpBg.BackgroundColor3 = Color3.fromRGB(20,20,20)
    hpBg.BorderSizePixel = 0; corner(hpBg, 2)
    local hpFill = Instance.new("Frame", hpBg)
    hpFill.Size = UDim2.new(1,0,1,0)
    hpFill.BackgroundColor3 = C.green
    hpFill.BorderSizePixel = 0; corner(hpFill, 2)

    local distLbl = Instance.new("TextLabel", bb)
    distLbl.Size = UDim2.new(1,0,0,14)
    distLbl.Position = UDim2.new(0,0,0,27)
    distLbl.BackgroundTransparency = 1
    distLbl.Font = Enum.Font.Gotham; distLbl.TextSize = 11
    distLbl.TextColor3 = C.text; distLbl.TextStrokeTransparency = 0.5

    local toolLbl = Instance.new("TextLabel", bb)
    toolLbl.Size = UDim2.new(1,0,0,14)
    toolLbl.Position = UDim2.new(0,0,0,42)
    toolLbl.BackgroundTransparency = 1
    toolLbl.Font = Enum.Font.GothamMedium; toolLbl.TextSize = 11
    toolLbl.TextColor3 = Color3.fromRGB(255,220,100)
    toolLbl.TextStrokeTransparency = 0.5

    renders[p] = {
        box = box, skel = skel, bb = bb,
        nameLbl = nameLbl, hpBg = hpBg, hpFill = hpFill,
        distLbl = distLbl, toolLbl = toolLbl,
        char = nil,
    }
end

local function destroyRender(p)
    local r = renders[p]
    if not r then return end
    if r.box then r.box:Destroy() end
    for _, l in ipairs(r.skel) do l:Destroy() end
    if r.bb then r.bb:Destroy() end
    renders[p] = nil
end

local function hideAll(r)
    r.box.Visible = false
    r.bb.Enabled = false
    for _, l in ipairs(r.skel) do l.Visible = false end
end

local function updateRender(p)
    local r = renders[p]
    if not r then return end
    local char = p.Character
    if not char then hideAll(r) return end

    if r.char ~= char then
        r.char = char
        r.bb.Adornee = char:FindFirstChild("Head")
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then hideAll(r) return end

    local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local dist = myHrp and (hrp.Position - myHrp.Position).Magnitude or 0
    if dist > S.range then hideAll(r) return end

    if S.teamCheck and p.Team and p.Team == player.Team then hideAll(r) return end

    if S.box then
        local head = char:FindFirstChild("Head")
        if head then
            local topP = project(head.Position + Vector3.new(0, 0.5, 0))
            local botP = project(hrp.Position - Vector3.new(0, 2.7, 0))
            if topP and botP then
                local h = math.abs(botP.Y - topP.Y)
                local w = h * 0.55
                r.box.Position = UDim2.new(0, topP.X, 0, math.min(topP.Y, botP.Y))
                r.box.Size = UDim2.new(0, w, 0, h)
                r.box.Visible = true
                r.box.UIStroke.Color = S.boxColor
            else
                r.box.Visible = false
            end
        else
            r.box.Visible = false
        end
    else
        r.box.Visible = false
    end

    if S.skeleton then
        local joints = getJoints(char)
        for i, conn in ipairs(SKEL) do
            local a, b = joints[conn[1]], joints[conn[2]]
            local line = r.skel[i]
            if a and b then
                local ap = project(a.Position)
                local bp = project(b.Position)
                if ap and bp then
                    local d = bp - ap
                    line.Position = UDim2.new(0, (ap.X + bp.X)/2, 0, (ap.Y + bp.Y)/2)
                    line.Size = UDim2.new(0, d.Magnitude, 0, 1)
                    line.Rotation = math.deg(math.atan2(d.Y, d.X))
                    line.Visible = true
                    line.BackgroundColor3 = S.skelColor
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    else
        for _, l in ipairs(r.skel) do l.Visible = false end
    end

    r.bb.Enabled = true
    r.nameLbl.Visible = S.name
    if S.name then r.nameLbl.Text = p.DisplayName end

    r.hpBg.Visible = S.health
    if S.health then
        local ratio = hum.Health / math.max(hum.MaxHealth, 1)
        r.hpFill.Size = UDim2.new(ratio, 0, 1, 0)
        r.hpFill.BackgroundColor3 = ratio > 0.5 and C.green
            or (ratio > 0.25 and C.yellow or C.red)
    end

    r.distLbl.Visible = S.distance
    if S.distance then r.distLbl.Text = string.format("%d studs", math.floor(dist)) end

    r.toolLbl.Visible = S.tool
    if S.tool then
        local tool = char:FindFirstChildOfClass("Tool")
        r.toolLbl.Text = tool and ("🔧 "..tool.Name) or ""
    end
end

RunService.RenderStepped:Connect(function()
    for p in pairs(espEnabled) do
        if p ~= player then
            if not renders[p] then createRender(p) end
            updateRender(p)
        end
    end
    for p in pairs(renders) do
        if not espEnabled[p] then destroyRender(p) end
    end
end)

local espRows = {}

local function updateEspEmpty()
    espEmpty.Visible = (next(espRows) == nil)
end

local function setEsp(p, on)
    espEnabled[p] = on or nil
    if espRows[p] then espRows[p].check.Visible = on end
    if not on then destroyRender(p) end
end

local function addEspRow(p)
    if p == player or espRows[p] then return end
    local b = Instance.new("TextButton", espList)
    b.Size = UDim2.new(1,0,0,34); b.BackgroundColor3 = C.itemBg
    b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false
    corner(b, 8)

    local cb = Instance.new("Frame", b)
    cb.Size = UDim2.new(0,18,0,18)
    cb.Position = UDim2.new(0,10,0.5,0); cb.AnchorPoint = Vector2.new(0,0.5)
    cb.BackgroundColor3 = Color3.new(1,1,1); cb.BackgroundTransparency = 0.9
    cb.BorderSizePixel = 0; corner(cb, 4); stroke(cb, C.accent, 1.5, 0)

    local check = Instance.new("TextLabel", cb)
    check.Size = UDim2.new(1,0,1,0); check.BackgroundTransparency = 1
    check.Font = Enum.Font.GothamBold; check.Text = "✓"
    check.TextColor3 = C.accent; check.TextSize = 14; check.Visible = false

    local nameLbl = Instance.new("TextLabel", b)
    nameLbl.Size = UDim2.new(1,-50,1,0); nameLbl.Position = UDim2.new(0,36,0,0)
    nameLbl.BackgroundTransparency = 1; nameLbl.Font = Enum.Font.GothamMedium
    nameLbl.Text = p.DisplayName.."  (@"..p.Name..")"
    nameLbl.TextColor3 = C.text; nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left

    espRows[p] = {button = b, check = check}
    b.MouseButton1Click:Connect(function()
        setEsp(p, not (espEnabled[p] == true))
    end)
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=C.itemHov}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=C.itemBg}):Play() end)
    updateEspEmpty()
end

local function removeEspRow(p)
    if espRows[p] then espRows[p].button:Destroy(); espRows[p] = nil end
    espEnabled[p] = nil
    destroyRender(p)
    updateEspEmpty()
end

local allOn = false
toggleAllBtn.MouseButton1Click:Connect(function()
    allOn = not allOn
    for p in pairs(espRows) do setEsp(p, allOn) end
    toggleAllBtn.Text = allOn and "❌  ВЫКЛЮЧИТЬ ВСЁ" or "✅  ВКЛЮЧИТЬ ВСЁ"
    TweenService:Create(toggleAllBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = allOn and C.red or C.green
    }):Play()
end)

-- ============================================================
--  ОБРАБОТКА ИГРОКОВ
-- ============================================================
local function setupPlayer(p)
    if p == player then return end
    addP(p)
    addEspRow(p)
end

for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(p)
    removeP(p)
    removeEspRow(p)
end)

-- ============================================================
--  ПЕРЕТАСКИВАНИЕ
-- ============================================================
local dragging, dragStart, startPos = false, nil, nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
       or input.UserInputType == Enum.UserInputType.Touch then
        local d = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============================================================
--  СВОРАЧИВАНИЕ С ПЛАВНОЙ АНИМАЦИЕЙ (RightShift / «—»)
-- ============================================================
local minimized = false
local fading    = false

local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 28, 1, 0)
minBtn.Position = UDim2.new(1, -28, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Font = Enum.Font.GothamBold
minBtn.Text = "—"
minBtn.TextSize = 20
minBtn.TextColor3 = C.dim
minBtn.AutoButtonColor = false
minBtn.MouseEnter:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.15), {TextColor3 = C.accent}):Play()
end)
minBtn.MouseLeave:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.15), {TextColor3 = C.dim}):Play()
end)

local miniBtn = Instance.new("TextButton", gui)
miniBtn.Size = UDim2.new(0, 54, 0, 54)
miniBtn.Position = UDim2.new(0, 20, 0, 80)
miniBtn.BackgroundColor3 = C.bg
miniBtn.BorderSizePixel = 0
miniBtn.Font = Enum.Font.GothamBold
miniBtn.Text = "⚡"
miniBtn.TextSize = 26
miniBtn.TextColor3 = C.accent
miniBtn.AutoButtonColor = false
miniBtn.Visible = false
miniBtn.BackgroundTransparency = 1
miniBtn.TextTransparency = 1
corner(miniBtn, 14)
local miniStroke = stroke(miniBtn, C.accent, 2, 1)

local miniGrad = Instance.new("UIGradient", miniBtn)
miniGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(38,38,58)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16,16,26)),
})
miniGrad.Rotation = 90

miniBtn.MouseEnter:Connect(function()
    TweenService:Create(miniBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.accent}):Play()
end)
miniBtn.MouseLeave:Connect(function()
    TweenService:Create(miniBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.bg}):Play()
end)

local originalT = {}
local function scanTransparency(root)
    for _, d in ipairs(root:GetDescendants()) do
        if originalT[d] == nil then
            local info = {}
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                info.TextTransparency = d.TextTransparency
                info.TextStrokeTransparency = d.TextStrokeTransparency
                info.BackgroundTransparency = d.BackgroundTransparency
            elseif d:IsA("GuiObject") then
                info.BackgroundTransparency = d.BackgroundTransparency
            elseif d:IsA("UIStroke") then
                info.Transparency = d.Transparency
            else
                info = nil
            end
            if info then originalT[d] = info end
        end
    end
end
scanTransparency(main)

local fadeInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function applyFade(goal)
    scanTransparency(main)
    for obj, props in pairs(originalT) do
        if obj and obj.Parent then
            local goals = {}
            for prop, origVal in pairs(props) do
                goals[prop] = (goal == "hidden") and 1 or origVal
            end
            TweenService:Create(obj, fadeInfo, goals):Play()
        end
    end
end

local function setMinimized(state)
    if fading or minimized == state then return end
    fading = true
    minimized = state

    if state then
        applyFade("hidden")

        miniBtn.Visible = true
        miniBtn.BackgroundTransparency = 1
        miniBtn.TextTransparency = 1
        if miniStroke then miniStroke.Transparency = 1 end

        local mInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        TweenService:Create(miniBtn, mInfo, {
            BackgroundTransparency = 0,
            TextTransparency = 0,
        }):Play()
        if miniStroke then
            TweenService:Create(miniStroke, mInfo, {Transparency = 0.3}):Play()
        end

        task.wait(0.3)
        main.Visible = false
    else
        main.Visible = true
        applyFade("visible")

        local mInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(miniBtn, mInfo, {
            BackgroundTransparency = 1,
            TextTransparency = 1,
        }):Play()
        if miniStroke then
            TweenService:Create(miniStroke, mInfo, {Transparency = 1}):Play()
        end

        task.wait(0.3)
        miniBtn.Visible = false
    end

    fading = false
end

minBtn.MouseButton1Click:Connect(function() setMinimized(true) end)
miniBtn.MouseButton1Click:Connect(function() setMinimized(false) end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setMinimized(not minimized)
    end
end)

local miniDrag, miniStart, miniPos = false, nil, nil
miniBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
       or inp.UserInputType == Enum.UserInputType.Touch then
        miniDrag = true
        miniStart = inp.Position
        miniPos = miniBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if not miniDrag then return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement
       or inp.UserInputType == Enum.UserInputType.Touch then
        local d = inp.Position - miniStart
        miniBtn.Position = UDim2.new(
            miniPos.X.Scale, miniPos.X.Offset + d.X,
            miniPos.Y.Scale, miniPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
       or inp.UserInputType == Enum.UserInputType.Touch then
        miniDrag = false
    end
end)

-- ============================================================
--  INIT
-- ============================================================
setTab("tp")
updateEmpty()
updateEspEmpty()
refreshWpList()