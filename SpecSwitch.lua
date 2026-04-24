local ADDON = "SpecSwitch"

local GetSpecialization = GetSpecialization or (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization)
local SetSpecialization = SetSpecialization or (C_SpecializationInfo and C_SpecializationInfo.SetSpecialization)
local GetNumSpecializations = GetNumSpecializations or (C_SpecializationInfo and C_SpecializationInfo.GetNumSpecializations)
local GetSpecializationInfo = GetSpecializationInfo or (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo)

local function GetInitials(name)
    local t = {}
    for word in name:gmatch("%S+") do
        t[#t + 1] = word:sub(1, 1):lower()
    end
    return table.concat(t)
end

local function MatchSpecs(input, specs)
    local seen = {}
    local results = {}
    for _, s in ipairs(specs) do
        if not seen[s.index]
            and (s.lower:find(input, 1, true) == 1
                or s.compressed:find(input, 1, true) == 1
                or s.initials:find(input, 1, true) == 1) then
            seen[s.index] = true
            results[#results + 1] = s
        end
    end
    return results
end

local function FindSpec(raw)
    raw = strtrim(raw)
    if raw == "" then
        return nil, "Usage: /spec <spec name>"
    end
    local input = raw:lower()

    local numSpecs = GetNumSpecializations()
    if numSpecs == 0 then
        return nil, "No specializations available"
    end

    local specs = {}
    for i = 1, numSpecs do
        local _, name = GetSpecializationInfo(i)
        local lower = name:lower()
        specs[i] = {
            index = i,
            name = name,
            lower = lower,
            compressed = lower:gsub("%s+", ""),
            initials = GetInitials(name),
        }
    end

    for _, s in ipairs(specs) do
        if s.lower == input or s.compressed == input then
            return s
        end
    end

    local matches = MatchSpecs(input, specs)
    if #matches == 1 then
        return matches[1]
    end
    if #matches > 1 then
        local names = {}
        for _, s in ipairs(matches) do
            names[#names + 1] = s.name
        end
        return nil, "Ambiguous — matches: " .. table.concat(names, ", ")
    end

    return nil, "No spec matching \"" .. raw .. "\""
end

local function Handler(input)
    local spec, err = FindSpec(input)
    if not spec then
        print("|cFFFFD100" .. ADDON .. ":|r " .. err)
        return
    end
    if GetSpecialization() == spec.index then
        print("|cFFFFD100" .. ADDON .. ":|r Already " .. spec.name)
        return
    end
    SetSpecialization(spec.index)
    print("|cFFFFD100" .. ADDON .. ":|r Switching to " .. spec.name)
end

SLASH_SPECSWITCH1 = "/spec"
SlashCmdList["SPECSWITCH"] = Handler
