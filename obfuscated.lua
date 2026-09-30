-- ============================================================
-- VEIL — V1
-- ============================================================

do
    if _G.__VEIL_last_bind then pcall(function() game:GetService("RunService"):UnbindFromRenderStep(_G.__VEIL_last_bind) end) end
    if _G.__VEIL_viewfov_bind then pcall(function() game:GetService("RunService"):UnbindFromRenderStep(_G.__VEIL_viewfov_bind) end) end
    if _G.__VEIL_last_connections then
        for _, c in ipairs(_G.__VEIL_last_connections) do pcall(function() c:Disconnect() end) end
    end
    pcall(function()
        local par = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui")
        for _, c in ipairs(par:GetChildren()) do
            local n = c.Name
            if n == "VEIL_UI" or n == "VEIL_Visuals" or n == "VEIL_FOV"
                or n == "VEIL_Startup" or n == "VEIL_Watermark" or n == "VEIL_MobileOverlay"
                or n == "VEIL_Discord" or n == "VEIL_Premium" or n == "VEIL_Picker"
                or n == "VEIL_KeyUI" or n == "VEIL_Popup" or n == "VEIL_Crosshair" then
                c:Destroy()
            end
        end
    end)
    _G.__VEIL_last_bind = nil _G.__VEIL_viewfov_bind = nil _G.__VEIL_last_connections = nil
    _G.__VEIL_CameraAssist = nil _G.__VEIL_Weapon = nil _G.__VEIL_ShowStartup = nil
    _G.__VEIL_Mobile = nil _G.__VEIL_StartupDone = nil _G.__VEIL_INITIALIZED = nil
end

local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local function sget(f, d) local ok, v = pcall(f) if ok then return v end return d end

local function detectDevice()
    local o = _G.__VEIL_ForceDevice
    if o == "mobile" then return {isMobile=true, isPC=false, isVR=false, platform="override"} end
    if o == "pc" then return {isMobile=false, isPC=true, isVR=false, platform="override"} end
    local p = sget(function() return UIS:GetPlatform() end, nil)
    local ps = tostring(p or "Unknown")
    local mp = ps:find("iOS") ~= nil or ps:find("Android") ~= nil or ps:find("UWP") ~= nil
    local t = sget(function() return UIS.TouchEnabled end, false)
    local k = sget(function() return UIS.KeyboardEnabled end, true)
    local m = sget(function() return UIS.MouseEnabled end, true)
    local v = sget(function() return UIS.VREnabled end, false)
    local im = false
    if v then im = false
    elseif mp then im = not k
    elseif t and not k and not m then im = true end
    return {isMobile=im, isPC=(not im) and (not v), isVR=v, platform=ps, touch=t, keyboard=k, mouse=m}
end

local DeviceInfo = detectDevice()
local RATE_MULT = DeviceInfo.isMobile and 3.0 or 1.0

local IS_LOW_UNC = false
pcall(function()
    if type(identifyexecutor) == "function" then
        local n = tostring(identifyexecutor() or ""):lower()
        if n:find("xeno") or n:find("solara") or n:find("krnl")
            or n:find("fluxus") or n:find("hydrogen") or n:find("codex")
            or n:find("trigon") then
            IS_LOW_UNC = true
        end
    end
end)
_G.__VEIL_IS_LOW_UNC = IS_LOW_UNC

local SILENT = { Active = false, Mode = "none", HitCount = 0 }
local SILENT_CAM = nil
_G.__VEIL_SILENT_CFG = _G.__VEIL_SILENT_CFG or {}
_G.__VEIL_SILENT_CFG.MinMag = 20
_G.__VEIL_SILENT_CFG.MinDot = 0.5
_G.__VEIL_SILENT_CFG.MinToTarget = 0.3

if _G.__VEIL_SILENT_REF then
    SILENT = _G.__VEIL_SILENT_REF
    SILENT.Active = false
    SILENT.HitCount = 0
    SILENT.Mode = "installed"
else
    _G.__VEIL_SILENT_REF = SILENT

    if IS_LOW_UNC then
        SILENT.Mode = "camera"
    else
        local _oldNamecall = nil
        local function current_lock()
            local ca = _G.__VEIL_CameraAssist
            local lk = ca and ca.Lock
            if not lk or not lk.LastPos or not lk.Character or not lk.Character.Parent then return nil end
            return lk
        end

        function SILENT.InstallHook()
            if _oldNamecall then return end
            if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then
                SILENT.Mode = "camera"
                return
            end
            local ok = pcall(function()
                _oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                    if not SILENT.Active then return _oldNamecall(self, ...) end
                    if self ~= workspace then return _oldNamecall(self, ...) end
                    if type(checkcaller) == "function" and checkcaller() then return _oldNamecall(self, ...) end
                    local method = getnamecallmethod()
                    if method ~= "Raycast" and method ~= "FindPartOnRay"
                        and method ~= "findPartOnRay"
                        and method ~= "FindPartOnRayWithIgnoreList"
                        and method ~= "FindPartOnRayWithWhitelist" then
                        return _oldNamecall(self, ...)
                    end
                    local lk = current_lock()
                    if not lk then return _oldNamecall(self, ...) end
                    local cam = SILENT_CAM
                    if not cam or not cam.Parent then
                        cam = Workspace.CurrentCamera
                        SILENT_CAM = cam
                    end
                    if not cam then return _oldNamecall(self, ...) end
                    local camLook = cam.CFrame.LookVector
                    local cfg = _G.__VEIL_SILENT_CFG
                    if method == "Raycast" then
                        local origin = select(1, ...)
                        local dir = select(2, ...)
                        if typeof(origin) == "Vector3" and typeof(dir) == "Vector3" then
                            local dirMag = dir.Magnitude
                            if dirMag >= cfg.MinMag then
                                local dirUnit = dir / dirMag
                                if camLook:Dot(dirUnit) > cfg.MinDot then
                                    local toTarget = lk.LastPos - origin
                                    if toTarget.Magnitude > cfg.MinToTarget then
                                        SILENT.HitCount = SILENT.HitCount + 1
                                        return _oldNamecall(self, origin, toTarget.Unit * dirMag, select(3, ...))
                                    end
                                end
                            end
                        end
                    else
                        local ray = select(1, ...)
                        if typeof(ray) == "Ray" then
                            local dirMag = ray.Direction.Magnitude
                            if dirMag >= cfg.MinMag then
                                local dirUnit = ray.Direction / dirMag
                                if camLook:Dot(dirUnit) > cfg.MinDot then
                                    local toTarget = lk.LastPos - ray.Origin
                                    if toTarget.Magnitude > cfg.MinToTarget then
                                        SILENT.HitCount = SILENT.HitCount + 1
                                        return _oldNamecall(self, Ray.new(ray.Origin, toTarget.Unit * dirMag), select(2, ...))
                                    end
                                end
                            end
                        end
                    end
                    return _oldNamecall(self, ...)
                end))
            end)
            SILENT.Mode = (ok and _oldNamecall) and "namecall" or "camera"
        end

        function SILENT.UninstallHook()
            if not _oldNamecall then return end
            pcall(function() hookmetamethod(game, "__namecall", _oldNamecall) end)
            _oldNamecall = nil
            SILENT.Mode = "idle"
        end

        SILENT.Mode = "idle"
    end
end

local CamControls = nil
if not IS_LOW_UNC then
    CamControls = _G.__VEIL_CamControls
    if not CamControls then
        pcall(function()
            local plr = Players.LocalPlayer
            if not plr then return end
            local ps = plr:FindFirstChild("PlayerScripts")
            if not ps then return end
            local pm = ps:FindFirstChild("PlayerModule")
            if not pm then return end
            local mod = require(pm)
            if mod and mod.GetControls then
                CamControls = mod:GetControls()
                _G.__VEIL_CamControls = CamControls
            end
        end)
    end
end

local HEAD_AIM_OFFSET = 0
local AIM_DEAD_ZONE = 0.08

