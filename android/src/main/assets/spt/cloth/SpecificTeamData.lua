local SpecificTeamData = {
    Bayern = {
        -- 这里的homeShirt以及awayShirt（mask，maskRedChannel，maskGreenChannel）主要用来进行撞色判断，号码颜色（backNumColor，backNumColor）是要应用在实际游戏中
        homeShirt = {
            mask = "Mask_41",
            maskRedChannel = "0.713, 0.115, 0.115, 1.000",
            maskGreenChannel = "1.000, 1.000, 1.000, 1.000",
            maskBlueChannel = "0.714, 0.114, 0.114, 1.000",
            backNumColor = "1.000, 1.000, 1.000, 1.000",
            trouNumColor = "1.000, 1.000, 1.000, 1.000",
        },
        awayShirt = {
            mask = "Mask_59",
            maskRedChannel = "1.000, 1.000, 1.000, 1.000",
            maskGreenChannel = "0.529, 0.095, 0.016, 1.000",
            maskBlueChannel = "0.078, 0.078, 0.078, 1.000",
            backNumColor = "1.000, 0, 0, 1.000",
            trouNumColor = "1.000, 1.000, 1.000, 1.000",
        },
        logo = "BayernLogo",
        spectators = {
            maskTex = "SpectatorsMask1",
            firstColor = "0.713, 0.115, 0.115, 1.000",
            secondColor = "1.000, 1.000, 1.000, 1.000",
        },

        nameNumType = require("cloth.NameNumGenerator").NameNumType.NameBottom,
        printingStyle = require("coregame.PlayerReplacer").PrintingStyle.BayernStyle,

        resMap = {
            [require("coregame.MatchUseShirtType").HOME] = {
                shirtPath = "Assets/CapstonesRes/Game/ClothMaker/SpecificCloth/BayernHome.jpg",
                smallCloth = "Assets/CapstonesRes/Game/UI/Common/Images/SpecificSmallCloth/BayernHome.png",
            },
            [require("coregame.MatchUseShirtType").AWAY] = {
                shirtPath = "Assets/CapstonesRes/Game/ClothMaker/SpecificCloth/BayernAway.jpg",
                smallCloth = "Assets/CapstonesRes/Game/UI/Common/Images/SpecificSmallCloth/BayernAway.png",
            },
        },
    },
    RealMadrid = {
        homeShirt = {
            mask = "Mask_01",
            maskRedChannel = "1.000, 1.000, 1.000, 1.000",
            maskGreenChannel = "1.000, 1.000, 1.000, 1.000",
            maskBlueChannel = "1.000, 1.000, 1.000, 1.000",
            backNumColor = "0, 0.466, 0.541, 1.000",
            trouNumColor = "0, 0.466, 0.541, 1.000",
        },
        awayShirt = {
            mask = "Mask_01",
            maskRedChannel = "0.100, 0.100, 0.100, 1.000",
            maskGreenChannel = "0, 0.466, 0.541, 1.000",
            maskBlueChannel = "0, 0.466, 0.541, 1.000",
            backNumColor = "1.000, 1.000, 1.000, 1.000",
            trouNumColor = "1.000, 1.000, 1.000, 1.000",
        },
        logo = "RealMadridLogo",
        spectators = {
            maskTex = "SpectatorsMask1",
            firstColor = "1.000, 1.000, 1.000, 1.000",
            secondColor = "0, 0.466, 0.541, 1.000",
        },

        nameNumType = require("cloth.NameNumGenerator").NameNumType.NameTop,
        printingStyle = require("coregame.PlayerReplacer").PrintingStyle.RealMadridStyle,

        resMap = {
            [require("coregame.MatchUseShirtType").HOME] = {
                shirtPath = "Assets/CapstonesRes/Game/ClothMaker/SpecificCloth/RealMadrid1718home.jpg",
                smallCloth = "Assets/CapstonesRes/Game/UI/Common/Images/SpecificSmallCloth/RealMadridHome.png",
            },
            [require("coregame.MatchUseShirtType").AWAY] = {
                shirtPath = "Assets/CapstonesRes/Game/ClothMaker/SpecificCloth/RealMadrid1718away.jpg",
                smallCloth = "Assets/CapstonesRes/Game/UI/Common/Images/SpecificSmallCloth/RealMadridAway.png",
            },
        },
    },
    Barcelona = {
        homeShirt = {
            mask = "Mask_15",
            maskRedChannel = "0.713, 0.115, 0.115, 1.000",
            maskGreenChannel = "1.000,1.000,1.000,1.000",
            maskBlueChannel = "0.714, 0.114, 0.114, 1.000",
            backNumColor = "0.957,0.796,0.133,1.000",
            trouNumColor = "0.957,0.796,0.133,1.000",
        },
        awayShirt = {
            mask = "Mask_15",
            maskRedChannel = "1.000, 1.000, 1.000, 1.000",
            maskGreenChannel = "0.529, 0.095, 0.016, 1.000",
            maskBlueChannel = "0.078, 0.078, 0.078, 1.000",
            backNumColor = "0.149,0.231,0.454,1.000",
            trouNumColor = "0.149,0.231,0.454,1.000",
        },
        logo = "BarcelonaLogo",
        spectators = {
            maskTex = "SpectatorsMask1",
            firstColor = "0.456,0.010,0.028,1.000",
            secondColor = "0.706,0.706,0.706,1.000",
        },

        nameNumType = require("cloth.NameNumGenerator").NameNumType.NameTop,
        printingStyle = require("coregame.PlayerReplacer").PrintingStyle.BarcelonaStyle,

        resMap = {
            [require("coregame.MatchUseShirtType").HOME] = {
                shirtPath = "Assets/CapstonesRes/Game/ClothMaker/SpecificCloth/BarcelonaHome.jpg",
                smallCloth = "Assets/CapstonesRes/Game/UI/Common/Images/SpecificSmallCloth/BarcelonaHome.png",
            },
            [require("coregame.MatchUseShirtType").AWAY] = {
                shirtPath = "Assets/CapstonesRes/Game/ClothMaker/SpecificCloth/BarcelonaAway.jpg",
                smallCloth = "Assets/CapstonesRes/Game/UI/Common/Images/SpecificSmallCloth/BarcelonaAway.png",
            },
        },
    },
}

return SpecificTeamData
