local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatRemote = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Combat"):WaitForChild("PlayerAttack")

local lPlr = Players.LocalPlayer
local maxAttacksPerSecond = 5 -- 5 attacks/sec = 25 attacks/5s (under your 30/5s limit)
local attackCooldown = 1 / maxAttacksPerSecond -- Dynamic delay (0.2s)

getgenv().WalkspeedEnabled = true
getgenv().Walkspeed = 75

local function getOptimalMobs()
    local validMobs = {}
    local character = lPlr.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return validMobs end

    local hrp = character.HumanoidRootPart
    for _, mob in pairs(workspace.Mobs:GetChildren()) do
        if mob.PrimaryPart and mob:GetAttribute("HP") > 0 then
            local distance = (hrp.Position - mob.PrimaryPart.Position).Magnitude
            if distance <= 150 then
                table.insert(validMobs, mob)
            end
        end
    end
    return validMobs
end

local lastAttack = 0

RunService.RenderStepped:Connect(function(deltaTime)

    local elapsed = os.clock() - lastAttack
    if elapsed >= attackCooldown then
        local mobs = getOptimalMobs()
        if #mobs > 0 then
            CombatRemote:FireServer(mobs)
            lastAttack = os.clock()
        end
    end

    if getgenv().WalkspeedEnabled then
        local lChar = lPlr.Character
        if not lChar then return end
        local lHum = lChar:FindFirstChildOfClass("Humanoid")
        local lRoot = lChar:FindFirstChild("HumanoidRootPart")
        if not lHum or not getgenv().WalkspeedEnabled or not lRoot then
            return
        end

        if lHum and lHum.MoveDirection.Magnitude > 0 then
            local walkSpeed = lHum.WalkSpeed
            local newWalkSpeed = getgenv().Walkspeed - walkSpeed
                
            lRoot.CFrame = lRoot.CFrame + (lHum.MoveDirection * newWalkSpeed * deltaTime)
        end
    end
end)

queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/ReallyDev1/DungeonHeroes/refs/heads/main/inject.lua'))()")