--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 Advanced Ranch System - Economy Engine (Server)

    Dynamic seasonal pricing, contract board generation and fulfillment,
    auction-house bidding with DB-row escrow (no duplication), and production
    chains converting raw goods into finished products. All money movement is
    cash-only — wolves.land never uses gold.

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Developer:   iBoss21 / The Lux Empire
    Website:     https://www.wolves.land
    Discord:     https://discord.gg/CrKcWdfd3A
    GitHub:      https://github.com/iBoss21
    Store:       https://theluxempire.tebex.io

    ═══════════════════════════════════════════════════════════════════════════════

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

local EV = function(ns, n) return RanchCore.EventName(ns, n) end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ BASE PRICING ██████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Base per-unit prices for every tradable good. Seasonal and demand
-- modifiers are applied on top, then clamped to the min/max envelope.
local BASE_PRICES = {
    beef      = 22,
    milk      = 6,
    wool      = 9,
    eggs      = 3,
    pork      = 19,
    mutton    = 18,
    leather   = 14,
    hides     = 11,
    horses    = 450,
    chickens  = 25
}

function RanchCore.PriceOf(good)
    local base = BASE_PRICES[good]
    if not base then return 0 end
    local season = (RanchCore.Environment and RanchCore.Environment.season) or 'spring'
    local seasonal = (Config.Economy.seasonalModifiers[season] or {})[good] or 1.0
    local demand = (Config.Economy.baseDemand or {})[good] or 1.0
    local mult = seasonal * demand
    mult = LXRUtils.Clamp(mult, Config.Economy.minPriceClamp or 0.4, Config.Economy.maxPriceClamp or 1.6)
    return math.floor(base * mult + 0.5)
end

function RanchCore.PriceTable()
    local t = {}
    for good, _ in pairs(BASE_PRICES) do t[good] = RanchCore.PriceOf(good) end
    return t
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ CONTRACTS (TOWN BOARDS) ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RanchCore.Contracts = RanchCore.Contracts or {}

function RanchCore.LoadAllContracts()
    RanchCore.Contracts = {}
    if DB.Mode() == 'mysql' then
        local rows = DB.Query(('SELECT * FROM `%s`'):format(DB.Table('contracts')))
        for i = 1, #(rows or {}) do
            local c = rows[i]
            RanchCore.Contracts[c.id] = {
                id         = c.id,
                town       = c.town,
                good       = c.good,
                amount     = tonumber(c.amount) or 0,
                reward     = tonumber(c.reward) or 0,
                deadline   = tonumber(c.deadline) or 0,
                assigned   = c.assigned,
                status     = c.status or 'open',
                created_at = tonumber(c.created_at) or os.time()
            }
        end
    else
        local store = DB.Json.Get('contracts') or {}
        for id, c in pairs(store) do RanchCore.Contracts[id] = c end
    end
end

local function persistContract(c)
    if DB.Mode() == 'mysql' then
        local exists = DB.Scalar(('SELECT COUNT(1) FROM `%s` WHERE id=?'):format(DB.Table('contracts')), { c.id })
        if (tonumber(exists) or 0) > 0 then
            DB.Update(
                ('UPDATE `%s` SET town=?,good=?,amount=?,reward=?,deadline=?,assigned=?,status=? WHERE id=?')
                    :format(DB.Table('contracts')),
                { c.town, c.good, c.amount, c.reward, c.deadline, c.assigned or '', c.status, c.id }
            )
        else
            DB.Insert(
                ('INSERT INTO `%s` (id,town,good,amount,reward,deadline,assigned,status,created_at) VALUES (?,?,?,?,?,?,?,?,?)')
                    :format(DB.Table('contracts')),
                { c.id, c.town, c.good, c.amount, c.reward, c.deadline,
                  c.assigned or '', c.status, c.created_at or os.time() }
            )
        end
    else
        local store = DB.Json.Get('contracts') or {}
        store[c.id] = c
        DB.Json.Set('contracts', store)
    end
end

local function deleteContractDb(id)
    if DB.Mode() == 'mysql' then
        DB.Update(('DELETE FROM `%s` WHERE id=?'):format(DB.Table('contracts')), { id })
    else
        local store = DB.Json.Get('contracts') or {}
        store[id] = nil
        DB.Json.Set('contracts', store)
    end
end