local Configuration = {
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

local ExecutorInfo = {
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
        local n = identifyexecutor()
        if n and n ~= "" then ExecutorInfo.Name = tostring(n) end
    end
end)

local function safeGuiParent()
    if type(gethui) == "function" then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local lp = Players.LocalPlayer
    if lp then
        local pg = lp:FindFirstChildOfClass("PlayerGui")
        if pg then return pg end
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
end

local function measureText(text, font, size, wrapWidth)
    local ts = game:GetService("TextService")
    local ok, bounds = pcall(function()
        return ts:GetTextSize(tostring(text or ""), size, font, Vector2.new(wrapWidth, 10000))
    end)
    if ok and bounds then return bounds.Y end
    local lines = math.ceil(#tostring(text or "") / math.max(1, wrapWidth / (size * 0.55)))
    return math.max(size + 4, lines * (size + 4))
end

local Popup = {}
Popup.Active = nil
function Popup.Show(text, ok)
    local par = safeGuiParent()
    if not par then return end
    if Popup.Active and Popup.Active.Parent then pcall(function() Popup.Active:Destroy() end) end
    local sg = Instance.new("ScreenGui")
    sg.Name = "VEIL_Popup" sg.ResetOnSpawn = false sg.IgnoreGuiInset = true sg.DisplayOrder = 500
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() sg.Parent = par end)
    Popup.Active = sg
    local accent = ok and Color3.fromRGB(80, 220, 130) or Color3.fromRGB(255, 80, 100)
    local PAD_X = 20
    local PAD_Y = 16
    local ICON = 30
    local GAP = 12
    local MAX_W = 400
    local MIN_W = 220
    local WRAP = MAX_W - (PAD_X * 2) - ICON - GAP
    local h = measureText(text, Enum.Font.GothamBold, 13, WRAP)
    local boxW = MAX_W
    if #tostring(text or "") < 48 then
        local ts = game:GetService("TextService")
        local okm, m = pcall(function() return ts:GetTextSize(tostring(text), 13, Enum.Font.GothamBold, Vector2.new(10000, 10000)) end)
        if okm and m then
            boxW = math.clamp(m.X + (PAD_X * 2) + ICON + GAP, MIN_W, MAX_W)
            h = m.Y
        end
    end
    local boxH = math.max(h + (PAD_Y * 2), ICON + (PAD_Y * 2))
    local box = Instance.new("Frame")
    box.AnchorPoint = Vector2.new(0.5, 0) box.Position = UDim2.new(0.5, 0, 0, -80)
    box.Size = UDim2.fromOffset(boxW, boxH) box.BackgroundColor3 = Color3.fromRGB(14, 12, 22)
    box.BackgroundTransparency = 0.03 box.BorderSizePixel = 0 box.Parent = sg
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 12) c.Parent = box
    local st = Instance.new("UIStroke") st.Color = accent st.Thickness = 1.5 st.Transparency = 0.15 st.Parent = box
    local stripe = Instance.new("Frame")
    stripe.Size = UDim2.new(0, 4, 1, -20) stripe.Position = UDim2.new(0, 6, 0, 10)
    stripe.BackgroundColor3 = accent stripe.BorderSizePixel = 0 stripe.Parent = box
    local sc = Instance.new("UICorner") sc.CornerRadius = UDim.new(0, 2) sc.Parent = stripe
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.fromOffset(ICON, ICON) icon.Position = UDim2.new(0, PAD_X, 0.5, -ICON * 0.5)
    icon.BackgroundColor3 = accent icon.BackgroundTransparency = 0.82
    icon.BorderSizePixel = 0 icon.Font = Enum.Font.GothamBlack icon.TextSize = 18
    icon.TextColor3 = accent icon.Text = ok and "\226\156\147" or "\226\156\149" icon.Parent = box
    local ic = Instance.new("UICorner") ic.CornerRadius = UDim.new(1, 0) ic.Parent = icon
    local lbl = Instance.new("TextLabel")
    lbl.Position = UDim2.new(0, PAD_X + ICON + GAP, 0, PAD_Y)
    lbl.Size = UDim2.new(1, -(PAD_X * 2 + ICON + GAP), 0, h)
    lbl.BackgroundTransparency = 1 lbl.Font = Enum.Font.GothamBold lbl.TextSize = 13
    lbl.TextColor3 = accent lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top lbl.TextWrapped = true lbl.Text = tostring(text or "")
    lbl.Parent = box
    TweenService:Create(box, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 24)}):Play()
    task.delay(ok and 2.4 or 3.0, function()
        TweenService:Create(box, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, -80)}):Play()
        TweenService:Create(lbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(icon, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        TweenService:Create(st, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TweenService:Create(stripe, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.delay(0.5, function() pcall(function() sg:Destroy() end) end)
    end)
end

local KeySystem = {}
KeySystem.Authorized = false
KeySystem.KeyLink = "https://work.ink/2YDv/key-system"
KeySystem.DefaultExpiry = 24 * 60 * 60
KeySystem.PremiumTiers = {
    ["week"]     = { name = "1 Week",   seconds = 7 * 24 * 60 * 60 },
    ["month"]    = { name = "1 Month",  seconds = 30 * 24 * 60 * 60 },
    ["3month"]   = { name = "3 Months", seconds = 90 * 24 * 60 * 60 },
    ["lifetime"] = { name = "Lifetime", seconds = 100 * 365 * 24 * 60 * 60 },
}
KeySystem.PremiumWhitelist = {
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

function KeySystem.DetectTier(key)
    if not key or key == "" then return nil end
    local upper = key:upper():gsub("^%s+", ""):gsub("%s+$", "")
    local tier = KeySystem.PremiumWhitelist[upper]
    if tier then return tier, KeySystem.PremiumTiers[tier] end
    return nil
end
local function ksHttpGet(url)
    if type(request) == "function" then
        local ok, res = pcall(request, { Url = url, Method = "GET" })
        if ok and res then return res end
    end
    if type(http_request) == "function" then
        local ok, res = pcall(http_request, { Url = url, Method = "GET" })
        if ok and res then return res end
    end
    if type(syn) == "table" and type(syn.request) == "function" then
        local ok, res = pcall(syn.request, { Url = url, Method = "GET" })
        if ok and res then return res end
    end
    return nil
end
function KeySystem.Validate(key)
    key = tostring(key or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if #key < 6 then return false, "too-short" end
    local tier, info = KeySystem.DetectTier(key)
    if tier then
        getgenv().SCRIPT_KEY = key
        Configuration.IsPremium = true
        Configuration.PremiumTier = info.name
        Configuration.PremiumExpiry = os.time() + info.seconds
        Configuration.PremiumKey = key
        return true, "premium:" .. info.name
    end
    local res = ksHttpGet("https://work.ink/_api/v2/token/isValid/" .. key)
    if not res then return false, "http-unavailable" end
    local body = res.Body or res.body or ""
    if body == "" then return false, "empty-response" end
    local decoded
    local ok = pcall(function() decoded = HttpService:JSONDecode(body) end)
    if not ok or type(decoded) ~= "table" then return false, "bad-response" end
    if decoded.valid == true then
        getgenv().SCRIPT_KEY = key
        Configuration.IsPremium = false
        return true, "valid"
    end
    return false, tostring(decoded.error or "invalid")
end
function KeySystem.ReadSaved()
    if not ExecutorInfo.HasReadfile then return nil, nil end
    for _, p in ipairs({"VEIL/Key.txt", "VEIL_Key.txt"}) do
        local ok, d = pcall(readfile, p)
        if ok and d and d ~= "" then
            local key, ts = d:match("^([^|]+)|(%d+)$")
            if key and ts then return key, tonumber(ts) end
        end
    end
    return nil, nil
end
function KeySystem.WriteSaved(key, expiry)
    if not ExecutorInfo.HasWritefile then return false end
    if ExecutorInfo.HasMakeFolder then pcall(makefolder, "VEIL") end
    local payload = tostring(key) .. "|" .. tostring(expiry)
    for _, p in ipairs({"VEIL/Key.txt", "VEIL_Key.txt"}) do
        if pcall(writefile, p, payload) then return true end
    end
    return false
end
function KeySystem.ClearSaved()
    if not ExecutorInfo.HasWritefile then return end
    for _, p in ipairs({"VEIL/Key.txt", "VEIL_Key.txt"}) do pcall(writefile, p, "") end
end

local function buildKeyUI(onAuthorized)
    local par = safeGuiParent()
    if not par then return nil end
    local sg = Instance.new("ScreenGui")
    sg.Name = "VEIL_KeyUI" sg.ResetOnSpawn = false sg.IgnoreGuiInset = true sg.DisplayOrder = 400
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() sg.Parent = par end)
    KeySystem.ScreenGui = sg

    local DI = "https://discord.gg/K3vgcVsCsS"
    local REF_W, REF_H = 1920, 1080

    local bd = Instance.new("Frame")
    bd.Size = UDim2.fromScale(1, 1) bd.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bd.BackgroundTransparency = 0.35 bd.BorderSizePixel = 0 bd.ZIndex = 1 bd.Parent = sg

    local moteLayer = Instance.new("Frame")
    moteLayer.Size = UDim2.fromScale(1, 1)
    moteLayer.BackgroundTransparency = 1
    moteLayer.BorderSizePixel = 0
    moteLayer.ClipsDescendants = true
    moteLayer.ZIndex = 2
    moteLayer.Parent = sg

    local boltLayer = Instance.new("Frame")
    boltLayer.Size = UDim2.fromScale(1, 1)
    boltLayer.BackgroundTransparency = 1
    boltLayer.BorderSizePixel = 0
    boltLayer.ClipsDescendants = true
    boltLayer.ZIndex = 4
    boltLayer.Parent = sg

    local boltAlive = true

    local function spawnMote()
        if not boltAlive or not moteLayer.Parent then return end
        local sz = 2 + math.random() * 3
        local m = Instance.new("Frame")
        m.AnchorPoint = Vector2.new(0.5, 0.5)
        m.Size = UDim2.fromOffset(sz, sz)
        m.BackgroundColor3 = Color3.fromRGB(190, 165, 255)
        m.BackgroundTransparency = 1
        m.BorderSizePixel = 0
        m.Position = UDim2.fromScale(math.random(), 1.05)
        m.ZIndex = 2
        m.Parent = moteLayer
        local mc = Instance.new("UICorner")
        mc.CornerRadius = UDim.new(1, 0)
        mc.Parent = m
        local drift = (math.random() - 0.5) * 0.25
        local dx = math.clamp(m.Position.X.Scale + drift, 0.02, 0.98)
        local lifetime = 4 + math.random() * 3
        TweenService:Create(m, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.35,
        }):Play()
        TweenService:Create(m, TweenInfo.new(lifetime, Enum.EasingStyle.Linear), {
            Position = UDim2.fromScale(dx, -0.08),
        }):Play()
        task.delay(lifetime - 1.0, function()
            if m.Parent then
                TweenService:Create(m, TweenInfo.new(1.0), {BackgroundTransparency = 1}):Play()
            end
        end)
        task.delay(lifetime + 0.2, function() if m.Parent then m:Destroy() end end)
    end

    local function spawnBolt()
        if not boltAlive or not boltLayer.Parent then return end
        local startX = math.random(10, 90) / 100
        local startY = -0.05 + math.random() * 0.15
        local endY = 0.55 + math.random() * 0.5
        local segCount = 4 + math.random(0, 2)
        local points = { Vector2.new(startX, startY) }
        local curX, curY = startX, startY
        local biasX = (math.random() - 0.5) * 0.1
        local totalRise = endY - startY
        for i = 1, segCount do
            curY = curY + totalRise / segCount + (math.random() - 0.5) * 0.03
            curX = curX + biasX + (math.random() - 0.5) * 0.13
            curX = math.clamp(curX, 0.02, 0.98)
            table.insert(points, Vector2.new(curX, curY))
        end
        local group = Instance.new("Frame")
        group.Size = UDim2.fromScale(1, 1)
        group.BackgroundTransparency = 1
        group.BorderSizePixel = 0
        group.ZIndex = 4
        group.Parent = boltLayer
        local headP, tailP = points[1], points[#points]
        local hdx = (tailP.X - headP.X) * REF_W
        local hdy = (tailP.Y - headP.Y) * REF_H
        local headLen = math.sqrt(hdx * hdx + hdy * hdy)
        local headAngle = math.deg(math.atan2(hdy, hdx))
        local midX = (headP.X + tailP.X) * 0.5
        local midY = (headP.Y + tailP.Y) * 0.5
        local glow = Instance.new("Frame")
        glow.AnchorPoint = Vector2.new(0.5, 0.5)
        glow.Position = UDim2.fromScale(midX, midY)
        glow.Size = UDim2.new(0, headLen, 0, 12)
        glow.Rotation = headAngle
        glow.BackgroundColor3 = Color3.fromRGB(160, 140, 240)
        glow.BackgroundTransparency = 0.72
        glow.BorderSizePixel = 0
        glow.ZIndex = 4
        glow.Parent = group
        local gc = Instance.new("UICorner")
        gc.CornerRadius = UDim.new(1, 0)
        gc.Parent = glow
        local segs = {}
        for i = 1, #points - 1 do
            local p1, p2 = points[i], points[i + 1]
            local dx = (p2.X - p1.X) * REF_W
            local dy = (p2.Y - p1.Y) * REF_H
            local len = math.sqrt(dx * dx + dy * dy)
            local ang = math.deg(math.atan2(dy, dx))
            local cx = (p1.X + p2.X) * 0.5
            local cy = (p1.Y + p2.Y) * 0.5
            local seg = Instance.new("Frame")
            seg.AnchorPoint = Vector2.new(0.5, 0.5)
            seg.Position = UDim2.fromScale(cx, cy)
            seg.Size = UDim2.new(0, len, 0, 3)
            seg.Rotation = ang
            seg.BackgroundColor3 = Color3.fromRGB(240, 235, 255)
            seg.BorderSizePixel = 0
            seg.BackgroundTransparency = 0.06
            seg.ZIndex = 5
            seg.Parent = group
            local sc = Instance.new("UICorner")
            sc.CornerRadius = UDim.new(1, 0)
            sc.Parent = seg
            table.insert(segs, seg)
        end
        if math.random() < 0.55 and #points >= 3 then
            local bp = points[math.random(2, #points - 1)]
            local fx = (math.random() - 0.5) * 0.18
            local fy = 0.08 + math.random() * 0.16
            local ex = math.clamp(bp.X + fx, 0.02, 0.98)
            local ey = bp.Y + fy
            local dx = (ex - bp.X) * REF_W
            local dy = (ey - bp.Y) * REF_H
            local len = math.sqrt(dx * dx + dy * dy)
            local ang = math.deg(math.atan2(dy, dx))
            local fseg = Instance.new("Frame")
            fseg.AnchorPoint = Vector2.new(0.5, 0.5)
            fseg.Position = UDim2.fromScale((bp.X + ex) * 0.5, (bp.Y + ey) * 0.5)
            fseg.Size = UDim2.new(0, len, 0, 2)
            fseg.Rotation = ang
            fseg.BackgroundColor3 = Color3.fromRGB(220, 210, 255)
            fseg.BorderSizePixel = 0
            fseg.BackgroundTransparency = 0.14
            fseg.ZIndex = 5
            fseg.Parent = group
            local fc = Instance.new("UICorner")
            fc.CornerRadius = UDim.new(1, 0)
            fc.Parent = fseg
            table.insert(segs, fseg)
        end
        local life = 0.05 + math.random() * 0.07
        task.delay(life, function()
            local fadeInfo = TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            for _, seg in ipairs(segs) do
                if seg.Parent then
                    TweenService:Create(seg, fadeInfo, {BackgroundTransparency = 1}):Play()
                end
            end
            if glow.Parent then
                TweenService:Create(glow, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
            end
            task.delay(0.4, function()
                if group.Parent then group:Destroy() end
            end)
        end)
    end

    task.spawn(function()
        while boltAlive and moteLayer.Parent do
            spawnMote()
            task.wait(0.28 + math.random() * 0.22)
        end
    end)

    task.spawn(function()
        task.wait(0.6 + math.random() * 0.8)
        while boltAlive and boltLayer.Parent do
            spawnBolt()
            if math.random() < 0.15 then
                task.wait(0.08 + math.random() * 0.1)
                spawnBolt()
            end
            task.wait(2.4 + math.random() * 2.2)
        end
    end)

    local panel = Instance.new("Frame")
    panel.AnchorPoint = Vector2.new(0.5, 0.5) panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.Size = UDim2.fromOffset(360, 400)
    panel.BackgroundColor3 = Color3.fromRGB(15, 12, 24)
    panel.BackgroundTransparency = 0.05
    panel.BorderSizePixel = 0
    panel.ZIndex = 10
    panel.Parent = sg
    local pc = Instance.new("UICorner") pc.CornerRadius = UDim.new(0, 16) pc.Parent = panel
    local ps = Instance.new("UIStroke")
    ps.Color = Color3.fromRGB(120, 100, 220) ps.Thickness = 1.5 ps.Transparency = 0.15 ps.Parent = panel
    local panelGlow = Instance.new("UIStroke")
    panelGlow.Color = Color3.fromRGB(180, 160, 255)
    panelGlow.Thickness = 3
    panelGlow.Transparency = 1
    panelGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    panelGlow.Parent = panel
    task.spawn(function()
        while panel.Parent do
            task.wait(2.2 + math.random() * 2.4)
            if panel.Parent then
                TweenService:Create(panelGlow, TweenInfo.new(0.1), {Transparency = 0.45}):Play()
                task.wait(0.18)
                TweenService:Create(panelGlow, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1}):Play()
            end
        end
    end)

    local xClose = Instance.new("TextButton")
    xClose.Size = UDim2.fromOffset(28, 28)
    xClose.Position = UDim2.new(1, -38, 0, 10)
    xClose.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
    xClose.BorderSizePixel = 0
    xClose.Font = Enum.Font.GothamBold
    xClose.TextSize = 16
    xClose.TextColor3 = Color3.fromRGB(220, 210, 255)
    xClose.Text = "x"
    xClose.AutoButtonColor = false
    xClose.ZIndex = 12
    xClose.Parent = panel
    local xc = Instance.new("UICorner") xc.CornerRadius = UDim.new(0, 8) xc.Parent = xClose
    local xst = Instance.new("UIStroke") xst.Color = Color3.fromRGB(80, 70, 120) xst.Thickness = 1 xst.Parent = xClose
    xClose.MouseEnter:Connect(function()
        TweenService:Create(xClose, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(90, 40, 50)}):Play()
        TweenService:Create(xClose, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 180, 180)}):Play()
    end)
    xClose.MouseLeave:Connect(function()
        TweenService:Create(xClose, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 30, 60)}):Play()
        TweenService:Create(xClose, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(220, 210, 255)}):Play()
    end)
    xClose.MouseButton1Click:Connect(function()
        boltAlive = false
        pcall(function() sg:Destroy() end)
    end)

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 0, 52) logo.Position = UDim2.new(0, 0, 0, 22)
    logo.BackgroundTransparency = 1 logo.Font = Enum.Font.GothamBlack logo.Text = "VEIL"
    logo.TextSize = 44 logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    logo.TextStrokeTransparency = 0.6 logo.TextStrokeColor3 = Color3.fromRGB(80, 60, 160)
    logo.ZIndex = 11 logo.Parent = panel
    local lgrad = Instance.new("UIGradient")
    lgrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 200, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 130, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 160, 255)),
    }
    lgrad.Parent = logo

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 16) sub.Position = UDim2.new(0, 0, 0, 78)
    sub.BackgroundTransparency = 1 sub.Font = Enum.Font.GothamBold
    sub.Text = "S E C U R I T Y   S U I T E" sub.TextSize = 9
    sub.TextColor3 = Color3.fromRGB(167, 139, 250) sub.ZIndex = 11 sub.Parent = panel

    local field = Instance.new("Frame")
    field.Size = UDim2.new(1, -60, 0, 46) field.Position = UDim2.new(0, 30, 0, 132)
    field.BackgroundColor3 = Color3.fromRGB(22, 18, 34) field.BorderSizePixel = 0
    field.ZIndex = 11 field.Parent = panel
    local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0, 10) fc.Parent = field
    local fst = Instance.new("UIStroke") fst.Color = Color3.fromRGB(60, 50, 100) fst.Thickness = 1.5 fst.Parent = field
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -24, 1, 0) input.Position = UDim2.new(0, 12, 0, 0)
    input.BackgroundTransparency = 1 input.Font = Enum.Font.GothamMedium
    input.TextSize = 14 input.TextColor3 = Color3.fromRGB(245, 243, 255)
    input.PlaceholderText = "VL-XXXXXXXX or work.ink key"
    input.PlaceholderColor3 = Color3.fromRGB(110, 110, 130) input.Text = ""
    input.ClearTextOnFocus = false input.TextXAlignment = Enum.TextXAlignment.Left
    input.ZIndex = 12 input.Parent = field
    input.Focused:Connect(function()
        TweenService:Create(fst, TweenInfo.new(0.2), {Color = Color3.fromRGB(139, 92, 246), Transparency = 0}):Play()
    end)
    input.FocusLost:Connect(function()
        TweenService:Create(fst, TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 50, 100), Transparency = 0}):Play()
    end)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -60, 0, 44) btn.Position = UDim2.new(0, 30, 0, 190)
    btn.BackgroundColor3 = Color3.fromRGB(139, 92, 246) btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold btn.Text = "Validate Key" btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255) btn.AutoButtonColor = false
    btn.ZIndex = 11 btn.Parent = panel
    local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0, 10) bc.Parent = btn
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(167, 139, 250)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(139, 92, 246)}):Play()
    end)

    local gk = Instance.new("TextButton")
    gk.Size = UDim2.new(1, -60, 0, 30) gk.Position = UDim2.new(0, 30, 0, 246)
    gk.BackgroundColor3 = Color3.fromRGB(22, 18, 34) gk.BorderSizePixel = 0
    gk.Font = Enum.Font.GothamBold gk.Text = "Get a Key  \226\134\146" gk.TextSize = 11
    gk.TextColor3 = Color3.fromRGB(167, 139, 250) gk.AutoButtonColor = false
    gk.ZIndex = 11 gk.Parent = panel
    local gkc = Instance.new("UICorner") gkc.CornerRadius = UDim.new(0, 8) gkc.Parent = gk
    local gks = Instance.new("UIStroke") gks.Color = Color3.fromRGB(60, 50, 100) gks.Thickness = 1 gks.Transparency = 0.4 gks.Parent = gk
    gk.MouseButton1Click:Connect(function()
        if type(setclipboard) == "function" then
            pcall(setclipboard, KeySystem.KeyLink)
            gk.Text = "Link copied!"
            task.delay(1.5, function() if gk.Parent then gk.Text = "Get a Key  \226\134\146" end end)
        else
            gk.Text = KeySystem.KeyLink
        end
    end)

    local helpBtn = Instance.new("TextButton")
    helpBtn.Size = UDim2.new(1, -60, 0, 32) helpBtn.Position = UDim2.new(0, 30, 0, 286)
    helpBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242) helpBtn.BorderSizePixel = 0
    helpBtn.Font = Enum.Font.GothamBold
    helpBtn.Text = "Need Help? Join the Discord"
    helpBtn.TextSize = 11
    helpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    helpBtn.AutoButtonColor = false
    helpBtn.ZIndex = 11 helpBtn.Parent = panel
    local hc = Instance.new("UICorner") hc.CornerRadius = UDim.new(0, 8) hc.Parent = helpBtn
    local hsh = Instance.new("UIStroke")
    hsh.Color = Color3.fromRGB(120, 135, 255) hsh.Thickness = 1 hsh.Transparency = 0.25 hsh.Parent = helpBtn
    helpBtn.MouseEnter:Connect(function()
        TweenService:Create(helpBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(110, 122, 255)}):Play()
    end)
    helpBtn.MouseLeave:Connect(function()
        TweenService:Create(helpBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
    end)
    helpBtn.MouseButton1Click:Connect(function()
        if type(setclipboard) == "function" then
            pcall(setclipboard, DI)
            helpBtn.Text = "\226\156\147 Discord invite copied"
            helpBtn.BackgroundColor3 = Color3.fromRGB(80, 220, 130)
            task.delay(1.8, function()
                if helpBtn.Parent then
                    helpBtn.Text = "Need Help? Join the Discord"
                    helpBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
                end
            end)
        else
            helpBtn.Text = DI
            task.delay(2.2, function()
                if helpBtn.Parent then helpBtn.Text = "Need Help? Join the Discord" end
            end)
        end
    end)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -60, 0, 16) status.Position = UDim2.new(0, 30, 0, 328)
    status.BackgroundTransparency = 1 status.Font = Enum.Font.Gotham
    status.Text = "" status.TextSize = 10 status.TextColor3 = Color3.fromRGB(161, 161, 170)
    status.ZIndex = 11 status.Parent = panel

    local panelScale = Instance.new("UIScale")
    panelScale.Scale = 0.85 panelScale.Parent = panel
    panel.BackgroundTransparency = 1
    TweenService:Create(panelScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    TweenService:Create(panel, TweenInfo.new(0.4), {BackgroundTransparency = 0.05}):Play()

    local validating = false
    local function tryValidate()
        if validating then return end
        local key = tostring(input.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if key == "" then Popup.Show("Enter a key first", false) return end
        validating = true
        btn.Text = "Validating..."
        status.Text = "Checking..."
        status.TextColor3 = Color3.fromRGB(167, 139, 250)
        task.spawn(function()
            local ok, reason = false, "invalid"
            local okc, r1, r2 = pcall(KeySystem.Validate, key)
            if okc then ok = r1 and true or false reason = r2 or reason else reason = "exception" end
            task.wait(0.3)
            validating = false
            btn.Text = "Validate Key"
            if ok then
                local expiry = Configuration.IsPremium and Configuration.PremiumExpiry or (os.time() + KeySystem.DefaultExpiry)
                KeySystem.WriteSaved(key, expiry)
                if Configuration.IsPremium then
                    status.Text = "Premium active: " .. tostring(Configuration.PremiumTier)
                    status.TextColor3 = Color3.fromRGB(255, 200, 40)
                    Popup.Show("Premium activated: " .. tostring(Configuration.PremiumTier), true)
                else
                    status.Text = "Key valid - 24h access"
                    status.TextColor3 = Color3.fromRGB(80, 220, 130)
                    Popup.Show("Key valid - welcome", true)
                end
                task.wait(1.9)
                boltAlive = false
                pcall(function() sg:Destroy() end)
                KeySystem.Authorized = true
                if onAuthorized then pcall(onAuthorized) end
            else
                local msg = "Key doesn't exist"
                if reason == "http-unavailable" then msg = "Executor has no HTTP access"
                elseif reason == "bad-response" then msg = "Server rejected the request"
                elseif reason == "empty-response" then msg = "Server returned empty"
                elseif reason == "too-short" then msg = "Key is too short" end
                status.Text = msg
                status.TextColor3 = Color3.fromRGB(255, 80, 100)
                Popup.Show(msg, false)
                input.Text = ""
            end
        end)
    end
    btn.MouseButton1Click:Connect(tryValidate)
    input.FocusLost:Connect(function(enter) if enter then tryValidate() end end)

    return sg
end

local function makeScreenGui(name, order, ii)
    local par = safeGuiParent()
    if not par then return nil end
    local sg = Instance.new("ScreenGui")
    sg.Name = name sg.ResetOnSpawn = false sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = order or 1 sg.IgnoreGuiInset = ii ~= false
    pcall(function() sg.AutoLocalize = false end)
    pcall(function() sg.Parent = par end)
    return sg
end

local WeaponProfiles = {}
local ActiveWeaponName = "Default"

local PER_WEAPON_SETTINGS = {
    "CameraAssistSmoothing", "CameraAssistFOV",
    "CameraAssistMouseSensitivity", "CameraAssistPrediction", "CameraAssistBulletSpeed",
    "CameraAssistLead", "CameraAssistPlayerSens",
}
local function defaultProfiles()
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
WeaponProfiles = defaultProfiles()

local function classifyWeaponName(name)
    if not name or name == "" then return "Default" end
    local n = name:lower()
    if n:find("knife") or n:find("melee") or n:find("sword") or n:find("bat") or n:find("hammer") or n:find("fist") or n:find("karambit") or n:find("cutlass") or n:find("katana") then return "Melee" end
    if n:find("sniper") or n:find("awp") or n:find("barrett") or n:find("hunt") or n:find("ranger") or n:find("longshot") then return "Sniper" end
    if n:find("shotgun") or n:find("judge") or n:find("spas") or n:find("pump") or n:find("double") then return "Shotgun" end
    if n:find("smg") or n:find("uzi") or n:find("mp5") or n:find("mp7") or n:find("vector") or n:find("mac") then return "SMG" end
    if n:find("pistol") or n:find("glock") or n:find("deagle") or n:find("revolver") or n:find("handgun") then return "Pistol" end
    if n:find("rifle") or n:find("scar") or n:find("ak") or n:find("m4") or n:find("m16") or n:find("fal") or n:find("burst") or n:find("auto") then return "AR" end
    return "Default"
end

local function detectWeapon()
    local lp = Players.LocalPlayer
    if not lp then return "Default", nil end
    local char = lp.Character
    if not char or not char.Parent then return "Default", nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool.Name and tool.Name ~= "" then return classifyWeaponName(tool.Name), tool.Name end
    return "Default", nil
end

local function applyProfile(pn)
    local prof = WeaponProfiles[pn] or WeaponProfiles.Default
    if not prof then return end
    if Configuration.SilentAimEnabled then return end
    for _, k in ipairs(PER_WEAPON_SETTINGS) do if prof[k] ~= nil then Configuration[k] = prof[k] end end
    Configuration.CameraAssistPlayerSens = 0.15
    Configuration.CameraAssistRotateChar = true
end

local function saveActiveProfile()
    local prof = WeaponProfiles[ActiveWeaponName]
    if not prof then prof = {} WeaponProfiles[ActiveWeaponName] = prof end
    for _, k in ipairs(PER_WEAPON_SETTINGS) do prof[k] = Configuration[k] end
end

local ENUM_KEYCODES = { MenuKey = true, AimKeyCode = true, AutoFireKeyCode = true, AimControllerButton = true, AutoFireControllerButton = true }
local ENUM_UITYPES = { MenuMouseButton = true, AimMouseButton = true, AutoFireMouseButton = true }
local LOAD_EXCLUDE = { FlyEnabled = true, SpeedEnabled = true }

function Configuration:Save()
    if not ExecutorInfo.HasWritefile then return false end
    saveActiveProfile()
    local payload = {}
    for k, v in pairs(self) do
        if k == "BoxColorMap" or k == "HitSoundMap" then
        elseif k == "Save" or k == "Load" then
        elseif ENUM_KEYCODES[k] or ENUM_UITYPES[k] then
            if typeof(v) == "EnumItem" then payload[k] = tostring(v) end
        elseif typeof(v) == "Color3" then payload[k] = {r = v.R, g = v.G, b = v.B}
        else payload[k] = v end
    end
    local data
    local ok = pcall(function() data = HttpService:JSONEncode(payload) end)
    if not ok or not data then return false end
    local wrote = false
    for _, c in ipairs({{folder="VEIL", file="VEIL/Config.json"}, {folder=nil, file="VEIL_Config.json"}}) do
        if c.folder and ExecutorInfo.HasMakeFolder then pcall(makefolder, c.folder) end
        if pcall(writefile, c.file, data) then wrote = true break end
    end
    local wpdata
    local ok2 = pcall(function() wpdata = HttpService:JSONEncode(WeaponProfiles) end)
    if ok2 and wpdata then
        for _, c in ipairs({{folder="VEIL", file="VEIL/Weapons.json"}, {folder=nil, file="VEIL_Weapons.json"}}) do
            if pcall(writefile, c.file, wpdata) then break end
        end
    end
    return wrote
end

function Configuration:Load()
    if not ExecutorInfo.HasReadfile then return false end
    local data
    for _, p in ipairs({"VEIL/Config.json", "VEIL_Config.json"}) do
        local ok, d = pcall(readfile, p)
        if ok and d then data = d break end
    end
    if data then
        local decoded
        local ok = pcall(function() decoded = HttpService:JSONDecode(data) end)
        if ok and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                if not LOAD_EXCLUDE[k] and self[k] ~= nil and k ~= "HitSoundMap" then
                    if ENUM_KEYCODES[k] and typeof(v) == "string" then
                        local name = v:gsub("Enum%.[%w_]+%.", "")
                        local ok2, enum = pcall(function() return Enum.KeyCode[name] end)
                        if ok2 and enum then self[k] = enum end
                    elseif ENUM_UITYPES[k] and typeof(v) == "string" then
                        local name = v:gsub("Enum%.[%w_]+%.", "")
                        local ok2, enum = pcall(function() return Enum.UserInputType[name] end)
                        if ok2 and enum then self[k] = enum end
                    elseif type(v) == "table" and v.r and v.g and v.b then
                        self[k] = Color3.new(v.r, v.g, v.b)
                    else self[k] = v end
                end
            end
        end
    end
    local wpdata
    for _, p in ipairs({"VEIL/Weapons.json", "VEIL_Weapons.json"}) do
        local ok, d = pcall(readfile, p)
        if ok and d and d ~= "" then wpdata = d break end
    end
    if wpdata then
        local decoded
        local ok = pcall(function() decoded = HttpService:JSONDecode(wpdata) end)
        if ok and type(decoded) == "table" then
            for cat, profile in pairs(decoded) do
                if type(profile) == "table" then
                    WeaponProfiles[cat] = WeaponProfiles[cat] or {}
                    for k, v in pairs(profile) do WeaponProfiles[cat][k] = v end
                end
            end
        end
    end
    self.FlySpeed = math.clamp(tonumber(self.FlySpeed) or 50, 10, 80)
    self.SpeedValue = math.clamp(tonumber(self.SpeedValue) or 16, 16, 500)
    return true
end

local Connections = {}
function Connections.Track(c) if c then table.insert(Connections, c) end return c end
function Connections.DisconnectAll()
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    table.clear(Connections)
end

-- ============================================================
-- Utility
-- ============================================================
local Utility = {}
Utility.Players = Players
Utility.RunService = RunService
Utility.UserInputService = UIS
Utility.Workspace = Workspace
Utility.VisibleCache = {}
Utility.VisibleCacheTimestamps = {}
Utility.VisibleCacheDuration = 0.05
Utility.MinRayDist = 0.1
Utility.RecentMaxFOV = 70
Utility.RecentMaxFOVTime = 0
Utility.TeamCache = {}
Utility.TeamCacheTime = {}
Utility.TeamCacheDuration = 0.15
Utility.RaycastParams = RaycastParams.new()
Utility.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
Utility.RaycastParams.IgnoreWater = true
Utility.LobbyCache = nil
Utility.LobbyCacheTime = 0
Utility.LobbyCacheDuration = 0.4
Utility._hbpCache = setmetatable({}, {__mode = "k"})
Utility._visFilter = {}
Utility.HitboxNamePatterns = {
    HitboxHead=true, HitboxHeadSmall=true, PhysicalHitboxHead=true,
    HitboxBody=true, HitboxBodySmall=true,
    Head=true, UpperTorso=true, LowerTorso=true, HumanoidRootPart=true, Torso=true,
    LeftUpperArm=true, RightUpperArm=true, LeftLowerArm=true, RightLowerArm=true,
    LeftUpperLeg=true, RightUpperLeg=true, LeftLowerLeg=true, RightLowerLeg=true,
    LeftFoot=true, RightFoot=true, LeftHand=true, RightHand=true,
}
Utility.HitboxModes = {}
Utility.HitboxModes.Head = {"Head", "HitboxHead", "PhysicalHitboxHead", "HitboxHeadSmall"}
Utility.HitboxModes.UpperTorso = {"HitboxBody", "HitboxBodySmall", "UpperTorso", "Torso", "HumanoidRootPart"}
Utility.HitboxModes.Chest = {"HitboxBody", "HitboxBodySmall", "UpperTorso", "Torso", "HumanoidRootPart"}
Utility.HitboxModes.LowerTorso = {"LowerTorso", "Torso", "HitboxBody", "HitboxBodySmall", "HumanoidRootPart"}
Utility.DeflectCache = {}
Utility.DeflectCacheTime = {}
Utility.DeflectCacheDuration = 0.2

function Utility.GetCamera() return Workspace.CurrentCamera end
function Utility.ViewportScale()
    if not Configuration.ScaleWithViewport then return 1 end
    local c = Workspace.CurrentCamera
    if not c then return 1 end
    local v = c.ViewportSize
    if not v or v.Y <= 0 then return 1 end
    return v.Y / 1080
end
function Utility.IsValidNumber(n) return n == n and n ~= math.huge and n ~= -math.huge end
function Utility.IsValidVector(v)
    if not v then return false end
    return Utility.IsValidNumber(v.X) and Utility.IsValidNumber(v.Y) and Utility.IsValidNumber(v.Z)
end
function Utility.WorldToViewport(pos)
    local c = Workspace.CurrentCamera
    if not c or not c.Parent then return Vector2.new(0, 0), false, 0 end
    local ok, r = pcall(function() return c:WorldToViewportPoint(pos) end)
    if not ok or not r then return Vector2.new(0, 0), false, 0 end
    if not Utility.IsValidNumber(r.X) or not Utility.IsValidNumber(r.Y) then return Vector2.new(0, 0), false, 0 end
    return Vector2.new(r.X, r.Y), r.Z > 0, r.Z
end
function Utility.IsLocalAirborne()
    local lp = Players.LocalPlayer
    if not lp or not lp.Character then return false end
    local h = lp.Character:FindFirstChildOfClass("Humanoid")
    if not h then return false end
    local s = h:GetState()
    return s == Enum.HumanoidStateType.Jumping or s == Enum.HumanoidStateType.Freefall
        or s == Enum.HumanoidStateType.FallingDown or s == Enum.HumanoidStateType.PlatformStanding
end
function Utility.GetPlayerTeam(p)
    if not p then return nil end
    local t = nil
    pcall(function() t = p.Team end)
    if t then return t end
    local now = tick()
    if Utility.TeamCacheTime[p] and (now - Utility.TeamCacheTime[p]) < Utility.TeamCacheDuration then return Utility.TeamCache[p] end
    local res = nil
    pcall(function()
        local a = p:GetAttributes()
        for n, v in pairs(a) do
            local l = n:lower()
            if l == "team" or l == "teamid" or l == "teamidentifier" or l == "teamindex" or l:find("teamid") then res = v break end
        end
    end)
    if not res and p.Character then
        pcall(function()
            local a = p.Character:GetAttributes()
            for n, v in pairs(a) do
                local l = n:lower()
                if l == "team" or l == "teamid" or l == "teamidentifier" or l == "teamindex" or l:find("teamid") then res = v break end
            end
        end)
    end
    Utility.TeamCache[p] = res
    Utility.TeamCacheTime[p] = now
    return res
end
function Utility.ClearTeamCache(p)
    Utility.TeamCache[p] = nil Utility.TeamCacheTime[p] = nil
    Utility._vpCacheTick = 0
end
function Utility.IsEnemy(a, b)
    if not a or not b then return true end
    if not Configuration.TeamCheck then return true end
    local ta = Utility.GetPlayerTeam(a)
    local tb = Utility.GetPlayerTeam(b)
    if ta == nil or tb == nil then return true end
    if typeof(ta) == "Instance" and typeof(tb) == "Instance" then return ta ~= tb end
    return tostring(ta) ~= tostring(tb)
end
Utility._vpCache = {}
Utility._vpCacheTick = 0
function Utility.GetValidPlayers()
    local t = tick()
    if (t - Utility._vpCacheTick) < 0.1 then return Utility._vpCache end
    Utility._vpCacheTick = t
    local ps = Utility._vpCache
    table.clear(ps)
    local lp = Players.LocalPlayer
    if not lp then return ps end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and Utility.IsEnemy(lp, p) then
            local c = p.Character
            if c and c.Parent then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then
                    local hd = c:FindFirstChild("Head")
                    local rt = c:FindFirstChild("HumanoidRootPart")
                    if hd and rt then
                        table.insert(ps, {Player=p, Character=c, Humanoid=h, UserId=p.UserId})
                    end
                end
            end
        end
    end
    return ps
end
function Utility.IsInGame()
    if not Configuration.LobbyGuardEnabled then return true end
    local now = tick()
    if Utility.LobbyCache ~= nil and (now - Utility.LobbyCacheTime) < Utility.LobbyCacheDuration then return Utility.LobbyCache end
    local function finish(s) Utility.LobbyCache = s Utility.LobbyCacheTime = now return s end
    local o = Configuration.LobbyStateOverride or "Auto"
    if o == "InGame" then return finish(true) end
    if o == "Lobby" then return finish(false) end
    local ws = Workspace
    local lp = Players.LocalPlayer
    if not lp then return finish(true) end
    local cc = ws:FindFirstChild("Characters")
    if cc then
        local c = lp.Character
        if c and c.Parent then
            local par = c.Parent
            if par.Parent == cc then return finish(true) end
            if par == ws or par == cc then return finish(false) end
            if par.Name and par.Name:lower():find("lobby") then return finish(false) end
        else return finish(false) end
    end
    return finish(true)
end
function Utility.InvalidateLobbyCache() Utility.LobbyCache = nil Utility.LobbyCacheTime = 0 end
function Utility.ResolveHitboxMode(mode)
    mode = mode or Configuration.CameraAssistHitboxMode or "Head"
    if mode == "Random" then
        local opts = {"Head", "UpperTorso", "Chest"}
        return opts[math.random(1, #opts)]
    end
    return mode
end
function Utility.GetHitboxPosition(c, hname, cachePart)
    if not c or not c.Parent then return nil, nil end
    if cachePart and cachePart.Parent and Utility.IsValidVector(cachePart.Position) then
        if hname == "Head" and cachePart:IsA("BasePart") then
            return cachePart.Position + Vector3.new(0, cachePart.Size.Y * 0.30, 0), cachePart
        end
        return cachePart.Position, cachePart
    end
    local mode = hname or Configuration.CameraAssistHitboxMode or "Head"
    if mode == "Random" then mode = Utility.ResolveHitboxMode("Random") end
    local cached = Utility._hbpCache[c]
    if cached and cached.mode == mode and cached.part and cached.part.Parent then
        local pos = cached.part.Position
        if mode == "Head" and cached.part:IsA("BasePart") then
            pos = pos + Vector3.new(0, cached.part.Size.Y * 0.30, 0)
        end
        if Utility.IsValidVector(pos) then return pos, cached.part end
    end
    local names = Utility.HitboxModes[mode] or Utility.HitboxModes.Head
    for _, n in ipairs(names) do
        local p = c:FindFirstChild(n)
        if p and p.Parent then
            local pos = p.Position
            if mode == "Head" and p:IsA("BasePart") then
                pos = pos + Vector3.new(0, p.Size.Y * 0.30, 0)
            end
            if Utility.IsValidVector(pos) then
                Utility._hbpCache[c] = { mode = mode, part = p }
                return pos, p
            end
        end
    end
    return nil, nil
end
function Utility.IsTargetablePart(p)
    if not p then return false end
    if Utility.HitboxNamePatterns[p.Name] then return true end
    local l = p.Name:lower()
    return l:find("hitbox") or l:find("torso") or l:find("head") or l:find("hand")
        or l:find("foot") or l:find("leg") or l:find("arm") or l:find("body") or l:find("chest")
end
Utility._reloadCacheTick = 0
Utility._reloadCacheVal = false
function Utility.IsReloading()
    local t = tick()
    if (t - Utility._reloadCacheTick) < 0.15 then return Utility._reloadCacheVal end
    Utility._reloadCacheTick = t
    local val = false
    local lp = Players.LocalPlayer
    if lp and lp.Character then
        local c = lp.Character
        local tool = c:FindFirstChildOfClass("Tool")
        if tool then
            for _, ch in ipairs(tool:GetChildren()) do
                if ch:IsA("BoolValue") and ch.Name:lower():find("reload") and ch.Value then val = true break end
            end
        end
    end
    Utility._reloadCacheVal = val
    return val
end
function Utility.IsPositionVisible(tp, il, ck, tpart)
    if not Configuration.CameraAssistVisibleCheck then return true end
    local cam = Workspace.CurrentCamera
    if not cam then return false end
    il = il or {}
    if ck then
        local ts = Utility.VisibleCacheTimestamps[ck]
        if ts and (tick() - ts) < Utility.VisibleCacheDuration then return Utility.VisibleCache[ck] end
    end
    local fl = Utility._visFilter
    table.clear(fl)
    for _, item in ipairs(il) do if item and item.Parent then table.insert(fl, item) end end
    local lp = Players.LocalPlayer
    if lp and lp.Character and lp.Character.Parent then
        local found = false
        for _, item in ipairs(fl) do if item == lp.Character then found = true break end end
        if not found then table.insert(fl, lp.Character) end
    end
    if cam and cam.Parent then table.insert(fl, cam) end
    local origin = cam.CFrame.Position
    local tc = tpart and tpart:FindFirstAncestorOfClass("Model") or nil
    local function rp(point)
        local d = point - origin
        local dist = d.Magnitude
        if dist < 0.01 then return true end
        Utility.RaycastParams.FilterDescendantsInstances = fl
        local ok, r = pcall(function() return Workspace:Raycast(origin, d / dist * dist, Utility.RaycastParams) end)
        if not ok then return false end
        if r == nil then return true end
        local hi = r.Instance
        if hi == tpart then return true end
        if tc and hi:IsDescendantOf(tc) then
            if (hi.Position - tp).Magnitude <= 1.5 then return true end
        end
        local tr = 0
        if hi then
            local okT, t = pcall(function() return hi.Transparency end)
            if okT and typeof(t) == "number" then tr = t end
        end
        if tr >= 0.9 then return true end
        if (r.Position - origin).Magnitude >= dist - Utility.MinRayDist then return true end
        return false
    end
    local v = rp(tp)
    if not v and tc then
        local h = tc:FindFirstChild("Head")
        if h then v = rp(h.Position) end
    end
    if ck then
        Utility.VisibleCache[ck] = v
        Utility.VisibleCacheTimestamps[ck] = tick()
    end
    return v
end
function Utility.CameraRaycast(maxDist)
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local fl = Utility._camRayFilter
    if not fl then fl = {} Utility._camRayFilter = fl end
    table.clear(fl)
    local lp = Players.LocalPlayer
    if lp and lp.Character then table.insert(fl, lp.Character) end
    if cam then table.insert(fl, cam) end
    local pr = RaycastParams.new()
    pr.FilterType = Enum.RaycastFilterType.Exclude
    pr.FilterDescendantsInstances = fl
    pr.IgnoreWater = true
    local ok, r = pcall(function() return Workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * (maxDist or 1000), pr) end)
    if not ok or not r then return nil end
    local i = r.Instance
    return i, r.Position, i and i:FindFirstAncestorOfClass("Model") or nil
end
function Utility.IsTargetDeflecting(p)
    if not p then return false end
    local now = tick()
    local tlast = Utility.DeflectCacheTime[p]
    if tlast and (now - tlast) < Utility.DeflectCacheDuration then
        if not p.Parent then
            Utility.DeflectCache[p] = nil Utility.DeflectCacheTime[p] = nil
        else return Utility.DeflectCache[p] end
    end
    local res = false
    local c = p.Character
    if c and c.Parent then
        local tool = c:FindFirstChildOfClass("Tool")
        if tool then
            local n = tool.Name:lower()
            if n:find("katana") or n:find("sword") or n:find("blade") or n:find("saber") then
                for _, ch in ipairs(tool:GetChildren()) do
                    if ch:IsA("BoolValue") and ch.Value then
                        local cn = ch.Name:lower()
                        if cn:find("block") or cn:find("parry") or cn:find("guard")
                            or cn:find("deflect") or cn:find("hold") then res = true break end
                    elseif ch:IsA("NumberValue") and ch.Value > 0 then
                        local cn = ch.Name:lower()
                        if cn:find("block") or cn:find("parry") or cn:find("guard") or cn:find("deflect") then res = true break end
                    end
                end
            end
        end
    end
    Utility.DeflectCache[p] = res
    Utility.DeflectCacheTime[p] = now
    return res
end
-- ============================================================
-- Palette
-- ============================================================
local Palette = {
    Primary = Color3.fromRGB(139, 92, 246), Accent3 = Color3.fromRGB(167, 139, 250),
    Bg = Color3.fromRGB(8, 8, 13),
    Panel = Color3.fromRGB(17, 17, 26), PanelLight = Color3.fromRGB(28, 25, 44),
    Card = Color3.fromRGB(22, 20, 34), Accent = Color3.fromRGB(139, 92, 246),
    Accent2 = Color3.fromRGB(99, 102, 241), Text = Color3.fromRGB(245, 243, 255),
    TextMuted = Color3.fromRGB(161, 161, 170), Border = Color3.fromRGB(48, 44, 72),
    Success = Color3.fromRGB(80, 220, 130), Danger = Color3.fromRGB(255, 80, 100),
    Discord = Color3.fromRGB(88, 101, 242),
}
local VEILUI = {
    Bg = Color3.fromRGB(8, 8, 13), BtnBg = Color3.fromRGB(22, 20, 34),
    Stroke = Color3.fromRGB(48, 44, 72), Accent = Color3.fromRGB(139, 92, 246),
    Accent2 = Color3.fromRGB(99, 102, 241), Accent3 = Color3.fromRGB(167, 139, 250),
    Text = Color3.fromRGB(245, 243, 255), TextMuted = Color3.fromRGB(161, 161, 170),
    Gold = Color3.fromRGB(255, 200, 40),
}
local function addShine(label)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(180, 155, 220)),
        ColorSequenceKeypoint.new(0.40, Color3.fromRGB(180, 155, 220)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.60, Color3.fromRGB(180, 155, 220)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(180, 155, 220)),
    })
    grad.Offset = Vector2.new(-1, 0) grad.Parent = label
    task.spawn(function()
        while label.Parent do
            grad.Offset = Vector2.new(-1, 0)
            TweenService:Create(grad, TweenInfo.new(4.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Offset = Vector2.new(1, 0)}):Play()
            task.wait(5.5)
        end
    end)
    return grad
