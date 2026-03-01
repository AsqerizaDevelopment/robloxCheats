local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

local existing = playerGui:FindFirstChild("PurpleBlackUI")
if existing then existing:Destroy() end

local Theme = {
	BG = Color3.fromRGB(10, 10, 14),
	Panel = Color3.fromRGB(18, 18, 26),
	Panel2 = Color3.fromRGB(24, 24, 34),
	Stroke = Color3.fromRGB(55, 55, 70),
	Text = Color3.fromRGB(235, 235, 245),
	Muted = Color3.fromRGB(170, 170, 190),
	Purple = Color3.fromRGB(168, 85, 247),
	Purple2 = Color3.fromRGB(124, 58, 237),
	Good = Color3.fromRGB(34, 197, 94),
	Bad = Color3.fromRGB(239, 68, 68),
	White = Color3.fromRGB(245, 245, 255),
}

local CURSOR_ARROW = "rbxasset://SystemCursors/Arrow"
local CURSOR_HAND = "rbxasset://SystemCursors/PointingHand"

local function mk(instType, props, children)
	local inst = Instance.new(instType)
	for k, v in pairs(props or {}) do inst[k] = v end
	for _, c in ipairs(children or {}) do c.Parent = inst end
	return inst
end

local function corner(radius)
	return mk("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function stroke(thickness, color, transparency)
	return mk("UIStroke", {
		Thickness = thickness or 1,
		Color = color or Theme.Stroke,
		Transparency = transparency or 0.25,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})
end

local function padding(p)
	return mk("UIPadding", {
		PaddingTop = UDim.new(0, p),
		PaddingBottom = UDim.new(0, p),
		PaddingLeft = UDim.new(0, p),
		PaddingRight = UDim.new(0, p),
	})
end

local function listlayout(fillDir, pad)
	return mk("UIListLayout", {
		FillDirection = fillDir or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, pad or 10)
	})
end

local function tween(obj, t, goal, style, dir)
	local ti = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, ti, goal)
	tw:Play()
	return tw
end

local function hoverCursor(btn)
	btn.MouseEnter:Connect(function()
		mouse.Icon = CURSOR_HAND
	end)
	btn.MouseLeave:Connect(function()
		mouse.Icon = CURSOR_ARROW
	end)
end

local gui = mk("ScreenGui", {
	Name = "PurpleBlackUI",
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, {
	mk("Frame", {
		Name = "Dim",
		BackgroundColor3 = Theme.BG,
		BackgroundTransparency = 0.25,
		Size = UDim2.fromScale(1, 1),
	}, {
		mk("UIGradient", {
			Rotation = 20,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(6, 6, 10)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 10, 28)),
			})
		})
	})
})
gui.Parent = playerGui

local dim = gui:WaitForChild("Dim")
local window = mk("Frame", {
	Name = "Window",
	BackgroundColor3 = Theme.Panel,
	Size = UDim2.fromOffset(720, 430),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
})
window.Parent = dim
corner(18).Parent = window
stroke(1, Theme.Stroke, 0.35).Parent = window

mk("UIGradient", {
	Rotation = 90,
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.Panel2),
		ColorSequenceKeypoint.new(1, Theme.Panel),
	})
}).Parent = window

local topbar = mk("Frame", {
	Name = "Topbar",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 56),
})
topbar.Parent = window

local title = mk("TextLabel", {
	Name = "Title",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(18, 10),
	Size = UDim2.new(1, -170, 0, 22),
	Font = Enum.Font.GothamBold,
	Text = "DEACTIVATED",
	TextColor3 = Theme.Text,
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Left,
})
title.Parent = topbar

local subtitle = mk("TextLabel", {
	Name = "Subtitle",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(18, 30),
	Size = UDim2.new(1, -170, 0, 18),
	Font = Enum.Font.Gotham,
	Text = "Noach - Milan - Tijn",
	TextColor3 = Theme.Muted,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
})
subtitle.Parent = topbar