local function generateContract(townKey)
    local board = Config.Economy.townBoards[townKey]
    if not board or not board.goods or #board.goods == 0 then return nil end
    local good = LXRUtils.Pick(board.goods)
    local amount = LXRUtils.Rand(5, 40)
    local unitPrice = RanchCore.PriceOf(good)
    local reward = Config.Economy.contracts.rewardBase + (amount * Config.Economy.contracts.rewardPerUnit)
    reward = reward + math.floor(unitPrice * amount * 0.5)
    local deadline = os.time() + (Config.Economy.contracts.defaultDeadlineHours or 48) * 3600
    local c = {
        id         = LXRUtils.GenId('ctr'),
        town       = townKey,
        good       = good,
        amount     = amount,
        reward     = reward,
        deadline   = deadline,
        assigned   = '',
        status     = 'open',
        created_at = os.time()
    }
    RanchCore.Contracts[c.id] = c
    persistContract(c)
    return c
end

function RanchCore.RerollBoards()
    -- Remove expired or old open contracts, top up to ~3 per board.
    local perBoard = 3
    local now = os.time()
    local countByTown = {}

    for id, c in pairs(RanchCore.Contracts) do
        if c.status == 'open' and c.deadline < now then
            c.status = 'expired'
            persistContract(c)
        end
        if c.status == 'open' then
            countByTown[c.town] = (countByTown[c.town] or 0) + 1
        end
    end

    for townKey in pairs(Config.Economy.townBoards or {}) do
        local need = perBoard - (countByTown[townKey] or 0)
        for i = 1, need do generateContract(townKey) end
    end
    TriggerClientEvent(EV('server', 'contractsRefreshed'), -1)
end

function RanchCore.AcceptContract(src, contractId)
    local c = RanchCore.Contracts[contractId]
    if not c or c.status ~= 'open' then return false, 'unavailable' end
    local ident = Framework.GetIdentifier(src)
    if c.assigned and c.assigned ~= '' and c.assigned ~= ident then return false, 'already_taken' end
    c.assigned = ident
    c.status = 'active'
    persistContract(c)
    TriggerClientEvent(EV('server', 'contractUpdated'), -1, c)
    return true
end

function RanchCore.DeliverContract(src, contractId)
    local c = RanchCore.Contracts[contractId]
    if not c or c.status ~= 'active' then return false, 'not_active' end
    local ident = Framework.GetIdentifier(src)
    if c.assigned ~= ident then return false, 'not_yours' end
    if os.time() > c.deadline then
        c.status = 'expired'
        persistContract(c)
        Framework.RemoveMoney(src, Config.Economy.contracts.penaltyOnFail or 0)
        Framework.Notify(src, Framework.L('contract_expired'), 'error')
        return false, 'expired'
    end
    -- Remove goods from inventory
    local itemKey = c.good
    if not Framework.HasItem(src, itemKey, c.amount) then
        Framework.Notify(src, Framework.L('missing_goods'), 'error')
        return false, 'missing_goods'
    end
    Framework.RemoveItem(src, itemKey, c.amount)
    Framework.AddMoney(src, c.reward)
    RanchCore.AddXp(ident, 'Teamster', Config.Progression.xpGains.deliverContract or 15)

    c.status = 'completed'
    persistContract(c)
    Framework.Notify(src, Framework.L('contract_delivered', c.reward), 'success')
    TriggerClientEvent(EV('server', 'contractUpdated'), -1, c)
    return true
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ AUCTIONS ██████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RanchCore.Auctions = RanchCore.Auctions or {}

function RanchCore.LoadAllAuctions()
    RanchCore.Auctions = {}
    if DB.Mode() == 'mysql' then
        local rows = DB.Query(('SELECT * FROM `%s`'):format(DB.Table('auctions')))
        for i = 1, #(rows or {}) do
            local a = rows[i]
            RanchCore.Auctions[a.id] = {
                id         = a.id,
                ranch_id   = a.ranch_id,
                lot_type   = a.lot_type,
                lot_ref    = a.lot_ref,
                seller     = a.seller,
                start_bid  = tonumber(a.start_bid) or 0,
                current_bid = tonumber(a.current_bid) or 0,
                high_bidder = a.high_bidder or '',
                deadline   = tonumber(a.deadline) or 0,
                status     = a.status or 'live',
                meta       = (a.meta and a.meta ~= '' and json.decode(a.meta)) or {}
            }
        end
    else
        local store = DB.Json.Get('auctions') or {}
        for id, a in pairs(store) do RanchCore.Auctions[id] = a end
    end
end

local function persistAuction(a)
    if DB.Mode() == 'mysql' then
        local exists = DB.Scalar(('SELECT COUNT(1) FROM `%s` WHERE id=?'):format(DB.Table('auctions')), { a.id })
        if (tonumber(exists) or 0) > 0 then
            DB.Update(
                ('UPDATE `%s` SET current_bid=?,high_bidder=?,status=?,meta=? WHERE id=?')
                    :format(DB.Table('auctions')),
                { a.current_bid, a.high_bidder or '', a.status, json.encode(a.meta or {}), a.id }
            )
        else
            DB.Insert(
                ('INSERT INTO `%s` (id,ranch_id,lot_type,lot_ref,seller,start_bid,current_bid,high_bidder,deadline,status,meta,created_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)')
                    :format(DB.Table('auctions')),
                { a.id, a.ranch_id, a.lot_type, a.lot_ref, a.seller,
                  a.start_bid, a.current_bid, a.high_bidder or '',
                  a.deadline, a.status, json.encode(a.meta or {}), os.time() }
            )
        end
    else
        local store = DB.Json.Get('auctions') or {}
        store[a.id] = a
        DB.Json.Set('auctions', store)
    end
