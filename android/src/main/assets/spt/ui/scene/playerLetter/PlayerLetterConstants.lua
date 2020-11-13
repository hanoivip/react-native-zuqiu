local PlayerLetterConstants = {}

-- 标签类型
PlayerLetterConstants.TagType = {
	-- 未回复标签
    NO_REPLY = "noReply",
    -- 已回复标签
    HAVE_REPLY = "haveReply",
}

-- 球员信函状态
PlayerLetterConstants.LetterState = {
    -- 未完成
    UNFINISHED = -1,
    -- 已完成，未领奖
    NOT_AWARD = 0,
    -- 已领奖
    HAVE_AWARD = 1,
}

-- 信函阅读状态
PlayerLetterConstants.LetterReadState = {
    -- 未读
    UNREAD = 0,
    -- 已读
    READ = 1, 
}

return PlayerLetterConstants