local closeBtn = mk("TextButton", {
	Name = "Close",
	BackgroundColor3 = Color3.fromRGB(30, 30, 42),
	Size = UDim2.fromOffset(72, 36),
	Position = UDim2.new(1, -90, 0, 10),
	Text = "Close",
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	TextColor3 = Theme.Text,
	AutoButtonColor = false,
})
closeBtn.Parent = topbar
corner(12).Parent = closeBtn
stroke(1, Theme.Stroke, 0.45).Parent = closeBtn
hoverCursor(closeBtn)

local body = mk("Frame", {
	Name = "Body",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(14, 62),
	Size = UDim2.new(1, -28, 1, -76),
})
body.Parent = window

local sidebar = mk("Frame", {
	Name = "Sidebar",
	BackgroundColor3 = Color3.fromRGB(14, 14, 20),
	Size = UDim2.new(0, 190, 1, 0),
})
sidebar.Parent = body
corner(14).Parent = sidebar
stroke(1, Theme.Stroke, 0.5).Parent = sidebar
padding(12).Parent = sidebar

local sbList = listlayout(Enum.FillDirection.Vertical, 10)
sbList.Parent = sidebar

local function tabButton(text, icon)
	local btn = mk("TextButton", {
		BackgroundColor3 = Color3.fromRGB(20, 20, 30),
		Size = UDim2.new(1, 0, 0, 44),
		Text = "",
		AutoButtonColor = false,
	}, {
		corner(12),
		stroke(1, Theme.Stroke, 0.55),
		mk("TextLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 10),
			Size = UDim2.fromOffset(24, 24),
			Font = Enum.Font.GothamBold,
			Text = icon or "●",
			TextColor3 = Theme.Purple,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Center,
		}),
		mk("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(42, 12),
			Size = UDim2.new(1, -54, 0, 20),
			Font = Enum.Font.GothamSemibold,
			Text = text,
			TextColor3 = Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		mk("Frame", {
			Name = "ActiveBar",
			BackgroundColor3 = Theme.Purple,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(4, 18),
			BackgroundTransparency = 1,
		}, { corner(8) })
	})

	btn.MouseEnter:Connect(function()
		tween(btn, 0.16, { BackgroundColor3 = Color3.fromRGB(26, 26, 38) })
		mouse.Icon = CURSOR_HAND
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, 0.16, { BackgroundColor3 = Color3.fromRGB(20, 20, 30) })
		mouse.Icon = CURSOR_ARROW
	end)

	return btn
end

local tabs = {
	Home = tabButton("Home"),
	Cheats = tabButton("Cheats"),
	Settings = tabButton("Settings"),
}

local tabOrder = { "Home", "Cheats", "Settings" }
for _, name in ipairs(tabOrder) do
	tabs[name].Parent = sidebar
end

local content = mk("Frame", {
	Name = "Content",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(206, 0),
	Size = UDim2.new(1, -206, 1, 0),
})
content.Parent = body

local pages = mk("Folder", { Name = "Pages" })
pages.Parent = content

local function makePage(name)
	local page = mk("Frame", {
		Name = name,
		BackgroundColor3 = Color3.fromRGB(14, 14, 20),
		Size = UDim2.fromScale(1, 1),
		Visible = false,
	}, {
		corner(14),
		stroke(1, Theme.Stroke, 0.5),
		padding(14),
	})
	page.Parent = pages

	local layout = listlayout(Enum.FillDirection.Vertical, 12)
	layout.Parent = page

	return page
end

local pageHome = makePage("Home")
local pageSettings = makePage("Settings")
local pageCheats = makePage("Cheats")

local function sectionHeader(parent, text, sub)
	local wrap = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 52) })
	wrap.Parent = parent

	mk("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		Font = Enum.Font.GothamBold,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
	}).Parent = wrap

	mk("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 24),
		Size = UDim2.new(1, 0, 0, 18),
		Font = Enum.Font.Gotham,
		Text = sub or "",
		TextColor3 = Theme.Muted,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}).Parent = wrap

	return wrap
end

