local Tactics = { }

Tactics.competitionMentality = {
    attack = {
        [1] = {1, 1, 1, 0.95, 0.9},
        [2] = {0.9, 0.95, 1, 0.95, 0.9},
        [3] = {0.85, 0.9, 1, 0.95, 0.9},
        [4] = {0.8, 0.9, 1, 0.95, 0.9},
        [5] = {0.8, 0.9, 1, 0.95, 0.9}
    },
    defense = {
        [1] = {0.8, 0.85, 1, 0.9, 0.85},
        [2] = {0.85, 0.9, 1, 0.9, 0.85},
        [3] = {0.9, 0.95, 1, 0.9, 0.85},
        [4] = {0.95, 1, 1, 1, 0.95},
        [5] = {1, 1, 1, 1, 1}
    },
    defendArea = {0, 0, 0, -20, -40},
    referencePosition = {"enemy", "enemy", "self", "self", "self"}
}

Tactics.attackEmphasis = {
    sidePass = {2, 1.5, 1, 1, 1},
    centerPass = {1, 1, 1, 1.15, 1.3},
    sideDribble = {1, 1, 1, 1, 1},
    centerDribble = {1, 1, 1, 1.15, 1.3},
}

Tactics.passTactic = {
    HighToF = {0, 1, 1, 1.4, 1.8},
    HighToOthers = {0, 1, 1, 1.1, 1.2},
    HighLeadPassDist = {25, 25, 25, 25, 25},
    GroundToOthers = {1.8, 1.4, 1, 1, 1}
}

Tactics.attackRhythm = {
    counterAttackProb = {0, 0.2, 0.4, 0.6, 0.8},
    rolling = {2, 1.5, 1, 1, 1}
}

return Tactics