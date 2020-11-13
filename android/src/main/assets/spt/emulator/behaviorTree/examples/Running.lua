local BT = import(..., '.BehaviorTree')

local running3Task = BT.Task.new( {
    start = function(self, object, instance)
        print("running 3 start")
        object.count = 0
    end,
    run = function(self, object, instance)
        object.count = object.count + 1
        print("running:" .. object.str .. ":" .. object.count)
        if object.count < 3 then
            print("status: running")
            return "running"
        else
            print("status: success")
            return "success"
        end
    end,
    finish = function(self, object, instance)
        print("running 3 finish")
    end
} )

local successTask = BT.Task.new( {
    run = function(self, object, instance)
        print("success:" .. object.str)
        return "success"
    end
} )

local failTask = BT.Task.new( {
    run = function(self, object, instance)
        print("fail:" .. object.str)
        return "fail"
    end
} )

local failCondition = BT.Condition.new( {
    run = function(self, object, instance)
        print("fail:" .. object.str)
        return "fail"
    end
} )

local successCondition = BT.Condition.new( {
    run = function(self, object, instance)
        print("success:" .. object.str)
        return "success"
    end
} )

local Frank = BT.new( {
    tree = BT.Sequence.new( {
        children = {
            --[[BT.Sequence.new( {
                children = {
                   failCondition, successTask,running3Task,failTask
                }
            } ),]]
            BT.Priority.new( {
                children = {
                   successCondition, running3Task, successTask, failTask
                }
            } ),
        }
    } )
} )

local object = { str = "haha", instance = Frank:createInstance() }

for i = 1, 20 do
    print(i)
    Frank:run(object, object.instance)
end

