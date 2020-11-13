local Setting = class(unity.base)

function Setting.SetSkipMatchOpening(isSkip)
    cache.setSkipMatchOpening(isSkip)
end

function Setting.ChangeSkipMatchOpening()
    local skip = cache.getSkipMatchOpening()
    cache.setSkipMatchOpening(not skip)
end

return Setting