property gameState, currentLevel, currentLevelIndex, levelList
global glob

on new me
  gameState = #PREGAME
  me.prepareLevelMenu()
  return me
end

on prepareLevelMenu me
  glob[#building] = [[#state: #open, #LEVELS: []]]
  building = 1
  level = 1
  repeat with n = 1 to the number of castMembers of castLib "levels"
    levelmem = member(n, "levels")
    leveldata = glob.config_manager.parseParams(levelmem.text)
    leveldata.info.title = glob.config_manager.restoreCommas(leveldata.info.title)
    leveldata.info.hint = glob.config_manager.restoreCommas(leveldata.info.hint)
    glob.building[building].LEVELS[level] = [#index: n, #title: leveldata.info.title, #goal: leveldata.info.par, #moves: 0, #data: levelmem.text, #info: leveldata.info]
    keys = integer(externalParamValue("sw2"))
    if voidp(keys) then
      keys = 10
    end if
    glob[#keyrequired] = 10
    glob[#current] = [#building: 1, #level: 1, #moves: 0]
    level = level + 1
    if level > 15 then
      level = 1
      building = building + 1
      glob.building[building] = [#state: #locked, #LEVELS: []]
    end if
    glob[#plaque] = "welcome"
  end repeat
  glob[#hof] = 60
  glob[#rankdata][#serverState] = #network
  record = glob.database_manager.getRecord()
  if not voidp(record) then
    me.decodeRecord(record)
  end if
  me.TotalKeys()
  if glob.rankdata.keys >= glob.hof then
    glob.rankdata[#AlreadySawHOF] = #YES
  end if
end

on encodeREcord me
  rec = [:]
  state = 2
  record = EMPTY
  total = 0
  repeat with bn = 1 to glob.building.count
    b = glob.building[bn]
    repeat with ln = 1 to b.LEVELS.count
      L = b.LEVELS[ln]
      if (bn = glob.current.building) and (ln = glob.current.level) then
        m = glob.current.moves
      else
        m = L.moves
      end if
      if m = 0 then
        state = 0
        next repeat
      end if
      total = total + m
      if (state > 0) and (m > L.goal) then
        state = 1
      end if
      if m > 999 then
        m = "+"
      end if
      record = record & L.index & " " & m & ","
    end repeat
  end repeat
  delete char -30000 of record
  rec[#state] = state
  rec[#total] = total
  rec[#record] = record
  me.TotalKeys()
  glob.rankdata[#moves] = total
  return rec
end

on decodeRecord me, rec
  repeat with i = 1 to rec.record.item.count
    Entry = item i of the record of rec
    n = integer(word 1 of Entry)
    m = integer(word 2 of Entry)
    if voidp(n) or voidp(m) then
      next repeat
    end if
    building = integer((n - 1) / 15) + 1
    level = n - (15 * (building - 1))
    glob.building[building].LEVELS[level].moves = m
  end repeat
  glob.rankdata[#moves] = rec.total
end

on setGame me, L
  levelList = L
  currentLevelIndex = 1
end

on selectlevel me
  me.exitGame()
  go("levels")
end

on startGame me
  go("play")
  me.startLevel()
end

on restartLevel me
  glob.PLAYER.play_manager.leave()
  glob.PLAYER.play_manager.setLevel(currentLevel)
  glob.PLAYER.play_manager.startLevel()
end

on pauseLevel me, flag
  if gameState = #INLEVEL then
    glob.PLAYER.play_manager.pauseLevel(flag)
  end if
end

on exitGame me
  glob.PLAYER.play_manager.leave()
  SndMusicEnd()
end

on gameOverButton me
  glob.PLAYER.play_manager.leave()
  gameState = #PREGAME
  SndMusicEnd()
  glob.download_manager.mainmenu()
end

on callback me, p
  case p of
    #com_nextlevel:
      glob.current.level = glob.current.level + 1
      me.startLevel()
    #title_done:
      glob.PLAYER.play_manager.startLevel()
    #restart_level:
      me.startGame()
    #select_level:
      me.selectlevel()
  end case
end

on endLevel me, winOrLose
  SndMusicEnd()
  setCursor(#none)
  if winOrLose = #WIN then
    glob.current.moves = glob.PLAYER.play_manager.gamestatus.moves
    SndSFX("voice_ohyeah")
    me.intermission()
    glob.database_manager.setRecord(me.encodeREcord())
  else
    me.loseGame()
  end if
end

on startLevel me
  glob.PLAYER.play_manager.leave()
  SndMusicStart("level" & random(5))
  if voidp(levelList) then
    if glob.current.level > glob.building[glob.current.building].LEVELS.count then
      me.selectlevel()
    else
      currentLevel = glob.building[glob.current.building].LEVELS[glob.current.level].data
      glob.PLAYER.play_manager.setLevel(currentLevel)
      glob.title_obj.updateData([glob.current.building, glob.current.level, glob.building[glob.current.building].LEVELS[glob.current.level].title], [#object: me, #parameter: #title_done])
    end if
  else
    currentLevel = levelList[currentLevelIndex]
    glob.PLAYER.play_manager.setLevel(currentLevel)
    glob.PLAYER.play_manager.startLevel()
  end if
end

on loseGame me
  SndMusicEnd()
  gameState = #loseGame
  glob.fail_msg_obj.updateData()
end

on finishGame me
  SndMusicEnd()
  gameState = #finishGame
  glob.PLAYER[#signsprite].showSign("signGameFinish", #gameOverButton)
end

on intermission me
  gameState = #INTERLEVEL
  glob[#master_obj].dropBox()
end

on TotalKeys me
  keys = 0
  repeat with i = 1 to 4
    building = glob[#building][i][#LEVELS]
    repeat with j = 1 to building.count
      if building[j][#moves] > 0 then
        keys = keys + 1
      end if
    end repeat
  end repeat
  glob[#rankdata][#keys] = keys
end

on goldTotal me
  gotgold = 0
  repeat with building = 1 to 4
    repeat with level = 1 to 15
      moves = glob[#building][building][#LEVELS][level][#moves]
      goal = glob[#building][building][#LEVELS][level][#goal]
      if (moves > 0) and (goal >= moves) then
        gotgold = gotgold + 1
        glob[#building][building][#LEVELS][level][#gold] = 1
      end if
    end repeat
  end repeat
  return gotgold
end

on updatePlaque me
  gotgold = me.goldTotal()
  if gotgold = 60 then
    glob[#plaque] = "president"
  else
    if gotgold >= 40 then
      glob[#plaque] = "year"
    else
      if gotgold >= 30 then
        glob[#plaque] = "Month"
      else
        if gotgold >= 20 then
          glob[#plaque] = "week"
        else
          if gotgold >= 10 then
            glob[#plaque] = "day"
          else
            glob[#plaque] = "welcome"
          end if
        end if
      end if
    end if
  end if
  return gotgold
end
