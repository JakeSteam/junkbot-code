global glob, version

on prepareMovie
  the actorList = []
  set the exitLock to 1
  the itemDelimiter = ","
  glob = [#EDITOR: [:], #catalog: [:], #PLAYER: [:]]
  glob[#config_manager] = new(script("config manager"))
  glob[#download_manager] = new(script("download manager"))
  glob[#legoparts_manager] = new(script("legoparts manager"))
  glob.PLAYER[#play_manager] = new(script("play manager"))
  glob[#database_manager] = new(script("database manager"))
  initSound()
  glob[#authorMode] = 0
  glob[#split_tall_members] = 1
  put "0" into field "editor par field"
  put EMPTY into field "catalog title"
  put EMPTY into field "editor hint field"
end

on startMovie
  glob[#rankdata] = [:]
  glob[#rankdata][#keys] = 0
  glob[#rankdata][#moves] = 0
  glob[#rankdata][#rank] = 0
  glob[#rankdata][#players] = 0
  glob.download_manager.begin()
  glob.database_manager.getState()
end

on movieloaded
  glob.PLAYER[#game_manager] = new(script("game manager"))
  glob.EDITOR[#edit_manager] = new(script("edit manager"))
  glob.catalog[#catalog_manager] = new(script("catalog manager"))
end

on stopMovie
  the actorList = []
end

on streamStatus URL, state, bytesSoFar, bytesTotal, error
  glob.download_manager.streamStatus(URL, state, bytesSoFar, bytesTotal)
end

on keyDown me
  sendAllSprites(#equiv_keydown, the key)
end

on gbutton msg
  case msg of
    #main_edit:
      do_editor()
    #main_play:
      do_player()
    #main_catalog:
      do_catalog()
  end case
end

on do_editor
  if the frame = marker("play") then
    glob.PLAYER.play_manager.leave()
  end if
  go(marker("edit"))
  glob.EDITOR.edit_manager.refresh()
end

on do_catalog
  if the frame = marker("edit") then
    glob.EDITOR.edit_manager.leave()
  end if
  if the frame = marker("play") then
    glob.PLAYER.play_manager.leave()
  end if
  go(marker("catalog"))
  glob.catalog.catalog_manager.catalog()
end

on do_player
  if the frame = marker("edit") then
    glob.EDITOR.edit_manager.leave()
  end if
  glob.PLAYER.game_manager.startGame()
end

on setCursorEffect ce
  if glob[#cursor] = VOID then
    glob[#cursor] = [:]
  end if
  glob[#cursor][ce] = 1
  setCursor()
end

on clearCursorEffect ce
  if glob[#cursor] = VOID then
    glob[#cursor] = [:]
  end if
  if ce = #all then
    glob[#cursor] = [:]
  else
    glob[#cursor][ce] = 0
  end if
  setCursor()
end

on setCursor c
  if glob[#cursor] = VOID then
    glob[#cursor] = [:]
  end if
  if ilk(c) = #symbol then
    glob[#cursor] = [:]
    glob[#cursor][c] = 1
  end if
  if glob[#cursor][#text] then
    cursor(0)
  else
    if glob[#cursor][#grab_up] then
      cursor([member("grab_up cursor").memberNum, member("grab cursor mask").memberNum])
    else
      if glob[#cursor][#grab_down] then
        cursor([member("grab_down cursor").memberNum, member("grab cursor mask").memberNum])
      else
        if glob[#cursor][#grab_both] then
          cursor([member("grab_both cursor").memberNum, member("grab cursor mask").memberNum])
        else
          if glob[#cursor][#grabber] then
            cursor([member("grabber cursor").memberNum, member("grabber cursor mask").memberNum])
          else
            if glob[#cursor][#eraser] = 1 then
              cursor([member("eraser cursor").memberNum, member("eraser cursor mask").memberNum])
            else
              cursor(0)
            end if
          end if
        end if
      end if
    end if
  end if
end

on enterFrame
  put "My name is Junkbot"
end

on exitFrame
  put "I love to eat trash"
end

on prepareFrame
  put "Junk is food!"
end

on showGlobals
  put "version = " & QUOTE & "8.0"
end