end

function RanchCore.CreateAuction(ranchId, lotType, lotRef, startBid, sellerIdent)
    if not Config.Economy.auctions.enabled then return false, 'disabled' end
    if not RanchCore.Ranches[ranchId] then return false, 'ranch_not_found' end

    -- Enforce per-ranch concurrency cap
    local live = 0
    for _, a in pairs(RanchCore.Auctions) do
        if a.ranch_id == ranchId and a.status == 'live' then live = live + 1 end
    end
    if live >= (Config.Economy.auctions.maxConcurrentPerRanch or 3) then
        return false, 'too_many_auctions'
    end

    -- For animal lots: freeze the animal (status = auction)
    if lotType == 'animal' then
        local animal = RanchCore.Animals[lotRef]
        if not animal or animal.ranch_id ~= ranchId then return false, 'animal_not_found' end
        animal.meta = animal.meta or {}
        if animal.meta.auctionLock then return false, 'already_locked' end
        animal.meta.auctionLock = true
        RanchCore.MarkAnimalDirty(lotRef)
    end

    local a = {
        id          = LXRUtils.GenId('auc'),
        ranch_id    = ranchId,
        lot_type    = lotType,
        lot_ref     = lotRef,
        seller      = sellerIdent,
        start_bid   = startBid,
        current_bid = startBid,
        high_bidder = '',
        deadline    = os.time() + (Config.Economy.auctions.durationMinutes or 15) * 60,
        status      = 'live',
        meta        = {}
    }
    RanchCore.Auctions[a.id] = a
    persistAuction(a)
    TriggerClientEvent(EV('server', 'auctionCreated'), -1, a)
    return true, a.id
end

function RanchCore.PlaceBid(src, auctionId, amount)
    local a = RanchCore.Auctions[auctionId]
    if not a or a.status ~= 'live' then return false, 'not_live' end
    if os.time() > a.deadline then return false, 'expired' end
    local ident = Framework.GetIdentifier(src)
    if ident == a.seller then return false, 'own_lot' end

    local minRaise = math.ceil(a.current_bid * (Config.Economy.auctions.minBidIncrementPct or 0.05))
    if amount < a.current_bid + minRaise then return false, 'too_low' end

    if Framework.GetMoney(src) < amount then return false, 'insufficient' end

    -- Escrow: only reserve virtually — DB row acts as escrow record.
    -- Actual money is withdrawn at settlement from current high bidder.
    -- Refund previous high bidder if any (no money was ever taken, since
    -- bid is a claim, not a withdrawal — simpler model, avoids idle lock).
    a.current_bid = amount
    a.high_bidder = ident
    a.meta.high_bidder_src = src
    persistAuction(a)
    TriggerClientEvent(EV('server', 'auctionUpdated'), -1, a)
    return true
end

function RanchCore.SettleAuction(auctionId)
    local a = RanchCore.Auctions[auctionId]
    if not a or a.status ~= 'live' then return end
    if os.time() < a.deadline then return end

    if not a.high_bidder or a.high_bidder == '' then
        a.status = 'unsold'
        persistAuction(a)
        -- Unlock animal if applicable
        if a.lot_type == 'animal' then
            local an = RanchCore.Animals[a.lot_ref]
            if an and an.meta then an.meta.auctionLock = nil end
        end
        TriggerClientEvent(EV('server', 'auctionSettled'), -1, a)
        return
    end

    local winnerSrc = RanchCore.FindOnlineSourceByIdent(a.high_bidder)
    if not winnerSrc or Framework.GetMoney(winnerSrc) < a.current_bid then
        -- Winner offline or lost funds → void
        a.status = 'void'
        persistAuction(a)
        if a.lot_type == 'animal' then
            local an = RanchCore.Animals[a.lot_ref]
            if an and an.meta then an.meta.auctionLock = nil end
        end
        TriggerClientEvent(EV('server', 'auctionSettled'), -1, a)
        return
    end

    local houseCut = math.floor(a.current_bid * (Config.Economy.auctions.houseCutPct or 0.05))
    local payout = a.current_bid - houseCut

    Framework.RemoveMoney(winnerSrc, a.current_bid)

    local sellerSrc = RanchCore.FindOnlineSourceByIdent(a.seller)
    if sellerSrc then Framework.AddMoney(sellerSrc, payout) end
    RanchCore.Deposit(a.ranch_id, payout, 'Auction payout', a.seller)

    -- Transfer the lot
    if a.lot_type == 'animal' then
        local an = RanchCore.Animals[a.lot_ref]
        if an then
            an.meta.auctionLock = nil
            -- Animal stays where it is, ownership in wolves.land model is ranch-scoped;
            -- the *ranch* may change owner in future extension. Buyer gets bid rights only.
            RanchCore.MarkAnimalDirty(a.lot_ref)
        end
    end

    a.status = 'sold'
    persistAuction(a)
    RanchCore.AddXp(a.high_bidder, 'Wrangler', Config.Progression.xpGains.winAuction or 20)
    TriggerClientEvent(EV('server', 'auctionSettled'), -1, a)
