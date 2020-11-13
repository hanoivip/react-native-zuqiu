local InspectorData = {
    matchInspectorData =
    {
        {
            dataName = "Time", dataType = "Block", data =
            {
                {
                    dataName = "ActualTime", dataType = "Block", data =
                    {
                        {
                            dataName = "currentTime", dataType = "time"
                        }
                    }
                }
            }
        },
        {
            dataName = "MatchStates", dataType = "Block", data =
            {
                {
                    dataName = "team.name", dataType = "teamName"
                },
                {
                    dataName = "team.score", dataType = "teamProperty"
                }
            }
        }
    },
    athleteInspectorData =
    {
        {
            dataName = "Position", dataType = "Block", data =
            {
                {
                    dataName = "position", dataType = "vector"
                }
            }
        },
        {
            dataName = "BodyDirection", dataType = "Block", data =
            {
                {
                    dataName = "bodyDirection", dataType = "vector"
                }
            }
        },
        {
            dataName = "MoveTargetPosition", dataType = "Block", data =
            {
                {
                    dataName = "targetPosition", dataType = "vector"
                }
            }
        },
        {
            dataName = "Role", dataType = "Block", data =
            {
                {
                    dataName = "role", dataType = "editableField"
                }
            }
        },
        {
            dataName = "Abilities", dataType = "Block", data =
            {
                {
                    dataName = "abilities.dribble", dataType = "inputField", editable = true
                },
                {
                    dataName = "abilities.pass", dataType = "inputField", editable = true
                },
                {
                    dataName = "abilities.shoot", dataType = "inputField", editable = true
                },
                {
                    dataName = "abilities.steal", dataType = "inputField", editable = true
                },
                {
                    dataName = "abilities.intercept", dataType = "inputField", editable = true
                },
                {
                    dataName = "abilities.save", dataType = "inputField", editable = true
                },
            }
        },
        {
            dataName = "CandidateActionScores", dataType = "Block", data =
            {
                {
                    dataName = "candidateActionScores.dribble1", dataType = "inputField", editable = false
                },
                {
                    dataName = "candidateActionScores.dribble2", dataType = "inputField", editable = false
                },
                {
                    dataName = "candidateActionScores.dribble3", dataType = "inputField", editable = false
                },
                {
                    dataName = "candidateActionScores.pass1", dataType = "inputField", editable = false
                },
                {
                    dataName = "candidateActionScores.pass2", dataType = "inputField", editable = false
                },
                {
                    dataName = "candidateActionScores.pass3", dataType = "inputField", editable = false
                },
                {
                    dataName = "candidateActionScores.shoot1", dataType = "inputField", editable = false
                },
                {
                    dataName = "candidateActionScores.shoot2", dataType = "inputField", editable = false
                },
                {
                    dataName = "candidateActionScores.shoot3", dataType = "inputField", editable = false
                },
            }
        },
        {
            dataName = "team.offsideLine", dataType = "inputField", editable = false
        },
        {
            dataName = "team.backLine", dataType = "inputField", editable = false
        },
        {
            dataName = "States", dataType = "Block", data =
            {
                {
                    dataName = "markingAthleteNumber", dataType = "inputField", editable = false
                },
                {
                    dataName = "currentAnimation.animationInfo.name", dataType = "inputField", editable = false
                },
            }
        }
    }
}

return InspectorData
