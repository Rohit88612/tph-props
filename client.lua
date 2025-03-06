local holdingProp = nil
local previewProp = nil
local propModel = nil
local previewOffset = vector3(0.0, 1.5, 0.0)
local previewRotation = 0.0
local isPreviewActive = false

local function updatePreviewPosition()
    if not previewProp or not isPreviewActive then return end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local forwardVector = GetEntityForwardVector(playerPed)

    -- Adjust preview position based on arrow key inputs
    if IsControlPressed(0, 172) then -- Up Arrow (Move Forward)
        previewOffset = previewOffset + forwardVector * 0.1
    elseif IsControlPressed(0, 173) then -- Down Arrow (Move Backward)
        previewOffset = previewOffset - forwardVector * 0.1
    end

    if IsControlPressed(0, 174) then -- Left Arrow (Move Left)
        previewOffset = previewOffset + vector3(-forwardVector.y, forwardVector.x, 0) * 0.1
    elseif IsControlPressed(0, 175) then -- Right Arrow (Move Right)
        previewOffset = previewOffset + vector3(forwardVector.y, -forwardVector.x, 0) * 0.1
    end

    if IsControlPressed(0, 44) then -- Q (Rotate Left)
        previewRotation = previewRotation - 2.0
    elseif IsControlPressed(0, 38) then -- E (Rotate Right)
        previewRotation = previewRotation + 2.0
    end

    -- Update preview position
    local newPos = playerCoords + previewOffset
    local _, groundZ = GetGroundZFor_3dCoord(newPos.x, newPos.y, newPos.z, false)
    SetEntityCoords(previewProp, newPos.x, newPos.y, groundZ + 0.2)
    SetEntityHeading(previewProp, previewRotation)
end

local function showPreview()
    if previewProp then
        DeleteEntity(previewProp)
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local forwardVector = GetEntityForwardVector(playerPed)
    local previewPosition = playerCoords + forwardVector * previewOffset.y

    local _, groundZ = GetGroundZFor_3dCoord(previewPosition.x, previewPosition.y, previewPosition.z, false)
    previewPosition = vector3(previewPosition.x, previewPosition.y, groundZ + 0.2)

    previewProp = CreateObject(propModel, previewPosition.x, previewPosition.y, previewPosition.z, false, false, false)
    SetEntityHeading(previewProp, previewRotation)
    FreezeEntityPosition(previewProp, true)
    SetEntityAlpha(previewProp, 150, false)
    SetEntityCollision(previewProp, false, false) -- No collision

    isPreviewActive = true

    -- Keep updating preview position in a loop
    Citizen.CreateThread(function()
        while isPreviewActive do
            updatePreviewPosition()
            Wait(50)
        end
    end)
end
