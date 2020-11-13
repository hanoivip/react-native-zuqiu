require("init")

local Initializer = require("Initializer")
local Sampler = require("Sampler")

local function doNothing()

end

function runTest(seed)
    math.randomseed(seed)
    local sampler = Sampler.new(
        doNothing,
        doNothing,
        doNothing,
        doNothing,
        doNothing,
        doNothing,
        doNothing,
        doNothing,
        doNothing,
        doNothing,
        doNothing,
        doNothing,
        doNothing,
        doNothing)
    sampler:init(Initializer)
    sampler:main()
end

for cnt = 1, 100 do
    local seed = cnt

    local startClock = os.clock()
    runTest(seed)
    local totalTime = os.clock() - startClock

    printf("time=%.2fs\n", totalTime)
end
