--used for auto test
require("init")

local cur = os.date('%Y_%m_%d_%H_%M_%S')
local fileName = '../output' .. cur .. '.txt'

math.randomseed(os.time())

io.output(fileName)
coreGameVer = coreGameVer and coreGameVer or "invalid"
io.write('CoreGame Version: ', coreGameVer, '\n')

local Initializer = require("Initializer")
local Match = require("Match")

function runTest(steps, seed)
    print('runTest: steps: ' .. steps .. ', seed: ' .. seed)
    math.randomseed(seed)
    local match = Match.new()
    match:init(Initializer)

    for i = 1, steps do
        match:nextKeyFrame()
        if match.state.name == "GameOver" then
            break
        end
    end
end

function onError(err)
    io.write(err, '\n')
    io.write(debug.traceback(), '\n')
end

local failCount = 0

for cnt = 1, 100000 do
    local seed = math.random(2147483647)
    local steps = 1800
    io.write('===========================================', '\n')
    io.write('runTest: ' .. cnt .. ' , steps:', steps, ', seed: ', seed, '\n')
    local status = xpcall(function() runTest(steps, seed) end, onError)
    if status then
        io.write('ok', '\n')
    else
        failCount = failCount + 1
    end
    io.write(string.format("fail count = %d, fail rate = %.6f%%", failCount, failCount * 100 / cnt), '\n')
    io.flush()
end
