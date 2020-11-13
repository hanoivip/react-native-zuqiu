local DialogManager = {}

DialogManager.DialogType = 
{
    GeneralBox = 1, 
    MessageBox = 2
}

local function ShowDialog(data, cameraType, closeByTouchOutside)
    local cameraBaseType = cameraType
    if not cameraType then
        cameraBaseType = 'overlay'
    end
    local resDlg, dialogcomp = res.ShowDialog('Assets/CapstonesRes/Game/UI/Control/Dialog/MessageBox.prefab', cameraBaseType, closeByTouchOutside, true)
    dialogcomp.contentcomp:initData(data)
    return resDlg, dialogcomp
end

local function ShowMessageToggleBox(data, cameraType, closeByTouchOutside)
    local cameraBaseType = cameraType
    if not cameraType then
        cameraBaseType = 'overlay'
    end
    local resDlg, dialogcomp = res.ShowDialog('Assets/CapstonesRes/Game/UI/Control/Dialog/MessageToggleBox.prefab', cameraBaseType, closeByTouchOutside, true)
    dialogcomp.contentcomp:initData(data)
    return resDlg, dialogcomp
end

local function ShowGeneralBox(data, cameraType, closeByTouchOutside)
    local cameraBaseType = cameraType
    if not cameraType then
        cameraBaseType = 'overlay'
    end
    local resDlg, dialogcomp = res.ShowDialog('Assets/CapstonesRes/Game/UI/Control/Dialog/GeneralBox.prefab', cameraBaseType, closeByTouchOutside, true)
    dialogcomp.contentcomp:initData(data)
    return resDlg, dialogcomp
end

--- 显示消息提示条
-- @param msg 消息内容
function DialogManager.ShowToast(msg, params)
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Control/Dialog/Toast.prefab", "overlay", false, false, true)
    dialogcomp.contentcomp:InitView(msg, params)
    return resDlg, dialogcomp
end

--- 显示消息提示条
-- @param msgKey 内容key，key从语言包中获取
function DialogManager.ShowToastByLang(msgKey)
    return DialogManager.ShowToast(lang.trans(msgKey))
end

--- 显示提示弹窗，没有按钮，点击周围或经过指定时间之后自动关闭
-- @param title 标题
-- @param msg 内容
-- @param autoCloseTime 自动关闭的秒数
-- @param cameraType 指定渲染模式
function DialogManager.ShowInfoPop(title, msg, autoCloseTime, cameraType, dialogType)
    local content = {}
    content.title = title
    content.content = msg
    content.autoCloseTime = autoCloseTime
    if dialogType == DialogManager.DialogType.GeneralBox then 
        return ShowGeneralBox(content, cameraType, true)
    else
        return ShowDialog(content, cameraType, true)
    end
end

--- 显示提示弹窗，没有按钮，点击周围或经过指定时间之后自动关闭
-- @param titleKey 标题key，key从语言包中获取
-- @param msgKey 内容key，key从语言包中获取
-- @param autoCloseTime 自动关闭的秒数
-- @param cameraType 指定渲染模式
function DialogManager.ShowInfoPopByLang(titleKey, msgKey, autoCloseTime, cameraType, dialogType)
    return DialogManager.ShowInfoPop(lang.trans(titleKey), lang.trans(msgKey), autoCloseTime, cameraType, dialogType)
end

--- 显示提示弹窗，只有一个确定按钮
-- @param title 标题
-- @param msg 内容
-- @param confirmCallback 点击确定按钮后的回调
-- @param cameraType 指定渲染模式
function DialogManager.ShowAlertPop(title, msg, confirmCallback, cameraType, dialogType)
    local content = {}
    content.title = title
    content.content = msg
    content.button2Text = lang.trans("confirm")
    content.onButton2Clicked = confirmCallback
    content.hideCloseIcon = true
    if dialogType == DialogManager.DialogType.GeneralBox then 
        return ShowGeneralBox(content, cameraType)
    else
        return ShowDialog(content, cameraType)
    end
end

function DialogManager.ShowAlertAlignmentPop(title, msg, alignment, confirmCallback, cameraType)
    local content = {}
    content.title = title
    content.content = msg
    content.textAlignment = alignment
    content.button2Text = lang.trans("confirm")
    content.onButton2Clicked = confirmCallback
    content.hideCloseIcon = true
    return ShowDialog(content, cameraType)