end

-- ============================================================
-- FOVCircle
-- ============================================================
local FOVCircle = {}
FOVCircle.Container = nil FOVCircle.Ring = nil FOVCircle.Stroke = nil FOVCircle.Hue = 0
FOVCircle._lastSize = nil FOVCircle._lastColor = nil FOVCircle._lastVisible = nil
FOVCircle._lastUpdate = 0
FOVCircle.ColorMap = {
    White = Color3.fromRGB(245, 243, 255), Red = Color3.fromRGB(255, 60, 60),
    Yellow = Color3.fromRGB(255, 220, 60), Blue = Palette.Accent2,
    Green = Color3.fromRGB(60, 220, 90), Black = Color3.fromRGB(25, 25, 30),
    Cyan = Color3.fromRGB(80, 220, 240), Purple = Color3.fromRGB(139, 92, 246),
    Orange = Color3.fromRGB(255, 140, 60), Pink = Color3.fromRGB(255, 100, 200),
    Lime = Color3.fromRGB(120, 255, 120), Teal = Color3.fromRGB(60, 200, 180),
}
function FOVCircle.Ensure()
    if FOVCircle.Container and FOVCircle.Container.Parent and FOVCircle.Ring and FOVCircle.Ring.Parent then return true end
    if FOVCircle.Container and not FOVCircle.Container.Parent then FOVCircle.Container = nil FOVCircle.Ring = nil FOVCircle.Stroke = nil end
    if not FOVCircle.Container then
        local sg = makeScreenGui("VEIL_FOV", 120, true)
        if not sg then return false end
        FOVCircle.Container = sg
    end
    if not FOVCircle.Ring or not FOVCircle.Ring.Parent then
        local r = Instance.new("Frame")
        r.Name = "Ring" r.AnchorPoint = Vector2.new(0.5, 0.5)
        r.Position = UDim2.new(0.5, 0, 0.5, 0) r.BackgroundTransparency = 1
        r.BorderSizePixel = 0 r.Visible = false r.Parent = FOVCircle.Container
        local cr = Instance.new("UICorner") cr.CornerRadius = UDim.new(0.5, 0) cr.Parent = r
        local st = Instance.new("UIStroke") st.Thickness = 2 st.Color = Palette.Primary st.Transparency = 0.1 st.Parent = r
        FOVCircle.Ring = r FOVCircle.Stroke = st
    end
    return true
end
function FOVCircle.Update()
    local now = tick()
    local interval = DeviceInfo.isMobile and (1 / 15) or (1 / 60)
    if now - FOVCircle._lastUpdate < interval then return end
    FOVCircle._lastUpdate = now
    FOVCircle.Ensure()
    if not FOVCircle.Ring then return end
    local cam = Workspace.CurrentCamera
    local showSilent = Configuration.SilentAimDrawFOV
    local showAimbot = Configuration.CameraAssistDrawFOV
    if not cam or (not showSilent and not showAimbot) then
        if FOVCircle._lastVisible ~= false then FOVCircle.Ring.Visible = false FOVCircle._lastVisible = false end
        return
    end
    local useSilent = showSilent
    local fovVal = useSilent and (Configuration.SilentAimFOV or 200) or (Configuration.CameraAssistFOV or 35)
    local colorName = useSilent and Configuration.SilentAimFOVColor or Configuration.CameraAssistFOVColor
    local sc = Utility.ViewportScale()
    local vp = cam.ViewportSize
    local maxDia = math.min(vp.X, vp.Y) - 40
    if maxDia < 40 then maxDia = 40 end
    local rad = math.clamp(fovVal * 10 * sc, 10, 4000)
    local dia = math.floor(rad * 2)
    if dia > maxDia then dia = maxDia end
    if FOVCircle._lastSize ~= dia then
        FOVCircle.Ring.Size = UDim2.new(0, dia, 0, dia)
        FOVCircle._lastSize = dia
    end
    if FOVCircle._lastVisible ~= true then FOVCircle.Ring.Visible = true FOVCircle._lastVisible = true end
    local st = FOVCircle.Stroke
    if not st then return end
    if colorName == "RGB" then
        FOVCircle.Hue = (FOVCircle.Hue + 0.002) % 1
        st.Color = Color3.fromHSV(FOVCircle.Hue, 1, 1)
        FOVCircle._lastColor = nil
    else
        local col = FOVCircle.ColorMap[colorName] or Palette.Primary
        if FOVCircle._lastColor ~= col then st.Color = col FOVCircle._lastColor = col end
    end
end
function FOVCircle.Destroy()
    if FOVCircle.Container then pcall(function() FOVCircle.Container:Destroy() end) end
    FOVCircle.Container = nil FOVCircle.Ring = nil FOVCircle.Stroke = nil
end

-- ============================================================
-- Visuals
-- ============================================================
local Visuals = {}
Visuals.Objects = {} Visuals.Container = nil Visuals.ValidPlayersCache = {}
Visuals.LastPlayerListUpdate = 0 Visuals.LastUpdateTime = 0 Visuals.LastVisibleCount = 0
Visuals.BoneConnections = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}
function Visuals.EnsureContainer()
    if Visuals.Container and Visuals.Container.Parent then return true end
    local sg = makeScreenGui("VEIL_Visuals", 5, true)
    if not sg then return false end
    Visuals.Container = sg
    return true
end
function Visuals.CreateSkeletonLines(player)
    local pid = player and player.UserId or "unknown"
    local lines = {}
    Visuals.EnsureContainer()
    if not Visuals.Container then return lines end
    local scm = Configuration.BoxColorMap or {}
    local baseCol = scm[Configuration.SkeletonColor] or Palette.Accent3
    for i = 1, #Visuals.BoneConnections do
        local l = Instance.new("Frame")
        l.Name = string.format("Skel_%s_%d", tostring(pid), i)
        l.BackgroundColor3 = baseCol l.BorderSizePixel = 0
        l.AnchorPoint = Vector2.new(0.5, 0.5)
        l.Size = UDim2.new(0, 0, 0, 1) l.Position = UDim2.new(0, -9999, 0, -9999)
        l.Visible = false l.ZIndex = 3 l.Parent = Visuals.Container
        table.insert(lines, l)
    end
    return lines
end
function Visuals.CreateElements(player)
    local pid = player and player.UserId
    if not pid or Visuals.Objects[pid] then return Visuals.Objects[pid] end
    Visuals.EnsureContainer()
    if not Visuals.Container then return nil end
    local fr = Instance.new("Frame")
    fr.Name = "Overlay_" .. tostring(pid)
    fr.Size = UDim2.new(0, 100, 0, 100) fr.Position = UDim2.new(0, -9999, 0, -9999)
    fr.BackgroundTransparency = 1 fr.BorderSizePixel = 0 fr.Visible = false fr.Parent = Visuals.Container
    local bx = Instance.new("Frame")
    bx.Size = UDim2.new(1, 0, 1, 0) bx.BackgroundTransparency = 1 bx.BorderSizePixel = 0 bx.ZIndex = 2 bx.Parent = fr
    local str = Instance.new("UIStroke")
    str.Color = Palette.Primary str.Thickness = 1.5
    str.ApplyStrokeMode = Enum.ApplyStrokeMode.Border str.Parent = bx
    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 0, 14) nl.Position = UDim2.new(0, 0, 0, -16)
    nl.BackgroundTransparency = 1 nl.Font = Enum.Font.Gotham nl.TextSize = 11
    nl.TextColor3 = Palette.Text nl.TextStrokeTransparency = 0.4
    nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) nl.TextXAlignment = Enum.TextXAlignment.Center
    nl.ZIndex = 4 nl.Parent = fr
    local hb = Instance.new("Frame")
    hb.Size = UDim2.new(0, 4, 1, 0) hb.Position = UDim2.new(-1, -6, 0, 0)
    hb.BackgroundColor3 = Color3.fromRGB(30, 28, 44) hb.BorderSizePixel = 0 hb.ZIndex = 2 hb.Parent = fr
    local hf = Instance.new("Frame")
    hf.Size = UDim2.new(1, 0, 1, 0) hf.BackgroundColor3 = Color3.fromRGB(0, 255, 100) hf.BorderSizePixel = 0 hf.Parent = hb
    local ht = Instance.new("TextLabel")
    ht.Size = UDim2.new(0, 32, 0, 12) ht.Position = UDim2.new(-1, -40, 0, -2)
    ht.BackgroundColor3 = Color3.fromRGB(0, 0, 0) ht.BackgroundTransparency = 0.35
    ht.Font = Enum.Font.Gotham ht.TextSize = 9 ht.TextColor3 = Palette.Text
    ht.TextStrokeTransparency = 0.5 ht.TextXAlignment = Enum.TextXAlignment.Left ht.ZIndex = 4 ht.Parent = fr
    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1, 0, 0, 12) dl.Position = UDim2.new(0, 0, 1, 2)
    dl.BackgroundTransparency = 1 dl.Font = Enum.Font.Gotham dl.TextSize = 9
    dl.TextColor3 = Palette.TextMuted dl.TextStrokeTransparency = 0.5
    dl.TextXAlignment = Enum.TextXAlignment.Center dl.ZIndex = 4 dl.Parent = fr
    local skel = Visuals.CreateSkeletonLines(player)
    local vo = { Container = fr, Box = bx, Stroke = str, Name = nl, HealthBar = hb, HealthFill = hf, HealthText = ht, Distance = dl, SkeletonLines = skel, Player = player, Character = nil }
    Visuals.Objects[pid] = vo
    return vo
end
function Visuals.UpdateSkeleton(vo, c)
    if not vo or not vo.SkeletonLines then return end
    local hide = false
    if not Configuration.ShowSkeleton then hide = true end
    if not vo.Container or not vo.Container.Visible then hide = true end
    if not c or not c.Parent then hide = true end
    if hide then
        for _, l in ipairs(vo.SkeletonLines) do if l.Visible then l.Visible = false end end
        return
    end
    local scm = Configuration.BoxColorMap or {}
    local skelCol = scm[Configuration.SkeletonColor] or Palette.Accent3
    for i, pair in ipairs(Visuals.BoneConnections) do
        local l = vo.SkeletonLines[i]
        if l then
            if l.BackgroundColor3 ~= skelCol then l.BackgroundColor3 = skelCol end
            local pa = c:FindFirstChild(pair[1])
            local pb = c:FindFirstChild(pair[2])
            local skip = false
            if not pa or not pb then skip = true end
            if not skip then
                local pa2, onA = Utility.WorldToViewport(pa.Position)
                local pb2, onB = Utility.WorldToViewport(pb.Position)
                if not onA or not onB then skip = true end
                if not skip then
                    local dx = pb2.X - pa2.X
                    local dy = pb2.Y - pa2.Y
                    local len = math.sqrt(dx * dx + dy * dy)
                    if len < 1 then skip = true end
                    if not skip then
                        local mx = (pa2.X + pb2.X) * 0.5
                        local my = (pa2.Y + pb2.Y) * 0.5
                        local ang = math.deg(math.atan2(dy, dx))
                        l.Size = UDim2.new(0, math.floor(len), 0, 1)
                        l.Position = UDim2.new(0, math.floor(mx), 0, math.floor(my))
                        l.Rotation = ang
                        if not l.Visible then l.Visible = true end
                    end
                end
            end
            if skip and l.Visible then l.Visible = false end
        end
    end
end
function Visuals.Step()
    if not Configuration.VisualsEnabled then
        for pid, vo in pairs(Visuals.Objects) do
            if vo.Container then pcall(function() vo.Container:Destroy() end) end
            if vo.SkeletonLines then
                for _, l in ipairs(vo.SkeletonLines) do if l then pcall(function() l:Destroy() end) end end
            end
        end
        Visuals.Objects = {}
        if Visuals.Container then
            for _, ch in ipairs(Visuals.Container:GetChildren()) do
                if ch.Name:sub(1, 7) == "Overlay" or ch.Name:sub(1, 5) == "Skel_" then pcall(function() ch:Destroy() end) end
            end
        end
        return
    end
    local now = tick()
    local lastCount = Visuals.LastVisibleCount or 0
    local targetHz
    if DeviceInfo.isMobile then
        if lastCount <= 6 then targetHz = 30
        elseif lastCount <= 12 then targetHz = 22
        elseif lastCount <= 24 then targetHz = 15
        else targetHz = 10 end
    else
        if lastCount <= 6 then targetHz = 240
        elseif lastCount <= 12 then targetHz = 144
        elseif lastCount <= 24 then targetHz = 90
        else targetHz = 60 end
    end
    local interval = 1.0 / targetHz
    if now - Visuals.LastUpdateTime < interval then return end
    Visuals.LastUpdateTime = now
    if now - Visuals.LastPlayerListUpdate > Configuration.PlayerListUpdateInterval then
        Visuals.LastPlayerListUpdate = now
        Visuals.ValidPlayersCache = Utility.GetValidPlayers()
    end
    local cam = Workspace.CurrentCamera
    if not cam or not cam.Parent then return end
    local lp = Players.LocalPlayer
    if not lp or not lp.Character then return end
    local lpRoot = lp.Character:FindFirstChild("HumanoidRootPart")
    local vpW = cam.ViewportSize.X
    local vpH = cam.ViewportSize.Y
    local active = {}
    local bcm = Configuration.BoxColorMap or {}
    for _, pd in ipairs(Visuals.ValidPlayersCache) do
        local player = pd.Player
        local c = pd.Character
        local h = pd.Humanoid
        if c and c.Parent and h and h.Parent then
            active[player.UserId] = true
            local vo = Visuals.Objects[player.UserId] or Visuals.CreateElements(player)
            if vo then
                local head = c:FindFirstChild("Head")
                local root = c:FindFirstChild("HumanoidRootPart")
                local vis = false
                if head and root then
                    local hS, hOn = Utility.WorldToViewport(head.Position)
                    local rS, rOn = Utility.WorldToViewport(root.Position)
                    if hOn and rOn then
                        local halfH = rS.Y - hS.Y
                        if halfH <= 0 then halfH = -halfH end
                        local ht = math.max(math.floor(halfH * 2 * 1.5 + 0.5), 30)
                        local wd = math.max(math.floor(ht * 0.45 + 0.5), 15)
                        local cx = math.floor(hS.X - wd * 0.5 + 0.5)
                        local cy = math.floor(hS.Y + halfH - ht * 0.5 + 0.5)
                        if cx > -wd and cx < vpW and cy > -ht and cy < vpH then
                            vo.Container.Position = UDim2.new(0, cx, 0, cy)
                            vo.Container.Size = UDim2.new(0, wd, 0, ht)
                            vo.Box.Visible = Configuration.ShowBoxes
                            vo.Stroke.Enabled = Configuration.ShowBoxes
                            vo.Stroke.Color = bcm[Configuration.BoxColor] or Palette.Primary
                            vo.Name.Visible = Configuration.ShowNames
                            vo.Name.TextColor3 = bcm[Configuration.NameColor] or Palette.Text
                            local nm = player.Name or "?"
                            if vo.Name.Text ~= nm then vo.Name.Text = nm end
                            if Configuration.ShowHealth then
                                vo.HealthBar.Visible = true
                                vo.HealthText.Visible = true
                                local hp = h.Health / math.max(h.MaxHealth, 1)
                                vo.HealthFill.Size = UDim2.new(1, 0, hp, 0)
                                local hpt = tostring(math.floor(h.Health))
                                if vo.HealthText.Text ~= hpt then vo.HealthText.Text = hpt end
                                local hc
                                if hp > 0.6 then hc = Color3.fromRGB(0, 255, 100)
                                elseif hp > 0.3 then hc = Color3.fromRGB(255, 255, 0)
                                else hc = Color3.fromRGB(255, 0, 0) end
                                if vo.HealthFill.BackgroundColor3 ~= hc then vo.HealthFill.BackgroundColor3 = hc end
                            else
                                if vo.HealthBar.Visible then vo.HealthBar.Visible = false end
                                if vo.HealthText.Visible then vo.HealthText.Visible = false end
                            end
                            if Configuration.ShowDistance and lpRoot then
                                if not vo.Distance.Visible then vo.Distance.Visible = true end
                                local d = (lpRoot.Position - root.Position).Magnitude
                                if d < Configuration.MaxRenderDistance then
                                    local dt = string.format("%dm", math.floor(d))
                                    if vo.Distance.Text ~= dt then vo.Distance.Text = dt end
                                else
                                    if vo.Distance.Visible then vo.Distance.Visible = false end
                                end
                            else
                                if vo.Distance.Visible then vo.Distance.Visible = false end
                            end
                            vis = true
                        end
                    end
                end
                if vis then
                    Visuals.UpdateSkeleton(vo, c)
                    if not vo.Container.Visible then vo.Container.Visible = true end
                else
                    if vo.Container.Visible then vo.Container.Visible = false end
                    if vo.SkeletonLines then
                        for _, l in ipairs(vo.SkeletonLines) do if l.Visible then l.Visible = false end end
                    end
                end
            end
        end
    end
    for pid, vo in pairs(Visuals.Objects) do
        if not active[pid] then
            if vo.Container then pcall(function() vo.Container:Destroy() end) end
            if vo.SkeletonLines then
                for _, l in ipairs(vo.SkeletonLines) do if l then pcall(function() l:Destroy() end) end end
            end
            Visuals.Objects[pid] = nil
        end
    end
    local n = 0
    for _ in pairs(active) do n = n + 1 end
    Visuals.LastVisibleCount = n
end
function Visuals.OnPlayerRemoving(player)
    local v = Visuals.Objects[player and player.UserId]
    if v then
        if v.Container then pcall(function() v.Container:Destroy() end) end
        if v.SkeletonLines then
            for _, l in ipairs(v.SkeletonLines) do if l then pcall(function() l:Destroy() end) end end
        end
        Visuals.Objects[player.UserId] = nil
    end
end

-- ============================================================
-- CameraAssist
-- ============================================================
local CameraAssist = {}
CameraAssist.Lock = nil CameraAssist.Bound = false
CameraAssist.BindName = "VEIL_Aim_" .. tostring(math.random(1, 999999))
CameraAssist.KeyHeld = false CameraAssist.ShuttingDown = false
CameraAssist.LastLockUserId = nil
CameraAssist.SavedPostFX = {}
CameraAssist.MouseAccumX = 0 CameraAssist.MouseAccumY = 0
CameraAssist.PingEstimate = 0.06 CameraAssist.LastPingUpdate = 0
CameraAssist.WasScoped = false CameraAssist.PreferUserId = nil CameraAssist.PreferUntil = 0
CameraAssist.MissGrace = 12 CameraAssist.DesiredLook = nil CameraAssist.LastWrittenCF = nil
CameraAssist.CamSignalConn = nil CameraAssist.CamSwapConn = nil
CameraAssist.WasAirborne = false CameraAssist.AirborneUntil = 0
CameraAssist.LockedTargetWorldPos = nil
CameraAssist.LastLockSwitchTime = 0 CameraAssist.AimState = nil CameraAssist.AimStateChar = nil
CameraAssist.LastFactor = 0 CameraAssist.LastEffSmoothing = 0
CameraAssist.LastTargetPos = nil CameraAssist.LastTargetPosTime = 0
CameraAssist._deflectCooldownUntil = 0 CameraAssist._deflectCooldownUser = nil
CameraAssist.ViewFOVBindName = "VEIL_ViewFOV_" .. tostring(math.random(1, 999999))
CameraAssist.ViewFOVBound = false
CameraAssist.ControllerFireHeld = false CameraAssist.LastInputWasController = false
CameraAssist.BlockFireTarget = nil
CameraAssist.SavedAutoRotate = nil
CameraAssist._preRenderConn = nil
CameraAssist._pendingNCF = nil
CameraAssist._lastCamWrite = 0
CameraAssist._neckJoint = nil
CameraAssist._neckC0 = nil

local MAX_PITCH = math.rad(85)
local SIN_MAX = math.sin(MAX_PITCH)

local function clampPitch(v)
    if not v or v.Magnitude < 1e-4 then return v end
    v = v.Unit
    local y = math.clamp(v.Y, -SIN_MAX, SIN_MAX)
    local hm = math.sqrt(math.max(0, 1 - y * y))
    local hl = math.sqrt(v.X * v.X + v.Z * v.Z)
    if hl < 1e-4 then return Vector3.new(0, y, -hm) end
    local s = hm / hl
    return Vector3.new(v.X * s, y, v.Z * s)
end
local function applyMouseDelta(dir, dyaw, dpitch)
    if not dir or dir.Magnitude < 1e-4 then return dir end
    dir = dir.Unit
    local yaw = math.atan2(-dir.X, -dir.Z)
    local pitch = math.asin(math.clamp(dir.Y, -1, 1))
    yaw = yaw + math.rad(dyaw)
    pitch = math.clamp(pitch + math.rad(dpitch), -MAX_PITCH, MAX_PITCH)
    local cy = math.cos(pitch)
    return Vector3.new(-math.sin(yaw) * cy, math.sin(pitch), -math.cos(yaw) * cy).Unit
end
local function smoothingToFactor(s, dt)
    if s <= 2 then return 1 end
    local rate
    if s <= 7 then rate = 8 + (7 - s) * 4 else rate = 60 / s end
    local f = 1 - math.exp(-rate * dt)
    return math.clamp(f, 0, 1)
end
function CameraAssist.BindViewFOV()
    if CameraAssist.ViewFOVBound then return end
    CameraAssist.ViewFOVBound = true
    pcall(function() RunService:UnbindFromRenderStep(CameraAssist.ViewFOVBindName) end)
    pcall(function()
        RunService:BindToRenderStep(CameraAssist.ViewFOVBindName, Enum.RenderPriority.Camera.Value + 10050, function()
            if CameraAssist.ShuttingDown then return end
            if not Configuration.ViewFOVEnabled then return end
            if CameraAssist.Lock then return end
            if CameraAssist.WasScoped then return end
            local c = Workspace.CurrentCamera
            if not c then return end
            local t = Configuration.ViewFOV or 90
            if math.abs(c.FieldOfView - t) > 0.5 then pcall(function() c.FieldOfView = t end) end
        end)
    end)
    _G.__VEIL_viewfov_bind = CameraAssist.ViewFOVBindName
end
function CameraAssist.UnbindViewFOV()
    if not CameraAssist.ViewFOVBound then return end
    CameraAssist.ViewFOVBound = false
    pcall(function() RunService:UnbindFromRenderStep(CameraAssist.ViewFOVBindName) end)
end
function CameraAssist.AttachCamWatcher()
    if CameraAssist.CamSignalConn then
        pcall(function() CameraAssist.CamSignalConn:Disconnect() end)
        CameraAssist.CamSignalConn = nil
    end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    pcall(function()
        CameraAssist.CamSignalConn = cam:GetPropertyChangedSignal("CFrame"):Connect(function()
            if CameraAssist.ShuttingDown then return end
            if not CameraAssist.Lock then return end
            if not CameraAssist.DesiredLook then return end
            local lk = CameraAssist.Lock
            if not lk.Character or not lk.Character.Parent then return end
            local inc = cam.CFrame
            if CameraAssist.LastWrittenCF and inc == CameraAssist.LastWrittenCF then return end
            local ok, cf = pcall(function() return CFrame.lookAt(inc.Position, inc.Position + CameraAssist.DesiredLook, Vector3.new(0, 1, 0)) end)
            if not ok or not cf then return end
            CameraAssist.LastWrittenCF = cf
            CameraAssist._lastCamWrite = tick()
            pcall(function() cam.CFrame = cf end)
        end)
    end)
end
function CameraAssist.AttachCameraSwapHook()
    if CameraAssist.CamSwapConn then
        pcall(function() CameraAssist.CamSwapConn:Disconnect() end)
        CameraAssist.CamSwapConn = nil
    end
    pcall(function()
        CameraAssist.CamSwapConn = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            task.wait(0.05)
            CameraAssist.AttachCamWatcher()
        end)
    end)
end
function CameraAssist.InitFocusTracking()
    pcall(function()
        Connections.Track(UIS.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                CameraAssist.MouseAccumX = CameraAssist.MouseAccumX + input.Delta.X
                CameraAssist.MouseAccumY = CameraAssist.MouseAccumY + input.Delta.Y
            end
        end))
    end)
    pcall(function()
        Connections.Track(UIS.InputBegan:Connect(function(input)
            if Configuration.AimBindType == "Mouse" then
                if input.UserInputType == Configuration.AimMouseButton then CameraAssist.KeyHeld = true end
            else
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Configuration.AimKeyCode then CameraAssist.KeyHeld = true end
            end
        end))
    end)
    pcall(function()
        Connections.Track(UIS.InputEnded:Connect(function(input)
            if Configuration.AimBindType == "Mouse" then
                if input.UserInputType == Configuration.AimMouseButton then CameraAssist.KeyHeld = false end
            else
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Configuration.AimKeyCode then CameraAssist.KeyHeld = false end
            end
        end))
    end)
    pcall(function()
        Connections.Track(UIS.InputBegan:Connect(function(input)
            local uit = input.UserInputType
            local isPad = uit == Enum.UserInputType.Gamepad1 or uit == Enum.UserInputType.Gamepad2 or uit == Enum.UserInputType.Gamepad3 or uit == Enum.UserInputType.Gamepad4
            if isPad then
                CameraAssist.LastInputWasController = true
                if input.KeyCode == Configuration.AimControllerButton then CameraAssist.KeyHeld = true end
                if input.KeyCode == Configuration.AutoFireControllerButton then CameraAssist.ControllerFireHeld = true end
            elseif uit == Enum.UserInputType.MouseButton1 or uit == Enum.UserInputType.MouseMovement or uit == Enum.UserInputType.Keyboard then
                CameraAssist.LastInputWasController = false
            end
        end))
    end)
    pcall(function()
        Connections.Track(UIS.InputEnded:Connect(function(input)
            local uit = input.UserInputType
            local isPad = uit == Enum.UserInputType.Gamepad1 or uit == Enum.UserInputType.Gamepad2 or uit == Enum.UserInputType.Gamepad3 or uit == Enum.UserInputType.Gamepad4
            if isPad then
                if input.KeyCode == Configuration.AimControllerButton then CameraAssist.KeyHeld = false end
                if input.KeyCode == Configuration.AutoFireControllerButton then CameraAssist.ControllerFireHeld = false end
            end
        end))
    end)
end
function CameraAssist.MutePostFX()
    CameraAssist.SavedPostFX = {}
    for _, inst in ipairs(Lighting:GetChildren()) do
        if inst:IsA("BlurEffect") or inst:IsA("DepthOfFieldEffect") then
            if inst.Enabled then
                CameraAssist.SavedPostFX[inst] = true
                pcall(function() inst.Enabled = false end)
            end
        end
    end
