property files, state, displaysprites, displaysaveloc, loadingbricksprites, nextbrick, readybrick, brickdropspeed, blinktimer, bumpertimer, loadp
global glob

on new me
  files = [the moviePath && the movieName]
  state = #preload
  displaysprites = [#intro_anim: [sprite(15), sprite(11), sprite(14), sprite(16)], #intro_level: [sprite(10), sprite(12), sprite(13)], #intro_level_note: [sprite(12), sprite(13)], #loaded_arrows: [sprite(3), sprite(4), sprite(5), sprite(6)], #loading_msg: [sprite(7)], #go_btn: [sprite(8), sprite(17)]]
  displaysaveloc = [:]
  loadp = 0
  member("download_msg").text = "DOWNLOAD IN PROGRESS"
  me.db("new")
  return me
end

on db me, t
end

on begin me
  bumpertimer = the ticks
  (the actorList).add(me)
  me.db("begin")
  nextbrick = 1
  readybrick = 0
  if the runMode contains "Plugin" then
    if frameReady() then
      me.streamStatus(EMPTY, "Complete", 1000, 1000, "OK")
      me.db("plugin frameready")
    else
      me.db("plugin not frameready")
      tellStreamStatus(1)
    end if
  else
    me.db("not plugin")
    me.streamStatus(EMPTY, "Complete", 1000, 1000, "OK")
  end if
end

on loadingframe me
  go("loading")
  me.db("loadingframe")
  SndMusicStart("intro")
  displaysaveloc = [:]
  displaysaveloc.addProp(sprite(15), sprite(15).loc)
  me.show([#intro_anim], 1)
  me.show([#intro_level], 0)
  brickdropspeed = 60
  loadingbricksprites = []
  repeat with i = 21 to 34
    loadingbricksprites.add([#sprite: sprite(i), #locV: sprite(i).locV])
    sprite(i).locV = (sprite(i).locV mod brickdropspeed) - brickdropspeed - 20
    sprite(i).visible = 1
  end repeat
  state = #intro_anim
  blinktimer = the ticks
end

on mainmenu me
  go("mainmenu")
  SndMusicStart("intro")
  me.show([#intro_level], 1)
  me.show([#intro_level_note, #intro_anim], 0)
  me.animDone()
  me.show([#go_btn], 1)
  repeat with lbs in loadingbricksprites
    lbs.sprite.visible = 1
  end repeat
end

on finish me, nextframe
  state = #done
  tellStreamStatus(0)
  (the actorList).deleteOne(me)
  repeat with sl in displaysprites
    repeat with s in sl
      s.visible = 1
      sloc = displaysaveloc.getaProp(s)
      if not voidp(sloc) then
        s.loc = sloc
      end if
    end repeat
  end repeat
  repeat with i = 1 to 50
    sprite(i).locZ = i
  end repeat
  go(nextframe)
end

on show me, which, v
  repeat with dsn in which
    repeat with s in displaysprites[dsn]
      s.visible = v
      sloc = displaysaveloc.getaProp(s)
      if not voidp(sloc) then
        if v then
          s.loc = sloc
          next repeat
        end if
        s.loc = point(1000, 1000)
      end if
    end repeat
  end repeat
end

on animDone me
  state = #sample_level
  me.show([#intro_anim], 0)
  me.show([#intro_level], 1)
  currentLevel = member("loading_level").text
  glob.PLAYER.play_manager.setLevel(currentLevel)
  glob.PLAYER.play_manager.startLevel()
end

on gbutton me, which
  case which of
    #Ok:
      if state = #sample_level then
        glob.PLAYER.play_manager.leave()
      end if
      me.finish("levels")
    #credits:
      if state = #sample_level then
        glob.PLAYER.play_manager.leave()
      end if
      me.finish("credits")
    #replay:
      if state = #sample_level then
        glob.PLAYER.play_manager.leave()
        me.show([#intro_anim], 1)
        me.show([#intro_level], 0)
        state = #intro_msg
      end if
      displaysprites[#intro_anim][1].gotoFrame(1)
      displaysprites[#intro_anim][1].play()
    #cleanup:
      if state = #sample_level then
        currentLevel = member("loading_level").text
        glob.PLAYER.play_manager.leave()
        glob.PLAYER.play_manager.setLevel(currentLevel)
        glob.PLAYER.play_manager.startLevel()
      end if
    #skip_movie:
      if state <> #sample_level then
        me.animDone()
      end if
  end case
end

on streamStatus me, URL, state, bytesSoFar, bytesTotal, error
  me.db("streamstatus" && bytesSoFar && bytesTotal && error)
  if bytesTotal = 0 then
    return 
  end if
  readybrick = bytesSoFar * 14 / bytesTotal
end

on stepFrame me
  me.db("stepframe nextbrick" && nextbrick && "readybrick" && readybrick)
  if state = #preload then
    if frameReady(1, marker("loading")) and (the ticks > (bumpertimer + 110)) then
      me.loadingframe()
    end if
  else
    if loadp then
    else
      if (nextbrick > loadingbricksprites.count) and glob.database_manager.READY() then
        me.show([#go_btn], 1)
        displaysprites.loading_msg[1].member.text = "READY TO PLAY"
        blinktimer = the ticks
        loadp = 1
        movieloaded()
      else
        if readybrick >= nextbrick then
          nb = loadingbricksprites[nextbrick]
          if nb.sprite.locV = nb.locV then
            nextbrick = nextbrick + 1
          else
            nb.sprite.locV = nb.sprite.locV + brickdropspeed
            if nb.sprite.locV > nb.locV then
              nb.sprite.locV = nb.locV
            end if
          end if
        end if
      end if
    end if
  end if
end
