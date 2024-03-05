property selected, data, dataAct
global glob

on beginSprite me
  glob[#level_scrn_obj] = me
  data = glob[#building]
  me.setBuilding(glob[#current][#building])
end

on enterFrame me
  SndMusicEnd()
end

on totalMoves me
end

on setBuilding me, num
  selected = num
  dataAct = data[num]
  me.checkKeys()
  me.updateTabs()
  me.updateList()
end

on checkKeys me
  repeat with i = 1 to 4
    keys = 0
    building = data[i][#LEVELS]
    repeat with j = 1 to building.count
      if building[j][#moves] > 0 then
        keys = keys + 1
      end if
    end repeat
    if (i < 4) and (keys >= glob[#keyrequired]) then
      data[i + 1][#state] = #open
    end if
  end repeat
end

on updateTabs me
  sprite(11).member = member("TAB." & selected)
  repeat with sn = 1 to 4
    case data[sn][#state] of
      #locked:
        sprite(11 + sn + 4).member = member("building_icon_" & sn & "_locked")
        num = 20
      #open:
        sprite(11 + sn + 4).member = member("building_icon_" & sn)
        if selected = sn then
          num = 100
        else
          num = 50
        end if
    end case
    sprite(11 + sn).blend = num
  end repeat
end

on updateList me
  LEVELS = dataAct[#LEVELS]
  titleText = EMPTY
  movesText = EMPTY
  repeat with L = 1 to LEVELS.count
    if LEVELS[L][#moves] = 0 then
      tempMoves = EMPTY
    else
      tempMoves = LEVELS[L][#moves]
    end if
    movesText = movesText & tempMoves & RETURN
    titleText = titleText & LEVELS[L][#title] & RETURN
    if LEVELS[L][#moves] > 0 then
      sprite(39 + L).member = member("checkbox_on")
      sprite(39 + L).blend = 100
      if LEVELS[L][#goal] >= LEVELS[L][#moves] then
        sprite(54 + L).blend = 100
      else
        sprite(54 + L).blend = 0
      end if
      next repeat
    end if
    sprite(39 + L).member = member("checkbox_off")
    sprite(39 + L).blend = 100
    sprite(54 + L).blend = 0
  end repeat
  member("level.name").text = titleText
  member("level.name").FixedLinespace = 21
  member("level.moves").text = movesText
  member("level.moves").alignment = #right
  member("level.moves").FixedLinespace = 21
end

on roTab me, snum, bnum
  if data[snum - 23][#state] = #open then
    return 0
  end if
  sprite(snum - 4).blend = bnum
  return 1
end

on tabClicked me, snum
  clicked = snum - 23
  if data[clicked][#state] = #locked then
    SndSFX("spring_1")
    exit
  end if
  if clicked = selected then
    exit
  end if
  SndSFX("h_powerup3")
  glob.current.building = clicked
  me.setBuilding(clicked)
end

on exitFrame me
  go(the frame)
end