end

function DialogManager.ShowAlertAlignmentAndWidthPop(title, msg, fixWidth, alignment, cameraType, closeByTouchOutside)
    local content = {}
    content.title = title
    content.content = msg
    content.button2Text = lang.trans("confirm")
    content.textAlignment = alignment
    content.width = fixWidth
    return ShowGeneralBox(content, cameraType, closeByTouchOutside)
end

--- 显示提示弹窗，只有一个确定按钮
-- @param titleKey 标题key，key从语言包中获取
-- @param msgKey 内容key，key从语言包中获取
-- @param confirmCallback 点击确定按钮后的回调
-- @param cameraType 指定渲染模式
function DialogManager.ShowAlertPopByLang(titleKey, msgKey, confirmCallback, cameraType, dialogType)
    return DialogManager.ShowAlertPop(lang.trans(titleKey), lang.trans(msgKey), confirmCallback, cameraType, dialogType)
end

--- 显示提示弹窗，只有一个重试按钮
-- @param title 标题
-- @param msg 内容
-- @param retryCallback 点击重试按钮后的回调
-- @param cameraType 指定渲染模式
function DialogManager.ShowRetryPop(title, msg, retryCallback, cameraType, dialogType)
    local content = {}
    content.title = title
    content.content = msg
    content.button1Text = lang.trans("retry")
    content.onButton1Clicked = retryCallback
    content.hideCloseIcon = true
    if dialogType == DialogManager.DialogType.GeneralBox then 
        return ShowGeneralBox(content, cameraType)
    else
        return ShowDialog(content, cameraType)
    end
end

--- 显示提示弹窗，只有一个重试按钮
-- @param titleKey 标题key，key从语言包中获取
-- @param msgKey 内容key，key从语言包中获取
-- @param retryCallback 点击重试按钮后的回调
-- @param cameraType 指定渲染模式
function DialogManager.ShowRetryPopByLang(titleKey, msgKey, retryCallback, cameraType, dialogType)
    return DialogManager.ShowRetryPop(lang.trans(titleKey), lang.trans(msgKey), retryCallback, cameraType, dialogType)
end

--- 显示提示弹窗，只有一个继续按钮
-- @param title 标题
-- @param msg 内容
-- @param continueCallback 点击继续按钮后的回调
-- @param cameraType 指定渲染模式
function DialogManager.ShowContinuePop(title, msg, continueCallback, cameraType, dialogType)
    local content = {}
    content.title = title
    content.content = msg
    content.button1Text = lang.trans("continue")
    content.onButton1Clicked = continueCallback
    content.hideCloseIcon = true
    if dialogType == DialogManager.DialogType.GeneralBox then 
        return ShowGeneralBox(content, cameraType)
    else
        return ShowDialog(content, cameraType)
    end
end

--- 显示提示弹窗，只有一个继续按钮
-- @param titleKey 标题key，key从语言包中获取
-- @param msgKey 内容key，key从语言包中获取
-- @param continueCallback 点击继续按钮后的回调
-- @param cameraType 指定渲染模式
function DialogManager.ShowContinuePopByLang(titleKey, msgKey, continueCallback, cameraType, dialogType)
    return DialogManager.ShowContinuePop(lang.trans(titleKey), lang.trans(msgKey), continueCallback, cameraType, dialogType)
end

--- 显示确定弹窗，一个确定按钮，一个取消按钮
-- @param title 标题
-- @param msg 内容
-- @param confirmCallback 点击确定按钮后的回调
-- @param cancelCallback 点击取消按钮后的回调
-- @param cameraType 指定渲染模式
function DialogManager.ShowConfirmPop(title, msg, confirmCallback, cancelCallback, cameraType, dialogType)
    local content = {}
    content.title = title
    content.content = msg
    content.button1Text = lang.trans("cancel")
    content.onButton1Clicked = cancelCallback
    content.button2Text = lang.trans("confirm")
    content.onButton2Clicked = confirmCallback
    content.hideCloseIcon = true
    if dialogType == DialogManager.DialogType.GeneralBox then 
        return ShowGeneralBox(content, cameraType)
    else
        return ShowDialog(content, cameraType)
    end
end

