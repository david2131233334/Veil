-- ============================================================
-- VEIL — V1
-- ============================================================

do
    if _G.__VEIL_last_bind then pcall(function() game:GetService("RunService"):UnbindFromRenderStep(_G.__VEIL_last_bind) end) end
    if _G.__VEIL_viewfov_bind then pcall(function() game:GetService("RunService"):UnbindFromRenderStep(_G.__VEIL_viewfov_bind) end) end
    if _G.__VEIL_last_connections then
        for _, _0x3A4B in ipairs(_G.__VEIL_last_connections) do pcall(function() _0x3A4B:Disconnect() end) end
    end
    pcall(function()
        local _0x14E4 = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui")
        for _, _0x3A4B in ipairs(_0x14E4:GetChildren()) do
            local _0xB877 = _0x3A4B.Name
            if _0xB877 == "VEIL_UI" or _0xB877 == "VEIL_Visuals" or _0xB877 == "VEIL_FOV"
                or _0xB877 == "VEIL_Startup" or _0xB877 == "VEIL_Watermark" or _0xB877 == "VEIL_MobileOverlay"
                or _0xB877 == "VEIL_Discord" or _0xB877 == "VEIL_Premium" or _0xB877 == "VEIL_Picker"
                or _0xB877 == "VEIL_KeyUI" or _0xB877 == "VEIL_Popup" or _0xB877 == "VEIL_Crosshair" then
                _0x3A4B:Destroy()
            end
        end
    end)
    _G.__VEIL_last_bind = nil _G.__VEIL_viewfov_bind = nil _G.__VEIL_last_connections = nil
    _G.__VEIL_CameraAssist = nil _G.__VEIL_Weapon = nil _G.__VEIL_ShowStartup = nil
    _G.__VEIL_Mobile = nil _G.__VEIL_StartupDone = nil _G.__VEIL_INITIALIZED = nil
end

local _0xA548 = game:GetService("UserInputService")
local _0xFC99 = game:GetService("HttpService")
local _0x27A5 = game:GetService("TweenService")
local _0xE1FF = game:GetService("Players")
local _0xB932 = game:GetService("RunService")
local _0x3BA1 = game:GetService("Workspace")
local _0x18A8 = game:GetService("Lighting")

local function _0x955B(_0x6EA8, _0x3748) local _0xDF7B, _0x8C41 = pcall(_0x6EA8) if _0xDF7B then return _0x8C41 end return _0x3748 end

local function _0x24C5()
    local _0x5B5D = _G.__VEIL_ForceDevice
    if _0x5B5D == "mobile" then return {isMobile=true, isPC=false, isVR=false, platform="override"} end
    if _0x5B5D == "pc" then return {isMobile=false, isPC=true, isVR=false, platform="override"} end
    local _0x938C = _0x955B(function() return _0xA548:GetPlatform() end, nil)
    local _0xA21A = tostring(_0x938C or "Unknown")
    local _0xE130 = _0xA21A:find("iOS") ~= nil or _0xA21A:find("Android") ~= nil or _0xA21A:find("UWP") ~= nil
    local _0xD871 = _0x955B(function() return _0xA548.TouchEnabled end, false)
    local _0xE7BF = _0x955B(function() return _0xA548.KeyboardEnabled end, true)
    local _0x4D37 = _0x955B(function() return _0xA548.MouseEnabled end, true)
    local _0x8C41 = _0x955B(function() return _0xA548.VREnabled end, false)
    local _0x780D = false
    if _0x8C41 then _0x780D = false
    elseif _0xE130 then _0x780D = not _0xE7BF
    elseif _0xD871 and not _0xE7BF and not _0x4D37 then _0x780D = true end
    return {isMobile=_0x780D, isPC=(not _0x780D) and (not _0x8C41), isVR=_0x8C41, platform=_0xA21A, touch=_0xD871, keyboard=_0xE7BF, mouse=_0x4D37}
end

local _0x9A4D = _0x24C5()
local _0x7C2F = _0x9A4D.isMobile and 3.0 or 1.0

local _0x0E63 = false
pcall(function()
    if type(identifyexecutor) == "function" then
        local _0xB877 = tostring(identifyexecutor() or ""):lower()
        if _0xB877:find("xeno") or _0xB877:find("solara") or _0xB877:find("krnl")
            or _0xB877:find("fluxus") or _0xB877:find("hydrogen") or _0xB877:find("codex")
            or _0xB877:find("trigon") then
            _0x0E63 = true
        end
    end
end)
_G.__VEIL_IS_LOW_UNC = _0x0E63

local _0x2D8B = { Active = false, Mode = "none", HitCount = 0 }
local _0xBEA0 = nil
_G.__VEIL_SILENT_CFG = _G.__VEIL_SILENT_CFG or {}
_G.__VEIL_SILENT_CFG.MinMag = 20
_G.__VEIL_SILENT_CFG.MinDot = 0.5
_G.__VEIL_SILENT_CFG.MinToTarget = 0.3

if _G.__VEIL_SILENT_REF then
    _0x2D8B = _G.__VEIL_SILENT_REF
    _0x2D8B.Active = false
    _0x2D8B.HitCount = 0
    _0x2D8B.Mode = "installed"
else
    _G.__VEIL_SILENT_REF = _0x2D8B

    if _0x0E63 then
        _0x2D8B.Mode = "camera"
    else
        local _0x1C7C = nil
        local function _0xDAA6()
            local _0x241D = _G.__VEIL_CameraAssist
            local _0x3135 = _0x241D and _0x241D.Lock
            if not _0x3135 or not _0x3135.LastPos or not _0x3135.Character or not _0x3135.Character.Parent then return nil end
            return _0x3135
        end

        function _0x2D8B.InstallHook()
            if _0x1C7C then return end
            if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then
                _0x2D8B.Mode = "camera"
                return
            end
            local _0xDF7B = pcall(function()
                _0x1C7C = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                    if not _0x2D8B.Active then return _0x1C7C(self, ...) end
                    if self ~= workspace then return _0x1C7C(self, ...) end
                    if type(checkcaller) == "function" and checkcaller() then return _0x1C7C(self, ...) end
                    local _0xEC18 = getnamecallmethod()
                    if _0xEC18 ~= "Raycast" and _0xEC18 ~= "FindPartOnRay"
                        and _0xEC18 ~= "findPartOnRay"
                        and _0xEC18 ~= "FindPartOnRayWithIgnoreList"
                        and _0xEC18 ~= "FindPartOnRayWithWhitelist" then
                        return _0x1C7C(self, ...)
                    end
                    local _0x3135 = _0xDAA6()
                    if not _0x3135 then return _0x1C7C(self, ...) end
                    local _0x7458 = _0xBEA0
                    if not _0x7458 or not _0x7458.Parent then
                        _0x7458 = _0x3BA1.CurrentCamera
                        _0xBEA0 = _0x7458
                    end
                    if not _0x7458 then return _0x1C7C(self, ...) end
                    local _0x2E19 = _0x7458.CFrame.LookVector
                    local _0xF085 = _G.__VEIL_SILENT_CFG
                    if _0xEC18 == "Raycast" then
                        local _0x562F = select(1, ...)
                        local _0xB0D1 = select(2, ...)
                        if typeof(_0x562F) == "Vector3" and typeof(_0xB0D1) == "Vector3" then
                            local _0x5C6F = _0xB0D1.Magnitude
                            if _0x5C6F >= _0xF085.MinMag then
                                local _0x12DD = _0xB0D1 / _0x5C6F
                                if _0x2E19:Dot(_0x12DD) > _0xF085.MinDot then
                                    local _0x0DED = _0x3135.LastPos - _0x562F
                                    if _0x0DED.Magnitude > _0xF085.MinToTarget then
                                        _0x2D8B.HitCount = _0x2D8B.HitCount + 1
                                        return _0x1C7C(self, _0x562F, _0x0DED.Unit * _0x5C6F, select(3, ...))
                                    end
                                end
                            end
                        end
                    else
                        local _0x96B1 = select(1, ...)
                        if typeof(_0x96B1) == "Ray" then
                            local _0x5C6F = _0x96B1.Direction.Magnitude
                            if _0x5C6F >= _0xF085.MinMag then
                                local _0x12DD = _0x96B1.Direction / _0x5C6F
                                if _0x2E19:Dot(_0x12DD) > _0xF085.MinDot then
                                    local _0x0DED = _0x3135.LastPos - _0x96B1.Origin
                                    if _0x0DED.Magnitude > _0xF085.MinToTarget then
                                        _0x2D8B.HitCount = _0x2D8B.HitCount + 1
                                        return _0x1C7C(self, Ray.new(_0x96B1.Origin, _0x0DED.Unit * _0x5C6F), select(2, ...))
                                    end
                                end
                            end
                        end
                    end
                    return _0x1C7C(self, ...)
                end))
            end)
            _0x2D8B.Mode = (_0xDF7B and _0x1C7C) and "namecall" or "camera"
        end

        function _0x2D8B.UninstallHook()
            if not _0x1C7C then return end
            pcall(function() hookmetamethod(game, "__namecall", _0x1C7C) end)
            _0x1C7C = nil
            _0x2D8B.Mode = "idle"
        end

        _0x2D8B.Mode = "idle"
    end
end

local _0x1857 = nil
if not _0x0E63 then
    _0x1857 = _G.__VEIL_CamControls
    if not _0x1857 then
        pcall(function()
            local _0xE188 = _0xE1FF.LocalPlayer
            if not _0xE188 then return end
            local _0xA21A = _0xE188:FindFirstChild("PlayerScripts")
            if not _0xA21A then return end
            local _0xBC37 = _0xA21A:FindFirstChild("PlayerModule")
            if not _0xBC37 then return end
            local _0xD481 = require(_0xBC37)
            if _0xD481 and _0xD481.GetControls then
                _0x1857 = _0xD481:GetControls()
                _G.__VEIL_CamControls = _0x1857
            end
        end)
    end
end

local _0x6B84 = 0
local _0x6806 = 0.08

local _0x77AD = {
    ConfigVersion = 160,
    VisualsEnabled = true, ShowBoxes = true, ShowNames = true, ShowHealth = true,
    ShowDistance = true, ShowSkeleton = false, SkeletonColor = "Purple",
    BoxColor = "Purple", NameColor = "White",
    BoxColorMap = {
        Purple = Color3.fromRGB(139, 92, 246), Red = Color3.fromRGB(255, 60, 60),
        Blue = Color3.fromRGB(99, 102, 241), Green = Color3.fromRGB(60, 220, 90),
        Yellow = Color3.fromRGB(255, 220, 60), White = Color3.fromRGB(245, 243, 255),
        Black = Color3.fromRGB(25, 25, 30), Cyan = Color3.fromRGB(80, 220, 240),
        Orange = Color3.fromRGB(255, 140, 60), Pink = Color3.fromRGB(255, 100, 200),
        Lime = Color3.fromRGB(120, 255, 120), Teal = Color3.fromRGB(60, 200, 180),
    },
    VisualsRateHz = 60,
    CameraAssistEnabled = false, CameraAssistAlwaysOn = false,
    CameraAssistUseMouseWhileLocking = false, CameraAssistFOV = 35,
    CameraAssistDrawFOV = false, CameraAssistFOVColor = "White",
    CameraAssistSmoothing = 8, CameraAssistHitbox = "Head",
    CameraAssistHitboxMode = "Head", CameraAssistVisibleCheck = false,
    CameraAssistAcquisitionRadius = 300, CameraAssistPrediction = true,
    CameraAssistBulletSpeed = 400, CameraAssistLead = 0.06,
    CameraAssistScopeSpeed = 1.0, CameraAssistMouseSensitivity = 1.0,
    CameraAssistPlayerSens = 0.15, CameraAssistRotateChar = true,
    CameraAssistFOVPriority = true,
    ViewFOVEnabled = false, ViewFOV = 90,
    LobbyGuardEnabled = false, LobbyStateOverride = "Auto",
    WeaponAutoDetect = true, WeaponProfilesEnabled = true,
    ScaleWithViewport = true, TeamCheck = true,
    AutoFireEnabled = false, AutoFireDelay = 0.06,
    AutoFireMaxDistance = 1000, AutoFireProximityFallback = true,
    AutoFireProximityAngle = 2.5, AutoFireAlwaysOn = true,
    AutoFireBindType = "Mouse", AutoFireKeyCode = Enum.KeyCode.V,
    AutoFireMouseButton = Enum.UserInputType.MouseButton2,
    FlyEnabled = false, FlySpeed = 50,
    SpeedEnabled = false, SpeedValue = 60,
    NoclipEnabled = false,
    NightVisionEnabled = false,
    HitboxExpanderEnabled = false, HitboxExpanderSize = 1.5,
    NoRecoilEnabled = false,
    AntiFlashEnabled = true, FPSBoostEnabled = false,
    AutoStopOnKatanaDeflect = true,
    AimControllerButton = Enum.KeyCode.ButtonL2,
    AutoFireControllerButton = Enum.KeyCode.ButtonR2,
    WatermarkEnabled = true,
    MenuBindType = "Key", MenuKey = Enum.KeyCode.RightShift,
    MenuMouseButton = Enum.UserInputType.MouseButton3,
    AimBindType = "Mouse", AimMouseButton = Enum.UserInputType.MouseButton2,
    AimKeyCode = Enum.KeyCode.LeftShift,
    PlayerListUpdateInterval = 0.5, MaxRenderDistance = 1000,
    SilentAimEnabled = false, SilentAimHitChance = 100,
    SilentAimFOV = 200, SilentAimHitbox = "Head",
    SilentAimDrawFOV = false, SilentAimFOVColor = "Cyan",
    SilentAimDistanceBoost = 1.0,
    SilentAimConvergenceSnap = true,
    SilentAimTightDeadzone = true,
    AimLockEnabled = false, RagebotEnabled = false,
    RapidFireEnabled = false, MaxAccuracyEnabled = false,
    NoSpreadEnabled = false, SpinbotEnabled = false,
    ESPTargetVisEnabled = false, ViewmodelChamsEnabled = false,
    SkyChangerEnabled = false, FlyNoclipEnabled = false, InfJumpEnabled = false,
    HitSoundsEnabled = false, HitSoundChoice = "Vine Boom",
    HitSoundMap = {
        ["Vine Boom"] = "rbxassetid://6308606116",
        ["Mega Knight"] = "rbxassetid://1310127925561718",
        ["MLG Airhorn"] = "rbxassetid://678089961",
        ["Boom Headshot"] = "rbxassetid://7361085557",
        ["Taco Bell"] = "rbxassetid://5556082054",
    },
    CustomCrosshairEnabled = false,
    IsPremium = false, PremiumTier = nil, PremiumExpiry = 0, PremiumKey = nil,
}

local _0x76B0 = {
    Name = "Unknown",
    HasGethui = type(gethui) == "function",
    HasWritefile = type(writefile) == "function",
    HasReadfile = type(readfile) == "function",
    HasMakeFolder = type(makefolder) == "function",
    HasMouse1Click = type(mouse1click) == "function",
    HasMouse1Press = type(mouse1press) == "function" and type(mouse1release) == "function",
    HasKeyPress = type(keypress) == "function" and type(keyrelease) == "function",
    HasVIM = pcall(function() return game:GetService("VirtualInputManager") end),
}
pcall(function()
    if type(identifyexecutor) == "function" then
        local _0xB877 = identifyexecutor()
        if _0xB877 and _0xB877 ~= "" then _0x76B0.Name = tostring(_0xB877) end
    end
end)

local function _0xB27C()
    if type(gethui) == "function" then
        local _0xDF7B, _0x830D = pcall(gethui)
        if _0xDF7B and _0x830D then return _0x830D end
    end
    local _0x1A90 = _0xE1FF.LocalPlayer
    if _0x1A90 then
        local _0xEC82 = _0x1A90:FindFirstChildOfClass("PlayerGui")
        if _0xEC82 then return _0xEC82 end
    end
    local _0xDF7B, _0x481A = pcall(function() return game:GetService("CoreGui") end)
    if _0xDF7B and _0x481A then return _0x481A end
end