local function card(parent, height)
	local c = mk("Frame", {
		BackgroundColor3 = Color3.fromRGB(18, 18, 28),
		Size = UDim2.new(1, 0, 0, height or 86),
	}, {
		corner(14),
		stroke(1, Theme.Stroke, 0.6),
		padding(12),
	})
	c.Parent = parent
	return c
end

local function toggle(parent, labelText, defaultOn, onChanged)
	local row = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34) })
	row.Parent = parent

	local label = mk("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -66, 1, 0),
		Font = Enum.Font.GothamSemibold,
		Text = labelText,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	label.Parent = row

	local pill = mk("TextButton", {
		BackgroundColor3 = Color3.fromRGB(32, 32, 46),
		Size = UDim2.fromOffset(54, 28),
		Position = UDim2.new(1, -54, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Text = "",
		AutoButtonColor = false,
	})
	pill.Parent = row
	corner(999).Parent = pill
	stroke(1, Theme.Stroke, 0.6).Parent = pill
	hoverCursor(pill)

	local knob = mk("Frame", {
		BackgroundColor3 = Theme.Text,
		Size = UDim2.fromOffset(22, 22),
		Position = UDim2.new(0, 3, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
	})
	knob.Parent = pill
	corner(999).Parent = knob

	local state = defaultOn and true or false
	local function apply(instant)
		local bg = state and Theme.Purple2 or Color3.fromRGB(32, 32, 46)
		local kp = state and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		if instant then
			pill.BackgroundColor3 = bg
			knob.Position = kp
		else
			tween(pill, 0.16, { BackgroundColor3 = bg })
			tween(knob, 0.16, { Position = kp })
		end
		if onChanged then onChanged(state) end
	end

	apply(true)

	pill.MouseButton1Click:Connect(function()
		state = not state
		apply(false)
	end)

	return {
		Get = function() return state end,
		Set = function(v) state = not not v; apply(false) end
	}
end

local function slider(parent, labelText, min, max, defaultValue, onChanged)
	local wrap = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 56) })
	wrap.Parent = parent

	local top = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20) })
	top.Parent = wrap

	local label = mk("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -60, 1, 0),
		Font = Enum.Font.GothamSemibold,
		Text = labelText,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	label.Parent = top

	local valueLbl = mk("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(60, 20),
		Position = UDim2.new(1, -60, 0, 0),
		Font = Enum.Font.Gotham,
		Text = tostring(defaultValue),
		TextColor3 = Theme.Muted,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	valueLbl.Parent = top

	local track = mk("Frame", {
		BackgroundColor3 = Color3.fromRGB(28, 28, 40),
		Position = UDim2.fromOffset(0, 28),
		Size = UDim2.new(1, 0, 0, 16),
	})
	track.Parent = wrap
	corner(999).Parent = track
	stroke(1, Theme.Stroke, 0.65).Parent = track
	hoverCursor(track)

	local fill = mk("Frame", {
		BackgroundColor3 = Theme.Purple,
		Size = UDim2.new(0, 0, 1, 0),
	})
	fill.Parent = track
	corner(999).Parent = fill

	local knob = mk("Frame", {
		BackgroundColor3 = Theme.Text,
		Size = UDim2.fromOffset(18, 18),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
	})
	knob.Parent = track
	corner(999).Parent = knob

	local dragging = false
	local value = defaultValue

	local function setFromX(x)
		local absPos = track.AbsolutePosition.X
		local absSize = track.AbsoluteSize.X
		local alpha = math.clamp((x - absPos) / absSize, 0, 1)
		value = math.floor((min + (max - min) * alpha) + 0.5)

		valueLbl.Text = tostring(value)

		tween(fill, 0.08, { Size = UDim2.new(alpha, 0, 1, 0) })
		tween(knob, 0.08, { Position = UDim2.new(alpha, 0, 0.5, 0) })

		if onChanged then onChanged(value) end
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			setFromX(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			setFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	task.defer(function()
		local alpha = (defaultValue - min) / (max - min)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
	end)

	return {
		Get = function() return value end
	}
end

local function button(parent, text, onClick)
	local btn = mk("TextButton", {
		BackgroundColor3 = Theme.Purple2,
		Size = UDim2.new(1, 0, 0, 40),
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Text,
		AutoButtonColor = false,
	})
	btn.Parent = parent
	corner(14).Parent = btn
	stroke(1, Theme.Purple, 0.25).Parent = btn
	hoverCursor(btn)

	btn.MouseEnter:Connect(function()
		tween(btn, 0.16, { BackgroundColor3 = Theme.Purple })
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, 0.16, { BackgroundColor3 = Theme.Purple2 })
	end)

	btn.MouseButton1Click:Connect(function()
		if onClick then onClick() end
	end)

	return btn
end

local isEnabled = false
local blinkTweenIn = nil
local blinkTweenOut = nil

local function stopBlink(dot)
	if blinkTweenIn then blinkTweenIn:Cancel() end
	if blinkTweenOut then blinkTweenOut:Cancel() end
	blinkTweenIn = nil
	blinkTweenOut = nil
	dot.BackgroundTransparency = 0
end

local function startBlink(dot)
	stopBlink(dot)
	local function loop()
		if not isEnabled then return end
		blinkTweenOut = TweenService:Create(dot, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.85 })
		blinkTweenOut:Play()
		blinkTweenOut.Completed:Wait()
		if not isEnabled then return end
		blinkTweenIn = TweenService:Create(dot, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.05 })
		blinkTweenIn:Play()
		blinkTweenIn.Completed:Wait()
		if isEnabled then
			task.defer(loop)
		end
	end
	task.defer(loop)
