property config, playfield_manager, toolmode, toolparam, toolcolor, currenttool_toolcolor, toolstate, toolframe, dragpart, movepart, moveoffset, mousestate
global glob

on new me
  me.setConfig()
  playfield_manager = new(script("playfield manager"), config.playfield)
  add(the actorList, me)
  toolmode = #none
  toolparam = VOID
  toolcolor = "GRAY"
  return me
end

on destroy me
  leave(me)
  deleteOne(the actorList, me)
end

on leave me
  playfield_manager.setInfo([#title: field("catalog title"), #par: field("editor par field"), #hint: field("editor hint field")])
  currentLevel = playfield_manager.toString()
  glob.PLAYER.game_manager.setGame([currentLevel])
  setCursor(#none)
  playfield_manager.leave()
end

on refresh me
  playfield_manager.refresh()
  info = playfield_manager.getInfo()
  if not voidp(info) then
    member("catalog title").text = string(info[#title])
    member("catalog par").text = string(info[#par])
    member("catalog hint").text = string(info[#hint])
  else
    member("catalog title").text = EMPTY
    member("catalog par").text = EMPTY
    member("catalog hint").text = EMPTY
  end if
  settoolmode(me, toolmode, toolparam, toolstate, toolframe)
end

on setConfig me
  configtext = member("config field").text
  config = glob[#config_manager].parseParams(configtext)
  if playfield_manager <> VOID then
    playfield_manager.setConfig(config.playfield)
  end if
end

on settoolmode me, m, p, s, f
  toolmode = m
  toolparam = p
  toolstate = s
  toolframe = f
  case toolmode of
    #move:
      setCursor(#grab)
      me.setdragsprite(#reset)
    #erase:
      setCursor(#eraser)
      me.setdragsprite(#reset)
    #place:
      setCursor(#none)
      me.setdragsprite([#type: toolparam, #color: toolcolor, #state: toolstate, #frame: toolframe])
    otherwise:
      setCursor(#none)
  end case
end

on settoolcolor me, c
  toolcolor = c
  if (glob.EDITOR[#drag_sprite] <> VOID) and (toolparam <> VOID) then
    me.setdragsprite([#color: toolcolor])
  end if
end

on bg_edit_item me, kind, mem
  case kind of
    #backdrop:
      playfield_manager.setBackdrop(mem.name)
    #decal:
      toolmode = #place_decal
      dragmember = mem
      glob.EDITOR.drag_sprite.member = dragmember
      glob.EDITOR.drag_sprite.rect = dragmember.rect
      glob.EDITOR.drag_sprite.ink = 36
      glob.EDITOR.drag_sprite.locZ = 200
      setCursor(#none)
  end case
end

on setdragsprite me, opt
  if glob.EDITOR[#drag_sprite] = VOID then
    return 
  end if
  glob.EDITOR.drag_sprite.puppet = 1
  glob.EDITOR.drag_sprite.ink = 36
  if opt = #reset then
    glob.EDITOR.drag_sprite.loc = point(-100, -100)
    glob.EDITOR.drag_sprite.blend = 100
    dragpart = VOID
    return 
  else
    if ilk(opt) = #propList then
      if not voidp(opt[#type]) then
        dragpart = opt
      else
        if dragpart <> VOID then
          dragpart[#color] = opt.color
        end if
      end if
    else
      return 
    end if
  end if
  if dragpart <> VOID then
    dragmembername = glob.legoparts_manager.getPieceMemberName(dragpart, #single)
    dragmember = member(dragmembername)
    glob.EDITOR.drag_sprite.member = dragmember
    glob.EDITOR.drag_sprite.width = glob.EDITOR.drag_sprite.member.width * playfield_manager.pf_scale
    glob.EDITOR.drag_sprite.height = glob.EDITOR.drag_sprite.member.height * playfield_manager.pf_scale
  end if
end

on stepFrame me
  if the frame <> marker("edit") then
    return 
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
  if toolmode = #moving then
    ml = ml + moveoffset
  end if
  fieldpos = playfield_manager.getPos(ml)
  if glob.EDITOR[#drag_sprite] <> VOID then
    case toolmode of
      #place:
        if voidp(fieldpos) then
          glob.EDITOR.drag_sprite.loc = point(-100, -100)
        else
          glob.EDITOR.drag_sprite.loc = fieldpos[2]
          glob.EDITOR.drag_sprite.locZ = 100000 - (1000 * fieldpos[1][2]) + 999
          if playfield_manager.checkFit(fieldpos[1], toolparam) then
            glob.EDITOR.drag_sprite.blend = 100
            if mousestate = #press then
              dragpart[#pos] = fieldpos[1]
              tpart = dragpart.duplicate()
              if ((tpart.type = #HAZ_SLICKSWITCH) or (tpart.type = #HAZ_SLICKFIRE) or (tpart.type = #HAZ_SLICKFAN)) and voidp(tpart[#label]) then
                tpart[#label] = "switch1"
              end if
              playfield_manager.placePiece(tpart)
            end if
          else
            glob.EDITOR.drag_sprite.blend = 30
          end if
        end if
      #config:
        if mousestate = #press then
          if not voidp(fieldpos) then
            tpart = playfield_manager.getPart(fieldpos[1])
            if voidp(tpart) then
              put EMPTY into field "part inspector field"
            else
              tpart = tpart.duplicate()
              tpart.deleteProp(#sprite)
              tpos = tpart[#pos]
              tpart.deleteProp(#pos)
              tpart[#tpos] = [tpos[1], tpos[2]]
              case tpart.type of
                #HAZ_SLICKSWITCH, #HAZ_SLICKFIRE, #HAZ_SLICKFAN:
                  if voidp(tpart[#label]) then
                    tpart[#label] = "switch1"
                  end if
              end case
              put glob.config_manager.toString([#part: tpart]) into field "part inspector field"
            end if
          end if
        end if
      #moving:
        if fieldpos = VOID then
          glob.EDITOR.drag_sprite.loc = point(-100, -100)
        else
          glob.EDITOR.drag_sprite.loc = fieldpos[2]
          glob.EDITOR.drag_sprite.locZ = 100000 - (1000 * fieldpos[1][2]) + 999
          if playfield_manager.checkFit(fieldpos[1], movepart.type) then
            glob.EDITOR.drag_sprite.blend = 100
            if (mousestate = #press) or ((toolmode = #moving) and (mousestate = #release)) then
              dragpart[#pos] = fieldpos[1]
              tpart = dragpart.duplicate()
              playfield_manager.placePiece(tpart)
              if toolmode = #moving then
                toolmode = #move
              end if
              setdragsprite(#reset)
            end if
          else
            glob.EDITOR.drag_sprite.blend = 30
          end if
        end if
      #erase:
        if not voidp(fieldpos) and (mousestate = #release) then
          tmppart = playfield_manager.erasePiece(fieldpos[1])
          if voidp(tmppart) then
            playfield_manager.eraseDecal(the mouseLoc)
          end if
        end if
      #move:
        if (mousestate = #press) and not voidp(fieldpos) then
          movepart = playfield_manager.erasePiece(fieldpos[1])
          if voidp(movepart) then
            decal = playfield_manager.eraseDecal(the mouseLoc)
            if voidp(decal) then
              me.setdragsprite(#reset)
            else
              me.bg_edit_item(#decal, decal.member)
              toolmode = #place_decal
              glob.EDITOR.drag_sprite.locZ = 200
            end if
          else
            moveoffset = playfield_manager.getLoc(movepart.pos + point(0, -1)) - ml
            me.setdragsprite(movepart)
            glob.EDITOR.drag_sprite.loc = playfield_manager.getLoc(movepart.pos)
            glob.EDITOR.drag_sprite.locZ = 100000 - (1000 * fieldpos[1][2]) + 999
            toolmode = #moving
          end if
        end if
      #place_decal:
        glob.EDITOR.drag_sprite.loc = the mouseLoc
        glob.EDITOR.drag_sprite.blend = 100
        glob.EDITOR.drag_sprite.locZ = 200
        if (mousestate = #release) and not voidp(fieldpos) then
          playfield_manager.placeDecal([#loc: glob.EDITOR.drag_sprite.loc, #member: glob.EDITOR.drag_sprite.member])
          toolmode = #move
          me.setdragsprite(#reset)
        end if
    end case
  end if
end

on doConfigPart me, part_text
  newpart = glob.config_manager.parseParams(part_text)[#part]
  newpart[#pos] = point(newpart.tpos[1], newpart.tpos[2])
  newpart.deleteProp(#tpos)
  playfield_manager.erasePiece(newpart.pos)
  playfield_manager.placePiece(newpart)
end