local function _0x9261(text, font, size, wrapWidth)
    local _0x41E5 = game:GetService("TextService")
    local _0xDF7B, _0x0622 = pcall(function()
        return _0x41E5:GetTextSize(tostring(text or ""), size, font, Vector2.new(wrapWidth, 10000))
    end)
    if _0xDF7B and _0x0622 then return _0x0622.Y end
    local _0x1844 = math.ceil(#tostring(text or "") / math.max(1, wrapWidth / (size * 0.55)))
    return math.max(size + 4, _0x1844 * (size + 4))
end

local _0xC488 = {}
_0xC488.Active = nil
function _0xC488.Show(text, _0xDF7B)
    local _0x14E4 = _0xB27C()
    if not _0x14E4 then return end
    if _0xC488.Active and _0xC488.Active.Parent then pcall(function() _0xC488.Active:Destroy() end) end
    local _0xFA03 = Instance.new("ScreenGui")
    _0xFA03.Name = "VEIL_Popup" _0xFA03.ResetOnSpawn = false _0xFA03.IgnoreGuiInset = true _0xFA03.DisplayOrder = 500
    _0xFA03.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() _0xFA03.Parent = _0x14E4 end)
    _0xC488.Active = _0xFA03
    local _0xBEA4 = _0xDF7B and Color3.fromRGB(80, 220, 130) or Color3.fromRGB(255, 80, 100)
    local _0xBAB4 = 20
    local _0x4928 = 16
    local _0x6B8E = 30
    local _0xF361 = 12
    local _0xB597 = 400
    local _0xDD0D = 220
    local _0x5DC7 = _0xB597 - (_0xBAB4 * 2) - _0x6B8E - _0xF361
    local _0x830D = _0x9261(text, Enum.Font.GothamBold, 13, _0x5DC7)
    local _0x93F0 = _0xB597
    if #tostring(text or "") < 48 then
        local _0x41E5 = game:GetService("TextService")
        local _0x89D2, _0x4D37 = pcall(function() return _0x41E5:GetTextSize(tostring(text), 13, Enum.Font.GothamBold, Vector2.new(10000, 10000)) end)
        if _0x89D2 and _0x4D37 then
            _0x93F0 = math.clamp(_0x4D37.X + (_0xBAB4 * 2) + _0x6B8E + _0xF361, _0xDD0D, _0xB597)
            _0x830D = _0x4D37.Y
        end
    end
    local _0x9781 = math.max(_0x830D + (_0x4928 * 2), _0x6B8E + (_0x4928 * 2))
    local _0x41F6 = Instance.new("Frame")
    _0x41F6.AnchorPoint = Vector2.new(0.5, 0) _0x41F6.Position = UDim2.new(0.5, 0, 0, -80)
    _0x41F6.Size = UDim2.fromOffset(_0x93F0, _0x9781) _0x41F6.BackgroundColor3 = Color3.fromRGB(14, 12, 22)
    _0x41F6.BackgroundTransparency = 0.03 _0x41F6.BorderSizePixel = 0 _0x41F6.Parent = _0xFA03
    local _0x3A4B = Instance.new("UICorner") _0x3A4B.CornerRadius = UDim.new(0, 12) _0x3A4B.Parent = _0x41F6
    local _0x48A3 = Instance.new("UIStroke") _0x48A3.Color = _0xBEA4 _0x48A3.Thickness = 1.5 _0x48A3.Transparency = 0.15 _0x48A3.Parent = _0x41F6
    local _0x257D = Instance.new("Frame")
    _0x257D.Size = UDim2.new(0, 4, 1, -20) _0x257D.Position = UDim2.new(0, 6, 0, 10)
    _0x257D.BackgroundColor3 = _0xBEA4 _0x257D.BorderSizePixel = 0 _0x257D.Parent = _0x41F6
    local _0x9649 = Instance.new("UICorner") _0x9649.CornerRadius = UDim.new(0, 2) _0x9649.Parent = _0x257D
    local _0x9A2F = Instance.new("TextLabel")
    _0x9A2F.Size = UDim2.fromOffset(_0x6B8E, _0x6B8E) _0x9A2F.Position = UDim2.new(0, _0xBAB4, 0.5, -_0x6B8E * 0.5)
    _0x9A2F.BackgroundColor3 = _0xBEA4 _0x9A2F.BackgroundTransparency = 0.82
    _0x9A2F.BorderSizePixel = 0 _0x9A2F.Font = Enum.Font.GothamBlack _0x9A2F.TextSize = 18
    _0x9A2F.TextColor3 = _0xBEA4 _0x9A2F.Text = _0xDF7B and "\226\156\147" or "\226\156\149" _0x9A2F.Parent = _0x41F6
    local _0x35E6 = Instance.new("UICorner") _0x35E6.CornerRadius = UDim.new(1, 0) _0x35E6.Parent = _0x9A2F
    local _0x57CD = Instance.new("TextLabel")
    _0x57CD.Position = UDim2.new(0, _0xBAB4 + _0x6B8E + _0xF361, 0, _0x4928)
    _0x57CD.Size = UDim2.new(1, -(_0xBAB4 * 2 + _0x6B8E + _0xF361), 0, _0x830D)
    _0x57CD.BackgroundTransparency = 1 _0x57CD.Font = Enum.Font.GothamBold _0x57CD.TextSize = 13
    _0x57CD.TextColor3 = _0xBEA4 _0x57CD.TextXAlignment = Enum.TextXAlignment.Left
    _0x57CD.TextYAlignment = Enum.TextYAlignment.Top _0x57CD.TextWrapped = true _0x57CD.Text = tostring(text or "")
    _0x57CD.Parent = _0x41F6
    _0x27A5:Create(_0x41F6, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 24)}):Play()
    task.delay(_0xDF7B and 2.4 or 3.0, function()
        _0x27A5:Create(_0x41F6, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, -80)}):Play()
        _0x27A5:Create(_0x57CD, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        _0x27A5:Create(_0x9A2F, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        _0x27A5:Create(_0x48A3, TweenInfo.new(0.3), {Transparency = 1}):Play()
        _0x27A5:Create(_0x257D, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.delay(0.5, function() pcall(function() _0xFA03:Destroy() end) end)
    end)
end

local _0xB7CC = {}
_0xB7CC.Authorized = false
_0xB7CC.KeyLink = "https://work.ink/2YDv/key-system"
_0xB7CC.DefaultExpiry = 24 * 60 * 60
_0xB7CC.PremiumTiers = {
    ["week"]     = { _0x4BFF = "1 Week",   seconds = 7 * 24 * 60 * 60 },
    ["month"]    = { _0x4BFF = "1 Month",  seconds = 30 * 24 * 60 * 60 },
    ["3month"]   = { _0x4BFF = "3 Months", seconds = 90 * 24 * 60 * 60 },
    ["lifetime"] = { _0x4BFF = "Lifetime", seconds = 100 * 365 * 24 * 60 * 60 },
}
_0xB7CC.PremiumWhitelist = {
    ["VL-7DK92XMF"] = "week",
    ["VL-7PN41QRT"] = "week",
    ["VL-7BW83JYC"] = "week",
    ["VL-7HG65ZLA"] = "week",
    ["VL-M4X72QPN"] = "month",
    ["VL-M9T16BKW"] = "month",
    ["VL-M3Y58ZDF"] = "month",
    ["VL-M7L24CHV"] = "month",
    ["VL-Q8N63XTR"] = "3month",
    ["VL-Q2P17KMW"] = "3month",
    ["VL-Q5Z49BHL"] = "3month",
    ["VL-L9T82XKN"] = "lifetime",
    ["VL-L4M16JRD"] = "lifetime",
}

function _0xB7CC.DetectTier(_0x6260)
    if not _0x6260 or _0x6260 == "" then return nil end
    local _0x7345 = _0x6260:upper():gsub("^%s+", ""):gsub("%s+$", "")
    local _0xB494 = _0xB7CC.PremiumWhitelist[_0x7345]
    if _0xB494 then return _0xB494, _0xB7CC.PremiumTiers[_0xB494] end
    return nil
end
local function _0xA3BD(url)
    if type(request) == "function" then
        local _0xDF7B, _0xBE70 = pcall(request, { Url = url, Method = "GET" })
        if _0xDF7B and _0xBE70 then return _0xBE70 end
    end
    if type(http_request) == "function" then
        local _0xDF7B, _0xBE70 = pcall(http_request, { Url = url, Method = "GET" })
        if _0xDF7B and _0xBE70 then return _0xBE70 end
    end
    if type(syn) == "table" and type(syn.request) == "function" then
        local _0xDF7B, _0xBE70 = pcall(syn.request, { Url = url, Method = "GET" })
        if _0xDF7B and _0xBE70 then return _0xBE70 end
    end
    return nil
end
function _0xB7CC.Validate(_0x6260)
    _0x6260 = tostring(_0x6260 or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if #_0x6260 < 6 then return false, "too-short" end
    local _0xB494, _0x05AC = _0xB7CC.DetectTier(_0x6260)
    if _0xB494 then
        getgenv().SCRIPT_KEY = _0x6260
        _0x77AD.IsPremium = true
        _0x77AD.PremiumTier = _0x05AC.name
        _0x77AD.PremiumExpiry = os.time() + _0x05AC.seconds
        _0x77AD.PremiumKey = _0x6260
        return true, "premium:" .. _0x05AC.name
    end
    local _0xBE70 = _0xA3BD("https://work.ink/_api/v2/token/isValid/" .. _0x6260)
    if not _0xBE70 then return false, "http-unavailable" end
    local _0x2413 = _0xBE70.Body or _0xBE70.body or ""
    if _0x2413 == "" then return false, "empty-response" end
    local _0xD2FF
    local _0xDF7B = pcall(function() _0xD2FF = _0xFC99:JSONDecode(_0x2413) end)
    if not _0xDF7B or type(_0xD2FF) ~= "table" then return false, "bad-response" end
    if _0xD2FF.valid == true then
        getgenv().SCRIPT_KEY = _0x6260
        _0x77AD.IsPremium = false
        return true, "valid"
    end
    return false, tostring(_0xD2FF.error or "invalid")
end
function _0xB7CC.ReadSaved()
    if not _0x76B0.HasReadfile then return nil, nil end
    for _, _0x938C in ipairs({"VEIL/Key.txt", "VEIL_Key.txt"}) do
        local _0xDF7B, _0x3748 = pcall(readfile, _0x938C)
        if _0xDF7B and _0x3748 and _0x3748 ~= "" then
            local _0x6260, _0x41E5 = _0x3748:match("^([^|]+)|(%d+)$")
            if _0x6260 and _0x41E5 then return _0x6260, tonumber(_0x41E5) end
        end
    end
    return nil, nil
end
function _0xB7CC.WriteSaved(_0x6260, _0x0C4D)
    if not _0x76B0.HasWritefile then return false end
    if _0x76B0.HasMakeFolder then pcall(makefolder, "VEIL") end
    local _0x7B6E = tostring(_0x6260) .. "|" .. tostring(_0x0C4D)
    for _, _0x938C in ipairs({"VEIL/Key.txt", "VEIL_Key.txt"}) do
        if pcall(writefile, _0x938C, _0x7B6E) then return true end
    end
    return false
end
function _0xB7CC.ClearSaved()
    if not _0x76B0.HasWritefile then return end
    for _, _0x938C in ipairs({"VEIL/Key.txt", "VEIL_Key.txt"}) do pcall(writefile, _0x938C, "") end
end

local function _0x6ABC(onAuthorized)
    local _0x14E4 = _0xB27C()
    if not _0x14E4 then return nil end
    local _0xFA03 = Instance.new("ScreenGui")
    _0xFA03.Name = "VEIL_KeyUI" _0xFA03.ResetOnSpawn = false _0xFA03.IgnoreGuiInset = true _0xFA03.DisplayOrder = 400
    _0xFA03.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() _0xFA03.Parent = _0x14E4 end)
    _0xB7CC.ScreenGui = _0xFA03

    local _0xBD2F = "https://discord.gg/K3vgcVsCsS"
    local _0xEDA7, _0x85B7 = 1920, 1080

    local _0x2B1D = Instance.new("Frame")
    _0x2B1D.Size = UDim2.fromScale(1, 1) _0x2B1D.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    _0x2B1D.BackgroundTransparency = 0.35 _0x2B1D.BorderSizePixel = 0 _0x2B1D.ZIndex = 1 _0x2B1D.Parent = _0xFA03

    local _0x5D3B = Instance.new("Frame")
    _0x5D3B.Size = UDim2.fromScale(1, 1)
    _0x5D3B.BackgroundTransparency = 1
    _0x5D3B.BorderSizePixel = 0
    _0x5D3B.ClipsDescendants = true
    _0x5D3B.ZIndex = 2
    _0x5D3B.Parent = _0xFA03

    local _0x74E0 = Instance.new("Frame")
    _0x74E0.Size = UDim2.fromScale(1, 1)
    _0x74E0.BackgroundTransparency = 1
    _0x74E0.BorderSizePixel = 0
    _0x74E0.ClipsDescendants = true
    _0x74E0.ZIndex = 4
    _0x74E0.Parent = _0xFA03

    local _0x0ABE = true

    local function _0x9040()
        if not _0x0ABE or not _0x5D3B.Parent then return end
        local _0x4FF3 = 2 + math.random() * 3
        local _0x4D37 = Instance.new("Frame")
        _0x4D37.AnchorPoint = Vector2.new(0.5, 0.5)
        _0x4D37.Size = UDim2.fromOffset(_0x4FF3, _0x4FF3)
        _0x4D37.BackgroundColor3 = Color3.fromRGB(190, 165, 255)
        _0x4D37.BackgroundTransparency = 1
        _0x4D37.BorderSizePixel = 0
        _0x4D37.Position = UDim2.fromScale(math.random(), 1.05)
        _0x4D37.ZIndex = 2
        _0x4D37.Parent = _0x5D3B
        local _0x7B5B = Instance.new("UICorner")
        _0x7B5B.CornerRadius = UDim.new(1, 0)
        _0x7B5B.Parent = _0x4D37
        local _0x958C = (math.random() - 0.5) * 0.25
        local _0x2912 = math.clamp(_0x4D37.Position.X.Scale + _0x958C, 0.02, 0.98)
        local _0xE103 = 4 + math.random() * 3
        _0x27A5:Create(_0x4D37, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.35,
        }):Play()
        _0x27A5:Create(_0x4D37, TweenInfo.new(_0xE103, Enum.EasingStyle.Linear), {
            Position = UDim2.fromScale(_0x2912, -0.08),
        }):Play()
        task.delay(_0xE103 - 1.0, function()
            if _0x4D37.Parent then
                _0x27A5:Create(_0x4D37, TweenInfo.new(1.0), {BackgroundTransparency = 1}):Play()
            end
        end)
        task.delay(_0xE103 + 0.2, function() if _0x4D37.Parent then _0x4D37:Destroy() end end)
    end

    local function _0x5AD1()
        if not _0x0ABE or not _0x74E0.Parent then return end
        local _0x641F = math.random(10, 90) / 100
        local _0x4246 = -0.05 + math.random() * 0.15
        local _0x70C1 = 0.55 + math.random() * 0.5
        local _0x1B35 = 4 + math.random(0, 2)
        local _0x4AB3 = { Vector2.new(_0x641F, _0x4246) }
        local _0xEA95, _0x92DE = _0x641F, _0x4246
        local _0x31B8 = (math.random() - 0.5) * 0.1
        local _0x4FC8 = _0x70C1 - _0x4246
        for _0x9236 = 1, _0x1B35 do
            _0x92DE = _0x92DE + _0x4FC8 / _0x1B35 + (math.random() - 0.5) * 0.03
            _0xEA95 = _0xEA95 + _0x31B8 + (math.random() - 0.5) * 0.13
            _0xEA95 = math.clamp(_0xEA95, 0.02, 0.98)
            table.insert(_0x4AB3, Vector2.new(_0xEA95, _0x92DE))
        end
        local _0x74DC = Instance.new("Frame")
        _0x74DC.Size = UDim2.fromScale(1, 1)
        _0x74DC.BackgroundTransparency = 1
        _0x74DC.BorderSizePixel = 0
        _0x74DC.ZIndex = 4
        _0x74DC.Parent = _0x74E0
        local _0x1B47, _0x7647 = _0x4AB3[1], _0x4AB3[#_0x4AB3]
        local _0xFA2B = (_0x7647.X - _0x1B47.X) * _0xEDA7
        local _0xD39F = (_0x7647.Y - _0x1B47.Y) * _0x85B7
        local _0xCB9B = math.sqrt(_0xFA2B * _0xFA2B + _0xD39F * _0xD39F)
        local _0x3283 = math.deg(math.atan2(_0xD39F, _0xFA2B))
        local _0xF77B = (_0x1B47.X + _0x7647.X) * 0.5
        local _0x8787 = (_0x1B47.Y + _0x7647.Y) * 0.5
        local _0x11B2 = Instance.new("Frame")
        _0x11B2.AnchorPoint = Vector2.new(0.5, 0.5)
        _0x11B2.Position = UDim2.fromScale(_0xF77B, _0x8787)
        _0x11B2.Size = UDim2.new(0, _0xCB9B, 0, 12)
        _0x11B2.Rotation = _0x3283
        _0x11B2.BackgroundColor3 = Color3.fromRGB(160, 140, 240)
        _0x11B2.BackgroundTransparency = 0.72
        _0x11B2.BorderSizePixel = 0
        _0x11B2.ZIndex = 4
        _0x11B2.Parent = _0x74DC
        local _0x5050 = Instance.new("UICorner")
        _0x5050.CornerRadius = UDim.new(1, 0)
        _0x5050.Parent = _0x11B2
        local _0x8D3A = {}
        for _0x9236 = 1, #_0x4AB3 - 1 do
            local _0xA375, _0x3590 = _0x4AB3[_0x9236], _0x4AB3[_0x9236 + 1]
            local _0x2912 = (_0x3590.X - _0xA375.X) * _0xEDA7
            local _0x4CC4 = (_0x3590.Y - _0xA375.Y) * _0x85B7
            local _0x4845 = math.sqrt(_0x2912 * _0x2912 + _0x4CC4 * _0x4CC4)
            local _0x9755 = math.deg(math.atan2(_0x4CC4, _0x2912))
            local _0x5B90 = (_0xA375.X + _0x3590.X) * 0.5
            local _0xD238 = (_0xA375.Y + _0x3590.Y) * 0.5
            local _0x3D75 = Instance.new("Frame")
            _0x3D75.AnchorPoint = Vector2.new(0.5, 0.5)
            _0x3D75.Position = UDim2.fromScale(_0x5B90, _0xD238)
            _0x3D75.Size = UDim2.new(0, _0x4845, 0, 3)
            _0x3D75.Rotation = _0x9755
            _0x3D75.BackgroundColor3 = Color3.fromRGB(240, 235, 255)
            _0x3D75.BorderSizePixel = 0
            _0x3D75.BackgroundTransparency = 0.06
            _0x3D75.ZIndex = 5
            _0x3D75.Parent = _0x74DC
            local _0x9649 = Instance.new("UICorner")
            _0x9649.CornerRadius = UDim.new(1, 0)
            _0x9649.Parent = _0x3D75
            table.insert(_0x8D3A, _0x3D75)
        end
        if math.random() < 0.55 and #_0x4AB3 >= 3 then
            local _0x70B7 = _0x4AB3[math.random(2, #_0x4AB3 - 1)]
            local _0xC525 = (math.random() - 0.5) * 0.18
            local _0x57E9 = 0.08 + math.random() * 0.16
            local _0x34BB = math.clamp(_0x70B7.X + _0xC525, 0.02, 0.98)
            local _0x8CE9 = _0x70B7.Y + _0x57E9
            local _0x2912 = (_0x34BB - _0x70B7.X) * _0xEDA7
            local _0x4CC4 = (_0x8CE9 - _0x70B7.Y) * _0x85B7
            local _0x4845 = math.sqrt(_0x2912 * _0x2912 + _0x4CC4 * _0x4CC4)
            local _0x9755 = math.deg(math.atan2(_0x4CC4, _0x2912))
            local _0xB4B6 = Instance.new("Frame")
            _0xB4B6.AnchorPoint = Vector2.new(0.5, 0.5)
            _0xB4B6.Position = UDim2.fromScale((_0x70B7.X + _0x34BB) * 0.5, (_0x70B7.Y + _0x8CE9) * 0.5)
            _0xB4B6.Size = UDim2.new(0, _0x4845, 0, 2)
            _0xB4B6.Rotation = _0x9755
            _0xB4B6.BackgroundColor3 = Color3.fromRGB(220, 210, 255)
            _0xB4B6.BorderSizePixel = 0
            _0xB4B6.BackgroundTransparency = 0.14
            _0xB4B6.ZIndex = 5
            _0xB4B6.Parent = _0x74DC
            local _0x3EC9 = Instance.new("UICorner")
            _0x3EC9.CornerRadius = UDim.new(1, 0)
            _0x3EC9.Parent = _0xB4B6
            table.insert(_0x8D3A, _0xB4B6)
        end
        local _0xBBBD = 0.05 + math.random() * 0.07
        task.delay(_0xBBBD, function()
            local _0x9C14 = TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            for _, _0x3D75 in ipairs(_0x8D3A) do
                if _0x3D75.Parent then
                    _0x27A5:Create(_0x3D75, _0x9C14, {BackgroundTransparency = 1}):Play()
                end
            end
            if _0x11B2.Parent then
                _0x27A5:Create(_0x11B2, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
            end
            task.delay(0.4, function()
                if _0x74DC.Parent then _0x74DC:Destroy() end
            end)
        end)
    end

    task.spawn(function()
        while _0x0ABE and _0x5D3B.Parent do
            _0x9040()
            task.wait(0.28 + math.random() * 0.22)
        end
    end)

    task.spawn(function()
        task.wait(0.6 + math.random() * 0.8)
        while _0x0ABE and _0x74E0.Parent do
            _0x5AD1()
            if math.random() < 0.15 then
                task.wait(0.08 + math.random() * 0.1)
                _0x5AD1()
            end
            task.wait(2.4 + math.random() * 2.2)
        end
    end)

    local _0xA05F = Instance.new("Frame")
    _0xA05F.AnchorPoint = Vector2.new(0.5, 0.5) _0xA05F.Position = UDim2.fromScale(0.5, 0.5)
    _0xA05F.Size = UDim2.fromOffset(360, 400)
    _0xA05F.BackgroundColor3 = Color3.fromRGB(15, 12, 24)
    _0xA05F.BackgroundTransparency = 0.05
    _0xA05F.BorderSizePixel = 0
    _0xA05F.ZIndex = 10
    _0xA05F.Parent = _0xFA03
    local _0x50EE = Instance.new("UICorner") _0x50EE.CornerRadius = UDim.new(0, 16) _0x50EE.Parent = _0xA05F
    local _0xA21A = Instance.new("UIStroke")
    _0xA21A.Color = Color3.fromRGB(120, 100, 220) _0xA21A.Thickness = 1.5 _0xA21A.Transparency = 0.15 _0xA21A.Parent = _0xA05F
    local _0x006E = Instance.new("UIStroke")
    _0x006E.Color = Color3.fromRGB(180, 160, 255)
    _0x006E.Thickness = 3
    _0x006E.Transparency = 1
    _0x006E.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    _0x006E.Parent = _0xA05F
    task.spawn(function()
        while _0xA05F.Parent do
            task.wait(2.2 + math.random() * 2.4)
            if _0xA05F.Parent then
                _0x27A5:Create(_0x006E, TweenInfo.new(0.1), {Transparency = 0.45}):Play()
                task.wait(0.18)
                _0x27A5:Create(_0x006E, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1}):Play()
            end
        end
    end)

    local _0x6A3E = Instance.new("TextButton")
    _0x6A3E.Size = UDim2.fromOffset(28, 28)
    _0x6A3E.Position = UDim2.new(1, -38, 0, 10)
    _0x6A3E.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
    _0x6A3E.BorderSizePixel = 0
    _0x6A3E.Font = Enum.Font.GothamBold
    _0x6A3E.TextSize = 16
    _0x6A3E.TextColor3 = Color3.fromRGB(220, 210, 255)
    _0x6A3E.Text = "x"
    _0x6A3E.AutoButtonColor = false
    _0x6A3E.ZIndex = 12
    _0x6A3E.Parent = _0xA05F
    local _0x6B88 = Instance.new("UICorner") _0x6B88.CornerRadius = UDim.new(0, 8) _0x6B88.Parent = _0x6A3E
    local _0x67B0 = Instance.new("UIStroke") _0x67B0.Color = Color3.fromRGB(80, 70, 120) _0x67B0.Thickness = 1 _0x67B0.Parent = _0x6A3E
    _0x6A3E.MouseEnter:Connect(function()
        _0x27A5:Create(_0x6A3E, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(90, 40, 50)}):Play()
        _0x27A5:Create(_0x6A3E, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 180, 180)}):Play()
    end)
    _0x6A3E.MouseLeave:Connect(function()
        _0x27A5:Create(_0x6A3E, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 30, 60)}):Play()
        _0x27A5:Create(_0x6A3E, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(220, 210, 255)}):Play()
    end)
    _0x6A3E.MouseButton1Click:Connect(function()
        _0x0ABE = false
        pcall(function() _0xFA03:Destroy() end)
    end)

    local _0x7284 = Instance.new("TextLabel")
    _0x7284.Size = UDim2.new(1, 0, 0, 52) _0x7284.Position = UDim2.new(0, 0, 0, 22)
    _0x7284.BackgroundTransparency = 1 _0x7284.Font = Enum.Font.GothamBlack _0x7284.Text = "VEIL"
    _0x7284.TextSize = 44 _0x7284.TextColor3 = Color3.fromRGB(255, 255, 255)
    _0x7284.TextStrokeTransparency = 0.6 _0x7284.TextStrokeColor3 = Color3.fromRGB(80, 60, 160)
    _0x7284.ZIndex = 11 _0x7284.Parent = _0xA05F
    local _0x1AEB = Instance.new("UIGradient")
    _0x1AEB.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 200, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 130, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 160, 255)),
    }
    _0x1AEB.Parent = _0x7284

    local _0xFC58 = Instance.new("TextLabel")
    _0xFC58.Size = UDim2.new(1, 0, 0, 16) _0xFC58.Position = UDim2.new(0, 0, 0, 78)
    _0xFC58.BackgroundTransparency = 1 _0xFC58.Font = Enum.Font.GothamBold
    _0xFC58.Text = "S E C U R I T Y   S U I T E" _0xFC58.TextSize = 9
    _0xFC58.TextColor3 = Color3.fromRGB(167, 139, 250) _0xFC58.ZIndex = 11 _0xFC58.Parent = _0xA05F

    local _0x455A = Instance.new("Frame")
    _0x455A.Size = UDim2.new(1, -60, 0, 46) _0x455A.Position = UDim2.new(0, 30, 0, 132)
    _0x455A.BackgroundColor3 = Color3.fromRGB(22, 18, 34) _0x455A.BorderSizePixel = 0
    _0x455A.ZIndex = 11 _0x455A.Parent = _0xA05F
    local _0x3EC9 = Instance.new("UICorner") _0x3EC9.CornerRadius = UDim.new(0, 10) _0x3EC9.Parent = _0x455A
    local _0xEDF3 = Instance.new("UIStroke") _0xEDF3.Color = Color3.fromRGB(60, 50, 100) _0xEDF3.Thickness = 1.5 _0xEDF3.Parent = _0x455A
    local _0xAE2A = Instance.new("TextBox")
    _0xAE2A.Size = UDim2.new(1, -24, 1, 0) _0xAE2A.Position = UDim2.new(0, 12, 0, 0)
    _0xAE2A.BackgroundTransparency = 1 _0xAE2A.Font = Enum.Font.GothamMedium
    _0xAE2A.TextSize = 14 _0xAE2A.TextColor3 = Color3.fromRGB(245, 243, 255)
    _0xAE2A.PlaceholderText = "VL-XXXXXXXX or work.ink key"
    _0xAE2A.PlaceholderColor3 = Color3.fromRGB(110, 110, 130) _0xAE2A.Text = ""
    _0xAE2A.ClearTextOnFocus = false _0xAE2A.TextXAlignment = Enum.TextXAlignment.Left
    _0xAE2A.ZIndex = 12 _0xAE2A.Parent = _0x455A
    _0xAE2A.Focused:Connect(function()
        _0x27A5:Create(_0xEDF3, TweenInfo.new(0.2), {Color = Color3.fromRGB(139, 92, 246), Transparency = 0}):Play()
    end)
    _0xAE2A.FocusLost:Connect(function()
        _0x27A5:Create(_0xEDF3, TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 50, 100), Transparency = 0}):Play()
    end)

    local _0x78ED = Instance.new("TextButton")
    _0x78ED.Size = UDim2.new(1, -60, 0, 44) _0x78ED.Position = UDim2.new(0, 30, 0, 190)
    _0x78ED.BackgroundColor3 = Color3.fromRGB(139, 92, 246) _0x78ED.BorderSizePixel = 0
    _0x78ED.Font = Enum.Font.GothamBold _0x78ED.Text = "Validate Key" _0x78ED.TextSize = 14
    _0x78ED.TextColor3 = Color3.fromRGB(255, 255, 255) _0x78ED.AutoButtonColor = false
    _0x78ED.ZIndex = 11 _0x78ED.Parent = _0xA05F
    local _0x3A50 = Instance.new("UICorner") _0x3A50.CornerRadius = UDim.new(0, 10) _0x3A50.Parent = _0x78ED
    _0x78ED.MouseEnter:Connect(function()
        _0x27A5:Create(_0x78ED, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(167, 139, 250)}):Play()
    end)
    _0x78ED.MouseLeave:Connect(function()
        _0x27A5:Create(_0x78ED, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(139, 92, 246)}):Play()
    end)

    local _0xF15B = Instance.new("TextButton")
    _0xF15B.Size = UDim2.new(1, -60, 0, 30) _0xF15B.Position = UDim2.new(0, 30, 0, 246)
    _0xF15B.BackgroundColor3 = Color3.fromRGB(22, 18, 34) _0xF15B.BorderSizePixel = 0
    _0xF15B.Font = Enum.Font.GothamBold _0xF15B.Text = "Get a Key  \226\134\146" _0xF15B.TextSize = 11
    _0xF15B.TextColor3 = Color3.fromRGB(167, 139, 250) _0xF15B.AutoButtonColor = false
    _0xF15B.ZIndex = 11 _0xF15B.Parent = _0xA05F
    local _0x73B4 = Instance.new("UICorner") _0x73B4.CornerRadius = UDim.new(0, 8) _0x73B4.Parent = _0xF15B
    local _0x0EFF = Instance.new("UIStroke") _0x0EFF.Color = Color3.fromRGB(60, 50, 100) _0x0EFF.Thickness = 1 _0x0EFF.Transparency = 0.4 _0x0EFF.Parent = _0xF15B
    _0xF15B.MouseButton1Click:Connect(function()
        if type(setclipboard) == "function" then
            pcall(setclipboard, _0xB7CC.KeyLink)
            _0xF15B.Text = "Link copied!"
            task.delay(1.5, function() if _0xF15B.Parent then _0xF15B.Text = "Get a Key  \226\134\146" end end)
        else
            _0xF15B.Text = _0xB7CC.KeyLink
        end
    end)

    local _0x55B7 = Instance.new("TextButton")
    _0x55B7.Size = UDim2.new(1, -60, 0, 32) _0x55B7.Position = UDim2.new(0, 30, 0, 286)
    _0x55B7.BackgroundColor3 = Color3.fromRGB(88, 101, 242) _0x55B7.BorderSizePixel = 0
    _0x55B7.Font = Enum.Font.GothamBold
    _0x55B7.Text = "Need Help? Join the Discord"
    _0x55B7.TextSize = 11
    _0x55B7.TextColor3 = Color3.fromRGB(255, 255, 255)
    _0x55B7.AutoButtonColor = false
    _0x55B7.ZIndex = 11 _0x55B7.Parent = _0xA05F
    local _0xA771 = Instance.new("UICorner") _0xA771.CornerRadius = UDim.new(0, 8) _0xA771.Parent = _0x55B7
    local _0x5F2D = Instance.new("UIStroke")
    _0x5F2D.Color = Color3.fromRGB(120, 135, 255) _0x5F2D.Thickness = 1 _0x5F2D.Transparency = 0.25 _0x5F2D.Parent = _0x55B7
    _0x55B7.MouseEnter:Connect(function()
        _0x27A5:Create(_0x55B7, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(110, 122, 255)}):Play()
    end)
    _0x55B7.MouseLeave:Connect(function()
        _0x27A5:Create(_0x55B7, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
    end)
    _0x55B7.MouseButton1Click:Connect(function()
        if type(setclipboard) == "function" then
            pcall(setclipboard, _0xBD2F)
            _0x55B7.Text = "\226\156\147 Discord invite copied"
            _0x55B7.BackgroundColor3 = Color3.fromRGB(80, 220, 130)
            task.delay(1.8, function()
                if _0x55B7.Parent then
                    _0x55B7.Text = "Need Help? Join the Discord"
                    _0x55B7.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
                end
            end)
        else
            _0x55B7.Text = _0xBD2F
            task.delay(2.2, function()
                if _0x55B7.Parent then _0x55B7.Text = "Need Help? Join the Discord" end
            end)
        end
    end)

    local _0xE8F7 = Instance.new("TextLabel")
    _0xE8F7.Size = UDim2.new(1, -60, 0, 16) _0xE8F7.Position = UDim2.new(0, 30, 0, 328)
    _0xE8F7.BackgroundTransparency = 1 _0xE8F7.Font = Enum.Font.Gotham
    _0xE8F7.Text = "" _0xE8F7.TextSize = 10 _0xE8F7.TextColor3 = Color3.fromRGB(161, 161, 170)
    _0xE8F7.ZIndex = 11 _0xE8F7.Parent = _0xA05F

    local _0x1AA5 = Instance.new("UIScale")
    _0x1AA5.Scale = 0.85 _0x1AA5.Parent = _0xA05F
    _0xA05F.BackgroundTransparency = 1
    _0x27A5:Create(_0x1AA5, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    _0x27A5:Create(_0xA05F, TweenInfo.new(0.4), {BackgroundTransparency = 0.05}):Play()

    local _0x61FD = false
    local function _0x4415()
        if _0x61FD then return end
        local _0x6260 = tostring(_0xAE2A.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if _0x6260 == "" then _0xC488.Show("Enter a key first", false) return end
        _0x61FD = true
        _0x78ED.Text = "Validating..."
        _0xE8F7.Text = "Checking..."
        _0xE8F7.TextColor3 = Color3.fromRGB(167, 139, 250)
        task.spawn(function()
            local _0xDF7B, _0xCBE1 = false, "invalid"
            local _0x2007, _0x049D, _0xDF1D = pcall(_0xB7CC.Validate, _0x6260)
            if _0x2007 then _0xDF7B = _0x049D and true or false _0xCBE1 = _0xDF1D or _0xCBE1 else _0xCBE1 = "exception" end
            task.wait(0.3)
            _0x61FD = false
            _0x78ED.Text = "Validate Key"
            if _0xDF7B then
                local _0x0C4D = _0x77AD.IsPremium and _0x77AD.PremiumExpiry or (os.time() + _0xB7CC.DefaultExpiry)
                _0xB7CC.WriteSaved(_0x6260, _0x0C4D)
                if _0x77AD.IsPremium then
                    _0xE8F7.Text = "Premium active: " .. tostring(_0x77AD.PremiumTier)
                    _0xE8F7.TextColor3 = Color3.fromRGB(255, 200, 40)
                    _0xC488.Show("Premium activated: " .. tostring(_0x77AD.PremiumTier), true)
                else
                    _0xE8F7.Text = "Key valid - 24h access"
                    _0xE8F7.TextColor3 = Color3.fromRGB(80, 220, 130)
                    _0xC488.Show("Key valid - welcome", true)
                end
                task.wait(1.9)
                _0x0ABE = false
                pcall(function() _0xFA03:Destroy() end)
                _0xB7CC.Authorized = true
                if onAuthorized then pcall(onAuthorized) end
            else
                local _0xC5D8 = "Key doesn't exist"
                if _0xCBE1 == "http-unavailable" then _0xC5D8 = "Executor has no HTTP access"
                elseif _0xCBE1 == "bad-response" then _0xC5D8 = "Server rejected the request"
                elseif _0xCBE1 == "empty-response" then _0xC5D8 = "Server returned empty"
                elseif _0xCBE1 == "too-short" then _0xC5D8 = "Key is too short" end
                _0xE8F7.Text = _0xC5D8
                _0xE8F7.TextColor3 = Color3.fromRGB(255, 80, 100)
                _0xC488.Show(_0xC5D8, false)
                _0xAE2A.Text = ""
            end
        end)
    end
    _0x78ED.MouseButton1Click:Connect(_0x4415)
    _0xAE2A.FocusLost:Connect(function(enter) if enter then _0x4415() end end)

    return _0xFA03
end

local function _0xE472(_0x4BFF, order, ii)
    local _0x14E4 = _0xB27C()
    if not _0x14E4 then return nil end
    local _0xFA03 = Instance.new("ScreenGui")
    _0xFA03.Name = _0x4BFF _0xFA03.ResetOnSpawn = false _0xFA03.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _0xFA03.DisplayOrder = order or 1 _0xFA03.IgnoreGuiInset = ii ~= false
    pcall(function() _0xFA03.AutoLocalize = false end)
    pcall(function() _0xFA03.Parent = _0x14E4 end)
    return _0xFA03
end

local _0xEE9E = {}
local _0x51E5 = "Default"

local _0xBD58 = {
    "CameraAssistSmoothing", "CameraAssistFOV",
    "CameraAssistMouseSensitivity", "CameraAssistPrediction", "CameraAssistBulletSpeed",
    "CameraAssistLead", "CameraAssistPlayerSens",
}
local function _0xB9CE()
    return {
        Default = {CameraAssistSmoothing=8, CameraAssistFOV=35, CameraAssistMouseSensitivity=1.0, CameraAssistPrediction=true, CameraAssistBulletSpeed=400, CameraAssistLead=0.06, CameraAssistPlayerSens=0.15},
        AR = {CameraAssistSmoothing=7, CameraAssistFOV=35, CameraAssistMouseSensitivity=1.0, CameraAssistPrediction=true, CameraAssistBulletSpeed=500, CameraAssistLead=0.06, CameraAssistPlayerSens=0.15},
        Sniper = {CameraAssistSmoothing=6, CameraAssistFOV=28, CameraAssistMouseSensitivity=1.0, CameraAssistPrediction=true, CameraAssistBulletSpeed=800, CameraAssistLead=0.03, CameraAssistPlayerSens=0.15},
        Shotgun = {CameraAssistSmoothing=5, CameraAssistFOV=55, CameraAssistMouseSensitivity=1.2, CameraAssistPrediction=false, CameraAssistBulletSpeed=250, CameraAssistLead=0.02, CameraAssistPlayerSens=0.15},
        SMG = {CameraAssistSmoothing=6, CameraAssistFOV=45, CameraAssistMouseSensitivity=1.0, CameraAssistPrediction=true, CameraAssistBulletSpeed=450, CameraAssistLead=0.05, CameraAssistPlayerSens=0.15},
        Pistol = {CameraAssistSmoothing=6, CameraAssistFOV=45, CameraAssistMouseSensitivity=1.0, CameraAssistPrediction=false, CameraAssistBulletSpeed=350, CameraAssistLead=0.03, CameraAssistPlayerSens=0.15},
        Melee = {},
    }
end
_0xEE9E = _0xB9CE()

local function _0xF769(_0x4BFF)
    if not _0x4BFF or _0x4BFF == "" then return "Default" end
    local _0xB877 = _0x4BFF:lower()
    if _0xB877:find("knife") or _0xB877:find("melee") or _0xB877:find("sword") or _0xB877:find("bat") or _0xB877:find("hammer") or _0xB877:find("fist") or _0xB877:find("karambit") or _0xB877:find("cutlass") or _0xB877:find("katana") then return "Melee" end
    if _0xB877:find("sniper") or _0xB877:find("awp") or _0xB877:find("barrett") or _0xB877:find("hunt") or _0xB877:find("ranger") or _0xB877:find("longshot") then return "Sniper" end
    if _0xB877:find("shotgun") or _0xB877:find("judge") or _0xB877:find("spas") or _0xB877:find("pump") or _0xB877:find("double") then return "Shotgun" end
    if _0xB877:find("smg") or _0xB877:find("uzi") or _0xB877:find("mp5") or _0xB877:find("mp7") or _0xB877:find("vector") or _0xB877:find("mac") then return "SMG" end
    if _0xB877:find("pistol") or _0xB877:find("glock") or _0xB877:find("deagle") or _0xB877:find("revolver") or _0xB877:find("handgun") then return "Pistol" end
    if _0xB877:find("rifle") or _0xB877:find("scar") or _0xB877:find("ak") or _0xB877:find("m4") or _0xB877:find("m16") or _0xB877:find("fal") or _0xB877:find("burst") or _0xB877:find("auto") then return "AR" end
    return "Default"
end

local function _0x11FD()
    local _0x1A90 = _0xE1FF.LocalPlayer
    if not _0x1A90 then return "Default", nil end
    local _0xE895 = _0x1A90.Character
    if not _0xE895 or not _0xE895.Parent then return "Default", nil end
    local _0x9EEE = _0xE895:FindFirstChildOfClass("Tool")
    if _0x9EEE and _0x9EEE.Name and _0x9EEE.Name ~= "" then return _0xF769(_0x9EEE.Name), _0x9EEE.Name end
    return "Default", nil
end

local function _0xA561(_0x9664)
    local _0xE816 = _0xEE9E[_0x9664] or _0xEE9E.Default
    if not _0xE816 then return end
    if _0x77AD.SilentAimEnabled then return end
    for _, _0xE7BF in ipairs(_0xBD58) do if _0xE816[_0xE7BF] ~= nil then _0x77AD[_0xE7BF] = _0xE816[_0xE7BF] end end
    _0x77AD.CameraAssistPlayerSens = 0.15
    _0x77AD.CameraAssistRotateChar = true
end

local function _0x9CA3()
    local _0xE816 = _0xEE9E[_0x51E5]
    if not _0xE816 then _0xE816 = {} _0xEE9E[_0x51E5] = _0xE816 end
    for _, _0xE7BF in ipairs(_0xBD58) do _0xE816[_0xE7BF] = _0x77AD[_0xE7BF] end
end

local _0xF87D = { MenuKey = true, AimKeyCode = true, AutoFireKeyCode = true, AimControllerButton = true, AutoFireControllerButton = true }
local _0x4FD8 = { MenuMouseButton = true, AimMouseButton = true, AutoFireMouseButton = true }
local _0xE37D = { FlyEnabled = true, SpeedEnabled = true }

function _0x77AD:Save()
    if not _0x76B0.HasWritefile then return false end
    _0x9CA3()
    local _0x7B6E = {}
    for _0xE7BF, _0x8C41 in pairs(self) do
        if _0xE7BF == "BoxColorMap" or _0xE7BF == "HitSoundMap" then
        elseif _0xE7BF == "Save" or _0xE7BF == "Load" then
        elseif _0xF87D[_0xE7BF] or _0x4FD8[_0xE7BF] then
            if typeof(_0x8C41) == "EnumItem" then _0x7B6E[_0xE7BF] = tostring(_0x8C41) end
        elseif typeof(_0x8C41) == "Color3" then _0x7B6E[_0xE7BF] = {_0x3FCC = _0x8C41.R, _0x8377 = _0x8C41.G, _0x2EAC = _0x8C41.B}
        else _0x7B6E[_0xE7BF] = _0x8C41 end
    end
    local _0x67E3
    local _0xDF7B = pcall(function() _0x67E3 = _0xFC99:JSONEncode(_0x7B6E) end)
    if not _0xDF7B or not _0x67E3 then return false end
    local _0x645A = false
    for _, _0x3A4B in ipairs({{folder="VEIL", file="VEIL/Config.json"}, {folder=nil, file="VEIL_Config.json"}}) do
        if _0x3A4B.folder and _0x76B0.HasMakeFolder then pcall(makefolder, _0x3A4B.folder) end
        if pcall(writefile, _0x3A4B.file, _0x67E3) then _0x645A = true break end
    end
    local _0x8B24
    local _0xD189 = pcall(function() _0x8B24 = _0xFC99:JSONEncode(_0xEE9E) end)
    if _0xD189 and _0x8B24 then
        for _, _0x3A4B in ipairs({{folder="VEIL", file="VEIL/Weapons.json"}, {folder=nil, file="VEIL_Weapons.json"}}) do
            if pcall(writefile, _0x3A4B.file, _0x8B24) then break end
        end
    end
    return _0x645A
end

function _0x77AD:Load()
    if not _0x76B0.HasReadfile then return false end
    local _0x67E3
    for _, _0x938C in ipairs({"VEIL/Config.json", "VEIL_Config.json"}) do
        local _0xDF7B, _0x3748 = pcall(readfile, _0x938C)
        if _0xDF7B and _0x3748 then _0x67E3 = _0x3748 break end
    end
    if _0x67E3 then
        local _0xD2FF
        local _0xDF7B = pcall(function() _0xD2FF = _0xFC99:JSONDecode(_0x67E3) end)
        if _0xDF7B and type(_0xD2FF) == "table" then
            for _0xE7BF, _0x8C41 in pairs(_0xD2FF) do
                if not _0xE37D[_0xE7BF] and self[_0xE7BF] ~= nil and _0xE7BF ~= "HitSoundMap" then
                    if _0xF87D[_0xE7BF] and typeof(_0x8C41) == "string" then
                        local _0x4BFF = _0x8C41:gsub("Enum%.[%w_]+%.", "")
                        local _0xD189, _0xCC07 = pcall(function() return Enum.KeyCode[_0x4BFF] end)
                        if _0xD189 and _0xCC07 then self[_0xE7BF] = _0xCC07 end
                    elseif _0x4FD8[_0xE7BF] and typeof(_0x8C41) == "string" then
                        local _0x4BFF = _0x8C41:gsub("Enum%.[%w_]+%.", "")
                        local _0xD189, _0xCC07 = pcall(function() return Enum.UserInputType[_0x4BFF] end)
                        if _0xD189 and _0xCC07 then self[_0xE7BF] = _0xCC07 end
                    elseif type(_0x8C41) == "table" and _0x8C41.r and _0x8C41.g and _0x8C41.b then
                        self[_0xE7BF] = Color3.new(_0x8C41.r, _0x8C41.g, _0x8C41.b)
                    else self[_0xE7BF] = _0x8C41 end
                end
            end
        end
    end
    local _0x8B24
    for _, _0x938C in ipairs({"VEIL/Weapons.json", "VEIL_Weapons.json"}) do
        local _0xDF7B, _0x3748 = pcall(readfile, _0x938C)
        if _0xDF7B and _0x3748 and _0x3748 ~= "" then _0x8B24 = _0x3748 break end
    end
    if _0x8B24 then
        local _0xD2FF
        local _0xDF7B = pcall(function() _0xD2FF = _0xFC99:JSONDecode(_0x8B24) end)
        if _0xDF7B and type(_0xD2FF) == "table" then
            for _0xD108, profile in pairs(_0xD2FF) do
                if type(profile) == "table" then
                    _0xEE9E[_0xD108] = _0xEE9E[_0xD108] or {}
                    for _0xE7BF, _0x8C41 in pairs(profile) do _0xEE9E[_0xD108][_0xE7BF] = _0x8C41 end
                end
            end
        end
    end
    self.FlySpeed = math.clamp(tonumber(self.FlySpeed) or 50, 10, 80)
    self.SpeedValue = math.clamp(tonumber(self.SpeedValue) or 16, 16, 500)
    return true
end

local _0x55FF = {}
function _0x55FF.Track(_0x3A4B) if _0x3A4B then table.insert(_0x55FF, _0x3A4B) end return _0x3A4B end
function _0x55FF.DisconnectAll()
    for _, _0x3A4B in ipairs(_0x55FF) do pcall(function() _0x3A4B:Disconnect() end) end
    table.clear(_0x55FF)
end

-- ============================================================
-- Utility
-- ============================================================
local _0xC036 = {}
_0xC036.Players = _0xE1FF
_0xC036.RunService = _0xB932
_0xC036.UserInputService = _0xA548
_0xC036.Workspace = _0x3BA1
_0xC036.VisibleCache = {}
_0xC036.VisibleCacheTimestamps = {}
_0xC036.VisibleCacheDuration = 0.05
_0xC036.MinRayDist = 0.1
_0xC036.RecentMaxFOV = 70
_0xC036.RecentMaxFOVTime = 0
_0xC036.TeamCache = {}
_0xC036.TeamCacheTime = {}
_0xC036.TeamCacheDuration = 0.15
_0xC036.RaycastParams = RaycastParams.new()
_0xC036.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
_0xC036.RaycastParams.IgnoreWater = true
_0xC036.LobbyCache = nil
_0xC036.LobbyCacheTime = 0
_0xC036.LobbyCacheDuration = 0.4
_0xC036._hbpCache = setmetatable({}, {__mode = "k"})
_0xC036._visFilter = {}
_0xC036.HitboxNamePatterns = {
    HitboxHead=true, HitboxHeadSmall=true, PhysicalHitboxHead=true,
    HitboxBody=true, HitboxBodySmall=true,
    Head=true, UpperTorso=true, LowerTorso=true, HumanoidRootPart=true, Torso=true,
    LeftUpperArm=true, RightUpperArm=true, LeftLowerArm=true, RightLowerArm=true,
    LeftUpperLeg=true, RightUpperLeg=true, LeftLowerLeg=true, RightLowerLeg=true,
    LeftFoot=true, RightFoot=true, LeftHand=true, RightHand=true,
}
_0xC036.HitboxModes = {}
_0xC036.HitboxModes.Head = {"Head", "HitboxHead", "PhysicalHitboxHead", "HitboxHeadSmall"}
_0xC036.HitboxModes.UpperTorso = {"HitboxBody", "HitboxBodySmall", "UpperTorso", "Torso", "HumanoidRootPart"}
_0xC036.HitboxModes.Chest = {"HitboxBody", "HitboxBodySmall", "UpperTorso", "Torso", "HumanoidRootPart"}
_0xC036.HitboxModes.LowerTorso = {"LowerTorso", "Torso", "HitboxBody", "HitboxBodySmall", "HumanoidRootPart"}
_0xC036.DeflectCache = {}
_0xC036.DeflectCacheTime = {}
_0xC036.DeflectCacheDuration = 0.2

function _0xC036.GetCamera() return _0x3BA1.CurrentCamera end
function _0xC036.ViewportScale()
    if not _0x77AD.ScaleWithViewport then return 1 end
    local _0x3A4B = _0x3BA1.CurrentCamera
    if not _0x3A4B then return 1 end
    local _0x8C41 = _0x3A4B.ViewportSize
    if not _0x8C41 or _0x8C41.Y <= 0 then return 1 end
    return _0x8C41.Y / 1080
end
function _0xC036.IsValidNumber(_0xB877) return _0xB877 == _0xB877 and _0xB877 ~= math.huge and _0xB877 ~= -math.huge end
function _0xC036.IsValidVector(_0x8C41)
    if not _0x8C41 then return false end
    return _0xC036.IsValidNumber(_0x8C41.X) and _0xC036.IsValidNumber(_0x8C41.Y) and _0xC036.IsValidNumber(_0x8C41.Z)
end
function _0xC036.WorldToViewport(_0x3694)
    local _0x3A4B = _0x3BA1.CurrentCamera
    if not _0x3A4B or not _0x3A4B.Parent then return Vector2.new(0, 0), false, 0 end
    local _0xDF7B, _0x3FCC = pcall(function() return _0x3A4B:WorldToViewportPoint(_0x3694) end)
    if not _0xDF7B or not _0x3FCC then return Vector2.new(0, 0), false, 0 end
    if not _0xC036.IsValidNumber(_0x3FCC.X) or not _0xC036.IsValidNumber(_0x3FCC.Y) then return Vector2.new(0, 0), false, 0 end
    return Vector2.new(_0x3FCC.X, _0x3FCC.Y), _0x3FCC.Z > 0, _0x3FCC.Z
end
function _0xC036.IsLocalAirborne()
    local _0x1A90 = _0xE1FF.LocalPlayer
    if not _0x1A90 or not _0x1A90.Character then return false end
    local _0x830D = _0x1A90.Character:FindFirstChildOfClass("Humanoid")
    if not _0x830D then return false end
    local _0x0404 = _0x830D:GetState()
    return _0x0404 == Enum.HumanoidStateType.Jumping or _0x0404 == Enum.HumanoidStateType.Freefall
        or _0x0404 == Enum.HumanoidStateType.FallingDown or _0x0404 == Enum.HumanoidStateType.PlatformStanding
end
function _0xC036.GetPlayerTeam(_0x938C)
    if not _0x938C then return nil end
    local _0xD871 = nil
    pcall(function() _0xD871 = _0x938C.Team end)
    if _0xD871 then return _0xD871 end
    local _0x17DA = tick()
    if _0xC036.TeamCacheTime[_0x938C] and (_0x17DA - _0xC036.TeamCacheTime[_0x938C]) < _0xC036.TeamCacheDuration then return _0xC036.TeamCache[_0x938C] end
    local _0xBE70 = nil
    pcall(function()
        local _0x7215 = _0x938C:GetAttributes()
        for _0xB877, _0x8C41 in pairs(_0x7215) do
            local _0x104C = _0xB877:lower()
            if _0x104C == "team" or _0x104C == "teamid" or _0x104C == "teamidentifier" or _0x104C == "teamindex" or _0x104C:find("teamid") then _0xBE70 = _0x8C41 break end
        end
    end)
    if not _0xBE70 and _0x938C.Character then
        pcall(function()
            local _0x7215 = _0x938C.Character:GetAttributes()
            for _0xB877, _0x8C41 in pairs(_0x7215) do
                local _0x104C = _0xB877:lower()
                if _0x104C == "team" or _0x104C == "teamid" or _0x104C == "teamidentifier" or _0x104C == "teamindex" or _0x104C:find("teamid") then _0xBE70 = _0x8C41 break end
            end
        end)
    end
    _0xC036.TeamCache[_0x938C] = _0xBE70
    _0xC036.TeamCacheTime[_0x938C] = _0x17DA
    return _0xBE70
end
function _0xC036.ClearTeamCache(_0x938C)
    _0xC036.TeamCache[_0x938C] = nil _0xC036.TeamCacheTime[_0x938C] = nil
    _0xC036._vpCacheTick = 0
end
function _0xC036.IsEnemy(_0x7215, _0x2EAC)
    if not _0x7215 or not _0x2EAC then return true end
    if not _0x77AD.TeamCheck then return true end
    local _0x213B = _0xC036.GetPlayerTeam(_0x7215)
    local _0x174A = _0xC036.GetPlayerTeam(_0x2EAC)
    if _0x213B == nil or _0x174A == nil then return true end
    if typeof(_0x213B) == "Instance" and typeof(_0x174A) == "Instance" then return _0x213B ~= _0x174A end
    return tostring(_0x213B) ~= tostring(_0x174A)
end
_0xC036._vpCache = {}
_0xC036._vpCacheTick = 0
function _0xC036.GetValidPlayers()
    local _0xD871 = tick()
    if (_0xD871 - _0xC036._vpCacheTick) < 0.1 then return _0xC036._vpCache end
    _0xC036._vpCacheTick = _0xD871
    local _0xA21A = _0xC036._vpCache
    table.clear(_0xA21A)
    local _0x1A90 = _0xE1FF.LocalPlayer
    if not _0x1A90 then return _0xA21A end
    for _, _0x938C in ipairs(_0xE1FF:GetPlayers()) do
        if _0x938C ~= _0x1A90 and _0xC036.IsEnemy(_0x1A90, _0x938C) then
            local _0x3A4B = _0x938C.Character
            if _0x3A4B and _0x3A4B.Parent then
                local _0x830D = _0x3A4B:FindFirstChildOfClass("Humanoid")
                if _0x830D and _0x830D.Health > 0 then
                    local _0x1041 = _0x3A4B:FindFirstChild("Head")
                    local _0x1582 = _0x3A4B:FindFirstChild("HumanoidRootPart")
                    if _0x1041 and _0x1582 then
                        table.insert(_0xA21A, {Player=_0x938C, Character=_0x3A4B, Humanoid=_0x830D, UserId=_0x938C.UserId})
                    end
                end
            end
        end
    end
    return _0xA21A
end
function _0xC036.IsInGame()
    if not _0x77AD.LobbyGuardEnabled then return true end
    local _0x17DA = tick()
    if _0xC036.LobbyCache ~= nil and (_0x17DA - _0xC036.LobbyCacheTime) < _0xC036.LobbyCacheDuration then return _0xC036.LobbyCache end
    local function _0x1F1C(_0x0404) _0xC036.LobbyCache = _0x0404 _0xC036.LobbyCacheTime = _0x17DA return _0x0404 end
    local _0x5B5D = _0x77AD.LobbyStateOverride or "Auto"
    if _0x5B5D == "InGame" then return _0x1F1C(true) end
    if _0x5B5D == "Lobby" then return _0x1F1C(false) end
    local _0xD044 = _0x3BA1
    local _0x1A90 = _0xE1FF.LocalPlayer
    if not _0x1A90 then return _0x1F1C(true) end
    local _0xA792 = _0xD044:FindFirstChild("Characters")
    if _0xA792 then
        local _0x3A4B = _0x1A90.Character
        if _0x3A4B and _0x3A4B.Parent then
            local _0x14E4 = _0x3A4B.Parent
            if _0x14E4.Parent == _0xA792 then return _0x1F1C(true) end
            if _0x14E4 == _0xD044 or _0x14E4 == _0xA792 then return _0x1F1C(false) end
            if _0x14E4.Name and _0x14E4.Name:lower():find("lobby") then return _0x1F1C(false) end
        else return _0x1F1C(false) end
    end
    return _0x1F1C(true)
end
function _0xC036.InvalidateLobbyCache() _0xC036.LobbyCache = nil _0xC036.LobbyCacheTime = 0 end
function _0xC036.ResolveHitboxMode(_0xC1D0)
    _0xC1D0 = _0xC1D0 or _0x77AD.CameraAssistHitboxMode or "Head"
    if _0xC1D0 == "Random" then
        local _0x9D43 = {"Head", "UpperTorso", "Chest"}
        return _0x9D43[math.random(1, #_0x9D43)]
    end
    return _0xC1D0
end
function _0xC036.GetHitboxPosition(_0x3A4B, hname, cachePart)
    if not _0x3A4B or not _0x3A4B.Parent then return nil, nil end
    if cachePart and cachePart.Parent and _0xC036.IsValidVector(cachePart.Position) then
        if hname == "Head" and cachePart:IsA("BasePart") then
            return cachePart.Position + Vector3.new(0, cachePart.Size.Y * 0.30, 0), cachePart
        end
        return cachePart.Position, cachePart
    end
    local _0xC1D0 = hname or _0x77AD.CameraAssistHitboxMode or "Head"
    if _0xC1D0 == "Random" then _0xC1D0 = _0xC036.ResolveHitboxMode("Random") end
    local _0xACE3 = _0xC036._hbpCache[_0x3A4B]
    if _0xACE3 and _0xACE3.mode == _0xC1D0 and _0xACE3.part and _0xACE3.part.Parent then
        local _0x3694 = _0xACE3.part.Position
        if _0xC1D0 == "Head" and _0xACE3.part:IsA("BasePart") then
            _0x3694 = _0x3694 + Vector3.new(0, _0xACE3.part.Size.Y * 0.30, 0)
        end
        if _0xC036.IsValidVector(_0x3694) then return _0x3694, _0xACE3.part end
    end
    local _0xB16F = _0xC036.HitboxModes[_0xC1D0] or _0xC036.HitboxModes.Head
    for _, _0xB877 in ipairs(_0xB16F) do
        local _0x938C = _0x3A4B:FindFirstChild(_0xB877)
        if _0x938C and _0x938C.Parent then
            local _0x3694 = _0x938C.Position
            if _0xC1D0 == "Head" and _0x938C:IsA("BasePart") then
                _0x3694 = _0x3694 + Vector3.new(0, _0x938C.Size.Y * 0.30, 0)
            end
            if _0xC036.IsValidVector(_0x3694) then
                _0xC036._hbpCache[_0x3A4B] = { _0xC1D0 = _0xC1D0, _0x7AA7 = _0x938C }
                return _0x3694, _0x938C
            end
        end
    end
    return nil, nil
end
function _0xC036.IsTargetablePart(_0x938C)
    if not _0x938C then return false end
    if _0xC036.HitboxNamePatterns[_0x938C.Name] then return true end
    local _0x104C = _0x938C.Name:lower()
    return _0x104C:find("hitbox") or _0x104C:find("torso") or _0x104C:find("head") or _0x104C:find("hand")
        or _0x104C:find("foot") or _0x104C:find("leg") or _0x104C:find("arm") or _0x104C:find("body") or _0x104C:find("chest")
end
_0xC036._reloadCacheTick = 0
_0xC036._reloadCacheVal = false
function _0xC036.IsReloading()
    local _0xD871 = tick()
    if (_0xD871 - _0xC036._reloadCacheTick) < 0.15 then return _0xC036._reloadCacheVal end
    _0xC036._reloadCacheTick = _0xD871
    local _0xD392 = false
    local _0x1A90 = _0xE1FF.LocalPlayer
    if _0x1A90 and _0x1A90.Character then
        local _0x3A4B = _0x1A90.Character
        local _0x9EEE = _0x3A4B:FindFirstChildOfClass("Tool")
        if _0x9EEE then
            for _, ch in ipairs(_0x9EEE:GetChildren()) do
                if ch:IsA("BoolValue") and ch.Name:lower():find("reload") and ch.Value then _0xD392 = true break end
            end
        end
    end
    _0xC036._reloadCacheVal = _0xD392
    return _0xD392
end
function _0xC036.IsPositionVisible(_0xE96E, il, ck, tpart)
    if not _0x77AD.CameraAssistVisibleCheck then return true end
    local _0x7458 = _0x3BA1.CurrentCamera
    if not _0x7458 then return false end
    il = il or {}
    if ck then
        local _0x41E5 = _0xC036.VisibleCacheTimestamps[ck]
        if _0x41E5 and (tick() - _0x41E5) < _0xC036.VisibleCacheDuration then return _0xC036.VisibleCache[ck] end
    end
    local _0xF96F = _0xC036._visFilter
    table.clear(_0xF96F)
    for _, item in ipairs(il) do if item and item.Parent then table.insert(_0xF96F, item) end end
    local _0x1A90 = _0xE1FF.LocalPlayer
    if _0x1A90 and _0x1A90.Character and _0x1A90.Character.Parent then
        local _0x7320 = false
        for _, item in ipairs(_0xF96F) do if item == _0x1A90.Character then _0x7320 = true break end end
        if not _0x7320 then table.insert(_0xF96F, _0x1A90.Character) end
    end
    if _0x7458 and _0x7458.Parent then table.insert(_0xF96F, _0x7458) end
    local _0x562F = _0x7458.CFrame.Position
    local _0x9C04 = tpart and tpart:FindFirstAncestorOfClass("Model") or nil
    local function _0xE4D4(point)
        local _0x3748 = point - _0x562F
        local _0xAFA9 = _0x3748.Magnitude
        if _0xAFA9 < 0.01 then return true end
        _0xC036.RaycastParams.FilterDescendantsInstances = _0xF96F
        local _0xDF7B, _0x3FCC = pcall(function() return _0x3BA1:Raycast(_0x562F, _0x3748 / _0xAFA9 * _0xAFA9, _0xC036.RaycastParams) end)
        if not _0xDF7B then return false end
        if _0x3FCC == nil then return true end
        local _0x366B = _0x3FCC.Instance
        if _0x366B == tpart then return true end
        if _0x9C04 and _0x366B:IsDescendantOf(_0x9C04) then
            if (_0x366B.Position - _0xE96E).Magnitude <= 1.5 then return true end
        end
        local _0x5D38 = 0
        if _0x366B then
            local _0x77C8, _0xD871 = pcall(function() return _0x366B.Transparency end)
            if _0x77C8 and typeof(_0xD871) == "number" then _0x5D38 = _0xD871 end
        end
        if _0x5D38 >= 0.9 then return true end
        if (_0x3FCC.Position - _0x562F).Magnitude >= _0xAFA9 - _0xC036.MinRayDist then return true end
        return false
    end
    local _0x8C41 = _0xE4D4(_0xE96E)
    if not _0x8C41 and _0x9C04 then
        local _0x830D = _0x9C04:FindFirstChild("Head")
        if _0x830D then _0x8C41 = _0xE4D4(_0x830D.Position) end
    end
    if ck then
        _0xC036.VisibleCache[ck] = _0x8C41
        _0xC036.VisibleCacheTimestamps[ck] = tick()
    end
    return _0x8C41
end
function _0xC036.CameraRaycast(maxDist)
    local _0x7458 = _0x3BA1.CurrentCamera
    if not _0x7458 then return nil end
    local _0xF96F = _0xC036._camRayFilter
    if not _0xF96F then _0xF96F = {} _0xC036._camRayFilter = _0xF96F end
    table.clear(_0xF96F)
    local _0x1A90 = _0xE1FF.LocalPlayer
    if _0x1A90 and _0x1A90.Character then table.insert(_0xF96F, _0x1A90.Character) end
    if _0x7458 then table.insert(_0xF96F, _0x7458) end
    local _0x3FCF = RaycastParams.new()
    _0x3FCF.FilterType = Enum.RaycastFilterType.Exclude
    _0x3FCF.FilterDescendantsInstances = _0xF96F
    _0x3FCF.IgnoreWater = true
    local _0xDF7B, _0x3FCC = pcall(function() return _0x3BA1:Raycast(_0x7458.CFrame.Position, _0x7458.CFrame.LookVector * (maxDist or 1000), _0x3FCF) end)
    if not _0xDF7B or not _0x3FCC then return nil end
    local _0x9236 = _0x3FCC.Instance
    return _0x9236, _0x3FCC.Position, _0x9236 and _0x9236:FindFirstAncestorOfClass("Model") or nil
end
function _0xC036.IsTargetDeflecting(_0x938C)
    if not _0x938C then return false end
    local _0x17DA = tick()
    local _0x4891 = _0xC036.DeflectCacheTime[_0x938C]
    if _0x4891 and (_0x17DA - _0x4891) < _0xC036.DeflectCacheDuration then
        if not _0x938C.Parent then
            _0xC036.DeflectCache[_0x938C] = nil _0xC036.DeflectCacheTime[_0x938C] = nil
        else return _0xC036.DeflectCache[_0x938C] end
    end
    local _0xBE70 = false
    local _0x3A4B = _0x938C.Character
    if _0x3A4B and _0x3A4B.Parent then
        local _0x9EEE = _0x3A4B:FindFirstChildOfClass("Tool")
        if _0x9EEE then
            local _0xB877 = _0x9EEE.Name:lower()
            if _0xB877:find("katana") or _0xB877:find("sword") or _0xB877:find("blade") or _0xB877:find("saber") then
                for _, ch in ipairs(_0x9EEE:GetChildren()) do
                    if ch:IsA("BoolValue") and ch.Value then
                        local _0xD9A1 = ch.Name:lower()
                        if _0xD9A1:find("block") or _0xD9A1:find("parry") or _0xD9A1:find("guard")
                            or _0xD9A1:find("deflect") or _0xD9A1:find("hold") then _0xBE70 = true break end
                    elseif ch:IsA("NumberValue") and ch.Value > 0 then
                        local _0xD9A1 = ch.Name:lower()
                        if _0xD9A1:find("block") or _0xD9A1:find("parry") or _0xD9A1:find("guard") or _0xD9A1:find("deflect") then _0xBE70 = true break end
                    end
                end
            end
        end
    end
    _0xC036.DeflectCache[_0x938C] = _0xBE70
    _0xC036.DeflectCacheTime[_0x938C] = _0x17DA
    return _0xBE70
end
-- ============================================================
-- Palette
-- ============================================================
local _0x3317 = {
    Primary = Color3.fromRGB(139, 92, 246), Accent3 = Color3.fromRGB(167, 139, 250),
    Bg = Color3.fromRGB(8, 8, 13),
    Panel = Color3.fromRGB(17, 17, 26), PanelLight = Color3.fromRGB(28, 25, 44),
    Card = Color3.fromRGB(22, 20, 34), Accent = Color3.fromRGB(139, 92, 246),
    Accent2 = Color3.fromRGB(99, 102, 241), Text = Color3.fromRGB(245, 243, 255),
    TextMuted = Color3.fromRGB(161, 161, 170), Border = Color3.fromRGB(48, 44, 72),
    Success = Color3.fromRGB(80, 220, 130), Danger = Color3.fromRGB(255, 80, 100),
    Discord = Color3.fromRGB(88, 101, 242),
}
local _0x7CB3 = {
    Bg = Color3.fromRGB(8, 8, 13), BtnBg = Color3.fromRGB(22, 20, 34),
    Stroke = Color3.fromRGB(48, 44, 72), Accent = Color3.fromRGB(139, 92, 246),
    Accent2 = Color3.fromRGB(99, 102, 241), Accent3 = Color3.fromRGB(167, 139, 250),
    Text = Color3.fromRGB(245, 243, 255), TextMuted = Color3.fromRGB(161, 161, 170),
    Gold = Color3.fromRGB(255, 200, 40),
}
local function _0x9BD5(label)
    local _0x48C5 = Instance.new("UIGradient")
    _0x48C5.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(180, 155, 220)),
        ColorSequenceKeypoint.new(0.40, Color3.fromRGB(180, 155, 220)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.60, Color3.fromRGB(180, 155, 220)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(180, 155, 220)),
    })
    _0x48C5.Offset = Vector2.new(-1, 0) _0x48C5.Parent = label
    task.spawn(function()
        while label.Parent do
            _0x48C5.Offset = Vector2.new(-1, 0)
            _0x27A5:Create(_0x48C5, TweenInfo.new(4.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Offset = Vector2.new(1, 0)}):Play()
            task.wait(5.5)
        end
    end)
    return _0x48C5
end

-- ============================================================
-- FOVCircle
-- ============================================================
local _0xA3FC = {}
_0xA3FC.Container = nil _0xA3FC.Ring = nil _0xA3FC.Stroke = nil _0xA3FC.Hue = 0
_0xA3FC._lastSize = nil _0xA3FC._lastColor = nil _0xA3FC._lastVisible = nil
_0xA3FC._lastUpdate = 0
_0xA3FC.ColorMap = {
    White = Color3.fromRGB(245, 243, 255), Red = Color3.fromRGB(255, 60, 60),
    Yellow = Color3.fromRGB(255, 220, 60), Blue = _0x3317.Accent2,
    Green = Color3.fromRGB(60, 220, 90), Black = Color3.fromRGB(25, 25, 30),
    Cyan = Color3.fromRGB(80, 220, 240), Purple = Color3.fromRGB(139, 92, 246),
    Orange = Color3.fromRGB(255, 140, 60), Pink = Color3.fromRGB(255, 100, 200),
    Lime = Color3.fromRGB(120, 255, 120), Teal = Color3.fromRGB(60, 200, 180),
}
function _0xA3FC.Ensure()
    if _0xA3FC.Container and _0xA3FC.Container.Parent and _0xA3FC.Ring and _0xA3FC.Ring.Parent then return true end
    if _0xA3FC.Container and not _0xA3FC.Container.Parent then _0xA3FC.Container = nil _0xA3FC.Ring = nil _0xA3FC.Stroke = nil end
    if not _0xA3FC.Container then
        local _0xFA03 = _0xE472("VEIL_FOV", 120, true)
        if not _0xFA03 then return false end
        _0xA3FC.Container = _0xFA03
    end
    if not _0xA3FC.Ring or not _0xA3FC.Ring.Parent then
        local _0x3FCC = Instance.new("Frame")
        _0x3FCC.Name = "Ring" _0x3FCC.AnchorPoint = Vector2.new(0.5, 0.5)
        _0x3FCC.Position = UDim2.new(0.5, 0, 0.5, 0) _0x3FCC.BackgroundTransparency = 1
        _0x3FCC.BorderSizePixel = 0 _0x3FCC.Visible = false _0x3FCC.Parent = _0xA3FC.Container
        local _0x631C = Instance.new("UICorner") _0x631C.CornerRadius = UDim.new(0.5, 0) _0x631C.Parent = _0x3FCC
        local _0x48A3 = Instance.new("UIStroke") _0x48A3.Thickness = 2 _0x48A3.Color = _0x3317.Primary _0x48A3.Transparency = 0.1 _0x48A3.Parent = _0x3FCC
        _0xA3FC.Ring = _0x3FCC _0xA3FC.Stroke = _0x48A3
    end
    return true
end
function _0xA3FC.Update()
    local _0x17DA = tick()
    local _0x2D85 = _0x9A4D.isMobile and (1 / 15) or (1 / 60)
    if _0x17DA - _0xA3FC._lastUpdate < _0x2D85 then return end
    _0xA3FC._lastUpdate = _0x17DA
    _0xA3FC.Ensure()
    if not _0xA3FC.Ring then return end
    local _0x7458 = _0x3BA1.CurrentCamera
    local _0x4645 = _0x77AD.SilentAimDrawFOV
    local _0x5F65 = _0x77AD.CameraAssistDrawFOV
    if not _0x7458 or (not _0x4645 and not _0x5F65) then
        if _0xA3FC._lastVisible ~= false then _0xA3FC.Ring.Visible = false _0xA3FC._lastVisible = false end
        return
    end
    local _0xE6BD = _0x4645
    local _0x39E3 = _0xE6BD and (_0x77AD.SilentAimFOV or 200) or (_0x77AD.CameraAssistFOV or 35)
    local _0xDA6A = _0xE6BD and _0x77AD.SilentAimFOVColor or _0x77AD.CameraAssistFOVColor
    local _0x9649 = _0xC036.ViewportScale()
    local _0xE794 = _0x7458.ViewportSize
    local _0x3A24 = math.min(_0xE794.X, _0xE794.Y) - 40
    if _0x3A24 < 40 then _0x3A24 = 40 end
    local _0x0753 = math.clamp(_0x39E3 * 10 * _0x9649, 10, 4000)
    local _0x0DF6 = math.floor(_0x0753 * 2)
    if _0x0DF6 > _0x3A24 then _0x0DF6 = _0x3A24 end
    if _0xA3FC._lastSize ~= _0x0DF6 then
        _0xA3FC.Ring.Size = UDim2.new(0, _0x0DF6, 0, _0x0DF6)
        _0xA3FC._lastSize = _0x0DF6
    end
    if _0xA3FC._lastVisible ~= true then _0xA3FC.Ring.Visible = true _0xA3FC._lastVisible = true end
    local _0x48A3 = _0xA3FC.Stroke
    if not _0x48A3 then return end
    if _0xDA6A == "RGB" then
        _0xA3FC.Hue = (_0xA3FC.Hue + 0.002) % 1
        _0x48A3.Color = Color3.fromHSV(_0xA3FC.Hue, 1, 1)
        _0xA3FC._lastColor = nil
    else
        local _0xE798 = _0xA3FC.ColorMap[_0xDA6A] or _0x3317.Primary
        if _0xA3FC._lastColor ~= _0xE798 then _0x48A3.Color = _0xE798 _0xA3FC._lastColor = _0xE798 end
    end
end
function _0xA3FC.Destroy()
    if _0xA3FC.Container then pcall(function() _0xA3FC.Container:Destroy() end) end
    _0xA3FC.Container = nil _0xA3FC.Ring = nil _0xA3FC.Stroke = nil
end

-- ============================================================
-- Visuals
-- ============================================================
local _0xD16E = {}
_0xD16E.Objects = {} _0xD16E.Container = nil _0xD16E.ValidPlayersCache = {}
_0xD16E.LastPlayerListUpdate = 0 _0xD16E.LastUpdateTime = 0 _0xD16E.LastVisibleCount = 0
_0xD16E.BoneConnections = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}
function _0xD16E.EnsureContainer()
    if _0xD16E.Container and _0xD16E.Container.Parent then return true end
    local _0xFA03 = _0xE472("VEIL_Visuals", 5, true)
    if not _0xFA03 then return false end
    _0xD16E.Container = _0xFA03
    return true
end
function _0xD16E.CreateSkeletonLines(_0xCE00)
    local _0x7112 = _0xCE00 and _0xCE00.UserId or "unknown"
    local _0x1844 = {}
    _0xD16E.EnsureContainer()
    if not _0xD16E.Container then return _0x1844 end
    local _0x38A0 = _0x77AD.BoxColorMap or {}
    local _0xF99E = _0x38A0[_0x77AD.SkeletonColor] or _0x3317.Accent3
    for _0x9236 = 1, #_0xD16E.BoneConnections do
        local _0x104C = Instance.new("Frame")
        _0x104C.Name = string.format("Skel_%s_%d", tostring(_0x7112), _0x9236)
        _0x104C.BackgroundColor3 = _0xF99E _0x104C.BorderSizePixel = 0
        _0x104C.AnchorPoint = Vector2.new(0.5, 0.5)
        _0x104C.Size = UDim2.new(0, 0, 0, 1) _0x104C.Position = UDim2.new(0, -9999, 0, -9999)
        _0x104C.Visible = false _0x104C.ZIndex = 3 _0x104C.Parent = _0xD16E.Container
        table.insert(_0x1844, _0x104C)
    end
    return _0x1844
end
function _0xD16E.CreateElements(_0xCE00)
    local _0x7112 = _0xCE00 and _0xCE00.UserId
    if not _0x7112 or _0xD16E.Objects[_0x7112] then return _0xD16E.Objects[_0x7112] end
    _0xD16E.EnsureContainer()
    if not _0xD16E.Container then return nil end
    local _0x91A7 = Instance.new("Frame")
    _0x91A7.Name = "Overlay_" .. tostring(_0x7112)
    _0x91A7.Size = UDim2.new(0, 100, 0, 100) _0x91A7.Position = UDim2.new(0, -9999, 0, -9999)
    _0x91A7.BackgroundTransparency = 1 _0x91A7.BorderSizePixel = 0 _0x91A7.Visible = false _0x91A7.Parent = _0xD16E.Container
    local _0x9817 = Instance.new("Frame")
    _0x9817.Size = UDim2.new(1, 0, 1, 0) _0x9817.BackgroundTransparency = 1 _0x9817.BorderSizePixel = 0 _0x9817.ZIndex = 2 _0x9817.Parent = _0x91A7
    local _0xFFFC = Instance.new("UIStroke")
    _0xFFFC.Color = _0x3317.Primary _0xFFFC.Thickness = 1.5
    _0xFFFC.ApplyStrokeMode = Enum.ApplyStrokeMode.Border _0xFFFC.Parent = _0x9817
    local _0x7C5C = Instance.new("TextLabel")
    _0x7C5C.Size = UDim2.new(1, 0, 0, 14) _0x7C5C.Position = UDim2.new(0, 0, 0, -16)
    _0x7C5C.BackgroundTransparency = 1 _0x7C5C.Font = Enum.Font.Gotham _0x7C5C.TextSize = 11
    _0x7C5C.TextColor3 = _0x3317.Text _0x7C5C.TextStrokeTransparency = 0.4
    _0x7C5C.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) _0x7C5C.TextXAlignment = Enum.TextXAlignment.Center
    _0x7C5C.ZIndex = 4 _0x7C5C.Parent = _0x91A7
    local _0x68A8 = Instance.new("Frame")
    _0x68A8.Size = UDim2.new(0, 4, 1, 0) _0x68A8.Position = UDim2.new(-1, -6, 0, 0)
    _0x68A8.BackgroundColor3 = Color3.fromRGB(30, 28, 44) _0x68A8.BorderSizePixel = 0 _0x68A8.ZIndex = 2 _0x68A8.Parent = _0x91A7
    local _0xC421 = Instance.new("Frame")
    _0xC421.Size = UDim2.new(1, 0, 1, 0) _0xC421.BackgroundColor3 = Color3.fromRGB(0, 255, 100) _0xC421.BorderSizePixel = 0 _0xC421.Parent = _0x68A8
    local _0x906D = Instance.new("TextLabel")
    _0x906D.Size = UDim2.new(0, 32, 0, 12) _0x906D.Position = UDim2.new(-1, -40, 0, -2)
    _0x906D.BackgroundColor3 = Color3.fromRGB(0, 0, 0) _0x906D.BackgroundTransparency = 0.35
    _0x906D.Font = Enum.Font.Gotham _0x906D.TextSize = 9 _0x906D.TextColor3 = _0x3317.Text
    _0x906D.TextStrokeTransparency = 0.5 _0x906D.TextXAlignment = Enum.TextXAlignment.Left _0x906D.ZIndex = 4 _0x906D.Parent = _0x91A7
    local _0x270D = Instance.new("TextLabel")
    _0x270D.Size = UDim2.new(1, 0, 0, 12) _0x270D.Position = UDim2.new(0, 0, 1, 2)
    _0x270D.BackgroundTransparency = 1 _0x270D.Font = Enum.Font.Gotham _0x270D.TextSize = 9
    _0x270D.TextColor3 = _0x3317.TextMuted _0x270D.TextStrokeTransparency = 0.5
    _0x270D.TextXAlignment = Enum.TextXAlignment.Center _0x270D.ZIndex = 4 _0x270D.Parent = _0x91A7
    local _0xB315 = _0xD16E.CreateSkeletonLines(_0xCE00)
    local _0x34B6 = { Container = _0x91A7, Box = _0x9817, Stroke = _0xFFFC, Name = _0x7C5C, HealthBar = _0x68A8, HealthFill = _0xC421, HealthText = _0x906D, Distance = _0x270D, SkeletonLines = _0xB315, Player = _0xCE00, Character = nil }
    _0xD16E.Objects[_0x7112] = _0x34B6
    return _0x34B6
