-- Dump the Suite window's frame tree as JSON lines for render.py.
local W = __W
local ids = {}
for i, o in ipairs(W.all) do ids[o] = i end
local function enc(v)
  local t = type(v)
  if t == "nil" then return "null" elseif t == "boolean" then return tostring(v)
  elseif t == "number" then if v ~= v or v == math.huge or v == -math.huge then return "0" end; return string.format("%.4f", v)
  elseif t == "string" then return '"' .. v:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('[%c]', '') .. '"'
  elseif t == "table" then
    if rawget(v, "_kind") then return tostring(ids[v] or 0) end
    local parts, isArr = {}, (#v > 0)
    if isArr then for _, x in ipairs(v) do parts[#parts + 1] = enc(x) end; return "[" .. table.concat(parts, ",") .. "]" end
    for k, x in pairs(v) do parts[#parts + 1] = enc(tostring(k)) .. ":" .. enc(x) end
    return "{" .. table.concat(parts, ",") .. "}"
  end
  return "null"
end
function __DUMP(root, path)
  for k in pairs(ids) do ids[k] = nil end
  for i, o in ipairs(W.all) do ids[o] = i end
  local out = io.open(path, "w")
  local stack = { root }
  local seen = {}
  while #stack > 0 do
    local o = table.remove(stack)
    if not seen[o] then
      seen[o] = true
      local rec = {
        id = ids[o], parent = rawget(o, "_parent") and ids[o._parent] or 0, kind = o._kind, shown = o._shown,
        alpha = o._alpha, scale = o._scale, w = o._w, h = o._h, level = o._level, layer = rawget(o, "_layer"),
        sub = rawget(o, "_sub"), points = {}, fill = rawget(o, "_fill"), tex = rawget(o, "_tex"), vc = rawget(o, "_vc"),
        tc = rawget(o, "_tc"), rot = rawget(o, "_rot"), grad = rawget(o, "_grad"), text = o._text, font = rawget(o, "_font"),
        tcolor = rawget(o, "_tcolor"), jh = rawget(o, "_jh"), vscroll = o._vscroll,
        child = rawget(o, "_child") and ids[o._child] or nil, insets = rawget(o, "_insets"),
      }
      for _, p in ipairs(rawget(o, "_points") or {}) do
        rec.points[#rec.points + 1] = { p[1], (p[2] and ids[p[2]]) or 0, p[3], p[4] or 0, p[5] or 0 }
      end
      if #rec.points == 0 then rec.points = nil end
      out:write(enc(rec), "\n")
      for _, ch in ipairs(rawget(o, "_children") or {}) do stack[#stack + 1] = ch end
    end
  end
  out:write('{"root":' .. ids[root] .. '}\n')
  out:close()
end
