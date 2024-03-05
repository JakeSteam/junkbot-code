property Prop, myNum, keys
global glob

on beginSprite me
  myNum = me.spriteNum
  glob[#BIG_MSG_OBJ] = me
  Prop = [:]
  Prop[#state] = #hide
  Prop[#loc] = [#Start: point(60, -280), #show: point(60, 80), #end: point(-340, 80)]
  Prop[#speed] = [#move1: [0, 40], #move2: [-40, 0]]
  Prop[#sprites] = [#MSG1: myNum + 9, #MSG2: myNum + 10, #MSG3: myNum + 11, #newrecord: myNum + 2, #gold: myNum + 3, #bicon: myNum + 4, #keys: myNum + 8]
  Prop[#todo] = []
end

on reportState me
  return Prop[#state]
end

on dropBox me
  setCursor(#none)
  sendAllSprites(#getOut)
  Prop[#state] = #move1
  me.fixLocZ()
  me.updateData1()
end

on updateData1 me
  Prop[#todo] = []
  building = glob[#current][#building]
  level = glob[#current][#level]
  moves = glob[#current][#moves]
  gold = glob[#building][building][#LEVELS][level][#gold]
  if level > 15 then
    exit
  end if
  repeat with x = 1 to 4
    if glob[#building][x][#state] = #open then
      sprite(x + (Prop[#sprites][#bicon] - 1)).member = member("building_icon_" & x)
      updateStage()
    end if
  end repeat
  member("num.moves").text = string(moves)
  flag = 0
  sprite(Prop[#sprites][#newrecord]).blend = 0
  data = glob[#building][building][#LEVELS]
  keys = 0
  repeat with i = 1 to 15
    if i = level then
      if data[i][#moves] > 0 then
        member("msgbox_1").text = "KEYCARD ALREADY ACQUIRED"
        sprite(myNum + 15).blend = 0
      else
        member("msgbox_1").text = "YOU GOT A BUILDING " & building & " KEYCARD"
        sprite(myNum + 15).blend = 100
        data[i][#moves] = moves
      end if
      if moves < data[i][#moves] then
        Prop[#todo].add(#newrecord)
        sprite(Prop[#sprites][#newrecord]).blend = 100
        data[i][#moves] = moves
      end if
      if gold = 1 then
        sprite(Prop[#sprites][#gold]).blend = 100
        member("msgbox_3").text = EMPTY
      else
        if data[i][#moves] <= data[i][#goal] then
          glob[#building][building][#LEVELS][level][#gold] = 1
          Prop[#todo].add(#goldaward)
          sprite(Prop[#sprites][#gold]).blend = 100
          member("msgbox_3").text = EMPTY
        else
          member("msgbox_3").text = "beat this level in " & data[i][#goal] & " moves or fewer" & RETURN & "to get the gold award"
          sprite(Prop[#sprites][#gold]).blend = 0
        end if
      end if
    end if
    if data[i][#moves] > 0 then
      keys = keys + 1
    end if
  end repeat
  if (keys >= glob[#keyrequired]) and not (building = 4) and not (glob[#building][building + 1][#state] = #open) then
    member("msgbox_2").text = "YOU UNLOCKED BUILDING " & building + 1
    Prop[#todo].add(#unlock)
    glob[#building][building + 1][#state] = #open
    SndSFX("unlock2")
  else
    if keys >= glob[#keyrequired] then
      glob.PLAYER[#game_manager].TotalKeys()
      if glob[#rankdata][#keys] = 60 then
        member("msgbox_2").text = EMPTY
      else
        member("msgbox_2").text = "GET ALL THE KEYCARDS!"
      end if
    else
      if (keys < glob[#keyrequired]) and not (building = 4) then
        member("msgbox_2").text = "GET " & glob[#keyrequired] - keys & " MORE TO UNLOCK BUILDING " & building + 1
      else
        member("msgbox_2").text = EMPTY
      end if
    end if
  end if
  if (level = 15) and (keys >= glob[#keyrequired]) and not (glob[#current][#building] = 4) then
    sprite(myNum + 13).blend = 100
    sprite(myNum + 13).member = member("but_next_bd")
    updateStage()
    sprite(myNum + 13).updateProp()
  else
    if (level = 15) and (keys >= glob[#keyrequired]) and (glob[#current][#building] = 4) then
      sprite(myNum + 13).blend = 0
    else
      sprite(myNum + 13).blend = 100
    end if
  end if
  me.makekey(keys)
end

on exitFrame me
  building = glob[#current][#building]
  case Prop[#state] of
    #hide:
    #move1:
      temp = me.doMove(Prop[#loc][#show], Prop[#speed][#move1])
      if temp then
        Prop[#state] = #show
      end if
    #show:
      setCursor(#none)
      if getOne(Prop[#todo], #unlock) > 0 then
        if building < 4 then
          bsp = sprite(Prop[#sprites][#bicon] + building)
          repeat with n = 1 to 10
            bsp.rect = bsp.rect + rect(-1, -1, 1, 1)
            bsp.blend = bsp.blend - 5
            updateStage()
          end repeat
          repeat with n = 1 to 10
            bsp.rect = bsp.rect + rect(1, 1, -1, -1)
            bsp.blend = bsp.blend + 5
            updateStage()
          end repeat
          bsp.stretch = 0
          updateStage()
          bsp.member = member("building_icon_" & building + 1)
        end if
      end if
      if getOne(Prop[#todo], #goldaward) > 0 then
        bsp = sprite(Prop[#sprites][#gold])
        bsp.blend = 100
        updateStage()
      end if
      if getOne(Prop[#todo], #newrecord) > 0 then
        bsp = sprite(Prop[#sprites][#newrecord])
        bsp.blend = 100
        updateStage()
      end if
      Prop[#state] = #showdone
    #move2:
      temp = me.doMove(Prop[#loc][#end], Prop[#speed][#move2])
      if temp then
        Prop[#state] = #hide
        me.updateLoc(Prop[#loc][#Start])
        if not voidp(Prop[#callback]) then
          Prop.callback.object.callback(Prop.callback.parameter)
          Prop.callback = VOID
        end if
      end if
  end case
end

on doMove me, toWhere, speed
  case Prop[#state] of
    #move1:
      if sprite(myNum).locV < toWhere[2] then
        newloc = sprite(myNum).loc + point(speed[1], speed[2])
        me.updateLoc(newloc)
        return 0
      else
        return 1
      end if
    #move2:
      if sprite(myNum).locH > toWhere[1] then
        newloc = sprite(myNum).loc + point(speed[1], speed[2])
        me.updateLoc(newloc)
        return 0
      else
        return 1
      end if
  end case
end

on getOut me
  if not (Prop[#state] = #hide) and not (Prop[#state] = #move2) then
    Prop[#state] = #move2
  end if
end

on updateState me, state, callback
  Prop[#callback] = callback
  Prop[#state] = state
end

on updateLoc me, newloc
  sprite(myNum).loc = newloc
  repeat with sn = 1 to 3
    sprite(myNum + sn).loc = sprite(myNum).loc
  end repeat
  sprite(myNum + 4).loc = sprite(myNum).loc + point(52, 177) + point(30, -19)
  sprite(myNum + 5).loc = sprite(myNum).loc + point(136, 177) + point(29, -14)
  sprite(myNum + 6).loc = sprite(myNum).loc + point(217, 177) + point(31, -17)
  sprite(myNum + 7).loc = sprite(myNum).loc + point(301, 177) + point(28, -21)
  sprite(myNum + 8).loc = sprite(myNum).loc + point(26, 75)
  sprite(myNum + 15).loc = sprite(myNum).loc + point(26, 75) + point((keys - 1) * 24, 0)
  sprite(myNum + 9).loc = sprite(myNum).loc + point(33, 49)
  sprite(myNum + 10).loc = sprite(myNum).loc + point(25, 96)
  sprite(myNum + 11).loc = sprite(myNum).loc + point(35, 214)
  sprite(myNum + 12).loc = sprite(myNum).loc + point(100, 188)
  sprite(myNum + 13).loc = sprite(myNum).loc + point(334, 236)
  sprite(myNum + 14).loc = sprite(myNum).loc + point(334, 207)
end

on fixLocZ me
  sprite(myNum).locZ = 1000000000
  repeat with sn = 1 to 17
    sprite(myNum + sn).locZ = 1000000001 + sn
    sprite(myNum + sn).blend = 100
    sprite(myNum + sn).visible = 1
  end repeat
end

on makekey me, keys
  member("mem_keys").image = image(400, 20, 8)
  img = image(24 * keys, 20, 8)
  src = member("key")
  repeat with i = 1 to keys
    img.copyPixels(src.image, src.rect + rect((i - 1) * 24, 0, (i - 1) * 24, 0), src.rect)
    member("mem_keys").image = img
    member("mem_keys").regPoint = point(0, 0)
  end repeat
end