end
function _0xD16E.UpdateSkeleton(_0x34B6, _0x3A4B)
    if not _0x34B6 or not _0x34B6.SkeletonLines then return end
    local _0xB888 = false
    if not _0x77AD.ShowSkeleton then _0xB888 = true end
    if not _0x34B6.Container or not _0x34B6.Container.Visible then _0xB888 = true end
    if not _0x3A4B or not _0x3A4B.Parent then _0xB888 = true end
    if _0xB888 then
        for _, _0x104C in ipairs(_0x34B6.SkeletonLines) do if _0x104C.Visible then _0x104C.Visible = false end end
        return
    end
    local _0x38A0 = _0x77AD.BoxColorMap or {}
    local _0x8E2A = _0x38A0[_0x77AD.SkeletonColor] or _0x3317.Accent3
    for _0x9236, pair in ipairs(_0xD16E.BoneConnections) do
        local _0x104C = _0x34B6.SkeletonLines[_0x9236]
        if _0x104C then
            if _0x104C.BackgroundColor3 ~= _0x8E2A then _0x104C.BackgroundColor3 = _0x8E2A end
            local _0x8015 = _0x3A4B:FindFirstChild(pair[1])
            local _0x9281 = _0x3A4B:FindFirstChild(pair[2])
            local _0x1215 = false
            if not _0x8015 or not _0x9281 then _0x1215 = true end
            if not _0x1215 then
                local _0xED05, _0x09FA = _0xC036.WorldToViewport(_0x8015.Position)
                local _0xE96A, _0x7005 = _0xC036.WorldToViewport(_0x9281.Position)
                if not _0x09FA or not _0x7005 then _0x1215 = true end
                if not _0x1215 then
                    local _0x2912 = _0xE96A.X - _0xED05.X
                    local _0x4CC4 = _0xE96A.Y - _0xED05.Y
                    local _0x4845 = math.sqrt(_0x2912 * _0x2912 + _0x4CC4 * _0x4CC4)
                    if _0x4845 < 1 then _0x1215 = true end
                    if not _0x1215 then
                        local _0xA856 = (_0xED05.X + _0xE96A.X) * 0.5
                        local _0xE174 = (_0xED05.Y + _0xE96A.Y) * 0.5
                        local _0x9755 = math.deg(math.atan2(_0x4CC4, _0x2912))
                        _0x104C.Size = UDim2.new(0, math.floor(_0x4845), 0, 1)
                        _0x104C.Position = UDim2.new(0, math.floor(_0xA856), 0, math.floor(_0xE174))
                        _0x104C.Rotation = _0x9755
                        if not _0x104C.Visible then _0x104C.Visible = true end
                    end
                end
            end
            if _0x1215 and _0x104C.Visible then _0x104C.Visible = false end
        end
    end
end
function _0xD16E.Step()
    if not _0x77AD.VisualsEnabled then
        for _0x7112, _0x34B6 in pairs(_0xD16E.Objects) do
            if _0x34B6.Container then pcall(function() _0x34B6.Container:Destroy() end) end
            if _0x34B6.SkeletonLines then
                for _, _0x104C in ipairs(_0x34B6.SkeletonLines) do if _0x104C then pcall(function() _0x104C:Destroy() end) end end
            end
        end
        _0xD16E.Objects = {}
        if _0xD16E.Container then
            for _, ch in ipairs(_0xD16E.Container:GetChildren()) do
                if ch.Name:sub(1, 7) == "Overlay" or ch.Name:sub(1, 5) == "Skel_" then pcall(function() ch:Destroy() end) end
            end
        end
        return
    end
    local _0x17DA = tick()
    local _0xAFA8 = _0xD16E.LastVisibleCount or 0
    local _0xDD3B
    if _0x9A4D.isMobile then
        if _0xAFA8 <= 6 then _0xDD3B = 30
        elseif _0xAFA8 <= 12 then _0xDD3B = 22
        elseif _0xAFA8 <= 24 then _0xDD3B = 15
        else _0xDD3B = 10 end
    else
        if _0xAFA8 <= 6 then _0xDD3B = 240
        elseif _0xAFA8 <= 12 then _0xDD3B = 144
        elseif _0xAFA8 <= 24 then _0xDD3B = 90
        else _0xDD3B = 60 end
    end
    local _0x2D85 = 1.0 / _0xDD3B
    if _0x17DA - _0xD16E.LastUpdateTime < _0x2D85 then return end
    _0xD16E.LastUpdateTime = _0x17DA
    if _0x17DA - _0xD16E.LastPlayerListUpdate > _0x77AD.PlayerListUpdateInterval then
        _0xD16E.LastPlayerListUpdate = _0x17DA
        _0xD16E.ValidPlayersCache = _0xC036.GetValidPlayers()
    end
    local _0x7458 = _0x3BA1.CurrentCamera
    if not _0x7458 or not _0x7458.Parent then return end
    local _0x1A90 = _0xE1FF.LocalPlayer
    if not _0x1A90 or not _0x1A90.Character then return end
    local _0x03BB = _0x1A90.Character:FindFirstChild("HumanoidRootPart")
    local _0xD6D2 = _0x7458.ViewportSize.X
    local _0xF50E = _0x7458.ViewportSize.Y
    local _0x4DDE = {}
    local _0xB12A = _0x77AD.BoxColorMap or {}
    for _, _0xB680 in ipairs(_0xD16E.ValidPlayersCache) do
        local _0xCE00 = _0xB680.Player
        local _0x3A4B = _0xB680.Character
        local _0x830D = _0xB680.Humanoid
        if _0x3A4B and _0x3A4B.Parent and _0x830D and _0x830D.Parent then
            _0x4DDE[_0xCE00.UserId] = true
            local _0x34B6 = _0xD16E.Objects[_0xCE00.UserId] or _0xD16E.CreateElements(_0xCE00)
            if _0x34B6 then
                local _0xAC0E = _0x3A4B:FindFirstChild("Head")
                local _0xA43B = _0x3A4B:FindFirstChild("HumanoidRootPart")
                local _0xC2AA = false
                if _0xAC0E and _0xA43B then
                    local _0x463D, _0x4FFE = _0xC036.WorldToViewport(_0xAC0E.Position)
                    local _0x2639, _0x4FE2 = _0xC036.WorldToViewport(_0xA43B.Position)
                    if _0x4FFE and _0x4FE2 then
                        local _0xB00C = _0x2639.Y - _0x463D.Y
                        if _0xB00C <= 0 then _0xB00C = -_0xB00C end
                        local _0x906D = math.max(math.floor(_0xB00C * 2 * 1.5 + 0.5), 30)
                        local _0xDA50 = math.max(math.floor(_0x906D * 0.45 + 0.5), 15)
                        local _0x5B90 = math.floor(_0x463D.X - _0xDA50 * 0.5 + 0.5)
                        local _0xD238 = math.floor(_0x463D.Y + _0xB00C - _0x906D * 0.5 + 0.5)
                        if _0x5B90 > -_0xDA50 and _0x5B90 < _0xD6D2 and _0xD238 > -_0x906D and _0xD238 < _0xF50E then
                            _0x34B6.Container.Position = UDim2.new(0, _0x5B90, 0, _0xD238)
                            _0x34B6.Container.Size = UDim2.new(0, _0xDA50, 0, _0x906D)
                            _0x34B6.Box.Visible = _0x77AD.ShowBoxes
                            _0x34B6.Stroke.Enabled = _0x77AD.ShowBoxes
                            _0x34B6.Stroke.Color = _0xB12A[_0x77AD.BoxColor] or _0x3317.Primary
                            _0x34B6.Name.Visible = _0x77AD.ShowNames
                            _0x34B6.Name.TextColor3 = _0xB12A[_0x77AD.NameColor] or _0x3317.Text
                            local _0x8E0F = _0xCE00.Name or "?"
                            if _0x34B6.Name.Text ~= _0x8E0F then _0x34B6.Name.Text = _0x8E0F end
                            if _0x77AD.ShowHealth then
                                _0x34B6.HealthBar.Visible = true
                                _0x34B6.HealthText.Visible = true
                                local _0xDE6D = _0x830D.Health / math.max(_0x830D.MaxHealth, 1)
                                _0x34B6.HealthFill.Size = UDim2.new(1, 0, _0xDE6D, 0)
                                local _0x43D1 = tostring(math.floor(_0x830D.Health))
                                if _0x34B6.HealthText.Text ~= _0x43D1 then _0x34B6.HealthText.Text = _0x43D1 end
                                local _0xA771
                                if _0xDE6D > 0.6 then _0xA771 = Color3.fromRGB(0, 255, 100)
                                elseif _0xDE6D > 0.3 then _0xA771 = Color3.fromRGB(255, 255, 0)
                                else _0xA771 = Color3.fromRGB(255, 0, 0) end
                                if _0x34B6.HealthFill.BackgroundColor3 ~= _0xA771 then _0x34B6.HealthFill.BackgroundColor3 = _0xA771 end
                            else
                                if _0x34B6.HealthBar.Visible then _0x34B6.HealthBar.Visible = false end
                                if _0x34B6.HealthText.Visible then _0x34B6.HealthText.Visible = false end
                            end
                            if _0x77AD.ShowDistance and _0x03BB then
                                if not _0x34B6.Distance.Visible then _0x34B6.Distance.Visible = true end
                                local _0x3748 = (_0x03BB.Position - _0xA43B.Position).Magnitude
                                if _0x3748 < _0x77AD.MaxRenderDistance then
                                    local _0x154F = string.format("%dm", math.floor(_0x3748))
                                    if _0x34B6.Distance.Text ~= _0x154F then _0x34B6.Distance.Text = _0x154F end
                                else
                                    if _0x34B6.Distance.Visible then _0x34B6.Distance.Visible = false end
                                end
                            else
                                if _0x34B6.Distance.Visible then _0x34B6.Distance.Visible = false end
                            end
                            _0xC2AA = true
                        end
                    end
                end
                if _0xC2AA then
                    _0xD16E.UpdateSkeleton(_0x34B6, _0x3A4B)
                    if not _0x34B6.Container.Visible then _0x34B6.Container.Visible = true end
                else
                    if _0x34B6.Container.Visible then _0x34B6.Container.Visible = false end
                    if _0x34B6.SkeletonLines then
                        for _, _0x104C in ipairs(_0x34B6.SkeletonLines) do if _0x104C.Visible then _0x104C.Visible = false end end
                    end
                end
            end
        end
    end
    for _0x7112, _0x34B6 in pairs(_0xD16E.Objects) do
        if not _0x4DDE[_0x7112] then
            if _0x34B6.Container then pcall(function() _0x34B6.Container:Destroy() end) end
            if _0x34B6.SkeletonLines then
                for _, _0x104C in ipairs(_0x34B6.SkeletonLines) do if _0x104C then pcall(function() _0x104C:Destroy() end) end end
            end
            _0xD16E.Objects[_0x7112] = nil
        end
    end
    local _0xB877 = 0
    for _ in pairs(_0x4DDE) do _0xB877 = _0xB877 + 1 end
    _0xD16E.LastVisibleCount = _0xB877
end
function _0xD16E.OnPlayerRemoving(_0xCE00)
    local _0x8C41 = _0xD16E.Objects[_0xCE00 and _0xCE00.UserId]
    if _0x8C41 then
        if _0x8C41.Container then pcall(function() _0x8C41.Container:Destroy() end) end
        if _0x8C41.SkeletonLines then
            for _, _0x104C in ipairs(_0x8C41.SkeletonLines) do if _0x104C then pcall(function() _0x104C:Destroy() end) end end
        end
        _0xD16E.Objects[_0xCE00.UserId] = nil
    end
end

-- ============================================================
-- CameraAssist
-- ============================================================
local _0x1996 = {}
_0x1996.Lock = nil _0x1996.Bound = false
_0x1996.BindName = "VEIL_Aim_" .. tostring(math.random(1, 999999))
_0x1996.KeyHeld = false _0x1996.ShuttingDown = false
_0x1996.LastLockUserId = nil
_0x1996.SavedPostFX = {}
_0x1996.MouseAccumX = 0 _0x1996.MouseAccumY = 0
_0x1996.PingEstimate = 0.06 _0x1996.LastPingUpdate = 0
_0x1996.WasScoped = false _0x1996.PreferUserId = nil _0x1996.PreferUntil = 0
_0x1996.MissGrace = 12 _0x1996.DesiredLook = nil _0x1996.LastWrittenCF = nil
_0x1996.CamSignalConn = nil _0x1996.CamSwapConn = nil
_0x1996.WasAirborne = false _0x1996.AirborneUntil = 0
_0x1996.LockedTargetWorldPos = nil
_0x1996.LastLockSwitchTime = 0 _0x1996.AimState = nil _0x1996.AimStateChar = nil
_0x1996.LastFactor = 0 _0x1996.LastEffSmoothing = 0
_0x1996.LastTargetPos = nil _0x1996.LastTargetPosTime = 0
_0x1996._deflectCooldownUntil = 0 _0x1996._deflectCooldownUser = nil
_0x1996.ViewFOVBindName = "VEIL_ViewFOV_" .. tostring(math.random(1, 999999))
_0x1996.ViewFOVBound = false
_0x1996.ControllerFireHeld = false _0x1996.LastInputWasController = false
_0x1996.BlockFireTarget = nil
_0x1996.SavedAutoRotate = nil
_0x1996._preRenderConn = nil
_0x1996._pendingNCF = nil
_0x1996._lastCamWrite = 0
_0x1996._neckJoint = nil
_0x1996._neckC0 = nil

local _0xE0A8 = math.rad(85)
local _0x9546 = math.sin(_0xE0A8)

local function _0x8466(_0x8C41)
    if not _0x8C41 or _0x8C41.Magnitude < 1e-4 then return _0x8C41 end
    _0x8C41 = _0x8C41.Unit
    local _0xF8D5 = math.clamp(_0x8C41.Y, -_0x9546, _0x9546)
    local _0xFC8F = math.sqrt(math.max(0, 1 - _0xF8D5 * _0xF8D5))
    local _0xEB0E = math.sqrt(_0x8C41.X * _0x8C41.X + _0x8C41.Z * _0x8C41.Z)
    if _0xEB0E < 1e-4 then return Vector3.new(0, _0xF8D5, -_0xFC8F) end
    local _0x0404 = _0xFC8F / _0xEB0E
    return Vector3.new(_0x8C41.X * _0x0404, _0xF8D5, _0x8C41.Z * _0x0404)
end
local function _0x0E67(_0xB0D1, dyaw, dpitch)
    if not _0xB0D1 or _0xB0D1.Magnitude < 1e-4 then return _0xB0D1 end
    _0xB0D1 = _0xB0D1.Unit
    local _0xF66B = math.atan2(-_0xB0D1.X, -_0xB0D1.Z)
    local _0xC172 = math.asin(math.clamp(_0xB0D1.Y, -1, 1))
    _0xF66B = _0xF66B + math.rad(dyaw)
    _0xC172 = math.clamp(_0xC172 + math.rad(dpitch), -_0xE0A8, _0xE0A8)
    local _0xD238 = math.cos(_0xC172)
    return Vector3.new(-math.sin(_0xF66B) * _0xD238, math.sin(_0xC172), -math.cos(_0xF66B) * _0xD238).Unit
end
local function _0x56C5(_0x0404, _0x154F)
    if _0x0404 <= 2 then return 1 end
    local _0x245B
    if _0x0404 <= 7 then _0x245B = 8 + (7 - _0x0404) * 4 else _0x245B = 60 / _0x0404 end
    local _0x6EA8 = 1 - math.exp(-_0x245B * _0x154F)
    return math.clamp(_0x6EA8, 0, 1)
end
function _0x1996.BindViewFOV()
    if _0x1996.ViewFOVBound then return end
    _0x1996.ViewFOVBound = true
    pcall(function() _0xB932:UnbindFromRenderStep(_0x1996.ViewFOVBindName) end)
    pcall(function()
        _0xB932:BindToRenderStep(_0x1996.ViewFOVBindName, Enum.RenderPriority.Camera.Value + 10050, function()
            if _0x1996.ShuttingDown then return end
            if not _0x77AD.ViewFOVEnabled then return end
            if _0x1996.Lock then return end
            if _0x1996.WasScoped then return end
            local _0x3A4B = _0x3BA1.CurrentCamera
            if not _0x3A4B then return end
            local _0xD871 = _0x77AD.ViewFOV or 90
            if math.abs(_0x3A4B.FieldOfView - _0xD871) > 0.5 then pcall(function() _0x3A4B.FieldOfView = _0xD871 end) end
        end)
    end)
    _G.__VEIL_viewfov_bind = _0x1996.ViewFOVBindName
end
function _0x1996.UnbindViewFOV()
    if not _0x1996.ViewFOVBound then return end
    _0x1996.ViewFOVBound = false
    pcall(function() _0xB932:UnbindFromRenderStep(_0x1996.ViewFOVBindName) end)
end
function _0x1996.AttachCamWatcher()
    if _0x1996.CamSignalConn then
        pcall(function() _0x1996.CamSignalConn:Disconnect() end)
        _0x1996.CamSignalConn = nil
    end
    local _0x7458 = _0x3BA1.CurrentCamera
    if not _0x7458 then return end
    pcall(function()
        _0x1996.CamSignalConn = _0x7458:GetPropertyChangedSignal("CFrame"):Connect(function()
            if _0x1996.ShuttingDown then return end
            if not _0x1996.Lock then return end
            if not _0x1996.DesiredLook then return end
            local _0x3135 = _0x1996.Lock
            if not _0x3135.Character or not _0x3135.Character.Parent then return end
            local _0x3A64 = _0x7458.CFrame
            if _0x1996.LastWrittenCF and _0x3A64 == _0x1996.LastWrittenCF then return end
            local _0xDF7B, _0x0B43 = pcall(function() return CFrame.lookAt(_0x3A64.Position, _0x3A64.Position + _0x1996.DesiredLook, Vector3.new(0, 1, 0)) end)
            if not _0xDF7B or not _0x0B43 then return end
            _0x1996.LastWrittenCF = _0x0B43
            _0x1996._lastCamWrite = tick()
            pcall(function() _0x7458.CFrame = _0x0B43 end)
        end)
    end)
end
function _0x1996.AttachCameraSwapHook()
    if _0x1996.CamSwapConn then
        pcall(function() _0x1996.CamSwapConn:Disconnect() end)
        _0x1996.CamSwapConn = nil
    end
    pcall(function()
        _0x1996.CamSwapConn = _0x3BA1:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            task.wait(0.05)
            _0x1996.AttachCamWatcher()
        end)
    end)