end

local function setEnabledUI(statusTextLabel, dot, value)
	isEnabled = value and true or false
	if isEnabled then
		statusTextLabel.Text = "INJECTED"
		statusTextLabel.TextColor3 = Theme.Good
		dot.Visible = true
		startBlink(dot)
	else
		statusTextLabel.Text = "DEACTIVATED"
		statusTextLabel.TextColor3 = Theme.Bad
		dot.Visible = false
		stopBlink(dot)
	end
end

sectionHeader(pageHome, "Dashboard").Parent = pageHome
local statusTextLabel = nil
local liveDot = nil
do
	local statusRow = mk("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 44),
	})
	statusRow.Parent = pageHome

	local inner = mk("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
	})
	inner.Parent = statusRow

	padding(6).Parent = inner

	local rowLayout = listlayout(Enum.FillDirection.Horizontal, 10)
	rowLayout.Parent = inner
	rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local left = mk("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 90, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "Status",
		TextColor3 = Theme.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	left.Parent = inner

	local dot = mk("Frame", {
		BackgroundColor3 = Theme.White,
		Size = UDim2.fromOffset(10, 10),
		Visible = false,
	})
	dot.Parent = inner
	corner(999).Parent = dot

	local status = mk("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -130, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "NOT INJECTED",
		TextColor3 = Theme.Bad,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	status.Parent = inner

	statusTextLabel = status
	liveDot = dot

	local hint = mk("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = Theme.Muted,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	hint.Parent = pageHome
end

sectionHeader(pageSettings, "Settings").Parent = pageSettings
do
	local c = card(pageSettings, 280)
	local layout = listlayout(Enum.FillDirection.Vertical, 14)
	layout.Parent = c

	slider(c, "UI Scale", 80, 130, 100, function(v)
		window.Size = UDim2.fromOffset(math.floor(720 * (v / 100)), math.floor(430 * (v / 100)))
	end)

	toggle(c, "Show FPS Counter", true, function(on) end)

	local spacer = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 8) })
	spacer.Parent = c
end

sectionHeader(pageCheats, "Cheats").Parent = pageCheats
do
	local cheatsBox = card(pageCheats, 150)
	local layoutA = listlayout(Enum.FillDirection.Vertical, 10)
	layoutA.Parent = cheatsBox

	local bottom = mk("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 44),
	})
	bottom.Parent = pageCheats

	local pad = mk("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 0),
		PaddingLeft = UDim.new(0, 0),
		PaddingRight = UDim.new(0, 0),
	})
	pad.Parent = bottom

	local row = mk("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
})
row.Parent = bottom

