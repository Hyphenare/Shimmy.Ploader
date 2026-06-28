-- Shimmy Loader - Clean Readable Version
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShimmyLoader"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Input Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 600)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "Shimmy Loader"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Parent = mainFrame

local inputBoxes = {}
for i = 1, 10 do
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 40)
    box.Position = UDim2.new(0, 10, 0, 60 + (i-1)*45)
    box.PlaceholderText = "Game " .. i .. " (e.g. Prison Life)"
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextScaled = true
    box.Parent = mainFrame
    inputBoxes[i] = box
end

local generateBtn = Instance.new("TextButton")
generateBtn.Size = UDim2.new(1, -20, 0, 50)
generateBtn.Position = UDim2.new(0, 10, 1, -60)
generateBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
generateBtn.Text = "Generate Loadout"
generateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
generateBtn.TextScaled = true
generateBtn.Parent = mainFrame

-- Loadout Frame
local loadoutFrame = Instance.new("Frame")
loadoutFrame.Size = UDim2.new(0, 500, 0, 600)
loadoutFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
loadoutFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
loadoutFrame.Visible = false
loadoutFrame.Parent = screenGui

local loadoutTitle = Instance.new("TextLabel")
loadoutTitle.Size = UDim2.new(1, 0, 0, 50)
loadoutTitle.BackgroundTransparency = 1
loadoutTitle.Text = "Generated Loadout - Click Exec"
loadoutTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
loadoutTitle.TextScaled = true
loadoutTitle.Parent = loadoutFrame

local loadoutSlots = {}
local gameNames = {}

local function fetchBestScript(gameName)
    local success, code = pcall(function()
        local searchUrl = "https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(gameName) .. "&max=5&sortBy=views&order=desc"
        local data = HttpService:GetAsync(searchUrl)
        local json = HttpService:JSONDecode(data)
        
        if json.result and json.result.scripts and #json.result.scripts > 0 then
            local bestScript = json.result.scripts[1]
            local rawUrl = "https://scriptblox.com/api/script/raw/" .. bestScript._id
            return HttpService:GetAsync(rawUrl)
        end
        return nil
    end)
    return success and code or nil
end

generateBtn.MouseButton1Click:Connect(function()
    gameNames = {}
    for i = 1, 10 do
        local name = inputBoxes[i].Text:match("^%s*(.-)%s*$")
        gameNames[i] = name \~= "" and name or ("Game " .. i)
    end
    
    mainFrame.Visible = false
    loadoutFrame.Visible = true
    
    for _, slot in ipairs(loadoutSlots) do
        slot:Destroy()
    end
    loadoutSlots = {}
    
    for i = 1, 10 do
        local slotFrame = Instance.new("Frame")
        slotFrame.Size = UDim2.new(1, -20, 0, 50)
        slotFrame.Position = UDim2.new(0, 10, 0, 60 + (i-1)*55)
        slotFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        slotFrame.Parent = loadoutFrame
        
        local numberLabel = Instance.new("TextLabel")
        numberLabel.Size = UDim2.new(0, 40, 1, 0)
        numberLabel.BackgroundTransparency = 1
        numberLabel.Text = i .. "."
        numberLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        numberLabel.TextScaled = true
        numberLabel.Parent = slotFrame
        
        local gameLabel = Instance.new("TextLabel")
        gameLabel.Size = UDim2.new(0.6, -50, 1, 0)
        gameLabel.Position = UDim2.new(0, 50, 0, 0)
        gameLabel.BackgroundTransparency = 1
        gameLabel.Text = gameNames[i]
        gameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        gameLabel.TextScaled = true
        gameLabel.TextXAlignment = Enum.TextXAlignment.Left
        gameLabel.Parent = slotFrame
        
        local execButton = Instance.new("TextButton")
        execButton.Size = UDim2.new(0, 80, 0.8, 0)
        execButton.Position = UDim2.new(1, -90, 0.1, 0)
        execButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        execButton.Text = "Exec"
        execButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        execButton.Parent = slotFrame
        
        execButton.MouseButton1Click:Connect(function()
            execButton.Text = "Fetching..."
            local scriptCode = fetchBestScript(gameNames[i])
            if scriptCode then
                local success, err = pcall(function()
                    loadstring(scriptCode)()
                end)
                execButton.Text = success and "Executed!" or "Error"
            else
                execButton.Text = "Not Found"
            end
            task.wait(2)
            execButton.Text = "Exec"
        end)
        
        table.insert(loadoutSlots, slotFrame)
    end
end)

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -45, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = loadoutFrame
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