end
function _0x1996.InitFocusTracking()
    pcall(function()
        _0x55FF.Track(_0xA548.InputChanged:Connect(function(_0xAE2A)
            if _0xAE2A.UserInputType == Enum.UserInputType.MouseMovement then
                _0x1996.MouseAccumX = _0x1996.MouseAccumX + _0xAE2A.Delta.X
                _0x1996.MouseAccumY = _0x1996.MouseAccumY + _0xAE2A.Delta.Y
            end
        end))
    end)
    pcall(function()
        _0x55FF.Track(_0xA548.InputBegan:Connect(function(_0xAE2A)
            if _0x77AD.AimBindType == "Mouse" then
                if _0xAE2A.UserInputType == _0x77AD.AimMouseButton then _0x1996.KeyHeld = true end
            else
                if _0xAE2A.UserInputType == Enum.UserInputType.Keyboard and _0xAE2A.KeyCode == _0x77AD.AimKeyCode then _0x1996.KeyHeld = true end
            end
        end))
    end)
    pcall(function()
        _0x55FF.Track(_0xA548.InputEnded:Connect(function(_0xAE2A)
            if _0x77AD.AimBindType == "Mouse" then
                if _0xAE2A.UserInputType == _0x77AD.AimMouseButton then _0x1996.KeyHeld = false end
            else
                if _0xAE2A.UserInputType == Enum.UserInputType.Keyboard and _0xAE2A.KeyCode == _0x77AD.AimKeyCode then _0x1996.KeyHeld = false end
            end
        end))
    end)
    pcall(function()
        _0x55FF.Track(_0xA548.InputBegan:Connect(function(_0xAE2A)
            local _0xA43F = _0xAE2A.UserInputType
            local _0xDA45 = _0xA43F == Enum.UserInputType.Gamepad1 or _0xA43F == Enum.UserInputType.Gamepad2 or _0xA43F == Enum.UserInputType.Gamepad3 or _0xA43F == Enum.UserInputType.Gamepad4
            if _0xDA45 then
                _0x1996.LastInputWasController = true
                if _0xAE2A.KeyCode == _0x77AD.AimControllerButton then _0x1996.KeyHeld = true end
                if _0xAE2A.KeyCode == _0x77AD.AutoFireControllerButton then _0x1996.ControllerFireHeld = true end
            elseif _0xA43F == Enum.UserInputType.MouseButton1 or _0xA43F == Enum.UserInputType.MouseMovement or _0xA43F == Enum.UserInputType.Keyboard then
                _0x1996.LastInputWasController = false
            end
        end))
    end)
    pcall(function()
        _0x55FF.Track(_0xA548.InputEnded:Connect(function(_0xAE2A)
            local _0xA43F = _0xAE2A.UserInputType
            local _0xDA45 = _0xA43F == Enum.UserInputType.Gamepad1 or _0xA43F == Enum.UserInputType.Gamepad2 or _0xA43F == Enum.UserInputType.Gamepad3 or _0xA43F == Enum.UserInputType.Gamepad4
            if _0xDA45 then
                if _0xAE2A.KeyCode == _0x77AD.AimControllerButton then _0x1996.KeyHeld = false end
                if _0xAE2A.KeyCode == _0x77AD.AutoFireControllerButton then _0x1996.ControllerFireHeld = false end
            end
        end))
    end)
end
function _0x1996.MutePostFX()
    _0x1996.SavedPostFX = {}
    for _, inst in ipairs(_0x18A8:GetChildren()) do
        if inst:IsA("BlurEffect") or inst:IsA("DepthOfFieldEffect") then
            if inst.Enabled then
                _0x1996.SavedPostFX[inst] = true
                pcall(function() inst.Enabled = false end)
            end
        end
    end
end
function _0x1996.RestorePostFX()
    local _0x0404 = _0x1996.SavedPostFX
    _0x1996.SavedPostFX = {}
    for inst, _ in pairs(_0x0404) do if inst and inst.Parent then pcall(function() inst.Enabled = true end) end end
end
function _0x1996.ClearLock()
    if not _0x0E63 and _0x1857 and _0x1857.SetRotation then
        local _0x7458 = _0x3BA1.CurrentCamera
        if _0x7458 then pcall(function() _0x1857:SetRotation(_0x7458.CFrame) end) end
    end
    if _0x1996.Lock and _0x1996.Lock.UserId then
        _0x1996.PreferUserId = _0x1996.Lock.UserId
        _0x1996.PreferUntil = tick() + 0.6
    end
    _0x1996.Lock = nil _0x1996.LastLockUserId = nil
    _0x1996.DesiredLook = nil _0x1996.LastWrittenCF = nil
    _0x1996.LockedTargetWorldPos = nil _0x1996.AimState = nil _0x1996.AimStateChar = nil
    _0x1996.LastTargetPos = nil _0x1996.LastTargetPosTime = 0
    _0x1996._pendingNCF = nil
    task.defer(function()
        pcall(function()
            local _0x1A90 = _0xE1FF.LocalPlayer
            local _0x7B5B = _0x1A90 and _0x1A90.Character
            if _0x7B5B then
                local _0x44C9 = _0x7B5B:FindFirstChildOfClass("Humanoid")
                local _0xE174 = _0x7B5B:FindFirstChild("HumanoidRootPart")
                if _0x44C9 and _0x1996.SavedAutoRotate ~= nil then
                    _0x44C9.AutoRotate = _0x1996.SavedAutoRotate
                    _0x1996.SavedAutoRotate = nil
                end
                if _0xE174 then
                    local _0x8377 = _0xE174:FindFirstChild("VEIL_AimGyro")
                    if _0x8377 then _0x8377:Destroy() end
                end
            end
        end)
    end)
end
function _0x1996.IsTargetSticky(_0x3135)
    if not _0x3135 or not _0x3135.Character or not _0x3135.Character.Parent then return false end
    local _0x7458 = _0x3BA1.CurrentCamera
    if not _0x7458 then return true end
    local _0x3694 = _0xC036.GetHitboxPosition(_0x3135.Character, _0x3135.ResolvedHitbox, _0x3135.HitboxPart)
    if not _0x3694 then return false end
    local _0xE958 = _0x7458.CFrame.Position
    local _0x44BC = _0x7458.CFrame.LookVector
    local _0x270D = _0x3694 - _0xE958
    local _0xAFA9 = _0x270D.Magnitude
    if _0xAFA9 < 0.1 then return true end
    local _0xB0D1 = _0x270D / _0xAFA9
    local _0x920D = math.deg(math.acos(math.clamp(_0x44BC:Dot(_0xB0D1), -1, 1)))
    local _0xFEB3 = _0x77AD.SilentAimEnabled
    local _0x8818 = _0xFEB3 and (_0x77AD.SilentAimFOV or 200) or (_0x77AD.CameraAssistFOV or 35)
    local _0x3990 = 1.0 - (math.min(_0x77AD.CameraAssistSmoothing or 0, 20) / 20) * 0.5
    local _0xC23D = math.max(_0x8818 * 0.9, 18) * 1.6 * _0x3990
    if _0xC036.IsLocalAirborne() then _0xC23D = _0xC23D * 2.2 end
    return _0x920D <= _0xC23D
end
function _0x1996.MakeLock(_0xB680, resolvedMode)
    local _0x4950 = _0x77AD.SilentAimEnabled
    local _0xB645 = _0x4950 and (_0x77AD.SilentAimHitbox or "Head") or (_0x77AD.CameraAssistHitboxMode or "Head")
    local _0xBE70 = resolvedMode or _0xC036.ResolveHitboxMode(_0xB645)
    local _0x3694, _0x7AA7 = _0xC036.GetHitboxPosition(_0xB680.Character, _0xBE70)
    if _0x3694 and _0xBE70 == "Head" and _0x6B84 ~= 0 then
        _0x3694 = _0x3694 + Vector3.new(0, _0x6B84, 0)
    end
    local _0x17DA = tick()
    return { UserId = _0xB680.UserId, Player = _0xB680.Player, Character = _0xB680.Character,
             UserMode = _0xB645, ResolvedHitbox = _0xBE70, HitboxPart = _0x7AA7,
             LastPos = _0x3694, LastPosTime = _0x3694 and _0x17DA or 0, Visible = true, MissFrames = 0,
             FirstLockTime = _0x17DA }
end
function _0x1996.UpdateLock(_0x3135)
    if not _0x3135 then return false end
    local _0x4950 = _0x77AD.SilentAimEnabled
    local _0x0372 = _0x4950 and (_0x77AD.SilentAimHitbox or "Head") or (_0x77AD.CameraAssistHitboxMode or "Head")
    if _0x3135.UserMode ~= _0x0372 then return false end
    local _0x938C = _0x3135.Player
    if not _0x938C or not _0x938C.Parent then return false end
    local _0x3A4B = _0x3135.Character
    if not _0x3A4B or not _0x3A4B.Parent then return false end
    local _0x830D = _0x3A4B:FindFirstChildOfClass("Humanoid")
    if not _0x830D or _0x830D.Health <= 0 then return false end
    if _0xC036.IsTargetDeflecting(_0x938C) then
        _0x1996._deflectCooldownUntil = tick() + 0.40
        _0x1996._deflectCooldownUser = _0x938C.UserId
        return false
    end
    if _0x1996._deflectCooldownUser == _0x938C.UserId and tick() < (_0x1996._deflectCooldownUntil or 0) then
        return false
    end
    if _0x3135.HitboxPart and _0x3135.HitboxPart.Parent then
        local _0x089E = _0xC036.HitboxModes[_0x3135.ResolvedHitbox] or _0xC036.HitboxModes.Head
        local _0xC317 = false
        for _, _0xB877 in ipairs(_0x089E) do if _0x3135.HitboxPart.Name == _0xB877 then _0xC317 = true break end end
        if not _0xC317 then _0x3135.HitboxPart = nil end
    else
        _0x3135.HitboxPart = nil
    end
    local _0x3694, _0x7AA7 = _0xC036.GetHitboxPosition(_0x3A4B, _0x3135.ResolvedHitbox, _0x3135.HitboxPart)
    if _0x3694 then
        if _0x3135.ResolvedHitbox == "Head" and _0x6B84 ~= 0 then
            _0x3694 = _0x3694 + Vector3.new(0, _0x6B84, 0)
        end
        _0x3135.LastPos = _0x3694 _0x3135.LastPosTime = tick()
        if _0x7AA7 then _0x3135.HitboxPart = _0x7AA7 end
    end
    if _0x77AD.CameraAssistVisibleCheck and _0x3135.LastPos then
        _0x3135.Visible = _0xC036.IsPositionVisible(_0x3135.LastPos, {_0x3A4B}, tostring(_0x3135.UserId), _0x3135.HitboxPart)
    else _0x3135.Visible = true end
    return true
end
function _0x1996.AcquireLock()
    if _0x77AD.LobbyGuardEnabled and not _0xC036.IsInGame() then return nil end
    local _0x7458 = _0x3BA1.CurrentCamera
    if not _0x7458 or not _0x7458.Parent then return nil end
    local _0x5B90 = _0x7458.ViewportSize.X * 0.5
    local _0xD238 = _0x7458.ViewportSize.Y * 0.5
    local _0x9649 = _0xC036.ViewportScale()
    local _0x4950 = _0x77AD.SilentAimEnabled
    local _0x8818 = _0x4950 and (_0x77AD.SilentAimFOV or 200) or (_0x77AD.CameraAssistFOV or 35)
    local _0x824F = math.max(_0x8818 * 10 * _0x9649, 110 * _0x9649)
    if not _0x4950 then
        local _0xB0D5 = (_0x77AD.CameraAssistAcquisitionRadius or 300) * _0x9649
        if _0xB0D5 > 0 and _0x824F > _0xB0D5 then _0x824F = _0xB0D5 end
    end
    local _0x819D = _0x824F * _0x824F
    local _0x7112 = _0x1996.PreferUserId
    local _0x8015 = _0x7112 and tick() < (_0x1996.PreferUntil or 0)
    local _0xB29F = (_0x824F * 1.8) * (_0x824F * 1.8)
    local _0x26C9, _0xC10D = nil, math.huge
    local _0x70B7, _0x5E21 = nil, math.huge
    local _0xBBA2, _0xC733 = nil, nil
    local _0xC1D0 = _0x4950 and (_0x77AD.SilentAimHitbox or "Head") or (_0x77AD.CameraAssistHitboxMode or "Head")
    local _0x40C2 = nil
    if _0x4950 then
        local _0xD753 = _0xE1FF.LocalPlayer and _0xE1FF.LocalPlayer.Character
        if _0xD753 then
            local _0x3FCC = _0xD753:FindFirstChild("HumanoidRootPart")
            if _0x3FCC then _0x40C2 = _0x3FCC.Position end
        end
    end
    for _, _0xB680 in ipairs(_0xC036.GetValidPlayers()) do
        local _0x3A4B = _0xB680.Character
        if _0x3A4B and _0x3A4B.Parent then
            local _0x1215 = false
            if _0x1996._deflectCooldownUser == _0xB680.UserId and tick() < (_0x1996._deflectCooldownUntil or 0) then
                _0x1215 = true
            elseif _0xC036.IsTargetDeflecting(_0xB680.Player) then _0x1215 = true end
            if not _0x1215 then
                local _0xE060 = _0xC1D0
                if _0xC1D0 == "Random" then _0xE060 = _0xC036.ResolveHitboxMode("Random") end
                local _0x3694, _0x7AA7 = _0xC036.GetHitboxPosition(_0x3A4B, _0xE060)
                if _0x3694 then
                    local _0x5D8C = true
                    if _0x77AD.CameraAssistVisibleCheck and not _0x4950 then
                        if not _0xC036.IsPositionVisible(_0x3694, {_0x3A4B}, nil, _0x7AA7) then _0x5D8C = false end
                    end
                    if _0x5D8C then
                        local _0xF894, _0x0207 = _0xC036.WorldToViewport(_0x3694)
                        if _0x0207 then
                            local _0x2912 = _0xF894.X - _0x5B90
                            local _0x4CC4 = _0xF894.Y - _0xD238
                            local _0x69E4 = _0x2912 * _0x2912 + _0x4CC4 * _0x4CC4
                            if _0x69E4 <= _0x819D then
                                if _0x4950 and _0x40C2 then
                                    local _0x06E6 = (_0x3694 - _0x40C2).Magnitude
                                    local _0x538A = _0x06E6 * _0x06E6
                                    if _0x8015 and _0xB680.UserId == _0x7112 and _0x69E4 <= _0xB29F then
                                        if _0x538A < _0x5E21 then _0x5E21 = _0x538A _0x70B7 = _0xB680 _0xC733 = _0xE060 end
                                    end
                                    if _0x538A < _0xC10D then _0xC10D = _0x538A _0x26C9 = _0xB680 _0xBBA2 = _0xE060 end
                                else
                                    if _0x8015 and _0xB680.UserId == _0x7112 and _0x69E4 <= _0xB29F then
                                        if _0x69E4 < _0x5E21 then _0x5E21 = _0x69E4 _0x70B7 = _0xB680 _0xC733 = _0xE060 end
                                    end
                                    if _0x69E4 < _0xC10D then _0xC10D = _0x69E4 _0x26C9 = _0xB680 _0xBBA2 = _0xE060 end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if _0x70B7 then _0x26C9 = _0x70B7 _0xBBA2 = _0xC733 end
    if not _0x26C9 then return nil end
    if _0x4950 and not _0x1996.Lock then
        local _0xB576 = math.clamp(_0x77AD.SilentAimHitChance or 100, 0, 100)
        if _0xB576 < 100 and math.random() * 100 > _0xB576 then return nil end
    end
    return _0x1996.MakeLock(_0x26C9, _0xBBA2)
end
function _0x1996.FindCloserTarget(_0x3060)
    if not _0x77AD.CameraAssistFOVPriority or not _0x3060 then return nil end
    if tick() - (_0x1996.LastLockSwitchTime or 0) < 0.1 then return nil end
    local _0x7458 = _0x3BA1.CurrentCamera
    if not _0x7458 or not _0x7458.Parent then return nil end
    local _0x5B90 = _0x7458.ViewportSize.X * 0.5
    local _0xD238 = _0x7458.ViewportSize.Y * 0.5
    local _0x9649 = _0xC036.ViewportScale()
    local _0x824F = math.max(_0x77AD.CameraAssistFOV * 10 * _0x9649, 110 * _0x9649)
    local _0xB0D5 = (_0x77AD.CameraAssistAcquisitionRadius or 300) * _0x9649
    if _0xB0D5 > 0 and _0x824F > _0xB0D5 then _0x824F = _0xB0D5 end
    local _0x819D = _0x824F * _0x824F
    local _0xC1D0 = _0x77AD.CameraAssistHitboxMode or "Head"
    local _0x419A = math.huge
    if _0x3060.Character and _0x3060.Character.Parent then
        local _0x3694 = _0xC036.GetHitboxPosition(_0x3060.Character, _0x3060.ResolvedHitbox, _0x3060.HitboxPart)
        if _0x3694 then
            local _0xF894, _0x0207 = _0xC036.WorldToViewport(_0x3694)
            if _0x0207 then
                local _0x2912 = _0xF894.X - _0x5B90
                local _0x4CC4 = _0xF894.Y - _0xD238
                _0x419A = _0x2912 * _0x2912 + _0x4CC4 * _0x4CC4
            end
        end
    end
    local _0x26C9, _0xC10D, _0xBBA2 = nil, math.huge, nil
    for _, _0xB680 in ipairs(_0xC036.GetValidPlayers()) do
        if _0xB680.UserId ~= _0x3060.UserId then
            local _0x3A4B = _0xB680.Character
            if _0x3A4B and _0x3A4B.Parent then
                local _0x3694, _0x7AA7 = _0xC036.GetHitboxPosition(_0x3A4B, _0xC1D0)
                if _0x3694 then
                    local _0x5D8C = true
                    if _0x77AD.CameraAssistVisibleCheck then
                        if not _0xC036.IsPositionVisible(_0x3694, {_0x3A4B}, nil, _0x7AA7) then _0x5D8C = false end
                    end
                    if _0x5D8C then
                        local _0xF894, _0x0207 = _0xC036.WorldToViewport(_0x3694)
                        if _0x0207 then
                            local _0x2912 = _0xF894.X - _0x5B90
                            local _0x4CC4 = _0xF894.Y - _0xD238
                            local _0x69E4 = _0x2912 * _0x2912 + _0x4CC4 * _0x4CC4
                            if _0x69E4 <= _0x819D and _0x69E4 < _0xC10D then _0xC10D = _0x69E4 _0x26C9 = _0xB680 _0xBBA2 = _0xC1D0 end
                        end
                    end
                end
            end
        end
    end
    if _0x26C9 and _0xC10D < _0x419A * 0.90 then return _0x1996.MakeLock(_0x26C9, _0xBBA2) end
    return nil
end
function _0x1996.Apply(_0x154F)
    if _0x1996.ShuttingDown then return end
    if not _0x77AD.CameraAssistEnabled and not _0x77AD.SilentAimEnabled then return end
    if not _0x0E63 and not _0x1857 then
        pcall(function()
            local _0x1A90 = _0xE1FF.LocalPlayer
            if not _0x1A90 then return end
            local _0xA21A = _0x1A90:FindFirstChild("PlayerScripts")
            if not _0xA21A then return end
            local _0xBC37 = _0xA21A:FindFirstChild("PlayerModule")
            if not _0xBC37 then return end
            local _0x4D37 = require(_0xBC37)
            if _0x4D37 and _0x4D37.GetControls then
                _0x1857 = _0x4D37:GetControls()
                _G.__VEIL_CamControls = _0x1857
            end
        end)
    end
    local _0xBDC8 = _0x1996.MouseAccumX or 0
    local _0x31AD = _0x1996.MouseAccumY or 0
    _0x1996.MouseAccumX = 0 _0x1996.MouseAccumY = 0
    local _0x27F4 = _0xC036.IsLocalAirborne()
    if _0x27F4 then _0x1996.AirborneUntil = tick() + 0.35 end
    local _0xE95E = _0x27F4 or tick() < (_0x1996.AirborneUntil or 0)
    local _0x2E25 = _0x1996.KeyHeld or (_0x77AD.CameraAssistAlwaysOn and _0x77AD.CameraAssistEnabled)
    local _0xF875 = false
    pcall(function() _0xF875 = _0xA548:GetFocusedTextBox() ~= nil end)
    if _0xF875 then _0x2E25 = false end
    local _0x7458 = _0x3BA1.CurrentCamera
    if not _0x7458 or not _0x7458.Parent then return end
    local _0x1A90 = _0xE1FF.LocalPlayer
    local _0x7B5B = _0x1A90 and _0x1A90.Character
    if not _0x7B5B or not _0x7B5B.Parent then return end
    if _0x77AD.LobbyGuardEnabled and not _0xC036.IsInGame() then
        if _0x1996.Lock then _0x1996.ClearLock() end
        if next(_0x1996.SavedPostFX) then _0x1996.RestorePostFX() end
        _0x1996.AimState = nil _0x1996.AimStateChar = nil _0x1996.BlockFireTarget = nil
        return
    end
    local _0x4422 = _0x7B5B:FindFirstChildOfClass("Humanoid")
    local _0x1AF0 = _0x7458.CameraSubject
    local _0x26C5 = false
    if not _0x4422 or _0x4422.Health <= 0 then _0x26C5 = true
    elseif _0x1AF0 and _0x1AF0:IsA("Humanoid") and _0x1AF0 ~= _0x4422 then _0x26C5 = true end
    if _0x26C5 then
        if _0x1996.Lock then _0x1996.ClearLock() end
        if next(_0x1996.SavedPostFX) then _0x1996.RestorePostFX() end
        _0x1996.DesiredLook = nil _0x1996.LastWrittenCF = nil _0x1996.BlockFireTarget = nil
        return
    end
    if _0x1996.Lock and _0x1996.Lock.Player then
        local _0x3196 = _0x1996.Lock.Player
        if _0xC036.IsTargetDeflecting(_0x3196) then
            _0x1996._deflectCooldownUntil = tick() + 0.40
            _0x1996._deflectCooldownUser = _0x3196.UserId
            _0x1996.ClearLock()
            _0x1996.AimState = nil _0x1996.AimStateChar = nil
            _0x1996.BlockFireTarget = nil _0x1996.DesiredLook = nil _0x1996.LastWrittenCF = nil
            return
        end
        if _0x1996._deflectCooldownUser == _0x3196.UserId and tick() < (_0x1996._deflectCooldownUntil or 0) then
            _0x1996.DesiredLook = nil _0x1996.LastWrittenCF = nil _0x1996.BlockFireTarget = nil
            return
        end
    end
    local _0x2060 = false
    local _0xA93D = _0x7458.FieldOfView
    if _0xA93D and _0xA93D >= 5 then
        local _0xF822 = tick()
        if _0xA93D > _0xC036.RecentMaxFOV then _0xC036.RecentMaxFOV = _0xA93D _0xC036.RecentMaxFOVTime = _0xF822
        elseif (_0xF822 - _0xC036.RecentMaxFOVTime) > 2.0 then
            _0xC036.RecentMaxFOV = math.max(_0xC036.RecentMaxFOV * 0.997, 40)
            _0xC036.RecentMaxFOVTime = _0xF822
        end
        local _0x33FF = math.max(_0xC036.RecentMaxFOV, 40)
        if _0x1996.WasScoped then _0x2060 = _0xA93D < (_0x33FF * 0.92) else _0x2060 = _0xA93D < (_0x33FF * 0.80) end
    end
    _0x1996.WasScoped = _0x2060
    if _0xC036.IsReloading() then
        if _0x1996.Lock then _0x1996.ClearLock() end
        _0x1996.AimState = nil _0x1996.AimStateChar = nil _0x1996.BlockFireTarget = nil
        return
    end
    if not _0x2E25 then
        if _0x1996.Lock then _0x1996.ClearLock() end
        if next(_0x1996.SavedPostFX) then _0x1996.RestorePostFX() end
        _0x1996.LockedTargetWorldPos = nil _0x1996.AimState = nil
        _0x1996.AimStateChar = nil _0x1996.BlockFireTarget = nil
        return
    end
    if _0x77AD.CameraAssistFOVPriority and _0x1996.Lock and not _0xE95E and not _0x77AD.SilentAimEnabled then
        local _0x3060 = _0x1996.FindCloserTarget(_0x1996.Lock)
        if _0x3060 then
            _0x1996.Lock = _0x3060
            _0x1996.AimState = nil _0x1996.AimStateChar = nil
            _0x1996.LastLockSwitchTime = tick()
            _0x1996.UpdateLock(_0x3060)
        end
    end
    if _0x1996.Lock then
        local _0x3135 = _0x1996.Lock
        local _0x8C41 = _0x1996.UpdateLock(_0x3135)
        if not _0x8C41 then _0x1996.ClearLock()
        else
            local _0x48A3 = _0x1996.IsTargetSticky(_0x3135)
            local _0x8180 = false
            if _0x77AD.CameraAssistVisibleCheck and _0x3135.Visible == false then _0x8180 = true end
            if _0x48A3 and not _0x8180 then _0x3135.MissFrames = 0
            else
                if _0xE95E then _0x3135.MissFrames = 0 _0x3135.Visible = true
                else
                    _0x1996.DesiredLook = nil
                    _0x3135.MissFrames = (_0x3135.MissFrames or 0) + 1
                    local _0x942D = _0x1996.MissGrace
                    if (_0x77AD.CameraAssistSmoothing or 8) <= 4 then _0x942D = _0x942D + 6 end
                    if _0x3135.MissFrames > (_0x8180 and 4 or _0x942D) then _0x1996.ClearLock() end
                end
            end
        end
    end
    if not _0x1996.Lock then
        local _0x7C5C = _0x1996.AcquireLock()
        if _0x7C5C then
            _0x1996.Lock = _0x7C5C
            _0x1996.LastLockUserId = _0x7C5C.UserId
            _0x1996.AimState = nil _0x1996.AimStateChar = nil
            _0x1996.LastLockSwitchTime = tick()
            _0x1996.MutePostFX()
            _0x1996.UpdateLock(_0x7C5C)
        end
        if not _0x1996.Lock then
            _0x1996.DesiredLook = nil _0x1996.LastWrittenCF = nil
            _0x1996.LockedTargetWorldPos = nil _0x1996.AimState = nil
            _0x1996.AimStateChar = nil _0x1996.BlockFireTarget = nil
            if next(_0x1996.SavedPostFX) then _0x1996.RestorePostFX() end
            return
        end
    end
    local _0x3135 = _0x1996.Lock
    if not _0x3135 or not _0x3135.LastPos then return end
    local _0x3A4B = _0x3135.Character
    if not _0x3A4B or not _0x3A4B.Parent then
        _0x1996.ClearLock() _0x1996.BlockFireTarget = nil
        return
    end
    _0x1996.BlockFireTarget = _0x3135.Player
    if _0x3135.LastPos then _0x1996.LockedTargetWorldPos = _0x3135.LastPos end
    local _0x3E2F = _0x7458.CFrame
    local _0xE958 = _0x3E2F.Position
    if not _0xC036.IsValidVector(_0xE958) then return end
    local _0x4402 = _0x3E2F.LookVector
    if not _0xC036.IsValidVector(_0x4402) or _0x4402.Magnitude < 1e-4 then _0x4402 = Vector3.new(0, 0, -1) end
    _0x4402 = _0x4402.Unit
    if not _0x1996.AimState or _0x1996.AimStateChar ~= _0x3A4B then
        _0x1996.AimState = _0x8466(_0x4402)
        _0x1996.AimStateChar = _0x3A4B
    end
    local _0xF12D = _0x77AD.CameraAssistUseMouseWhileLocking == true
        and (_0x77AD.CameraAssistSmoothing or 8) > 3
    if _0xF12D and (_0xBDC8 ~= 0 or _0x31AD ~= 0) then
        _0x4402 = _0x0E67(_0x4402, -_0xBDC8 * 0.15, -_0x31AD * 0.15)
    end
    local _0x17DA = tick()
    if not _0x0E63 and _0x17DA - (_0x1996.LastPingUpdate or 0) > 3.0 then
        _0x1996.LastPingUpdate = _0x17DA
        pcall(function()
            local _0x8F06 = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
            if _0x8F06 and _0x8F06 > 0 then _0x1996.PingEstimate = math.clamp(_0x8F06 / 1000, 0.02, 0.20) end
        end)
    end
    local _0xE96E = _0x3135.LastPos
    local _0x41E5 = 0
    local _0xAD19 = nil
    local _0x1582 = _0x3A4B:FindFirstChild("HumanoidRootPart")
    if _0x1582 then
        pcall(function() _0xAD19 = _0x1582.AssemblyLinearVelocity end)
        if not _0xAD19 then pcall(function() _0xAD19 = _0x1582.Velocity end) end
        if _0xAD19 and _0xC036.IsValidVector(_0xAD19) then _0x41E5 = _0xAD19.Magnitude end
        if _0x41E5 < 0.5 then
            local _0x55F2 = _0x1582.Position
            if _0x1996.LastTargetPos and _0x1996.LastTargetPosTime > 0 then
                local _0x5F42 = _0x17DA - _0x1996.LastTargetPosTime
                if _0x5F42 > 0.001 and _0x5F42 < 0.5 then
                    local _0xBE78 = (_0x55F2 - _0x1996.LastTargetPos) / _0x5F42
                    if _0xC036.IsValidVector(_0xBE78) then _0xAD19 = _0xBE78 _0x41E5 = _0xBE78.Magnitude end
                end
            end
            _0x1996.LastTargetPos = _0x55F2 _0x1996.LastTargetPosTime = _0x17DA
        else
            _0x1996.LastTargetPos = _0x1582.Position _0x1996.LastTargetPosTime = _0x17DA
        end
    end
    local _0xD330 = _0x77AD.CameraAssistPrediction and (_0x77AD.CameraAssistSmoothing or 8) > 3
    if _0xD330 and _0xAD19 and _0x41E5 > 4 then
        local _0xAFA9 = (_0xE96E - _0xE958).Magnitude
        local _0x90B2 = math.max(_0x77AD.CameraAssistBulletSpeed or 400, 50)
        local _0xD8B4 = math.clamp(_0x1996.PingEstimate or 0.06, 0, 0.15) * 0.5
        local _0x159E = math.max(_0x77AD.CameraAssistLead or 0.02, 0)
        local _0x5D38 = math.min(_0xAFA9 / _0x90B2 + _0x159E + _0xD8B4, 0.25)
        local _0x3FCF = Vector3.new(_0xAD19.X, 0, _0xAD19.Z) * _0x5D38
        local _0x7546 = math.min(2.0, _0xAFA9 * 0.25)
        if _0x3FCF.Magnitude > _0x7546 then _0x3FCF = _0x3FCF.Unit * _0x7546 end
        _0xE96E = _0xE96E + _0x3FCF
    end
    local _0x7ACC = _0xE96E - _0xE958
    local _0xF10C = _0x7ACC.Magnitude
    if _0xF10C < 0.01 then return end
    _0x7ACC = _0x7ACC.Unit
    local _0x8AF2 = _0x77AD.CameraAssistSmoothing or 0
    if _0x2060 then _0x8AF2 = _0x8AF2 / math.max(_0x77AD.CameraAssistScopeSpeed or 1.0, 0.1) end
    local _0xFA10 = _0xF12D and _0x4402 or (_0x1996.AimState or _0x4402)
    local _0x920D = math.deg(math.acos(math.clamp(_0xFA10:Dot(_0x7ACC), -1, 1)))
    local _0x2B1D = _0x6806
    if _0x3135.ResolvedHitbox == "Head" then _0x2B1D = _0x2B1D * 0.30 end
    local _0xF7B4 = _0x77AD.CameraAssistSmoothing or 8
    if _0xF7B4 <= 4 then _0x2B1D = _0x2B1D * 0.25 elseif _0xF7B4 <= 8 then _0x2B1D = _0x2B1D * 0.55 end
    local _0x744D = 1 / (1 + _0xF10C / 150)
    if _0x77AD.SilentAimTightDeadzone then _0x744D = _0x744D * 0.55 end
    local _0x6ED4 = _0x2B1D * (1 + math.clamp(_0xF10C / 500, 0, 1) * 0.4) * _0x744D
    if _0x6ED4 < 0.015 then _0x6ED4 = 0.015 end
    local _0x1215 = _0x77AD.CameraAssistVisibleCheck and _0x3135.Visible == false and not _0xE95E
    local _0xB2B3
    if _0x1215 or _0x920D < _0x6ED4 then _0xB2B3 = _0xFA10
    else
        local _0x33FF = _0x56C5(_0x8AF2, _0x154F) * (_0x77AD.CameraAssistMouseSensitivity or 1) * 2.2
        local _0x274D = 1 + math.clamp(_0xF10C / 200, 0, 1) * (_0x77AD.SilentAimDistanceBoost or 1.0) * 0.9
        _0x33FF = _0x33FF * _0x274D
        if _0x77AD.SilentAimConvergenceSnap then
            local _0x04BD = math.max(_0x6ED4 * 2.0, 1.5)
            if _0x920D < _0x04BD then _0x33FF = 1 end
        end
        local _0x918A = tick() - (_0x3135.FirstLockTime or 0)
        if _0xF10C > 150 and _0x918A < 0.35 and _0x33FF < 0.75 then _0x33FF = 0.75 end
        local _0x6EA8 = math.clamp(_0x33FF, 0, 1)
        _0x1996.LastFactor = _0x6EA8 _0x1996.LastEffSmoothing = _0x8AF2
        if _0x6EA8 >= 1 then _0xB2B3 = _0x7ACC
        else
            local _0x5BCC = _0xFA10:Lerp(_0x7ACC, _0x6EA8)
            _0xB2B3 = (_0x5BCC.Magnitude > 1e-4) and _0x5BCC.Unit or _0x7ACC
        end
    end
    _0x1996.AimState = _0x8466(_0xB2B3)
    if _0x1215 then
        _0x1996.DesiredLook = nil _0x1996.LastWrittenCF = nil
        return
    end
    local _0xF96F = _0x1996.AimState
    if not _0xF96F or _0xF96F.Magnitude < 1e-4 then return end
    _0xF96F = _0x8466(_0xF96F.Unit)
    _0x1996.DesiredLook = _0xF96F
    if _0x77AD.CameraAssistRotateChar and not _0x27F4 then
        local _0xE174 = _0x7B5B:FindFirstChild("HumanoidRootPart")
        local _0x44C9 = _0x7B5B:FindFirstChildOfClass("Humanoid")
        if _0xE174 and _0x44C9 then
            local _0x0D30 = Vector3.new(_0xF96F.X, 0, _0xF96F.Z)
            if _0x0D30.Magnitude > 0.001 then
                _0x0D30 = _0x0D30.Unit
                local _0x7D73 = math.atan2(-_0x0D30.X, -_0x0D30.Z)
                pcall(function()
                    if _0x1996.SavedAutoRotate == nil then
                        _0x1996.SavedAutoRotate = _0x44C9.AutoRotate
                    end
                    local _0xCA88 = _0x44C9.MoveDirection.Magnitude > 0.1
                    if _0xCA88 then
                        _0x44C9.AutoRotate = true
                    else
                        _0x44C9.AutoRotate = false
                        local _0x8377 = _0xE174:FindFirstChild("VEIL_AimGyro")
                        if _0x8377 then _0x8377:Destroy() end
                        local _0xD617 = math.atan2(-_0xE174.CFrame.LookVector.X, -_0xE174.CFrame.LookVector.Z)
                        local _0x4CC4 = math.atan2(math.sin(_0x7D73 - _0xD617), math.cos(_0x7D73 - _0xD617))
                        local _0xC64D = _0x77AD.CameraAssistSmoothing or 8
                        local _0x7AC4
                        if _0xC64D <= 1 then _0x7AC4 = math.rad(180)
                        elseif _0xC64D <= 3 then _0x7AC4 = math.rad(90)
                        elseif _0xC64D <= 7 then _0x7AC4 = math.rad(45)
                        elseif _0xC64D <= 12 then _0x7AC4 = math.rad(25)
                        else _0x7AC4 = math.rad(15) end
                        _0x4CC4 = math.clamp(_0x4CC4, -_0x7AC4, _0x7AC4)
                        local _0x5B8A = _0xD617 + _0x4CC4
                        _0xE174.CFrame = CFrame.new(_0xE174.Position.X, _0xE174.Position.Y, _0xE174.Position.Z) * CFrame.Angles(0, _0x5B8A, 0)
                    end
                    local _0xAC0E = _0x7B5B:FindFirstChild("Head")
                    local _0xFD61 = _0xAC0E and _0xAC0E:FindFirstChild("Neck")
                    if not _0xFD61 then
                        local _0x3970 = _0x7B5B:FindFirstChild("UpperTorso")
                        if _0x3970 then _0xFD61 = _0x3970:FindFirstChild("Neck") end
                    end
                    if _0xFD61 then
                        if _0x1996._neckJoint ~= _0xFD61 then
                            _0x1996._neckJoint = _0xFD61
                            _0x1996._neckC0 = _0xFD61.C0
                        end
                        if _0x1996._neckC0 then
                            local _0xC172 = math.asin(math.clamp(_0xF96F.Y, -1, 1))
                            _0xFD61.C0 = _0x1996._neckC0 * CFrame.Angles(-_0xC172, 0, 0)
                        end
                    end
                end)
            end
        end
    else
        pcall(function()
            local _0xE174 = _0x7B5B:FindFirstChild("HumanoidRootPart")
            local _0x44C9 = _0x7B5B:FindFirstChildOfClass("Humanoid")
            if _0xE174 then
                local _0x8377 = _0xE174:FindFirstChild("VEIL_AimGyro")
                if _0x8377 then _0x8377:Destroy() end
            end
            if _0x44C9 and _0x1996.SavedAutoRotate ~= nil then
                _0x44C9.AutoRotate = _0x1996.SavedAutoRotate
                _0x1996.SavedAutoRotate = nil
            end
        end)
    end
    local _0xAAE6
    local _0xDF7B, _0xBE70 = pcall(function() return CFrame.lookAt(_0xE958, _0xE958 + _0xF96F, Vector3.new(0, 1, 0)) end)
    if _0xDF7B and _0xBE70 then _0xAAE6 = _0xBE70 else _0xAAE6 = CFrame.new(_0xE958, _0xE958 + _0xF96F) end
    _0x1996.LastWrittenCF = _0xAAE6
    _0x1996._lastCamWrite = tick()
    if not _0x0E63 then
        pcall(function() _0x7458.CFrame = _0xAAE6 end)
        if _0x1857 and _0x1857.SetRotation then
            pcall(function() _0x1857:SetRotation(_0xAAE6) end)
        end
    else
        _0x1996._pendingNCF = _0xAAE6
    end
