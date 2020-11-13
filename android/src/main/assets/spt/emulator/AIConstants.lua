local AIConstants = {}

AIConstants.matchScoreState = {
    PLAYERLEAD = 1,
    DRAW = 0,
    PLYAERLAG = -1,
}

AIConstants.teamScoreState = {
    LEAD = 1,
    DRAW = 0,
    LAG = -1,
}

return AIConstants
