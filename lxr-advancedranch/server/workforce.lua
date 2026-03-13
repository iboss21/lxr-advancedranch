local Config = require("shared.config")
local Utils = require("shared.utils")
local Storage = require("server.storage")
local RanchManager = require("server.ranch_manager")

local Workforce = {}
Workforce.Rosters = Storage.Workforce:Get("rosters") or {}
Workforce.Tasks = Storage.Workforce:Get("tasks") or {}

local function save()
    Storage.Workforce:Set("rosters", Workforce.Rosters)
    Storage.Workforce:Set("tasks", Workforce.Tasks)
end

local function ensureRoster(ranchId)
    if not Workforce.Rosters[ranchId] then
        Workforce.Rosters[ranchId] = {}
    end
    return Workforce.Rosters[ranchId]
end

local function ensureTaskBoard(ranchId)
    if not Workforce.Tasks[ranchId] then
        Workforce.Tasks[ranchId] = {}
    end
    return Workforce.Tasks[ranchId]
end

function Workforce.AssignWorker(ranchId, identifier, role)
    local roster = ensureRoster(ranchId)
    roster[identifier] = roster[identifier] or {
        role = role or "Hand",
        morale = 0.8,
        fatigue = 0.2,
        accidents = 0
    }
    roster[identifier].role = role or roster[identifier].role
    save()
    RanchManager.AppendHistory(ranchId, { type = "worker_assigned", identifier = identifier, role = role })
    return roster[identifier]
end

function Workforce.RemoveWorker(ranchId, identifier)
    local roster = ensureRoster(ranchId)
    roster[identifier] = nil
    save()
    RanchManager.AppendHistory(ranchId, { type = "worker_removed", identifier = identifier })
end

function Workforce.CreateTask(ranchId, taskType, metadata)
    local tasks = ensureTaskBoard(ranchId)
    local taskConfig = Config.Workforce.TaskBoard.TaskTypes[taskType]
    if not taskConfig then return false, "Unknown task" end
    local id = string.format("task_%06d", math.random(0, 999999))
    tasks[id] = {
        id = id,
        type = taskType,
        createdAt = Utils.Timestamp(),
        duration = taskConfig.durationMinutes,
        xp = taskConfig.xp,
        metadata = metadata or {},
        assignedTo = nil,
        status = "pending"
    }
    save()
    TriggerClientEvent("ranch:workforce:tasks", -1, ranchId, tasks)
    return true, tasks[id]
end

function Workforce.AssignTask(ranchId, taskId, identifier)
    local tasks = ensureTaskBoard(ranchId)
    if not tasks[taskId] then return false, "Task not found" end
    tasks[taskId].assignedTo = identifier
    tasks[taskId].status = "in_progress"
    tasks[taskId].startedAt = Utils.Timestamp()
    save()
    TriggerClientEvent("ranch:workforce:tasks", -1, ranchId, tasks)
    return true
end

function Workforce.CompleteTask(ranchId, taskId, success)
    local tasks = ensureTaskBoard(ranchId)
    local roster = ensureRoster(ranchId)
    local task = tasks[taskId]
    if not task then return false, "Task not found" end
    task.status = success and "complete" or "failed"
    task.completedAt = Utils.Timestamp()
    if task.assignedTo and roster[task.assignedTo] then
        local worker = roster[task.assignedTo]
        worker.fatigue = Utils.Clamp((worker.fatigue or 0) + Config.Workforce.FatiguePerTask, 0, 1)
        local moraleDelta = success and Config.Ranches.Morale.Bonuses.eventWins or Config.Ranches.Morale.Penalties.accidents
        worker.morale = Utils.Clamp((worker.morale or 0.5) + moraleDelta, 0, 1)
    end
    save()
    TriggerClientEvent("ranch:workforce:tasks", -1, ranchId, tasks)
    RanchManager.AppendHistory(ranchId, { type = "task_complete", task = taskId, success = success })
    return true
end

function Workforce.Tick()
    for ranchId, roster in pairs(Workforce.Rosters) do
        for identifier, worker in pairs(roster) do
            worker.fatigue = Utils.Clamp((worker.fatigue or 0) - Config.Workforce.RestRecoveryPerHour, 0, 1)
            worker.morale = Utils.Clamp((worker.morale or 0.5) - Config.Workforce.MoraleDecayPerHour, 0, 1)
            if math.random() < Config.Workforce.AccidentChance then
                worker.accidents = (worker.accidents or 0) + 1
                RanchManager.AppendHistory(ranchId, { type = "worker_accident", identifier = identifier })
            end
        end
    end
    save()
end

CreateThread(function()
    while true do
        Wait(60 * 60 * 1000)
        Workforce.Tick()
    end
end)

RegisterNetEvent("ranch:workforce:requestSync", function(ranchId)
    local src = source
    TriggerClientEvent("ranch:workforce:roster", src, ranchId, ensureRoster(ranchId))
    TriggerClientEvent("ranch:workforce:tasks", src, ranchId, ensureTaskBoard(ranchId))
end)

return Workforce
