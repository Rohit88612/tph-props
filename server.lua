RegisterNetEvent("blrp:pickupProp")
AddEventHandler("blrp:pickupProp", function(netId)
    local object = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(object) then
        DeleteEntity(object)
    end
end)

RegisterNetEvent("blrp:placeProp")
AddEventHandler("blrp:placeProp", function(model, coords, heading)
    local prop = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    SetEntityHeading(prop, heading)
    FreezeEntityPosition(prop, false)
    SetEntityCollision(prop, true, true)
    SetEntityDynamic(prop, true)
end)