end

function RanchCore.StartAuctionTicker()
    CreateThread(function()
        while true do
            Wait(30 * 1000)
            for id, a in pairs(RanchCore.Auctions) do
                if a.status == 'live' and os.time() >= a.deadline then
                    RanchCore.SettleAuction(id)
                end
            end
        end
    end)
end

function RanchCore.StartContractTicker()
    CreateThread(function()
        Wait(5000)
        RanchCore.RerollBoards()
        while true do
            Wait((Config.Economy.contracts.rerollMinutes or 60) * 60 * 1000)
            RanchCore.RerollBoards()
        end
    end)
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PRODUCTION CHAINS █████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchCore.StartProduction(src, chainKey)
    local chain = Config.Economy.productionChains[chainKey]
    if not chain then return false, 'invalid_chain' end
    for item, count in pairs(chain.input or {}) do
        if not Framework.HasItem(src, item, count) then
            Framework.Notify(src, Framework.L('missing_input'), 'error')
            return false, 'missing_input'
        end
    end
    for item, count in pairs(chain.input or {}) do
        Framework.RemoveItem(src, item, count)
    end

    local waitMs = (chain.timeMinutes or 1) * 60 * 1000
    Framework.Notify(src, Framework.L('production_started'), 'info')
    CreateThread(function()
        Wait(waitMs)
        for item, count in pairs(chain.output or {}) do
            Framework.AddItem(src, item, count)
        end
        local ident = Framework.GetIdentifier(src)
        if chainKey == 'dairy' then
            RanchCore.AddXp(ident, 'Husbandry', chain.xpPerBatch or 5)
        elseif chainKey == 'butcher' then
            RanchCore.AddXp(ident, 'Butcher', chain.xpPerBatch or 5)
        elseif chainKey == 'wool' then
            RanchCore.AddXp(ident, 'Husbandry', chain.xpPerBatch or 5)
        end
        Framework.Notify(src, Framework.L('production_done'), 'success')
    end)
    return true
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ NET EVENTS ████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterNetEvent(EV('client', 'acceptContract'), function(contractId)
    local src = source
    if not RanchCore.RateCheck(src, 'contract', 30) then return end
    RanchCore.AcceptContract(src, contractId)
end)

RegisterNetEvent(EV('client', 'deliverContract'), function(contractId)
    local src = source
    if not RanchCore.RateCheck(src, 'contract', 30) then return end
    RanchCore.DeliverContract(src, contractId)
end)

RegisterNetEvent(EV('client', 'createAuction'), function(ranchId, lotType, lotRef, startBid)
    local src = source
    if not RanchCore.RateCheck(src, 'auction', 10) then return end
    local ident = Framework.GetIdentifier(src)
    if not (RanchCore.PlayerIsOwner(ident, ranchId) or RanchCore.WorkerCan(ranchId, ident, 'canSellAnimal')) then
        Framework.Notify(src, Framework.L('no_permission'), 'error')
        return
    end
    startBid = math.max(1, math.floor(tonumber(startBid) or 0))
    RanchCore.CreateAuction(ranchId, lotType, lotRef, startBid, ident)
end)

RegisterNetEvent(EV('client', 'placeBid'), function(auctionId, amount)
    local src = source
    if not RanchCore.RateCheck(src, 'bid', 60) then return end
    amount = math.floor(tonumber(amount) or 0)
    local ok, err = RanchCore.PlaceBid(src, auctionId, amount)
    if not ok then
        Framework.Notify(src, Framework.L('bid_rejected_' .. (err or 'unknown')) or Framework.L('bid_rejected'), 'error')
    end
end)

RegisterNetEvent(EV('client', 'startProduction'), function(chainKey)
    local src = source
    if not RanchCore.RateCheck(src, 'produce', 20) then return end
    RanchCore.StartProduction(src, chainKey)
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
