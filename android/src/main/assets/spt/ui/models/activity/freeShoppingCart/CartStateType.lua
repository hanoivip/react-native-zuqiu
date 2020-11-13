local CartStateType =
{
    Miss = 1, -- 已错过
    Selected = 2, -- 之前已选
    TodaySelected = 3, -- 今日已选
    CanSelect = 4, -- 可选
    Disable = 5, --不可选
}

return CartStateType
