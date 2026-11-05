
-- GHOST MEGA AI V7
-- Connects to your existing ai.lua
-- Two AI passes for better Roblox scripts

local env = getgenv and getgenv() or _G

local MegaAI = {}
MegaAI.Version = "7.0"

local function clean(text)
    if type(text) ~= "string" then
        return nil
    end

    if text:lower():find("<html", 1, true)
        or text:lower():find("<!doctype", 1, true)
        or text:lower():find("access restricted", 1, true) then
        return nil
    end

    local fenced = text:match(
        "```[%w]*%s*\n(.-)```"
    )

    text = fenced or text
    text = text:match("^%s*(.-)%s*$")

    if not text or #text == 0 then
        return nil
    end

    return text
end

local function score(code)
    local points = 0

    if code:find("local ", 1, true) then
        points += 2
    end

    if code:find("game:GetService", 1, true) then
        points += 3
    end

    if code:find("Players.LocalPlayer", 1, true) then
        points += 3
    end

    if code:find("Instance.new", 1, true) then
        points += 1
    end

    if code:find(":Connect", 1, true) then
        points += 1
    end

    if #code > 400 then
        points += 2
    end

    if #code > 1200 then
        points += 2
    end

    return points
end

function MegaAI.Generate(requestText, onProgress)
    local original = env.GhostAI

    if not original
        or type(original.Generate) ~= "function" then
        return nil, "Original ai.lua is not loaded."
    end

    if type(requestText) ~= "string"
        or requestText:match("^%s*$") then
        return nil, "Enter a script request."
    end

    local function progress(text)
        if type(onProgress) == "function" then
            pcall(onProgress, text)
        end
    end

    -- FIRST AI PASS

    progress("AI Pass 1: Building script...")

    local firstPrompt =
        "Make a complete Roblox Luau LocalScript " ..
        "for this request: " .. requestText ..
        ". Include needed mobile controls. " ..
        "Return only complete executable Lua code."

    local first, err1 = original.Generate(firstPrompt)
    first = clean(first)

    if not first then
        return nil, err1 or "First AI request failed."
    end

    -- SECOND AI PASS
    -- Give the model a short excerpt of the first draft.
    -- Keep request length within the server limit.

    progress("AI Pass 2: Improving script...")

    local excerpt = first:sub(1, 650)

    local secondPrompt =
        "Create an improved COMPLETE Roblox LocalScript. " ..
        "Fix likely runtime errors and include mobile support. " ..
        "User wants: " .. requestText:sub(1, 350) ..
        ". Previous draft begins: " .. excerpt ..
        ". Return ONLY the full new Lua script."

    local second, err2 = original.Generate(secondPrompt)
    second = clean(second)

    -- If second pass fails, keep the first draft.
    if not second then
        progress("Using first AI draft")
        return first, nil, 1
    end

    local chosen = first

    if score(second) >= score(first) then
        chosen = second
    end

    progress("Mega AI response ready!")

    return chosen, nil, 2
end

env.GhostMegaAI = MegaAI

print("GHOST MEGA AI V7 LOADED")
