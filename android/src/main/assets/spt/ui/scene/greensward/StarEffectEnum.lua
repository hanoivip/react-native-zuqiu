local StarEffectEnum =
{
    None = 1,
    AllAttribute_Add = 2,
    Morale_Sub = 3,
    AllAttribute_Sub = 4,
    Morale_Add = 5,
    MonsterAttribute_Add = 7,
    FristMonsterAttribute_Sub = 8,
    BossAttribute_Add = 9,
    FristBossAttribute_Sub = 10,
    Treasure_Rand_Probability_Add = 11,
}

--事件ID	事件名称	事件备注
--1 无特殊效果
--2 全员全属性 + { 1 } %
--3 需要消耗士气的操作，士气消耗减少 { 1 } %
--4 全员全属性 - { 1 } %
--5 需要消耗士气的操作，士气消耗增加 { 1 } %
--7 所有普通怪全属性 + { 1 } %
--8 该星象周期内， 挑战的第一个普通怪全属性 - { 1 } %
--9 所有高级怪全属性 + { 1 } %
--10 该星象周期内， 挑战的第一个高级怪全属性 - { 1 } %
--11 完成挖掘事件时，挖到宝物的概率增加

return StarEffectEnum