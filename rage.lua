local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- 중복 실행 방지
if playerGui:FindFirstChild("UnnamedEnhancementsPanel") then
    playerGui.UnnamedEnhancementsPanel:Destroy()
end

-- [1] 안전한 UI 패널 생성 (PlayerGui 방식)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UnnamedEnhancementsPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 380)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 26)
titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
titleBar.TextColor3 = Color3.fromRGB(210, 210, 210)
titleBar.TextSize = 12
titleBar.Font = Enum.Font.Code
titleBar.Text = "  UNNAMED ENHANCEMENTS - RIVALS"
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Parent = mainFrame

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
    btn.Size = UDim2.new(0, 220, 0, 24)
    btn.Position = UDim2.new(0, 15, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.fromRGB(190, 190, 190)
    btn.TextSize = 11
    btn.Font = Enum.Font.Code
    btn.Text = " [ ]  " .. name
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = mainFrame

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.Text = " [X]  " .. name
            btn.BackgroundColor3 = Color3.fromRGB(0, 60, 30)
            btn.TextColor3 = Color3.fromRGB(0, 255, 128)
        else
            btn.Text = " [ ]  " .. name
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            btn.TextColor3 = Color3.fromRGB(190, 190, 190)
        end
        callback(state)
    end)
end

createToggleUI("AIMBOT", 50, function(v) toggles.Aimbot = v end)
createToggleUI("SILENT AIM", 80, function(v) toggles.SilentAim = v end)
createToggleUI("RAGEBOT", 110, function(v) toggles.Ragebot = v end)
createToggleUI("FLY MODE", 140, function(v) toggles.Fly = v end)
createToggleUI("INFINITE JUMP", 170, function(v) toggles.InfiniteJump = v end)
createToggleUI("VOID SPAM (1000해)", 200, function(v) toggles.VoidSpam = v end)

-- [2] 핵심 로직 및 안전장치
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
