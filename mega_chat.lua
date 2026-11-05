
-- GHOST MEGA AI CHAT V7
-- Run after ai.lua and mega_ai.lua

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local env = getgenv and getgenv() or _G

local pg = player:WaitForChild("PlayerGui")
local previous = pg:FindFirstChild("GhostMegaChat")
if previous then previous:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "GhostMegaChat"
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000
gui.Parent = pg

local function new(class, properties, parent)
    local object = Instance.new(class)

    for k,v in pairs(properties) do
        object[k] = v
    end

    object.Parent = parent
    return object
end

local function rounded(obj)
    new("UICorner", {
        CornerRadius = UDim.new(0,9)
    },obj)
end

local main = new("Frame",{
    Size = UDim2.fromOffset(310,400),
    Position = UDim2.new(0.5,-155,0.5,-200),
    BackgroundColor3 = Color3.fromRGB(17,17,29),
    BorderSizePixel = 0,
    Active = true,
    Draggable = true
},gui)
rounded(main)

new("UIStroke",{
    Color = Color3.fromRGB(165,95,255),
    Thickness = 2
},main)

local title = new("TextLabel",{
    Position = UDim2.fromOffset(10,6),
    Size = UDim2.fromOffset(245,34),
    BackgroundTransparency = 1,
    Text = "GHOST MEGA AI V7",
    TextColor3 = Color3.fromRGB(190,145,255),
    Font = Enum.Font.GothamBold,
    TextSize = 17
},main)

local close = new("TextButton",{
    Position = UDim2.fromOffset(268,8),
    Size = UDim2.fromOffset(32,30),
    BackgroundColor3 = Color3.fromRGB(100,50,75),
    TextColor3 = Color3.new(1,1,1),
    Text = "X",
    TextSize = 14
},main)
rounded(close)

local prompt = new("TextBox",{
    Position = UDim2.fromOffset(10,48),
    Size = UDim2.fromOffset(290,85),
    BackgroundColor3 = Color3.fromRGB(35,33,52),
    TextColor3 = Color3.new(1,1,1),
    PlaceholderText = "What Roblox script should Mega AI make?",
    Text = "",
    MultiLine = true,
    TextWrapped = true,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextSize = 13,
    Font = Enum.Font.Code
},main)
rounded(prompt)

local generate = new("TextButton",{
    Position = UDim2.fromOffset(10,143),
    Size = UDim2.fromOffset(290,38),
    BackgroundColor3 = Color3.fromRGB(117,66,225),
    TextColor3 = Color3.new(1,1,1),
    Text = "GENERATE WITH MEGA AI",
    Font = Enum.Font.GothamBold,
    TextSize = 13
},main)
rounded(generate)

local status = new("TextLabel",{
    Position = UDim2.fromOffset(10,185),
    Size = UDim2.fromOffset(290,23),
    BackgroundTransparency = 1,
    Text = "Ready",
    TextColor3 = Color3.fromRGB(185,165,225),
    TextSize = 11
},main)

local scroll = new("ScrollingFrame",{
    Position = UDim2.fromOffset(10,214),
    Size = UDim2.fromOffset(290,132),
    BackgroundColor3 = Color3.fromRGB(9,11,19),
    BorderSizePixel = 0,
    ScrollBarThickness = 5,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.fromOffset(0,0)
},main)
rounded(scroll)

local result = new("TextLabel",{
    Position = UDim2.fromOffset(6,6),
    Size = UDim2.new(1,-16,0,0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    Text = "-- AI LocalScript will appear here",
    TextColor3 = Color3.fromRGB(120,245,169),
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextSize = 12,
    Font = Enum.Font.Code
},scroll)

local copy = new("TextButton",{
    Position = UDim2.fromOffset(10,355),
    Size = UDim2.fromOffset(290,35),
    BackgroundColor3 = Color3.fromRGB(36,126,88),
    TextColor3 = Color3.new(1,1,1),
    Text = "COPY GENERATED SCRIPT",
    Font = Enum.Font.GothamBold,
    TextSize = 13
},main)
rounded(copy)

local busy = false
local latestCode = nil

generate.Activated:Connect(function()
    if busy then return end

    if prompt.Text:match("^%s*$") then
        status.Text = "Type a request first."
        return
    end

    local mega = env.GhostMegaAI

    if not mega or type(mega.Generate) ~= "function" then
        status.Text = "Mega AI engine not loaded."
        return
    end

    busy = true
    latestCode = nil
    generate.Text = "AI WORKING..."
    result.Text = "-- Generating..."

    local message = prompt.Text

    task.spawn(function()
        local ok, code, err, passes = pcall(function()
            return mega.Generate(message,function(progress)
                if gui.Parent then
                    status.Text = progress
                end
            end)
        end)

        if not gui.Parent then return end

        if ok and type(code) == "string" then
            latestCode = code
            result.Text = code

            status.Text =
                "Script ready! AI passes: " ..
                tostring(passes or 1)
        else
            latestCode = nil
            result.Text = "-- No script received"
            status.Text = ok
                and tostring(err or "AI unavailable")
                or "AI request failed."
        end

        scroll.CanvasPosition = Vector2.zero
        generate.Text = "GENERATE WITH MEGA AI"
        busy = false
    end)
end)

copy.Activated:Connect(function()
    if not latestCode then
        status.Text = "Generate a script first."
        return
    end

    local fn = setclipboard or toclipboard

    if type(fn) == "function" then
        fn(latestCode)
        status.Text = "Script copied!"
    else
        status.Text = "Clipboard unavailable."
    end
end)

close.Activated:Connect(function()
    gui:Destroy()
end)

print("GHOST MEGA CHAT V7 LOADED")
