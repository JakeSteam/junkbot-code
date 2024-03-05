property cgi, netids, cattext, localmode, localprefix, localcatalog, database, levelCache, idToBeCached, levelTitles
global glob

on new me
  localmode = (the environment).internetConnected = #offline
  database = "alpha"
  levelCache = []
  levelTitles = []
  netids = []
  cgi = "http://www.urth.net/lego_db/levels.cgi"
  localprefix = "lego"
  cattext = member("catalog text")
  add(the actorList, me)
  idToBeCached = []
  return me
end

on clickLoad me, rowid
  levelList = []
  repeat with i = integer(rowid) down to 1
    if levelCache[i] = 0 then
      next repeat
    end if
    levelList.add(levelCache[i])
  end repeat
  glob.PLAYER.game_manager.setGame(levelList)
  glob.EDITOR.edit_manager.playfield_manager.current_level = levelList[1]
end

on load me, rowid
  if localmode then
    t = getPref(localprefix & rowid)
    alert("Level loaded")
  else
    if netids.count > 0 then
      return 
    end if
    nid = postNetText(cgi, [#mode: "load", #rowid: rowid, #database: database])
    netids.add([nid, #load, rowid])
  end if
end

on catalog me
  if localmode then
    t = getPref(localprefix & "cat")
    if t = VOID then
      t = EMPTY
      setPref(localprefix & "cat", t)
    end if
    me.do_catalog_2(t)
  else
    if netids.count > 0 then
      return 
    end if
    nid = postNetText(cgi, [#mode: "load", #rowid: "all", #database: database])
    netids.add([nid, #catalog])
    cattext.text = EMPTY
  end if
end

on save me
  if localmode then
    me.catalog()
    localcatalog.Entry.add([#name: member("catalog name").text, #title: member("catalog title").text, #comment: member("catalog comment").text])
    t = EMPTY
    repeat with i = 1 to localcatalog.Entry.count
      e = localcatalog.Entry[i]
      t = t & "[Entry " & i & "]" & RETURN
      t = t & "Name=" & e.name & RETURN
      t = t & "Title=" & e.title & RETURN
      t = t & "Comment=" & e.comment & RETURN
      t = t & RETURN
    end repeat
    setPref(localprefix & "cat", t)
    setPref(localprefix & localcatalog.Entry.count, glob.EDITOR.edit_manager.playfield_manager.current_level)
    me.do_catalog_2(t)
  else
    if netids.count > 0 then
      return 
    end if
    nid = postNetText(cgi, [#mode: "save", #name: member("catalog name").text, #title: member("catalog title").text, #comment: member("catalog comment").text, #level: glob.EDITOR.edit_manager.playfield_manager.current_level, #database: database])
    netids.add([nid, #save])
  end if
end

on do_catalog me, nid
  t = netTextResult(nid)
  me.do_catalog_2(t)
end

on do_catalog_2 me, t
  rawlevels = []
  clevel = VOID
  nlt = the number of lines in t
  repeat with ln = 1 to nlt
    L = line ln of t
    if word 1 of L = "<<<<" then
      clevel = integer(word 2 of L)
      rawlevels[clevel] = EMPTY
    else
      if not voidp(clevel) then
        rawlevels[clevel] = rawlevels[clevel] & L & RETURN
      end if
    end if
    if (ln mod 100) = 0 then
      cattext.text = "Scanning" && ln && "of" && nlt
      updateStage()
    end if
  end repeat
  menutext = EMPTY
  hyperlinkID = []
  repeat with entrynum = rawlevels.count down to 1
    rl = rawlevels[entrynum]
    if rl = 0 then
      next repeat
    end if
    hyperlinkID.add(entrynum)
    menutext = menutext & line 2 of rl && "by" && line 1 of rl && "(" & line 3 of rl && ")" & RETURN
    levelTitles[entrynum] = line 2 of rl
    delete line 1 to 4 of rl
    levelCache[entrynum] = rl
  end repeat
  delete char -30000 of menutext
  cattext.text = menutext
  i = 0
  repeat with i = 1 to the number of lines in the text of cattext
    hl = string(hyperlinkID[i])
    member(cattext).line[i].Hyperlink = hl
  end repeat
end

on prepareCache me, hyperlinkID
  repeat with id in hyperlinkID
    if id > levelCache.count then
      idToBeCached.add(id)
      next repeat
    end if
    if not (ilk(levelCache[id]) = #string) then
      idToBeCached.add(id)
    end if
  end repeat
end

on do_save me, nid
  me.catalog()
end

on do_load me, nid, rowid
  t = netTextResult(nid)
  levelCache[rowid] = t
end

on stepFrame me
  if netids.count = 0 then
    sendAllSprites(#netReady, 1)
    return 
  end if
  sendAllSprites(#netReady, 0)
  streamsofar = 0
  streamtotal = 0
  repeat with nid in netids
    ss = getStreamStatus(nid[1])
    streamsofar = streamsofar + ss.bytesSoFar
    streamtotal = streamtotal + ss.bytesTotal
    if nid[2] = #catalog then
      cattext.text = "Loading" && streamsofar && "of about 200,000"
    end if
    if netDone(nid[1]) then
      netids.deleteOne(nid)
      case nid[2] of
        #load:
          me.do_load(nid[1], nid[3])
        #catalog:
          me.do_catalog(nid[1])
        #save:
          me.do_save(nid[1])
      end case
    end if
  end repeat
  if (netids.count = 0) and (idToBeCached.count > 0) then
    id = idToBeCached[1]
    idToBeCached.deleteAt(1)
    me.load(id)
    put "caching" && id
  end if
end
