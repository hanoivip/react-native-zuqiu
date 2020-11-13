local HomeMenuHelper = {}

HomeMenuHelper.MenuBarOpenOption = 
{ 
    Transfer = { Id = 1, LockObjPath = "transferLock", LockObjTextPath = "transferLockText", ImagePaths = {open = "transferOpen", lock = "transferClose"}} 
}

HomeMenuHelper.ContentOpenOption = 
{
    League = { Id = 2, LockObjPath = "leagueLock", LockObjTextPath = "leagueLockText", LockObjIcon = "leagueInteractable", SweepPath = "leagueSweep"},
    Train = { Id = 3, LockObjPath = "trainLock", LockObjTextPath = "trainLockText", LockObjIcon = "trainInteractable", SweepPath = "trainSweep"} ,
    Court = { Id = 5, LockObjPath = "courtLock", LockObjTextPath = "courtLockText", LockObjIcon = "courtInteractable", SweepPath = "courtSweep"} 
}

return HomeMenuHelper
