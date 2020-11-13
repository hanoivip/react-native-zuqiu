local CommentSettingView = class(unity.base)

local CommentResManager = require("ui.control.manager.CommentResManager")

local toBeDownloadCommentIndex = "commentGuoMingHui"

function CommentSettingView:ctor()
    self.close = self.___ex.close
    self.scorllContent = self.___ex.scorllContent
end

function CommentSettingView:start()
    self.close:regOnButtonClick(function()
        if CommentResManager.GetCurrentUseCommentIndex() == toBeDownloadCommentIndex then
            audio.GetPlayer("commentTest").PlayAudio("Assets/CapstonesRes/Game/Audio/commentGuoMingHui/GMHTest.mp3", 1)
        else
            audio.GetPlayer("commentTest").PlayAudio("Assets/CapstonesRes/Game/Audio/Commentary/Lmessi_p.mp3", 1)            
        end
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

function CommentSettingView:AddCommentItem()
    
end

return CommentSettingView
