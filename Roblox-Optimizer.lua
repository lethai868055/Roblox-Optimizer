repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer
local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/MacLib"))()
local win = MacLib:CreateWindow("Roblox Optimizer")

local AutoOptimize = false
local ManualOptions = {CPU_GPU=false, ClearRAM=false, RemoveLagObjects=false}
local AntiAFKEnabled = false
local LoggingEnabled = false
local SafeMode = true
local AggressiveMode = false
local FPSLimit = 30
local AutoReExe = true
local DarkTheme = true

setfpscap(FPSLimit)

local vu = game:GetService("VirtualUser")
local player = game:GetService("Players").LocalPlayer
local function clickAnywhere()
    vu:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    vu:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end
task.spawn(function()
    while true do
        if AntiAFKEnabled then
            clickAnywhere()
        end
        task.wait(300)
    end
end)
player.Idled:Connect(function()
    if AntiAFKEnabled then
        clickAnywhere()
    end
end)

local function Optimize()
    if AutoOptimize or ManualOptions.CPU_GPU then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e9
        Lighting.Brightness = 1
        sethiddenproperty(Lighting,"Technology",Enum.Technology.Compatibility)
    end
    if AutoOptimize or ManualOptions.ClearRAM then
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Explosion") or v:IsA("Fire") or v:IsA("Smoke") then
                v:Destroy()
            end
        end
        collectgarbage("collect")
    end
    if AutoOptimize or ManualOptions.RemoveLagObjects then
        for _,v in pairs(workspace:GetChildren()) do
            if v:IsA("Model") and #v:GetDescendants()>250 then
                v:Destroy()
            end
        end
    end
end

local tab1 = win:Tab("Optimize")
tab1:Button("Auto Optimize", function()
    AutoOptimize = not AutoOptimize
    if AutoOptimize then
        MacLib:Notify("Auto Optimize ON",3)
        task.spawn(function()
            while AutoOptimize do
                Optimize()
                task.wait(15)
            end
        end)
    else
        MacLib:Notify("Auto Optimize OFF",3)
    end
end)

tab1:Toggle("CPU/GPU",false,function(v) ManualOptions.CPU_GPU=v end)
tab1:Toggle("Clear RAM",false,function(v) ManualOptions.ClearRAM=v end)
tab1:Toggle("Remove Lag Objects",false,function(v) ManualOptions.RemoveLagObjects=v end)
tab1:Button("Manual Optimize Now",function()
    Optimize()
    MacLib:Notify("Manual Optimize Done",3)
end)

local tab2 = win:Tab("Stat Monitor")
local Stats = game:GetService("Stats")
tab2:Label("Updating every 2s")
task.spawn(function()
    while true do
        local fps = workspace:GetRealPhysicsFPS()
        local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
        local ram = collectgarbage("count")/1024
        local ramPercent = math.min(ram/5000*100,100)
        local objCount = #workspace:GetDescendants()
        tab2:SetLabelText(1,"FPS: "..math.floor(fps).." | Ping: "..ping.." | RAM: "..math.floor(ram).."MB ("..math.floor(ramPercent).."%) | Objects: "..objCount)
        task.wait(2)
    end
end)

local tab3 = win:Tab("Settings")
tab3:Toggle("Anti-AFK",false,function(v) AntiAFKEnabled=v end)
tab3:Toggle("Logging",false,function(v) LoggingEnabled=v end)
tab3:Toggle("Safe Mode",true,function(v) SafeMode=v end)
tab3:Toggle("Aggressive Mode",false,function(v) AggressiveMode=v end)
tab3:Toggle("Auto Re-Execute",true,function(v) AutoReExe=v end)
tab3:Toggle("Dark Theme",true,function(v) DarkTheme=v end)
tab3:Slider("Set FPS Limit",30,15,120,true,function(v)
    FPSLimit=v
    setfpscap(FPSLimit)
end)

local TeleportService = game:GetService("TeleportService")
TeleportService.TeleportInitFailed:Connect(function()
    if AutoReExe then
        syn.queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/lethai868055/Roblox-Optimizer/main/Roblox-Optimizer.lua"))()]])
    end
end)
