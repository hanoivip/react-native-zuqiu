local GreenswardItemActionMap = {
    -- 确认对话框
    DialogConfirm = {
        model = "ui.models.greensward.item.itemAction.ItemActionDialogConfirmModel",
        ctrl = "ui.controllers.greensward.item.itemAction.ItemActionDialogConfirmCtrl"
    },
    -- 白条提示
    DialogToast = {
        model = "ui.models.greensward.item.itemAction.ItemActionDialogToastModel",
        ctrl = "ui.controllers.greensward.item.itemAction.ItemActionDialogToastCtrl"
    },
    -- 奖励结果
    DialogReward = {
        model = "ui.models.greensward.item.itemAction.ItemActionDialogRewardModel",
        ctrl = "ui.controllers.greensward.item.itemAction.ItemActionDialogRewardCtrl"
    },
    -- 天气
    WeatherChange = {
        model = "ui.models.greensward.item.itemAction.ItemActionWeatherChangeModel",
        ctrl = "ui.controllers.greensward.item.itemAction.ItemActionWeatherChangeCtrl"
    },
    -- 星象与天气一致逻辑
    AstrologyChange = {
        model = "ui.models.greensward.item.itemAction.ItemActionWeatherChangeModel",
        ctrl = "ui.controllers.greensward.item.itemAction.ItemActionWeatherChangeCtrl"
    },
    -- 藏宝图
    TreasureMap = {
        model = "ui.models.greensward.item.itemAction.ItemActionTreasureMapModel",
        ctrl = "ui.controllers.greensward.item.itemAction.ItemActionTreasureMapCtrl"
    },
    -- 神秘指令
    MysticHint = {
        model = "ui.models.greensward.item.itemAction.ItemActionMysticHintModel",
        ctrl = "ui.controllers.greensward.item.itemAction.ItemActionMysticHintCtrl"
    },
    -- 金属探测器探宝
    TreasureOpen = {
        model = "ui.models.greensward.item.itemAction.ItemActionTreasureOpenModel",
        ctrl = "ui.controllers.greensward.item.itemAction.ItemActionTreasureOpenCtrl"
    },
    -- 修改地图事件状态
    AdvTrigger = {
        model = "ui.models.greensward.item.itemAction.ItemActionAdvTriggerModel",
        ctrl = "ui.controllers.greensward.item.itemAction.ItemActionAdvTriggerCtrl"
    },
    -- 修改自身buff
    BuffChange = {
        model = "ui.models.greensward.item.itemAction.ItemActionBuffChangeModel",
        ctrl = "ui.controllers.greensward.item.itemAction.ItemActionBuffChangeCtrl"
    },
    -- 削弱对手战力
    WeakenOpponent = {
        model = "ui.models.greensward.item.itemAction.ItemActionWeakenOpponentModel",
        ctrl = "ui.controllers.greensward.item.itemAction.ItemActionWeakenOpponentCtrl"
    },
    -- 照明弹
    FlashBang = {
        model = "ui.models.greensward.item.itemAction.ItemActionFlashBangModel",
        ctrl = "ui.controllers.greensward.item.itemAction.ItemActionFlashBangCtrl"
    },
    -- 透视镜
    Glasses = {
        model = "ui.models.greensward.item.itemAction.ItemActionGlassesModel",
        ctrl = "ui.controllers.greensward.item.itemAction.ItemActionGlassesCtrl"
    }
}

return GreenswardItemActionMap