end
function _0x1996.Bind()
    if _0x1996.Bound then return end
    _0x1996.Bound = true
    pcall(function() _0xB932:UnbindFromRenderStep(_0x1996.BindName) end)
    pcall(function()
        _0xB932:BindToRenderStep(_0x1996.BindName, Enum.RenderPriority.Camera.Value + 10000, function(_0x154F)
            if _0x1996.ShuttingDown then return end
            pcall(function() _0x1996.Apply(_0x154F) end)
        end)
    end)
    if _0x0E63 and not _0x1996._preRenderConn then
        pcall(function()
            _0x1996._preRenderConn = _0xB932.PreRender:Connect(function()
                if _0x1996.ShuttingDown then return end
                if not _0x1996.Lock then return end
                if not _0x1996.DesiredLook then return end
                local _0x7458 = _0x3BA1.CurrentCamera
                if not _0x7458 or not _0x7458.Parent then return end
                local _0x3694 = _0x7458.CFrame.Position
                if not _0xC036.IsValidVector(_0x3694) then return end
                local _0xDF7B, _0x0B43 = pcall(function() return CFrame.lookAt(_0x3694, _0x3694 + _0x1996.DesiredLook, Vector3.new(0, 1, 0)) end)
                if not _0xDF7B or not _0x0B43 then return end
                _0x1996.LastWrittenCF = _0x0B43
                _0x1996._lastCamWrite = tick()
                pcall(function() _0x7458.CFrame = _0x0B43 end)
            end)
        end)
    end
    _0x1996.AttachCamWatcher()
    _0x1996.AttachCameraSwapHook()
    _G.__VEIL_last_bind = _0x1996.BindName
end
function _0x1996.Unbind()
    if not _0x1996.Bound then return end
    _0x1996.Bound = false
    pcall(function() _0xB932:UnbindFromRenderStep(_0x1996.BindName) end)
    if _0x1996.CamSignalConn then pcall(function() _0x1996.CamSignalConn:Disconnect() end) _0x1996.CamSignalConn = nil end
    if _0x1996.CamSwapConn then pcall(function() _0x1996.CamSwapConn:Disconnect() end) _0x1996.CamSwapConn = nil end
    if _0x1996._preRenderConn then
        pcall(function() _0x1996._preRenderConn:Disconnect() end)
        _0x1996._preRenderConn = nil
    end
end
_G.__VEIL_CameraAssist = _0x1996

local function _0x6E17()
    task.spawn(function()
        while true do
            task.wait(0.75)
            if _0x1996.ShuttingDown then return end
            if _0x77AD.WeaponProfilesEnabled and _0x77AD.WeaponAutoDetect then
                local _0xD108, _0xC99D = _0x11FD()
                if _0xD108 ~= _0x51E5 then
                    _0x9CA3()
                    _0x51E5 = _0xD108
                    _0xA561(_0xD108)
                    if _G.__VEIL_WeaponChanged then pcall(_G.__VEIL_WeaponChanged, _0xD108, _0xC99D) end
                end
            end
        end
    end)
end
_0x6E17()

-- ============================================================
-- AutoFire
-- ============================================================
local _0x034E = {}
_0x034E.LastFireTime = 0 _0x034E.IsFiring = false _0x034E.FireStart = 0
_0x034E.KeyHeld = false
function _0x034E.RaycastCheck()
    if _0x77AD.LobbyGuardEnabled and not _0xC036.IsInGame() then return nil end
    local _0x7458 = _0x3BA1.CurrentCamera
    if not _0x7458 then return nil end
    local _0x1A90 = _0xE1FF.LocalPlayer
    if not _0x1A90 or not _0x1A90.Character then return nil end
    local _0xDE6D, _0x7783, _0xFC8F = _0xC036.CameraRaycast(_0x77AD.AutoFireMaxDistance or 1000)
    if _0xDE6D and _0xFC8F then
        local _0x938C = _0xE1FF:GetPlayerFromCharacter(_0xFC8F)
        if _0x938C and _0x938C ~= _0x1A90 and _0xC036.IsEnemy(_0x1A90, _0x938C) then
            local _0x830D = _0xFC8F:FindFirstChildOfClass("Humanoid")
            if _0x830D and _0x830D.Health > 0 and _0xC036.IsTargetablePart(_0xDE6D) then return _0x938C, _0xDE6D.Name, _0x7783 end
        end
    end
    if _0x77AD.AutoFireProximityFallback ~= false then
        local _0xE958 = _0x7458.CFrame.Position
        local _0x3135 = _0x7458.CFrame.LookVector
        local _0x7E78 = _0x77AD.AutoFireMaxDistance or 1000
        local _0xF7F9 = math.rad(_0x77AD.AutoFireProximityAngle or 2.5)
        local _0x4A22, _0x4E18, _0x85F5, _0x90B2 = nil, nil, nil, math.huge
        local _0xC64D = _0x77AD.CameraAssistHitboxMode or "Head"
        if _0xC64D == "Random" then _0xC64D = _0xC036.ResolveHitboxMode("Random") end
        for _, _0xB680 in ipairs(_0xC036.GetValidPlayers()) do
            local _0x3A4B = _0xB680.Character
            if _0x3A4B and _0x3A4B.Parent then
                local _0x3694, _0x7AA7 = _0xC036.GetHitboxPosition(_0x3A4B, _0xC64D)
                if _0x3694 then
                    local _0x270D = _0x3694 - _0xE958
                    local _0xAFA9 = _0x270D.Magnitude
                    if _0xAFA9 > 0.5 and _0xAFA9 <= _0x7E78 then
                        local _0x5811 = _0x3135:Dot(_0x270D / _0xAFA9)
                        if _0x5811 > 0 then
                            local _0x9755 = math.acos(math.clamp(_0x5811, -1, 1))
                            local _0xF561 = math.max(_0xF7F9, math.atan(0.7 / _0xAFA9))
                            if _0x9755 <= _0xF561 then
                                local _0x8D29 = _0x9755 / _0xF561 + _0xAFA9 / _0x7E78 * 0.05
                                if _0x8D29 < _0x90B2 then _0x90B2 = _0x8D29 _0x4A22 = _0xB680.Player _0x4E18 = _0x7AA7 and _0x7AA7.Name or _0xC64D _0x85F5 = _0x3694 end
                            end
                        end
                    end
                end
            end
        end
        if _0x4A22 then return _0x4A22, _0x4E18, _0x85F5 end
    end
    return nil
end
function _0x034E.ShouldFire()
    if not _0x77AD.AutoFireEnabled then return false, nil end
    if not _0x77AD.AutoFireAlwaysOn and not _0x034E.KeyHeld then return false, nil end
    if _0x77AD.LobbyGuardEnabled and not _0xC036.IsInGame() then return false, nil end
    local _0x7458 = _0x3BA1.CurrentCamera
    if not _0x7458 or not _0x7458.Parent then return false, nil end
    if tick() - _0x034E.LastFireTime < _0x77AD.AutoFireDelay then return false, nil end
    if _0x1996.LastInputWasController and not _0x1996.ControllerFireHeld then return false, nil end
    if tick() < (_0x1996._deflectCooldownUntil or 0) then return false, nil end
    local _0x938C, _0x9664, _0xDE6D = _0x034E.RaycastCheck()
    if _0x938C then return true, {_0xCE00=_0x938C, _0x7AA7=_0x9664, position=_0xDE6D} end
    return false, nil
end
function _0x034E.FireOnce()
    if _0x76B0.HasMouse1Click then
        local _0xDF7B = pcall(mouse1click)
        if _0xDF7B then return true end
    end
    if _0x76B0.HasMouse1Press then
        local _0xDF7B = pcall(function() mouse1press() task.wait(0.02) mouse1release() end)
        if _0xDF7B then return true end
    end
    if _0x76B0.HasVIM then
        local _0x7458 = _0x3BA1.CurrentCamera
        local _0xE794 = (_0x7458 and _0x7458.ViewportSize) or Vector2.new(1920, 1080)
        local _0xDF7B = pcall(function()
            local _0xCA2C = game:GetService("VirtualInputManager")
            _0xCA2C:SendMouseButtonEvent(math.floor(_0xE794.X * 0.5), math.floor(_0xE794.Y * 0.5), 0, true, game, 0)
            task.wait(0.02)
            _0xCA2C:SendMouseButtonEvent(math.floor(_0xE794.X * 0.5), math.floor(_0xE794.Y * 0.5), 0, false, game, 0)
        end)
        if _0xDF7B then return true end
    end
    if _0x76B0.HasKeyPress then
        local _0xDF7B = pcall(function() keypress(0x01) task.wait(0.02) keyrelease(0x01) end)
        if _0xDF7B then return true end
    end
    return false
end
function _0x034E.Execute(fd)
    if not fd then return end
    if _0x034E.IsFiring then
        if tick() - _0x034E.FireStart > 0.5 then _0x034E.IsFiring = false else return end
    end
    local _0x938C = fd.player
    if not _0x938C or not _0x938C.Parent then return end
    local _0x3A4B = _0x938C.Character
    if not _0x3A4B or not _0x3A4B.Parent then return end
    local _0x830D = _0x3A4B:FindFirstChildOfClass("Humanoid")
    if not _0x830D or _0x830D.Health <= 0 then return end
    _0x034E.IsFiring = true _0x034E.FireStart = tick()
    _0x034E.FireOnce()
    _0x034E.LastFireTime = tick()
    _0x034E.IsFiring = false
end
function _0x034E.CheckAndFire()
    local _0x0404, _0x3748 = _0x034E.ShouldFire()
    if _0x0404 then _0x034E.Execute(_0x3748) end
end

-- ============================================================
-- Watermark
-- ============================================================
local _0x8553 = {Gui = nil}
local function _0x2F55()
    if _0x8553.Gui and _0x8553.Gui.Parent then
        _0x8553.Gui.Enabled = _0x77AD.WatermarkEnabled ~= false
        return
    end
    local _0x14E4 = _0xB27C()
    if not _0x14E4 then return end
    local _0xFA03 = Instance.new("ScreenGui")
    _0xFA03.Name = "VEIL_Watermark" _0xFA03.ResetOnSpawn = false _0xFA03.IgnoreGuiInset = true _0xFA03.DisplayOrder = 90
    pcall(function() _0xFA03.AutoLocalize = false end)
    _0xFA03.Parent = _0x14E4
    local _0x5237 = Instance.new("Frame")
    _0x5237.AnchorPoint = Vector2.new(0, 1) _0x5237.Position = UDim2.new(0, 14, 1, -14)
    _0x5237.Size = UDim2.fromOffset(180, 26) _0x5237.BackgroundTransparency = 1 _0x5237.Parent = _0xFA03
    local _0x154F = Instance.new("Frame")
    _0x154F.AnchorPoint = Vector2.new(0, 0.5) _0x154F.Position = UDim2.new(0, 0, 0.5, 0)
    _0x154F.Size = UDim2.fromOffset(6, 6) _0x154F.BackgroundColor3 = Color3.fromRGB(139, 92, 246)
    _0x154F.BorderSizePixel = 0 _0x154F.Parent = _0x5237
    local _0x4087 = Instance.new("UICorner") _0x4087.CornerRadius = UDim.new(0.5, 0) _0x4087.Parent = _0x154F
    local _0xF864 = Instance.new("TextLabel")
    _0xF864.AnchorPoint = Vector2.new(0, 0.5) _0xF864.Position = UDim2.new(0, 12, 0.5, 0)
    _0xF864.Size = UDim2.fromOffset(150, 20) _0xF864.BackgroundTransparency = 1
    _0xF864.Text = "VEIL" _0xF864.TextColor3 = Color3.fromRGB(245, 243, 255)
    _0xF864.Font = Enum.Font.GothamBlack _0xF864.TextSize = 15
    _0xF864.TextXAlignment = Enum.TextXAlignment.Left _0xF864.TextYAlignment = Enum.TextYAlignment.Center
    _0xF864.TextStrokeTransparency = 0.6 _0xF864.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) _0xF864.Parent = _0x5237
    local _0x6B50 = Instance.new("UIGradient")
    _0x6B50.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(245, 243, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(99, 102, 241)) })
    _0x6B50.Parent = _0xF864
    _0x8553.Gui = _0xFA03
    _0xFA03.Enabled = _0x77AD.WatermarkEnabled ~= false
end
local function _0x8977(_0x0207)
    _0x77AD.WatermarkEnabled = _0x0207 and true or false
    if _0x8553.Gui then _0x8553.Gui.Enabled = _0x77AD.WatermarkEnabled
    else _0x2F55() end
end

-- ============================================================
-- Startup animation
-- ============================================================
local function _0xB5D3(onReveal)
    local _0x14E4 = _0xB27C()
    if not _0x14E4 then if onReveal then pcall(onReveal) end return end
    local _0xFA03 = Instance.new("ScreenGui")
    _0xFA03.Name = "VEIL_Startup" _0xFA03.ResetOnSpawn = false _0xFA03.IgnoreGuiInset = true _0xFA03.DisplayOrder = 9999
    _0xFA03.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local _0x61A0 = pcall(function() _0xFA03.Parent = _0x14E4 end)
    if not _0x61A0 or not _0xFA03.Parent then
        pcall(function() _0xFA03.Parent = game:GetService("CoreGui") end)
    end
    if not _0xFA03.Parent then if onReveal then pcall(onReveal) end return end

    local _0x0EDC = false
    local _0x50EE = Instance.new("Frame")
    _0x50EE.Size = UDim2.fromScale(1, 1) _0x50EE.BackgroundTransparency = 1 _0x50EE.ZIndex = 5 _0x50EE.Parent = _0xFA03

    local function _0xE0D9()
        if _0x0EDC then return end
        _0x0EDC = true
        pcall(function()
            for _, ch in ipairs(_0x50EE:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
        end)
        pcall(function() _0xFA03:Destroy() end)
    end
    task.delay(10, _0xE0D9)

    local _0x2B1D = Instance.new("Frame")
    _0x2B1D.Size = UDim2.fromScale(1, 1) _0x2B1D.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    _0x2B1D.BorderSizePixel = 0 _0x2B1D.ZIndex = 1 _0x2B1D.Parent = _0xFA03

    local _0x470B = Instance.new("Frame")
    _0x470B.AnchorPoint = Vector2.new(0.5, 0.5) _0x470B.Position = UDim2.fromScale(0.5, 0.42)
    _0x470B.Size = UDim2.fromOffset(900, 900)
    _0x470B.BackgroundColor3 = Color3.fromRGB(110, 50, 220)
    _0x470B.BackgroundTransparency = 0.86
    _0x470B.BorderSizePixel = 0 _0x470B.ZIndex = 2 _0x470B.Parent = _0xFA03
    local _0xA771 = Instance.new("UICorner") _0xA771.CornerRadius = UDim.new(1, 0) _0xA771.Parent = _0x470B

    local function _0x8096()
        if _0x0EDC then return end
        local _0x4FF3 = math.random(2, 5)
        local _0xE3EF = math.random(10, 90) / 100
        local _0xF5B6 = 1.1 + math.random() * 0.15
        local _0x2912 = _0xE3EF + (math.random() - 0.5) * 0.15
        local _0x8CE9 = -0.15 - math.random() * 0.08
        local _0xB753 = 4 + math.random() * 2.5
        local _0x938C = Instance.new("Frame")
        _0x938C.AnchorPoint = Vector2.new(0.5, 0.5) _0x938C.Position = UDim2.fromScale(_0xE3EF, _0xF5B6)
        _0x938C.Size = UDim2.fromOffset(_0x4FF3, _0x4FF3) _0x938C.BackgroundColor3 = Color3.fromRGB(200, 160, 255)
        _0x938C.BackgroundTransparency = 1 _0x938C.BorderSizePixel = 0 _0x938C.ZIndex = 6 _0x938C.Parent = _0x50EE
        _0x27A5:Create(_0x938C, TweenInfo.new(0.5), {BackgroundTransparency = 0.4}):Play()
        _0x27A5:Create(_0x938C, TweenInfo.new(_0xB753, Enum.EasingStyle.Linear), {Position = UDim2.fromScale(_0x2912, _0x8CE9)}):Play()
        task.delay(_0xB753 - 0.8, function()
            if _0x938C.Parent then _0x27A5:Create(_0x938C, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play() end
        end)
        task.delay(_0xB753 + 0.1, function() if _0x938C.Parent then _0x938C:Destroy() end end)
    end

    local _0x2BA5 = Instance.new("Frame")
    _0x2BA5.Name = "VHolder"
    _0x2BA5.AnchorPoint = Vector2.new(0.5, 0.5)
    _0x2BA5.Position = UDim2.fromScale(0.5, 0.30)
    _0x2BA5.Size = UDim2.fromOffset(900, 900)
    _0x2BA5.BackgroundTransparency = 1 _0x2BA5.ZIndex = 30 _0x2BA5.Parent = _0xFA03

    local _0x126D = Instance.new("TextLabel")
    _0x126D.Size = UDim2.fromScale(1, 1)
    _0x126D.Position = UDim2.fromOffset(10, 12)
    _0x126D.BackgroundTransparency = 1
    _0x126D.Font = Enum.Font.GothamBlack _0x126D.Text = "V" _0x126D.TextSize = 700
    _0x126D.TextColor3 = Color3.fromRGB(40, 15, 90) _0x126D.TextTransparency = 0.4
    _0x126D.TextXAlignment = Enum.TextXAlignment.Center _0x126D.TextYAlignment = Enum.TextYAlignment.Center
    _0x126D.ZIndex = 30 _0x126D.Parent = _0x2BA5

    local _0xE600 = Instance.new("TextLabel")
    _0xE600.Size = UDim2.fromScale(1, 1) _0xE600.BackgroundTransparency = 1
    _0xE600.Font = Enum.Font.GothamBlack _0xE600.Text = "V" _0xE600.TextSize = 700
    _0xE600.TextColor3 = Color3.fromRGB(255, 255, 255)
    _0xE600.TextXAlignment = Enum.TextXAlignment.Center _0xE600.TextYAlignment = Enum.TextYAlignment.Center
    _0xE600.ZIndex = 31 _0xE600.Parent = _0x2BA5

    local _0x9EDE = Instance.new("UIGradient")
    _0x9EDE.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 205, 255)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(160, 100, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 130, 245)),
    }
    _0x9EDE.Rotation = 90 _0x9EDE.Parent = _0xE600

    local _0x254E = Instance.new("UIStroke")
    _0x254E.Color = Color3.fromRGB(210, 160, 255) _0x254E.Thickness = 4 _0x254E.Transparency = 0.15 _0x254E.Parent = _0xE600

    local _0xEFCA = Instance.new("TextLabel")
    _0xEFCA.AnchorPoint = Vector2.new(0.5, 0.5) _0xEFCA.Position = UDim2.fromScale(0.5, 0.70)
    _0xEFCA.Size = UDim2.fromOffset(600, 60) _0xEFCA.BackgroundTransparency = 1
    _0xEFCA.Font = Enum.Font.GothamBlack _0xEFCA.Text = "VEIL" _0xEFCA.TextSize = 58
    _0xEFCA.TextColor3 = Color3.fromRGB(255, 255, 255) _0xEFCA.TextXAlignment = Enum.TextXAlignment.Center
    _0xEFCA.ZIndex = 32 _0xEFCA.Parent = _0xFA03
    local _0x40A4 = Instance.new("UIGradient")
    _0x40A4.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 210, 255)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(180, 130, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 160, 255)),
    }
    _0x40A4.Parent = _0xEFCA
    local _0x9746 = Instance.new("UIStroke")
    _0x9746.Color = Color3.fromRGB(170, 120, 255) _0x9746.Thickness = 1.5 _0x9746.Transparency = 0.4 _0x9746.Parent = _0xEFCA
    _0xEFCA.TextTransparency = 1 _0x9746.Transparency = 1

    local _0xFC58 = Instance.new("TextLabel")
    _0xFC58.AnchorPoint = Vector2.new(0.5, 0.5) _0xFC58.Position = UDim2.fromScale(0.5, 0.765)
    _0xFC58.Size = UDim2.fromOffset(600, 20) _0xFC58.BackgroundTransparency = 1
    _0xFC58.Font = Enum.Font.GothamBold _0xFC58.Text = "S E C U R I T Y   S U I T E"
    _0xFC58.TextSize = 12 _0xFC58.TextColor3 = Color3.fromRGB(180, 145, 255)
    _0xFC58.TextXAlignment = Enum.TextXAlignment.Center _0xFC58.TextTransparency = 1 _0xFC58.ZIndex = 32 _0xFC58.Parent = _0xFA03

    local _0x3A26 = Instance.new("TextLabel")
    _0x3A26.AnchorPoint = Vector2.new(0.5, 0.5) _0x3A26.Position = UDim2.fromScale(0.5, 0.80)
    _0x3A26.Size = UDim2.fromOffset(600, 16) _0x3A26.BackgroundTransparency = 1
    _0x3A26.Font = Enum.Font.GothamMedium _0x3A26.Text = "Right Shift To Open Menu"
    _0x3A26.TextSize = 11 _0x3A26.TextColor3 = Color3.fromRGB(200, 170, 255)
    _0x3A26.TextXAlignment = Enum.TextXAlignment.Center _0x3A26.TextTransparency = 1 _0x3A26.ZIndex = 32 _0x3A26.Parent = _0xFA03

    local _0x734C = Instance.new("Frame")
    _0x734C.AnchorPoint = Vector2.new(0.5, 0.5) _0x734C.Position = UDim2.fromScale(0.5, 0.88)
    _0x734C.Size = UDim2.fromOffset(340, 12) _0x734C.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
    _0x734C.BackgroundTransparency = 0.85 _0x734C.BorderSizePixel = 0 _0x734C.ZIndex = 31 _0x734C.Parent = _0xFA03
    local _0x98F0 = Instance.new("UICorner") _0x98F0.CornerRadius = UDim.new(1, 0) _0x98F0.Parent = _0x734C

    local _0xFA67 = Instance.new("Frame")
    _0xFA67.AnchorPoint = Vector2.new(0.5, 0.5) _0xFA67.Position = UDim2.fromScale(0.5, 0.88)
    _0xFA67.Size = UDim2.fromOffset(300, 3) _0xFA67.BackgroundColor3 = Color3.fromRGB(40, 25, 70)
    _0xFA67.BorderSizePixel = 0 _0xFA67.ZIndex = 32 _0xFA67.Parent = _0xFA03
    local _0xD147 = Instance.new("UICorner") _0xD147.CornerRadius = UDim.new(1, 0) _0xD147.Parent = _0xFA67
    local _0x91BE = Instance.new("Frame")
    _0x91BE.Size = UDim2.new(0, 0, 1, 0) _0x91BE.BackgroundColor3 = Color3.fromRGB(180, 120, 255)
    _0x91BE.BorderSizePixel = 0 _0x91BE.ZIndex = 33 _0x91BE.Parent = _0xFA67
    local _0x18D8 = Instance.new("UICorner") _0x18D8.CornerRadius = UDim.new(1, 0) _0x18D8.Parent = _0x91BE
    local _0x8C49 = Instance.new("UIGradient")
    _0x8C49.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 80, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(230, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 200, 255)),
    }
    _0x8C49.Parent = _0x91BE

    task.spawn(function()
        while not _0x0EDC do
            _0x8096()
            task.wait(0.12 + math.random() * 0.06)
        end
    end)

    task.spawn(function()
        pcall(function()
            _0x27A5:Create(_0xE600, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize = 850}):Play()
            _0x27A5:Create(_0x126D, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize = 850}):Play()
            task.wait(0.35)
            _0x27A5:Create(_0xEFCA, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
            _0x27A5:Create(_0x9746, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Transparency = 0.4}):Play()
            task.wait(0.22)
            _0x27A5:Create(_0xFC58, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0.1}):Play()
            _0x27A5:Create(_0x3A26, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0.2}):Play()

            local _0x0B1B = 2.8
            _0x27A5:Create(_0x91BE, TweenInfo.new(_0x0B1B, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
            _0x27A5:Create(_0x734C, TweenInfo.new(_0x0B1B, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(344, 5), BackgroundTransparency = 0.9}):Play()

            task.wait(_0x0B1B + 0.25)
            if onReveal then pcall(onReveal) end
            _0x0EDC = true

            for _, _0x938C in ipairs(_0x50EE:GetChildren()) do
                if _0x938C:IsA("Frame") then
                    _0x27A5:Create(_0x938C, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
                end
            end

            _0x27A5:Create(_0xE600, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextSize = 980, TextTransparency = 0.5}):Play()
            _0x27A5:Create(_0x126D, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextSize = 980, TextTransparency = 1}):Play()

            task.delay(0.08, function()
                _0x27A5:Create(_0xEFCA, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
                _0x27A5:Create(_0x9746, TweenInfo.new(0.4), {Transparency = 1}):Play()
                _0x27A5:Create(_0xFC58, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
                _0x27A5:Create(_0x3A26, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
                _0x27A5:Create(_0xE600, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                _0x27A5:Create(_0x254E, TweenInfo.new(0.5), {Transparency = 1}):Play()
                _0x27A5:Create(_0x734C, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
                _0x27A5:Create(_0x91BE, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
                _0x27A5:Create(_0xFA67, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            end)

            _0x27A5:Create(_0x470B, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                BackgroundTransparency = 1, Size = UDim2.fromOffset(400, 400),
            }):Play()

            task.wait(0.55)
            _0x27A5:Create(_0x2B1D, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
            task.wait(0.7)
        end)
        pcall(_0xE0D9)
    end)
end
_G.__VEIL_ShowStartup = function() pcall(_0xB5D3) end

-- ============================================================
-- Discord popup
-- ============================================================
local function _0x0AE1()
    local _0x14E4 = _0xB27C()
    if not _0x14E4 then return end
    local _0xFA03 = Instance.new("ScreenGui")
    _0xFA03.Name = "VEIL_Discord" _0xFA03.ResetOnSpawn = false _0xFA03.IgnoreGuiInset = true _0xFA03.DisplayOrder = 95 _0xFA03.Parent = _0x14E4
    local _0xE9B8 = "Join our discord for updates. Bug reports go in the same server."
    local _0x16A9 = 14
    local _0x163E = 340 - _0x16A9 * 2
    local _0x929D = _0x9261(_0xE9B8, Enum.Font.Gotham, 11, _0x163E)
    _0x929D = math.max(_0x929D, 14)
    local _0xCAD6 = 36
    local _0x78A4 = 22
    local _0x198D = 14
    local _0x9781 = _0xCAD6 + _0x929D + 8 + _0x78A4 + _0x198D
    local _0x41F6 = Instance.new("Frame")
    _0x41F6.AnchorPoint = Vector2.new(0, 1) _0x41F6.Position = UDim2.new(0, 14, 1, -50)
    _0x41F6.Size = UDim2.fromOffset(340, _0x9781) _0x41F6.BackgroundColor3 = Color3.fromRGB(22, 20, 34)
    _0x41F6.BackgroundTransparency = 0.05 _0x41F6.BorderSizePixel = 0 _0x41F6.Parent = _0xFA03
    local _0x3A4B = Instance.new("UICorner") _0x3A4B.CornerRadius = UDim.new(0, 10) _0x3A4B.Parent = _0x41F6
    local _0x48A3 = Instance.new("UIStroke") _0x48A3.Color = Color3.fromRGB(88, 101, 242) _0x48A3.Thickness = 1.5 _0x48A3.Transparency = 0.3 _0x48A3.Parent = _0x41F6
    local _0x85ED = Instance.new("TextLabel")
    _0x85ED.Size = UDim2.new(1, -80, 0, 22) _0x85ED.Position = UDim2.new(0, 14, 0, 10)
    _0x85ED.BackgroundTransparency = 1 _0x85ED.Font = Enum.Font.GothamBold _0x85ED.TextSize = 12
    _0x85ED.TextColor3 = Color3.fromRGB(180, 170, 255) _0x85ED.TextXAlignment = Enum.TextXAlignment.Left
    _0x85ED.Text = "VEIL - Community" _0x85ED.Parent = _0x41F6
    local _0x2CBA = Instance.new("TextButton")
    _0x2CBA.Size = UDim2.fromOffset(22, 22) _0x2CBA.Position = UDim2.new(1, -32, 0, 10)
    _0x2CBA.BackgroundColor3 = Color3.fromRGB(40, 30, 60) _0x2CBA.BorderSizePixel = 0
    _0x2CBA.Font = Enum.Font.GothamBold _0x2CBA.TextSize = 14 _0x2CBA.TextColor3 = Color3.fromRGB(220, 210, 255)
    _0x2CBA.Text = "x" _0x2CBA.AutoButtonColor = false _0x2CBA.Parent = _0x41F6
    local _0xA792 = Instance.new("UICorner") _0xA792.CornerRadius = UDim.new(0, 5) _0xA792.Parent = _0x2CBA
    local _0xC5D8 = Instance.new("TextLabel")
    _0xC5D8.Size = UDim2.new(1, -_0x16A9 * 2, 0, _0x929D) _0xC5D8.Position = UDim2.new(0, _0x16A9, 0, _0xCAD6)
    _0xC5D8.BackgroundTransparency = 1 _0xC5D8.Font = Enum.Font.Gotham _0xC5D8.TextSize = 11
    _0xC5D8.TextColor3 = Color3.fromRGB(220, 215, 235) _0xC5D8.TextXAlignment = Enum.TextXAlignment.Left
    _0xC5D8.TextYAlignment = Enum.TextYAlignment.Top _0xC5D8.TextWrapped = true
    _0xC5D8.Text = _0xE9B8 _0xC5D8.Parent = _0x41F6
    local _0x4A2C = Instance.new("TextButton")
    _0x4A2C.Size = UDim2.new(1, -_0x16A9 * 2, 0, _0x78A4) _0x4A2C.Position = UDim2.new(0, _0x16A9, 1, -(_0x78A4 + _0x198D))
    _0x4A2C.BackgroundColor3 = Color3.fromRGB(88, 101, 242) _0x4A2C.BorderSizePixel = 0
    _0x4A2C.Font = Enum.Font.GothamBold _0x4A2C.TextSize = 11 _0x4A2C.TextColor3 = Color3.fromRGB(255, 255, 255)
    _0x4A2C.Text = "discord.gg/K3vgcVsCsS - tap to copy" _0x4A2C.AutoButtonColor = false _0x4A2C.Parent = _0x41F6
    local _0x9C8D = Instance.new("UICorner") _0x9C8D.CornerRadius = UDim.new(0, 6) _0x9C8D.Parent = _0x4A2C
    local _0xFC09 = "https://discord.gg/K3vgcVsCsS"
    _0x4A2C.MouseButton1Click:Connect(function()
        if type(setclipboard) == "function" then pcall(setclipboard, _0xFC09) _0x4A2C.Text = "Copied"
        else _0x4A2C.Text = "discord.gg/K3vgcVsCsS" end
        task.delay(1.5, function() if _0x4A2C and _0x4A2C.Parent then _0x4A2C.Text = "discord.gg/K3vgcVsCsS - tap to copy" end end)
    end)
    _0x2CBA.MouseButton1Click:Connect(function() pcall(function() _0xFA03:Destroy() end) end)
end

-- ============================================================
-- NightVision
-- ============================================================
local _0x0CF8 = {Active = false, Saved = nil, Effect = nil}
local function _0x6ADF()
    if _0x0CF8.Active then return end
    _0x0CF8.Active = true
    _0x0CF8.Saved = { Ambient = _0x18A8.Ambient, OutdoorAmbient = _0x18A8.OutdoorAmbient, Brightness = _0x18A8.Brightness, GlobalShadows = _0x18A8.GlobalShadows, FogEnd = _0x18A8.FogEnd, FogStart = _0x18A8.FogStart }
    pcall(function()
        _0x18A8.Ambient = Color3.fromRGB(170, 175, 180)
        _0x18A8.OutdoorAmbient = Color3.fromRGB(180, 185, 190)
        _0x18A8.Brightness = 3 _0x18A8.GlobalShadows = false
        _0x18A8.FogEnd = math.max(_0x18A8.FogEnd, 2000) _0x18A8.FogStart = math.max(_0x18A8.FogStart, 500)
    end)
    if _0x0CF8.Effect and _0x0CF8.Effect.Parent then _0x0CF8.Effect:Destroy() end
    local _0xA792 = Instance.new("ColorCorrectionEffect")
    _0xA792.Name = "VEIL_NightVision" _0xA792.Brightness = 0.25 _0xA792.Contrast = 0.1 _0xA792.Saturation = 0.05
    _0xA792.TintColor = Color3.fromRGB(210, 230, 210) _0xA792.Parent = _0x18A8
    _0x0CF8.Effect = _0xA792
end
local function _0xDC48()
    if not _0x0CF8.Active then return end
    _0x0CF8.Active = false
    if _0x0CF8.Saved then
        for _0xE7BF, _0x8C41 in pairs(_0x0CF8.Saved) do pcall(function() _0x18A8[_0xE7BF] = _0x8C41 end) end
        _0x0CF8.Saved = nil
    end
    if _0x0CF8.Effect and _0x0CF8.Effect.Parent then _0x0CF8.Effect:Destroy() end
    _0x0CF8.Effect = nil
end
local function _0x6EEB() if _0x77AD.NightVisionEnabled then _0x6ADF() else _0xDC48() end end

-- ============================================================
-- Performance
-- ============================================================
local _0xE5C4 = {}
_0xE5C4.Saved = {}
local _0xD27D = {
    ParticleEmitter = true, Beam = true, Trail = true, Fire = true, Smoke = true, Sparkles = true,
    PointLight = true, SpotLight = true, SurfaceLight = true,
}
function _0xE5C4.EnableFPSBoost()
    _0xE5C4.Saved.Lighting = {
        GlobalShadows = _0x18A8.GlobalShadows, Brightness = _0x18A8.Brightness,
        EnvironmentDiffuseScale = _0x18A8.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = _0x18A8.EnvironmentSpecularScale,
        FogEnd = _0x18A8.FogEnd, FogStart = _0x18A8.FogStart,
    }
    pcall(function()
        _0x18A8.GlobalShadows = false
        _0x18A8.Brightness = math.max(_0x18A8.Brightness, 1)
        _0x18A8.EnvironmentDiffuseScale = 0
        _0x18A8.EnvironmentSpecularScale = 0
        _0x18A8.FogEnd = 100000 _0x18A8.FogStart = 100000
    end)
    _0xE5C4.Saved.PostFX = {}
    for _, e in ipairs(_0x18A8:GetChildren()) do
        if e:IsA("PostEffect") and e.Name ~= "VEIL_NightVision" then
            _0xE5C4.Saved.PostFX[e] = e.Enabled
            pcall(function() e.Enabled = false end)
        end
    end
    _0xE5C4.Saved.WorkspaceEffects = {}
    for _, _0x3748 in ipairs(_0x3BA1:GetDescendants()) do
        if _0xD27D[_0x3748.ClassName] then
            local _0xDF7B, _0xA382 = pcall(function() return _0x3748.Enabled end)
            if _0xDF7B then
                _0xE5C4.Saved.WorkspaceEffects[_0x3748] = _0xA382
                pcall(function() _0x3748.Enabled = false end)
            end
        end
    end
end
function _0xE5C4.DisableFPSBoost()
    local _0x5F94 = _0xE5C4.Saved
    if _0x5F94.Lighting then
        for _0xE7BF, _0x8C41 in pairs(_0x5F94.Lighting) do pcall(function() _0x18A8[_0xE7BF] = _0x8C41 end) end
        _0x5F94.Lighting = nil
    end
    if _0x5F94.PostFX then
        for inst, state in pairs(_0x5F94.PostFX) do
            if inst and inst.Parent then pcall(function() inst.Enabled = state end) end
        end
        _0x5F94.PostFX = nil
    end
    if _0x5F94.WorkspaceEffects then
        for inst, state in pairs(_0x5F94.WorkspaceEffects) do
            if inst and inst.Parent then pcall(function() inst.Enabled = state end) end
        end
        _0x5F94.WorkspaceEffects = nil
    end
    _0xE5C4.Saved = {}
end

local _0x4C3F = {}
local function _0xDC8F(id, snapshot, onChange)
    if not _0x4C3F[id] then _0x4C3F[id] = { wasOn = false, _0x5F94 = {} } end
    local _0x48A3 = _0x4C3F[id]
    if snapshot.enabled and not _0x48A3.wasOn then
        _0x48A3.wasOn = true _0x48A3.saved = {}
        for _0xE7BF, _ in pairs(snapshot.set) do _0x48A3.saved[_0xE7BF] = _0x77AD[_0xE7BF] end
        for _0xE7BF, _0x8C41 in pairs(snapshot.set) do _0x77AD[_0xE7BF] = _0x8C41 end
        if onChange then pcall(onChange, true) end
    elseif not snapshot.enabled and _0x48A3.wasOn then
        _0x48A3.wasOn = false
        for _0xE7BF, _0x8C41 in pairs(_0x48A3.saved) do _0x77AD[_0xE7BF] = _0x8C41 end
        _0x48A3.saved = {}
        if onChange then pcall(onChange, false) end
    end
end

-- ============================================================
-- Presence
-- ============================================================
local _0x6C2B = { Namespace = "veil-7x9k3m-prod", BucketWindow = 300, LastBucket = nil }
local function _0xAEDD(url)
    local _0x2413 = nil
    task.spawn(function()
        local _0xDF7B, _0xBE70
        if type(request) == "function" then _0xDF7B, _0xBE70 = pcall(request, { Url = url, Method = "GET" })
        elseif type(http_request) == "function" then _0xDF7B, _0xBE70 = pcall(http_request, { Url = url, Method = "GET" })
        elseif type(syn) == "table" and type(syn.request) == "function" then _0xDF7B, _0xBE70 = pcall(syn.request, { Url = url, Method = "GET" }) end
        if _0xDF7B and _0xBE70 then _0x2413 = _0xBE70.Body or _0xBE70.body end
    end)
    local _0xFB05 = 0
    while _0x2413 == nil and _0xFB05 < 1 do task.wait(0.05) _0xFB05 = _0xFB05 + 0.05 end
    return _0x2413
end
local function _0xB6C1(_0x2413)
    if not _0x2413 or _0x2413 == "" then return nil end
    local _0xDF7B, _0xD2FF = pcall(function() return _0xFC99:JSONDecode(_0x2413) end)
    if not _0xDF7B or type(_0xD2FF) ~= "table" then return nil end
    return _0xD2FF.value
end
local function _0x614F(_0x6260)
    return _0xB6C1(_0xAEDD("https://abacus.jasoncameron.dev/hit/" .. _0x6C2B.Namespace .. "/" .. _0x6260))
end
function _0x6C2B.Tick()
    local _0x1E14 = math.floor(os.time() / _0x6C2B.BucketWindow)
    if _0x6C2B.LastBucket ~= _0x1E14 then
        _0x6C2B.LastBucket = _0x1E14
        task.spawn(function() _0x614F("active_" .. _0x1E14) end)
    end
end
function _0x6C2B.Register()
    task.delay(6, function()
        task.spawn(function() pcall(function() _0x614F("users_total") end) end)
        task.spawn(function() pcall(function() _0x6C2B.Tick() end) end)
    end)
    task.spawn(function()
        while not _0x1996.ShuttingDown do task.wait(240) pcall(function() _0x6C2B.Tick() end) end
    end)
end
-- ============================================================
-- Interface
-- ============================================================
local _0xB457 = {}
_0xB457.ScreenGui = nil _0xB457.MainFrame = nil
_0xB457.TabContents = {} _0xB457.TabButtons = {} _0xB457.CurrentTab = nil
local _0x97CF = _0x3317
local _0xFB97 = _0x27A5
local function _0xE1D1(_0x8377, _0x3FCC) local _0x3A4B = Instance.new("UICorner") _0x3A4B.CornerRadius = UDim.new(0, _0x3FCC or 8) _0x3A4B.Parent = _0x8377 return _0x3A4B end
local function _0x80E5(_0x8377, _0xE798, th, _0x5D38) local _0x0404 = Instance.new("UIStroke") _0x0404.Color = _0xE798 or _0x97CF.Border _0x0404.Thickness = th or 1 _0x0404.Transparency = _0x5D38 or 0 _0x0404.Parent = _0x8377 return _0x0404 end
local function _0x9E48(parent, text)
    local _0x0404 = Instance.new("Frame")
    _0x0404.Size = UDim2.new(1, 0, 0, 24) _0x0404.BackgroundTransparency = 1 _0x0404.Parent = parent
    local _0x2EAC = Instance.new("Frame")
    _0x2EAC.Size = UDim2.new(0, 3, 0, 12) _0x2EAC.Position = UDim2.new(0, 0, 0.5, -6)
    _0x2EAC.BackgroundColor3 = _0x97CF.Accent _0x2EAC.BorderSizePixel = 0 _0x2EAC.Parent = _0x0404
    _0xE1D1(_0x2EAC, 2)
    local _0x104C = Instance.new("TextLabel")
    _0x104C.Size = UDim2.new(1, -14, 1, 0) _0x104C.Position = UDim2.new(0, 14, 0, 0)
    _0x104C.BackgroundTransparency = 1 _0x104C.Font = Enum.Font.GothamBold
    _0x104C.Text = tostring(text):upper() _0x104C.TextSize = 10 _0x104C.TextColor3 = _0x97CF.Accent3
    _0x104C.TextXAlignment = Enum.TextXAlignment.Left _0x104C.Parent = _0x0404
    return _0x0404
end
local function _0x6C63(parent, text)
    local _0x0404 = Instance.new("Frame")
    _0x0404.Size = UDim2.new(1, 0, 0, 24) _0x0404.BackgroundTransparency = 1 _0x0404.Parent = parent
    local _0x2EAC = Instance.new("Frame")
    _0x2EAC.Size = UDim2.new(0, 3, 0, 12) _0x2EAC.Position = UDim2.new(0, 0, 0.5, -6)
    _0x2EAC.BackgroundColor3 = Color3.fromRGB(255, 200, 40) _0x2EAC.BorderSizePixel = 0 _0x2EAC.Parent = _0x0404
    _0xE1D1(_0x2EAC, 2)
    local _0x104C = Instance.new("TextLabel")
    _0x104C.Size = UDim2.new(1, -14, 1, 0) _0x104C.Position = UDim2.new(0, 14, 0, 0)
    _0x104C.BackgroundTransparency = 1 _0x104C.Font = Enum.Font.GothamBold
    _0x104C.Text = "\226\152\133 " .. tostring(text):upper() _0x104C.TextSize = 10
    _0x104C.TextColor3 = Color3.fromRGB(255, 200, 40) _0x104C.TextXAlignment = Enum.TextXAlignment.Left _0x104C.Parent = _0x0404
    return _0x0404
end
local _0x0912 = false
local _0x04E8 = 0
local function _0x6E22(customTitle, customBody)
    local _0x17DA = tick()
    if _0x0912 or _0x17DA - _0x04E8 < 0.4 then return end
    _0x04E8 = _0x17DA _0x0912 = true
    local _0x14E4 = _0xB27C()
    if not _0x14E4 then _0x0912 = false return end
    local _0xFA03 = Instance.new("ScreenGui")
    _0xFA03.Name = "VEIL_Premium" _0xFA03.ResetOnSpawn = false _0xFA03.IgnoreGuiInset = true _0xFA03.DisplayOrder = 97
    pcall(function() _0xFA03.Parent = _0x14E4 end)
    local _0xA176 = customTitle or "PREMIUM REQUIRED"
    local _0x6652 = customBody or "This feature is reserved for VEIL Premium.\nUnlock it in our Discord."
    local _0xA1C7 = 10
    local _0xC661 = 54
    local _0x8C3F = 4
    local _0xED4D = 16
    local _0x3B1B = 6
    local _0x61C4 = 12
    local _0x4B37 = 26
    local _0x2DE5 = 14
    local _0xBAB4 = 14
    local _0xFA91 = 380
    local _0x4CEB = _0xFA91 - _0xBAB4 * 2
    local _0xF25D = _0xA1C7 + _0xC661 + _0x8C3F
    local _0x34E3 = _0xF25D + _0xED4D + _0x3B1B
    local _0x8079 = math.max(_0x9261(_0x6652, Enum.Font.Gotham, 11, _0x4CEB), 16)
    local _0x1B61 = _0x34E3 + _0x8079 + _0x61C4 + _0x4B37 + _0x2DE5
    local _0xC028 = Instance.new("Frame")
    _0xC028.AnchorPoint = Vector2.new(0.5, 0) _0xC028.Position = UDim2.new(0.5, 0, 0, -100)
    _0xC028.Size = UDim2.fromOffset(_0xFA91, _0x1B61) _0xC028.BackgroundColor3 = Color3.fromRGB(18, 14, 8)
    _0xC028.BackgroundTransparency = 1 _0xC028.BorderSizePixel = 0 _0xC028.Parent = _0xFA03
    _0xE1D1(_0xC028, 14)
    local _0xCAF8 = Instance.new("UIStroke")
    _0xCAF8.Color = Color3.fromRGB(255, 200, 40) _0xCAF8.Thickness = 1.5 _0xCAF8.Transparency = 0.15 _0xCAF8.Parent = _0xC028
    local _0x4BBC = Instance.new("UIScale") _0x4BBC.Scale = 0.7 _0x4BBC.Parent = _0xC028
    local _0xC6B3 = Instance.new("Frame")
    _0xC6B3.Size = UDim2.fromOffset(_0xC661, _0xC661)
    _0xC6B3.AnchorPoint = Vector2.new(0.5, 0)
    _0xC6B3.Position = UDim2.new(0.5, 0, 0, _0xA1C7)
    _0xC6B3.BackgroundTransparency = 1 _0xC6B3.Parent = _0xC028
    local _0x09BF = Instance.new("TextLabel")
    _0x09BF.Size = UDim2.fromScale(1, 1) _0x09BF.BackgroundTransparency = 1
    _0x09BF.Font = Enum.Font.GothamBlack _0x09BF.Text = "\226\152\133"
    _0x09BF.TextSize = 38 _0x09BF.TextColor3 = Color3.fromRGB(255, 215, 60)
    _0x09BF.TextXAlignment = Enum.TextXAlignment.Center _0x09BF.TextYAlignment = Enum.TextYAlignment.Center
    _0x09BF.Parent = _0xC6B3
    local _0x4B0A = Instance.new("UIGradient")
    _0x4B0A.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 245, 180)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 215, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(215, 150, 20)),
    }
    _0x4B0A.Rotation = 45 _0x4B0A.Parent = _0x09BF
    local _0x6765 = Instance.new("UIStroke")
    _0x6765.Color = Color3.fromRGB(255, 240, 150) _0x6765.Thickness = 2 _0x6765.Transparency = 0.3 _0x6765.Parent = _0x09BF
    task.spawn(function()
        local _0xFE70 = 0
        while _0x09BF.Parent and _0xC6B3.Parent do
            _0x27A5:Create(_0x09BF, TweenInfo.new(3.4, Enum.EasingStyle.Linear), {Rotation = _0xFE70 + 360}):Play()
            task.wait(3.4)
            _0xFE70 = (_0xFE70 + 360) % 360
            pcall(function() _0x09BF.Rotation = _0xFE70 end)
        end
    end)
    task.spawn(function()
        while _0x6765.Parent do
            _0x27A5:Create(_0x6765, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.75, Thickness = 4}):Play()
            task.wait(0.85)
            _0x27A5:Create(_0x6765, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.25, Thickness = 2}):Play()
            task.wait(0.85)
        end
    end)
    task.spawn(function()
        while _0xC6B3.Parent do
            _0x27A5:Create(_0x09BF, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 44}):Play()
            task.wait(1.4)
            _0x27A5:Create(_0x09BF, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 36}):Play()
            task.wait(1.4)
        end
    end)
    local _0xAB9E = Instance.new("TextLabel")
    _0xAB9E.Size = UDim2.new(1, -_0xBAB4 * 2, 0, _0xED4D)
    _0xAB9E.Position = UDim2.new(0, _0xBAB4, 0, _0xF25D)
    _0xAB9E.BackgroundTransparency = 1 _0xAB9E.Font = Enum.Font.GothamBlack
    _0xAB9E.Text = _0xA176 _0xAB9E.TextSize = 12
    _0xAB9E.TextColor3 = Color3.fromRGB(255, 210, 70)
    _0xAB9E.TextXAlignment = Enum.TextXAlignment.Center _0xAB9E.Parent = _0xC028
    local _0x2413 = Instance.new("TextLabel")
    _0x2413.Size = UDim2.new(1, -_0xBAB4 * 2, 0, _0x8079)
    _0x2413.Position = UDim2.new(0, _0xBAB4, 0, _0x34E3)
    _0x2413.BackgroundTransparency = 1 _0x2413.Font = Enum.Font.Gotham
    _0x2413.Text = _0x6652
    _0x2413.TextSize = 11 _0x2413.TextColor3 = Color3.fromRGB(230, 220, 200)
    _0x2413.TextXAlignment = Enum.TextXAlignment.Center _0x2413.TextYAlignment = Enum.TextYAlignment.Top
    _0x2413.TextWrapped = true _0x2413.Parent = _0xC028
    local _0x3AD0 = Instance.new("TextButton")
    _0x3AD0.Size = UDim2.new(1, -_0xBAB4 * 2, 0, _0x4B37)
    _0x3AD0.Position = UDim2.new(0, _0xBAB4, 1, -(_0x4B37 + _0x2DE5))
    _0x3AD0.BackgroundColor3 = Color3.fromRGB(255, 200, 40) _0x3AD0.BorderSizePixel = 0
    _0x3AD0.Font = Enum.Font.GothamBold _0x3AD0.Text = "TAP TO COPY DISCORD INVITE" _0x3AD0.TextSize = 11
    _0x3AD0.TextColor3 = Color3.fromRGB(28, 22, 10) _0x3AD0.AutoButtonColor = false _0x3AD0.Parent = _0xC028
    _0xE1D1(_0x3AD0, 7)
    local _0xFC09 = "https://discord.gg/K3vgcVsCsS"
    _0x3AD0.MouseButton1Click:Connect(function()
        if type(setclipboard) == "function" then
            pcall(setclipboard, _0xFC09)
            _0x3AD0.Text = "COPIED TO CLIPBOARD"
            _0x3AD0.BackgroundColor3 = Color3.fromRGB(80, 220, 130)
            task.delay(1.8, function()
                if _0x3AD0.Parent then
                    _0x3AD0.Text = "TAP TO COPY DISCORD INVITE"
                    _0x3AD0.BackgroundColor3 = Color3.fromRGB(255, 200, 40)
                end
            end)
        else
            _0x3AD0.Text = _0xFC09
            task.delay(2.2, function() if _0x3AD0.Parent then _0x3AD0.Text = "TAP TO COPY DISCORD INVITE" end end)
        end
    end)
    _0x27A5:Create(_0x4BBC, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    _0x27A5:Create(_0xC028, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 14), BackgroundTransparency = 0}):Play()
    task.delay(10, function()
        _0x27A5:Create(_0xC028, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, -100), BackgroundTransparency = 1}):Play()
        task.delay(0.5, function() pcall(function() _0xFA03:Destroy() end) _0x0912 = false end)
    end)
