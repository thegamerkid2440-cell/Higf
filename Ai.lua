
-- GHOST AI ENGINE V6
-- Run this FIRST in Delta
-- No access code required

local Http = game:GetService("HttpService")

local API = "https://ghost-ai-script-maker-uygmf4.v2.appdeploy.ai/api/generate"

local env = getgenv and getgenv() or _G

local GhostAI = {}
GhostAI.Ready = true

local function getRequester()
    if type(request) == "function" then
        return request
    end

    if type(http_request) == "function" then
        return http_request
    end

    if syn and type(syn.request) == "function" then
        return syn.request
    end

    if http and type(http.request) == "function" then
        return http.request
    end

    return nil
end

local function isHTML(text)
    if type(text) ~= "string" then
        return true
    end

    local lower = text:lower()

    return lower:find("<!doctype", 1, true)
        or lower:find("<html", 1, true)
        or lower:find("access restricted", 1, true)
end

local function cleanCode(text)
    if type(text) ~= "string" then
        return nil
    end

    if isHTML(text) then
        return nil
    end

    local fenced = text:match(
        "```[%w]*%s*\n(.-)```"
    )

    if fenced then
        text = fenced
    end

    text = text:match("^%s*(.-)%s*$")

    if not text or #text == 0 then
        return nil
    end

    return text
end

function GhostAI.Generate(message)
    if type(message) ~= "string"
        or message:match("^%s*$") then
        return nil, "Please enter a request."
    end

    local send = getRequester()

    if not send then
        return nil, "HTTP POST is unavailable."
    end

    local prompt =
        "Create ONE complete Roblox Luau LocalScript. " ..
        "Return only Lua code, no HTML or explanations. " ..
        "Include mobile support if appropriate. " ..
        "Request: " .. message

    local success, response = pcall(function()
        return send({
            Url = API,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Accept"] = "application/json"
            },
            Body = Http:JSONEncode({
                prompt = prompt
            })
        })
    end)

    if not success then
        return nil, "Could not contact AI server."
    end

    if type(response) ~= "table" then
        return nil, "Invalid server response."
    end

    local body = response.Body or response.body or ""
    local status = tonumber(
        response.StatusCode
        or response.Status
        or response.status_code
    ) or 0

    if isHTML(body) then
        return nil, "AI host blocked the request."
    end

    if status < 200 or status >= 300 then
        return nil, "AI server error: " .. status
    end

    local decoded, data = pcall(function()
        return Http:JSONDecode(body)
    end)

    if not decoded or type(data) ~= "table" then
        return nil, "AI returned invalid JSON."
    end

    if data.success ~= true then
        return nil, tostring(
            data.error or "AI generation failed."
        )
    end

    local code = cleanCode(
        data.code or data.reply
    )

    if not code then
        return nil, "AI did not return Luau code."
    end

    return code, nil
end

env.GhostAI = GhostAI

print("GHOST AI ENGINE LOADED")
