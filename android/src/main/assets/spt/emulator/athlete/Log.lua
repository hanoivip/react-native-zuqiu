local Athlete = import("./Core")

function Athlete:logDebug(fmt, ...)
    log.debug("[%.1f] [athlete %d] " .. fmt, self.match.currentTime, self.id, ...)
end

function Athlete:logInfo(fmt, ...)
    log.info("[%.1f] [athlete %d] " .. fmt, self.match.currentTime, self.id, ...)
end

function Athlete:logWarning(fmt, ...)
    log.warning("[%.1f] [athlete %d] " .. fmt, self.match.currentTime, self.id, ...)
end

function Athlete:logError(fmt, ...)
    log.error("[%.1f] [athlete %d] " .. fmt, self.match.currentTime, self.id, ...)
end

function Athlete:logAssert(v, fmt, ...)
    log.assert(v, "[%.1f] [athlete %d] " .. fmt, self.match.currentTime, self.id, ...)
end