end
function CameraAssist.RestorePostFX()
    local s = CameraAssist.SavedPostFX
    CameraAssist.SavedPostFX = {}
    for inst, _ in pairs(s) do if inst and inst.Parent then pcall(function() inst.Enabled = true end) end end
end
function CameraAssist.ClearLock()
    if not IS_LOW_UNC and CamControls and CamControls.SetRotation then
        local cam = Workspace.CurrentCamera
        if cam then pcall(function() CamControls:SetRotation(cam.CFrame) end) end
    end
    if CameraAssist.Lock and CameraAssist.Lock.UserId then
        CameraAssist.PreferUserId = CameraAssist.Lock.UserId
        CameraAssist.PreferUntil = tick() + 0.6
    end
    CameraAssist.Lock = nil CameraAssist.LastLockUserId = nil
    CameraAssist.DesiredLook = nil CameraAssist.LastWrittenCF = nil
    CameraAssist.LockedTargetWorldPos = nil CameraAssist.AimState = nil CameraAssist.AimStateChar = nil
    CameraAssist.LastTargetPos = nil CameraAssist.LastTargetPosTime = 0
    CameraAssist._pendingNCF = nil
    task.defer(function()
        pcall(function()
            local lp = Players.LocalPlayer
            local mc = lp and lp.Character
            if mc then
                local hum = mc:FindFirstChildOfClass("Humanoid")
                local my = mc:FindFirstChild("HumanoidRootPart")
                if hum and CameraAssist.SavedAutoRotate ~= nil then
                    hum.AutoRotate = CameraAssist.SavedAutoRotate
                    CameraAssist.SavedAutoRotate = nil
                end
                if my then
                    local g = my:FindFirstChild("VEIL_AimGyro")
                    if g then g:Destroy() end
                end
            end
        end)
    end)
end
function CameraAssist.IsTargetSticky(lk)
    if not lk or not lk.Character or not lk.Character.Parent then return false end
    local cam = Workspace.CurrentCamera
    if not cam then return true end
    local pos = Utility.GetHitboxPosition(lk.Character, lk.ResolvedHitbox, lk.HitboxPart)
    if not pos then return false end
    local cp = cam.CFrame.Position
    local look = cam.CFrame.LookVector
    local dl = pos - cp
    local dist = dl.Magnitude
    if dist < 0.1 then return true end
    local dir = dl / dist
    local ad = math.deg(math.acos(math.clamp(look:Dot(dir), -1, 1)))
    local silentActive = Configuration.SilentAimEnabled
    local activeFov = silentActive and (Configuration.SilentAimFOV or 200) or (Configuration.CameraAssistFOV or 35)
    local ss = 1.0 - (math.min(Configuration.CameraAssistSmoothing or 0, 20) / 20) * 0.5
    local sa = math.max(activeFov * 0.9, 18) * 1.6 * ss
    if Utility.IsLocalAirborne() then sa = sa * 2.2 end
    return ad <= sa
end
function CameraAssist.MakeLock(pd, resolvedMode)
    local silent = Configuration.SilentAimEnabled
    local um = silent and (Configuration.SilentAimHitbox or "Head") or (Configuration.CameraAssistHitboxMode or "Head")
    local res = resolvedMode or Utility.ResolveHitboxMode(um)
    local pos, part = Utility.GetHitboxPosition(pd.Character, res)
    if pos and res == "Head" and HEAD_AIM_OFFSET ~= 0 then
        pos = pos + Vector3.new(0, HEAD_AIM_OFFSET, 0)
    end
    local now = tick()
    return { UserId = pd.UserId, Player = pd.Player, Character = pd.Character,
             UserMode = um, ResolvedHitbox = res, HitboxPart = part,
             LastPos = pos, LastPosTime = pos and now or 0, Visible = true, MissFrames = 0,
             FirstLockTime = now }
end
function CameraAssist.UpdateLock(lk)
    if not lk then return false end
    local silent = Configuration.SilentAimEnabled
    local expected = silent and (Configuration.SilentAimHitbox or "Head") or (Configuration.CameraAssistHitboxMode or "Head")
    if lk.UserMode ~= expected then return false end
    local p = lk.Player
    if not p or not p.Parent then return false end
    local c = lk.Character
    if not c or not c.Parent then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    if Utility.IsTargetDeflecting(p) then
        CameraAssist._deflectCooldownUntil = tick() + 0.40
        CameraAssist._deflectCooldownUser = p.UserId
        return false
    end
    if CameraAssist._deflectCooldownUser == p.UserId and tick() < (CameraAssist._deflectCooldownUntil or 0) then
        return false
    end
    if lk.HitboxPart and lk.HitboxPart.Parent then
        local allowed = Utility.HitboxModes[lk.ResolvedHitbox] or Utility.HitboxModes.Head
        local okname = false
        for _, n in ipairs(allowed) do if lk.HitboxPart.Name == n then okname = true break end end
        if not okname then lk.HitboxPart = nil end
    else
        lk.HitboxPart = nil
    end
    local pos, part = Utility.GetHitboxPosition(c, lk.ResolvedHitbox, lk.HitboxPart)
    if pos then
        if lk.ResolvedHitbox == "Head" and HEAD_AIM_OFFSET ~= 0 then
            pos = pos + Vector3.new(0, HEAD_AIM_OFFSET, 0)
        end
        lk.LastPos = pos lk.LastPosTime = tick()
        if part then lk.HitboxPart = part end
    end
    if Configuration.CameraAssistVisibleCheck and lk.LastPos then
        lk.Visible = Utility.IsPositionVisible(lk.LastPos, {c}, tostring(lk.UserId), lk.HitboxPart)
    else lk.Visible = true end
    return true
end
function CameraAssist.AcquireLock()
    if Configuration.LobbyGuardEnabled and not Utility.IsInGame() then return nil end
    local cam = Workspace.CurrentCamera
    if not cam or not cam.Parent then return nil end
    local cx = cam.ViewportSize.X * 0.5
    local cy = cam.ViewportSize.Y * 0.5
    local sc = Utility.ViewportScale()
    local silent = Configuration.SilentAimEnabled
    local activeFov = silent and (Configuration.SilentAimFOV or 200) or (Configuration.CameraAssistFOV or 35)
    local br = math.max(activeFov * 10 * sc, 110 * sc)
    if not silent then
        local cap = (Configuration.CameraAssistAcquisitionRadius or 300) * sc
        if cap > 0 and br > cap then br = cap end
    end
    local brSq = br * br
    local pid = CameraAssist.PreferUserId
    local pa = pid and tick() < (CameraAssist.PreferUntil or 0)
    local prSq = (br * 1.8) * (br * 1.8)
    local best, bdSq = nil, math.huge
    local bp, bpdSq = nil, math.huge
    local bres, bpres = nil, nil
    local mode = silent and (Configuration.SilentAimHitbox or "Head") or (Configuration.CameraAssistHitboxMode or "Head")
    local lpPos = nil
    if silent then
        local lpC = Players.LocalPlayer and Players.LocalPlayer.Character
        if lpC then
            local r = lpC:FindFirstChild("HumanoidRootPart")
            if r then lpPos = r.Position end
        end
    end
    for _, pd in ipairs(Utility.GetValidPlayers()) do
        local c = pd.Character
        if c and c.Parent then
            local skip = false
            if CameraAssist._deflectCooldownUser == pd.UserId and tick() < (CameraAssist._deflectCooldownUntil or 0) then
                skip = true
            elseif Utility.IsTargetDeflecting(pd.Player) then skip = true end
            if not skip then
                local rm = mode
                if mode == "Random" then rm = Utility.ResolveHitboxMode("Random") end
                local pos, part = Utility.GetHitboxPosition(c, rm)
                if pos then
                    local el = true
                    if Configuration.CameraAssistVisibleCheck and not silent then
                        if not Utility.IsPositionVisible(pos, {c}, nil, part) then el = false end
                    end
                    if el then
                        local sp, on = Utility.WorldToViewport(pos)
                        if on then
                            local dx = sp.X - cx
                            local dy = sp.Y - cy
                            local dSq = dx * dx + dy * dy
                            if dSq <= brSq then
                                if silent and lpPos then
                                    local d3 = (pos - lpPos).Magnitude
                                    local d3sq = d3 * d3
                                    if pa and pd.UserId == pid and dSq <= prSq then
                                        if d3sq < bpdSq then bpdSq = d3sq bp = pd bpres = rm end
                                    end
                                    if d3sq < bdSq then bdSq = d3sq best = pd bres = rm end
                                else
                                    if pa and pd.UserId == pid and dSq <= prSq then
                                        if dSq < bpdSq then bpdSq = dSq bp = pd bpres = rm end
                                    end
                                    if dSq < bdSq then bdSq = dSq best = pd bres = rm end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if bp then best = bp bres = bpres end
    if not best then return nil end
    if silent and not CameraAssist.Lock then
        local chance = math.clamp(Configuration.SilentAimHitChance or 100, 0, 100)
        if chance < 100 and math.random() * 100 > chance then return nil end
    end
    return CameraAssist.MakeLock(best, bres)
end
function CameraAssist.FindCloserTarget(cl)
    if not Configuration.CameraAssistFOVPriority or not cl then return nil end
    if tick() - (CameraAssist.LastLockSwitchTime or 0) < 0.1 then return nil end
    local cam = Workspace.CurrentCamera
    if not cam or not cam.Parent then return nil end
    local cx = cam.ViewportSize.X * 0.5
    local cy = cam.ViewportSize.Y * 0.5
    local sc = Utility.ViewportScale()
    local br = math.max(Configuration.CameraAssistFOV * 10 * sc, 110 * sc)
    local cap = (Configuration.CameraAssistAcquisitionRadius or 300) * sc
    if cap > 0 and br > cap then br = cap end
    local brSq = br * br
    local mode = Configuration.CameraAssistHitboxMode or "Head"
    local cdSq = math.huge
    if cl.Character and cl.Character.Parent then
        local pos = Utility.GetHitboxPosition(cl.Character, cl.ResolvedHitbox, cl.HitboxPart)
        if pos then
            local sp, on = Utility.WorldToViewport(pos)
            if on then
                local dx = sp.X - cx
                local dy = sp.Y - cy
                cdSq = dx * dx + dy * dy
            end
        end
    end
    local best, bdSq, bres = nil, math.huge, nil
    for _, pd in ipairs(Utility.GetValidPlayers()) do
        if pd.UserId ~= cl.UserId then
            local c = pd.Character
            if c and c.Parent then
                local pos, part = Utility.GetHitboxPosition(c, mode)
                if pos then
                    local el = true
                    if Configuration.CameraAssistVisibleCheck then
                        if not Utility.IsPositionVisible(pos, {c}, nil, part) then el = false end
                    end
                    if el then
                        local sp, on = Utility.WorldToViewport(pos)
                        if on then
                            local dx = sp.X - cx
                            local dy = sp.Y - cy
                            local dSq = dx * dx + dy * dy
                            if dSq <= brSq and dSq < bdSq then bdSq = dSq best = pd bres = mode end
                        end
                    end
                end
            end
        end
    end
    if best and bdSq < cdSq * 0.90 then return CameraAssist.MakeLock(best, bres) end
    return nil
end
function CameraAssist.Apply(dt)
    if CameraAssist.ShuttingDown then return end
    if not Configuration.CameraAssistEnabled and not Configuration.SilentAimEnabled then return end
    if not IS_LOW_UNC and not CamControls then
        pcall(function()
            local lp = Players.LocalPlayer
            if not lp then return end
            local ps = lp:FindFirstChild("PlayerScripts")
            if not ps then return end
            local pm = ps:FindFirstChild("PlayerModule")
            if not pm then return end
            local m = require(pm)
            if m and m.GetControls then
                CamControls = m:GetControls()
                _G.__VEIL_CamControls = CamControls
            end
        end)
    end
    local mdX = CameraAssist.MouseAccumX or 0
    local mdY = CameraAssist.MouseAccumY or 0
    CameraAssist.MouseAccumX = 0 CameraAssist.MouseAccumY = 0
    local air = Utility.IsLocalAirborne()
    if air then CameraAssist.AirborneUntil = tick() + 0.35 end
    local inAir = air or tick() < (CameraAssist.AirborneUntil or 0)
    local kh = CameraAssist.KeyHeld or (Configuration.CameraAssistAlwaysOn and Configuration.CameraAssistEnabled)
    local typing = false
    pcall(function() typing = UIS:GetFocusedTextBox() ~= nil end)
    if typing then kh = false end
    local cam = Workspace.CurrentCamera
    if not cam or not cam.Parent then return end
    local lp = Players.LocalPlayer
    local mc = lp and lp.Character
    if not mc or not mc.Parent then return end
    if Configuration.LobbyGuardEnabled and not Utility.IsInGame() then
        if CameraAssist.Lock then CameraAssist.ClearLock() end
        if next(CameraAssist.SavedPostFX) then CameraAssist.RestorePostFX() end
        CameraAssist.AimState = nil CameraAssist.AimStateChar = nil CameraAssist.BlockFireTarget = nil
        return
    end
    local myHum = mc:FindFirstChildOfClass("Humanoid")
    local subj = cam.CameraSubject
    local spectating = false
    if not myHum or myHum.Health <= 0 then spectating = true
    elseif subj and subj:IsA("Humanoid") and subj ~= myHum then spectating = true end
    if spectating then
        if CameraAssist.Lock then CameraAssist.ClearLock() end
        if next(CameraAssist.SavedPostFX) then CameraAssist.RestorePostFX() end
        CameraAssist.DesiredLook = nil CameraAssist.LastWrittenCF = nil CameraAssist.BlockFireTarget = nil
        return
    end
    if CameraAssist.Lock and CameraAssist.Lock.Player then
        local lkp = CameraAssist.Lock.Player
        if Utility.IsTargetDeflecting(lkp) then
            CameraAssist._deflectCooldownUntil = tick() + 0.40
            CameraAssist._deflectCooldownUser = lkp.UserId
            CameraAssist.ClearLock()
            CameraAssist.AimState = nil CameraAssist.AimStateChar = nil
            CameraAssist.BlockFireTarget = nil CameraAssist.DesiredLook = nil CameraAssist.LastWrittenCF = nil
            return
        end
        if CameraAssist._deflectCooldownUser == lkp.UserId and tick() < (CameraAssist._deflectCooldownUntil or 0) then
            CameraAssist.DesiredLook = nil CameraAssist.LastWrittenCF = nil CameraAssist.BlockFireTarget = nil
            return
        end
    end
    local scoped = false
    local fov = cam.FieldOfView
    if fov and fov >= 5 then
        local now2 = tick()
        if fov > Utility.RecentMaxFOV then Utility.RecentMaxFOV = fov Utility.RecentMaxFOVTime = now2
        elseif (now2 - Utility.RecentMaxFOVTime) > 2.0 then
            Utility.RecentMaxFOV = math.max(Utility.RecentMaxFOV * 0.997, 40)
            Utility.RecentMaxFOVTime = now2
        end
        local base = math.max(Utility.RecentMaxFOV, 40)
        if CameraAssist.WasScoped then scoped = fov < (base * 0.92) else scoped = fov < (base * 0.80) end
    end
    CameraAssist.WasScoped = scoped
    if Utility.IsReloading() then
        if CameraAssist.Lock then CameraAssist.ClearLock() end
        CameraAssist.AimState = nil CameraAssist.AimStateChar = nil CameraAssist.BlockFireTarget = nil
        return
    end
    if not kh then
        if CameraAssist.Lock then CameraAssist.ClearLock() end
        if next(CameraAssist.SavedPostFX) then CameraAssist.RestorePostFX() end
        CameraAssist.LockedTargetWorldPos = nil CameraAssist.AimState = nil
        CameraAssist.AimStateChar = nil CameraAssist.BlockFireTarget = nil
        return
    end
    if Configuration.CameraAssistFOVPriority and CameraAssist.Lock and not inAir and not Configuration.SilentAimEnabled then
        local cl = CameraAssist.FindCloserTarget(CameraAssist.Lock)
        if cl then
            CameraAssist.Lock = cl
            CameraAssist.AimState = nil CameraAssist.AimStateChar = nil
            CameraAssist.LastLockSwitchTime = tick()
            CameraAssist.UpdateLock(cl)
        end
    end
    if CameraAssist.Lock then
        local lk = CameraAssist.Lock
        local v = CameraAssist.UpdateLock(lk)
        if not v then CameraAssist.ClearLock()
        else
            local st = CameraAssist.IsTargetSticky(lk)
            local oc = false
            if Configuration.CameraAssistVisibleCheck and lk.Visible == false then oc = true end
            if st and not oc then lk.MissFrames = 0
            else
                if inAir then lk.MissFrames = 0 lk.Visible = true
                else
                    CameraAssist.DesiredLook = nil
                    lk.MissFrames = (lk.MissFrames or 0) + 1
                    local base_grace = CameraAssist.MissGrace
                    if (Configuration.CameraAssistSmoothing or 8) <= 4 then base_grace = base_grace + 6 end
                    if lk.MissFrames > (oc and 4 or base_grace) then CameraAssist.ClearLock() end
                end
            end
        end
    end
    if not CameraAssist.Lock then
        local nl = CameraAssist.AcquireLock()
        if nl then
            CameraAssist.Lock = nl
            CameraAssist.LastLockUserId = nl.UserId
            CameraAssist.AimState = nil CameraAssist.AimStateChar = nil
            CameraAssist.LastLockSwitchTime = tick()
            CameraAssist.MutePostFX()
            CameraAssist.UpdateLock(nl)
        end
        if not CameraAssist.Lock then
            CameraAssist.DesiredLook = nil CameraAssist.LastWrittenCF = nil
            CameraAssist.LockedTargetWorldPos = nil CameraAssist.AimState = nil
            CameraAssist.AimStateChar = nil CameraAssist.BlockFireTarget = nil
            if next(CameraAssist.SavedPostFX) then CameraAssist.RestorePostFX() end
            return
        end
    end
    local lk = CameraAssist.Lock
    if not lk or not lk.LastPos then return end
    local c = lk.Character
    if not c or not c.Parent then
        CameraAssist.ClearLock() CameraAssist.BlockFireTarget = nil
        return
    end
    CameraAssist.BlockFireTarget = lk.Player
    if lk.LastPos then CameraAssist.LockedTargetWorldPos = lk.LastPos end
    local ccf = cam.CFrame
    local cp = ccf.Position
    if not Utility.IsValidVector(cp) then return end
    local baseLook = ccf.LookVector
    if not Utility.IsValidVector(baseLook) or baseLook.Magnitude < 1e-4 then baseLook = Vector3.new(0, 0, -1) end
    baseLook = baseLook.Unit
    if not CameraAssist.AimState or CameraAssist.AimStateChar ~= c then
        CameraAssist.AimState = clampPitch(baseLook)
        CameraAssist.AimStateChar = c
    end
    local useMouse = Configuration.CameraAssistUseMouseWhileLocking == true
        and (Configuration.CameraAssistSmoothing or 8) > 3
    if useMouse and (mdX ~= 0 or mdY ~= 0) then
        baseLook = applyMouseDelta(baseLook, -mdX * 0.15, -mdY * 0.15)
    end
    local now = tick()
    if not IS_LOW_UNC and now - (CameraAssist.LastPingUpdate or 0) > 3.0 then
        CameraAssist.LastPingUpdate = now
        pcall(function()
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
            if ping and ping > 0 then CameraAssist.PingEstimate = math.clamp(ping / 1000, 0.02, 0.20) end
        end)
    end
    local tp = lk.LastPos
    local ts = 0
    local tv = nil
    local rt = c:FindFirstChild("HumanoidRootPart")
    if rt then
        pcall(function() tv = rt.AssemblyLinearVelocity end)
        if not tv then pcall(function() tv = rt.Velocity end) end
        if tv and Utility.IsValidVector(tv) then ts = tv.Magnitude end
        if ts < 0.5 then
            local cpos = rt.Position
            if CameraAssist.LastTargetPos and CameraAssist.LastTargetPosTime > 0 then
                local ddt = now - CameraAssist.LastTargetPosTime
                if ddt > 0.001 and ddt < 0.5 then
                    local diff = (cpos - CameraAssist.LastTargetPos) / ddt
                    if Utility.IsValidVector(diff) then tv = diff ts = diff.Magnitude end
                end
            end
            CameraAssist.LastTargetPos = cpos CameraAssist.LastTargetPosTime = now
        else
            CameraAssist.LastTargetPos = rt.Position CameraAssist.LastTargetPosTime = now
        end
    end
    local predEnabled = Configuration.CameraAssistPrediction and (Configuration.CameraAssistSmoothing or 8) > 3
    if predEnabled and tv and ts > 4 then
        local dist = (tp - cp).Magnitude
        local bs = math.max(Configuration.CameraAssistBulletSpeed or 400, 50)
        local ow = math.clamp(CameraAssist.PingEstimate or 0.06, 0, 0.15) * 0.5
        local ul = math.max(Configuration.CameraAssistLead or 0.02, 0)
        local tr = math.min(dist / bs + ul + ow, 0.25)
        local pr = Vector3.new(tv.X, 0, tv.Z) * tr
        local mo = math.min(2.0, dist * 0.25)
        if pr.Magnitude > mo then pr = pr.Unit * mo end
        tp = tp + pr
    end
    local td = tp - cp
    local tdist = td.Magnitude
    if tdist < 0.01 then return end
    td = td.Unit
    local es = Configuration.CameraAssistSmoothing or 0
    if scoped then es = es / math.max(Configuration.CameraAssistScopeSpeed or 1.0, 0.1) end
    local source = useMouse and baseLook or (CameraAssist.AimState or baseLook)
    local ad = math.deg(math.acos(math.clamp(source:Dot(td), -1, 1)))
    local bd = AIM_DEAD_ZONE
    if lk.ResolvedHitbox == "Head" then bd = bd * 0.30 end
    local sv = Configuration.CameraAssistSmoothing or 8
    if sv <= 4 then bd = bd * 0.25 elseif sv <= 8 then bd = bd * 0.55 end
    local dzDist = 1 / (1 + tdist / 150)
    if Configuration.SilentAimTightDeadzone then dzDist = dzDist * 0.55 end
    local dz = bd * (1 + math.clamp(tdist / 500, 0, 1) * 0.4) * dzDist
    if dz < 0.015 then dz = 0.015 end
    local skip = Configuration.CameraAssistVisibleCheck and lk.Visible == false and not inAir
    local finalAim
    if skip or ad < dz then finalAim = source
    else
        local base = smoothingToFactor(es, dt) * (Configuration.CameraAssistMouseSensitivity or 1) * 2.2
        local boost = 1 + math.clamp(tdist / 200, 0, 1) * (Configuration.SilentAimDistanceBoost or 1.0) * 0.9
        base = base * boost
        if Configuration.SilentAimConvergenceSnap then
            local near = math.max(dz * 2.0, 1.5)
            if ad < near then base = 1 end
        end
        local lockAge = tick() - (lk.FirstLockTime or 0)
        if tdist > 150 and lockAge < 0.35 and base < 0.75 then base = 0.75 end
        local f = math.clamp(base, 0, 1)
        CameraAssist.LastFactor = f CameraAssist.LastEffSmoothing = es
        if f >= 1 then finalAim = td
        else
            local lp2 = source:Lerp(td, f)
            finalAim = (lp2.Magnitude > 1e-4) and lp2.Unit or td
        end
    end
    CameraAssist.AimState = clampPitch(finalAim)
    if skip then
        CameraAssist.DesiredLook = nil CameraAssist.LastWrittenCF = nil
        return
    end
    local fl = CameraAssist.AimState
    if not fl or fl.Magnitude < 1e-4 then return end
    fl = clampPitch(fl.Unit)
    CameraAssist.DesiredLook = fl
    if Configuration.CameraAssistRotateChar and not air then
        local my = mc:FindFirstChild("HumanoidRootPart")
        local hum = mc:FindFirstChildOfClass("Humanoid")
        if my and hum then
            local flat = Vector3.new(fl.X, 0, fl.Z)
            if flat.Magnitude > 0.001 then
                flat = flat.Unit
                local ty = math.atan2(-flat.X, -flat.Z)
                pcall(function()
                    if CameraAssist.SavedAutoRotate == nil then
                        CameraAssist.SavedAutoRotate = hum.AutoRotate
                    end
                    local isMoving = hum.MoveDirection.Magnitude > 0.1
                    if isMoving then
                        hum.AutoRotate = true
                    else
                        hum.AutoRotate = false
                        local g = my:FindFirstChild("VEIL_AimGyro")
                        if g then g:Destroy() end
                        local curYaw = math.atan2(-my.CFrame.LookVector.X, -my.CFrame.LookVector.Z)
                        local dy = math.atan2(math.sin(ty - curYaw), math.cos(ty - curYaw))
                        local sm = Configuration.CameraAssistSmoothing or 8
                        local maxStep
                        if sm <= 1 then maxStep = math.rad(180)
                        elseif sm <= 3 then maxStep = math.rad(90)
                        elseif sm <= 7 then maxStep = math.rad(45)
                        elseif sm <= 12 then maxStep = math.rad(25)
                        else maxStep = math.rad(15) end
                        dy = math.clamp(dy, -maxStep, maxStep)
                        local newYaw = curYaw + dy
                        my.CFrame = CFrame.new(my.Position.X, my.Position.Y, my.Position.Z) * CFrame.Angles(0, newYaw, 0)
                    end
                    local head = mc:FindFirstChild("Head")
                    local neck = head and head:FindFirstChild("Neck")
                    if not neck then
                        local ut = mc:FindFirstChild("UpperTorso")
                        if ut then neck = ut:FindFirstChild("Neck") end
                    end
                    if neck then
                        if CameraAssist._neckJoint ~= neck then
                            CameraAssist._neckJoint = neck
                            CameraAssist._neckC0 = neck.C0
                        end
                        if CameraAssist._neckC0 then
                            local pitch = math.asin(math.clamp(fl.Y, -1, 1))
                            neck.C0 = CameraAssist._neckC0 * CFrame.Angles(-pitch, 0, 0)
                        end
                    end
                end)
            end
        end
    else
        pcall(function()
            local my = mc:FindFirstChild("HumanoidRootPart")
            local hum = mc:FindFirstChildOfClass("Humanoid")
            if my then
                local g = my:FindFirstChild("VEIL_AimGyro")
                if g then g:Destroy() end
            end
            if hum and CameraAssist.SavedAutoRotate ~= nil then
                hum.AutoRotate = CameraAssist.SavedAutoRotate
                CameraAssist.SavedAutoRotate = nil
            end
        end)
    end
    local ncf
    local ok, res = pcall(function() return CFrame.lookAt(cp, cp + fl, Vector3.new(0, 1, 0)) end)
    if ok and res then ncf = res else ncf = CFrame.new(cp, cp + fl) end
    CameraAssist.LastWrittenCF = ncf
    CameraAssist._lastCamWrite = tick()
    if not IS_LOW_UNC then
        pcall(function() cam.CFrame = ncf end)
        if CamControls and CamControls.SetRotation then
            pcall(function() CamControls:SetRotation(ncf) end)
        end
    else
        CameraAssist._pendingNCF = ncf
    end
end
function CameraAssist.Bind()
    if CameraAssist.Bound then return end
    CameraAssist.Bound = true
    pcall(function() RunService:UnbindFromRenderStep(CameraAssist.BindName) end)
    pcall(function()
        RunService:BindToRenderStep(CameraAssist.BindName, Enum.RenderPriority.Camera.Value + 10000, function(dt)
            if CameraAssist.ShuttingDown then return end
            pcall(function() CameraAssist.Apply(dt) end)
        end)
    end)
    if IS_LOW_UNC and not CameraAssist._preRenderConn then
        pcall(function()
            CameraAssist._preRenderConn = RunService.PreRender:Connect(function()
                if CameraAssist.ShuttingDown then return end
                if not CameraAssist.Lock then return end
                if not CameraAssist.DesiredLook then return end
                local cam = Workspace.CurrentCamera
                if not cam or not cam.Parent then return end
                local pos = cam.CFrame.Position
                if not Utility.IsValidVector(pos) then return end
                local ok, cf = pcall(function() return CFrame.lookAt(pos, pos + CameraAssist.DesiredLook, Vector3.new(0, 1, 0)) end)
                if not ok or not cf then return end
                CameraAssist.LastWrittenCF = cf
                CameraAssist._lastCamWrite = tick()
                pcall(function() cam.CFrame = cf end)
            end)
        end)
    end
    CameraAssist.AttachCamWatcher()
    CameraAssist.AttachCameraSwapHook()
    _G.__VEIL_last_bind = CameraAssist.BindName
