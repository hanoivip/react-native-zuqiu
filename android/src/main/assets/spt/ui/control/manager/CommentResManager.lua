-- 语音包资源管理
local CommentResManager = {}

local ResManager = clr.Capstones.UnityFramework.ResManager
local PlatDependant = clr.Capstones.PlatExt.PlatDependant

CommentResManager.CommentIndexMap = {
    DEFAULT = "default",
    GMH = "commentGuoMingHui",
}

CommentResManager.StatusType = {
    NONE = 1, -- 默认状态
    LOCAL = 2, -- 本地存在
    INUSE = 3, -- 使用中
}

-- 获取当前正在使用的语音包
function CommentResManager.GetCurrentUseCommentIndex()
    return cache.getUseCommentIndex() or CommentResManager.CommentIndexMap.DEFAULT
end

-- 设置使用的语音包
function CommentResManager.SetCurrentUseCommentIndex(commentIndex)
    local currentuseCommentIndex = CommentResManager.GetCurrentUseCommentIndex()
    if currentuseCommentIndex == commentIndex then
        return
    end

    if currentuseCommentIndex ~= CommentResManager.CommentIndexMap.DEFAULT then
        ResManager.RemoveDistributeFlag(currentuseCommentIndex)
    end
    if commentIndex ~= CommentResManager.CommentIndexMap.DEFAULT then
        ResManager.AddDistributeFlag(commentIndex)
    end

    ResManager.ReinitResForDistribute()

    local ret = cache.setUseCommentIndex(commentIndex)
    EventSystem.SendEvent("CommentResManager_SetCurrentUseCommentIndex", commentIndex)
    return ret
end

-- 本地所有可用的语音包资源
function CommentResManager.GetCommentResList()
    return cache.getCommentResList() or {}
end

function CommentResManager.SetCommentResList(commentIndexList)
    return cache.setCommentResList(commentIndexList)
end

-- 获取一个语音包的状态
function CommentResManager.GetCommentStatus(commentIndex)
    local currentUseCommentIndex = CommentResManager.GetCurrentUseCommentIndex()
    if commentIndex == currentUseCommentIndex then
        return CommentResManager.StatusType.INUSE
    else
        if commentIndex == CommentResManager.CommentIndexMap.DEFAULT then
            return CommentResManager.StatusType.LOCAL
        end

        local commentResList = CommentResManager.GetCommentResList()
        for i, v in ipairs(commentResList) do
            if v == commentIndex then
                return CommentResManager.StatusType.LOCAL
            end
        end
    end

    return CommentResManager.StatusType.NONE
end

return CommentResManager
