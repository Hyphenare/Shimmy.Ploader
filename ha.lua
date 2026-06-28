-- Shimmy Explorer - Fixed
local HttpService = game:GetService("HttpService")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShimmyPro"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 520, 0, 380)
main.Position = UDim2.new(0.5, -260, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
main.BorderSizePixel = 0
main.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.BackgroundTransparency = 1
title.Text = "Shimmy Explorer"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -38, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -40, 0, 40)
searchBox.Position = UDim2.new(0, 20, 0, 55)
searchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
searchBox.PlaceholderText = "Search scripts on ScriptBlox..."
searchBox.TextColor3 = Color3.fromRGB(255,255,255)
searchBox.TextScaled = true
searchBox.Font = Enum.Font.SourceSans
searchBox.Parent = main

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -40, 1, -150)
scroll.Position = UDim2.new(0, 20, 0, 110)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 8
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = scroll

local function fetchScripts(query)
    for _, v in pairs(scroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    local url = "https://scriptblox.com/api/script/fetch?page=1&limit=25&search=" .. HttpService:UrlEncode(query)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        for _, s in pairs(data.result.scripts) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,55)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            btn.Text = s.title .. "\ncom.shimmy." .. (s.gameName or "universal"):lower() .. "." .. s.slug
            btn.TextColor3 = Color3.fromRGB(200,255,200)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.TextScaled = true
            btn.Parent = scroll

            btn.MouseButton1Click:Connect(function()
                if s.script then
                    loadstring(s.script)()
                end
            end)
        end
        scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)
    else
        warn("Failed to fetch from ScriptBlox")
    end
end

searchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and searchBox.Text \~= "" then
        fetchScripts(searchBox.Text)
    end
end)

-- Initial load
task.spawn(function()
    fetchScripts("universal")
end)

print("Shimmy Explorer loaded. Search for scripts.")