end
local _0x21BE = {
    SilentAimEnabled = true, SilentAimHitChance = true, SilentAimFOV = true, SilentAimHitbox = true,
    SilentAimDrawFOV = true, SilentAimFOVColor = true, HitSoundsEnabled = true, HitSoundChoice = true,
    CustomCrosshairEnabled = true, HitboxExpanderEnabled = true, HitboxExpanderSize = true,
    SpinbotEnabled = true, RapidFireEnabled = true, MaxAccuracyEnabled = true, NoSpreadEnabled = true,
    ESPTargetVisEnabled = true, ViewmodelChamsEnabled = true, FlyNoclipEnabled = true,
    NightVisionEnabled = true, AimLockEnabled = true, RagebotEnabled = true,
    SilentAimDistanceBoost = true, SilentAimConvergenceSnap = true, SilentAimTightDeadzone = true,
}
local _0x22B6 = {}
local function _0x4201(parent, text, _0x6260, _0x2CBA)
    local _0xEB70 = _0x21BE[_0x6260] == true
    local _0xF9E8 = _0xEB70 and not _0x77AD.IsPremium
    local _0xA100 = Instance.new("Frame")
    _0xA100.Size = UDim2.new(1, 0, 0, 34) _0xA100.BackgroundTransparency = 1 _0xA100.Parent = parent
    local _0x104C = Instance.new("TextLabel")
    _0x104C.Size = UDim2.new(1, -60, 1, 0)
    if _0xEB70 then _0x104C.Position = UDim2.new(0, 16, 0, 0) end
    _0x104C.BackgroundTransparency = 1 _0x104C.Font = Enum.Font.Gotham
    _0x104C.Text = tostring(text) _0x104C.TextSize = 12 _0x104C.TextColor3 = _0x97CF.Text
    _0x104C.TextXAlignment = Enum.TextXAlignment.Left _0x104C.Parent = _0xA100
    if _0xEB70 then
        local _0x0404 = Instance.new("TextLabel")
        _0x0404.Size = UDim2.fromOffset(16, 14) _0x0404.Position = UDim2.new(0, -2, 0.5, -7)
        _0x0404.BackgroundTransparency = 1 _0x0404.Font = Enum.Font.GothamBold
        _0x0404.Text = "\226\152\133" _0x0404.TextSize = 12 _0x0404.TextColor3 = Color3.fromRGB(255, 200, 40) _0x0404.Parent = _0xA100
    end
    local _0x938C = Instance.new("Frame")
    _0x938C.Size = UDim2.new(0, 40, 0, 20) _0x938C.Position = UDim2.new(1, -40, 0.5, -10)
    _0x938C.BackgroundColor3 = _0xF9E8 and Color3.fromRGB(40, 30, 15) or _0x97CF.PanelLight
    _0x938C.BorderSizePixel = 0 _0x938C.Parent = _0xA100
    _0xE1D1(_0x938C, 10)
    _0x80E5(_0x938C, _0xF9E8 and Color3.fromRGB(120, 90, 40) or _0x97CF.Border, 1, 0.3)
    local _0xE7BF = Instance.new("Frame")
    _0xE7BF.Size = UDim2.new(0, 14, 0, 14) _0xE7BF.Position = UDim2.new(0, 3, 0.5, -7)
    _0xE7BF.BackgroundColor3 = _0xF9E8 and Color3.fromRGB(120, 90, 40) or _0x97CF.TextMuted
    _0xE7BF.BorderSizePixel = 0 _0xE7BF.ZIndex = 2 _0xE7BF.Parent = _0x938C
    _0xE1D1(_0xE7BF, 7)
    local _0x78ED = Instance.new("TextButton")
    _0x78ED.Size = UDim2.new(1, 0, 1, 0) _0x78ED.BackgroundTransparency = 1 _0x78ED.Text = "" _0x78ED.Parent = _0x938C
    local function _0x96C1(_0x0207, an)
        if _0xF9E8 then return end
        local _0x05AC = TweenInfo.new(an and 0.2 or 0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        if _0x0207 then
            _0xFB97:Create(_0x938C, _0x05AC, {BackgroundColor3 = _0x97CF.Accent}):Play()
            _0xFB97:Create(_0xE7BF, _0x05AC, {Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = _0x97CF.Text}):Play()
        else
            _0xFB97:Create(_0x938C, _0x05AC, {BackgroundColor3 = _0x97CF.PanelLight}):Play()
            _0xFB97:Create(_0xE7BF, _0x05AC, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = _0x97CF.TextMuted}):Play()
        end
    end
    _0x78ED.MouseButton1Click:Connect(function()
        if _0xF9E8 then pcall(_0x6E22) return end
        _0x77AD[_0x6260] = not _0x77AD[_0x6260]
        _0x96C1(_0x77AD[_0x6260], true)
        if _0x2CBA then pcall(_0x2CBA, _0x77AD[_0x6260]) end
        if _0x6260 == "SilentAimEnabled" then
            if _0x77AD.SilentAimEnabled then
                if _0x2D8B.InstallHook then pcall(_0x2D8B.InstallHook) end
                if not _0x0E63 then
                    _G.__VEIL_AimbotBeforeSilent = _0x77AD.CameraAssistEnabled
                    _0x77AD.CameraAssistEnabled = false
                    if _0x22B6["CameraAssistEnabled"] then _0x22B6["CameraAssistEnabled"](false, true) end
                else
                    _0x77AD.CameraAssistEnabled = true
                    if _0x22B6["CameraAssistEnabled"] then _0x22B6["CameraAssistEnabled"](true, true) end
                end
            else
                if _0x2D8B.UninstallHook then pcall(_0x2D8B.UninstallHook) end
                if not _0x0E63 then
                    if _G.__VEIL_AimbotBeforeSilent then
                        _0x77AD.CameraAssistEnabled = true
                        if _0x22B6["CameraAssistEnabled"] then _0x22B6["CameraAssistEnabled"](true, true) end
                    end
                    _G.__VEIL_AimbotBeforeSilent = false
                end
                pcall(_0xA561, _0x51E5)
            end
        elseif _0x6260 == "CameraAssistEnabled" and _0x77AD.CameraAssistEnabled then
            if not _0x0E63 then
                _0x77AD.SilentAimEnabled = false
                if _0x22B6["SilentAimEnabled"] then _0x22B6["SilentAimEnabled"](false, true) end
            end
            pcall(_0xA561, _0x51E5)
        end
        _0xC036.InvalidateLobbyCache()
        _0x9CA3()
    end)
    _0x22B6[_0x6260] = _0x96C1
    _0x96C1(_0x77AD[_0x6260], false)
    return _0xA100
end
local function _0x7F2D(parent, text, toggleKey, colorKey, _0x2CBA)
    local _0xA100 = Instance.new("Frame")
    _0xA100.Size = UDim2.new(1, 0, 0, 34) _0xA100.BackgroundTransparency = 1 _0xA100.Parent = parent
    local _0x104C = Instance.new("TextLabel")
    _0x104C.Size = UDim2.new(1, -200, 1, 0) _0x104C.BackgroundTransparency = 1
    _0x104C.Font = Enum.Font.Gotham _0x104C.Text = tostring(text) _0x104C.TextSize = 12
    _0x104C.TextColor3 = _0x97CF.Text _0x104C.TextXAlignment = Enum.TextXAlignment.Left _0x104C.Parent = _0xA100
    local _0xCA90 = Instance.new("TextButton")
    _0xCA90.Size = UDim2.new(0, 100, 0, 22) _0xCA90.Position = UDim2.new(1, -146, 0.5, -11)
    _0xCA90.BackgroundColor3 = _0x97CF.Card _0xCA90.BorderSizePixel = 0
    _0xCA90.Font = Enum.Font.GothamMedium _0xCA90.TextSize = 10 _0xCA90.TextColor3 = _0x97CF.Text
    _0xCA90.Text = "Change colour" _0xCA90.AutoButtonColor = false _0xCA90.Parent = _0xA100
    _0xE1D1(_0xCA90, 6) _0x80E5(_0xCA90, _0x97CF.Border, 1, 0.4)
    _0xCA90.MouseButton1Click:Connect(function()
        local _0x9794 = {
            {_0x4BFF="Purple", _0xE798=Color3.fromRGB(139, 92, 246)}, {_0x4BFF="Red", _0xE798=Color3.fromRGB(255, 60, 60)},
            {_0x4BFF="Blue", _0xE798=Color3.fromRGB(99, 102, 241)}, {_0x4BFF="Green", _0xE798=Color3.fromRGB(60, 220, 90)},
            {_0x4BFF="Yellow", _0xE798=Color3.fromRGB(255, 220, 60)}, {_0x4BFF="White", _0xE798=Color3.fromRGB(245, 243, 255)},
            {_0x4BFF="Black", _0xE798=Color3.fromRGB(25, 25, 30)}, {_0x4BFF="Cyan", _0xE798=Color3.fromRGB(80, 220, 240)},
            {_0x4BFF="Orange", _0xE798=Color3.fromRGB(255, 140, 60)}, {_0x4BFF="Pink", _0xE798=Color3.fromRGB(255, 100, 200)},
            {_0x4BFF="Lime", _0xE798=Color3.fromRGB(120, 255, 120)}, {_0x4BFF="Teal", _0xE798=Color3.fromRGB(60, 200, 180)},
        }
        local _0x14E4 = _0xB27C()
        if not _0x14E4 then return end
        local _0x65E1 = Instance.new("ScreenGui")
        _0x65E1.Name = "VEIL_Picker" _0x65E1.ResetOnSpawn = false _0x65E1.IgnoreGuiInset = true
        _0x65E1.DisplayOrder = 6000 _0x65E1.Parent = _0x14E4
        local _0x94DC = Instance.new("TextButton")
        _0x94DC.Size = UDim2.fromScale(1, 1) _0x94DC.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        _0x94DC.BackgroundTransparency = 0.5 _0x94DC.BorderSizePixel = 0 _0x94DC.Text = "" _0x94DC.AutoButtonColor = false _0x94DC.Parent = _0x65E1
        local _0xA05F = Instance.new("Frame")
        _0xA05F.AnchorPoint = Vector2.new(0.5, 0.5) _0xA05F.Position = UDim2.fromScale(0.5, 0.5)
        _0xA05F.Size = UDim2.fromOffset(300, 220) _0xA05F.BackgroundColor3 = _0x97CF.Panel
        _0xA05F.BorderSizePixel = 0 _0xA05F.Parent = _0x65E1
        _0xE1D1(_0xA05F, 10) _0x80E5(_0xA05F, _0x97CF.Border, 1, 0)
        local _0xEFCA = Instance.new("TextLabel")
        _0xEFCA.Size = UDim2.new(1, -40, 0, 24) _0xEFCA.Position = UDim2.new(0, 14, 0, 10)
        _0xEFCA.BackgroundTransparency = 1 _0xEFCA.Font = Enum.Font.GothamBold
        _0xEFCA.TextSize = 12 _0xEFCA.TextColor3 = _0x97CF.Text
        _0xEFCA.TextXAlignment = Enum.TextXAlignment.Left _0xEFCA.Text = "Pick a color" _0xEFCA.Parent = _0xA05F
        local _0x1B59 = Instance.new("TextButton")
        _0x1B59.Size = UDim2.fromOffset(22, 22) _0x1B59.Position = UDim2.new(1, -32, 0, 10)
        _0x1B59.BackgroundColor3 = _0x97CF.PanelLight _0x1B59.BorderSizePixel = 0
        _0x1B59.Font = Enum.Font.GothamBold _0x1B59.TextSize = 13 _0x1B59.TextColor3 = _0x97CF.Text
        _0x1B59.Text = "x" _0x1B59.AutoButtonColor = false _0x1B59.Parent = _0xA05F
        _0xE1D1(_0x1B59, 5)
        local _0x7891 = Instance.new("Frame")
        _0x7891.Size = UDim2.new(1, -28, 1, -52) _0x7891.Position = UDim2.new(0, 14, 0, 42)
        _0x7891.BackgroundTransparency = 1 _0x7891.Parent = _0xA05F
        local _0xADB5 = Instance.new("UIGridLayout")
        _0xADB5.CellSize = UDim2.fromOffset(60, 34) _0xADB5.CellPadding = UDim2.fromOffset(6, 6)
        _0xADB5.SortOrder = Enum.SortOrder.LayoutOrder _0xADB5.Parent = _0x7891
        local function _0x17EC() pcall(function() _0x65E1:Destroy() end) end
        _0x94DC.MouseButton1Click:Connect(_0x17EC)
        _0x1B59.MouseButton1Click:Connect(_0x17EC)
        for _, _0x05AC in ipairs(_0x9794) do
            local _0x2EAC = Instance.new("TextButton")
            _0x2EAC.BackgroundColor3 = _0x05AC.col _0x2EAC.BorderSizePixel = 0 _0x2EAC.Text = "" _0x2EAC.AutoButtonColor = false _0x2EAC.Parent = _0x7891
            _0xE1D1(_0x2EAC, 6) _0x80E5(_0x2EAC, _0x97CF.Border, 1, 0.3)
            _0x2EAC.MouseButton1Click:Connect(function()
                _0x77AD[colorKey] = _0x05AC.name
                _0x9CA3()
                _0x17EC()
            end)
        end
    end)
    local _0x938C = Instance.new("Frame")
    _0x938C.Size = UDim2.new(0, 40, 0, 20) _0x938C.Position = UDim2.new(1, -40, 0.5, -10)
    _0x938C.BackgroundColor3 = _0x97CF.PanelLight _0x938C.BorderSizePixel = 0 _0x938C.Parent = _0xA100
    _0xE1D1(_0x938C, 10) _0x80E5(_0x938C, _0x97CF.Border, 1, 0.3)
    local _0xE7BF = Instance.new("Frame")
    _0xE7BF.Size = UDim2.new(0, 14, 0, 14) _0xE7BF.Position = UDim2.new(0, 3, 0.5, -7)
    _0xE7BF.BackgroundColor3 = _0x97CF.TextMuted _0xE7BF.BorderSizePixel = 0 _0xE7BF.ZIndex = 2 _0xE7BF.Parent = _0x938C
    _0xE1D1(_0xE7BF, 7)
    local _0x78ED = Instance.new("TextButton")
    _0x78ED.Size = UDim2.new(1, 0, 1, 0) _0x78ED.BackgroundTransparency = 1 _0x78ED.Text = "" _0x78ED.Parent = _0x938C
    local function _0x96C1(_0x0207, an)
        local _0x05AC = TweenInfo.new(an and 0.2 or 0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        if _0x0207 then
            _0xFB97:Create(_0x938C, _0x05AC, {BackgroundColor3 = _0x97CF.Accent}):Play()
            _0xFB97:Create(_0xE7BF, _0x05AC, {Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = _0x97CF.Text}):Play()
        else
            _0xFB97:Create(_0x938C, _0x05AC, {BackgroundColor3 = _0x97CF.PanelLight}):Play()
            _0xFB97:Create(_0xE7BF, _0x05AC, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = _0x97CF.TextMuted}):Play()
        end
    end
    _0x78ED.MouseButton1Click:Connect(function()
        _0x77AD[toggleKey] = not _0x77AD[toggleKey]
        _0x96C1(_0x77AD[toggleKey], true)
        if _0x2CBA then pcall(_0x2CBA, _0x77AD[toggleKey]) end
        _0x9CA3()
    end)
    _0x96C1(_0x77AD[toggleKey], false)
    return _0xA100
end
local function _0xE17A(parent, text, _0x6260, mn, _0xA856, step, bfn)
    local _0xEB70 = _0x21BE[_0x6260] == true
    local _0xF9E8 = _0xEB70 and not _0x77AD.IsPremium
    local _0x3A4B = Instance.new("Frame")
    _0x3A4B.Size = UDim2.new(1, 0, 0, bfn and 64 or 44) _0x3A4B.BackgroundTransparency = 1 _0x3A4B.Parent = parent
    local _0x104C = Instance.new("TextLabel")
    _0x104C.Size = UDim2.new(0.7, 0, 0, 16)
    if _0xEB70 then _0x104C.Position = UDim2.new(0, 16, 0, 0) end
    _0x104C.BackgroundTransparency = 1 _0x104C.Font = Enum.Font.Gotham _0x104C.Text = tostring(text)
    _0x104C.TextSize = 11 _0x104C.TextColor3 = _0x97CF.Text _0x104C.TextXAlignment = Enum.TextXAlignment.Left _0x104C.Parent = _0x3A4B
    local _0x8C41 = Instance.new("TextLabel")
    _0x8C41.Size = UDim2.new(0.3, 0, 0, 16) _0x8C41.Position = UDim2.new(0.7, 0, 0, 0)
    _0x8C41.BackgroundTransparency = 1 _0x8C41.Font = Enum.Font.GothamBold _0x8C41.TextSize = 11
    _0x8C41.TextColor3 = _0x97CF.Accent3 _0x8C41.TextXAlignment = Enum.TextXAlignment.Right _0x8C41.Parent = _0x3A4B
    local _0x5D38 = Instance.new("Frame")
    _0x5D38.Size = UDim2.new(1, 0, 0, 4) _0x5D38.Position = UDim2.new(0, 0, 0, 26)
    _0x5D38.BackgroundColor3 = _0x97CF.PanelLight _0x5D38.BorderSizePixel = 0 _0x5D38.Parent = _0x3A4B
    _0xE1D1(_0x5D38, 2)
    local _0x6EA8 = Instance.new("Frame")
    _0x6EA8.Size = UDim2.new(0, 0, 1, 0) _0x6EA8.BackgroundColor3 = _0x97CF.Accent _0x6EA8.BorderSizePixel = 0 _0x6EA8.Parent = _0x5D38
    _0xE1D1(_0x6EA8, 2)
    local _0x830D = Instance.new("Frame")
    _0x830D.Size = UDim2.new(0, 12, 0, 12) _0x830D.Position = UDim2.new(0, -6, 0.5, -6)
    _0x830D.BackgroundColor3 = _0x97CF.Text _0x830D.BorderSizePixel = 0 _0x830D.ZIndex = 3 _0x830D.Parent = _0x5D38
    _0xE1D1(_0x830D, 6) _0x80E5(_0x830D, _0x97CF.Accent, 2, 0)
    local _0x70E0 = "%.0f"
    if step and step < 1 then _0x70E0 = "%.2f" end
    local _0xB8C8 = false
    local function _0x582D(x)
        if _0xF9E8 then return end
        local _0xE96E = _0x5D38.AbsolutePosition.X
        local _0x41E5 = _0x5D38.AbsoluteSize.X
        if _0x41E5 <= 0 then return end
        local _0xA616 = math.clamp((x - _0xE96E) / _0x41E5, 0, 1)
        local _0xD392 = mn + (_0xA856 - mn) * _0xA616
        if step and step > 0 then _0xD392 = math.round(_0xD392 / step) * step end
        _0x77AD[_0x6260] = _0xD392
        _0x8C41.Text = string.format(_0x70E0, _0xD392)
        _0x6EA8.Size = UDim2.new(_0xA616, 0, 1, 0)
        _0x830D.Position = UDim2.new(_0xA616, -6, 0.5, -6)
        if bfn then
            local _0xDF7B, _0xD871 = pcall(bfn, _0xD392)
            if _0xDF7B and _0xD871 then _0x8C41.Text = tostring(_0xD871) end
        end
        _0x9CA3()
    end
    local _0x78ED = Instance.new("TextButton")
    _0x78ED.Size = UDim2.new(1, 0, 0, 16) _0x78ED.Position = UDim2.new(0, 0, 0, 20)
    _0x78ED.BackgroundTransparency = 1 _0x78ED.Text = "" _0x78ED.Parent = _0x3A4B
    _0x78ED.InputBegan:Connect(function(_0xAE2A)
        if _0xF9E8 then pcall(_0x6E22) return end
        if _0xAE2A.UserInputType == Enum.UserInputType.MouseButton1 or _0xAE2A.UserInputType == Enum.UserInputType.Touch then
            _0xB8C8 = true _0x582D(_0xAE2A.Position.X)
        end
    end)
    _0x55FF.Track(_0xA548.InputChanged:Connect(function(_0xAE2A)
        if _0xB8C8 and (_0xAE2A.UserInputType == Enum.UserInputType.MouseMovement or _0xAE2A.UserInputType == Enum.UserInputType.Touch) then _0x582D(_0xAE2A.Position.X) end
    end))
    _0x55FF.Track(_0xA548.InputEnded:Connect(function(_0xAE2A)
        if _0xAE2A.UserInputType == Enum.UserInputType.MouseButton1 or _0xAE2A.UserInputType == Enum.UserInputType.Touch then _0xB8C8 = false end
    end))
    local _0xF1C9 = math.clamp((_0x77AD[_0x6260] - mn) / (_0xA856 - mn), 0, 1)
    _0x8C41.Text = string.format(_0x70E0, _0x77AD[_0x6260])
    _0x6EA8.Size = UDim2.new(_0xF1C9, 0, 1, 0)
    _0x830D.Position = UDim2.new(_0xF1C9, -6, 0.5, -6)
    if bfn then
        local _0xDF7B, _0xD871 = pcall(bfn, _0x77AD[_0x6260])
        if _0xDF7B and _0xD871 then _0x8C41.Text = tostring(_0xD871) end
    end
    return _0x3A4B
end
local function _0xAA0B(parent, text, _0x2CBA, styl)
    styl = styl or "default"
    local _0x3A50, _0xA771, _0x9C04 = _0x97CF.Card, _0x97CF.PanelLight, _0x97CF.Text
    if styl == "danger" then _0x3A50 = Color3.fromRGB(60, 22, 28) _0xA771 = Color3.fromRGB(90, 30, 38) _0x9C04 = Color3.fromRGB(255, 200, 200)
    elseif styl == "accent" then _0x3A50 = _0x97CF.Accent _0xA771 = _0x97CF.Accent:Lerp(Color3.new(1, 1, 1), 0.15)
    elseif styl == "discord" then _0x3A50 = _0x97CF.Discord _0xA771 = Color3.fromRGB(110, 122, 255) _0x9C04 = Color3.fromRGB(255, 255, 255) end
    local _0x2EAC = Instance.new("TextButton")
    _0x2EAC.Size = UDim2.new(1, 0, 0, 30) _0x2EAC.BackgroundColor3 = _0x3A50 _0x2EAC.BorderSizePixel = 0
    _0x2EAC.Font = Enum.Font.GothamMedium _0x2EAC.Text = tostring(text) _0x2EAC.TextSize = 12
    _0x2EAC.TextColor3 = _0x9C04 _0x2EAC.AutoButtonColor = false _0x2EAC.Parent = parent
    _0xE1D1(_0x2EAC, 8)
    if styl ~= "accent" and styl ~= "discord" then _0x80E5(_0x2EAC, _0x97CF.Border, 1, 0.4) end
    _0x2EAC.MouseEnter:Connect(function() _0xFB97:Create(_0x2EAC, TweenInfo.new(0.15), {BackgroundColor3 = _0xA771}):Play() end)
    _0x2EAC.MouseLeave:Connect(function() _0xFB97:Create(_0x2EAC, TweenInfo.new(0.15), {BackgroundColor3 = _0x3A50}):Play() end)
    _0x2EAC.MouseButton1Click:Connect(function() if _0x2CBA then _0x2CBA(_0x2EAC) end end)
    return _0x2EAC
end
local function _0xC3F2(parent, _0x57CD, _0x6260, _0x9D43)
    local _0x3A4B = Instance.new("Frame")
    _0x3A4B.Size = UDim2.new(1, 0, 0, 48) _0x3A4B.BackgroundTransparency = 1 _0x3A4B.Parent = parent
    local _0x104C = Instance.new("TextLabel")
    _0x104C.Size = UDim2.new(1, 0, 0, 16) _0x104C.BackgroundTransparency = 1
    _0x104C.Font = Enum.Font.Gotham _0x104C.Text = tostring(_0x57CD) _0x104C.TextSize = 11
    _0x104C.TextColor3 = _0x97CF.Text _0x104C.TextXAlignment = Enum.TextXAlignment.Left _0x104C.Parent = _0x3A4B
    local _0x830D = Instance.new("Frame")
    _0x830D.Size = UDim2.new(1, 0, 0, 24) _0x830D.Position = UDim2.new(0, 0, 0, 20)
    _0x830D.BackgroundColor3 = _0x97CF.Card _0x830D.BorderSizePixel = 0 _0x830D.Parent = _0x3A4B
    _0xE1D1(_0x830D, 6) _0x80E5(_0x830D, _0x97CF.Border, 1, 0.4)
    local _0xFA03 = 1 / #_0x9D43
    local _0x2D92 = {}
    for _0x9236, opt in ipairs(_0x9D43) do
        local _0x2EAC = Instance.new("TextButton")
        _0x2EAC.Size = UDim2.new(_0xFA03, 0, 1, 0) _0x2EAC.Position = UDim2.new(_0xFA03 * (_0x9236 - 1), 0, 0, 0)
        _0x2EAC.BackgroundTransparency = 1 _0x2EAC.Font = Enum.Font.GothamMedium _0x2EAC.TextSize = 10
        _0x2EAC.TextColor3 = _0x97CF.TextMuted _0x2EAC.Text = tostring(opt) _0x2EAC.AutoButtonColor = false _0x2EAC.Parent = _0x830D
        _0x2EAC.MouseButton1Click:Connect(function()
            _0x77AD[_0x6260] = opt
            for _0x5B5D, bb in pairs(_0x2D92) do
                if _0x5B5D == opt then bb.TextColor3 = _0x97CF.Text else bb.TextColor3 = _0x97CF.TextMuted end
            end
            _0x9CA3()
        end)
        _0x2D92[opt] = _0x2EAC
        if _0x77AD[_0x6260] == opt then _0x2EAC.TextColor3 = _0x97CF.Text end
    end
    return _0x3A4B
