log = {}
log.levels = { debug = 1, info = 2, warning = 3, error = 4 }
log.level = log.levels.debug

local levelMap = { }
for k, v in pairs(log.levels) do
    levelMap[v] = string.upper(k)
end

function log.printf(lvl, fmt, ...)
    if lvl >= log.level then
        printf("[" .. levelMap[lvl] .. "] " .. string.format(fmt, ...))
    end
end

function log.debug(fmt, ...)
    log.printf(log.levels.debug, fmt, ...)
end

function log.info(fmt, ...)
    log.printf(log.levels.info, fmt, ...)
end

function log.warning(fmt, ...)
    log.printf(log.levels.warning, fmt, ...)
end

function log.error(fmt, ...)
    local traceback = debug.traceback("", 2)
    log.printf(log.levels.error, fmt .. traceback, ...)
    error(string.format(fmt, ...))
end

function log.assert(v, fmt, ...)
    if not v then
        local traceback = debug.traceback("", 2)
        log.printf(log.levels.error, fmt .. traceback, ...)
        error(string.format(fmt, ...))
    end
end