local hl = mk("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 10),
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Center,
})
hl.Parent = row

local injectWrap = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0) })
injectWrap.Parent = row

local deactWrap = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0) })
deactWrap.Parent = row

button(injectWrap, "ENABLE", function()
	setEnabledUI(statusTextLabel, liveDot, true)
	title.Text = "Enabled!"
	tween(title, 0.12, { TextColor3 = Theme.Purple })
	task.delay(0.35, function()
		tween(title, 0.18, { TextColor3 = Theme.Text })
	end)
end)

button(deactWrap, "DISABLE", function()
	setEnabledUI(statusTextLabel, liveDot, false)
	title.Text = "Disabled"
	tween(title, 0.12, { TextColor3 = Theme.Purple })
	task.delay(0.35, function()
		tween(title, 0.18, { TextColor3 = Theme.Text })
	end)
end)
end

setEnabledUI(statusTextLabel, liveDot, false)

local currentPage = nil

local function setActive(tabName)
	for name, btn in pairs(tabs) do
		local bar = btn:FindFirstChild("ActiveBar")
		if bar then
			local active = (name == tabName)
			tween(bar, 0.16, { BackgroundTransparency = active and 0 or 1 })
			tween(btn, 0.16, { BackgroundColor3 = active and Color3.fromRGB(26, 22, 40) or Color3.fromRGB(20, 20, 30) })
			local icon = btn:FindFirstChild("Icon")
			if icon and icon:IsA("TextLabel") then
				tween(icon, 0.16, { TextColor3 = active and Theme.Purple or Theme.Purple2 })
			end
		end
	end

	if currentPage then currentPage.Visible = false end
	currentPage = pages:FindFirstChild(tabName)
	if currentPage then
		currentPage.Visible = true
		currentPage.BackgroundTransparency = 1
		tween(currentPage, 0.18, { BackgroundTransparency = 0 })
	end
end

tabs.Home.MouseButton1Click:Connect(function() setActive("Home") end)
tabs.Cheats.MouseButton1Click:Connect(function() setActive("Cheats") end)
tabs.Settings.MouseButton1Click:Connect(function() setActive("Settings") end)

setActive("Home")

do
	local dragging = false
	local dragStart, startPos

	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = window.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			window.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

local menuOpen = true
local prevMouseIconEnabled = UserInputService.MouseIconEnabled
local prevMouseBehavior = UserInputService.MouseBehavior

local function applyMouseForMenu(isOpen)
	if isOpen then
		UserInputService.MouseIconEnabled = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		mouse.Icon = CURSOR_ARROW
	else
		UserInputService.MouseIconEnabled = prevMouseIconEnabled
		UserInputService.MouseBehavior = prevMouseBehavior
		mouse.Icon = CURSOR_ARROW
	end
end

local function openMenu()
	menuOpen = true
	dim.Visible = true
	dim.BackgroundTransparency = 1
	window.BackgroundTransparency = 1
	window.Size = UDim2.fromOffset(680, 390)
	tween(dim, 0.18, { BackgroundTransparency = 0.25 })
	tween(window, 0.22, { BackgroundTransparency = 0, Size = UDim2.fromOffset(720, 430) })
	applyMouseForMenu(true)
end

local function closeMenu()
	menuOpen = false
	tween(window, 0.18, { Size = UDim2.fromOffset(680, 390), BackgroundTransparency = 0.25 })
	tween(dim, 0.18, { BackgroundTransparency = 1 })
	task.delay(0.2, function()
		if not menuOpen then
			dim.Visible = false
			applyMouseForMenu(false)
		end
	end)
end

closeBtn.MouseButton1Click:Connect(function()
	closeMenu()
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.F10 then
		if menuOpen then
			closeMenu()
		else
			openMenu()
		end
	end
end)

window.BackgroundTransparency = 1
window.Size = UDim2.fromOffset(680, 390)
tween(window, 0.22, { BackgroundTransparency = 0, Size = UDim2.fromOffset(720, 430) })
applyMouseForMenu(true)