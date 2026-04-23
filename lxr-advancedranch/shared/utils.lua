--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 lxr-advancedranch — The Land of Wolves — Shared Utilities
     ═══════════════════════════════════════════════════════════════════════════
     Developer   : iBoss21 | Brand : The Lux Empire
     https://www.wolves.land | https://discord.gg/CrKcWdfd3A
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / The Lux Empire — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRUtils = LXRUtils or {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔧 ID GENERATION
-- ═══════════════════════════════════════════════════════════════════════════════

local ID_CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'

function LXRUtils.GenId(prefix, len)
    prefix = prefix or 'id'
    len = len or 10
    local out = {}
    for i = 1, len do
        local n = math.random(1, #ID_CHARS)
        out[i] = ID_CHARS:sub(n, n)
    end
    return prefix .. '_' .. table.concat(out)
end

function LXRUtils.Uuid()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔧 TABLE HELPERS
-- ═══════════════════════════════════════════════════════════════════════════════

function LXRUtils.DeepCopy(t)
    if type(t) ~= 'table' then return t end
    local out = {}
    for k, v in pairs(t) do out[k] = LXRUtils.DeepCopy(v) end
    return out
end

function LXRUtils.Keys(t)
    local out = {}
    for k in pairs(t or {}) do out[#out + 1] = k end
    return out
end

function LXRUtils.Count(t)
    local n = 0
    for _ in pairs(t or {}) do n = n + 1 end
    return n
end

function LXRUtils.Merge(a, b)
    local out = LXRUtils.DeepCopy(a or {})
    for k, v in pairs(b or {}) do
        if type(v) == 'table' and type(out[k]) == 'table' then
            out[k] = LXRUtils.Merge(out[k], v)
        else
            out[k] = v
        end
    end
    return out
end

function LXRUtils.HasValue(t, value)
    for _, v in pairs(t or {}) do if v == value then return true end end
    return false
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔧 MATH & RANDOM
-- ═══════════════════════════════════════════════════════════════════════════════

function LXRUtils.Clamp(n, lo, hi)
    if n < lo then return lo end
    if n > hi then return hi end
    return n
end

function LXRUtils.Rand(a, b)
    if not b then return math.random(a) end
    return math.random(a, b)
end

function LXRUtils.RandFloat(a, b)
    return a + math.random() * (b - a)
end

function LXRUtils.Chance(p)
    return math.random() < (p or 0)
end

function LXRUtils.Pick(t)
    if not t or #t == 0 then return nil end
    return t[math.random(1, #t)]
end

function LXRUtils.WeightedPick(weightMap)
    local total = 0
    for _, w in pairs(weightMap) do total = total + w end
    if total <= 0 then return nil end
    local r = math.random() * total
    local acc = 0
    for k, w in pairs(weightMap) do
        acc = acc + w
        if r <= acc then return k end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔧 TIME HELPERS
-- ═══════════════════════════════════════════════════════════════════════════════

function LXRUtils.Now()
    return os.time()
end

function LXRUtils.NowMs()
    return GetGameTimer()
end

function LXRUtils.HoursBetween(a, b)
    return math.floor((b - a) / 3600)
end

function LXRUtils.DaysBetween(a, b)
    return math.floor((b - a) / 86400)
end

function LXRUtils.FormatDuration(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then return ('%dh %dm'):format(h, m) end
    if m > 0 then return ('%dm %ds'):format(m, s) end
    return ('%ds'):format(s)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔧 STRING HELPERS
-- ═══════════════════════════════════════════════════════════════════════════════

function LXRUtils.Trim(s)
    if type(s) ~= 'string' then return s end
    return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

function LXRUtils.StartsWith(s, prefix)
    return type(s) == 'string' and s:sub(1, #prefix) == prefix
end

function LXRUtils.SafeString(s, maxLen)
    if type(s) ~= 'string' then return '' end
    s = s:gsub('[^%w%s%-%_%.%,%!%?%:]', '')
    if maxLen and #s > maxLen then s = s:sub(1, maxLen) end
    return s
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔧 GEOMETRY
-- ═══════════════════════════════════════════════════════════════════════════════

function LXRUtils.Distance2D(ax, ay, bx, by)
    local dx, dy = ax - bx, ay - by
    return math.sqrt(dx * dx + dy * dy)
end

function LXRUtils.Distance3D(ax, ay, az, bx, by, bz)
    local dx, dy, dz = ax - bx, ay - by, az - bz
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function LXRUtils.PointInPoly(px, py, poly)
    -- Ray casting
    local inside = false
    local n = #poly
    local j = n
    for i = 1, n do
        local pi, pj = poly[i], poly[j]
        if ((pi.y > py) ~= (pj.y > py)) and
           (px < (pj.x - pi.x) * (py - pi.y) / (pj.y - pi.y + 1e-10) + pi.x) then
            inside = not inside
        end
        j = i
    end
    return inside
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔧 RATE LIMITER
-- ═══════════════════════════════════════════════════════════════════════════════

local rateBuckets = {}

function LXRUtils.RateLimit(key, maxPerWindow, windowMs)
    windowMs = windowMs or 60000
    local now = GetGameTimer()
    local bucket = rateBuckets[key]
    if not bucket or (now - bucket.start) > windowMs then
        rateBuckets[key] = { start = now, count = 1 }
        return true
    end
    if bucket.count >= maxPerWindow then return false end
    bucket.count = bucket.count + 1
    return true
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ═══════════════════════════════════════════════════════════════════════════════