end
function CameraAssist.Unbind()
    if not CameraAssist.Bound then return end
    CameraAssist.Bound = false
    pcall(function() RunService:UnbindFromRenderStep(CameraAssist.BindName) end)
    if CameraAssist.CamSignalConn then pcall(function() CameraAssist.CamSignalConn:Disconnect() end) CameraAssist.CamSignalConn = nil end
    if CameraAssist.CamSwapConn then pcall(function() CameraAssist.CamSwapConn:Disconnect() end) CameraAssist.CamSwapConn = nil end
    if CameraAssist._preRenderConn then
        pcall(function() CameraAssist._preRenderConn:Disconnect() end)
        CameraAssist._preRenderConn = nil
    end
end
_G.__VEIL_CameraAssist = CameraAssist

local function weaponWatcher()
    task.spawn(function()
        while true do
            task.wait(0.75)
            if CameraAssist.ShuttingDown then return end
            if Configuration.WeaponProfilesEnabled and Configuration.WeaponAutoDetect then
                local cat, raw = detectWeapon()
                if cat ~= ActiveWeaponName then
                    saveActiveProfile()
                    ActiveWeaponName = cat
                    applyProfile(cat)
                    if _G.__VEIL_WeaponChanged then pcall(_G.__VEIL_WeaponChanged, cat, raw) end
                end
            end
        end
    end)
end
weaponWatcher()

-- ============================================================
-- AutoFire
-- ============================================================
local AutoFire = {}
AutoFire.LastFireTime = 0 AutoFire.IsFiring = false AutoFire.FireStart = 0
AutoFire.KeyHeld = false
function AutoFire.RaycastCheck()
    if Configuration.LobbyGuardEnabled and not Utility.IsInGame() then return nil end
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local lp = Players.LocalPlayer
    if not lp or not lp.Character then return nil end
    local hp, hpos, hm = Utility.CameraRaycast(Configuration.AutoFireMaxDistance or 1000)
    if hp and hm then
        local p = Players:GetPlayerFromCharacter(hm)
        if p and p ~= lp and Utility.IsEnemy(lp, p) then
            local h = hm:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 and Utility.IsTargetablePart(hp) then return p, hp.Name, hpos end
        end
    end
    if Configuration.AutoFireProximityFallback ~= false then
        local cp = cam.CFrame.Position
        local lk = cam.CFrame.LookVector
        local md = Configuration.AutoFireMaxDistance or 1000
        local at = math.rad(Configuration.AutoFireProximityAngle or 2.5)
        local bp2, bpart, bpos, bs = nil, nil, nil, math.huge
        local sm = Configuration.CameraAssistHitboxMode or "Head"
        if sm == "Random" then sm = Utility.ResolveHitboxMode("Random") end
        for _, pd in ipairs(Utility.GetValidPlayers()) do
            local c = pd.Character
            if c and c.Parent then
                local pos, part = Utility.GetHitboxPosition(c, sm)
                if pos then
                    local dl = pos - cp
                    local dist = dl.Magnitude
                    if dist > 0.5 and dist <= md then
                        local dot = lk:Dot(dl / dist)
                        if dot > 0 then
                            local ang = math.acos(math.clamp(dot, -1, 1))
                            local ha = math.max(at, math.atan(0.7 / dist))
                            if ang <= ha then
                                local sc2 = ang / ha + dist / md * 0.05
                                if sc2 < bs then bs = sc2 bp2 = pd.Player bpart = part and part.Name or sm bpos = pos end
                            end
                        end
                    end
                end
            end
        end
        if bp2 then return bp2, bpart, bpos end
    end
    return nil
end
function AutoFire.ShouldFire()
    if not Configuration.AutoFireEnabled then return false, nil end
    if not Configuration.AutoFireAlwaysOn and not AutoFire.KeyHeld then return false, nil end
    if Configuration.LobbyGuardEnabled and not Utility.IsInGame() then return false, nil end
    local cam = Workspace.CurrentCamera
    if not cam or not cam.Parent then return false, nil end
    if tick() - AutoFire.LastFireTime < Configuration.AutoFireDelay then return false, nil end
    if CameraAssist.LastInputWasController and not CameraAssist.ControllerFireHeld then return false, nil end
    if tick() < (CameraAssist._deflectCooldownUntil or 0) then return false, nil end
    local p, pn, hp = AutoFire.RaycastCheck()
    if p then return true, {player=p, part=pn, position=hp} end
    return false, nil
end
function AutoFire.FireOnce()
    if ExecutorInfo.HasMouse1Click then
        local ok = pcall(mouse1click)
        if ok then return true end
    end
    if ExecutorInfo.HasMouse1Press then
        local ok = pcall(function() mouse1press() task.wait(0.02) mouse1release() end)
        if ok then return true end
    end
    if ExecutorInfo.HasVIM then
        local cam = Workspace.CurrentCamera
        local vp = (cam and cam.ViewportSize) or Vector2.new(1920, 1080)
        local ok = pcall(function()
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(math.floor(vp.X * 0.5), math.floor(vp.Y * 0.5), 0, true, game, 0)
            task.wait(0.02)
            vim:SendMouseButtonEvent(math.floor(vp.X * 0.5), math.floor(vp.Y * 0.5), 0, false, game, 0)
        end)
        if ok then return true end
    end
    if ExecutorInfo.HasKeyPress then
        local ok = pcall(function() keypress(0x01) task.wait(0.02) keyrelease(0x01) end)
        if ok then return true end
    end
    return false
end
function AutoFire.Execute(fd)
    if not fd then return end
    if AutoFire.IsFiring then
        if tick() - AutoFire.FireStart > 0.5 then AutoFire.IsFiring = false else return end
    end
    local p = fd.player
    if not p or not p.Parent then return end
    local c = p.Character
    if not c or not c.Parent then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return end
    AutoFire.IsFiring = true AutoFire.FireStart = tick()
    AutoFire.FireOnce()
    AutoFire.LastFireTime = tick()
    AutoFire.IsFiring = false
end
function AutoFire.CheckAndFire()
    local s, d = AutoFire.ShouldFire()
    if s then AutoFire.Execute(d) end
end

-- ============================================================
-- Watermark
-- ============================================================
local WatermarkControl = {Gui = nil}
local function makeWatermark()
    if WatermarkControl.Gui and WatermarkControl.Gui.Parent then
        WatermarkControl.Gui.Enabled = Configuration.WatermarkEnabled ~= false
        return
    end
    local par = safeGuiParent()
    if not par then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "VEIL_Watermark" sg.ResetOnSpawn = false sg.IgnoreGuiInset = true sg.DisplayOrder = 90
    pcall(function() sg.AutoLocalize = false end)
    sg.Parent = par
    local ct = Instance.new("Frame")
    ct.AnchorPoint = Vector2.new(0, 1) ct.Position = UDim2.new(0, 14, 1, -14)
    ct.Size = UDim2.fromOffset(180, 26) ct.BackgroundTransparency = 1 ct.Parent = sg
    local dt = Instance.new("Frame")
    dt.AnchorPoint = Vector2.new(0, 0.5) dt.Position = UDim2.new(0, 0, 0.5, 0)
    dt.Size = UDim2.fromOffset(6, 6) dt.BackgroundColor3 = Color3.fromRGB(139, 92, 246)
    dt.BorderSizePixel = 0 dt.Parent = ct
    local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(0.5, 0) dc.Parent = dt
    local wm = Instance.new("TextLabel")
    wm.AnchorPoint = Vector2.new(0, 0.5) wm.Position = UDim2.new(0, 12, 0.5, 0)
    wm.Size = UDim2.fromOffset(150, 20) wm.BackgroundTransparency = 1
    wm.Text = "VEIL" wm.TextColor3 = Color3.fromRGB(245, 243, 255)
    wm.Font = Enum.Font.GothamBlack wm.TextSize = 15
    wm.TextXAlignment = Enum.TextXAlignment.Left wm.TextYAlignment = Enum.TextYAlignment.Center
    wm.TextStrokeTransparency = 0.6 wm.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) wm.Parent = ct
    local gr = Instance.new("UIGradient")
    gr.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(245, 243, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(99, 102, 241)) })
    gr.Parent = wm
    WatermarkControl.Gui = sg
    sg.Enabled = Configuration.WatermarkEnabled ~= false
end
local function setWatermarkEnabled(on)
    Configuration.WatermarkEnabled = on and true or false
    if WatermarkControl.Gui then WatermarkControl.Gui.Enabled = Configuration.WatermarkEnabled
    else makeWatermark() end
end

-- ============================================================
-- Startup animation
-- ============================================================
local function showStartup(onReveal)
    local par = safeGuiParent()
    if not par then if onReveal then pcall(onReveal) end return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "VEIL_Startup" sg.ResetOnSpawn = false sg.IgnoreGuiInset = true sg.DisplayOrder = 9999
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local okP = pcall(function() sg.Parent = par end)
    if not okP or not sg.Parent then
        pcall(function() sg.Parent = game:GetService("CoreGui") end)
    end
    if not sg.Parent then if onReveal then pcall(onReveal) end return end

    local dead = false
    local pc = Instance.new("Frame")
    pc.Size = UDim2.fromScale(1, 1) pc.BackgroundTransparency = 1 pc.ZIndex = 5 pc.Parent = sg

    local function kill()
        if dead then return end
        dead = true
        pcall(function()
            for _, ch in ipairs(pc:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
        end)
        pcall(function() sg:Destroy() end)
    end
    task.delay(10, kill)

    local bd = Instance.new("Frame")
    bd.Size = UDim2.fromScale(1, 1) bd.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bd.BorderSizePixel = 0 bd.ZIndex = 1 bd.Parent = sg

    local halo = Instance.new("Frame")
    halo.AnchorPoint = Vector2.new(0.5, 0.5) halo.Position = UDim2.fromScale(0.5, 0.42)
    halo.Size = UDim2.fromOffset(900, 900)
    halo.BackgroundColor3 = Color3.fromRGB(110, 50, 220)
    halo.BackgroundTransparency = 0.86
    halo.BorderSizePixel = 0 halo.ZIndex = 2 halo.Parent = sg
    local hc = Instance.new("UICorner") hc.CornerRadius = UDim.new(1, 0) hc.Parent = halo

    local function spawnParticle()
        if dead then return end
        local sz = math.random(2, 5)
        local sx = math.random(10, 90) / 100
        local sy = 1.1 + math.random() * 0.15
        local dx = sx + (math.random() - 0.5) * 0.15
        local ey = -0.15 - math.random() * 0.08
        local dr = 4 + math.random() * 2.5
        local p = Instance.new("Frame")
        p.AnchorPoint = Vector2.new(0.5, 0.5) p.Position = UDim2.fromScale(sx, sy)
        p.Size = UDim2.fromOffset(sz, sz) p.BackgroundColor3 = Color3.fromRGB(200, 160, 255)
        p.BackgroundTransparency = 1 p.BorderSizePixel = 0 p.ZIndex = 6 p.Parent = pc
        TweenService:Create(p, TweenInfo.new(0.5), {BackgroundTransparency = 0.4}):Play()
        TweenService:Create(p, TweenInfo.new(dr, Enum.EasingStyle.Linear), {Position = UDim2.fromScale(dx, ey)}):Play()
        task.delay(dr - 0.8, function()
            if p.Parent then TweenService:Create(p, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play() end
        end)
        task.delay(dr + 0.1, function() if p.Parent then p:Destroy() end end)
    end

    local lh = Instance.new("Frame")
    lh.Name = "VHolder"
    lh.AnchorPoint = Vector2.new(0.5, 0.5)
    lh.Position = UDim2.fromScale(0.5, 0.30)
    lh.Size = UDim2.fromOffset(900, 900)
    lh.BackgroundTransparency = 1 lh.ZIndex = 30 lh.Parent = sg

    local shadow = Instance.new("TextLabel")
    shadow.Size = UDim2.fromScale(1, 1)
    shadow.Position = UDim2.fromOffset(10, 12)
    shadow.BackgroundTransparency = 1
    shadow.Font = Enum.Font.GothamBlack shadow.Text = "V" shadow.TextSize = 700
    shadow.TextColor3 = Color3.fromRGB(40, 15, 90) shadow.TextTransparency = 0.4
    shadow.TextXAlignment = Enum.TextXAlignment.Center shadow.TextYAlignment = Enum.TextYAlignment.Center
    shadow.ZIndex = 30 shadow.Parent = lh

    local vm = Instance.new("TextLabel")
    vm.Size = UDim2.fromScale(1, 1) vm.BackgroundTransparency = 1
    vm.Font = Enum.Font.GothamBlack vm.Text = "V" vm.TextSize = 700
    vm.TextColor3 = Color3.fromRGB(255, 255, 255)
    vm.TextXAlignment = Enum.TextXAlignment.Center vm.TextYAlignment = Enum.TextYAlignment.Center
    vm.ZIndex = 31 vm.Parent = lh

    local vg = Instance.new("UIGradient")
    vg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 205, 255)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(160, 100, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 130, 245)),
    }
    vg.Rotation = 90 vg.Parent = vm

    local vs = Instance.new("UIStroke")
    vs.Color = Color3.fromRGB(210, 160, 255) vs.Thickness = 4 vs.Transparency = 0.15 vs.Parent = vm

    local title = Instance.new("TextLabel")
    title.AnchorPoint = Vector2.new(0.5, 0.5) title.Position = UDim2.fromScale(0.5, 0.70)
    title.Size = UDim2.fromOffset(600, 60) title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack title.Text = "VEIL" title.TextSize = 58
    title.TextColor3 = Color3.fromRGB(255, 255, 255) title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 32 title.Parent = sg
    local tg = Instance.new("UIGradient")
    tg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 210, 255)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(180, 130, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 160, 255)),
    }
    tg.Parent = title
    local ts2 = Instance.new("UIStroke")
    ts2.Color = Color3.fromRGB(170, 120, 255) ts2.Thickness = 1.5 ts2.Transparency = 0.4 ts2.Parent = title
    title.TextTransparency = 1 ts2.Transparency = 1

    local sub = Instance.new("TextLabel")
    sub.AnchorPoint = Vector2.new(0.5, 0.5) sub.Position = UDim2.fromScale(0.5, 0.765)
    sub.Size = UDim2.fromOffset(600, 20) sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.GothamBold sub.Text = "S E C U R I T Y   S U I T E"
    sub.TextSize = 12 sub.TextColor3 = Color3.fromRGB(180, 145, 255)
    sub.TextXAlignment = Enum.TextXAlignment.Center sub.TextTransparency = 1 sub.ZIndex = 32 sub.Parent = sg

    local hint = Instance.new("TextLabel")
    hint.AnchorPoint = Vector2.new(0.5, 0.5) hint.Position = UDim2.fromScale(0.5, 0.80)
    hint.Size = UDim2.fromOffset(600, 16) hint.BackgroundTransparency = 1
    hint.Font = Enum.Font.GothamMedium hint.Text = "Right Shift To Open Menu"
    hint.TextSize = 11 hint.TextColor3 = Color3.fromRGB(200, 170, 255)
    hint.TextXAlignment = Enum.TextXAlignment.Center hint.TextTransparency = 1 hint.ZIndex = 32 hint.Parent = sg

    local bg = Instance.new("Frame")
    bg.AnchorPoint = Vector2.new(0.5, 0.5) bg.Position = UDim2.fromScale(0.5, 0.88)
    bg.Size = UDim2.fromOffset(340, 12) bg.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
    bg.BackgroundTransparency = 0.85 bg.BorderSizePixel = 0 bg.ZIndex = 31 bg.Parent = sg
    local bgc = Instance.new("UICorner") bgc.CornerRadius = UDim.new(1, 0) bgc.Parent = bg

    local bt = Instance.new("Frame")
    bt.AnchorPoint = Vector2.new(0.5, 0.5) bt.Position = UDim2.fromScale(0.5, 0.88)
    bt.Size = UDim2.fromOffset(300, 3) bt.BackgroundColor3 = Color3.fromRGB(40, 25, 70)
    bt.BorderSizePixel = 0 bt.ZIndex = 32 bt.Parent = sg
    local btc = Instance.new("UICorner") btc.CornerRadius = UDim.new(1, 0) btc.Parent = bt
    local bf = Instance.new("Frame")
    bf.Size = UDim2.new(0, 0, 1, 0) bf.BackgroundColor3 = Color3.fromRGB(180, 120, 255)
    bf.BorderSizePixel = 0 bf.ZIndex = 33 bf.Parent = bt
    local bfc = Instance.new("UICorner") bfc.CornerRadius = UDim.new(1, 0) bfc.Parent = bf
    local bfg = Instance.new("UIGradient")
    bfg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 80, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(230, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 200, 255)),
    }
    bfg.Parent = bf

    task.spawn(function()
        while not dead do
            spawnParticle()
            task.wait(0.12 + math.random() * 0.06)
        end
    end)

    task.spawn(function()
        pcall(function()
            TweenService:Create(vm, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize = 850}):Play()
            TweenService:Create(shadow, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize = 850}):Play()
            task.wait(0.35)
            TweenService:Create(title, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
            TweenService:Create(ts2, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Transparency = 0.4}):Play()
            task.wait(0.22)
            TweenService:Create(sub, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0.1}):Play()
            TweenService:Create(hint, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0.2}):Play()

            local barDur = 2.8
            TweenService:Create(bf, TweenInfo.new(barDur, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
            TweenService:Create(bg, TweenInfo.new(barDur, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(344, 5), BackgroundTransparency = 0.9}):Play()

            task.wait(barDur + 0.25)
            if onReveal then pcall(onReveal) end
            dead = true

            for _, p in ipairs(pc:GetChildren()) do
                if p:IsA("Frame") then
                    TweenService:Create(p, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
                end
            end

            TweenService:Create(vm, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextSize = 980, TextTransparency = 0.5}):Play()
            TweenService:Create(shadow, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextSize = 980, TextTransparency = 1}):Play()

            task.delay(0.08, function()
                TweenService:Create(title, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
                TweenService:Create(ts2, TweenInfo.new(0.4), {Transparency = 1}):Play()
                TweenService:Create(sub, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
                TweenService:Create(hint, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
                TweenService:Create(vm, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                TweenService:Create(vs, TweenInfo.new(0.5), {Transparency = 1}):Play()
                TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
                TweenService:Create(bf, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
                TweenService:Create(bt, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            end)

            TweenService:Create(halo, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                BackgroundTransparency = 1, Size = UDim2.fromOffset(400, 400),
            }):Play()

            task.wait(0.55)
            TweenService:Create(bd, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
            task.wait(0.7)
        end)
        pcall(kill)
    end)
end
_G.__VEIL_ShowStartup = function() pcall(showStartup) end

-- ============================================================
-- Discord popup
-- ============================================================
local function makeDiscordPopup()
    local par = safeGuiParent()
    if not par then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "VEIL_Discord" sg.ResetOnSpawn = false sg.IgnoreGuiInset = true sg.DisplayOrder = 95 sg.Parent = par
    local msgText = "Join our discord for updates. Bug reports go in the same server."
    local PAD = 14
    local MSG_W = 340 - PAD * 2
    local msgH = measureText(msgText, Enum.Font.Gotham, 11, MSG_W)
    msgH = math.max(msgH, 14)
    local msgTop = 36
    local btnH = 22
    local bottomPad = 14
    local boxH = msgTop + msgH + 8 + btnH + bottomPad
    local box = Instance.new("Frame")
    box.AnchorPoint = Vector2.new(0, 1) box.Position = UDim2.new(0, 14, 1, -50)
    box.Size = UDim2.fromOffset(340, boxH) box.BackgroundColor3 = Color3.fromRGB(22, 20, 34)
    box.BackgroundTransparency = 0.05 box.BorderSizePixel = 0 box.Parent = sg
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 10) c.Parent = box
    local st = Instance.new("UIStroke") st.Color = Color3.fromRGB(88, 101, 242) st.Thickness = 1.5 st.Transparency = 0.3 st.Parent = box
    local ti = Instance.new("TextLabel")
    ti.Size = UDim2.new(1, -80, 0, 22) ti.Position = UDim2.new(0, 14, 0, 10)
    ti.BackgroundTransparency = 1 ti.Font = Enum.Font.GothamBold ti.TextSize = 12
    ti.TextColor3 = Color3.fromRGB(180, 170, 255) ti.TextXAlignment = Enum.TextXAlignment.Left
    ti.Text = "VEIL - Community" ti.Parent = box
    local cb = Instance.new("TextButton")
    cb.Size = UDim2.fromOffset(22, 22) cb.Position = UDim2.new(1, -32, 0, 10)
    cb.BackgroundColor3 = Color3.fromRGB(40, 30, 60) cb.BorderSizePixel = 0
    cb.Font = Enum.Font.GothamBold cb.TextSize = 14 cb.TextColor3 = Color3.fromRGB(220, 210, 255)
    cb.Text = "x" cb.AutoButtonColor = false cb.Parent = box
    local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0, 5) cc.Parent = cb
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -PAD * 2, 0, msgH) msg.Position = UDim2.new(0, PAD, 0, msgTop)
    msg.BackgroundTransparency = 1 msg.Font = Enum.Font.Gotham msg.TextSize = 11
    msg.TextColor3 = Color3.fromRGB(220, 215, 235) msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextYAlignment = Enum.TextYAlignment.Top msg.TextWrapped = true
    msg.Text = msgText msg.Parent = box
    local lb = Instance.new("TextButton")
    lb.Size = UDim2.new(1, -PAD * 2, 0, btnH) lb.Position = UDim2.new(0, PAD, 1, -(btnH + bottomPad))
    lb.BackgroundColor3 = Color3.fromRGB(88, 101, 242) lb.BorderSizePixel = 0
    lb.Font = Enum.Font.GothamBold lb.TextSize = 11 lb.TextColor3 = Color3.fromRGB(255, 255, 255)
    lb.Text = "discord.gg/K3vgcVsCsS - tap to copy" lb.AutoButtonColor = false lb.Parent = box
    local lc = Instance.new("UICorner") lc.CornerRadius = UDim.new(0, 6) lc.Parent = lb
    local DU = "https://discord.gg/K3vgcVsCsS"
    lb.MouseButton1Click:Connect(function()
        if type(setclipboard) == "function" then pcall(setclipboard, DU) lb.Text = "Copied"
        else lb.Text = "discord.gg/K3vgcVsCsS" end
        task.delay(1.5, function() if lb and lb.Parent then lb.Text = "discord.gg/K3vgcVsCsS - tap to copy" end end)
    end)
    cb.MouseButton1Click:Connect(function() pcall(function() sg:Destroy() end) end)
end

-- ============================================================
-- NightVision
-- ============================================================
local NightVision = {Active = false, Saved = nil, Effect = nil}
local function NVEnable()
    if NightVision.Active then return end
    NightVision.Active = true
    NightVision.Saved = { Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, Brightness = Lighting.Brightness, GlobalShadows = Lighting.GlobalShadows, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart }
    pcall(function()
        Lighting.Ambient = Color3.fromRGB(170, 175, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 185, 190)
        Lighting.Brightness = 3 Lighting.GlobalShadows = false
        Lighting.FogEnd = math.max(Lighting.FogEnd, 2000) Lighting.FogStart = math.max(Lighting.FogStart, 500)
    end)
    if NightVision.Effect and NightVision.Effect.Parent then NightVision.Effect:Destroy() end
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "VEIL_NightVision" cc.Brightness = 0.25 cc.Contrast = 0.1 cc.Saturation = 0.05
    cc.TintColor = Color3.fromRGB(210, 230, 210) cc.Parent = Lighting
    NightVision.Effect = cc
end
local function NVDisable()
    if not NightVision.Active then return end
    NightVision.Active = false
    if NightVision.Saved then
        for k, v in pairs(NightVision.Saved) do pcall(function() Lighting[k] = v end) end
        NightVision.Saved = nil
    end
    if NightVision.Effect and NightVision.Effect.Parent then NightVision.Effect:Destroy() end
    NightVision.Effect = nil
end
local function NVApply() if Configuration.NightVisionEnabled then NVEnable() else NVDisable() end end

-- ============================================================
-- Performance
-- ============================================================
local PerformanceTools = {}
PerformanceTools.Saved = {}
local EFFECT_CLASSES = {
    ParticleEmitter = true, Beam = true, Trail = true, Fire = true, Smoke = true, Sparkles = true,
    PointLight = true, SpotLight = true, SurfaceLight = true,
}
function PerformanceTools.EnableFPSBoost()
    PerformanceTools.Saved.Lighting = {
        GlobalShadows = Lighting.GlobalShadows, Brightness = Lighting.Brightness,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
    }
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.Brightness = math.max(Lighting.Brightness, 1)
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.FogEnd = 100000 Lighting.FogStart = 100000
    end)
    PerformanceTools.Saved.PostFX = {}
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("PostEffect") and e.Name ~= "VEIL_NightVision" then
            PerformanceTools.Saved.PostFX[e] = e.Enabled
            pcall(function() e.Enabled = false end)
        end
    end
    PerformanceTools.Saved.WorkspaceEffects = {}
    for _, d in ipairs(Workspace:GetDescendants()) do
        if EFFECT_CLASSES[d.ClassName] then
            local ok, en = pcall(function() return d.Enabled end)
            if ok then
                PerformanceTools.Saved.WorkspaceEffects[d] = en
                pcall(function() d.Enabled = false end)
            end
        end
    end
end
function PerformanceTools.DisableFPSBoost()
    local saved = PerformanceTools.Saved
    if saved.Lighting then
        for k, v in pairs(saved.Lighting) do pcall(function() Lighting[k] = v end) end
        saved.Lighting = nil
    end
    if saved.PostFX then
        for inst, state in pairs(saved.PostFX) do
            if inst and inst.Parent then pcall(function() inst.Enabled = state end) end
        end
        saved.PostFX = nil
    end
    if saved.WorkspaceEffects then
        for inst, state in pairs(saved.WorkspaceEffects) do
            if inst and inst.Parent then pcall(function() inst.Enabled = state end) end
        end
        saved.WorkspaceEffects = nil
    end
    PerformanceTools.Saved = {}
end

local FeatureState = {}
local function FeatureApply(id, snapshot, onChange)
    if not FeatureState[id] then FeatureState[id] = { wasOn = false, saved = {} } end
    local st = FeatureState[id]
    if snapshot.enabled and not st.wasOn then
        st.wasOn = true st.saved = {}
        for k, _ in pairs(snapshot.set) do st.saved[k] = Configuration[k] end
        for k, v in pairs(snapshot.set) do Configuration[k] = v end
        if onChange then pcall(onChange, true) end
    elseif not snapshot.enabled and st.wasOn then
        st.wasOn = false
        for k, v in pairs(st.saved) do Configuration[k] = v end
        st.saved = {}
        if onChange then pcall(onChange, false) end
    end
end

-- ============================================================
-- Presence
-- ============================================================
local Presence = { Namespace = "veil-7x9k3m-prod", BucketWindow = 300, LastBucket = nil }
local function presenceRequest(url)
    local body = nil
    task.spawn(function()
        local ok, res
        if type(request) == "function" then ok, res = pcall(request, { Url = url, Method = "GET" })
        elseif type(http_request) == "function" then ok, res = pcall(http_request, { Url = url, Method = "GET" })
        elseif type(syn) == "table" and type(syn.request) == "function" then ok, res = pcall(syn.request, { Url = url, Method = "GET" }) end
        if ok and res then body = res.Body or res.body end
    end)
    local waited = 0
    while body == nil and waited < 1 do task.wait(0.05) waited = waited + 0.05 end
    return body
end
local function presenceDecode(body)
    if not body or body == "" then return nil end
    local ok, decoded = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok or type(decoded) ~= "table" then return nil end
    return decoded.value
end
local function presenceHit(key)
    return presenceDecode(presenceRequest("https://abacus.jasoncameron.dev/hit/" .. Presence.Namespace .. "/" .. key))
end
function Presence.Tick()
    local bucket = math.floor(os.time() / Presence.BucketWindow)
    if Presence.LastBucket ~= bucket then
        Presence.LastBucket = bucket
        task.spawn(function() presenceHit("active_" .. bucket) end)
    end
end
function Presence.Register()
    task.delay(6, function()
        task.spawn(function() pcall(function() presenceHit("users_total") end) end)
        task.spawn(function() pcall(function() Presence.Tick() end) end)
    end)
    task.spawn(function()
        while not CameraAssist.ShuttingDown do task.wait(240) pcall(function() Presence.Tick() end) end
    end)
end
-- ============================================================
-- Interface
-- ============================================================
local Interface = {}
Interface.ScreenGui = nil Interface.MainFrame = nil
Interface.TabContents = {} Interface.TabButtons = {} Interface.CurrentTab = nil
local C = Palette
local T = TweenService
local function corner(g, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 8) c.Parent = g return c end
local function stroke(g, col, th, tr) local s = Instance.new("UIStroke") s.Color = col or C.Border s.Thickness = th or 1 s.Transparency = tr or 0 s.Parent = g return s end
local function CSe(parent, text)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, 0, 0, 24) s.BackgroundTransparency = 1 s.Parent = parent
    local b = Instance.new("Frame")
    b.Size = UDim2.new(0, 3, 0, 12) b.Position = UDim2.new(0, 0, 0.5, -6)
    b.BackgroundColor3 = C.Accent b.BorderSizePixel = 0 b.Parent = s
    corner(b, 2)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -14, 1, 0) l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1 l.Font = Enum.Font.GothamBold
    l.Text = tostring(text):upper() l.TextSize = 10 l.TextColor3 = C.Accent3
    l.TextXAlignment = Enum.TextXAlignment.Left l.Parent = s
    return s
