local ActionLayerConfig = {}

ActionLayerConfig.ScoreChange = {
    None = 0,
    PlayerScore = 1,
    OpponentScore = 2
}

ActionLayerConfig.FindCharacterType = {
    Random = 0,
    ClosestToPosition = 1,
    ClosestToHero = 2
}

ActionLayerConfig.SideLinePosX = 37.3
ActionLayerConfig.PenaltySpotZ = 44
ActionLayerConfig.ShootCelebrateDelay = 0
ActionLayerConfig.GoalWidth = 3.66
ActionLayerConfig.GoalOutsideWidth = 3.95
ActionLayerConfig.GoalHeight = 2.44
ActionLayerConfig.GoalPositionZ = 55
ActionLayerConfig.BallRadius = 0.1
ActionLayerConfig.BallDiameter = 0.2
ActionLayerConfig.Gravity = 9.8
ActionLayerConfig.ShootBallGravity = 19.6
ActionLayerConfig.ExitCorner = { x = -40, y = -60 }
ActionLayerConfig.CornerKickBallPosX = 36.2
ActionLayerConfig.CornerKickBallPosZ = 54.5
ActionLayerConfig.ThrowInResetPosX = 36.7

--free fly ball - start
ActionLayerConfig.AIR_DRAG = -0.5 --空气阻力，暂定常量，仅考虑水平方向

ActionLayerConfig.GROUND_BOUNCE_VERTICAL_SPEED_ATTENUATION = -0.6
ActionLayerConfig.GROUND_BOUNCE_HORIZIONTAL_SPEED_ATTENUATION = 0.6

ActionLayerConfig.GOALBACK_BOUNCE_HORIZONTAL_VERTICAL_CONVERTER = 0.3
ActionLayerConfig.GOALBACK_BOUNCE_HORIZONTAL_VERTICAL_CONVERTER_UP = 0.8
ActionLayerConfig.GOALBACK_BOUNCE_HORIZONTAL_STOP_DISTANCE = 0.1
ActionLayerConfig.GOALBACK_BOUNCE_SPEED_X_ATTENUATION = 0.4
ActionLayerConfig.GOALBACK_BOUNCE_SPEED_Z_ATTENUATION = 0.2
ActionLayerConfig.GOALBACK_BOUNCE_SPEED_Y_ATTENUATION = 0.4
ActionLayerConfig.GOALBACK_BOUNCE_SPEED_Y_ATTENUATION_UP = 0.8

ActionLayerConfig.GOALSIDE_BOUNCE_SPEED_X_ATTENUATION = 0.2
ActionLayerConfig.GOALSIDE_BOUNCE_SPEED_Z_ATTENUATION = 0.3
ActionLayerConfig.GOALSIDE_BOUNCE_SPEED_Y_ATTENUATION = 0.4
ActionLayerConfig.GOALSIDE_BOUNCE_SPEED_Y_ATTENUATION_UP = 0.6
ActionLayerConfig.GOALSIDE_BOUNCE_HORIZONTAL_VERTICAL_CONVERTER = 0.8

ActionLayerConfig.GOALUP_BOUNCE_HORIZONTAL_VERTICAL_CONVERTER = 0.2
ActionLayerConfig.GOALUP_BOUNCE_SPEED_X_ATTENUATION = 0.5
ActionLayerConfig.GOALUP_BOUNCE_SPEED_Z_ATTENUATION = 0.5
ActionLayerConfig.GOALUP_BOUNCE_SPEED_Y_ATTENUATION = 0.4

ActionLayerConfig.HORIZIONTAL_MIN_SPEED_DROP = 0.5

ActionLayerConfig.AD_BOARD_HORIZONTAL_SPEED_ATTENUATION = 0.5
ActionLayerConfig.AD_BOARD_VERTICAL_SPEED_MAX = 3
ActionLayerConfig.AD_BOARD_VERTICAL_SPEED_MIN = 1
--free fly ball - end

return ActionLayerConfig