local NoticeSingleView = class(unity.base)

function NoticeSingleView:ctor()
    self.title = self.___ex.title
    self.noticeText = self.___ex.noticeText
end

function NoticeSingleView:Init(title, text)
    self.title.text = tostring(title)
    self.noticeText.inline.text = tostring(text)
end

return NoticeSingleView
