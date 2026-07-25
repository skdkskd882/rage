local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

if playerGui:FindFirstChild("DarkCustomPanel") then
    playerGui.DarkCustomPanel:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkCustomPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 320)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
titleBar.TextColor3 = Color3.fromRGB(240, 240, 240)
titleBar.TextSize = 14
titleBar.Font = Enum.Font.GothamBold
titleBar.Text = "  DARK CONTROL PANEL"
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local toggles = {
    InfiniteJump = false,
    Fly = false,
    Aimbot = true,
    SilentAim = true,
    Ragebot = true,
    VoidSpam = false
}

local currentSpeed = 16

local function createToggleUI(name, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 380, 0, 30)
    btn.Position = UDim2.new(0, 20, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 12
    btn.Font = Enum.Font.Gotham
    btn.Text = "  " .. name .. " [OFF]"
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = mainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.Text = "  " .. name .. " [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(0, 120, 60)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.Text = "  " .. name .. " [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        callback(state)
    end)
end

createToggleUI("AIMBOT", 50, function(v) toggles.Aimbot = v end)
createToggleUI("SILENT AIM", 85, function(v) toggles.SilentAim = v end)
createToggleUI("RAGEBOT", 120, function(v) toggles.Ragebot = v end)
createToggleUI("FLY MODE", 155, function(v) toggles.Fly = v end)
createToggleUI("INFINITE JUMP", 190, function(v) toggles.InfiniteJump = v end)
createToggleUI("VOID SPAM (1000해)", 225, function(v) toggles.VoidSpam = v end)

UIS.JumpRequest:Connect(function()
    local char = player.Character
    if toggles.InfiniteJump and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local function getBestTarget()
    local bestTarget, shortestDist = nil, math.huge
    local mouseLoc = UIS:GetMouseLocation()
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local head = p.Character:FindFirstChild("Head")
            if hum and hum.Health > 0 and head then
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        bestTarget = p
                    end
                end
            end
        end
    end
    return bestTarget
end

local flyBV, flyBG
local function updateFly(state, rootPart)
    if state and not flyBV and rootPart then
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = rootPart
        
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBG.CFrame = rootPart.CFrame
        flyBG.Parent = rootPart
    elseif not state and flyBV then
        flyBV:Destroy()
        flyBG:Destroy()
        flyBV, flyBG = nil, nil
    end
end

RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    humanoid.WalkSpeed = currentSpeed

    if toggles.Fly then
        updateFly(true, rootPart)
        if flyBV and flyBG then
            flyBV.Velocity = camera.CFrame.LookVector * currentSpeed * 1.5
            flyBG.CFrame = camera.CFrame
        end
    else
        updateFly(false, rootPart)
    end

    local target = getBestTarget()

    if toggles.Ragebot then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local enemyRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and enemyRoot then
                    if (rootPart.Position - enemyRoot.Position).Magnitude <= 1000 then
                        camera.CFrame = CFrame.new(camera.CFrame.Position, enemyRoot.Position)
                        break
                    end
                end
            end
        end
    elseif toggles.Aimbot and target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
        end
    end

    if toggles.VoidSpam and target and target.Character then
        local enemyRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if enemyRoot then
            enemyRoot.CFrame = enemyRoot.CFrame + Vector3.new(0, 1e24, 0)
        end
    end
end)