end
local function _0x3169(parent, _0x57CD, _0x6260, order, cmap)
    local _0xA100 = Instance.new("Frame")
    _0xA100.Size = UDim2.new(1, 0, 0, 34) _0xA100.BackgroundTransparency = 1 _0xA100.Parent = parent
    local _0x104C = Instance.new("TextLabel")
    _0x104C.Size = UDim2.new(0.4, 0, 1, 0) _0x104C.BackgroundTransparency = 1
    _0x104C.Font = Enum.Font.Gotham _0x104C.Text = tostring(_0x57CD) _0x104C.TextSize = 12
    _0x104C.TextColor3 = _0x97CF.Text _0x104C.TextXAlignment = Enum.TextXAlignment.Left _0x104C.Parent = _0xA100
    local _0x830D = Instance.new("Frame")
    _0x830D.Size = UDim2.new(0.6, 0, 1, 0) _0x830D.Position = UDim2.new(0.4, 0, 0, 0)
    _0x830D.BackgroundTransparency = 1 _0x830D.Parent = _0xA100
    local _0x2900 = Instance.new("UIListLayout")
    _0x2900.FillDirection = Enum.FillDirection.Horizontal
    _0x2900.HorizontalAlignment = Enum.HorizontalAlignment.Right
    _0x2900.VerticalAlignment = Enum.VerticalAlignment.Center
    _0x2900.Padding = UDim.new(0, 6) _0x2900.Parent = _0x830D
    local _0x2D92 = {}
    local function _0x843F()
        for _0x8E0F, _0x2EAC in pairs(_0x2D92) do
            local _0xD94A = _0x2EAC:FindFirstChildOfClass("UIStroke")
            if _0xD94A then
                if _0x77AD[_0x6260] == _0x8E0F then _0xD94A.Thickness = 2 _0xD94A.Color = _0x97CF.Accent _0xD94A.Transparency = 0
                else _0xD94A.Thickness = 1 _0xD94A.Color = _0x97CF.Border _0xD94A.Transparency = 0.4 end
            end
        end
    end
    for _, _0x8E0F in ipairs(order) do
        local _0x2EAC = Instance.new("TextButton")
        _0x2EAC.Size = UDim2.new(0, 16, 0, 16) _0x2EAC.BackgroundColor3 = cmap[_0x8E0F] or Color3.fromRGB(255, 255, 255)
        _0x2EAC.BorderSizePixel = 0 _0x2EAC.Text = "" _0x2EAC.AutoButtonColor = false _0x2EAC.Parent = _0x830D
        _0xE1D1(_0x2EAC, 8)
        if _0x8E0F == "RGB" then
            local _0x1AA4 = Instance.new("UIGradient")
            _0x1AA4.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
            }
            _0x1AA4.Parent = _0x2EAC
        end
        local _0xD94A = Instance.new("UIStroke")
        _0xD94A.Thickness = 1 _0xD94A.Color = _0x97CF.Border _0xD94A.Transparency = 0.4 _0xD94A.Parent = _0x2EAC
        _0x2EAC.MouseButton1Click:Connect(function() _0x77AD[_0x6260] = _0x8E0F _0x843F() end)
        _0x2D92[_0x8E0F] = _0x2EAC
    end
    _0x843F()
    return _0xA100
end
local function _0x6A58(parent, _0x57CD, tKey, cKey, mKey)
    local _0xA100 = Instance.new("Frame")
    _0xA100.Size = UDim2.new(1, 0, 0, 30) _0xA100.BackgroundTransparency = 1 _0xA100.Parent = parent
    local _0x104C = Instance.new("TextLabel")
    _0x104C.Size = UDim2.new(1, -130, 1, 0) _0x104C.BackgroundTransparency = 1
    _0x104C.Font = Enum.Font.Gotham _0x104C.Text = tostring(_0x57CD) _0x104C.TextSize = 12
    _0x104C.TextColor3 = _0x97CF.Text _0x104C.TextXAlignment = Enum.TextXAlignment.Left _0x104C.Parent = _0xA100
    local _0x2EAC = Instance.new("TextButton")
    _0x2EAC.Size = UDim2.new(0, 110, 0, 22) _0x2EAC.Position = UDim2.new(1, -110, 0.5, -11)
    _0x2EAC.BackgroundColor3 = _0x97CF.Card _0x2EAC.BorderSizePixel = 0
    _0x2EAC.Font = Enum.Font.GothamMedium _0x2EAC.TextSize = 11 _0x2EAC.TextColor3 = _0x97CF.Text
    _0x2EAC.AutoButtonColor = false _0x2EAC.Parent = _0xA100
    _0xE1D1(_0x2EAC, 6) _0x80E5(_0x2EAC, _0x97CF.Border, 1, 0.4)
    local function _0x7BF5()
        if _0x77AD[tKey] == "Mouse" then return tostring(_0x77AD[mKey]):gsub("Enum.UserInputType.", "") end
        return tostring(_0x77AD[cKey]):gsub("Enum.KeyCode.", "")
    end
    local _0xB0D5 = false
    local _0xA792 = nil
    _0x2EAC.MouseButton1Click:Connect(function()
        if _0xB0D5 then _0xB0D5 = false _0x2EAC.Text = _0x7BF5() if _0xA792 then pcall(function() _0xA792:Disconnect() end) _0xA792 = nil end return end
        _0xB0D5 = true _0x2EAC.Text = "press any key..." _0x2EAC.BackgroundColor3 = _0x97CF.Accent
        _0xA792 = _0xA548.InputBegan:Connect(function(_0xAE2A)
            if _0xAE2A.UserInputType == Enum.UserInputType.MouseButton1 then return end
            if _0xAE2A.UserInputType == Enum.UserInputType.MouseButton2 or _0xAE2A.UserInputType == Enum.UserInputType.MouseButton3 then
                _0x77AD[tKey] = "Mouse" _0x77AD[mKey] = _0xAE2A.UserInputType
            elseif _0xAE2A.UserInputType == Enum.UserInputType.Keyboard then
                _0x77AD[tKey] = "Key" _0x77AD[cKey] = _0xAE2A.KeyCode
            else return end
            _0xB0D5 = false _0x2EAC.Text = _0x7BF5() _0x2EAC.BackgroundColor3 = _0x97CF.Card
            if _0xA792 then pcall(function() _0xA792:Disconnect() end) _0xA792 = nil end
        end)
    end)
    _0x2EAC.Text = _0x7BF5()
    return _0xA100
end
local function _0xE439(sec)
    if not sec or sec <= 0 then return "Expired" end
    local _0x3748 = math.floor(sec / 86400)
    local _0x830D = math.floor((sec % 86400) / 3600)
    local _0x4D37 = math.floor((sec % 3600) / 60)
    local _0x0404 = math.floor(sec % 60)
    if _0x3748 > 0 then return string.format("%dd %dh", _0x3748, _0x830D) end
    if _0x830D > 0 then return string.format("%dh %dm", _0x830D, _0x4D37) end
    return string.format("%dm %ds", _0x4D37, _0x0404)
end

function _0xB457.BuildVisualsTab(parent)
    _0x9E48(parent, "ESP")
    _0x4201(parent, "Enable Visuals", "VisualsEnabled")
    _0x7F2D(parent, "Show Boxes", "ShowBoxes", "BoxColor")
    _0x4201(parent, "Show Names", "ShowNames")
    _0x4201(parent, "Show Health", "ShowHealth")
    _0x4201(parent, "Show Distance", "ShowDistance")
    _0x7F2D(parent, "Show Skeleton", "ShowSkeleton", "SkeletonColor")
    _0x6C63(parent, "Extras")
    _0x4201(parent, "Sky Changer", "SkyChangerEnabled")
    _0x4201(parent, "ESP Target Visibility", "ESPTargetVisEnabled")
    _0x4201(parent, "Viewmodel Chams", "ViewmodelChamsEnabled")
    _0x4201(parent, "Night Vision", "NightVisionEnabled", _0x6EEB)
    _0x9E48(parent, "Interface")
    _0x4201(parent, "Show Watermark", "WatermarkEnabled", function(_0x0207) pcall(_0x8977, _0x0207) end)
end

function _0xB457.BuildCombatTab(parent)
    _0x9E48(parent, "Aimbot")
    _0x4201(parent, "Enable Aimbot", "CameraAssistEnabled")
    _0x4201(parent, "Always On", "CameraAssistAlwaysOn")
    _0x4201(parent, "Use Mouse While Locking", "CameraAssistUseMouseWhileLocking")
    _0x4201(parent, "Rotate Character", "CameraAssistRotateChar")
    _0x6C63(parent, "Modes")
    _0x4201(parent, "Camera Assist", "AimLockEnabled")
    _0x4201(parent, "Ragebot", "RagebotEnabled")
    _0x9E48(parent, "Aim FOV")
    _0xE17A(parent, "Aim FOV", "CameraAssistFOV", 5, 65, 1)
    _0x4201(parent, "Draw FOV Circle", "CameraAssistDrawFOV")
    _0x3169(parent, "FOV Color", "CameraAssistFOVColor", {"White", "Red", "Yellow", "Blue", "Green", "Black", "Cyan", "RGB"}, _0xA3FC.ColorMap)
    _0x9E48(parent, "Keybind")
    _0x6A58(parent, "Aim Key", "AimBindType", "AimKeyCode", "AimMouseButton")
    _0x9E48(parent, "Smoothing")
    _0xE17A(parent, "Smoothing", "CameraAssistSmoothing", 0, 20, 1)
    _0x9E48(parent, "Target")
    _0xC3F2(parent, "Hitbox Mode", "CameraAssistHitboxMode", {"Head", "UpperTorso", "Chest", "Random"})
    _0x9E48(parent, "Filters")
    _0x4201(parent, "Team Check", "TeamCheck")
    _0x4201(parent, "Visible Check", "CameraAssistVisibleCheck")
    _0x4201(parent, "FOV Priority", "CameraAssistFOVPriority")
    _0x4201(parent, "Auto Stop on Katana Deflect", "AutoStopOnKatanaDeflect")
    _0x9E48(parent, "Weapon")
    _0x4201(parent, "Auto-Detect Weapon", "WeaponAutoDetect")
    _0x4201(parent, "Use Weapon Profiles", "WeaponProfilesEnabled")
    _0x9E48(parent, "View FOV")
    _0x4201(parent, "Custom View FOV", "ViewFOVEnabled")
    _0xE17A(parent, "View FOV", "ViewFOV", 70, 120, 1)
end

function _0xB457.BuildSilentTab(parent)
    _0x6C63(parent, "Silent Aim")
    _0x4201(parent, "Enable Silent Aim", "SilentAimEnabled")
    _0xE17A(parent, "Hit Chance (%)", "SilentAimHitChance", 0, 100, 1)
    _0xC3F2(parent, "Hitbox Mode", "SilentAimHitbox", {"Head", "UpperTorso", "Chest", "Random"})

    _0x6C63(parent, "Silent FOV")
    _0xE17A(parent, "Silent FOV", "SilentAimFOV", 5, 400, 1)
    _0x4201(parent, "Draw Silent FOV", "SilentAimDrawFOV")
    _0x3169(parent, "FOV Color", "SilentAimFOVColor", {"White", "Red", "Yellow", "Blue", "Green", "Black", "Cyan", "RGB"}, _0xA3FC.ColorMap)

    _0x6C63(parent, "Sniper / Long Range")
    _0xE17A(parent, "Distance Boost", "SilentAimDistanceBoost", 0.0, 2.0, 0.1, function(_0x8C41)
        if _0x8C41 <= 0.2 then return "OFF", Color3.fromRGB(180, 180, 180) end
        if _0x8C41 <= 0.8 then return "LOW", Color3.fromRGB(120, 200, 255) end
        if _0x8C41 <= 1.4 then return "MID", Color3.fromRGB(255, 190, 60) end
        return "MAX", Color3.fromRGB(255, 120, 90)
    end)
    _0x4201(parent, "Convergence Snap", "SilentAimConvergenceSnap")
    _0x4201(parent, "Tight Deadzone (far targets)", "SilentAimTightDeadzone")

    _0x6C63(parent, "Info")
    local _0x05AC = Instance.new("TextLabel")
    _0x05AC.Size = UDim2.new(1, 0, 0, 60) _0x05AC.BackgroundTransparency = 1
    _0x05AC.Font = Enum.Font.Gotham _0x05AC.TextSize = 10
    _0x05AC.TextColor3 = _0x97CF.TextMuted _0x05AC.TextWrapped = true
    _0x05AC.TextXAlignment = Enum.TextXAlignment.Left
    _0x05AC.TextYAlignment = Enum.TextYAlignment.Top
    _0x05AC.Text = "Distance Boost raises pull strength on far targets. Convergence Snap commits the aim inside the last few degrees so the shot lands. Tight Deadzone shrinks the stop angle for far targets where the head subtends less than a tenth of a degree."
    _0x05AC.Parent = parent
end

function _0xB457.BuildTriggerTab(parent)
    _0x9E48(parent, "Triggerbot")
    _0x4201(parent, "Enable Triggerbot", "AutoFireEnabled")
    _0x4201(parent, "Always On", "AutoFireAlwaysOn")
    _0x9E48(parent, "Keybind")
    _0x6A58(parent, "Fire Key", "AutoFireBindType", "AutoFireKeyCode", "AutoFireMouseButton")
    _0x9E48(parent, "Timing")
    _0xE17A(parent, "Fire Delay", "AutoFireDelay", 0.01, 0.5, 0.01)
    _0x9E48(parent, "Range")
    _0xE17A(parent, "Max Distance", "AutoFireMaxDistance", 100, 2000, 50)
    _0x4201(parent, "Proximity Fallback", "AutoFireProximityFallback")
    _0xE17A(parent, "Proximity Angle", "AutoFireProximityAngle", 1.0, 8.0, 0.1)
end

function _0xB457.BuildModsTab(parent)
    _0x9E48(parent, "Movement")
    _0x4201(parent, "Fly", "FlyEnabled")
    _0xE17A(parent, "Fly Speed", "FlySpeed", 10, 80, 5)
    _0x4201(parent, "Speed Hack", "SpeedEnabled")
    _0xE17A(parent, "Walk Speed", "SpeedValue", 16, 500, 1)
    _0x4201(parent, "Infinite Jump", "InfJumpEnabled")
    _0x4201(parent, "Noclip", "NoclipEnabled")
    _0x9E48(parent, "Recoil & Effects")
    _0x4201(parent, "No Recoil", "NoRecoilEnabled")
    _0x4201(parent, "Anti Flash", "AntiFlashEnabled")
    _0x9E48(parent, "Weapon Tweaks")
    _0x4201(parent, "Hitbox Expander", "HitboxExpanderEnabled")
    _0xE17A(parent, "Expander Size", "HitboxExpanderSize", 1.0, 5.0, 0.1)
    _0x6C63(parent, "Combat Extras")
    _0x4201(parent, "Rapid Fire", "RapidFireEnabled")
    _0x4201(parent, "Max Accuracy", "MaxAccuracyEnabled")
    _0x4201(parent, "No Spread", "NoSpreadEnabled")
    _0x4201(parent, "Spinbot", "SpinbotEnabled")
    _0x4201(parent, "Custom Crosshair", "CustomCrosshairEnabled")
    _0x6C63(parent, "Fun")
    _0x4201(parent, "Hit Sounds", "HitSoundsEnabled")
    local _0xA3FF = {"Vine Boom", "Mega Knight", "MLG Airhorn", "Boom Headshot", "Taco Bell"}
    local _0xCE35 = Instance.new("Frame")
    _0xCE35.Size = UDim2.new(1, 0, 0, 24) _0xCE35.BackgroundColor3 = _0x7CB3.BtnBg
    _0xCE35.BorderSizePixel = 0 _0xCE35.Parent = parent
    _0xE1D1(_0xCE35, 6) _0x80E5(_0xCE35, _0x7CB3.Stroke, 1, 0.4)
    local _0xF801 = 1 / #_0xA3FF
    local _0x8897 = {}
    for _0x9236, _0x8E0F in ipairs(_0xA3FF) do
        local _0x2EAC = Instance.new("TextButton")
        _0x2EAC.Size = UDim2.new(_0xF801, 0, 1, 0) _0x2EAC.Position = UDim2.new(_0xF801 * (_0x9236 - 1), 0, 0, 0)
        _0x2EAC.BackgroundTransparency = 1 _0x2EAC.Font = Enum.Font.GothamMedium _0x2EAC.TextSize = 9
        _0x2EAC.TextColor3 = _0x7CB3.TextMuted _0x2EAC.Text = _0x8E0F _0x2EAC.AutoButtonColor = false _0x2EAC.Parent = _0xCE35
        _0x2EAC.MouseButton1Click:Connect(function()
            if not _0x77AD.IsPremium then pcall(_0x6E22) return end
            _0x77AD.HitSoundChoice = _0x8E0F
            for _0x5B5D, bb in pairs(_0x8897) do
                if _0x5B5D == _0x8E0F then bb.TextColor3 = _0x7CB3.Text else bb.TextColor3 = _0x7CB3.TextMuted end
            end
            _0x9CA3()
        end)
        _0x8897[_0x8E0F] = _0x2EAC
        if _0x77AD.HitSoundChoice == _0x8E0F then _0x2EAC.TextColor3 = _0x7CB3.Text end
    end
end

