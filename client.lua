local holdingProp = nil
local previewProp = nil
local propModel = nil
local previewOffset = vector3(0.0, 1.5, 0.0)
local previewRotation = 0.0

local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

local function disableActions()
    Citizen.CreateThread(function()
        while holdingProp do
            DisableControlAction(0, 140, true) -- Disable melee attack
            DisableControlAction(0, 141, true) -- Disable melee heavy attack
            DisableControlAction(0, 142, true) -- Disable alternative melee attack
            Wait(0)
        end
    end)
end

local function getClosestProp()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local handle, object = FindFirstObject()
    local success
    local closestObject = nil
    local closestDistance = 2.0

    repeat
        local objCoords = GetEntityCoords(object)
        local distance = #(playerCoords - objCoords)
        if distance < closestDistance and not IsPedAPlayer(object) then
            closestObject = object
            closestDistance = distance
        end
        success, object = FindNextObject(handle)
    until not success
    EndFindObject(handle)

    return closestObject
end

local function showPreview()
    if previewProp then
        DeleteEntity(previewProp)
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed) + GetEntityForwardVector(playerPed) * previewOffset.y
    local _, groundZ = GetGroundZFor_3dCoord(playerCoords.x, playerCoords.y, playerCoords.z, false)
    playerCoords = vector3(playerCoords.x, playerCoords.y, groundZ + previewOffset.z)
    
    previewProp = CreateObject(propModel, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false)
    SetEntityHeading(previewProp, previewRotation)
    FreezeEntityPosition(previewProp, true)
    SetEntityAlpha(previewProp, 150, false)

    Citizen.CreateThread(function()
        while previewProp do
            local playerCoords = GetEntityCoords(playerPed) + GetEntityForwardVector(playerPed) * previewOffset.y
            local _, groundZ = GetGroundZFor_3dCoord(playerCoords.x, playerCoords.y, playerCoords.z, false)
            playerCoords = vector3(playerCoords.x, playerCoords.y, groundZ + previewOffset.z)
            
            SetEntityCoords(previewProp, playerCoords.x, playerCoords.y, playerCoords.z)
            SetEntityHeading(previewProp, previewRotation)
            Wait(0)
        end
    end)
end

local function pickupProp()
    local playerPed = PlayerPedId()
    local object = getClosestProp()
    
    if object and DoesEntityExist(object) then
        propModel = GetEntityModel(object)
        loadAnimDict("anim@heists@narcotics@trash")
        TaskPlayAnim(playerPed, "anim@heists@narcotics@trash", "idle", 8.0, -8.0, -1, 49, 0, false, false, false)
        
        SetEntityAsMissionEntity(object, true, true)
        DeleteEntity(object) -- Remove the original object
        
        holdingProp = CreateObject(propModel, 0, 0, 0, true, true, true)
        AttachEntityToEntity(holdingProp, playerPed, GetPedBoneIndex(playerPed, 57005), 0.2, -0.15, -0.1, 0.0, 90.0, 0.0, true, true, false, true, 1, true)
        disableActions()
        showPreview()
    end
end

local function placeProp()
    if holdingProp then
        local playerPed = PlayerPedId()
        TaskPlayAnim(playerPed, "anim@heists@narcotics@trash", "throw_b", 8.0, -8.0, 1000, 16, 0, false, false, false)
        Wait(600)
        
        DeleteEntity(holdingProp)
        holdingProp = nil
        
        local finalCoords = GetEntityCoords(playerPed) + GetEntityForwardVector(playerPed) * previewOffset.y
        local _, groundZ = GetGroundZFor_3dCoord(finalCoords.x, finalCoords.y, finalCoords.z, false)
        finalCoords = vector3(finalCoords.x, finalCoords.y, groundZ + 0.2)
        
        -- Spawn the new prop with correct properties
        local placedProp = CreateObject(propModel, finalCoords.x, finalCoords.y, finalCoords.z, true, true, false)
        SetEntityHeading(placedProp, previewRotation)

        -- Enable physics and gravity
        SetEntityCollision(placedProp, true, true)
        SetEntityDynamic(placedProp, true)
        ActivatePhysics(placedProp)
        SetEntityHasGravity(placedProp, true)

        -- If it's a heavy prop, make sure it's treated as su
        if previewProp then
            DeleteEntity(previewProp)
            previewProp = nil
        end
        
        ClearPedTasks(playerPed)
    end
end

Citizen.CreateThread(function()
    while true do
        if previewProp then
            -- Arrow key movement for preview prop
            if IsControlPressed(0, 172) then -- Up Arrow
                previewOffset = previewOffset + vector3(0.0, 0.02, 0.0)
            end
            if IsControlPressed(0, 173) then -- Down Arrow
                previewOffset = previewOffset - vector3(0.0, 0.02, 0.0)
            end
            if IsControlPressed(0, 174) then -- Left Arrow
                previewOffset = previewOffset - vector3(0.02, 0.0, 0.0)
            end
            if IsControlPressed(0, 175) then -- Right Arrow
                previewOffset = previewOffset + vector3(0.02, 0.0, 0.0)
            end
            if IsControlPressed(0, 44) then -- Q Key (Rotate Left)
                previewRotation = previewRotation - 1.0
            end
            if IsControlPressed(0, 51) then -- E Key (Rotate Right)
                previewRotation = previewRotation + 1.0
            end
        end
        Wait(0)
    end
end)

RegisterCommand("pickup_prop", function()
    pickupProp()
end, false)

RegisterCommand("place_prop", function()
    placeProp()
end, false)
