lib.locale()

RegisterNetEvent('fivemBuisnessCard:server:GetCards')
AddEventHandler('fivemBuisnessCard:server:GetCards', function(frontImage, backImage, amount)
    local item = 'money'
    local cost = Config.Item.price * amount

    local moneyItem = exports.ox_inventory:GetItem(source, item)

    if not (moneyItem and moneyItem.count >= cost) then
        lib.notify(source, {
            title = locale('not_enough_money'),
            description = string.format(locale('not_enough_money_description'), amount),
            type = 'error',
        })
        return
    end

    exports.ox_inventory:RemoveItem(source, item, cost)

    local metadata = {
        frontImage = frontImage,
        backImage = backImage,
    }

    local success, response = exports.ox_inventory:AddItem(source, Config.Item.name, amount, metadata, nil)
    if success then
        local slot = exports.ox_inventory:GetSlotForItem(source, Config.Item.name, nil)
        exports.ox_inventory:SetMetadata(source, slot, metadata)
        lib.notify(source, {
            title = string.format(locale('order_success'), amount, cost),
            type = 'success',
        })
    else
        print('Failed to add item. Response: ' .. response)
    end
end)