function _0xB457.BuildConfigTab(parent)
    _0x9E48(parent, "Interface")
    _0x6A58(parent, "Menu Key", "MenuBindType", "MenuKey", "MenuMouseButton")
    _0x9E48(parent, "Performance Tools")
    _0x4201(parent, "FPS Boost", "FPSBoostEnabled", function(_0x0207)
        if _0x0207 then pcall(_0xE5C4.EnableFPSBoost) else pcall(_0xE5C4.DisableFPSBoost) end
    end)
    _0xE17A(parent, "Max Render Distance", "MaxRenderDistance", 200, 2000, 50)
    _0x9E48(parent, "Premium Key \226\152\133")
    local _0xD9E2 = Instance.new("TextBox")
    _0xD9E2.Size = UDim2.new(1, 0, 0, 34) _0xD9E2.BackgroundColor3 = _0x7CB3.BtnBg
    _0xD9E2.BorderSizePixel = 0 _0xD9E2.Font = Enum.Font.GothamMedium
    _0xD9E2.TextSize = 12 _0xD9E2.TextColor3 = _0x7CB3.Text
    _0xD9E2.PlaceholderText = "VL-XXXXXXXXX"
    _0xD9E2.PlaceholderColor3 = _0x7CB3.TextMuted _0xD9E2.Text = ""
    _0xD9E2.ClearTextOnFocus = false _0xD9E2.TextXAlignment = Enum.TextXAlignment.Left _0xD9E2.Parent = parent
    _0xE1D1(_0xD9E2, 6)
    local _0x81AB = Instance.new("UIPadding")
    _0x81AB.PaddingLeft = UDim.new(0, 10) _0x81AB.PaddingRight = UDim.new(0, 10) _0x81AB.Parent = _0xD9E2
    _0xAA0B(parent, "Redeem Premium Key", function(_0x78ED)
        local _0x6260 = tostring(_0xD9E2.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if _0x6260 == "" then _0xC488.Show("Enter a key first", false) return end
        local _0xDF7B = _0xB7CC.Validate(_0x6260)
        if _0xDF7B and _0x77AD.IsPremium then
            _0x78ED.Text = "Activated: " .. _0x77AD.PremiumTier
            _0xD9E2.Text = ""
            task.wait(2) _0x78ED.Text = "Redeem Premium Key"
        else
            _0x78ED.Text = "Not a valid premium key"
            task.wait(2) _0x78ED.Text = "Redeem Premium Key"
        end
    end, "accent")
    _0x9E48(parent, "License Status")
    local _0xFEF8 = Instance.new("Frame")
    _0xFEF8.Size = UDim2.new(1, 0, 0, 50) _0xFEF8.BackgroundColor3 = _0x7CB3.BtnBg
    _0xFEF8.BackgroundTransparency = 0.3 _0xFEF8.BorderSizePixel = 0 _0xFEF8.Parent = parent
    _0xE1D1(_0xFEF8, 6) _0x80E5(_0xFEF8, _0x7CB3.Stroke, 1, 0.3)
    local _0x0241 = Instance.new("TextLabel")
    _0x0241.Size = UDim2.new(1, -16, 0, 16) _0x0241.Position = UDim2.new(0, 8, 0, 6)
    _0x0241.BackgroundTransparency = 1 _0x0241.Font = Enum.Font.GothamBold
    _0x0241.TextSize = 11 _0x0241.TextColor3 = _0x7CB3.Accent3
    _0x0241.TextXAlignment = Enum.TextXAlignment.Left
    _0x0241.Text = "Type: --" _0x0241.Parent = _0xFEF8
    local _0x6FB4 = Instance.new("TextLabel")
    _0x6FB4.Size = UDim2.new(1, -16, 0, 16) _0x6FB4.Position = UDim2.new(0, 8, 0, 24)
    _0x6FB4.BackgroundTransparency = 1 _0x6FB4.Font = Enum.Font.Gotham
    _0x6FB4.TextSize = 11 _0x6FB4.TextColor3 = _0x7CB3.TextMuted
    _0x6FB4.TextXAlignment = Enum.TextXAlignment.Left
    _0x6FB4.Text = "Time Remaining: --" _0x6FB4.Parent = _0xFEF8
    _0x55FF.Track(_0xB932.Heartbeat:Connect(function()
        if _0x1996.ShuttingDown or not _0xFEF8.Parent then return end
        if _0x77AD.IsPremium and _0x77AD.PremiumExpiry > 0 then
            local _0xEFA2 = _0x77AD.PremiumExpiry - os.time()
            if _0xEFA2 <= 0 then
                _0x77AD.IsPremium = false _0x77AD.PremiumTier = nil
                _0x77AD.PremiumExpiry = 0 _0x77AD.PremiumKey = nil
                _0x0241.Text = "Type: Expired" _0x0241.TextColor3 = _0x7CB3.Danger
                _0x6FB4.Text = "Time Remaining: --"
            else
                _0x0241.Text = "Type: Premium \226\152\133 " .. tostring(_0x77AD.PremiumTier or "")
                _0x0241.TextColor3 = _0x7CB3.Gold
                _0x6FB4.Text = "Time Remaining: " .. _0xE439(_0xEFA2)
            end
        else
            local _0x47F4, _0x0C4D = _0xB7CC.ReadSaved()
            if _0x47F4 and _0x0C4D and _0x0C4D > os.time() then
                _0x0241.Text = "Type: Work.ink Key" _0x0241.TextColor3 = _0x7CB3.Accent3
                _0x6FB4.Text = "Time Remaining: " .. _0xE439(_0x0C4D - os.time())
            else
                _0x0241.Text = "Type: --" _0x0241.TextColor3 = _0x7CB3.TextMuted
                _0x6FB4.Text = "Time Remaining: --"
            end
        end
    end))
    _0x9E48(parent, "Configuration")
    _0xAA0B(parent, "Save Config", function(_0x78ED)
        local _0xDF7B = _0x77AD:Save()
        local _0x5B5D = _0x78ED.Text _0x78ED.Text = _0xDF7B and "Saved" or "Failed"
        task.wait(1.2) _0x78ED.Text = _0x5B5D
    end, "accent")
    _0xAA0B(parent, "Load Config", function(_0x78ED)
        local _0xDF7B = _0x77AD:Load()
        local _0x5B5D = _0x78ED.Text _0x78ED.Text = _0xDF7B and "Loaded" or "No Save"
        task.wait(1.2) _0x78ED.Text = _0x5B5D
    end)
    _0x9E48(parent, "Community")
    _0xAA0B(parent, "Join Discord", function(_0x78ED)
        local _0x5B5D = _0x78ED.Text
        if type(setclipboard) == "function" then pcall(setclipboard, "https://discord.gg/K3vgcVsCsS") _0x78ED.Text = "Link copied" end
        task.wait(1.6) _0x78ED.Text = _0x5B5D
    end, "discord")
    _0x9E48(parent, "System")
    _0xAA0B(parent, "Unload VEIL", function() _0xB457.Unload() end, "danger")
end

function _0xB457.Create()
    local _0xFA03 = _0xE472("VEIL_UI", 5000, false)
    if not _0xFA03 then return nil end
    _0xB457.ScreenGui = _0xFA03
    local _0xAD95 = Instance.new("Frame")
    _0xAD95.Name = "Main"
    _0xAD95.Size = UDim2.new(0, 700, 0, 480)
    _0xAD95.Position = UDim2.new(0.5, -350, 0.5, -240)
    _0xAD95.BackgroundColor3 = _0x7CB3.Bg _0xAD95.BorderSizePixel = 0
    _0xAD95.ClipsDescendants = true _0xAD95.Visible = false _0xAD95.Parent = _0xFA03
    _0xB457.MainFrame = _0xAD95
    _0xE1D1(_0xAD95, 14) _0x80E5(_0xAD95, _0x7CB3.Stroke, 1.5, 0)
    local _0xEAAA = Instance.new("Frame")
    _0xEAAA.Size = UDim2.new(0, 158, 1, -16) _0xEAAA.Position = UDim2.new(0, 8, 0, 8)
    _0xEAAA.BackgroundTransparency = 1 _0xEAAA.Parent = _0xAD95
    local _0x7284 = Instance.new("TextLabel")
    _0x7284.Size = UDim2.new(1, 0, 0, 36) _0x7284.BackgroundTransparency = 1
    _0x7284.Font = Enum.Font.GothamBlack _0x7284.Text = "VEIL" _0x7284.TextSize = 30
    _0x7284.TextColor3 = Color3.fromRGB(255, 255, 255)
    _0x7284.TextXAlignment = Enum.TextXAlignment.Center _0x7284.Parent = _0xEAAA
    _0x9BD5(_0x7284)
    local _0xAA02 = Instance.new("TextLabel")
    _0xAA02.Size = UDim2.new(1, 0, 0, 12) _0xAA02.Position = UDim2.new(0, 0, 0, 34)
    _0xAA02.BackgroundTransparency = 1 _0xAA02.Font = Enum.Font.GothamBold
    _0xAA02.Text = "V 1" _0xAA02.TextSize = 10
    _0xAA02.TextColor3 = Color3.fromRGB(180, 130, 255)
    _0xAA02.TextXAlignment = Enum.TextXAlignment.Center _0xAA02.Parent = _0xEAAA
    _0x9BD5(_0xAA02)
    local _0xECAA = Instance.new("TextLabel")
    _0xECAA.Size = UDim2.new(1, 0, 0, 12) _0xECAA.Position = UDim2.new(0, 0, 0, 48)
    _0xECAA.BackgroundTransparency = 1 _0xECAA.Font = Enum.Font.GothamBold
    _0xECAA.Text = "S E C U R I T Y   S U I T E" _0xECAA.TextSize = 8
    _0xECAA.TextColor3 = _0x7CB3.Accent3 _0xECAA.TextXAlignment = Enum.TextXAlignment.Center _0xECAA.Parent = _0xEAAA
    _0x9BD5(_0xECAA)
    local _0xA7E9 = {"Visuals", "Combat", "Silent", "Trigger", "Mods", "Config"}
    local _0x6207 = {}
    for _0x9236, _0x8E0F in ipairs(_0xA7E9) do
        local _0x2EAC = Instance.new("TextButton")
        _0x2EAC.Size = UDim2.new(1, -12, 0, 30) _0x2EAC.Position = UDim2.new(0, 6, 0, 78 + (_0x9236 - 1) * 36)
        _0x2EAC.BackgroundColor3 = _0x7CB3.BtnBg _0x2EAC.BackgroundTransparency = 0.4 _0x2EAC.BorderSizePixel = 0
        _0x2EAC.Font = Enum.Font.GothamMedium _0x2EAC.Text = _0x8E0F _0x2EAC.TextSize = 12
        _0x2EAC.TextColor3 = _0x7CB3.TextMuted _0x2EAC.AutoButtonColor = false _0x2EAC.Parent = _0xEAAA
        _0xE1D1(_0x2EAC, 8) _0x80E5(_0x2EAC, _0x7CB3.Stroke, 1, 0.3)
        _0x6207[_0x8E0F] = _0x2EAC
        _0xB457.TabButtons[_0x8E0F] = _0x2EAC
    end
    local _0xCA7B = Instance.new("Frame")
    _0xCA7B.Size = UDim2.new(1, -12, 0, 48) _0xCA7B.Position = UDim2.new(0, 6, 1, -56)
    _0xCA7B.BackgroundTransparency = 1 _0xCA7B.Parent = _0xEAAA
    local _0x8960 = Instance.new("Frame")
    _0x8960.Size = UDim2.new(1, 0, 0, 20) _0x8960.BackgroundColor3 = _0x7CB3.BtnBg
    _0x8960.BackgroundTransparency = 0.3 _0x8960.BorderSizePixel = 0 _0x8960.Parent = _0xCA7B
    _0xE1D1(_0x8960, 6) _0x80E5(_0x8960, _0x7CB3.Accent, 1, 0.5)
    local _0x458F = Instance.new("Frame")
    _0x458F.Size = UDim2.fromOffset(6, 6) _0x458F.Position = UDim2.new(0, 8, 0.5, -3)
    _0x458F.BackgroundColor3 = Color3.fromRGB(80, 220, 130) _0x458F.BorderSizePixel = 0 _0x458F.Parent = _0x8960
    _0xE1D1(_0x458F, 3)
    local _0xE369 = Instance.new("TextLabel")
    _0xE369.Size = UDim2.new(1, -22, 1, 0) _0xE369.Position = UDim2.new(0, 20, 0, 0)
    _0xE369.BackgroundTransparency = 1 _0xE369.Font = Enum.Font.GothamBold
    _0xE369.Text = "--- FPS" _0xE369.TextSize = 10 _0xE369.TextColor3 = _0x7CB3.Text
    _0xE369.TextXAlignment = Enum.TextXAlignment.Left _0xE369.Parent = _0x8960
    local _0xB847 = Instance.new("TextLabel")
    _0xB847.Size = UDim2.new(1, 0, 0, 22) _0xB847.Position = UDim2.new(0, 0, 0, 26)
    _0xB847.BackgroundTransparency = 1 _0xB847.Font = Enum.Font.GothamBold
    _0xB847.Text = tostring(_0x76B0.Name) _0xB847.TextSize = 14
    _0xB847.TextColor3 = _0x7CB3.Accent3 _0xB847.TextXAlignment = Enum.TextXAlignment.Center _0xB847.Parent = _0xCA7B
    local _0xBC73, _0xC358 = 0, 0
    _0x55FF.Track(_0xB932.RenderStepped:Connect(function(_0x154F)
        if _0x1996.ShuttingDown or not _0xE369.Parent then return end
        _0xBC73 = _0xBC73 + _0x154F _0xC358 = _0xC358 + 1
        if _0xBC73 >= 0.5 then
            local _0x6EA8 = math.floor(_0xC358 / _0xBC73 + 0.5)
            _0xE369.Text = tostring(_0x6EA8) .. " FPS"
            local _0xE798 = _0x6EA8 >= 90 and Color3.fromRGB(80, 220, 130) or (_0x6EA8 >= 45 and Color3.fromRGB(255, 220, 60) or Color3.fromRGB(255, 80, 100))
            _0x458F.BackgroundColor3 = _0xE798 _0xE369.TextColor3 = _0xE798
            _0xBC73 = 0 _0xC358 = 0
        end
    end))
    local _0x643E = Instance.new("Frame")
    _0x643E.Size = UDim2.new(1, -176, 1, -16) _0x643E.Position = UDim2.new(0, 168, 0, 8)
    _0x643E.BackgroundColor3 = _0x7CB3.BtnBg _0x643E.BackgroundTransparency = 0.7
    _0x643E.BorderSizePixel = 0 _0x643E.Parent = _0xAD95
    _0xE1D1(_0x643E, 10) _0x80E5(_0x643E, _0x7CB3.Stroke, 1.5, 0)
    local _0xAE53 = Instance.new("TextButton")
    _0xAE53.Size = UDim2.fromOffset(24, 24) _0xAE53.Position = UDim2.new(1, -30, 0, 6)
    _0xAE53.BackgroundTransparency = 1 _0xAE53.Font = Enum.Font.GothamBold _0xAE53.Text = "X"
    _0xAE53.TextSize = 14 _0xAE53.TextColor3 = _0x7CB3.Text _0xAE53.AutoButtonColor = false _0xAE53.Parent = _0xAD95
    _0xAE53.MouseButton1Click:Connect(function() _0xAD95.Visible = false end)
    local _0xB8C8 = false dS = nil dP = nil
    _0xAD95.InputBegan:Connect(function(_0xAE2A)
        if _0xAE2A.UserInputType == Enum.UserInputType.MouseButton1 then
            _0xB8C8 = true dS = _0xAE2A.Position dP = _0xAD95.Position
        end
    end)
    _0x55FF.Track(_0xA548.InputChanged:Connect(function(_0xAE2A)
        if _0xB8C8 and _0xAE2A.UserInputType == Enum.UserInputType.MouseMovement then
            local _0x270D = _0xAE2A.Position - dS
            _0xAD95.Position = UDim2.new(dP.X.Scale, dP.X.Offset + _0x270D.X, dP.Y.Scale, dP.Y.Offset + _0x270D.Y)
        end
    end))
    _0x55FF.Track(_0xA548.InputEnded:Connect(function(_0xAE2A)
        if _0xAE2A.UserInputType == Enum.UserInputType.MouseButton1 then _0xB8C8 = false end
    end))
    for _, _0x8E0F in ipairs(_0xA7E9) do
        local _0x9649 = Instance.new("ScrollingFrame")
        _0x9649.Size = UDim2.new(1, -16, 1, -16) _0x9649.Position = UDim2.new(0, 8, 0, 8)
        _0x9649.BackgroundTransparency = 1 _0x9649.BorderSizePixel = 0
        _0x9649.ScrollBarThickness = 3 _0x9649.ScrollBarImageColor3 = _0x7CB3.Accent
        _0x9649.CanvasSize = UDim2.new(0, 0, 0, 0)
        _0x9649.AutomaticCanvasSize = Enum.AutomaticSize.Y _0x9649.Visible = false _0x9649.Parent = _0x643E
        local _0x2900 = Instance.new("UIListLayout")
        _0x2900.Padding = UDim.new(0, 4) _0x2900.SortOrder = Enum.SortOrder.LayoutOrder _0x2900.Parent = _0x9649
        local _0xB680 = Instance.new("UIPadding")
        _0xB680.PaddingTop = UDim.new(0, 4) _0xB680.PaddingBottom = UDim.new(0, 6) _0xB680.PaddingRight = UDim.new(0, 4) _0xB680.Parent = _0x9649
        _0xB457.TabContents[_0x8E0F] = _0x9649
    end
    function _0xB457.SelectTab(_0x8E0F)
        if _0xB457.CurrentTab then
            local _0xBADE = _0x6207[_0xB457.CurrentTab]
            if _0xBADE then _0xFB97:Create(_0xBADE, TweenInfo.new(0.2), {BackgroundColor3 = _0x7CB3.BtnBg, BackgroundTransparency = 0.4, TextColor3 = _0x7CB3.TextMuted}):Play() end
        end
        _0xB457.CurrentTab = _0x8E0F
        local _0x2EAC = _0x6207[_0x8E0F]
        if _0x2EAC then
            _0x2EAC.BackgroundColor3 = _0x7CB3.Accent
            _0xFB97:Create(_0x2EAC, TweenInfo.new(0.2), {BackgroundTransparency = 0.1, TextColor3 = _0x7CB3.Text}):Play()
        end
        for _0xB877, _0x3A4B in pairs(_0xB457.TabContents) do _0x3A4B.Visible = (_0xB877 == _0x8E0F) end
    end
    for _0x8E0F, _0x2EAC in pairs(_0x6207) do _0x2EAC.MouseButton1Click:Connect(function() _0xB457.SelectTab(_0x8E0F) end) end
    pcall(function() _0xB457.BuildVisualsTab(_0xB457.TabContents["Visuals"]) end)
    pcall(function() _0xB457.BuildCombatTab(_0xB457.TabContents["Combat"]) end)
    pcall(function() _0xB457.BuildSilentTab(_0xB457.TabContents["Silent"]) end)
    pcall(function() _0xB457.BuildTriggerTab(_0xB457.TabContents["Trigger"]) end)
    pcall(function() _0xB457.BuildModsTab(_0xB457.TabContents["Mods"]) end)
    pcall(function() _0xB457.BuildConfigTab(_0xB457.TabContents["Config"]) end)
    _0xB457.SelectTab("Visuals")
end

function _0xB457.Unload()
    _0x1996.ShuttingDown = true
    _0x2D8B.Active = false
    if _0x2D8B.UninstallHook then pcall(_0x2D8B.UninstallHook) end
    pcall(function() _0x1996.Unbind() end)
    pcall(function() _0x1996.UnbindViewFOV() end)
    pcall(function() _0x1996.RestorePostFX() end)
    pcall(function() _0xDC48() end)
    pcall(function() _0xE5C4.DisableFPSBoost() end)
    pcall(function()
        local _0x1A90 = _0xE1FF.LocalPlayer
        if _0x1A90 and _0x1A90.Character then
            local _0xD871 = _0x1A90.Character:FindFirstChildOfClass("Tool")
            if _0xD871 and not _0xD871.Enabled then _0xD871.Enabled = true end
            local _0x44C9 = _0x1A90.Character:FindFirstChildOfClass("Humanoid")
            if _0x44C9 then
                pcall(function() _0x44C9.AutoRotate = true end)
                pcall(function() _0x44C9:SetStateEnabled(Enum.HumanoidStateType.Freefall, true) end)
                pcall(function() _0x44C9:SetStateEnabled(Enum.HumanoidStateType.Running, true) end)
                pcall(function() _0x44C9:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
            end
            if _0x1996._neckJoint and _0x1996._neckC0 then
                pcall(function()
                    if _0x1996._neckJoint.Parent then
                        _0x1996._neckJoint.C0 = _0x1996._neckC0
                    end
                end)
            end
            _0x1996._neckJoint = nil _0x1996._neckC0 = nil
        end
    end)
    pcall(function() _0x55FF.DisconnectAll() end)
    _0x77AD.VisualsEnabled = false
    _0x77AD.CameraAssistEnabled = false
    _0x77AD.AutoFireEnabled = false
    pcall(function()
        for _, _0x8C41 in pairs(_0xD16E.Objects) do
            if _0x8C41 then
                if _0x8C41.Container then pcall(function() _0x8C41.Container:Destroy() end) end
                if _0x8C41.SkeletonLines then
                    for _, _0x104C in ipairs(_0x8C41.SkeletonLines) do if _0x104C then pcall(function() _0x104C:Destroy() end) end end
                end
            end
        end
        _0xD16E.Objects = {}
    end)
    pcall(function()
        if _0xD16E.Container then _0xD16E.Container:Destroy() end
        _0xD16E.Container = nil
    end)
    pcall(function() _0xA3FC.Destroy() end)
    pcall(function() if _0xB457.ScreenGui then _0xB457.ScreenGui:Destroy() end end)
    pcall(function() _0x9CA3() end)
    pcall(function() _0x77AD:Save() end)
    pcall(function()
        local _0x14E4 = _0xB27C()
        if _0x14E4 then
            for _, _0x8377 in ipairs(_0x14E4:GetChildren()) do
                local _0xB877 = _0x8377.Name
                if _0xB877 == "VEIL_Startup" or _0xB877 == "VEIL_Watermark" or _0xB877 == "VEIL_Discord"
                    or _0xB877 == "VEIL_Premium" or _0xB877 == "VEIL_MobileOverlay" or _0xB877 == "VEIL_Picker"
                    or _0xB877 == "VEIL_Crosshair" or _0xB877 == "VEIL_KeyUI" or _0xB877 == "VEIL_Popup"
                    or _0xB877 == "VEIL_UI" or _0xB877 == "VEIL_Visuals" or _0xB877 == "VEIL_FOV" then
                    pcall(function() _0x8377:Destroy() end)
                end
            end
        end
    end)
end

-- ============================================================
-- Mobile overlay
-- ============================================================
local _0x453F = nil
local _0x1FFE = function() if _0xB457.MainFrame then _0xB457.MainFrame.Visible = not _0xB457.MainFrame.Visible end end
if _0x9A4D.isMobile then
    local _0x14E4 = _0xB27C()
    if _0x14E4 then
        local _0xFA03 = Instance.new("ScreenGui")
        _0xFA03.Name = "VEIL_MobileOverlay" _0xFA03.ResetOnSpawn = false _0xFA03.IgnoreGuiInset = true
        _0xFA03.ZIndexBehavior = Enum.ZIndexBehavior.Sibling _0xFA03.DisplayOrder = 50
        pcall(function() _0xFA03.Parent = _0x14E4 end)
        local function _0x2146(_0x4BFF, text, px, py, size, _0xE798)
            local _0x2EAC = Instance.new("TextButton")
            _0x2EAC.Name = _0x4BFF _0x2EAC.AnchorPoint = Vector2.new(0.5, 0.5)
            _0x2EAC.Size = UDim2.fromOffset(size, size) _0x2EAC.Position = UDim2.new(px, 0, py, 0)
            _0x2EAC.BackgroundColor3 = _0xE798 _0x2EAC.BackgroundTransparency = 0.35 _0x2EAC.BorderSizePixel = 0
            _0x2EAC.Font = Enum.Font.GothamBold _0x2EAC.TextSize = math.floor(size * 0.22)
            _0x2EAC.TextColor3 = Color3.fromRGB(255, 255, 255) _0x2EAC.Text = text
            _0x2EAC.TextStrokeTransparency = 0.5 _0x2EAC.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            _0x2EAC.AutoButtonColor = false _0x2EAC.Parent = _0xFA03
            local _0x3A4B = Instance.new("UICorner") _0x3A4B.CornerRadius = UDim.new(0.5, 0) _0x3A4B.Parent = _0x2EAC
            return _0x2EAC
        end
        local _0x74F4 = _0x2146("Aim", "AIM", 0.88, 0.55, 100, Color3.fromRGB(220, 60, 90))
        local _0x1D79 = _0x2146("Menu", "MENU", 0.12, 0.10, 70, Color3.fromRGB(99, 102, 241))
        _0x74F4.InputBegan:Connect(function(_0xAE2A)
            if _0xAE2A.UserInputType == Enum.UserInputType.Touch or _0xAE2A.UserInputType == Enum.UserInputType.MouseButton1 then _0x1996.KeyHeld = true end
        end)
        _0x74F4.InputEnded:Connect(function(_0xAE2A)
            if _0xAE2A.UserInputType == Enum.UserInputType.Touch or _0xAE2A.UserInputType == Enum.UserInputType.MouseButton1 then _0x1996.KeyHeld = false end
        end)
        _0x1D79.MouseButton1Click:Connect(_0x1FFE)
        _0x453F = _0xFA03
    end
    _0x77AD.CameraAssistUseMouseWhileLocking = false
    _0x77AD.CameraAssistSmoothing = 10
    _0x77AD.CameraAssistFOV = 30
end

-- ============================================================
-- Anti-Flash
-- ============================================================
local _0xF82F = {
    "flash", "blind", "damage", "hitmark", "hit_", "_hit", "blood",
    "redflash", "whiteflash", "grenade", "flashbang", "concussion",
    "overlay", "vignette", "hurt", "dmg",
}
local function _0x300B(_0xB877)
    if not _0xB877 then return false end
    local _0x104C = _0xB877:lower()
    for _, _0x938C in ipairs(_0xF82F) do if _0x104C:find(_0x938C) then return true end end
    return false
end
local function _0xDAC4()
    local _0xB361 = { killedFX = setmetatable({}, {__mode = "k"}), conns = {}, sweepTask = nil }
    local function _0xEFF8(inst)
        if not _0x77AD.AntiFlashEnabled or not inst or not inst.Parent then return end
        if inst:IsA("ColorCorrectionEffect") or inst:IsA("BrightnessEffect")
            or inst:IsA("BlurEffect") or inst:IsA("DepthOfFieldEffect") then
            if inst.Name == "VEIL_NightVision" then return end
            local _0xA6E8 = _0x300B(inst.Name)
            if not _0xA6E8 and inst:IsA("ColorCorrectionEffect") then
                if (inst.Brightness or 0) > 0.35 then _0xA6E8 = true end
                local _0x9C04 = inst.TintColor
                if _0x9C04 and _0x9C04.R > 0.85 and _0x9C04.G > 0.85 and _0x9C04.B > 0.85 and (inst.Enabled ~= false) then _0xA6E8 = true end
            end
            if not _0xA6E8 and inst:IsA("BrightnessEffect") and (inst.Brightness or 0) > 0.25 then _0xA6E8 = true end
            if _0xA6E8 then pcall(function() inst.Enabled = false end) _0xB361.killedFX[inst] = true end
        end
    end
    for _, ch in ipairs(_0x18A8:GetChildren()) do _0xEFF8(ch) end
    table.insert(_0xB361.conns, _0x18A8.DescendantAdded:Connect(function(ch)
        if not _0x77AD.AntiFlashEnabled then return end
        task.defer(function() _0xEFF8(ch) end)
    end))
    _0xB361.sweepTask = task.spawn(function()
        while not _0x1996.ShuttingDown do
            task.wait(0.33 * _0x7C2F)
            if not _0x77AD.AntiFlashEnabled then continue end
            for _, ch in ipairs(_0x18A8:GetChildren()) do _0xEFF8(ch) end
        end
    end)
    _G.__VEIL_AntiFlash = _0xB361
end

-- ============================================================
-- Initialize
-- ============================================================
local function _0xDFD4()
    if _G.__VEIL_INITIALIZED then return end
    _G.__VEIL_INITIALIZED = true
    pcall(function() _0x77AD:Load() end)
    if _0x77AD.SilentAimEnabled and _0x2D8B.InstallHook then
        pcall(_0x2D8B.InstallHook)
    end
    local _0xD108 = _0x11FD()
    if _0x77AD.WeaponProfilesEnabled and _0x77AD.WeaponAutoDetect then
        _0x51E5 = _0xD108 or "Default"
        _0xA561(_0x51E5)
    else
        _0x51E5 = "Default"
    end
    _0xB457.Create()
    _0xA3FC.Ensure()
    if _0x77AD.FPSBoostEnabled then pcall(_0xE5C4.EnableFPSBoost) end
    pcall(_0xDAC4)
    if _0x77AD.NightVisionEnabled then pcall(_0x6ADF) end
    _0x1996.InitFocusTracking()
    _0x1996.Bind()
    pcall(_0x1996.BindViewFOV)
    _G.__VEIL_BindDeferred = function()
        if _0x1996.Bound then return end
        _0x1996.Bind()
        pcall(_0x1996.BindViewFOV)
    end
    _G.__VEIL_Weapon = {
        get = function() return _0x51E5 end,
        set = function(_0x4BFF) _0x9CA3() _0x51E5 = _0x4BFF _0xA561(_0x4BFF) end,
    }
    _0x55FF.Track(_0xA548.InputBegan:Connect(function(_0xAE2A)
        local _0x73FD = false
        if _0x77AD.MenuBindType == "Mouse" then
            _0x73FD = _0xAE2A.UserInputType == _0x77AD.MenuMouseButton
        else
            _0x73FD = _0xAE2A.UserInputType == Enum.UserInputType.Keyboard and _0xAE2A.KeyCode == _0x77AD.MenuKey
        end
        if not _0x73FD then return end
        if _0xB457.MainFrame then _0xB457.MainFrame.Visible = not _0xB457.MainFrame.Visible end
    end))
    _0x55FF.Track(_0xA548.InputBegan:Connect(function(_0xAE2A)
        if _0x77AD.AutoFireBindType == "Mouse" then
            if _0xAE2A.UserInputType == _0x77AD.AutoFireMouseButton then _0x034E.KeyHeld = true end
        else
            if _0xAE2A.UserInputType == Enum.UserInputType.Keyboard and _0xAE2A.KeyCode == _0x77AD.AutoFireKeyCode then _0x034E.KeyHeld = true end
        end
    end))
    _0x55FF.Track(_0xA548.InputEnded:Connect(function(_0xAE2A)
        if _0x77AD.AutoFireBindType == "Mouse" then
            if _0xAE2A.UserInputType == _0x77AD.AutoFireMouseButton then _0x034E.KeyHeld = false end
        else
            if _0xAE2A.UserInputType == Enum.UserInputType.Keyboard and _0xAE2A.KeyCode == _0x77AD.AutoFireKeyCode then _0x034E.KeyHeld = false end
        end
    end))
    _0x55FF.Track(_0xE1FF.PlayerRemoving:Connect(function(_0x938C)
        _0xD16E.OnPlayerRemoving(_0x938C)
        _0xC036.ClearTeamCache(_0x938C)
    end))
    _0x55FF.Track(_0xB932.RenderStepped:Connect(function()
        if _0x1996.ShuttingDown then return end
        if _0x77AD.VisualsEnabled or next(_0xD16E.Objects) ~= nil then
            pcall(function() _0xD16E.Step() end)
        end
        if _0x77AD.CameraAssistDrawFOV or _0x77AD.SilentAimDrawFOV then
            pcall(function() _0xA3FC.Update() end)
        end
    end))
    local _0x4816 = {}
    local function _0x67F3(_0x4BFF, _0x245B, fn) _0x4816[_0x4BFF] = { _0x245B = _0x245B * _0x7C2F, _0x905F = 0, fn = fn } end
    _0x67F3("silent_flag", 0, function()
        _0x2D8B.Active = _0x77AD.SilentAimEnabled
            and _0x1996.Lock ~= nil
            and _0x1996.Lock.Character ~= nil
            and _0x1996.Lock.Character.Parent ~= nil
    end)
    _0x67F3("input_reconcile", 0, function()
        if not _0x1996.KeyHeld and not _0x034E.KeyHeld then return end
        if _0x1996.KeyHeld then
            local _0x025D = false
            if _0x77AD.AimBindType == "Mouse" then
                pcall(function() _0x025D = _0xA548:IsMouseButtonPressed(_0x77AD.AimMouseButton) end)
            else
                pcall(function() _0x025D = _0xA548:IsKeyDown(_0x77AD.AimKeyCode) end)
            end
            if not _0x025D then _0x1996.KeyHeld = false end
        end
        if _0x034E.KeyHeld then
            local _0x025D = false
            if _0x77AD.AutoFireBindType == "Mouse" then
                pcall(function() _0x025D = _0xA548:IsMouseButtonPressed(_0x77AD.AutoFireMouseButton) end)
            else
                pcall(function() _0x025D = _0xA548:IsKeyDown(_0x77AD.AutoFireKeyCode) end)
            end
            if not _0x025D then _0x034E.KeyHeld = false end
        end
    end)
    _0x67F3("autofire", 0, function()
        if not _0x77AD.AutoFireEnabled then return end
        _0x034E.CheckAndFire()
    end)
    _0x67F3("featureapply", 0.15, function()
        _0xDC8F("aimlock", { enabled = _0x77AD.AimLockEnabled, set = { CameraAssistUseMouseWhileLocking = false } })
        _0xDC8F("ragebot", { enabled = _0x77AD.RagebotEnabled, set = { CameraAssistSmoothing = 0, CameraAssistFOV = 65 } })
        _0xDC8F("rapidfire", { enabled = _0x77AD.RapidFireEnabled, set = { AutoFireDelay = 0.01 } })
        _0xDC8F("accuracy", { enabled = (_0x77AD.MaxAccuracyEnabled or _0x77AD.NoSpreadEnabled), set = { CameraAssistBulletSpeed = 3000, CameraAssistPrediction = true } })
    end)
    _0x67F3("spinbot", 0.05, function()
        local _0x1A90 = _0xE1FF.LocalPlayer
        local _0xE174 = _0x1A90 and _0x1A90.Character and _0x1A90.Character:FindFirstChild("HumanoidRootPart")
        if not _0xE174 then return end
        local _0x6916 = _0xE174:FindFirstChild("VEIL_SpinGyro")
        if _0x77AD.SpinbotEnabled and not _0x1996.Lock then
            if not _0x6916 then
                _0x6916 = Instance.new("BodyGyro")
                _0x6916.Name = "VEIL_SpinGyro" _0x6916.MaxTorque = Vector3.new(0, 10e20, 0)
                _0x6916.P = 1e6 _0x6916.D = 1e5 _0x6916.Parent = _0xE174
                _0x6916.CFrame = _0xE174.CFrame
            end
            _0x6916.CFrame = _0x6916.CFrame * CFrame.Angles(0, math.rad(25), 0)
        elseif _0x6916 then _0x6916:Destroy() end
    end)
    local _0xA5E2 = 0
    _0x55FF.Track(_0xA548.JumpRequest:Connect(function() _0xA5E2 = tick() end))
    _0x67F3("infjump", 0.05, function()
        if not _0x77AD.InfJumpEnabled then return end
        local _0x1A90 = _0xE1FF.LocalPlayer
        local _0x44C9 = _0x1A90 and _0x1A90.Character and _0x1A90.Character:FindFirstChildOfClass("Humanoid")
        if not _0x44C9 then return end
        local _0xB090 = _0xA548:IsKeyDown(Enum.KeyCode.Space)
        if not _0xB090 and (tick() - _0xA5E2) > 0.15 then return end
        pcall(function() _0x44C9:ChangeState(Enum.HumanoidStateType.Jumping) end)
        pcall(function() _0x44C9.Jump = true end)
    end)
    local _0x924F = {}
    local _0x7357 = false
    _0x67F3("noclip", 0.15, function()
        local _0x1A90 = _0xE1FF.LocalPlayer
        local _0xE895 = _0x1A90 and _0x1A90.Character
        if not _0xE895 then _0x924F = {} _0x7357 = false return end
        local _0xF184 = _0x77AD.NoclipEnabled or _0x77AD.FlyNoclipEnabled
        if _0xF184 then
            _0x7357 = true
            if _0x77AD.FlyNoclipEnabled then _0x77AD.FlyEnabled = true end
            for _, _0x938C in ipairs(_0xE895:GetDescendants()) do
                if _0x938C:IsA("BasePart") and not _0x924F[_0x938C] then _0x924F[_0x938C] = _0x938C.CanCollide _0x938C.CanCollide = false end
            end
        elseif _0x7357 then
            for _0x7AA7, state in pairs(_0x924F) do pcall(function() _0x7AA7.CanCollide = state end) end
            _0x924F = {} _0x7357 = false
        end
    end)
    local _0xED98 = {}
    local _0x6B0D = nil
    local _0xC4E0 = nil
    _0x67F3("chams", 0.08, function()
        local _0x1A90 = _0xE1FF.LocalPlayer
        local _0xE895 = _0x1A90 and _0x1A90.Character
        local _0x9EEE = _0xE895 and _0xE895:FindFirstChildOfClass("Tool")
        if not _0x77AD.ViewmodelChamsEnabled then
            if _0x6B0D then
                for _0x7AA7, _0x67E3 in pairs(_0xED98) do pcall(function() _0x7AA7.Material = _0x67E3.m _0x7AA7.Color = _0x67E3.c end) end
                _0xED98 = {} _0x6B0D = nil _0xC4E0 = nil
            end
            return
        end
        local _0x6FFD = _0x7CB3.Accent
        if _0x9EEE and _0x9EEE ~= _0x6B0D then
            for _0x7AA7, _0x67E3 in pairs(_0xED98) do pcall(function() _0x7AA7.Material = _0x67E3.m _0x7AA7.Color = _0x67E3.c end) end
            _0xED98 = {} _0x6B0D = _0x9EEE _0xC4E0 = _0x6FFD
            for _, _0x938C in ipairs(_0x9EEE:GetDescendants()) do
                if _0x938C:IsA("BasePart") then
                    _0xED98[_0x938C] = { _0x4D37 = _0x938C.Material, _0x3A4B = _0x938C.Color }
                    _0x938C.Material = Enum.Material.Neon
                    _0x938C.Color = _0x6FFD
                end
            end
        elseif _0x9EEE and _0xC4E0 ~= _0x6FFD then
            _0xC4E0 = _0x6FFD
            for _0x7AA7, _ in pairs(_0xED98) do
                if _0x7AA7.Parent then pcall(function() _0x7AA7.Color = _0x6FFD end) end
            end
        end
    end)
    local _0x6513 = false
    _0x67F3("sky", 1.0, function()
        local _0x21A6 = _0x77AD.SkyChangerEnabled
        if _0x21A6 == _0x6513 then return end
        _0x6513 = _0x21A6
        if _0x21A6 then
            if not _0x18A8:FindFirstChild("VEIL_Sky") then
                local _0x0E85 = Instance.new("Sky")
                _0x0E85.Name = "VEIL_Sky"
                _0x0E85.SkyboxBk = "rbxassetid://159454299" _0x0E85.SkyboxDn = "rbxassetid://159454296"
                _0x0E85.SkyboxFt = "rbxassetid://159454293" _0x0E85.SkyboxLf = "rbxassetid://159454286"
                _0x0E85.SkyboxRt = "rbxassetid://159454300" _0x0E85.SkyboxUp = "rbxassetid://159454288"
                _0x0E85.Parent = _0x18A8
            end
        else
            local _0x0E85 = _0x18A8:FindFirstChild("VEIL_Sky")
            if _0x0E85 then _0x0E85:Destroy() end
        end
    end)
    local _0x187F = false
    _0x67F3("crosshair", 1.0, function()
        local _0x21A6 = _0x77AD.CustomCrosshairEnabled and _0x77AD.IsPremium
        if _0x21A6 == _0x187F then return end
        _0x187F = _0x21A6
        if _0x21A6 then
            local _0xFA03 = _0xE472("VEIL_Crosshair", 150, true)
            if _0xFA03 then
                local _0x74DC = Instance.new("Frame")
                _0x74DC.AnchorPoint = Vector2.new(0.5, 0.5) _0x74DC.Position = UDim2.new(0.5, 0, 0.5, 0)
                _0x74DC.Size = UDim2.fromOffset(24, 24) _0x74DC.BackgroundTransparency = 1 _0x74DC.Parent = _0xFA03
                local function _0xE383(offx, offy, sizex, sizey)
                    local _0x5B5D = Instance.new("Frame")
                    _0x5B5D.AnchorPoint = Vector2.new(0.5, 0.5)
                    _0x5B5D.Position = UDim2.new(0.5, offx, 0.5, offy)
                    _0x5B5D.Size = UDim2.fromOffset(sizex + 2, sizey + 2)
                    _0x5B5D.BackgroundColor3 = Color3.fromRGB(0, 0, 0) _0x5B5D.BorderSizePixel = 0 _0x5B5D.Parent = _0x74DC
                    local _0x9236 = Instance.new("Frame")
                    _0x9236.AnchorPoint = Vector2.new(0.5, 0.5)
                    _0x9236.Position = UDim2.new(0.5, offx, 0.5, offy)
                    _0x9236.Size = UDim2.fromOffset(sizex, sizey)
                    _0x9236.BackgroundColor3 = Color3.fromRGB(255, 255, 255) _0x9236.BorderSizePixel = 0 _0x9236.Parent = _0x74DC
                end
                _0xE383(0, -4.5, 1, 6) _0xE383(0, 4.5, 1, 6) _0xE383(-4.5, 0, 6, 1) _0xE383(4.5, 0, 6, 1)
            end
        else
            local _0x14E4 = _0xB27C()
            if _0x14E4 then
                for _, _0x8377 in ipairs(_0x14E4:GetChildren()) do
                    if _0x8377.Name == "VEIL_Crosshair" then pcall(function() _0x8377:Destroy() end) end
                end
            end
        end
    end)
    _0x67F3("espvis", 0.12, function()
        if not _0x77AD.ESPTargetVisEnabled then return end
        local _0xB12A = _0x77AD.BoxColorMap or {}
        for _, _0x34B6 in pairs(_0xD16E.Objects) do
            if _0x34B6.Player and _0x34B6.Character and _0x34B6.Stroke then
                local _0x3694, _0x7AA7 = _0xC036.GetHitboxPosition(_0x34B6.Character, "Head")
                if _0x3694 then
                    local _0xC2AA = _0xC036.IsPositionVisible(_0x3694, {_0x34B6.Character}, tostring(_0x34B6.Player.UserId), _0x7AA7)
                    _0x34B6.Stroke.Color = _0xC2AA and Color3.fromRGB(80, 220, 130) or (_0xB12A[_0x77AD.BoxColor] or Color3.fromRGB(255, 100, 60))
                end
            end
        end
    end)
    _0x67F3("hitsounds", 0.2, function()
        if not _0x77AD.HitSoundsEnabled or not _0x77AD.IsPremium then return end
        local _0x3135 = _0x1996.Lock
        if not _0x3135 or not _0x3135.Player or not _0x3135.Character then return end
        local _0x44C9 = _0x3135.Character:FindFirstChildOfClass("Humanoid")
        if not _0x44C9 then return end
        local _0x6260 = "VEIL_HP_" .. tostring(_0x3135.Player.UserId)
        local _0x905F = _G[_0x6260]
        if _0x905F and _0x44C9.Health < _0x905F then
            local _0x3E54 = (_0x77AD.HitSoundMap or {})[_0x77AD.HitSoundChoice or "Vine Boom"] or "rbxassetid://6308606116"
            pcall(function()
                local _0x1642 = Instance.new("Sound")
                _0x1642.SoundId = _0x3E54 _0x1642.Volume = 0.5 _0x1642.Parent = game:GetService("SoundService")
                _0x1642:Play()
                task.delay(2, function() pcall(function() _0x1642:Destroy() end) end)
            end)
        end
        _G[_0x6260] = _0x44C9.Health
    end)
    _0x67F3("hitbox", 0.4, function()
        if not _0x77AD.HitboxExpanderEnabled then
            local _0x1A90 = _0xE1FF.LocalPlayer
            if not _0x1A90 then return end
            for _, _0x938C in ipairs(_0xE1FF:GetPlayers()) do
                if _0x938C ~= _0x1A90 and _0x938C.Character and _0x938C.Character.Parent then
                    for _, _0xB877 in ipairs({"Head","UpperTorso","LowerTorso","Torso","HumanoidRootPart"}) do
                        local _0x7AA7 = _0x938C.Character:FindFirstChild(_0xB877)
                        if _0x7AA7 and _0x7AA7:IsA("BasePart") then
                            local _0x3639 = _0x7AA7:GetAttribute("VEIL_OrigSize")
                            if _0x3639 and _0x7AA7.Size ~= _0x3639 then pcall(function() _0x7AA7.Size = _0x3639 end) end
                        end
                    end
                end
            end
            return
        end
        local _0x1A90 = _0xE1FF.LocalPlayer
        if not _0x1A90 then return end
        for _, _0x938C in ipairs(_0xE1FF:GetPlayers()) do
            if _0x938C ~= _0x1A90 and _0x938C.Character and _0x938C.Character.Parent then
                for _, part_name in ipairs({"Head", "UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart"}) do
                    local _0x7AA7 = _0x938C.Character:FindFirstChild(part_name)
                    if _0x7AA7 and _0x7AA7:IsA("BasePart") then
                        if not _0x7AA7:GetAttribute("VEIL_OrigSize") then _0x7AA7:SetAttribute("VEIL_OrigSize", _0x7AA7.Size) end
                        local _0x3639 = _0x7AA7:GetAttribute("VEIL_OrigSize")
                        local _0xF079 = _0x3639 * (_0x77AD.HitboxExpanderSize or 1.5)
                        if _0x7AA7.Size ~= _0xF079 then pcall(function() _0x7AA7.Size = _0xF079 end) end
                    end
                end
            end
        end
    end)
    _0x67F3("norecoil", 0.08, function()
        if not _0x77AD.NoRecoilEnabled then return end
        local _0x1A90 = _0xE1FF.LocalPlayer
        if not _0x1A90 or not _0x1A90.Character then return end
        local _0xE895 = _0x1A90.Character
        local _0x44C9 = _0xE895:FindFirstChildOfClass("Humanoid")
        if not _0x44C9 then return end
        if _0x44C9.CameraOffset.Magnitude > 0.001 then
            pcall(function() _0x44C9.CameraOffset = Vector3.zero end)
        end
        local _0x9EEE = _0xE895:FindFirstChildOfClass("Tool")
        if _0x9EEE then
            for _, ch in ipairs(_0x9EEE:GetChildren()) do
                if ch:IsA("NumberValue") then
                    local _0xB877 = ch.Name:lower()
                    if _0xB877:find("recoil") or _0xB877:find("kick") or _0xB877:find("spread") or _0xB877:find("shake") then
                        if ch.Value ~= 0 then pcall(function() ch.Value = 0 end) end
                    end
                elseif ch:IsA("Vector3Value") then
                    local _0xB877 = ch.Name:lower()
                    if _0xB877:find("recoil") or _0xB877:find("kick") or _0xB877:find("shake") then
                        if ch.Value.Magnitude > 0 then pcall(function() ch.Value = Vector3.zero end) end
                    end
                end
            end
        end
    end)
    local _0x9799 = { Tool = nil, WasForcing = false, StatesDisabled = false, SpeedApplied = false, PreSpeed = nil, PreJump = nil, Boost = nil }
    local _0xF647 = Instance.new("BodyVelocity")
    _0xF647.Name = "VEIL_FlyBV" _0xF647.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    _0xF647.P = 10000 _0xF647.Parent = nil
    _0x67F3("flyspeed", 0.05, function()
        local _0x1A90 = _0xE1FF.LocalPlayer
        if not _0x1A90 then return end
        local _0xE895 = _0x1A90.Character
        if not _0xE895 or not _0xE895.Parent then
            _0xF647.Parent = nil _0x9799.Tool = nil _0x9799.WasForcing = false
            _0x9799.StatesDisabled = false _0x9799.SpeedApplied = false
            if _0x9799.Boost then pcall(function() _0x9799.Boost:Destroy() end) _0x9799.Boost = nil end
            return
        end
        local _0x0F19 = _0xE895:FindFirstChild("HumanoidRootPart")
        local _0x44C9 = _0xE895:FindFirstChildOfClass("Humanoid")
        if not _0x0F19 or not _0x44C9 then _0xF647.Parent = nil return end
        if not _0x77AD.FlyEnabled and not _0x77AD.SpeedEnabled and not _0x9799.WasForcing and not _0x9799.SpeedApplied and _0xF647.Parent == nil then return end
        local _0x7BF5 = _0xE895:FindFirstChildOfClass("Tool")
        if _0x7BF5 then _0x9799.Tool = _0x7BF5 end
        local _0x2AB7 = _0x77AD.FlyEnabled
        local _0x04DD = _0x77AD.SpeedEnabled
        local _0x193F = _0x2AB7 or _0x04DD
        if _0x2AB7 then
            if _0xF647.Parent ~= _0x0F19 then _0xF647.Parent = _0x0F19 end
            local _0x7458 = _0x3BA1.CurrentCamera
            local _0xA856, _0xE174, _0x0D19 = 0, 0, 0
            if _0x9A4D.isMobile then
                local _0x4EAD = _0x44C9.MoveDirection
                if _0x4EAD and _0x4EAD.Magnitude > 0.01 then _0xA856 = _0x4EAD.X _0xE174 = 0 _0x0D19 = _0x4EAD.Z end
            else
                if _0xA548:IsKeyDown(Enum.KeyCode.W) then _0x0D19 = _0x0D19 - 1 end
                if _0xA548:IsKeyDown(Enum.KeyCode.S) then _0x0D19 = _0x0D19 + 1 end
                if _0xA548:IsKeyDown(Enum.KeyCode.A) then _0xA856 = _0xA856 - 1 end
                if _0xA548:IsKeyDown(Enum.KeyCode.D) then _0xA856 = _0xA856 + 1 end
                if _0xA548:IsKeyDown(Enum.KeyCode.Space) then _0xE174 = _0xE174 + 1 end
                if _0xA548:IsKeyDown(Enum.KeyCode.LeftControl) then _0xE174 = _0xE174 - 1 end
            end
            local _0x4EAD = Vector3.new(_0xA856, _0xE174, _0x0D19)
            local _0x33FF = math.clamp(_0x77AD.FlySpeed or 50, 10, 80)
            local _0xF894 = _0x33FF
            if not _0x9A4D.isMobile and _0xA548:IsKeyDown(Enum.KeyCode.LeftShift) then _0xF894 = _0x33FF * 2.2 end
            if _0x7458 and _0x4EAD.Magnitude > 0 then
                local _0xB0D1 = (_0x7458.CFrame.LookVector * -_0x4EAD.Z + _0x7458.CFrame.RightVector * _0x4EAD.X + Vector3.new(0, 1, 0) * _0x4EAD.Y)
                if _0xB0D1.Magnitude > 0 then _0xB0D1 = _0xB0D1.Unit end
                _0xF647.Velocity = _0xF647.Velocity:Lerp(_0xB0D1 * _0xF894, 0.35)
            else
                _0xF647.Velocity = _0xF647.Velocity * 0.15
            end
        else
            if _0xF647.Parent then _0xF647.Velocity = Vector3.new(0, 0, 0) _0xF647.Parent = nil end
        end
        if _0x04DD then
            if not _0x9799.SpeedApplied then
                _0x9799.PreSpeed = _0x44C9.WalkSpeed
                _0x9799.PreJump = _0x44C9.JumpPower
                _0x9799.SpeedApplied = true
                _0x9799.Boost = Instance.new("BodyVelocity")
                _0x9799.Boost.Name = "VEIL_SpeedBoost"
                _0x9799.Boost.MaxForce = Vector3.new(1e5, 0, 1e5)
                _0x9799.Boost.P = 1250
                _0x9799.Boost.Parent = _0x0F19
            end
            local _0x0ADB = math.clamp(_0x77AD.SpeedValue or 60, 16, 500)
            pcall(function() _0x44C9.WalkSpeed = _0x0ADB end)
            pcall(function() _0x44C9.JumpPower = math.max(_0x44C9.JumpPower, 50) end)
            if _0x9799.Boost and _0x0F19 then
                local _0x4EAD = _0x44C9.MoveDirection
                if _0x4EAD and _0x4EAD.Magnitude > 0.01 then
                    _0x9799.Boost.Velocity = Vector3.new(_0x4EAD.X, 0, _0x4EAD.Z).Unit * (_0x0ADB * 0.9)
                else
                    _0x9799.Boost.Velocity = Vector3.new(0, 0, 0)
                end
            end
        else
            if _0x9799.SpeedApplied then
                if _0x9799.PreSpeed then pcall(function() _0x44C9.WalkSpeed = _0x9799.PreSpeed end) end
                if _0x9799.PreJump then pcall(function() _0x44C9.JumpPower = _0x9799.PreJump end) end
                if _0x9799.Boost then pcall(function() _0x9799.Boost:Destroy() end) _0x9799.Boost = nil end
                _0x9799.PreSpeed = nil _0x9799.PreJump = nil _0x9799.SpeedApplied = false
            end
        end
        if _0x193F then
            _0x9799.WasForcing = true
            local _0x48A3 = _0x44C9:GetState()
            if _0x48A3 ~= Enum.HumanoidStateType.Running and _0x48A3 ~= Enum.HumanoidStateType.RunningNoPhysics then
                pcall(function() _0x44C9:ChangeState(Enum.HumanoidStateType.Running) end)
            end
            if not _0x9799.StatesDisabled then
                _0x9799.StatesDisabled = true
                pcall(function() _0x44C9:SetStateEnabled(Enum.HumanoidStateType.Freefall, false) end)
            end
            if _0x9799.Tool and _0x9799.Tool.Parent ~= _0xE895 and (not _0x9799.Tool.Parent or _0x9799.Tool.Parent == _0x1A90.Backpack) then
                pcall(function() _0x44C9:EquipTool(_0x9799.Tool) end)
            end
            if _0x9799.Tool and not _0x9799.Tool.Parent then _0x9799.Tool = nil end
        elseif _0x9799.WasForcing then
            _0x9799.WasForcing = false _0x9799.StatesDisabled = false
            pcall(function() _0x44C9:SetStateEnabled(Enum.HumanoidStateType.Freefall, true) end)
            if _0x9799.Tool and _0x9799.Tool.Parent == _0x1A90.Backpack then
                pcall(function() _0x44C9:EquipTool(_0x9799.Tool) end)
            end
        end
    end)
    _0x67F3("deflectblock", 0.1, function()
        if not _0x77AD.AutoStopOnKatanaDeflect then return end
        local _0x1A90 = _0xE1FF.LocalPlayer
        if not _0x1A90 then return end
        local _0xE895 = _0x1A90.Character
        if not _0xE895 or not _0xE895.Parent then return end
        local _0x9EEE = _0xE895:FindFirstChildOfClass("Tool")
        if not _0x9EEE then return end
        local _0x4141 = false
        local _0x3135 = _0x1996.Lock
        if _0x3135 and _0x3135.Player and _0xC036.IsTargetDeflecting(_0x3135.Player) then _0x4141 = true end
        if _0x4141 then
            if _0x9EEE.Enabled then pcall(function() _0x9EEE.Enabled = false end) end
        elseif not _0x9EEE.Enabled then
            pcall(function() _0x9EEE.Enabled = true end)
        end
    end)
    _0x55FF.Track(_0xB932.Heartbeat:Connect(function(_0x154F)
        if _0x1996.ShuttingDown then return end
        local _0x17DA = tick()
        for _, sys in pairs(_0x4816) do
            if _0x17DA - sys.last >= sys.rate then
                sys.last = _0x17DA
                pcall(sys.fn, _0x154F)
            end
        end
    end))
end

_G.__VEIL_last_connections = _0x55FF
_G.__VEIL_Mobile = {
    device = _0x9A4D,
    aim = function(_0x0404) _0x1996.KeyHeld = _0x0404 and true or false end,
    toggleMenu = function() _0x1FFE() end,
    overlay = _0x453F,
}

-- ============================================================
-- Startup gate
-- ============================================================
local _0xDA01 = {}
_0xDA01.Interval = 12 * 60 * 60
_0xDA01._memLast = nil
local function _0x0A8D()
    if _0x76B0.HasReadfile then
        for _, _0x938C in ipairs({"VEIL/LastStartup.txt", "VEIL_LastStartup.txt"}) do
            local _0xDF7B, _0x3748 = pcall(readfile, _0x938C)
            if _0xDF7B and _0x3748 then local _0xB877 = tonumber(_0x3748) if _0xB877 and _0xB877 > 0 then return _0xB877 end end
        end
    end
    return _0xDA01._memLast
end
local function _0x5BB4(_0xD871)
    _0xDA01._memLast = _0xD871
    if not _0x76B0.HasWritefile then return end
    if _0x76B0.HasMakeFolder then pcall(makefolder, "VEIL") end
    for _, _0x938C in ipairs({"VEIL/LastStartup.txt", "VEIL_LastStartup.txt"}) do
        if pcall(writefile, _0x938C, tostring(_0xD871)) then return end
    end
end
function _0xDA01.ShouldPlay()
    local _0x905F = _0x0A8D()
    if not _0x905F then return true end
    return (os.time() - _0x905F) >= _0xDA01.Interval
end
function _0xDA01.Run()
    task.defer(function()
        task.wait(0.3)
        local _0x5B20 = false
        local function _0xCFC4()
            if _0x5B20 then return end
            _0x5B20 = true
            if _0xB457.MainFrame then _0xB457.MainFrame.Visible = true end
            _G.__VEIL_StartupDone = true
            if _G.__VEIL_BindDeferred then pcall(_G.__VEIL_BindDeferred) end
        end
        if not _0xDA01.ShouldPlay() then _0xCFC4() return end
        _0x5BB4(os.time())
        local _0xE903 = pcall(_0xB5D3, _0xCFC4)
        if not _0xE903 then _0xCFC4() end
        task.delay(8, _0xCFC4)
    end)
end
local function _0x7130()
    task.spawn(function()
        local _0xFB05 = 0
        while not _G.__VEIL_StartupDone and _0xFB05 < 15 do task.wait(0.15) _0xFB05 = _0xFB05 + 0.15 end
        task.wait(0.6)
        local _0x17DA = os.time()
        local _0x905F = nil
        if _0x76B0.HasReadfile then
            for _, _0x938C in ipairs({"VEIL/LastDiscordPopup.txt", "VEIL_LastDiscordPopup.txt"}) do
                local _0xDF7B, _0x3748 = pcall(readfile, _0x938C)
                if _0xDF7B and _0x3748 then local _0xB877 = tonumber(_0x3748) if _0xB877 and _0xB877 > 0 then _0x905F = _0xB877 break end end
            end
        end
        if _0x905F and (_0x17DA - _0x905F) < 12 * 60 * 60 then return end
        if _0x76B0.HasWritefile then
            if _0x76B0.HasMakeFolder then pcall(makefolder, "VEIL") end
            for _, _0x938C in ipairs({"VEIL/LastDiscordPopup.txt", "VEIL_LastDiscordPopup.txt"}) do
                if pcall(writefile, _0x938C, tostring(_0x17DA)) then break end
            end
        end
        pcall(_0x0AE1)
    end)
end

-- ============================================================
-- Boot
-- ============================================================
task.defer(function()
    local _0x47F4, _0x05BC = _0xB7CC.ReadSaved()
    if _0x47F4 and _0x05BC and os.time() < _0x05BC then
        local _0xB494, _0x05AC = _0xB7CC.DetectTier(_0x47F4)
        if _0xB494 then
            _0x77AD.IsPremium = true
            _0x77AD.PremiumTier = _0x05AC.name
            _0x77AD.PremiumExpiry = _0x05BC
            _0x77AD.PremiumKey = _0x47F4
        end
        _0xB7CC.Authorized = true
        pcall(_0xDFD4)
        _0x2F55()
        _0xDA01.Run()
        _0x7130()
        pcall(_0x6C2B.Register)
        return
    end
    _0xB7CC.ClearSaved()
    _0x6ABC(function()
        pcall(_0xDFD4)
        _0x2F55()
        _0xDA01.Run()
        _0x7130()
        pcall(_0x6C2B.Register)
    end)
end)

return {_0x77AD = _0x77AD, _0xC036 = _0xC036, _0xB7CC = _0xB7CC}
