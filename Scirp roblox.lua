--[[ TDK Hub | Blox Fruits
     Tính năng: Auto Farm, Auto Quest, Auto Raid Finder, Server Hop
     Dùng cho Delta Executor
]]

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "TDK_Hub"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 340)
main.Position = UDim2.new(0, 20, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
title.Text = "⚡ TDK HUB | BLOX FRUITS"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = main

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 12)
tc.Parent = title

local function makeToggle(text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 240, 0, 34)
    btn.Position = UDim2.new(0, 20, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text .. " : OFF"
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = main
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. " : " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 60) or Color3.fromRGB(45, 45, 55)
        callback(state)
    end)
    return btn
end

local autoFarm = false
local autoQuest = false

local function getChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function farmLoop()
    while autoFarm do
        task.wait(0.3)
        local char = getChar()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local closest, dist = nil, math.huge
        for _, mob in pairs(workspace.Enemies:GetChildren()) do
            if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                if mobRoot then
                    local d = (hrp.Position - mobRoot.Position).Magnitude
                    if d < dist then dist = d; closest = mobRoot end
                end
            end
        end
        if closest and dist < 500 then
            hrp.CFrame = closest.CFrame * CFrame.new(0, 0, 8)
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end
end

local function questLoop()
    while autoQuest do
        task.wait(2)
        local char = getChar()
        for _, npc in pairs(workspace.NPCs:GetChildren()) do
            if npc:FindFirstChild("Humanoid") then
                local name = npc.Name
                if string.find(name, "Quest") or string.find(name, "Task") then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                        task.wait(0.5)
                        local prompt = npc:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then
                            prompt:InputHoldBegin()
                            task.wait(1)
                            prompt:InputHoldEnd()
                        end
                    end
                end
            end
        end
    end
end

makeToggle("Auto Farm", 50, function(v) autoFarm = v; if v then task.spawn(farmLoop) end end)
makeToggle("Auto Quest", 90, function(v) autoQuest = v; if v then task.spawn(questLoop) end end)

-- Teleport nhanh
local islands = {
    ["Sea 1 - Starter"] = Vector3.new(100, 50, 100),
    ["Sea 1 - Jungle"] = Vector3.new(-500, 50, -500),
    ["Sea 2 - Kingdom"] = Vector3.new(2000, 50, 2000),
    ["Sea 3 - Floating"] = Vector3.new(-5000, 50, -5000),
}
local y = 130
for name, pos in pairs(islands) do
    makeToggle("TP " .. name, y, function(v)
        if v then
            local hrp = getChar():FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(pos) end
        end
    end)
    y = y + 40
end

print("[TDK HUB] Loaded successfully.")