end
local function CSeP(parent, text)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, 0, 0, 24) s.BackgroundTransparency = 1 s.Parent = parent
    local b = Instance.new("Frame")
    b.Size = UDim2.new(0, 3, 0, 12) b.Position = UDim2.new(0, 0, 0.5, -6)
    b.BackgroundColor3 = Color3.fromRGB(255, 200, 40) b.BorderSizePixel = 0 b.Parent = s
    corner(b, 2)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -14, 1, 0) l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1 l.Font = Enum.Font.GothamBold
    l.Text = "\226\152\133 " .. tostring(text):upper() l.TextSize = 10
    l.TextColor3 = Color3.fromRGB(255, 200, 40) l.TextXAlignment = Enum.TextXAlignment.Left l.Parent = s
    return s
end
local PNS = false
local LastPremShown = 0
local function showPrem(customTitle, customBody)
    local now = tick()
    if PNS or now - LastPremShown < 0.4 then return end
    LastPremShown = now PNS = true
    local par = safeGuiParent()
    if not par then PNS = false return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "VEIL_Premium" sg.ResetOnSpawn = false sg.IgnoreGuiInset = true sg.DisplayOrder = 97
    pcall(function() sg.Parent = par end)
    local headerText = customTitle or "PREMIUM REQUIRED"
    local bodyText = customBody or "This feature is reserved for VEIL Premium.\nUnlock it in our Discord."
    local STAR_TOP = 10
    local STAR_H = 54
    local STAR_GAP = 4
    local HEADER_H = 16
    local BODY_GAP = 6
    local CTA_TOP_GAP = 12
    local CTA_H = 26
    local BOTTOM_PAD = 14
    local PAD_X = 14
    local CARD_W = 380
    local INNER_W = CARD_W - PAD_X * 2
    local headerY = STAR_TOP + STAR_H + STAR_GAP
    local bodyY = headerY + HEADER_H + BODY_GAP
    local bodyH = math.max(measureText(bodyText, Enum.Font.Gotham, 11, INNER_W), 16)
    local cardH = bodyY + bodyH + CTA_TOP_GAP + CTA_H + BOTTOM_PAD
    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0) card.Position = UDim2.new(0.5, 0, 0, -100)
    card.Size = UDim2.fromOffset(CARD_W, cardH) card.BackgroundColor3 = Color3.fromRGB(18, 14, 8)
    card.BackgroundTransparency = 1 card.BorderSizePixel = 0 card.Parent = sg
    corner(card, 14)
    local cardSt = Instance.new("UIStroke")
    cardSt.Color = Color3.fromRGB(255, 200, 40) cardSt.Thickness = 1.5 cardSt.Transparency = 0.15 cardSt.Parent = card
    local cardScale = Instance.new("UIScale") cardScale.Scale = 0.7 cardScale.Parent = card
    local starHolder = Instance.new("Frame")
    starHolder.Size = UDim2.fromOffset(STAR_H, STAR_H)
    starHolder.AnchorPoint = Vector2.new(0.5, 0)
    starHolder.Position = UDim2.new(0.5, 0, 0, STAR_TOP)
    starHolder.BackgroundTransparency = 1 starHolder.Parent = card
    local star = Instance.new("TextLabel")
    star.Size = UDim2.fromScale(1, 1) star.BackgroundTransparency = 1
    star.Font = Enum.Font.GothamBlack star.Text = "\226\152\133"
    star.TextSize = 38 star.TextColor3 = Color3.fromRGB(255, 215, 60)
    star.TextXAlignment = Enum.TextXAlignment.Center star.TextYAlignment = Enum.TextYAlignment.Center
    star.Parent = starHolder
    local starGrad = Instance.new("UIGradient")
    starGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 245, 180)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 215, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(215, 150, 20)),
    }
    starGrad.Rotation = 45 starGrad.Parent = star
    local starStroke = Instance.new("UIStroke")
    starStroke.Color = Color3.fromRGB(255, 240, 150) starStroke.Thickness = 2 starStroke.Transparency = 0.3 starStroke.Parent = star
    task.spawn(function()
        local rot = 0
        while star.Parent and starHolder.Parent do
            TweenService:Create(star, TweenInfo.new(3.4, Enum.EasingStyle.Linear), {Rotation = rot + 360}):Play()
            task.wait(3.4)
            rot = (rot + 360) % 360
            pcall(function() star.Rotation = rot end)
        end
    end)
    task.spawn(function()
        while starStroke.Parent do
            TweenService:Create(starStroke, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.75, Thickness = 4}):Play()
            task.wait(0.85)
            TweenService:Create(starStroke, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.25, Thickness = 2}):Play()
            task.wait(0.85)
        end
    end)
    task.spawn(function()
        while starHolder.Parent do
            TweenService:Create(star, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 44}):Play()
            task.wait(1.4)
            TweenService:Create(star, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 36}):Play()
            task.wait(1.4)
        end
    end)
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -PAD_X * 2, 0, HEADER_H)
    header.Position = UDim2.new(0, PAD_X, 0, headerY)
    header.BackgroundTransparency = 1 header.Font = Enum.Font.GothamBlack
    header.Text = headerText header.TextSize = 12
    header.TextColor3 = Color3.fromRGB(255, 210, 70)
    header.TextXAlignment = Enum.TextXAlignment.Center header.Parent = card
    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1, -PAD_X * 2, 0, bodyH)
    body.Position = UDim2.new(0, PAD_X, 0, bodyY)
    body.BackgroundTransparency = 1 body.Font = Enum.Font.Gotham
    body.Text = bodyText
    body.TextSize = 11 body.TextColor3 = Color3.fromRGB(230, 220, 200)
    body.TextXAlignment = Enum.TextXAlignment.Center body.TextYAlignment = Enum.TextYAlignment.Top
    body.TextWrapped = true body.Parent = card
    local cta = Instance.new("TextButton")
    cta.Size = UDim2.new(1, -PAD_X * 2, 0, CTA_H)
    cta.Position = UDim2.new(0, PAD_X, 1, -(CTA_H + BOTTOM_PAD))
    cta.BackgroundColor3 = Color3.fromRGB(255, 200, 40) cta.BorderSizePixel = 0
    cta.Font = Enum.Font.GothamBold cta.Text = "TAP TO COPY DISCORD INVITE" cta.TextSize = 11
    cta.TextColor3 = Color3.fromRGB(28, 22, 10) cta.AutoButtonColor = false cta.Parent = card
    corner(cta, 7)
    local DU = "https://discord.gg/K3vgcVsCsS"
    cta.MouseButton1Click:Connect(function()
        if type(setclipboard) == "function" then
            pcall(setclipboard, DU)
            cta.Text = "COPIED TO CLIPBOARD"
            cta.BackgroundColor3 = Color3.fromRGB(80, 220, 130)
            task.delay(1.8, function()
                if cta.Parent then
                    cta.Text = "TAP TO COPY DISCORD INVITE"
                    cta.BackgroundColor3 = Color3.fromRGB(255, 200, 40)
                end
            end)
        else
            cta.Text = DU
            task.delay(2.2, function() if cta.Parent then cta.Text = "TAP TO COPY DISCORD INVITE" end end)
        end
    end)
    TweenService:Create(cardScale, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 14), BackgroundTransparency = 0}):Play()
    task.delay(10, function()
        TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, -100), BackgroundTransparency = 1}):Play()
        task.delay(0.5, function() pcall(function() sg:Destroy() end) PNS = false end)
    end)
end
local PREMIUM_KEYS = {
    SilentAimEnabled = true, SilentAimHitChance = true, SilentAimFOV = true, SilentAimHitbox = true,
    SilentAimDrawFOV = true, SilentAimFOVColor = true, HitSoundsEnabled = true, HitSoundChoice = true,
    CustomCrosshairEnabled = true, HitboxExpanderEnabled = true, HitboxExpanderSize = true,
    SpinbotEnabled = true, RapidFireEnabled = true, MaxAccuracyEnabled = true, NoSpreadEnabled = true,
    ESPTargetVisEnabled = true, ViewmodelChamsEnabled = true, FlyNoclipEnabled = true,
    NightVisionEnabled = true, AimLockEnabled = true, RagebotEnabled = true,
    SilentAimDistanceBoost = true, SilentAimConvergenceSnap = true, SilentAimTightDeadzone = true,
}
local ToggleRegistry = {}
local function CTog(parent, text, key, cb)
    local isPrem = PREMIUM_KEYS[key] == true
    local locked = isPrem and not Configuration.IsPremium
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34) row.BackgroundTransparency = 1 row.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -60, 1, 0)
    if isPrem then l.Position = UDim2.new(0, 16, 0, 0) end
    l.BackgroundTransparency = 1 l.Font = Enum.Font.Gotham
    l.Text = tostring(text) l.TextSize = 12 l.TextColor3 = C.Text
    l.TextXAlignment = Enum.TextXAlignment.Left l.Parent = row
    if isPrem then
        local s = Instance.new("TextLabel")
        s.Size = UDim2.fromOffset(16, 14) s.Position = UDim2.new(0, -2, 0.5, -7)
        s.BackgroundTransparency = 1 s.Font = Enum.Font.GothamBold
        s.Text = "\226\152\133" s.TextSize = 12 s.TextColor3 = Color3.fromRGB(255, 200, 40) s.Parent = row
    end
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, 40, 0, 20) p.Position = UDim2.new(1, -40, 0.5, -10)
    p.BackgroundColor3 = locked and Color3.fromRGB(40, 30, 15) or C.PanelLight
    p.BorderSizePixel = 0 p.Parent = row
    corner(p, 10)
    stroke(p, locked and Color3.fromRGB(120, 90, 40) or C.Border, 1, 0.3)
    local k = Instance.new("Frame")
    k.Size = UDim2.new(0, 14, 0, 14) k.Position = UDim2.new(0, 3, 0.5, -7)
    k.BackgroundColor3 = locked and Color3.fromRGB(120, 90, 40) or C.TextMuted
    k.BorderSizePixel = 0 k.ZIndex = 2 k.Parent = p
    corner(k, 7)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0) btn.BackgroundTransparency = 1 btn.Text = "" btn.Parent = p
    local function setS(on, an)
        if locked then return end
        local info = TweenInfo.new(an and 0.2 or 0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        if on then
            T:Create(p, info, {BackgroundColor3 = C.Accent}):Play()
            T:Create(k, info, {Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = C.Text}):Play()
        else
            T:Create(p, info, {BackgroundColor3 = C.PanelLight}):Play()
            T:Create(k, info, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = C.TextMuted}):Play()
        end
    end
    btn.MouseButton1Click:Connect(function()
        if locked then pcall(showPrem) return end
        Configuration[key] = not Configuration[key]
        setS(Configuration[key], true)
        if cb then pcall(cb, Configuration[key]) end
        if key == "SilentAimEnabled" then
            if Configuration.SilentAimEnabled then
                if SILENT.InstallHook then pcall(SILENT.InstallHook) end
                if not IS_LOW_UNC then
                    _G.__VEIL_AimbotBeforeSilent = Configuration.CameraAssistEnabled
                    Configuration.CameraAssistEnabled = false
                    if ToggleRegistry["CameraAssistEnabled"] then ToggleRegistry["CameraAssistEnabled"](false, true) end
                else
                    Configuration.CameraAssistEnabled = true
                    if ToggleRegistry["CameraAssistEnabled"] then ToggleRegistry["CameraAssistEnabled"](true, true) end
                end
            else
                if SILENT.UninstallHook then pcall(SILENT.UninstallHook) end
                if not IS_LOW_UNC then
                    if _G.__VEIL_AimbotBeforeSilent then
                        Configuration.CameraAssistEnabled = true
                        if ToggleRegistry["CameraAssistEnabled"] then ToggleRegistry["CameraAssistEnabled"](true, true) end
                    end
                    _G.__VEIL_AimbotBeforeSilent = false
                end
                pcall(applyProfile, ActiveWeaponName)
            end
        elseif key == "CameraAssistEnabled" and Configuration.CameraAssistEnabled then
            if not IS_LOW_UNC then
                Configuration.SilentAimEnabled = false
                if ToggleRegistry["SilentAimEnabled"] then ToggleRegistry["SilentAimEnabled"](false, true) end
            end
            pcall(applyProfile, ActiveWeaponName)
        end
        Utility.InvalidateLobbyCache()
        saveActiveProfile()
    end)
    ToggleRegistry[key] = setS
    setS(Configuration[key], false)
    return row
end
local function CTogColor(parent, text, toggleKey, colorKey, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34) row.BackgroundTransparency = 1 row.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -200, 1, 0) l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham l.Text = tostring(text) l.TextSize = 12
    l.TextColor3 = C.Text l.TextXAlignment = Enum.TextXAlignment.Left l.Parent = row
    local cb2 = Instance.new("TextButton")
    cb2.Size = UDim2.new(0, 100, 0, 22) cb2.Position = UDim2.new(1, -146, 0.5, -11)
    cb2.BackgroundColor3 = C.Card cb2.BorderSizePixel = 0
    cb2.Font = Enum.Font.GothamMedium cb2.TextSize = 10 cb2.TextColor3 = C.Text
    cb2.Text = "Change colour" cb2.AutoButtonColor = false cb2.Parent = row
    corner(cb2, 6) stroke(cb2, C.Border, 1, 0.4)
    cb2.MouseButton1Click:Connect(function()
        local COLS = {
            {name="Purple", col=Color3.fromRGB(139, 92, 246)}, {name="Red", col=Color3.fromRGB(255, 60, 60)},
            {name="Blue", col=Color3.fromRGB(99, 102, 241)}, {name="Green", col=Color3.fromRGB(60, 220, 90)},
            {name="Yellow", col=Color3.fromRGB(255, 220, 60)}, {name="White", col=Color3.fromRGB(245, 243, 255)},
            {name="Black", col=Color3.fromRGB(25, 25, 30)}, {name="Cyan", col=Color3.fromRGB(80, 220, 240)},
            {name="Orange", col=Color3.fromRGB(255, 140, 60)}, {name="Pink", col=Color3.fromRGB(255, 100, 200)},
            {name="Lime", col=Color3.fromRGB(120, 255, 120)}, {name="Teal", col=Color3.fromRGB(60, 200, 180)},
        }
        local par = safeGuiParent()
        if not par then return end
        local psg = Instance.new("ScreenGui")
        psg.Name = "VEIL_Picker" psg.ResetOnSpawn = false psg.IgnoreGuiInset = true
        psg.DisplayOrder = 6000 psg.Parent = par
        local bdp = Instance.new("TextButton")
        bdp.Size = UDim2.fromScale(1, 1) bdp.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bdp.BackgroundTransparency = 0.5 bdp.BorderSizePixel = 0 bdp.Text = "" bdp.AutoButtonColor = false bdp.Parent = psg
        local panel = Instance.new("Frame")
        panel.AnchorPoint = Vector2.new(0.5, 0.5) panel.Position = UDim2.fromScale(0.5, 0.5)
        panel.Size = UDim2.fromOffset(300, 220) panel.BackgroundColor3 = C.Panel
        panel.BorderSizePixel = 0 panel.Parent = psg
        corner(panel, 10) stroke(panel, C.Border, 1, 0)
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -40, 0, 24) title.Position = UDim2.new(0, 14, 0, 10)
        title.BackgroundTransparency = 1 title.Font = Enum.Font.GothamBold
        title.TextSize = 12 title.TextColor3 = C.Text
        title.TextXAlignment = Enum.TextXAlignment.Left title.Text = "Pick a color" title.Parent = panel
        local closeB = Instance.new("TextButton")
        closeB.Size = UDim2.fromOffset(22, 22) closeB.Position = UDim2.new(1, -32, 0, 10)
        closeB.BackgroundColor3 = C.PanelLight closeB.BorderSizePixel = 0
        closeB.Font = Enum.Font.GothamBold closeB.TextSize = 13 closeB.TextColor3 = C.Text
        closeB.Text = "x" closeB.AutoButtonColor = false closeB.Parent = panel
        corner(closeB, 5)
        local grid = Instance.new("Frame")
        grid.Size = UDim2.new(1, -28, 1, -52) grid.Position = UDim2.new(0, 14, 0, 42)
        grid.BackgroundTransparency = 1 grid.Parent = panel
        local gl = Instance.new("UIGridLayout")
        gl.CellSize = UDim2.fromOffset(60, 34) gl.CellPadding = UDim2.fromOffset(6, 6)
        gl.SortOrder = Enum.SortOrder.LayoutOrder gl.Parent = grid
        local function cclose() pcall(function() psg:Destroy() end) end
        bdp.MouseButton1Click:Connect(cclose)
        closeB.MouseButton1Click:Connect(cclose)
        for _, info in ipairs(COLS) do
            local b = Instance.new("TextButton")
            b.BackgroundColor3 = info.col b.BorderSizePixel = 0 b.Text = "" b.AutoButtonColor = false b.Parent = grid
            corner(b, 6) stroke(b, C.Border, 1, 0.3)
            b.MouseButton1Click:Connect(function()
                Configuration[colorKey] = info.name
                saveActiveProfile()
                cclose()
            end)
        end
    end)
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, 40, 0, 20) p.Position = UDim2.new(1, -40, 0.5, -10)
    p.BackgroundColor3 = C.PanelLight p.BorderSizePixel = 0 p.Parent = row
    corner(p, 10) stroke(p, C.Border, 1, 0.3)
    local k = Instance.new("Frame")
    k.Size = UDim2.new(0, 14, 0, 14) k.Position = UDim2.new(0, 3, 0.5, -7)
    k.BackgroundColor3 = C.TextMuted k.BorderSizePixel = 0 k.ZIndex = 2 k.Parent = p
    corner(k, 7)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0) btn.BackgroundTransparency = 1 btn.Text = "" btn.Parent = p
    local function setS(on, an)
        local info = TweenInfo.new(an and 0.2 or 0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        if on then
            T:Create(p, info, {BackgroundColor3 = C.Accent}):Play()
            T:Create(k, info, {Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = C.Text}):Play()
        else
            T:Create(p, info, {BackgroundColor3 = C.PanelLight}):Play()
            T:Create(k, info, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = C.TextMuted}):Play()
        end
    end
    btn.MouseButton1Click:Connect(function()
        Configuration[toggleKey] = not Configuration[toggleKey]
        setS(Configuration[toggleKey], true)
        if cb then pcall(cb, Configuration[toggleKey]) end
        saveActiveProfile()
    end)
    setS(Configuration[toggleKey], false)
    return row
end
local function CSl(parent, text, key, mn, mx, step, bfn)
    local isPrem = PREMIUM_KEYS[key] == true
    local locked = isPrem and not Configuration.IsPremium
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, bfn and 64 or 44) c.BackgroundTransparency = 1 c.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.7, 0, 0, 16)
    if isPrem then l.Position = UDim2.new(0, 16, 0, 0) end
    l.BackgroundTransparency = 1 l.Font = Enum.Font.Gotham l.Text = tostring(text)
    l.TextSize = 11 l.TextColor3 = C.Text l.TextXAlignment = Enum.TextXAlignment.Left l.Parent = c
    local v = Instance.new("TextLabel")
    v.Size = UDim2.new(0.3, 0, 0, 16) v.Position = UDim2.new(0.7, 0, 0, 0)
    v.BackgroundTransparency = 1 v.Font = Enum.Font.GothamBold v.TextSize = 11
    v.TextColor3 = C.Accent3 v.TextXAlignment = Enum.TextXAlignment.Right v.Parent = c
    local tr = Instance.new("Frame")
    tr.Size = UDim2.new(1, 0, 0, 4) tr.Position = UDim2.new(0, 0, 0, 26)
    tr.BackgroundColor3 = C.PanelLight tr.BorderSizePixel = 0 tr.Parent = c
    corner(tr, 2)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 0, 1, 0) f.BackgroundColor3 = C.Accent f.BorderSizePixel = 0 f.Parent = tr
    corner(f, 2)
    local h = Instance.new("Frame")
    h.Size = UDim2.new(0, 12, 0, 12) h.Position = UDim2.new(0, -6, 0.5, -6)
    h.BackgroundColor3 = C.Text h.BorderSizePixel = 0 h.ZIndex = 3 h.Parent = tr
    corner(h, 6) stroke(h, C.Accent, 2, 0)
    local fm = "%.0f"
    if step and step < 1 then fm = "%.2f" end
    local dg = false
    local function upd(x)
        if locked then return end
        local tp = tr.AbsolutePosition.X
        local ts = tr.AbsoluteSize.X
        if ts <= 0 then return end
        local pct = math.clamp((x - tp) / ts, 0, 1)
        local val = mn + (mx - mn) * pct
        if step and step > 0 then val = math.round(val / step) * step end
        Configuration[key] = val
        v.Text = string.format(fm, val)
        f.Size = UDim2.new(pct, 0, 1, 0)
        h.Position = UDim2.new(pct, -6, 0.5, -6)
        if bfn then
            local ok, t = pcall(bfn, val)
            if ok and t then v.Text = tostring(t) end
        end
        saveActiveProfile()
    end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 16) btn.Position = UDim2.new(0, 0, 0, 20)
    btn.BackgroundTransparency = 1 btn.Text = "" btn.Parent = c
    btn.InputBegan:Connect(function(input)
        if locked then pcall(showPrem) return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dg = true upd(input.Position.X)
        end
    end)
    Connections.Track(UIS.InputChanged:Connect(function(input)
        if dg and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then upd(input.Position.X) end
    end))
    Connections.Track(UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dg = false end
    end))
    local ip = math.clamp((Configuration[key] - mn) / (mx - mn), 0, 1)
    v.Text = string.format(fm, Configuration[key])
    f.Size = UDim2.new(ip, 0, 1, 0)
    h.Position = UDim2.new(ip, -6, 0.5, -6)
    if bfn then
        local ok, t = pcall(bfn, Configuration[key])
        if ok and t then v.Text = tostring(t) end
    end
    return c
end
local function CBut(parent, text, cb, styl)
    styl = styl or "default"
    local bc, hc, tc = C.Card, C.PanelLight, C.Text
    if styl == "danger" then bc = Color3.fromRGB(60, 22, 28) hc = Color3.fromRGB(90, 30, 38) tc = Color3.fromRGB(255, 200, 200)
    elseif styl == "accent" then bc = C.Accent hc = C.Accent:Lerp(Color3.new(1, 1, 1), 0.15)
    elseif styl == "discord" then bc = C.Discord hc = Color3.fromRGB(110, 122, 255) tc = Color3.fromRGB(255, 255, 255) end
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 30) b.BackgroundColor3 = bc b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamMedium b.Text = tostring(text) b.TextSize = 12
    b.TextColor3 = tc b.AutoButtonColor = false b.Parent = parent
    corner(b, 8)
    if styl ~= "accent" and styl ~= "discord" then stroke(b, C.Border, 1, 0.4) end
    b.MouseEnter:Connect(function() T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = hc}):Play() end)
    b.MouseLeave:Connect(function() T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = bc}):Play() end)
    b.MouseButton1Click:Connect(function() if cb then cb(b) end end)
    return b
end
local function CSeg(parent, lbl, key, opts)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 48) c.BackgroundTransparency = 1 c.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 16) l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham l.Text = tostring(lbl) l.TextSize = 11
    l.TextColor3 = C.Text l.TextXAlignment = Enum.TextXAlignment.Left l.Parent = c
    local h = Instance.new("Frame")
    h.Size = UDim2.new(1, 0, 0, 24) h.Position = UDim2.new(0, 0, 0, 20)
    h.BackgroundColor3 = C.Card h.BorderSizePixel = 0 h.Parent = c
    corner(h, 6) stroke(h, C.Border, 1, 0.4)
    local sg = 1 / #opts
    local btns = {}
    for i, opt in ipairs(opts) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(sg, 0, 1, 0) b.Position = UDim2.new(sg * (i - 1), 0, 0, 0)
        b.BackgroundTransparency = 1 b.Font = Enum.Font.GothamMedium b.TextSize = 10
        b.TextColor3 = C.TextMuted b.Text = tostring(opt) b.AutoButtonColor = false b.Parent = h
        b.MouseButton1Click:Connect(function()
            Configuration[key] = opt
            for o, bb in pairs(btns) do
                if o == opt then bb.TextColor3 = C.Text else bb.TextColor3 = C.TextMuted end
            end
            saveActiveProfile()
        end)
        btns[opt] = b
        if Configuration[key] == opt then b.TextColor3 = C.Text end
    end
    return c
end
local function CCS(parent, lbl, key, order, cmap)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34) row.BackgroundTransparency = 1 row.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.4, 0, 1, 0) l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham l.Text = tostring(lbl) l.TextSize = 12
    l.TextColor3 = C.Text l.TextXAlignment = Enum.TextXAlignment.Left l.Parent = row
    local h = Instance.new("Frame")
    h.Size = UDim2.new(0.6, 0, 1, 0) h.Position = UDim2.new(0.4, 0, 0, 0)
    h.BackgroundTransparency = 1 h.Parent = row
    local ly = Instance.new("UIListLayout")
    ly.FillDirection = Enum.FillDirection.Horizontal
    ly.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ly.VerticalAlignment = Enum.VerticalAlignment.Center
    ly.Padding = UDim.new(0, 6) ly.Parent = h
    local btns = {}
    local function rf()
        for nm, b in pairs(btns) do
            local st2 = b:FindFirstChildOfClass("UIStroke")
            if st2 then
                if Configuration[key] == nm then st2.Thickness = 2 st2.Color = C.Accent st2.Transparency = 0
                else st2.Thickness = 1 st2.Color = C.Border st2.Transparency = 0.4 end
            end
        end
    end
    for _, nm in ipairs(order) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 16, 0, 16) b.BackgroundColor3 = cmap[nm] or Color3.fromRGB(255, 255, 255)
        b.BorderSizePixel = 0 b.Text = "" b.AutoButtonColor = false b.Parent = h
        corner(b, 8)
        if nm == "RGB" then
            local rgbGrad = Instance.new("UIGradient")
            rgbGrad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
            }
            rgbGrad.Parent = b
        end
        local st2 = Instance.new("UIStroke")
        st2.Thickness = 1 st2.Color = C.Border st2.Transparency = 0.4 st2.Parent = b
        b.MouseButton1Click:Connect(function() Configuration[key] = nm rf() end)
        btns[nm] = b
    end
    rf()
    return row
