local VorpCore = exports.vorp_core:GetCore()

CreateThread(function()
    if VorpCore.RegisterJobs then
       if Config.joblocked then
          local jobs <const> = {}
            for _, job in ipairs(Config.Butchers) do
                if job.butcherjob and job.butcherjob ~= "" then
                    jobs[job.butcherjob] = {}
                end
            end

            if next(jobs) then
                VorpCore.RegisterJobs(jobs, GetCurrentResourceName())
            end
       end
    end
end)

local function giveReward(context, data, skipfinal)
    local _source = source
    local Character = VorpCore.getUser(_source).getUsedCharacter

    -- Seguridad por job
    if Config.joblocked then
        for _, value in ipairs(Config.Butchers) do
            if Character.job == value.butcherjob then
                TriggerClientEvent("rs_hunting:lock", _source)
                VorpCore.NotifyObjective(_source, "is job locked", 4000)
                return
            end
        end
    end

    local money, gold = 0, 0
    local animal, found
    local itemsToGive = {}

    if context == "skinned" then
        animal = Config.SkinnableAnimals[data.model]
        if animal then
            found = true

            itemsToGive = animal.items or {}

            money     = animal.money      or 0
            gold      = animal.gold       or 0
        end

    elseif context == "pelt" then
        animal = Config.Animals[data.model]
        if animal then
            found = true

            gold      = animal.gold      or 0

            if data.quality == animal.perfect then
                money = animal.peltMoneyPerfect or 0
            elseif data.quality == animal.good then
                money = animal.peltMoneyGood or 0
            elseif data.quality == animal.poor then
                money = animal.peltMoneyPoor or 0
            else
                money = animal.peltMoneyPoor or 0
            end
        end

    elseif context == "carcass" then
        animal = Config.Animals[data.model]
        if animal then
            found = true

            money     = animal.carcassMoney or 0
            gold      = animal.gold         or 0
        end

    elseif context == "skinnedcarcass" then
        animal = Config.Animals[data.model]
        if animal then
            found = true

            money     = animal.skinnedBodyMoney or 0
            gold      = animal.gold             or 0
        end
    end

    if found then
        local monies = {}
        local moneylinux = (math.floor(money * 100) / 100)

        if money ~= 0 then
            local displayMoney = Config.Linux and moneylinux or money
            table.insert(monies, Config.Language.dollar .. displayMoney)
            Character.addCurrency(0, money)
        end

        if gold ~= 0 then
            table.insert(monies, gold .. " gold")
            Character.addCurrency(1, gold)
        end

        if #monies > 0 then
            VorpCore.NotifyObjective(_source, Config.Language.AnimalSold .. table.concat(monies, ", "), 4000)
        end

        if not skipfinal then
            local entity1 = NetworkGetEntityFromNetworkId(data.netid)
            DeleteEntity(entity1)
            TriggerClientEvent("rs_hunting:finalizeReward", _source, data.entity, data.horse)
        end

        if #itemsToGive > 0 then
            local givenMsg = Config.Language.SkinnableAnimalstowed

            for _, entry in ipairs(itemsToGive) do
                local item = entry.item
                local qty  = entry.quantity or 1
                local label = entry.label or item

                if not exports.vorp_inventory:canCarryItem(_source, item, qty) then
                    VorpCore.NotifyObjective(_source, Config.Language.FullInventory, 4000)
                    TriggerClientEvent("rs_hunting:unlock", _source)
                    return
                end

                exports.vorp_inventory:addItem(_source, item, qty)
                givenMsg = givenMsg .. Config.Language.join .. label
            end

            local dict = animal.type or "satchel_textures"
            local icon = animal.texture or ""

            VorpCore.NotifyLeftRank(_source, Config.Language.action, givenMsg, dict, icon, 5000, "COLOR_WHITE")
        end
    end

    TriggerClientEvent("rs_hunting:unlock", _source)
end

RegisterServerEvent("rs_hunting:giveReward", giveReward)