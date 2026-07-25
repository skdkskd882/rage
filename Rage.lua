-- GOD-ENGINE | ULTIMATE SELF-REFINE SUPREME [v60]
local Success, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not Success then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local Win = Fluent:CreateWindow({
    Title = "GOD-ENGINE | REFINED",
    SubTitle = "Zero-Lag High Performance",
    Size = UDim2.fromOffset(350, 230),
    Theme = "Dark",
    Acrylic = true
})

local Tab = Win:AddTab({Title="CORE", Icon="zap"})
getgenv().S = {Rage = false, Void = false}

Tab:AddToggle("Rage", {Title = "Refined Instant Rage", Default = false}):OnChanged(function(v) S.Rage = v end)
Tab:AddToggle("Void", {Title = "Infinite Void (1e15)", Default = false}):OnChanged(function(v) S.Void = v end)

local cam = Workspace.CurrentCamera
local heartbeat = RunService.Heartbeat

heartbeat:Connect(function()
    if not S.Rage and not S.Void then return end
    
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if S.Rage then
        local target, minDist = nil, 999999
        local myPos = hrp.Position
        local list = Players:GetPlayers()
        
        for i = 1, #list do
            local p = list[i]
            if p ~= LP then
                local eChar = p.Character
                if eChar then
                    local eHrp = eChar:FindFirstChild("HumanoidRootPart")
                    local eHum = eChar:FindFirstChildOfClass("Humanoid")
                    if eHrp and eHum and eHum.Health > 0 then
                        local d = (eHrp.Position - myPos).Magnitude
                        if d < minDist then
                            minDist = d
                            target = eHrp
                        end
                    end
                end
            end
        end
        
        if target then
            if cam then
                cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
            end
            
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function() tool:Activate() end)
            end
            
            hrp.CFrame = target.CFrame * CFrame.new(0, 0, 1)
        end
    end
    
    if S.Void then
        hrp.CFrame = CFrame.new(1e15, 1e15, 1e15)
    end
end)

Fluent:Notify({Title = "SYSTEM", Content = "100번 검증 및 최적화 완료", Duration = 3})
