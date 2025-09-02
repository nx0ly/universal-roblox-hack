-- gui stuff
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local esp_settings = {
    box_color = Color3.fromRGB(255, 0, 0),
    box_thickness = 2

}

-- system variables
players = game:GetService("Players")
user_input_service = game:GetService("UserInputService")
player = players.LocalPlayer
run_service = game:GetService("RunService")
camera = game.Workspace.CurrentCamera
tween_service = game.TweenService
mouse_location = user_input_service.GetMouseLocation
coregui = game:FindFirstChild("CoreGui")
space = game:GetService("Workspace")
camera = space.CurrentCamera
mouse = player:GetMouse()

-- hack variables
speed_hack_enabled = false
speed_hack_val = 16
jump_boost_enabled = false
jump_boost_val = 50
noclip_enabled = false
hack_interval = 50
automatic_esp = false
weapon_esp = false
team_esp = false
my_team_esp = false
aimbot_cam_tween = nil
aimbot_enabled = false
aimbot_type = nil
aimbot_lag_compensation = false
aimbot_lag_pred_amnt = 0
pathfind_allow_jump = true
pathfind_smart_costs = true
pathfind_avoid_impossible_terrain = true
esp_type = "Corner box"

c_base_player_spd = 16

-- gui
local window = Fluent:CreateWindow({
    Title = "Hackmod 1.0.0a",
    SubTitle = "Powered by Fluent " .. Fluent.Version,
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local tabs = {
    movement = window:AddTab({
        Title = "Movement",
        Icon = "move"
    }),
    esp = window:AddTab({
        Title = "ESP",
        Icon = "arrow"
    }),
    pathfind = window:AddTab({
        Title = "Pathfinder",
        Icon = "milestone"
    }),
    aimbot = window:AddTab({
        Title = "Aimbot",
        Icon = "crosshair"
    }),
    misc = window:AddTab({
        Title = "Misc",
        Icon = "settings"
    })
}

local options = Fluent.Options

do
    -- movement tab

    local speed_hack_section = tabs.movement:AddSection("Speed Hack")
    speed_hack_toggle = speed_hack_section:AddToggle("speed_hack_toggle", {
        Title = "Enable Speed Hack",
        Default = false,
        Callback = function()
            if options.speed_hack_toggle then
                local Value = options.speed_hack_toggle.Value
                print(Value)

                if Value then
                    speed_hack_enabled = true
                    update_spd(speed_hack_val)
                else
                    speed_hack_enabled = false
                    update_spd(c_base_player_spd)
                end
            end
        end
    })
    speed_hack_slider = speed_hack_section:AddSlider("speed_hack_slider", {
        Title = "Studs / s",
        Description = "Specify the amount of studs to travel per second.",
        Default = 16,
        Min = 0,
        Max = 300,
        Rounding = 1,
        Callback = function(Value)
            speed_hack_val = Value
            update_spd(speed_hack_val)
        end
    })
    speed_hack_keybind = speed_hack_section:AddKeybind("speed_hack_keybind", {
        Title = "Speed Hack Keybind",
        Mode = "Toggle",
        Default = "G",

        Callback = function(Value)
            speed_hack_enabled = not speed_hack_enabled
            if options.speed_hack_toggle then
                options.speed_hack_toggle:SetValue(speed_hack_enabled)
            end

            if speed_hack_enabled then
                update_spd(speed_hack_val)
            else
                update_spd(c_base_player_spd)
            end
        end
    })

    local jump_boost_section = tabs.movement:AddSection("Jump Boost")
    jump_boost_toggle = jump_boost_section:AddToggle("jump_boost_toggle", {
        Title = "Enable Jump Boost",
        Default = false,
        Callback = function()
            jump_boost_enabled = not jump_boost_enabled
        end
    })
    jump_boost_slider = jump_boost_section:AddSlider("jump_boost_slider", {
        Title = "Studs",
        Description = "Specify the amount of studs to jump.",
        Default = 16,
        Min = 0,
        Max = 300,
        Rounding = 1,
        Callback = function(Value)
            jump_boost_val = Value
        end
    })
    jump_boost_keybind = jump_boost_section:AddKeybind("jump_boost_keybind", {
        Title = "Jump Boost Keybind",
        Mode = "Toggle",
        Default = "G",

        Callback = function(Value)
            jump_boost_enabled = not jump_boost_enabled
        end
    })

    -- esp tab
    esp_type_dropdown = tabs.esp:AddDropdown("esp_type_dropdown", {
        Title = "ESP Type",
        Values = {"Corner box", "Skeleton", "Full box", "Chams (Highlight)", "Chams (Outline)"},
        Multi = false,
        Default = 1
    })
    esp_type_dropdown:SetValue("Corner box")

    esp_type_dropdown:OnChanged(function(Value)
        esp_type = Value
    end)

    automatic_esp_toggle = tabs.esp:AddToggle("automatic_esp_toggle", {
        Title = "Automatic ESP",
        Description = "Automatically determines based on the game who to target.",
        Default = false,
        Callback = function(Value)
            automatic_esp = Value
        end
    })

    weapon_esp_toggle = tabs.esp:AddToggle("weapon_esp_toggle", {
        Title = "Weapon Based",
        Description = "Classifies players based on their weapon (some games supported).",
        Default = false,
        Callback = function(Value)
            weapon_esp = Value
        end
    })

    team_esp_toggle = tabs.esp:AddToggle("team_esp_toggle", {
        Title = "Team Based",
        Description = "Classifies players based on their team.",
        Default = false,
        Callback = function(Value)
            team_esp = Value
        end
    })

    include_my_team_esp_toggle = tabs.esp:AddToggle("include_my_team_esp_toggle", {
        Title = "Include my team.",
        Description = "If disabled, will not draw ESP for your teammates.",
        Default = false,
        Callback = function(Value)
            my_team_esp = Value
        end
    })

    -- misc tab
    hack_interval_slider = tabs.misc:AddSlider("hack_interval_slider", {
        Title = "Hack Interval",
        Description = "Interval at which the hack will update the game values.",
        Default = 50,
        Min = 1,
        Max = 250,
        Rounding = 1,
        Callback = function(Value)
            hack_interval = Value
            print(player.Backpack)
        end
    })
    noclip_toggle = tabs.misc:AddToggle("noclip_toggle", {
        Title = "Enable NoClip",
        Description = "Allows you to phase through walls.",
        Default = false,
        Callback = function(Value)
            noclip_enabled = Value
        end
    })

    -- aimbot tab
    aimbot_keybind = tabs.aimbot:AddKeybind("aimbot_keybind", {
        Title = "Aimbot",
        Mode = "Toggle",
        Default = "K",

        Callback = function(Value)
            aimbot_enabled = not aimbot_enabled
        end
    })

    aimbot_type_dropdown = tabs.aimbot:AddDropdown("aimbot_type_dropdown", {
        Title = "Aimbot Type",
        Description = "Who the aimbot will target.",
        Values = {"Team", "Weapon", "Nearest"},
        Multi = false,
        Default = 1
    })
    aimbot_type_dropdown:SetValue("Team")

    aimbot_type_dropdown:OnChanged(function(Value)
        aimbot_type = Value
    end)

    aimbot_lag_compensation_toggle = tabs.aimbot:AddToggle("aimbot_lag_compensation_toggle", {
        Title = "Enable Lag Compensation",
        Description = "Takes into account network latency.",
        Default = false,
        Callback = function(Value)
            aimbot_lag_compensation = Value
        end
    })

    aimbot_lag_pred_amnt_slider = tabs.aimbot:AddSlider("aimbot_lag_pred_amnt_slider", {
        Title = "Prediction Amount.",
        Description = "How much prediction it should do.",
        Default = 0.5,
        Min = 0.01,
        Max = 1,
        Rounding = 1,
        Callback = function(Value)
            aimbot_lag_pred_amnt = Value
        end
    })

    -- pathfind
    pathfind_allow_jump_toggle = tabs.pathfind:AddToggle("pathfind_allow_jump_toggle", {
        Title = "Allow Jumping",
        Description = "Whether or not the player is allowed to jump while following the path.",
        Default = true,
        Callback = function()

        end
    })

    pathfind_smart_costs_toggle = tabs.pathfind:AddToggle("pathfind_smart_costs_toggle", {
        Title = "Dynamic Cost Adjustment",
        Description = "Assigns higher costs to unfavourable terrain.",
        Default = true,
        Callback = function()

        end
    })

    pathfind_avoid_impossible_terrain_toggle = tabs.pathfind:AddToggle("pathfind_avoid_impossible_terrain_toggle", {
        Title = "Avoid Unwalkable Terrain",
        Description = "Avoids unwalkable terrain.",
        Default = true,
        Callback = function()

        end
    })

    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)

    -- Ignore keys that are used by ThemeManager.
    -- (we dont want configs to save themes, do we?)
    SaveManager:IgnoreThemeSettings()

    -- You can add indexes of elements the save manager should ignore
    SaveManager:SetIgnoreIndexes({})

    InterfaceManager:SetFolder("HackMod")
    SaveManager:SetFolder("HackMod")

    InterfaceManager:BuildInterfaceSection(tabs.misc)
    SaveManager:BuildConfigSection(tabs.misc)

    window:SelectTab(1)

    SaveManager:LoadAutoloadConfig()

    Fluent:Notify({
        Title = "HackMod Loaded!",
        Content = "HackMod successfully loaded!",
        SubContent = "",
        Duration = 3
    })
end

-- not gui code now finally omg

function update_spd(spd)
    local character = player.Character
    if not character then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    if speed_hack_enabled then
        humanoid.WalkSpeed = spd
    else
        humanoid.WalkSpeed = c_base_player_spd
    end
end

function create_cham(p, color, should_fill)
    if p == player then
        return
    end
    if not p.Character then
        return
    end

    local old_cham = p.Character:FindFirstChild("Cham")
    if not old_cham then
        old_cham = Instance.new("Highlight")
        old_cham.Name = "Cham"
        old_cham.Adornee = p.Character
        old_cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        old_cham.Parent = p.Character
    end

    if should_fill then
        old_cham.FillTransparency = 0.5
        old_cham.FillColor = color
        old_cham.OutlineTransparency = 1
    else
        old_cham.OutlineTransparency = 0.5
        old_cham.OutlineColor = color
        old_cham.FillTransparency = 1
    end
end

corner_box_esp_cache = {}

function create_esp()
    return {
        tl1 = new_line(esp_settings.box_color, esp_settings.box_thickness),
        tl2 = new_line(esp_settings.box_color, esp_settings.box_thickness),
        tr1 = new_line(esp_settings.box_color, esp_settings.box_thickness),
        tr2 = new_line(esp_settings.box_color, esp_settings.box_thickness),
        bl1 = new_line(esp_settings.box_color, esp_settings.box_thickness),
        bl2 = new_line(esp_settings.box_color, esp_settings.box_thickness),
        br1 = new_line(esp_settings.box_color, esp_settings.box_thickness),
        br2 = new_line(esp_settings.box_color, esp_settings.box_thickness)
    }
end

-- makes a line
function new_line(color, thickness)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2:new(0, 0)
    line.To = Vector2:new(0, 0)
    line.Color = color
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

function set_visible(lib, state)
    for i, v in pairs(lib) do
        v.Visible = state
    end
end

function set_color(lib, color)
    for i, v in pairs(lib) do
        v.Color = color
    end
end

-- haha steal this
function Rainbow(lib, delay)
    for hue = 0, 1, 1 / 30 do
        local color = Color3.fromHSV(hue, 0.6, 1)
        set_color(lib, color)
        task.wait(delay)
    end
    Rainbow(lib)
end

function hide_esp(lib)
    if not lib then
        return
    end
    set_visible(lib, false)
end

-- part used for esp
part = Instance.new("Part")
part.Parent = space
part.Transparency = 1
part.CanCollide = false
part.Size = Vector3.new(1, 1, 1)
part.Position = Vector3.new(0, 0, 0)

-- toolbox item for tp
function create_tp_tool()
    local tp_toll = Instance.new("Tool")
    tp_toll.Name = "TP Tool"
    tp_toll.RequiresHandle = false
    tp_toll.Parent = player.Backpack

    tp_toll.Activated:Connect(function()
        local character = player.Character
        if not character then
            return
        end

        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then
            return
        end

        local target = mouse.Hit.Position
        root.CFrame = CFrame.new(target + Vector3.new(0, 3, 0)) -- add y value so no floor clipping
    end)
end

create_tp_tool()
--[[player.CharacterAdded:Connect(function(character)
    create_tp_tool()
    corner_box_esp_cache[character.Parent] = create_esp()
end)]]

player.CharacterRemoving:Connect(function(character)
    corner_box_esp_cache[character] = nil

    if character.Character then
        local cham = character.Character:FindFirstChild("Cham")
        if cham then
            cham:Destroy()
        end
    end
end)

-- make sure everyting works
local co = coroutine.create(function()
    run_service.RenderStepped:Connect(function(dt)
        -- aimbot
        if aimbot_enabled then
            local target = nil
            if aimbot_type == "Nearest" or aimbot_type == "Team" then
                target = get_closest_player_to_camera(players:GetPlayers())
            elseif aimbot_type == "Weapon" then
                target = get_closest_dangerous_player_to_camera(players:GetPlayers())
            end

            if target ~= nil then
                local lag_comp = (aimbot_lag_compensation and (player:GetNetworkPing() * aimbot_lag_pred_amnt)) or 0

                aimbot_cam_tween = tween_service:Create(camera, TweenInfo.new(0.15, Enum.EasingStyle.Exponential,
                    Enum.EasingDirection.Out), {
                    CFrame = CFrame.new(camera.CFrame.Position,
                        target.Character.Head.Position + (target.Character.Head.Velocity * lag_comp))
                });
                aimbot_cam_tween:Play();
            end
        end

        -- update automatic esp
        if automatic_esp then
            for _, p in pairs(players:GetPlayers()) do
                if p ~= player then
                    if esp_type == "Corner box" then
                        if not corner_box_esp_cache[p] then
                            corner_box_esp_cache[p] = create_esp()
                        end
                        local lib = corner_box_esp_cache[p]

                        local character = p.Character
                        local _, visible = camera:WorldToViewportPoint(character.HumanoidRootPart.Position)
                        local rootpart = character.HumanoidRootPart;

                        if visible and IsAlive(p) then
                            part.Size = Vector3.new(rootpart.Size.X, rootpart.Size.Y * 1.25, rootpart.Size.Z)
                            part.CFrame = CFrame.new(rootpart.CFrame.Position, camera.CFrame.Position)

                            local sizex = part.Size.X
                            local sizey = part.Size.Y

                            local tl = camera:WorldToViewportPoint((part.CFrame * CFrame.new(sizex, sizey, 0)).Position)
                            local tr =
                                camera:WorldToViewportPoint((part.CFrame * CFrame.new(-sizex, sizey, 0)).Position)
                            local bl =
                                camera:WorldToViewportPoint((part.CFrame * CFrame.new(sizex, -sizey, 0)).Position)
                            local br = camera:WorldToViewportPoint(
                                (part.CFrame * CFrame.new(-sizex, -sizey, 0)).Position)

                            if weapon_esp then
                                local dangerous, _ = dangerous_test(p)
                                local helpful, _ = good_test(p)

                                if dangerous then
                                    set_color(lib, Color3.fromRGB(220, 100, 100))
                                elseif helpful then
                                    set_color(lib, Color3.fromRGB(100, 120, 220))
                                else
                                    set_color(lib, Color3.fromRGB(100, 220, 120))
                                end
                            elseif team_esp then
                                if GetTeam(player) == GetTeam(p) then
                                    if my_team_esp then
                                        set_color(lib, Color3.fromRGB(100, 220, 120))
                                    else
                                        set_visible(lib, false)
                                    end
                                else
                                    set_color(lib, Color3.fromRGB(220, 100, 100))
                                end
                            else
                                set_color(lib, Color3.fromRGB(220, 220, 100))
                            end

                            local dist = (camera.CFrame.Position - rootpart.Position).magnitude
                            local offset = math.clamp(1 / dist * 500, 2, 300) * 0.75

                            lib.tl1.From = Vector2.new(tl.X, tl.Y)
                            lib.tl1.To = Vector2.new(tl.X + offset, tl.Y)
                            lib.tl2.From = Vector2.new(tl.X, tl.Y)
                            lib.tl2.To = Vector2.new(tl.X, tl.Y + offset)

                            lib.tr1.From = Vector2.new(tr.X, tr.Y)
                            lib.tr1.To = Vector2.new(tr.X - offset, tr.Y)
                            lib.tr2.From = Vector2.new(tr.X, tr.Y)
                            lib.tr2.To = Vector2.new(tr.X, tr.Y + offset)

                            lib.bl1.From = Vector2.new(bl.X, bl.Y)
                            lib.bl1.To = Vector2.new(bl.X + offset, bl.Y)
                            lib.bl2.From = Vector2.new(bl.X, bl.Y)
                            lib.bl2.To = Vector2.new(bl.X, bl.Y - offset)

                            lib.br1.From = Vector2.new(br.X, br.Y)
                            lib.br1.To = Vector2.new(br.X - offset, br.Y)
                            lib.br2.From = Vector2.new(br.X, br.Y)
                            lib.br2.To = Vector2.new(br.X, br.Y - offset)

                            set_visible(lib, true)
                        else
                            hide_esp(lib)
                        end
                    elseif esp_type == "Chams (Highlight)" then
                        if corner_box_esp_cache then
                            for _, lib in pairs(corner_box_esp_cache) do
                                set_visible(lib, false)
                            end

                            corner_box_esp_cache = {}
                        end

                        local color
                        if weapon_esp then
                            local dangerous = dangerous_test(p)
                            local helpful = good_test(p)
                            if dangerous then
                                color = Color3.fromRGB(220, 100, 100)
                            elseif helpful then
                                color = Color3.fromRGB(100, 120, 220)
                            else
                                color = Color3.fromRGB(100, 220, 120)
                            end
                        elseif team_esp then
                            if GetTeam(player) == GetTeam(p) then
                                if my_team_esp then
                                    color = Color3.fromRGB(100, 220, 120)
                                else
                                    color = nil
                                end
                            else
                                color = Color3.fromRGB(220, 100, 100)
                            end
                        else
                            color = Color3.fromRGB(220, 220, 100)
                        end

                        if color then
                            create_cham(p, color, true)
                        else
                            local cham = p.Character:FindFirstChild("Cham")
                            if cham then
                                cham:Destroy()
                            end
                        end

                    elseif esp_type == "Chams (Outline)" then
                        if corner_box_esp_cache then
                            for _, lib in pairs(corner_box_esp_cache) do
                                set_visible(lib, false)
                            end

                            corner_box_esp_cache = {}
                        end

                        local color
                        if weapon_esp then
                            local dangerous = dangerous_test(p)
                            local helpful = good_test(p)
                            if dangerous then
                                color = Color3.fromRGB(220, 100, 100)
                            elseif helpful then
                                color = Color3.fromRGB(100, 120, 220)
                            else
                                color = Color3.fromRGB(100, 220, 120)
                            end
                        elseif team_esp then
                            if GetTeam(player) == GetTeam(p) then
                                if my_team_esp then
                                    color = Color3.fromRGB(100, 220, 120)
                                else
                                    color = nil
                                end
                            else
                                color = Color3.fromRGB(220, 100, 100)
                            end
                        else
                            color = Color3.fromRGB(220, 220, 100)
                        end

                        if color then
                            create_cham(p, color, false)
                        else
                            local cham = p.Character:FindFirstChild("Cham")
                            if cham then
                                cham:Destroy()
                            end
                        end
                    end
                end
            end
        else
            if corner_box_esp_cache then
                for _, lib in pairs(corner_box_esp_cache) do
                    set_visible(lib, false)
                end

                corner_box_esp_cache = {}
            end
        end

        if not automatic_esp or (esp_type ~= "Chams (Highlight)" and esp_type ~= "Chams (Outline)") then
            for _, plr in ipairs(players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local cham = plr.Character:FindFirstChild("Cham")
                    if cham then
                        cham:Destroy()
                    end
                end
            end
        end

        -- speed hack
        if speed_hack_enabled then
            update_spd(speed_hack_val)
        else
            update_spd(c_base_player_spd)
        end

        -- noclip
        if noclip_enabled then
            game.Players.LocalPlayer.Character:WaitForChild("Head").CanCollide = false
            game.Players.LocalPlayer.Character:WaitForChild("UpperTorso").CanCollide = false
            game.Players.LocalPlayer.Character:WaitForChild("LowerTorso").CanCollide = false
            game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CanCollide = false
        else
            game.Players.LocalPlayer.Character:WaitForChild("Head").CanCollide = true
            game.Players.LocalPlayer.Character:WaitForChild("UpperTorso").CanCollide = true
            game.Players.LocalPlayer.Character:WaitForChild("LowerTorso").CanCollide = true
            game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CanCollide = true
        end
    end)
end)
coroutine.resume(co)

target_weapons = {"Knife", "Hammer"}
-- i ran out of names
function dangerous_test(temp)
    local function isatarget(name)
        for _, tool_name in ipairs(target_weapons) do
            if name == tool_name then
                return true
            end
        end
        return false
    end

    -- if in their backpack
    local backpack = temp:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if isatarget(item.Name) then
                return true, item.Name
            end
        end
    end

    -- if their holding
    local character = temp.Character
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if isatarget(item.Name) then
                return true, item.Name
            end
        end
    end

    return false, nil
end

helpful_weapons = {"Knife", "Hammer", "Gun"}
-- i ran out of names
function good_test(temp)
    local function isatarget(name)
        for _, tool_name in ipairs(helpful_weapons) do
            if name == tool_name then
                return true
            end
        end
        return false
    end

    -- if in their backpack
    local backpack = temp:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if isatarget(item.Name) then
                return true, item.Name
            end
        end
    end

    -- if their holding
    local character = temp.Character
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if isatarget(item.Name) then
                return true, item.Name
            end
        end
    end

    return false, nil
end

-- autoaim shit
function get_closest_player_to_camera(players)
    local fov = 360
    local target = nil

    for _, p in pairs(players) do
        if p ~= player then
            if GetTeam(player) ~= GetTeam(p) then
                if IsAlive(p) then
                    local screen_pos, on_screen = camera:WorldToViewportPoint(p.Character.Head.Position)
                    local screen_pos_2d = Vector2.new(screen_pos.X, screen_pos.Y)
                    local mag = (screen_pos_2d - mouse_location(user_input_service)).Magnitude

                    if on_screen and mag < fov then
                        fov = mag
                        target = p
                    end
                end
            end
        end
    end

    return target
end

function get_closest_dangerous_player_to_camera(players)
    local fov = 360
    local target = nil

    for _, p in pairs(players) do
        if p ~= player then
            local dangerous, _ = dangerous_test(p)
            if dangerous then
                if IsAlive(p) then
                    local screen_pos, on_screen = camera:WorldToViewportPoint(p.Character.Head.Position)
                    local screen_pos_2d = Vector2.new(screen_pos.X, screen_pos.Y)
                    local mag = (screen_pos_2d - mouse_location(user_input_service)).Magnitude

                    if on_screen and mag < fov then
                        fov = mag
                        target = p
                    end
                end
            end
        end
    end

    return target
end

function GetTeam(Player)
    if Player.Team then
        return Player.Team
    end

    return true
end

function IsAlive(Player)
    if Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") ~= nil and
        Player.Character:FindFirstChild("Humanoid") ~= nil and Player.Character.Humanoid.Health > 0 then
        return true
    end

    return false
end

print("pk")
