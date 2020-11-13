local actionConfig = {
    ["GOAL_KEEPER_SAVE_ACTIONS"] = {
        "E_C001",
        "E_C002",
        "E_C003",
        "E_C004",
        "E_C004_1",
        "E_C004_2",
        "E_C004_3",
        "E_C005",
        "E_C005_1",
        "E_C006",
        "E_C006_1",
        "E_C006_2",
        "E_C006_3",
        "E_C007",
        "E_C007_1",
        "E_C009",
        "E_C009_1"
    },
    ["GOAL_KEEPER_CATCH_ACTIONS"] = {
        "E_B001",
        "E_B002",
        "E_B003",
        "E_B004",
        "E_B004_1",
        "E_B005",
        "E_B005_1",
        "E_B006",
        "E_B006_1",
        "E_B007",
        "E_B007_1"
    },
    ["SHOOTER_CELERATE_ACTIONS"] = {
        "230",
        "236",
        "247",
        "247_1",
        "248",
        "250",
        "252",
        "259"
    },
    ["NON_SHOOTER_CELERATE_ACTIONS"] = {
        "246",
        "194"
    },
    ["REGRET_ACTIONS"] = {
        "23",
        "24",
        "25"
    },

    -- for upper body
    ["UPPER_BODY_CHASE_DEFENSE_RIGHT"] = {
        "G_K01"
    },
    ["UPPER_BODY_CHASE_DEFENSE_LEFT"] = {
        "G_K01_1"
    },
    ["UPPER_BODY_ANTIDEFENSE_RIGHT"] = {
        "G_K04"
    },
    ["UPPER_BODY_ANTIDEFENSE_LEFT"] = {
        "G_K04_1"
    },
    ["UPPER_BODY_MARK_DEFENSE_FORWARD"] = {
        "G_K05"
    },
    ["UPPER_BODY_CALL_FOR_BALL_RIGHT"] = {
        "G_A01",
        "G_A02"
    },
    ["UPPER_BODY_CALL_FOR_BALL_LEFT"] = {
        "G_A01_1",
        "G_A02_1"
    },

    -- run forward & backward & turn
    ["RUN_BACKWARD_ACTIONS"] = {
        "B_R017",
        "B_R018",
        "B_R019"
    },

    ["GK_MOVE_TINY_MOTION"] = {
        "B_R028_1"
    },
    ["GK_MOVE_LEFT_MOTION"] = {
        "E_R004_1"
    },
    ["GK_MOVE_RIGHT_MOTION"] = {
        "E_R003_1"
    },
    ["GK_RUN_LEFT_MOTION"] = {
        "B_R025_1"
    },
    ["GK_RUN_RIGHT_MOTION"] = {
        "B_R027_1"
    },
    ["GK_FAIL_LEFT_MOTION"] = {
       "E_S005"
    },
    ["GK_FAIL_RIGHT_MOTION"] = {
       "E_S005_1"
    },
    ["GK_FAIL_LEFT_MOTION2"] = {
        "E_S006"
    },
    ["GK_FAIL_RIGHT_MOTION2"] = {
        "E_S006_1"
    },
    ["GK_PREPARE_MOTION"] = {
        "A03"
    },
    ["WALL_ACTIONS"] = {
        "E_Q001",
        "E_Q006",
        "E_Q007",
        "E_Q008",
        "E_Q009"
    },

    ["PLAYER_ENTER_MOTION"] = {
        "B_W002"
    },
}

function actionConfig.GetOneAction(key)
    assert(type(key) == "string")
    local tmpList = actionConfig[key]
    local r = math.random(1, #tmpList)
    return tmpList[r]
end

return actionConfig
