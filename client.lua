lib.locale()

local showCard = function(front, back)
    SendNUIMessage({
        action = 'show',
        frontImage = front,
        backImage = back
    })
    SetNuiFocus(true, true)
end

exports('businesscard', function(data, slot)
    if slot.metadata then
        local frontImage = slot.metadata.frontImage
        local backImage = slot.metadata.backImage
        showCard(frontImage, backImage)
    end
end)

RegisterNetEvent('fivemBuisnessCard:client:ShowCard')
AddEventHandler('fivemBuisnessCard:client:ShowCard', function(data)
    showCard(data.frontImage, data.backImage)
end)


local openBuisnessCardMenu = function()
    local input = lib.inputDialog(string.format(locale('order_business_card_title'), Config.Item.price), { 
        { type = 'input', label = locale('front'), description = locale('front_image_description'), required = true, min = 1, max = 100 },
        { type = 'input', label = locale('back'), description = locale('back_image_description'), required = true, min = 1, max = 100 },
        { type = 'number', label = locale('number_of_cards'), description = locale('card_quantity_description'), icon = 'address-card' },
        { type = 'input', label = locale('card_item_label'), description = locale('card_item_label_description'), required = false, min = 1, max = 100 },
    })
    
    if input then
        local frontImage = input[1]
        local backImage = input[2]
        local amount = input[3] and tonumber(input[3]) or 1
    
        --if not string.match(frontImage, 'r2.fivemanage.com') or not string.match(backImage, 'r2.fivemanage.com') then
        --    lib.notify({
        --        title = locale('image_url_error'),
        --        type = 'error',
        --    })
        --    return
        --end
        TriggerServerEvent('fivemBuisnessCard:server:GetCards', frontImage, backImage, amount)
    end
end

local zone = lib.points.new({
    coords = Config.Ped.PedCoords,
    distance = 5.0,
    ped = nil
})

function zone:onEnter()
    self.ped = CreatePed(4, lib.requestModel(Config.Ped.PedModel), Config.Ped.PedCoords.x, Config.Ped.PedCoords.y, Config.Ped.PedCoords.z - 1, Config.Ped.PedHeading, false, true)
    SetEntityAsMissionEntity(self.ped, true, true)
    SetEntityInvincible(self.ped, true)
    FreezeEntityPosition(self.ped, true)
    SetBlockingOfNonTemporaryEvents(self.ped, true)
end

function zone:onExit()
    if DoesEntityExist(self.ped) then
        SetModelAsNoLongerNeeded(Config.Ped.PedModel)
        SetEntityAsNoLongerNeeded(self.ped)
        DeletePed(self.ped)
        self.ped = nil
    end
end

function zone:nearby()
    local isOpen, text = lib.isTextUIOpen()
    if self.currentDistance < 1 and (isOpen == false or text ~= locale('order_business_card')) then
        lib.showTextUI(locale('order_business_card'), {
            icon = 'fa-solid fa-address-card',
            position = 'top-right',
        })
    end
    if self.currentDistance < 1 and IsControlJustReleased(0, 38) then
        openBuisnessCardMenu()
    end
    if self.currentDistance >= 2 then
        lib.hideTextUI()
    end
end

RegisterNUICallback('close', function(data, cb)
    SendNUIMessage({
        action = 'hide'
    })
    SetNuiFocus(false, false)
    cb('ok')
end)