--- 显示确定弹窗，一个确定按钮，一个取消按钮
-- @param titleKey 标题key，key从语言包中获取
-- @param msgKey 内容key，key从语言包中获取
-- @param confirmCallback 点击确定按钮后的回调
-- @param cancelCallback 点击取消按钮后的回调
-- @param cameraType 指定渲染模式
function DialogManager.ShowConfirmPopByLang(titleKey, msgKey, confirmCallback, cancelCallback, cameraType, dialogType)
    return DialogManager.ShowConfirmPop(lang.trans(titleKey), lang.trans(msgKey), confirmCallback, cancelCallback, cameraType, dialogType)
end

function DialogManager.ShowMessageBox(titleText, contentText, callback, button1Text, button2Text) 
    local content = { }
    content.title = titleText
    content.content = contentText
    content.button1Text = button1Text or lang.trans("cancel")
    content.button2Text = button2Text or lang.trans("confirm")
    content.onButton2Clicked = function()
        callback()
    end
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Control/Dialog/MessageBox.prefab", "overlay", true, true, nil, nil, 10000)
    dialogcomp.contentcomp:initData(content)
end

function DialogManager.ShowMessageBox_Extra(titleText, contentText, confirmCallback, cancelCallback, button1Text, button2Text) 
    local content = { }
    content.title = titleText
    content.content = contentText
    content.button1Text = button1Text or lang.trans("cancel")
	content.onButton1Clicked = cancelCallback
    content.button2Text = button2Text or lang.trans("confirm")
    content.onButton2Clicked = confirmCallback
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Control/Dialog/MessageBox.prefab", "overlay", true, true, nil, nil, 10000)
    dialogcomp.contentcomp:initData(content)
end

function DialogManager.ShowMessageBoxByTimer(titleText, contentText, button1Text, time, callback) 
    local content = { }
    content.title = titleText
    content.content = contentText
    content.button1Text = button1Text or lang.trans("confirm")
    content.onButton1Clicked = callback and function()
        callback()
    end
    content.autoCloseTime = time
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Control/Dialog/MessageBox.prefab", "overlay", true, true, nil, nil, 10000)
    dialogcomp.contentcomp:initData(content)
end

-- key 根据不同版本开启是否需要二次确认界面
local multipleControl = {["kr"] = true}
function DialogManager.ShowConfirmPopControl(key, title, msg, confirmCallback, cancelCallback, cameraType, dialogType)
    local resManager = clr.Capstones.UnityFramework.ResManager
    local flags = resManager.GetDistributeFlags()
    flags = clr.table(flags)
    if multipleControl[key] then 
        DialogManager.ShowConfirmPop(title, msg, confirmCallback, cancelCallback, cameraType, dialogType)
    elseif type(confirmCallback) == "function" then
        confirmCallback()
    end
end

--- 显示确定弹窗，一个确定按钮，一个取消按钮, 一个选择框
-- @param title 标题
-- @param msg 内容
-- @param confirmCallback 点击确定按钮后的回调
-- @param cancelCallback 点击取消按钮后的回调
-- @param cameraType 指定渲染模式
function DialogManager.ShowToggleConfirmPop(title, msg, toggleTxt, confirmCallback, cancelCallback, toggleCallback, cameraType)
    local content = {}
    content.title = title
    content.content = msg
    content.button1Text = lang.transstr("cancel")
    content.onButton1Clicked = cancelCallback
    content.button2Text = lang.transstr("confirm")
    content.onButton2Clicked = confirmCallback
    content.toggleTxt = toggleTxt
    content.onToggleClicked = toggleCallback
    content.hideCloseIcon = true
    return ShowMessageToggleBox(content, cameraType)
end

-- 带提示的弹框
function DialogManager.ShowMessageTipsBox(titleText, contentText, callback, button1Text, button2Text, tip1, tip2, tip3, cancelCallback1) 
    local content = { }
    content.title = titleText
    content.content = contentText
    content.button1Text = button1Text or lang.trans("cancel")
    content.button2Text = button2Text or lang.trans("confirm")
    content.tip1 = tip1 or ""
    content.tip2 = tip2
    content.tip3 = tip3
    content.onButton1Clicked = cancelCallback1 -- 点击取消/放弃按钮后的回调
    content.onButton2Clicked = callback
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Control/Dialog/MessageTipsBox.prefab", "overlay", true, true, nil, nil, 10000)
    dialogcomp.contentcomp:initData(content)
end

return DialogManager