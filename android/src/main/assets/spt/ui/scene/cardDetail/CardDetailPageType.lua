local CardDetailPageType =
{
    BasePage = "base",
    ChemicalPage = "chemical",
    TrainPage = "train",
    AscendPage = "ascend",
    MedalPage = "medal",
    MemoryPage = "memory",
    FeaturePage = "feature"
}

CardDetailPageType.PageAscOrder =
{
    [CardDetailPageType.BasePage] = 1,
    [CardDetailPageType.ChemicalPage] = 2,
    [CardDetailPageType.TrainPage] = 3,
    [CardDetailPageType.AscendPage] = 4,
    [CardDetailPageType.MedalPage] = 5,
    [CardDetailPageType.MemoryPage] = 6,
    [CardDetailPageType.FeaturePage] = 7
}

return CardDetailPageType