end
local function CKB(parent, lbl, tKey, cKey, mKey)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30) row.BackgroundTransparency = 1 row.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -130, 1, 0) l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham l.Text = tostring(lbl) l.TextSize = 12
    l.TextColor3 = C.Text l.TextXAlignment = Enum.TextXAlignment.Left l.Parent = row
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 110, 0, 22) b.Position = UDim2.new(1, -110, 0.5, -11)
    b.BackgroundColor3 = C.Card b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamMedium b.TextSize = 11 b.TextColor3 = C.Text
    b.AutoButtonColor = false b.Parent = row
    corner(b, 6) stroke(b, C.Border, 1, 0.4)
    local function cur()
        if Configuration[tKey] == "Mouse" then return tostring(Configuration[mKey]):gsub("Enum.UserInputType.", "") end
        return tostring(Configuration[cKey]):gsub("Enum.KeyCode.", "")
    end
    local cap = false
    local cc = nil
    b.MouseButton1Click:Connect(function()
        if cap then cap = false b.Text = cur() if cc then pcall(function() cc:Disconnect() end) cc = nil end return end
        cap = true b.Text = "press any key..." b.BackgroundColor3 = C.Accent
        cc = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then return end
            if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                Configuration[tKey] = "Mouse" Configuration[mKey] = input.UserInputType
            elseif input.UserInputType == Enum.UserInputType.Keyboard then
                Configuration[tKey] = "Key" Configuration[cKey] = input.KeyCode
            else return end
            cap = false b.Text = cur() b.BackgroundColor3 = C.Card
            if cc then pcall(function() cc:Disconnect() end) cc = nil end
        end)
    end)
    b.Text = cur()
    return row
end
local function formatTime(sec)
    if not sec or sec <= 0 then return "Expired" end
    local d = math.floor(sec / 86400)
    local h = math.floor((sec % 86400) / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = math.floor(sec % 60)
    if d > 0 then return string.format("%dd %dh", d, h) end
    if h > 0 then return string.format("%dh %dm", h, m) end
    return string.format("%dm %ds", m, s)
end

function Interface.BuildVisualsTab(parent)
    CSe(parent, "ESP")
    CTog(parent, "Enable Visuals", "VisualsEnabled")
    CTogColor(parent, "Show Boxes", "ShowBoxes", "BoxColor")
    CTog(parent, "Show Names", "ShowNames")
    CTog(parent, "Show Health", "ShowHealth")
    CTog(parent, "Show Distance", "ShowDistance")
    CTogColor(parent, "Show Skeleton", "ShowSkeleton", "SkeletonColor")
    CSeP(parent, "Extras")
    CTog(parent, "Sky Changer", "SkyChangerEnabled")
    CTog(parent, "ESP Target Visibility", "ESPTargetVisEnabled")
    CTog(parent, "Viewmodel Chams", "ViewmodelChamsEnabled")
    CTog(parent, "Night Vision", "NightVisionEnabled", NVApply)
    CSe(parent, "Interface")
    CTog(parent, "Show Watermark", "WatermarkEnabled", function(on) pcall(setWatermarkEnabled, on) end)
end

function Interface.BuildCombatTab(parent)
    CSe(parent, "Aimbot")
    CTog(parent, "Enable Aimbot", "CameraAssistEnabled")
    CTog(parent, "Always On", "CameraAssistAlwaysOn")
    CTog(parent, "Use Mouse While Locking", "CameraAssistUseMouseWhileLocking")
    CTog(parent, "Rotate Character", "CameraAssistRotateChar")
    CSeP(parent, "Modes")
    CTog(parent, "Camera Assist", "AimLockEnabled")
    CTog(parent, "Ragebot", "RagebotEnabled")
    CSe(parent, "Aim FOV")
    CSl(parent, "Aim FOV", "CameraAssistFOV", 5, 65, 1)
    CTog(parent, "Draw FOV Circle", "CameraAssistDrawFOV")
    CCS(parent, "FOV Color", "CameraAssistFOVColor", {"White", "Red", "Yellow", "Blue", "Green", "Black", "Cyan", "RGB"}, FOVCircle.ColorMap)
    CSe(parent, "Keybind")
    CKB(parent, "Aim Key", "AimBindType", "AimKeyCode", "AimMouseButton")
    CSe(parent, "Smoothing")
    CSl(parent, "Smoothing", "CameraAssistSmoothing", 0, 20, 1)
    CSe(parent, "Target")
    CSeg(parent, "Hitbox Mode", "CameraAssistHitboxMode", {"Head", "UpperTorso", "Chest", "Random"})
    CSe(parent, "Filters")
    CTog(parent, "Team Check", "TeamCheck")
    CTog(parent, "Visible Check", "CameraAssistVisibleCheck")
    CTog(parent, "FOV Priority", "CameraAssistFOVPriority")
    CTog(parent, "Auto Stop on Katana Deflect", "AutoStopOnKatanaDeflect")
    CSe(parent, "Weapon")
    CTog(parent, "Auto-Detect Weapon", "WeaponAutoDetect")
    CTog(parent, "Use Weapon Profiles", "WeaponProfilesEnabled")
    CSe(parent, "View FOV")
    CTog(parent, "Custom View FOV", "ViewFOVEnabled")
    CSl(parent, "View FOV", "ViewFOV", 70, 120, 1)
end

function Interface.BuildSilentTab(parent)
    CSeP(parent, "Silent Aim")
    CTog(parent, "Enable Silent Aim", "SilentAimEnabled")
    CSl(parent, "Hit Chance (%)", "SilentAimHitChance", 0, 100, 1)
    CSeg(parent, "Hitbox Mode", "SilentAimHitbox", {"Head", "UpperTorso", "Chest", "Random"})

    CSeP(parent, "Silent FOV")
    CSl(parent, "Silent FOV", "SilentAimFOV", 5, 400, 1)
    CTog(parent, "Draw Silent FOV", "SilentAimDrawFOV")
    CCS(parent, "FOV Color", "SilentAimFOVColor", {"White", "Red", "Yellow", "Blue", "Green", "Black", "Cyan", "RGB"}, FOVCircle.ColorMap)

    CSeP(parent, "Sniper / Long Range")
    CSl(parent, "Distance Boost", "SilentAimDistanceBoost", 0.0, 2.0, 0.1, function(v)
        if v <= 0.2 then return "OFF", Color3.fromRGB(180, 180, 180) end
        if v <= 0.8 then return "LOW", Color3.fromRGB(120, 200, 255) end
        if v <= 1.4 then return "MID", Color3.fromRGB(255, 190, 60) end
        return "MAX", Color3.fromRGB(255, 120, 90)
    end)
    CTog(parent, "Convergence Snap", "SilentAimConvergenceSnap")
    CTog(parent, "Tight Deadzone (far targets)", "SilentAimTightDeadzone")

    CSeP(parent, "Info")
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 60) info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham info.TextSize = 10
    info.TextColor3 = C.TextMuted info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.Text = "Distance Boost raises pull strength on far targets. Convergence Snap commits the aim inside the last few degrees so the shot lands. Tight Deadzone shrinks the stop angle for far targets where the head subtends less than a tenth of a degree."
    info.Parent = parent
end

function Interface.BuildTriggerTab(parent)
    CSe(parent, "Triggerbot")
    CTog(parent, "Enable Triggerbot", "AutoFireEnabled")
    CTog(parent, "Always On", "AutoFireAlwaysOn")
    CSe(parent, "Keybind")
    CKB(parent, "Fire Key", "AutoFireBindType", "AutoFireKeyCode", "AutoFireMouseButton")
    CSe(parent, "Timing")
    CSl(parent, "Fire Delay", "AutoFireDelay", 0.01, 0.5, 0.01)
    CSe(parent, "Range")
    CSl(parent, "Max Distance", "AutoFireMaxDistance", 100, 2000, 50)
    CTog(parent, "Proximity Fallback", "AutoFireProximityFallback")
    CSl(parent, "Proximity Angle", "AutoFireProximityAngle", 1.0, 8.0, 0.1)
end

function Interface.BuildModsTab(parent)
    CSe(parent, "Movement")
    CTog(parent, "Fly", "FlyEnabled")
    CSl(parent, "Fly Speed", "FlySpeed", 10, 80, 5)
    CTog(parent, "Speed Hack", "SpeedEnabled")
    CSl(parent, "Walk Speed", "SpeedValue", 16, 500, 1)
    CTog(parent, "Infinite Jump", "InfJumpEnabled")
    CTog(parent, "Noclip", "NoclipEnabled")
    CSe(parent, "Recoil & Effects")
    CTog(parent, "No Recoil", "NoRecoilEnabled")
    CTog(parent, "Anti Flash", "AntiFlashEnabled")
    CSe(parent, "Weapon Tweaks")
    CTog(parent, "Hitbox Expander", "HitboxExpanderEnabled")
    CSl(parent, "Expander Size", "HitboxExpanderSize", 1.0, 5.0, 0.1)
    CSeP(parent, "Combat Extras")
    CTog(parent, "Rapid Fire", "RapidFireEnabled")
    CTog(parent, "Max Accuracy", "MaxAccuracyEnabled")
    CTog(parent, "No Spread", "NoSpreadEnabled")
    CTog(parent, "Spinbot", "SpinbotEnabled")
    CTog(parent, "Custom Crosshair", "CustomCrosshairEnabled")
    CSeP(parent, "Fun")
    CTog(parent, "Hit Sounds", "HitSoundsEnabled")
    local soundOpts = {"Vine Boom", "Mega Knight", "MLG Airhorn", "Boom Headshot", "Taco Bell"}
    local soundRow = Instance.new("Frame")
    soundRow.Size = UDim2.new(1, 0, 0, 24) soundRow.BackgroundColor3 = VEILUI.BtnBg
    soundRow.BorderSizePixel = 0 soundRow.Parent = parent
    corner(soundRow, 6) stroke(soundRow, VEILUI.Stroke, 1, 0.4)
    local sw = 1 / #soundOpts
    local sBtns = {}
    for i, nm in ipairs(soundOpts) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(sw, 0, 1, 0) b.Position = UDim2.new(sw * (i - 1), 0, 0, 0)
        b.BackgroundTransparency = 1 b.Font = Enum.Font.GothamMedium b.TextSize = 9
        b.TextColor3 = VEILUI.TextMuted b.Text = nm b.AutoButtonColor = false b.Parent = soundRow
        b.MouseButton1Click:Connect(function()
            if not Configuration.IsPremium then pcall(showPrem) return end
            Configuration.HitSoundChoice = nm
            for o, bb in pairs(sBtns) do
                if o == nm then bb.TextColor3 = VEILUI.Text else bb.TextColor3 = VEILUI.TextMuted end
            end
            saveActiveProfile()
        end)
        sBtns[nm] = b
        if Configuration.HitSoundChoice == nm then b.TextColor3 = VEILUI.Text end
    end
end

function Interface.BuildConfigTab(parent)
    CSe(parent, "Interface")
    CKB(parent, "Menu Key", "MenuBindType", "MenuKey", "MenuMouseButton")
    CSe(parent, "Performance Tools")
    CTog(parent, "FPS Boost", "FPSBoostEnabled", function(on)
        if on then pcall(PerformanceTools.EnableFPSBoost) else pcall(PerformanceTools.DisableFPSBoost) end
    end)
    CSl(parent, "Max Render Distance", "MaxRenderDistance", 200, 2000, 50)
    CSe(parent, "Premium Key \226\152\133")
    local premInput = Instance.new("TextBox")
    premInput.Size = UDim2.new(1, 0, 0, 34) premInput.BackgroundColor3 = VEILUI.BtnBg
    premInput.BorderSizePixel = 0 premInput.Font = Enum.Font.GothamMedium
    premInput.TextSize = 12 premInput.TextColor3 = VEILUI.Text
    premInput.PlaceholderText = "VL-XXXXXXXXX"
    premInput.PlaceholderColor3 = VEILUI.TextMuted premInput.Text = ""
    premInput.ClearTextOnFocus = false premInput.TextXAlignment = Enum.TextXAlignment.Left premInput.Parent = parent
    corner(premInput, 6)
    local premPad = Instance.new("UIPadding")
    premPad.PaddingLeft = UDim.new(0, 10) premPad.PaddingRight = UDim.new(0, 10) premPad.Parent = premInput
    CBut(parent, "Redeem Premium Key", function(btn)
        local key = tostring(premInput.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if key == "" then Popup.Show("Enter a key first", false) return end
        local ok = KeySystem.Validate(key)
        if ok and Configuration.IsPremium then
            btn.Text = "Activated: " .. Configuration.PremiumTier
            premInput.Text = ""
            task.wait(2) btn.Text = "Redeem Premium Key"
        else
            btn.Text = "Not a valid premium key"
            task.wait(2) btn.Text = "Redeem Premium Key"
        end
    end, "accent")
    CSe(parent, "License Status")
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, 0, 0, 50) statusFrame.BackgroundColor3 = VEILUI.BtnBg
    statusFrame.BackgroundTransparency = 0.3 statusFrame.BorderSizePixel = 0 statusFrame.Parent = parent
    corner(statusFrame, 6) stroke(statusFrame, VEILUI.Stroke, 1, 0.3)
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -16, 0, 16) statusLabel.Position = UDim2.new(0, 8, 0, 6)
    statusLabel.BackgroundTransparency = 1 statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 11 statusLabel.TextColor3 = VEILUI.Accent3
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Text = "Type: --" statusLabel.Parent = statusFrame
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(1, -16, 0, 16) timeLabel.Position = UDim2.new(0, 8, 0, 24)
    timeLabel.BackgroundTransparency = 1 timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextSize = 11 timeLabel.TextColor3 = VEILUI.TextMuted
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Text = "Time Remaining: --" timeLabel.Parent = statusFrame
    Connections.Track(RunService.Heartbeat:Connect(function()
        if CameraAssist.ShuttingDown or not statusFrame.Parent then return end
        if Configuration.IsPremium and Configuration.PremiumExpiry > 0 then
            local remaining = Configuration.PremiumExpiry - os.time()
            if remaining <= 0 then
                Configuration.IsPremium = false Configuration.PremiumTier = nil
                Configuration.PremiumExpiry = 0 Configuration.PremiumKey = nil
                statusLabel.Text = "Type: Expired" statusLabel.TextColor3 = VEILUI.Danger
                timeLabel.Text = "Time Remaining: --"
            else
                statusLabel.Text = "Type: Premium \226\152\133 " .. tostring(Configuration.PremiumTier or "")
                statusLabel.TextColor3 = VEILUI.Gold
                timeLabel.Text = "Time Remaining: " .. formatTime(remaining)
            end
        else
            local savedKey, expiry = KeySystem.ReadSaved()
            if savedKey and expiry and expiry > os.time() then
                statusLabel.Text = "Type: Work.ink Key" statusLabel.TextColor3 = VEILUI.Accent3
                timeLabel.Text = "Time Remaining: " .. formatTime(expiry - os.time())
            else
                statusLabel.Text = "Type: --" statusLabel.TextColor3 = VEILUI.TextMuted
                timeLabel.Text = "Time Remaining: --"
            end
        end
    end))
    CSe(parent, "Configuration")
    CBut(parent, "Save Config", function(btn)
        local ok = Configuration:Save()
        local o = btn.Text btn.Text = ok and "Saved" or "Failed"
        task.wait(1.2) btn.Text = o
    end, "accent")
    CBut(parent, "Load Config", function(btn)
        local ok = Configuration:Load()
        local o = btn.Text btn.Text = ok and "Loaded" or "No Save"
        task.wait(1.2) btn.Text = o
    end)
    CSe(parent, "Community")
    CBut(parent, "Join Discord", function(btn)
        local o = btn.Text
        if type(setclipboard) == "function" then pcall(setclipboard, "https://discord.gg/K3vgcVsCsS") btn.Text = "Link copied" end
        task.wait(1.6) btn.Text = o
    end, "discord")
    CSe(parent, "System")
    CBut(parent, "Unload VEIL", function() Interface.Unload() end, "danger")
end

function Interface.Create()
    local sg = makeScreenGui("VEIL_UI", 5000, false)
    if not sg then return nil end
    Interface.ScreenGui = sg
    local mf = Instance.new("Frame")
    mf.Name = "Main"
    mf.Size = UDim2.new(0, 700, 0, 480)
    mf.Position = UDim2.new(0.5, -350, 0.5, -240)
    mf.BackgroundColor3 = VEILUI.Bg mf.BorderSizePixel = 0
    mf.ClipsDescendants = true mf.Visible = false mf.Parent = sg
    Interface.MainFrame = mf
    corner(mf, 14) stroke(mf, VEILUI.Stroke, 1.5, 0)
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 158, 1, -16) sidebar.Position = UDim2.new(0, 8, 0, 8)
    sidebar.BackgroundTransparency = 1 sidebar.Parent = mf
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 0, 36) logo.BackgroundTransparency = 1
    logo.Font = Enum.Font.GothamBlack logo.Text = "VEIL" logo.TextSize = 30
    logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    logo.TextXAlignment = Enum.TextXAlignment.Center logo.Parent = sidebar
    addShine(logo)
    local v1 = Instance.new("TextLabel")
    v1.Size = UDim2.new(1, 0, 0, 12) v1.Position = UDim2.new(0, 0, 0, 34)
    v1.BackgroundTransparency = 1 v1.Font = Enum.Font.GothamBold
    v1.Text = "V 1" v1.TextSize = 10
    v1.TextColor3 = Color3.fromRGB(180, 130, 255)
    v1.TextXAlignment = Enum.TextXAlignment.Center v1.Parent = sidebar
    addShine(v1)
    local sl = Instance.new("TextLabel")
    sl.Size = UDim2.new(1, 0, 0, 12) sl.Position = UDim2.new(0, 0, 0, 48)
    sl.BackgroundTransparency = 1 sl.Font = Enum.Font.GothamBold
    sl.Text = "S E C U R I T Y   S U I T E" sl.TextSize = 8
    sl.TextColor3 = VEILUI.Accent3 sl.TextXAlignment = Enum.TextXAlignment.Center sl.Parent = sidebar
    addShine(sl)
    local tabN = {"Visuals", "Combat", "Silent", "Trigger", "Mods", "Config"}
    local tabBtns = {}
    for i, nm in ipairs(tabN) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -12, 0, 30) b.Position = UDim2.new(0, 6, 0, 78 + (i - 1) * 36)
        b.BackgroundColor3 = VEILUI.BtnBg b.BackgroundTransparency = 0.4 b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamMedium b.Text = nm b.TextSize = 12
        b.TextColor3 = VEILUI.TextMuted b.AutoButtonColor = false b.Parent = sidebar
        corner(b, 8) stroke(b, VEILUI.Stroke, 1, 0.3)
        tabBtns[nm] = b
        Interface.TabButtons[nm] = b
    end
    local statusRow = Instance.new("Frame")
    statusRow.Size = UDim2.new(1, -12, 0, 48) statusRow.Position = UDim2.new(0, 6, 1, -56)
    statusRow.BackgroundTransparency = 1 statusRow.Parent = sidebar
    local fpsBar = Instance.new("Frame")
    fpsBar.Size = UDim2.new(1, 0, 0, 20) fpsBar.BackgroundColor3 = VEILUI.BtnBg
    fpsBar.BackgroundTransparency = 0.3 fpsBar.BorderSizePixel = 0 fpsBar.Parent = statusRow
    corner(fpsBar, 6) stroke(fpsBar, VEILUI.Accent, 1, 0.5)
    local fpsDot = Instance.new("Frame")
    fpsDot.Size = UDim2.fromOffset(6, 6) fpsDot.Position = UDim2.new(0, 8, 0.5, -3)
    fpsDot.BackgroundColor3 = Color3.fromRGB(80, 220, 130) fpsDot.BorderSizePixel = 0 fpsDot.Parent = fpsBar
    corner(fpsDot, 3)
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, -22, 1, 0) fpsLabel.Position = UDim2.new(0, 20, 0, 0)
    fpsLabel.BackgroundTransparency = 1 fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.Text = "--- FPS" fpsLabel.TextSize = 10 fpsLabel.TextColor3 = VEILUI.Text
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left fpsLabel.Parent = fpsBar
    local stat = Instance.new("TextLabel")
    stat.Size = UDim2.new(1, 0, 0, 22) stat.Position = UDim2.new(0, 0, 0, 26)
    stat.BackgroundTransparency = 1 stat.Font = Enum.Font.GothamBold
    stat.Text = tostring(ExecutorInfo.Name) stat.TextSize = 14
    stat.TextColor3 = VEILUI.Accent3 stat.TextXAlignment = Enum.TextXAlignment.Center stat.Parent = statusRow
    local fa, ff = 0, 0
    Connections.Track(RunService.RenderStepped:Connect(function(dt)
        if CameraAssist.ShuttingDown or not fpsLabel.Parent then return end
        fa = fa + dt ff = ff + 1
        if fa >= 0.5 then
            local f = math.floor(ff / fa + 0.5)
            fpsLabel.Text = tostring(f) .. " FPS"
            local col = f >= 90 and Color3.fromRGB(80, 220, 130) or (f >= 45 and Color3.fromRGB(255, 220, 60) or Color3.fromRGB(255, 80, 100))
            fpsDot.BackgroundColor3 = col fpsLabel.TextColor3 = col
            fa = 0 ff = 0
        end
    end))
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -176, 1, -16) content.Position = UDim2.new(0, 168, 0, 8)
    content.BackgroundColor3 = VEILUI.BtnBg content.BackgroundTransparency = 0.7
    content.BorderSizePixel = 0 content.Parent = mf
    corner(content, 10) stroke(content, VEILUI.Stroke, 1.5, 0)
    local cB = Instance.new("TextButton")
    cB.Size = UDim2.fromOffset(24, 24) cB.Position = UDim2.new(1, -30, 0, 6)
    cB.BackgroundTransparency = 1 cB.Font = Enum.Font.GothamBold cB.Text = "X"
    cB.TextSize = 14 cB.TextColor3 = VEILUI.Text cB.AutoButtonColor = false cB.Parent = mf
    cB.MouseButton1Click:Connect(function() mf.Visible = false end)
    local dg = false dS = nil dP = nil
    mf.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dg = true dS = input.Position dP = mf.Position
        end
    end)
    Connections.Track(UIS.InputChanged:Connect(function(input)
        if dg and input.UserInputType == Enum.UserInputType.MouseMovement then
            local dl = input.Position - dS
            mf.Position = UDim2.new(dP.X.Scale, dP.X.Offset + dl.X, dP.Y.Scale, dP.Y.Offset + dl.Y)
        end
    end))
    Connections.Track(UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dg = false end
    end))
    for _, nm in ipairs(tabN) do
        local sc = Instance.new("ScrollingFrame")
        sc.Size = UDim2.new(1, -16, 1, -16) sc.Position = UDim2.new(0, 8, 0, 8)
        sc.BackgroundTransparency = 1 sc.BorderSizePixel = 0
        sc.ScrollBarThickness = 3 sc.ScrollBarImageColor3 = VEILUI.Accent
        sc.CanvasSize = UDim2.new(0, 0, 0, 0)
        sc.AutomaticCanvasSize = Enum.AutomaticSize.Y sc.Visible = false sc.Parent = content
        local ly = Instance.new("UIListLayout")
        ly.Padding = UDim.new(0, 4) ly.SortOrder = Enum.SortOrder.LayoutOrder ly.Parent = sc
        local pd = Instance.new("UIPadding")
        pd.PaddingTop = UDim.new(0, 4) pd.PaddingBottom = UDim.new(0, 6) pd.PaddingRight = UDim.new(0, 4) pd.Parent = sc
        Interface.TabContents[nm] = sc
    end
    function Interface.SelectTab(nm)
        if Interface.CurrentTab then
            local ob = tabBtns[Interface.CurrentTab]
            if ob then T:Create(ob, TweenInfo.new(0.2), {BackgroundColor3 = VEILUI.BtnBg, BackgroundTransparency = 0.4, TextColor3 = VEILUI.TextMuted}):Play() end
        end
        Interface.CurrentTab = nm
        local b = tabBtns[nm]
        if b then
            b.BackgroundColor3 = VEILUI.Accent
            T:Create(b, TweenInfo.new(0.2), {BackgroundTransparency = 0.1, TextColor3 = VEILUI.Text}):Play()
        end
        for n, c in pairs(Interface.TabContents) do c.Visible = (n == nm) end
    end
    for nm, b in pairs(tabBtns) do b.MouseButton1Click:Connect(function() Interface.SelectTab(nm) end) end
    pcall(function() Interface.BuildVisualsTab(Interface.TabContents["Visuals"]) end)
    pcall(function() Interface.BuildCombatTab(Interface.TabContents["Combat"]) end)
    pcall(function() Interface.BuildSilentTab(Interface.TabContents["Silent"]) end)
    pcall(function() Interface.BuildTriggerTab(Interface.TabContents["Trigger"]) end)
    pcall(function() Interface.BuildModsTab(Interface.TabContents["Mods"]) end)
    pcall(function() Interface.BuildConfigTab(Interface.TabContents["Config"]) end)
    Interface.SelectTab("Visuals")
end

function Interface.Unload()
    CameraAssist.ShuttingDown = true
    SILENT.Active = false
    if SILENT.UninstallHook then pcall(SILENT.UninstallHook) end
    pcall(function() CameraAssist.Unbind() end)
    pcall(function() CameraAssist.UnbindViewFOV() end)
    pcall(function() CameraAssist.RestorePostFX() end)
    pcall(function() NVDisable() end)
    pcall(function() PerformanceTools.DisableFPSBoost() end)
    pcall(function()
        local lp = Players.LocalPlayer
        if lp and lp.Character then
            local t = lp.Character:FindFirstChildOfClass("Tool")
            if t and not t.Enabled then t.Enabled = true end
            local hum = lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function() hum.AutoRotate = true end)
                pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true) end)
                pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Running, true) end)
                pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
            end
            if CameraAssist._neckJoint and CameraAssist._neckC0 then
                pcall(function()
                    if CameraAssist._neckJoint.Parent then
                        CameraAssist._neckJoint.C0 = CameraAssist._neckC0
                    end
                end)
            end
            CameraAssist._neckJoint = nil CameraAssist._neckC0 = nil
        end
    end)
    pcall(function() Connections.DisconnectAll() end)
    Configuration.VisualsEnabled = false
    Configuration.CameraAssistEnabled = false
    Configuration.AutoFireEnabled = false
    pcall(function()
        for _, v in pairs(Visuals.Objects) do
            if v then
                if v.Container then pcall(function() v.Container:Destroy() end) end
                if v.SkeletonLines then
                    for _, l in ipairs(v.SkeletonLines) do if l then pcall(function() l:Destroy() end) end end
                end
            end
        end
        Visuals.Objects = {}
    end)
    pcall(function()
        if Visuals.Container then Visuals.Container:Destroy() end
        Visuals.Container = nil
    end)
    pcall(function() FOVCircle.Destroy() end)
    pcall(function() if Interface.ScreenGui then Interface.ScreenGui:Destroy() end end)
    pcall(function() saveActiveProfile() end)
    pcall(function() Configuration:Save() end)
    pcall(function()
        local par = safeGuiParent()
        if par then
            for _, g in ipairs(par:GetChildren()) do
                local n = g.Name
                if n == "VEIL_Startup" or n == "VEIL_Watermark" or n == "VEIL_Discord"
                    or n == "VEIL_Premium" or n == "VEIL_MobileOverlay" or n == "VEIL_Picker"
                    or n == "VEIL_Crosshair" or n == "VEIL_KeyUI" or n == "VEIL_Popup"
                    or n == "VEIL_UI" or n == "VEIL_Visuals" or n == "VEIL_FOV" then
                    pcall(function() g:Destroy() end)
                end
            end
        end
    end)
end

