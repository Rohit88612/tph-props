RegisterNetEvent("tph-props:spawnProp")
AddEventHandler("tph-props:spawnProp", function(model, coords, heading)
    local src = source
    local prop = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    SetEntityHeading(prop, heading)
    FreezeEntityPosition(prop, false)
    SetEntityCollision(prop, true, true)
    SetEntityDynamic(prop, true)
end)
