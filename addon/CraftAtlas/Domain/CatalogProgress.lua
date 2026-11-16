local _, ns = ...

-- Tracks attempted local work, not successful client-cache resolution.
function ns.NewCatalogProgress(total)
    total = type(total) == "number" and math.max(0, math.floor(total)) or 0
    return {total = total, completed = 0, status = total == 0 and "complete" or "active",
        batches = 0, maxBatchMs = 0}
end

function ns.CatalogPercent(progress)
    if not progress then return 0 end
    if progress.total <= 0 then return progress.status == "complete" and 100 or 0 end
    return math.max(0, math.min(100,
        math.floor(100 * math.min(progress.completed, progress.total) / progress.total)))
end

function ns.AdvanceCatalogProgress(progress, attempted, batchMs)
    if not progress or progress.status ~= "active" then return end
    attempted = type(attempted) == "number" and math.max(0, math.floor(attempted)) or 0
    progress.completed = math.min(progress.total, progress.completed + attempted)
    progress.batches = progress.batches + 1
    if type(batchMs) == "number" then
        progress.maxBatchMs = math.max(progress.maxBatchMs, math.max(0, batchMs))
    end
    if progress.completed == progress.total then progress.status = "complete" end
end

function ns.StopCatalogProgress(progress)
    if progress and progress.status == "active" then progress.status = "incomplete" end
end

-- Pure scheduling gate: at most one outstanding redraw per view.
function ns.NewCatalogRefreshGate()
    return {scheduled = false, dirty = false, pendingGeneration = 0, renders = 0}
end

function ns.MarkCatalogRefreshDirty(gate)
    gate.dirty = true
    gate.pendingGeneration = gate.pendingGeneration + 1
    if gate.scheduled then return false end
    gate.scheduled = true
    return true
end

function ns.ConsumeCatalogRefresh(gate)
    gate.scheduled = false
    if not gate.dirty then return false end
    gate.dirty = false
    gate.renders = gate.renders + 1
    return true
end
