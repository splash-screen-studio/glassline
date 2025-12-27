--!strict
--[[
    Network/Validators.luau
    Input validation for network requests
]]

local VERSION = "1.0.0"

local Validators = {}

-- Mount request validation
export type MountRequestData = {
    vehicleId: string,
}

function Validators.validateMountRequest(data: any): (boolean, MountRequestData?)
    if type(data) ~= "table" then
        return false, nil
    end

    if type(data.vehicleId) ~= "string" then
        return false, nil
    end

    -- Sanitize vehicle ID (alphanumeric + underscore only)
    local sanitized = data.vehicleId:match("^[%w_]+$")
    if not sanitized then
        return false, nil
    end

    return true, {
        vehicleId = sanitized,
    }
end

-- Generic string validation
function Validators.validateString(value: any, maxLength: number?): (boolean, string?)
    if type(value) ~= "string" then
        return false, nil
    end

    local max = maxLength or 256
    if #value > max then
        return false, nil
    end

    return true, value
end

-- Generic number validation
function Validators.validateNumber(value: any, min: number?, max: number?): (boolean, number?)
    if type(value) ~= "number" then
        return false, nil
    end

    if value ~= value then -- NaN check
        return false, nil
    end

    if min and value < min then
        return false, nil
    end

    if max and value > max then
        return false, nil
    end

    return true, value
end

-- Vector3 validation
function Validators.validateVector3(value: any): (boolean, Vector3?)
    if typeof(value) ~= "Vector3" then
        return false, nil
    end

    -- Check for NaN
    if value.X ~= value.X or value.Y ~= value.Y or value.Z ~= value.Z then
        return false, nil
    end

    return true, value
end

print("[Validators v" .. VERSION .. "] Loaded")

return Validators