-- ============================================================
-- Mobile overlay
-- ============================================================
local MobileOverlay = nil
local mobileToggleMenu = function() if Interface.MainFrame then Interface.MainFrame.Visible = not Interface.MainFrame.Visible end end
if DeviceInfo.isMobile then
    local par = safeGuiParent()
    if par then
        local sg = Instance.new("ScreenGui")
        sg.Name = "VEIL_MobileOverlay" sg.ResetOnSpawn = false sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling sg.DisplayOrder = 50
        pcall(function() sg.Parent = par end)
        local function mb(name, text, px, py, size, col)
            local b = Instance.new("TextButton")
            b.Name = name b.AnchorPoint = Vector2.new(0.5, 0.5)
            b.Size = UDim2.fromOffset(size, size) b.Position = UDim2.new(px, 0, py, 0)
            b.BackgroundColor3 = col b.BackgroundTransparency = 0.35 b.BorderSizePixel = 0
            b.Font = Enum.Font.GothamBold b.TextSize = math.floor(size * 0.22)
            b.TextColor3 = Color3.fromRGB(255, 255, 255) b.Text = text
            b.TextStrokeTransparency = 0.5 b.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            b.AutoButtonColor = false b.Parent = sg
            local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0.5, 0) c.Parent = b
            return b
        end
        local ab = mb("Aim", "AIM", 0.88, 0.55, 100, Color3.fromRGB(220, 60, 90))
        local mB = mb("Menu", "MENU", 0.12, 0.10, 70, Color3.fromRGB(99, 102, 241))
        ab.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then CameraAssist.KeyHeld = true end
        end)
        ab.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then CameraAssist.KeyHeld = false end
        end)
        mB.MouseButton1Click:Connect(mobileToggleMenu)
        MobileOverlay = sg
    end
    Configuration.CameraAssistUseMouseWhileLocking = false
    Configuration.CameraAssistSmoothing = 10
    Configuration.CameraAssistFOV = 30
end

-- ============================================================
-- Anti-Flash
-- ============================================================
local FLASH_NAME_PATTERNS = {
    "flash", "blind", "damage", "hitmark", "hit_", "_hit", "blood",
    "redflash", "whiteflash", "grenade", "flashbang", "concussion",
    "overlay", "vignette", "hurt", "dmg",
}
local function nameIsFlashy(n)
    if not n then return false end
    local l = n:lower()
    for _, p in ipairs(FLASH_NAME_PATTERNS) do if l:find(p) then return true end end
    return false
end
local function initAntiFlash()
    local AntiFlash = { killedFX = setmetatable({}, {__mode = "k"}), conns = {}, sweepTask = nil }
    local function killLighting(inst)
        if not Configuration.AntiFlashEnabled or not inst or not inst.Parent then return end
        if inst:IsA("ColorCorrectionEffect") or inst:IsA("BrightnessEffect")
            or inst:IsA("BlurEffect") or inst:IsA("DepthOfFieldEffect") then
            if inst.Name == "VEIL_NightVision" then return end
            local flashy = nameIsFlashy(inst.Name)
            if not flashy and inst:IsA("ColorCorrectionEffect") then
                if (inst.Brightness or 0) > 0.35 then flashy = true end
                local tc = inst.TintColor
                if tc and tc.R > 0.85 and tc.G > 0.85 and tc.B > 0.85 and (inst.Enabled ~= false) then flashy = true end
            end
            if not flashy and inst:IsA("BrightnessEffect") and (inst.Brightness or 0) > 0.25 then flashy = true end
            if flashy then pcall(function() inst.Enabled = false end) AntiFlash.killedFX[inst] = true end
        end
    end
    for _, ch in ipairs(Lighting:GetChildren()) do killLighting(ch) end
    table.insert(AntiFlash.conns, Lighting.DescendantAdded:Connect(function(ch)
        if not Configuration.AntiFlashEnabled then return end
        task.defer(function() killLighting(ch) end)
    end))
    AntiFlash.sweepTask = task.spawn(function()
        while not CameraAssist.ShuttingDown do
            task.wait(0.33 * RATE_MULT)
            if not Configuration.AntiFlashEnabled then continue end
            for _, ch in ipairs(Lighting:GetChildren()) do killLighting(ch) end
        end
    end)
    _G.__VEIL_AntiFlash = AntiFlash
end

-- ============================================================
-- Initialize
-- ============================================================
local function initialize()
    if _G.__VEIL_INITIALIZED then return end
    _G.__VEIL_INITIALIZED = true
    pcall(function() Configuration:Load() end)
    if Configuration.SilentAimEnabled and SILENT.InstallHook then
        pcall(SILENT.InstallHook)
    end
    local cat = detectWeapon()
    if Configuration.WeaponProfilesEnabled and Configuration.WeaponAutoDetect then
        ActiveWeaponName = cat or "Default"
        applyProfile(ActiveWeaponName)
    else
        ActiveWeaponName = "Default"
    end
    Interface.Create()
    FOVCircle.Ensure()
    if Configuration.FPSBoostEnabled then pcall(PerformanceTools.EnableFPSBoost) end
    pcall(initAntiFlash)
    if Configuration.NightVisionEnabled then pcall(NVEnable) end
    CameraAssist.InitFocusTracking()
    CameraAssist.Bind()
    pcall(CameraAssist.BindViewFOV)
    _G.__VEIL_BindDeferred = function()
        if CameraAssist.Bound then return end
        CameraAssist.Bind()
        pcall(CameraAssist.BindViewFOV)
    end
    _G.__VEIL_Weapon = {
        get = function() return ActiveWeaponName end,
        set = function(name) saveActiveProfile() ActiveWeaponName = name applyProfile(name) end,
    }
    Connections.Track(UIS.InputBegan:Connect(function(input)
        local isMenuInput = false
        if Configuration.MenuBindType == "Mouse" then
            isMenuInput = input.UserInputType == Configuration.MenuMouseButton
        else
            isMenuInput = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Configuration.MenuKey
        end
        if not isMenuInput then return end
        if Interface.MainFrame then Interface.MainFrame.Visible = not Interface.MainFrame.Visible end
    end))
    Connections.Track(UIS.InputBegan:Connect(function(input)
        if Configuration.AutoFireBindType == "Mouse" then
            if input.UserInputType == Configuration.AutoFireMouseButton then AutoFire.KeyHeld = true end
        else
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Configuration.AutoFireKeyCode then AutoFire.KeyHeld = true end
        end
    end))
    Connections.Track(UIS.InputEnded:Connect(function(input)
        if Configuration.AutoFireBindType == "Mouse" then
            if input.UserInputType == Configuration.AutoFireMouseButton then AutoFire.KeyHeld = false end
        else
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Configuration.AutoFireKeyCode then AutoFire.KeyHeld = false end
        end
    end))
    Connections.Track(Players.PlayerRemoving:Connect(function(p)
        Visuals.OnPlayerRemoving(p)
        Utility.ClearTeamCache(p)
    end))
    Connections.Track(RunService.RenderStepped:Connect(function()
        if CameraAssist.ShuttingDown then return end
        if Configuration.VisualsEnabled or next(Visuals.Objects) ~= nil then
            pcall(function() Visuals.Step() end)
        end
        if Configuration.CameraAssistDrawFOV or Configuration.SilentAimDrawFOV then
            pcall(function() FOVCircle.Update() end)
        end
    end))
    local HB = {}
    local function Reg(name, rate, fn) HB[name] = { rate = rate * RATE_MULT, last = 0, fn = fn } end
    Reg("silent_flag", 0, function()
        SILENT.Active = Configuration.SilentAimEnabled
            and CameraAssist.Lock ~= nil
            and CameraAssist.Lock.Character ~= nil
            and CameraAssist.Lock.Character.Parent ~= nil
    end)
    Reg("input_reconcile", 0, function()
        if not CameraAssist.KeyHeld and not AutoFire.KeyHeld then return end
        if CameraAssist.KeyHeld then
            local stillHeld = false
            if Configuration.AimBindType == "Mouse" then
                pcall(function() stillHeld = UIS:IsMouseButtonPressed(Configuration.AimMouseButton) end)
            else
                pcall(function() stillHeld = UIS:IsKeyDown(Configuration.AimKeyCode) end)
            end
            if not stillHeld then CameraAssist.KeyHeld = false end
        end
        if AutoFire.KeyHeld then
            local stillHeld = false
            if Configuration.AutoFireBindType == "Mouse" then
                pcall(function() stillHeld = UIS:IsMouseButtonPressed(Configuration.AutoFireMouseButton) end)
            else
                pcall(function() stillHeld = UIS:IsKeyDown(Configuration.AutoFireKeyCode) end)
            end
            if not stillHeld then AutoFire.KeyHeld = false end
        end
    end)
    Reg("autofire", 0, function()
        if not Configuration.AutoFireEnabled then return end
        AutoFire.CheckAndFire()
    end)
    Reg("featureapply", 0.15, function()
        FeatureApply("aimlock", { enabled = Configuration.AimLockEnabled, set = { CameraAssistUseMouseWhileLocking = false } })
        FeatureApply("ragebot", { enabled = Configuration.RagebotEnabled, set = { CameraAssistSmoothing = 0, CameraAssistFOV = 65 } })
        FeatureApply("rapidfire", { enabled = Configuration.RapidFireEnabled, set = { AutoFireDelay = 0.01 } })
        FeatureApply("accuracy", { enabled = (Configuration.MaxAccuracyEnabled or Configuration.NoSpreadEnabled), set = { CameraAssistBulletSpeed = 3000, CameraAssistPrediction = true } })
    end)
    Reg("spinbot", 0.05, function()
        local lp = Players.LocalPlayer
        local my = lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not my then return end
        local gyro = my:FindFirstChild("VEIL_SpinGyro")
        if Configuration.SpinbotEnabled and not CameraAssist.Lock then
            if not gyro then
                gyro = Instance.new("BodyGyro")
                gyro.Name = "VEIL_SpinGyro" gyro.MaxTorque = Vector3.new(0, 10e20, 0)
                gyro.P = 1e6 gyro.D = 1e5 gyro.Parent = my
                gyro.CFrame = my.CFrame
            end
            gyro.CFrame = gyro.CFrame * CFrame.Angles(0, math.rad(25), 0)
        elseif gyro then gyro:Destroy() end
    end)
    local infJumpStamp = 0
    Connections.Track(UIS.JumpRequest:Connect(function() infJumpStamp = tick() end))
    Reg("infjump", 0.05, function()
        if not Configuration.InfJumpEnabled then return end
        local lp = Players.LocalPlayer
        local hum = lp and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local held = UIS:IsKeyDown(Enum.KeyCode.Space)
        if not held and (tick() - infJumpStamp) > 0.15 then return end
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
        pcall(function() hum.Jump = true end)
    end)
    local noclipped = {}
    local noclipWasOn = false
    Reg("noclip", 0.15, function()
        local lp = Players.LocalPlayer
        local char = lp and lp.Character
        if not char then noclipped = {} noclipWasOn = false return end
        local wantNoclip = Configuration.NoclipEnabled or Configuration.FlyNoclipEnabled
        if wantNoclip then
            noclipWasOn = true
            if Configuration.FlyNoclipEnabled then Configuration.FlyEnabled = true end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and not noclipped[p] then noclipped[p] = p.CanCollide p.CanCollide = false end
            end
        elseif noclipWasOn then
            for part, state in pairs(noclipped) do pcall(function() part.CanCollide = state end) end
            noclipped = {} noclipWasOn = false
        end
    end)
    local chamsSaved = {}
    local chamsLastTool = nil
    local chamsLastColor = nil
    Reg("chams", 0.08, function()
        local lp = Players.LocalPlayer
        local char = lp and lp.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if not Configuration.ViewmodelChamsEnabled then
            if chamsLastTool then
                for part, data in pairs(chamsSaved) do pcall(function() part.Material = data.m part.Color = data.c end) end
                chamsSaved = {} chamsLastTool = nil chamsLastColor = nil
            end
            return
        end
        local targetColor = VEILUI.Accent
        if tool and tool ~= chamsLastTool then
            for part, data in pairs(chamsSaved) do pcall(function() part.Material = data.m part.Color = data.c end) end
            chamsSaved = {} chamsLastTool = tool chamsLastColor = targetColor
            for _, p in ipairs(tool:GetDescendants()) do
                if p:IsA("BasePart") then
                    chamsSaved[p] = { m = p.Material, c = p.Color }
                    p.Material = Enum.Material.Neon
                    p.Color = targetColor
                end
            end
        elseif tool and chamsLastColor ~= targetColor then
            chamsLastColor = targetColor
            for part, _ in pairs(chamsSaved) do
                if part.Parent then pcall(function() part.Color = targetColor end) end
            end
        end
    end)
    local skyLastState = false
    Reg("sky", 1.0, function()
        local want = Configuration.SkyChangerEnabled
        if want == skyLastState then return end
        skyLastState = want
        if want then
            if not Lighting:FindFirstChild("VEIL_Sky") then
                local sky = Instance.new("Sky")
                sky.Name = "VEIL_Sky"
                sky.SkyboxBk = "rbxassetid://159454299" sky.SkyboxDn = "rbxassetid://159454296"
                sky.SkyboxFt = "rbxassetid://159454293" sky.SkyboxLf = "rbxassetid://159454286"
                sky.SkyboxRt = "rbxassetid://159454300" sky.SkyboxUp = "rbxassetid://159454288"
                sky.Parent = Lighting
            end
        else
            local sky = Lighting:FindFirstChild("VEIL_Sky")
            if sky then sky:Destroy() end
        end
    end)
    local crossLastState = false
    Reg("crosshair", 1.0, function()
        local want = Configuration.CustomCrosshairEnabled and Configuration.IsPremium
        if want == crossLastState then return end
        crossLastState = want
        if want then
            local sg = makeScreenGui("VEIL_Crosshair", 150, true)
            if sg then
                local group = Instance.new("Frame")
                group.AnchorPoint = Vector2.new(0.5, 0.5) group.Position = UDim2.new(0.5, 0, 0.5, 0)
                group.Size = UDim2.fromOffset(24, 24) group.BackgroundTransparency = 1 group.Parent = sg
                local function arm(offx, offy, sizex, sizey)
                    local o = Instance.new("Frame")
                    o.AnchorPoint = Vector2.new(0.5, 0.5)
                    o.Position = UDim2.new(0.5, offx, 0.5, offy)
                    o.Size = UDim2.fromOffset(sizex + 2, sizey + 2)
                    o.BackgroundColor3 = Color3.fromRGB(0, 0, 0) o.BorderSizePixel = 0 o.Parent = group
                    local i = Instance.new("Frame")
                    i.AnchorPoint = Vector2.new(0.5, 0.5)
                    i.Position = UDim2.new(0.5, offx, 0.5, offy)
                    i.Size = UDim2.fromOffset(sizex, sizey)
                    i.BackgroundColor3 = Color3.fromRGB(255, 255, 255) i.BorderSizePixel = 0 i.Parent = group
                end
                arm(0, -4.5, 1, 6) arm(0, 4.5, 1, 6) arm(-4.5, 0, 6, 1) arm(4.5, 0, 6, 1)
            end
        else
            local par = safeGuiParent()
            if par then
                for _, g in ipairs(par:GetChildren()) do
                    if g.Name == "VEIL_Crosshair" then pcall(function() g:Destroy() end) end
                end
            end
        end
    end)
    Reg("espvis", 0.12, function()
        if not Configuration.ESPTargetVisEnabled then return end
        local bcm = Configuration.BoxColorMap or {}
        for _, vo in pairs(Visuals.Objects) do
            if vo.Player and vo.Character and vo.Stroke then
                local pos, part = Utility.GetHitboxPosition(vo.Character, "Head")
                if pos then
                    local vis = Utility.IsPositionVisible(pos, {vo.Character}, tostring(vo.Player.UserId), part)
                    vo.Stroke.Color = vis and Color3.fromRGB(80, 220, 130) or (bcm[Configuration.BoxColor] or Color3.fromRGB(255, 100, 60))
                end
            end
        end
    end)
    Reg("hitsounds", 0.2, function()
        if not Configuration.HitSoundsEnabled or not Configuration.IsPremium then return end
        local lk = CameraAssist.Lock
        if not lk or not lk.Player or not lk.Character then return end
        local hum = lk.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local key = "VEIL_HP_" .. tostring(lk.Player.UserId)
        local last = _G[key]
        if last and hum.Health < last then
            local soundId = (Configuration.HitSoundMap or {})[Configuration.HitSoundChoice or "Vine Boom"] or "rbxassetid://6308606116"
            pcall(function()
                local snd = Instance.new("Sound")
                snd.SoundId = soundId snd.Volume = 0.5 snd.Parent = game:GetService("SoundService")
                snd:Play()
                task.delay(2, function() pcall(function() snd:Destroy() end) end)
            end)
        end
        _G[key] = hum.Health
    end)
    Reg("hitbox", 0.4, function()
        if not Configuration.HitboxExpanderEnabled then
            local lp = Players.LocalPlayer
            if not lp then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character.Parent then
                    for _, n in ipairs({"Head","UpperTorso","LowerTorso","Torso","HumanoidRootPart"}) do
                        local part = p.Character:FindFirstChild(n)
                        if part and part:IsA("BasePart") then
                            local orig = part:GetAttribute("VEIL_OrigSize")
                            if orig and part.Size ~= orig then pcall(function() part.Size = orig end) end
                        end
                    end
                end
            end
            return
        end
        local lp = Players.LocalPlayer
        if not lp then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character.Parent then
                for _, part_name in ipairs({"Head", "UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart"}) do
                    local part = p.Character:FindFirstChild(part_name)
                    if part and part:IsA("BasePart") then
                        if not part:GetAttribute("VEIL_OrigSize") then part:SetAttribute("VEIL_OrigSize", part.Size) end
                        local orig = part:GetAttribute("VEIL_OrigSize")
                        local target = orig * (Configuration.HitboxExpanderSize or 1.5)
                        if part.Size ~= target then pcall(function() part.Size = target end) end
                    end
                end
            end
        end
    end)
    Reg("norecoil", 0.08, function()
        if not Configuration.NoRecoilEnabled then return end
        local lp = Players.LocalPlayer
        if not lp or not lp.Character then return end
        local char = lp.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if hum.CameraOffset.Magnitude > 0.001 then
            pcall(function() hum.CameraOffset = Vector3.zero end)
        end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, ch in ipairs(tool:GetChildren()) do
                if ch:IsA("NumberValue") then
                    local n = ch.Name:lower()
                    if n:find("recoil") or n:find("kick") or n:find("spread") or n:find("shake") then
                        if ch.Value ~= 0 then pcall(function() ch.Value = 0 end) end
                    end
                elseif ch:IsA("Vector3Value") then
                    local n = ch.Name:lower()
                    if n:find("recoil") or n:find("kick") or n:find("shake") then
                        if ch.Value.Magnitude > 0 then pcall(function() ch.Value = Vector3.zero end) end
                    end
                end
            end
        end
    end)
    local FlyState = { Tool = nil, WasForcing = false, StatesDisabled = false, SpeedApplied = false, PreSpeed = nil, PreJump = nil, Boost = nil }
    local FlyForward = Instance.new("BodyVelocity")
    FlyForward.Name = "VEIL_FlyBV" FlyForward.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    FlyForward.P = 10000 FlyForward.Parent = nil
    Reg("flyspeed", 0.05, function()
        local lp = Players.LocalPlayer
        if not lp then return end
        local char = lp.Character
        if not char or not char.Parent then
            FlyForward.Parent = nil FlyState.Tool = nil FlyState.WasForcing = false
            FlyState.StatesDisabled = false FlyState.SpeedApplied = false
            if FlyState.Boost then pcall(function() FlyState.Boost:Destroy() end) FlyState.Boost = nil end
            return
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then FlyForward.Parent = nil return end
        if not Configuration.FlyEnabled and not Configuration.SpeedEnabled and not FlyState.WasForcing and not FlyState.SpeedApplied and FlyForward.Parent == nil then return end
        local cur = char:FindFirstChildOfClass("Tool")
        if cur then FlyState.Tool = cur end
        local flyA = Configuration.FlyEnabled
        local spdA = Configuration.SpeedEnabled
        local forceRun = flyA or spdA
        if flyA then
            if FlyForward.Parent ~= hrp then FlyForward.Parent = hrp end
            local cam = Workspace.CurrentCamera
            local mx, my, mz = 0, 0, 0
            if DeviceInfo.isMobile then
                local mv = hum.MoveDirection
                if mv and mv.Magnitude > 0.01 then mx = mv.X my = 0 mz = mv.Z end
            else
                if UIS:IsKeyDown(Enum.KeyCode.W) then mz = mz - 1 end
                if UIS:IsKeyDown(Enum.KeyCode.S) then mz = mz + 1 end
                if UIS:IsKeyDown(Enum.KeyCode.A) then mx = mx - 1 end
                if UIS:IsKeyDown(Enum.KeyCode.D) then mx = mx + 1 end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then my = my + 1 end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then my = my - 1 end
            end
            local mv = Vector3.new(mx, my, mz)
            local base = math.clamp(Configuration.FlySpeed or 50, 10, 80)
            local sp = base
            if not DeviceInfo.isMobile and UIS:IsKeyDown(Enum.KeyCode.LeftShift) then sp = base * 2.2 end
            if cam and mv.Magnitude > 0 then
                local dir = (cam.CFrame.LookVector * -mv.Z + cam.CFrame.RightVector * mv.X + Vector3.new(0, 1, 0) * mv.Y)
                if dir.Magnitude > 0 then dir = dir.Unit end
                FlyForward.Velocity = FlyForward.Velocity:Lerp(dir * sp, 0.35)
            else
                FlyForward.Velocity = FlyForward.Velocity * 0.15
            end
        else
            if FlyForward.Parent then FlyForward.Velocity = Vector3.new(0, 0, 0) FlyForward.Parent = nil end
        end
        if spdA then
            if not FlyState.SpeedApplied then
                FlyState.PreSpeed = hum.WalkSpeed
                FlyState.PreJump = hum.JumpPower
                FlyState.SpeedApplied = true
                FlyState.Boost = Instance.new("BodyVelocity")
                FlyState.Boost.Name = "VEIL_SpeedBoost"
                FlyState.Boost.MaxForce = Vector3.new(1e5, 0, 1e5)
                FlyState.Boost.P = 1250
                FlyState.Boost.Parent = hrp
            end
            local target_ws = math.clamp(Configuration.SpeedValue or 60, 16, 500)
            pcall(function() hum.WalkSpeed = target_ws end)
            pcall(function() hum.JumpPower = math.max(hum.JumpPower, 50) end)
            if FlyState.Boost and hrp then
                local mv = hum.MoveDirection
                if mv and mv.Magnitude > 0.01 then
                    FlyState.Boost.Velocity = Vector3.new(mv.X, 0, mv.Z).Unit * (target_ws * 0.9)
                else
                    FlyState.Boost.Velocity = Vector3.new(0, 0, 0)
                end
            end
        else
            if FlyState.SpeedApplied then
                if FlyState.PreSpeed then pcall(function() hum.WalkSpeed = FlyState.PreSpeed end) end
                if FlyState.PreJump then pcall(function() hum.JumpPower = FlyState.PreJump end) end
                if FlyState.Boost then pcall(function() FlyState.Boost:Destroy() end) FlyState.Boost = nil end
                FlyState.PreSpeed = nil FlyState.PreJump = nil FlyState.SpeedApplied = false
            end
        end
        if forceRun then
            FlyState.WasForcing = true
            local st = hum:GetState()
            if st ~= Enum.HumanoidStateType.Running and st ~= Enum.HumanoidStateType.RunningNoPhysics then
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
            end
            if not FlyState.StatesDisabled then
                FlyState.StatesDisabled = true
                pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false) end)
            end
            if FlyState.Tool and FlyState.Tool.Parent ~= char and (not FlyState.Tool.Parent or FlyState.Tool.Parent == lp.Backpack) then
                pcall(function() hum:EquipTool(FlyState.Tool) end)
            end
            if FlyState.Tool and not FlyState.Tool.Parent then FlyState.Tool = nil end
        elseif FlyState.WasForcing then
            FlyState.WasForcing = false FlyState.StatesDisabled = false
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true) end)
            if FlyState.Tool and FlyState.Tool.Parent == lp.Backpack then
                pcall(function() hum:EquipTool(FlyState.Tool) end)
            end
        end
    end)
    Reg("deflectblock", 0.1, function()
        if not Configuration.AutoStopOnKatanaDeflect then return end
        local lp = Players.LocalPlayer
        if not lp then return end
        local char = lp.Character
        if not char or not char.Parent then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end
        local blk = false
        local lk = CameraAssist.Lock
        if lk and lk.Player and Utility.IsTargetDeflecting(lk.Player) then blk = true end
        if blk then
            if tool.Enabled then pcall(function() tool.Enabled = false end) end
        elseif not tool.Enabled then
            pcall(function() tool.Enabled = true end)
        end
    end)
    Connections.Track(RunService.Heartbeat:Connect(function(dt)
        if CameraAssist.ShuttingDown then return end
        local now = tick()
        for _, sys in pairs(HB) do
            if now - sys.last >= sys.rate then
                sys.last = now
                pcall(sys.fn, dt)
            end
        end
    end))
end

_G.__VEIL_last_connections = Connections
_G.__VEIL_Mobile = {
    device = DeviceInfo,
    aim = function(s) CameraAssist.KeyHeld = s and true or false end,
    toggleMenu = function() mobileToggleMenu() end,
    overlay = MobileOverlay,
}

-- ============================================================
-- Startup gate
-- ============================================================
local StartupGate = {}
StartupGate.Interval = 12 * 60 * 60
StartupGate._memLast = nil
local function sgRead()
    if ExecutorInfo.HasReadfile then
        for _, p in ipairs({"VEIL/LastStartup.txt", "VEIL_LastStartup.txt"}) do
            local ok, d = pcall(readfile, p)
            if ok and d then local n = tonumber(d) if n and n > 0 then return n end end
        end
    end
    return StartupGate._memLast
end
local function sgWrite(t)
    StartupGate._memLast = t
    if not ExecutorInfo.HasWritefile then return end
    if ExecutorInfo.HasMakeFolder then pcall(makefolder, "VEIL") end
    for _, p in ipairs({"VEIL/LastStartup.txt", "VEIL_LastStartup.txt"}) do
        if pcall(writefile, p, tostring(t)) then return end
    end
end
function StartupGate.ShouldPlay()
    local last = sgRead()
    if not last then return true end
    return (os.time() - last) >= StartupGate.Interval
end
function StartupGate.Run()
    task.defer(function()
        task.wait(0.3)
        local rev = false
        local function rv()
            if rev then return end
            rev = true
            if Interface.MainFrame then Interface.MainFrame.Visible = true end
            _G.__VEIL_StartupDone = true
            if _G.__VEIL_BindDeferred then pcall(_G.__VEIL_BindDeferred) end
        end
        if not StartupGate.ShouldPlay() then rv() return end
        sgWrite(os.time())
        local sok = pcall(showStartup, rv)
        if not sok then rv() end
        task.delay(8, rv)
    end)
end
local function scheduleDiscordPopup()
    task.spawn(function()
        local waited = 0
        while not _G.__VEIL_StartupDone and waited < 15 do task.wait(0.15) waited = waited + 0.15 end
        task.wait(0.6)
        local now = os.time()
        local last = nil
        if ExecutorInfo.HasReadfile then
            for _, p in ipairs({"VEIL/LastDiscordPopup.txt", "VEIL_LastDiscordPopup.txt"}) do
                local ok, d = pcall(readfile, p)
                if ok and d then local n = tonumber(d) if n and n > 0 then last = n break end end
            end
        end
        if last and (now - last) < 12 * 60 * 60 then return end
        if ExecutorInfo.HasWritefile then
            if ExecutorInfo.HasMakeFolder then pcall(makefolder, "VEIL") end
            for _, p in ipairs({"VEIL/LastDiscordPopup.txt", "VEIL_LastDiscordPopup.txt"}) do
                if pcall(writefile, p, tostring(now)) then break end
            end
        end
        pcall(makeDiscordPopup)
    end)
end

-- ============================================================
-- Boot
-- ============================================================
task.defer(function()
    local savedKey, savedExpiry = KeySystem.ReadSaved()
    if savedKey and savedExpiry and os.time() < savedExpiry then
        local tier, info = KeySystem.DetectTier(savedKey)
        if tier then
            Configuration.IsPremium = true
            Configuration.PremiumTier = info.name
            Configuration.PremiumExpiry = savedExpiry
            Configuration.PremiumKey = savedKey
        end
        KeySystem.Authorized = true
        pcall(initialize)
        makeWatermark()
        StartupGate.Run()
        scheduleDiscordPopup()
        pcall(Presence.Register)
        return
    end
    KeySystem.ClearSaved()
    buildKeyUI(function()
        pcall(initialize)
        makeWatermark()
        StartupGate.Run()
        scheduleDiscordPopup()
        pcall(Presence.Register)
    end)
end)

return {Configuration = Configuration, Utility = Utility, KeySystem = KeySystem}
