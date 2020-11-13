local CommentResManager = require("ui.control.manager.CommentResManager")

local ResManager = clr.Capstones.UnityFramework.ResManager
local PlatDependant = clr.Capstones.PlatExt.PlatDependant

local EventSystem = require ("EventSystem")

local CommentItemView = class(unity.base)

function CommentItemView:ctor()
   self.icon = self.___ex.icon
   self.title = self.___ex.title
   self.availableTips = self.___ex.availableTips
   self.inUseLabel = self.___ex.inUseLabel
   self.btnDownload = self.___ex.btnDownload
   self.btnUse = self.___ex.btnUse
   self.btnDownloadText = self.___ex.btnDownloadText
   self.progressBar = self.___ex.progressBar
   self.progressText = self.___ex.progressText
end

function CommentItemView:start()
    self.btnDownload:regOnButtonClick(function()
        self:StartDownload(self.commentIndex)
    end)
    self.btnUse:regOnButtonClick(function()
        CommentResManager.SetCurrentUseCommentIndex(self.commentIndex)
    end)
    self:RegEvent()
end

function CommentItemView:onDestroy()
    self:RemoveEvent()
end

function CommentItemView:RefreshView()
    self:InitView(self.commentIndex)
end

function CommentItemView:RegEvent()
    EventSystem.AddEvent("CommentResManager_SetCurrentUseCommentIndex", self, self.RefreshView)
end

function CommentItemView:RemoveEvent()
    EventSystem.RemoveEvent("CommentResManager_SetCurrentUseCommentIndex", self, self.RefreshView)
end

function CommentItemView:StartDownload(commentIndex)
    local status = CommentResManager.GetCommentStatus(commentIndex)
    if status ~= CommentResManager.StatusType.NONE then
        require("ui.control.manager.DialogManager").ShowContinuePop("", "已经存在此语音包！", function()
                self:InitView(commentIndex)
        end)
        return
    end

    _G["___resver"]["res" .. commentIndex] = 0

    self:coroutine(function()
        update.update(function(hasDownload)
            dump(hasDownload, "hasDownload")
            unity.waitForNextEndOfFrame()
            if hasDownload then
                ResManager.MovePendingUpdate()

                local commentResList = CommentResManager.GetCommentResList()
                commentResList = commentResList or {}
                table.insert(commentResList, commentIndex)
                CommentResManager.SetCommentResList(commentResList)
            end

            self:InitView(commentIndex)
        end,
        function(key, val, exinfo, ex2)
            if key == "filter" then
                if val == "res" .. tostring(commentIndex) then
                    return false
                end
            elseif key == 'cnt' then
                if ex2 then
                    self.quiet = true
                else
                    local waitHandle = { waiting = true }
                    local title = "开始下载"
                    local msg = ""
                    if tonumber(exinfo) > 0 then
                        msg = lang.transstr("find_hot_update_msg1", math.ceil(tonumber(exinfo)/1024/1024 * 100) / 100)
                    else
                        msg = lang.transstr("find_hot_update_msg2")
                    end
                    require("ui.control.manager.DialogManager").ShowContinuePop(title, msg, function ()
                        waitHandle.waiting = nil
                    end)
                    return waitHandle
                end
            elseif key == 'force_cold' then
            elseif key == 'error' then
                self.progressText.text = "下载失败！"
            elseif key == 'ver' then
                dump(val, "ver")
            elseif key == 'key' then
                dump(val, "key")
                -- 开始下载
                self.btnDownload.gameObject:SetActive(false)
                self.btnUse.gameObject:SetActive(false)
                self.progressBar.gameObject:SetActive(true)
                self.inUseLabel:SetActive(false)
            elseif key == 'streamlength' then
            elseif key == 'percent' then
                self.progressText.text = (math.floor(val * 100 * 10) / 10) .. "%"
                self.progressBar.value = val
            elseif key == 'unzip' then
                self.progressText.text = "解压中..."
            elseif key == 'unzipprog' then
                self.progressText.text = "解压中..."
            end

            return true
        end)
    end)

end

function CommentItemView:InitView(commentIndex, icon, title)
    self.commentIndex = commentIndex
    if icon then
        self.icon.overrideSprite = res.LoadRes(icon)
    end
    if title then
        self.title.text = title
    end

    self.btnDownload.gameObject:SetActive(false)
    self.btnUse.gameObject:SetActive(false)
    self.progressBar.gameObject:SetActive(false)
    self.inUseLabel:SetActive(false)
    self.availableTips:SetActive(false)

    local status = CommentResManager.GetCommentStatus(commentIndex)
    if status == CommentResManager.StatusType.NONE then
        self.btnDownload.gameObject:SetActive(true)
    elseif status == CommentResManager.StatusType.LOCAL then
        self.btnUse.gameObject:SetActive(true)
        self.availableTips:SetActive(true)
    elseif status == CommentResManager.StatusType.INUSE then
        self.inUseLabel:SetActive(true)
        self.availableTips:SetActive(true)
    end
end

return CommentItemView
