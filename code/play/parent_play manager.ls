property config, playfield_manager, dragmember, toolmode, movepart, moveoffset, mousestate, myactors, myactorstime, tracktime, reported_fieldpos, gamestatus, activeState, movePieceGroup, pressLoc, pressPos, goalList, numGoals
global glob

on new me
  activeState = #STANDBY
  toolmode = #move
  myactors = []
  goalList = []
  myactorstime = [:]
  tracktime = 0
  reported_fieldpos = VOID
  add(the actorList, me)
  return me
end

on destroy me
  leave(me)
  deleteOne(the actorList, me)
end

on leave me
  me.clearDragBricks()
  glob.PLAYER[#partclick_recipient] = VOID
  activeState = #STANDBY
  setCursor(#none)
  myactors = []
  if playfield_manager <> VOID then
    playfield_manager.leave()
  end if
  playfield_manager = VOID
end

on refresh me
  setLevel(me, glob.EDITOR.edit_manager.playfield_manager.current_level)
end

on actorDone me, a
  myactors.deleteOne(a)
  myactorstime.deleteOne(a)
end

on setLevel me, conf
  toolmode = #move
  if ilk(conf) = #string then
    config = glob.config_manager.parseParams(conf)
  else
    config = conf
  end if
  playfield_manager = new(script("playfield manager"), config.playfield)
  playfield_manager.setPlayfield(config)
  if not voidp(config[#info]) then
    member("level title").text = config.info[#title] && "(" & config.info[#par] & ")"
  end if
  myactors = []
  mytypes = [#MINIFIG: "minifig walk parent", #haz_walker: "hazard walk parent", #HAZ_FLOAT: "hazard float parent", #HAZ_DUMBFLOAT: "hazard dumbfloat parent", #HAZ_CLIMBER: "hazard climb parent", #HAZ_SLICKFAN: "hazard slick fan parent", #HAZ_SLICKFIRE: "hazard slick fire parent", #haz_slickJump: "hazard slick jump parent", #BRICK_SLICKJUMP: "hazard slick jump parent", #HAZ_SLICKPIPE: "hazard slick pipe parent", #HAZ_SLICKSWITCH: "hazard slick switch parent", #HAZ_SLICKSHIELD: "hazard slick shield parent"]
  repeat with a = 1 to mytypes.count
    active_part_type = mytypes.getPropAt(a)
    behavior_script_name = mytypes[a]
    repeat with active_part in playfield_manager.getPartsByType([active_part_type])
      newactor = new(script(behavior_script_name), active_part)
      myactors.add(newactor)
      if tracktime then
        myactorstime.addProp(newactor, 0)
      end if
    end repeat
  end repeat
  goalList = playfield_manager.getPartsByType([#flag])
  numGoals = goalList.count
  gamestatus = [#damage: 0, #goals: 0, #moves: 0]
  me.updateStatus()
  activeState = #pause
end

on startLevel me
  glob.PLAYER[#partclick_recipient] = me
  activeState = #Run
end

on pauseLevel me, flag
  if flag then
    glob.PLAYER[#partclick_recipient] = VOID
    activeState = #pause
  else
    glob.PLAYER[#partclick_recipient] = me
    activeState = #Run
  end if
end

on setdragsprite me, opt
  if glob.EDITOR[#drag_sprite] = VOID then
    return 
  end if
  glob.EDITOR.drag_sprite.puppet = 1
  if opt = #reset then
    glob.EDITOR.drag_sprite.loc = point(-100, -100)
    glob.EDITOR.drag_sprite.blend = 100
    return 
  else
    if ilk(opt) = #propList then
      myType = opt.type
      myColor = opt.color
      myMember = opt.member
    else
      return 
    end if
  end if
  dragmember = myMember
  glob.EDITOR.drag_sprite.member = myMember
  glob.EDITOR.drag_sprite.width = glob.EDITOR.drag_sprite.member.width * playfield_manager.pf_scale
  glob.EDITOR.drag_sprite.height = glob.EDITOR.drag_sprite.member.height * playfield_manager.pf_scale
end

on instantWin me
  if glob[#authorMode] <> 1 then
    return 
  end if
end

on addStatus me, p, d
  case p of
    #damage:
      SndSFX("die")
      activeState = #pause
      me.clearDragBricks()
      setCursor(#none)
      glob.PLAYER.game_manager.endLevel(#LOSE)
      setCursor(#none)
    #goals:
      numGoals = numGoals - 1
      if numGoals = 0 then
        activeState = #pause
        me.clearDragBricks()
        setCursor(#none)
        glob.PLAYER.game_manager.endLevel(#WIN)
        setCursor(#none)
      end if
  end case
  gamestatus[p] = gamestatus[p] + d
  me.updateStatus()
end

on updateStatus me
  t = EMPTY
  repeat with i = 1 to gamestatus.count
    t = t & gamestatus.getPropAt(i) & ":" && gamestatus[i] & RETURN
  end repeat
  member("play status field").text = t
  member("play move counter field").text = string(gamestatus.moves)
end

on doSwitch me, args
  repeat with part in playfield_manager.getPartsByLabel(args.label)
    part.behavior.notify([#switch: args.state])
  end repeat
end

on clearDragBricks me
  if ilk(movePieceGroup) = #list then
    repeat with ss in movePieceGroup
      repeat with s in ss.sprite
        s.loc = point(-200, -200)
      end repeat
    end repeat
  end if
end

on partclick me, part, evt
  case evt of
    #mouseEnter:
      reported_fieldpos = [part.pos, part.sprite[1].loc]
    #mouseLeave:
      reported_fieldpos = VOID
  end case
end

on stepFrame me
  if not (activeState = #Run) then
    return 
  end if
  if glob.EDITOR[#drag_sprite] = VOID then
    return 
  end if
  if playfield_manager = VOID then
    return 
  end if
  repeat with a in myactors.duplicate()
    ms = the milliSeconds
    a.stepFrame()
    if tracktime then
      myactorstime[a] = myactorstime[a] + the milliSeconds - ms
    end if
  end repeat
  if toolmode = VOID then
    toolmode = #move
  end if
  if the mouseDown then
    if mousestate = #UP then
      mousestate = #press
    else
      mousestate = #down
    end if
  else
    if mousestate = #down then
      mousestate = #release
    else
      mousestate = #UP
    end if
  end if
  ml = the mouseLoc
  if toolmode = #dragging then
    ml = ml + moveoffset
  end if
  fieldpos = playfield_manager.getPos(ml)
  case toolmode of
    #dragging:
      if fieldpos = VOID then
        repeat with mp in movePieceGroup
          repeat with s in mp.sprite
            s.blend = 0
          end repeat
        end repeat
      else
        posOffSet = fieldpos[1] - movePieceGroup[1].pos
        locOffset = pressLoc - movePieceGroup[1].sprite[1].loc
        everythingPlaceable = 1
        fitDir = VOID
        repeat with mp in movePieceGroup
          check = playfield_manager.checkPlaceable(mp.pos + posOffSet, mp.type)
          if check = #nofit then
            everythingPlaceable = 0
            exit repeat
            next repeat
          end if
          if check = #above then
            if fitDir = #below then
              everythingPlaceable = 0
              exit repeat
            else
              fitDir = #above
            end if
            next repeat
          end if
          if check = #below then
            if fitDir = #above then
              everythingPlaceable = 0
              exit repeat
            else
              fitDir = #below
            end if
            next repeat
          end if
        end repeat
        if voidp(fitDir) then
          everythingPlaceable = 0
        end if
        repeat with mp in movePieceGroup
          repeat with si = 1 to mp.sprite.count
            s = mp.sprite[si]
            s.loc = playfield_manager.getLoc(mp.pos + posOffSet)
            s.locZ = playfield_manager.posToLocZ(mp.pos + posOffSet - point(0, si - 1))
            if everythingPlaceable then
              s.blend = 75
              next repeat
            end if
            s.blend = 25
          end repeat
        end repeat
        if everythingPlaceable and ((mousestate = #press) or (mousestate = #release)) then
          repeat with mp in movePieceGroup
            mp.pos = mp.pos + posOffSet
            playfield_manager.placePiece(mp)
          end repeat
          toolmode = #move
          SndSFX("blockdrop")
          movePieceGroup = []
        end if
      end if
    #move:
      if not voidp(reported_fieldpos) then
        fieldpos = reported_fieldpos
      end if
      if voidp(fieldpos) then
        setCursor(#none)
      else
        temp = [:]
        temp[#down] = playfield_manager.findPieceGroup(fieldpos[1], #down)
        temp[#UP] = playfield_manager.findPieceGroup(fieldpos[1], #UP)
        if (temp[#down] = []) and (temp[#UP] = []) then
          setCursor(#none)
        else
          if temp[#down] = [] then
            setCursor(#grab_up)
          else
            if temp[#UP] = [] then
              setCursor(#grab_down)
            else
              setCursor(#grab_both)
            end if
          end if
          if mousestate = #press then
            pressLoc = ml
            pressPos = fieldpos[1]
            toolmode = #pressing
            SndSFX("blockclick")
            me.doPressing(ml)
          end if
        end if
      end if
    #pressing:
      me.doPressing(ml)
  end case
  if keyPressed(" ") and (activeState = #Run) then
    me.instantWin()
  end if
end

on doPressing me, ml
  temp = [:]
  temp[#down] = playfield_manager.findPieceGroup(pressPos, #down)
  temp[#UP] = playfield_manager.findPieceGroup(pressPos, #UP)
  dragDir = 0
  pressOffSet = ml - pressLoc
  if (pressOffSet[2] > 3) or (temp[#UP] = []) then
    dragDir = #down
  end if
  if (pressOffSet[2] < -3) or (temp[#down] = []) then
    dragDir = #UP
  end if
  if dragDir = 0 then
    if mousestate = #release then
      toolmode = #move
    end if
  end if
  if not (dragDir = 0) then
    movePieceGroup = temp[dragDir]
    if movePieceGroup = [] then
      if abs(pressOffSet[2]) > 20 then
        toolmode = #move
      end if
    else
      playfield_manager.erasePieceGroup(movePieceGroup, 1)
      moveoffset = playfield_manager.getLoc(movePieceGroup[1].pos + point(0, -1)) - pressLoc
      repeat with mp in movePieceGroup
        repeat with s in mp.sprite
          s.blend = 75
        end repeat
      end repeat
      toolmode = #dragging
      setCursor(#grabber)
      SndSFX("blockpickup")
      me.addStatus(#moves, 1)
    end if
  end if
end
