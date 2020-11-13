local SGPCustomEventConstants = {}

SGPCustomEventConstants.DiamondSource = {["pay"] = "充值",["2"] = "系统发放",["3"] = "系统发放"}

SGPCustomEventConstants.DiamondConsume = {["store"] = "商城",["2"] = "商城",["3"] = "商城",["4"] = "商城",["5"] = "商城",["6"] = "商城"}

SGPCustomEventConstants.BlackDiamondSource = {["pay"] = "充值"}

SGPCustomEventConstants.BlackDiamondConsume = {["store"] = "商城"}
--   
SGPCustomEventConstants.Phylum = {["pay"] = "充值",["store"] = "商城",["activity"] = "活动", ["court"] = "球场建设",["guild"] = "工会", ["card"] = "球员大卡", ["transfer"] = "转会市场", ["vipStore"] = "VIP商店"}

SGPCustomEventConstants.ClassField = {["gacha"] = "抽卡",["refresh"] = "刷新",["item"] = "礼盒",["skillLvlUp"] = "技能升级", ["signIn"] = "签到", ["guildSetting"] = "工会设置", ["changeName"] = "改名",
                                     ["create"] = "创建",["buildUpgrade"] = "升级", ["timeLimit"] = "限时售卖", ["luckyWheel"] = "限时夺宝"
                                    }

SGPCustomEventConstants.Genus = {["one"] = "单抽",["ten"] = "十连抽"}

return SGPCustomEventConstants