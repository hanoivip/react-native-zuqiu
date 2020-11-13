local update = {}

local UnityEngine = clr.UnityEngine
local Application = UnityEngine.Application
local WWW = UnityEngine.WWW
local ResManager = clr.Capstones.UnityFramework.ResManager
local PlatDependant = clr.Capstones.PlatExt.PlatDependant

function update.checkzip(file)
    local stream = PlatDependant.OpenRead(file)
    if not stream then
        return false
    end

    local zip = clr.Unity.IO.Compression.ZipArchive(stream, clr.Unity.IO.Compression.ZipArchiveMode.Read)
    local correct = not not zip and not not zip.Entries
    if correct then
        for i, v in ipairs(clr.table(zip.Entries)) do
            dump(v.FullName)
        end
    end
    if zip then
        zip:Dispose()
    end

    stream:Dispose()

    return correct
end

function update.update(funcComplete, funcReport)
    if luaevt.trig("ShouldSkipUpdate") then
        return funcComplete(false)
    end
    local resp = req.checkVersion(nil, { [2002] = 1, [2003] = 1, })
    if api.success(resp) then
        luaevt.trig("BICheckPoint", "device_version_success", "4.2")
        -- login界面的背景图
        local loadingBg = resp.val.loadingBg
        if loadingBg then
            funcReport("loadingBg", loadingBg)
        end

        local version = resp.val.update
        if type(version) == 'table' then
            
            local cvtable = _G["___resver"];
            if type(cvtable) ~= 'table' then
                cvtable = {}
                _G["___resver"] = cvtable;
            end

            local newres = {}
            for i, v in ipairs(version) do
                if type(v) == 'table' then
                    local key = v.key
                    local ver = v.ver
                    local url = v.url
                    if type(url) == 'string' and type(key) == 'string' and type(ver) == 'number' then
                        if ver < 0 or tonumber(cvtable[key]) < ver then
                            if not funcReport('filter', key) then
                                newres[#newres + 1] = v
                            end
                        end
                    elseif type(ver) == 'string' then
                        newres[#newres + 1] = v
                    end
                end
            end

            if #newres > 0 then
				luaevt.trig("SDK_Report", "update_begin")
                local totallen = 0
                local quiet = true
                for i, v in ipairs(newres) do
                    local len = tonumber(v.len)
                    totallen = totallen + len
                    if not v.quiet then
                        quiet = false
                    end
                end
                local waitHandle = funcReport('cnt', #newres, totallen, quiet)
                if type(waitHandle) == 'table' then
                    while waitHandle.waiting do
                        coroutine.yield(UnityEngine.WaitForEndOfFrame())
                    end
                end

                for i, v in ipairs(newres) do
                    local key = v.key
                    local ver = v.ver
                    local url = v.url
                    local len = tonumber(v.len)
                    local itemsuccess = false
                    local retry_wait = 450

                    funcReport('prog', i)
                    funcReport('key', v.desc or "zip")
                    funcReport('ver', ver)

                    while not itemsuccess do
                        while retry_wait < 450 do
                            retry_wait = retry_wait + 1
                            coroutine.yield(UnityEngine.WaitForEndOfFrame())
                        end
                        retry_wait = 0
                        local updateFileIndex = 0;
                        if ver == '+dflag' then
                            ResManager.AddDistributeFlag(key)
                            itemsuccess = true
                        elseif ver == '-dflag' then
                            ResManager.RemoveDistributeFlag(key)
                            itemsuccess = true
                        elseif string.sub(url, -4) == '.zip' then
                            dump(v)
                            local zippath = Application.temporaryCachePath..'/download/update'..updateFileIndex..'.zip'
                            local enablerange = false
                            local rangefile = zippath..'.url'
                            local rangestream = PlatDependant.OpenReadText(rangefile)
                            if rangestream and rangestream ~= clr.null then
                                local ourl = rangestream:ReadLine()
                                rangestream:Dispose()
                                if ourl == url then
                                    if PlatDependant.IsFileExist(zippath) then
                                        enablerange = true
                                        dump('range enabled.')
                                    end
                                end
                            end
                            if not enablerange then
                                PlatDependant.DeleteFile(zippath)
                                local rangestream = PlatDependant.OpenWriteText(rangefile)
                                if rangestream and rangestream ~= clr.null then
                                    rangestream:Write(url)
                                    rangestream:Dispose()
                                end
                            end
							local stream = PlatDependant.OpenAppend(zippath)
                            --dump(stream)
							if stream then
								local prog = PlatDependant.DownloadLargeFile(url, stream, enablerange, nil)
                                dump(prog)
								if prog ~= nil then
									while not prog.Done do
										if len > 0 then
                                            if tonumber(v.rlen) > 0 then
                                                len = tonumber(v.rlen)
                                            end
                                            if tonumber(prog.Total) > 0 then
                                                len = tonumber(prog.Total)
                                            end
											funcReport('percent', math.clamp(prog.Length / len, 0, 1))
										else
											funcReport('streamlength', prog.Length)
										end
                                        retry_wait = retry_wait + 1
										coroutine.yield(UnityEngine.WaitForEndOfFrame())
									end
                                end
                                stream:Dispose()
                                if prog ~= nil then
									if prog.Error and prog.Error ~= "" then
                                        local msg = prog.Error
                                        if prog.Error == 'timedout' then
                                            msg = lang.transstr('timedOut')
                                        else
                                            msg = lang.transstr('networkError')
                                        end
										funcReport('error', msg)
										dump('update error - download error')
                                        dump(msg)
									else
										if update.checkzip(zippath) then
                                            funcReport('unzip')
                                            luaevt.trig("SDK_Report", "uncompress")
                                            
                                            local resindexdifffiles = {}
                                            local pendingPath = clr.updatepath..'/pending'
                                            local arrpendingFiles = clr.table(PlatDependant.GetAllFiles(pendingPath))
                                            dump(arrpendingFiles, "unzip...")
                                            if arrpendingFiles then
                                                for i, v in ipairs(arrpendingFiles) do
                                                    if string.sub(v, -18) == '.resindex.diff.txt' then
                                                        -- copy to some other place...
                                                        part = string.sub(v, string.len(pendingPath) + 2, -19)
                                                        local dest = clr.updatepath..'/pending2/'..part
                                                        resindexdifffiles[v] = dest
                                                        PlatDependant.MoveFile(v, dest)
                                                    end
                                                end
                                            end
                                            dump(resindexdifffiles)
                                            
                                            local prog = ResManager.UnzipPackageBackground(zippath, clr.updatepath..'/pending')
                                            while not prog.Done do
                                                funcReport('unzipprog')
                                                retry_wait = retry_wait + 1
                                                coroutine.yield(UnityEngine.WaitForEndOfFrame())
                                            end
                                            
                                            for k, v in pairs(resindexdifffiles) do
                                                if PlatDependant.IsFileExist(k) then
                                                    dump('merge '..v..' '..k)
                                                    ResManager.MergeResIndexDiff(v, k, k)
                                                else
                                                    dump('move '..v..' '..k)
                                                    PlatDependant.MoveFile(v, k)
                                                end
                                            end
                                            
                                            if prog.Error and prog.Error ~= "" then
										        funcReport('error', prog.Error)
										        dump('update error - zip file error')
                                                luaevt.trig("SDK_Report", "uncompress_result_fail")
                                            else
											    ResManager.RecordCacheVersion(key, ver)
											    itemsuccess = true
                                                dump('success '..url)
                                                luaevt.trig("SDK_Report", "uncompress_result_success")
                                            end
											PlatDependant.DeleteFile(zippath)
                                            dump('done and deleted '..zippath)
                                        else
                                            PlatDependant.DeleteFile(rangefile)
											funcReport('error', 'zip file is not correct')
											dump('update error - zip error')
										end
									end
								else
									stream:Dispose()
									funcReport('error', 'cannot start download.')
									dump('update error - download error')
								end
							else
                                updateFileIndex = updateFileIndex + 1
								funcReport('error', 'downloading file is in using.')
								dump('update error - download prepare error')
							end
                        else
                            if string.sub(key, 1, 7) == 'delfile' then
                                if type(v.path) == 'string' then
                                    PlatDependant.DeleteFile(clr.updatepath..'/'..v.path)
                                    ResManager.RecordCacheVersion(key, ver)
                                    itemsuccess = true
                                end
                            else
                                local wwwBundle = WWW(url)
                                while not wwwBundle.isDone do
                                    funcReport('percent', wwwBundle.progress)
                                    unity.waitForEndOfFrame()
                                end
                                if not wwwBundle.error or wwwBundle.error == '' then
                                    if string.sub(key, 1, 7) == 'scripts' then
                                        ResManager.DecompressScriptBundle(wwwBundle.assetBundle)
                                        ResManager.RecordCacheVersion(key, ver)
                                        itemsuccess = true
                                    elseif string.sub(key, 1, 7) == 'txtfile' then
                                        if type(v.path) == 'string' then
                                            local f = io.open(clr.updatepath..'/'..v.path, 'wb')
                                            if f then
                                                f:write(wwwBundle.bytes)
                                                f:flush()
                                                f:close()
                                                ResManager.RecordCacheVersion(key, ver)
                                                itemsuccess = true
                                            end
                                        end
                                    elseif string.sub(key, -6) == '.unity' then
                                        ResManager.UpdateResourceBundle(string.sub(key, 1, -7), clr.array(wwwBundle.bytes))
                                        ResManager.RecordCacheVersion(key, ver)
                                        itemsuccess = true
                                    else
                                        ResManager.UpdateResourceBundle(wwwBundle.assetBundle, clr.array(wwwBundle.bytes))
                                        ResManager.RecordCacheVersion(key, ver)
                                        itemsuccess = true
                                    end
                                end
                                wwwBundle:Dispose()
                            end
                        end
                    end
                end
                return funcComplete(true)
            else
                luaevt.trig("SDK_Report", "unupdate_result_pass")
            end
        else
            luaevt.trig("SDK_Report", "unupdate_result_pass")
        end
    elseif resp.failed == 2002 then
        funcReport('force_cold', true)
        luaevt.trig("SDK_Report", "force_cold")
        return
    elseif resp.failed == 2003 then
        clr.Capstones.UnityFramework.ResManager.ResetCacheVersion()
        unity.restart()
        return
    end
    funcComplete(false)
end

function update.reset()
    ResManager.ResetCacheVersion()
end

_G['update'] = update

return update