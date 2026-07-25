local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- 중복 실행 방지
if CoreGui:FindFirstChild("UnnamedEnhancementsPanel") then
    CoreGui.UnnamedEnhancementsPanel:Destroy()
end

-- [1] Unnamed 스타일 메인 UI 패널 생성
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UnnamedEnhancementsPanel"
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 380)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- 상단 타이틀 바
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 26)
titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
titleBar.TextColor3 = Color3.fromRGB(210, 210, 210)
titleBar.TextSize = 12
titleBar.Font = Enum.Font.Code
titleBar.Text = "  UNNAMED ENHANCEMENTS - DISCORD.GG/ENHANCEMENT | RIVALS"
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Parent = mainFrame

-- 기능 상태 테이블
local toggles = {
    InfiniteJump = false,
    Fly = false,
    Aimbot = true,
    SilentAim = true,
    Ragebot = true,
    VoidSpam = false
}

local MIN_SPEED, MAX_SPEED = 16, 150
local currentSpeed = 16

-- 토글 체크박스 생성 함수
local function createToggleUI(name, posX, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 24)
    btn.Position = UDim2.new(0, posX, 0, posY)
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

-- UI 컨트롤 배치 (좌우 컬럼 형태)
createToggleUI("AIMBOT (HEAD SNAP)", 15, 50, function(v) toggles.Aimbot = v end)
createToggleUI("SILENT AIM (HIT FORCE)", 15, 80, function(v) toggles.SilentAim = v end)
createToggleUI("RAGEBOT (EXTREME TARGET)", 15, 110, function(v) toggles.Ragebot = v end)
createToggleUI("FLY MODE", 15, 140, function(v) toggles.Fly = v end)
createToggleUI("INFINITE JUMP", 15, 170, function(v) toggles.InfiniteJump = v end)
createToggleUI("VOID SPAM (1000해)", 15, 200, function(v) toggles.VoidSpam = v end)

-- 속도 표시 라벨
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 220, 0, 24)
speedLabel.Position = UDim2.new(0, 15, 0, 240)
speedLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
speedLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
speedLabel.TextSize = 11
speedLabel.Font = Enum.Font.Code
speedLabel.Text = " SPEED: 16 (16 ~ 150)"
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

-- [2] 핵심 연산 및 로직 통합
UIS.JumpRequest:Connect(function()
    local char = player.Character
    if toggles.InfiniteJump and char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
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
        flyBV = Instance.new("BodyVelocity", rootPart)
        flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBV.Velocity = Vector3.zero
        
        flyBG = Instance.new("BodyGyro", rootPart)
        flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBG.CFrame = rootPart.CFrame
    elseif not state and flyBV then
        flyBV:Destroy()
        flyBG:Destroy()
        flyBV, flyBG = nil, nil
    end
end

RunService.RenderStepped:Connect(function(deltaTime)
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then return end
    local humanoid = char.Humanoid
    local rootPart = char.HumanoidRootPart

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

    -- ① 레이지봇
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
    -- ② 에임봇
    elseif toggles.Aimbot and target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
        end
    end

    -- ③ 사일런트봇 (머리 타격 강제 보정 훅)
    if toggles.SilentAim and target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            local absoluteHeadPos = head.Position
        end
    end

    -- ④ 보이드 스팸 (하늘 위 1000해 스터드 전송)
    if toggles.VoidSpam and target and target.Character then
        local enemyRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if enemyRoot then
            enemyRoot.CFrame = enemyRoot.CFrame + Vector3.new(0, 1e24, 0)
        end
    end
end)
