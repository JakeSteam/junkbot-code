property pf_size, pf_spacing, pf_scale, pf_grid, config, info, background, decalz, playfield, partslist, bg_image, current_level, spriteBuffer
global glob

on new me, conf
  if ilk(conf) = #string then
    p = glob[#config_manager].parseParams(conf)
    conf = p[#playfield]
  end if
  me.setConfig(conf)
  spriteBuffer = []
  repeat with i = 200 to 999
    spriteBuffer.add(sprite(i))
  end repeat
  background = [#backdrop: member("bkg1", "backgrounds"), #decals: []]
  decalz = 10001
  return me
end

on leave me
  current_level = me.toString()
  eraseAll(me)
end

on refresh me
  eraseAll(me)
  if current_level <> VOID then
    setPlayfield(me, current_level)
  end if
end

on setConfig me, conf
  info = [:]
  config = conf
  pf_size = conf.size
  pf_spacing = conf.spacing
  pf_scale = conf.scale
  pf_grid = pf_spacing * pf_scale
  if playfield = VOID then
    playfield = []
  end if
  repeat with i = playfield.count + 1 to pf_size[1]
    playfield[i] = []
  end repeat
  repeat with i = 1 to pf_size[1]
    if playfield[i].count < pf_size[2] then
      playfield[i][pf_size[2]] = 0
    end if
  end repeat
  if partslist = VOID then
    partslist = []
  end if
end

on setInfo me, i
  if voidp(i[#title]) or voidp(i[#par]) then
    return 
  end if
  info = i
  if voidp(integer(info.par)) then
    info.par = 0
  end if
end

on getInfo me
  return info
end

on toString me
  out_partslist = []
  out_typelist = [#BLOCK01, #BLOCK02]
  out_colorlist = [#GRAY, #blue]
  type_map = [#BLOCK01: 1, #BLOCK02: 2]
  color_map = [#GRAY: 1, #blue: 2]
  repeat with i = 1 to partslist.count
    part = partslist[i]
    if part <> 0 then
      if type_map[part.type] = VOID then
        out_typelist.add(part.type)
        type_map[part.type] = out_typelist.count
        type_num = out_typelist.count
      else
        type_num = type_map[part.type]
      end if
      if part.color = VOID then
        color_num = 0
      else
        if color_map[part.color] = VOID then
          out_colorlist.add(part.color)
          color_map[part.color] = out_colorlist.count
          color_num = out_colorlist.count
        else
          color_num = color_map[part.color]
        end if
      end if
      if voidp(part[#state]) then
        state_name = "0"
      else
        state_name = string(part.state)
      end if
      if voidp(part[#frame]) then
        frame_num = 0
      else
        frame_num = part.frame
      end if
      if voidp(part[#label]) then
        label_val = "0"
      else
        label_val = part.label
      end if
      part_text = part.pos[1] & ";" & part.pos[2] & ";" & type_num & ";" & color_num & ";" & state_name & ";" & frame_num & ";" & label_val
      out_partslist.add(part_text)
    end if
  end repeat
  if voidp(background) then
    out_bglist = [#backdrop: "bkg1", #decals: []]
  else
    out_bglist = [#backdrop: background.backdrop.member.name, #decals: []]
    repeat with d in background.decals
      out_bglist.decals.add(d.loc[1] & ";" & d.loc[2] & ";" & d.member.name)
    end repeat
  end if
  return glob.config_manager.toString([#info: info, #background: out_bglist, #playfield: config, #partslist: [#types: out_typelist, #colors: out_colorlist, #parts: out_partslist]])
end

on setPlayfield me, pfinfo, opt
  playfield = VOID
  partslist = VOID
  setConfig(me, config)
  if ilk(pfinfo) = #string then
    pfinfo = glob.config_manager.parseParams(pfinfo)
  end if
  if not voidp(pfinfo[#info]) then
    info = pfinfo.info
  end if
  if voidp(pfinfo[#background]) then
    pfinfo[#background] = [#backdrop: "bkg1", #decals: []]
  end if
  background = [#decals: []]
  background[#backdrop] = member(pfinfo.background.backdrop, "backgrounds")
  if ilk(pfinfo.background.decals) <> #list then
    pfinfo.background.decals = [pfinfo.background.decals]
  end if
  repeat with d in pfinfo.background.decals
    tid = the itemDelimiter
    the itemDelimiter = ";"
    decal_loc_x = integer(item 1 of d)
    if not voidp(decal_loc_x) then
      decal_loc_y = integer(item 2 of d)
      decal_member_name = string(item 3 of d)
      background.decals.add([#member: member(decal_member_name, "backgrounds"), #loc: point(decal_loc_x, decal_loc_y)])
    end if
    the itemDelimiter = tid
  end repeat
  me.refreshBackground()
  pf = pfinfo.partslist
  if (pf[#parts] = VOID) or (pf[#parts] = EMPTY) then
    pf[#parts] = []
  else
    if ilk(pf.parts) = #string then
      pf.parts = [pf.parts]
    end if
  end if
  repeat with p in pf.parts
    tid = the itemDelimiter
    the itemDelimiter = ";"
    part_pos_x = integer(item 1 of p)
    part_pos_y = integer(item 2 of p)
    part_typenum = integer(item 3 of p)
    part_colornum = integer(item 4 of p)
    part_statename = string(item 5 of p)
    part_framenum = integer(item 6 of p)
    part_labelval = string(item 7 of p)
    the itemDelimiter = tid
    part_type = pf.types[part_typenum]
    if part_colornum = 0 then
      part_color = VOID
    else
      part_color = pf.colors[part_colornum]
    end if
    part = [#pos: point(part_pos_x, part_pos_y), #type: symbol(part_type), #color: symbol(part_color)]
    if part_labelval <> "0" then
      part[#label] = part_labelval
    end if
    if not voidp(part_statename) and (part_statename <> "0") and (part_statename <> EMPTY) then
      part[#state] = symbol(part_statename)
    end if
    if not voidp(part_framenum) and (part_framenum <> 0) then
      part[#frame] = part_framenum
    end if
    case part.type of
      #HAZ_SLICKFIRE, #HAZ_SLICKFAN:
        if (part[#state] <> #off) and (part[#state] <> #on) then
          part.state = #on
        end if
    end case
    me.placePiece(part)
  end repeat
  current_level = me.toString()
end

on makeGrid me
  bg_image = image(pf_size[1] * pf_grid[1], pf_size[2] * pf_grid[2], 16)
  bg_image.fill(bg_image.rect, rgb(190, 225, 190))
  repeat with i = 1 to pf_size[1] - 1
    repeat with j = 1 to pf_size[2] - 1
      bg_image.setPixel(i * pf_grid[1], j * pf_grid[2], rgb(128, 128, 128))
    end repeat
  end repeat
  epg = member("editor-playfield grid")
  epg.image = bg_image
  epg.regPoint = point(0, 0)
end

on getPos me, L
  if glob.EDITOR[#playfield_sprite] = VOID then
    return VOID
  end if
  p = (L - glob.EDITOR.playfield_sprite.loc) / pf_grid
  l2 = ((p + [0, 1]) * pf_grid) + glob.EDITOR.playfield_sprite.loc
  p = p + [1, 1]
  if (p[1] < 1) or (p[2] < 1) or (p[1] > pf_size[1]) or (p[2] > pf_size[2]) then
    return VOID
  end if
  return [p, l2]
end

on getLoc me, arg
  o = point(0, 0)
  if ilk(arg) = #propList then
    p = arg.pos
    if not voidp(arg[#pixelOffset]) then
      o = arg.pixelOffset
    end if
  else
    p = arg
  end if
  return ((p - [1, 0]) * pf_grid) + glob.EDITOR.playfield_sprite.loc + o
end

on getPart me, pos
  p = playfield[pos[1]][pos[2]]
  if p = 0 then
    return VOID
  end if
  return partslist[p]
end

on checkFit me, pos, typ
  sh = glob.legoparts_manager.getPieceShape(typ)
  fit = 1
  repeat with i = 1 to sh.count
    t = pos + sh[i]
    if (t[1] < 1) or (t[2] < 1) or (t[1] > pf_size[1]) or (t[2] > pf_size[2]) then
      fit = 0
      exit repeat
      next repeat
    end if
    if playfield[t[1]][t[2]] <> 0 then
      fit = 0
      exit repeat
    end if
  end repeat
  return fit
end

on checkFitOrGoal me, pos, typ
  sh = glob.legoparts_manager.getPieceShape(typ)
  fit = 1
  goal = VOID
  repeat with i = 1 to sh.count
    t = pos + sh[i]
    if (t[1] < 1) or (t[2] < 1) or (t[1] > pf_size[1]) or (t[2] > pf_size[2]) then
      fit = 0
      goal = VOID
      exit repeat
      next repeat
    end if
    pnum = playfield[t[1]][t[2]]
    if pnum <> 0 then
      p = partslist[pnum]
      if me.goalP(p) then
        goal = p
        next repeat
      end if
      fit = 0
      goal = VOID
      exit repeat
    end if
  end repeat
  if goal = VOID then
    return fit
  else
    return goal
  end if
end

on checkFitOrNonbrick me, pos, typ
  sh = glob.legoparts_manager.getPieceShape(typ)
  fit = 1
  nonbrick = VOID
  repeat with i = 1 to sh.count
    t = pos + sh[i]
    if (t[1] < 1) or (t[2] < 1) or (t[1] > pf_size[1]) or (t[2] > pf_size[2]) then
      fit = 0
      nonbrick = VOID
      exit repeat
      next repeat
    end if
    pnum = playfield[t[1]][t[2]]
    if pnum <> 0 then
      p = partslist[pnum]
      if not me.brickP(p) then
        nonbrick = p
        next repeat
      end if
      fit = 0
      nonbrick = VOID
      exit repeat
    end if
  end repeat
  if nonbrick = VOID then
    return fit
  else
    return nonbrick
  end if
end

on checkFitOrMinifig me, pos, typ
  sh = glob.legoparts_manager.getPieceShape(typ)
  fit = 1
  goal = VOID
  repeat with i = 1 to sh.count
    t = pos + sh[i]
    if (t[1] < 1) or (t[2] < 1) or (t[1] > pf_size[1]) or (t[2] > pf_size[2]) then
      fit = 0
      goal = VOID
      exit repeat
      next repeat
    end if
    pnum = playfield[t[1]][t[2]]
    if pnum <> 0 then
      p = partslist[pnum]
      if me.minifigP(p) then
        goal = p
        next repeat
      end if
      fit = 0
      goal = VOID
      exit repeat
    end if
  end repeat
  if goal = VOID then
    return fit
  else
    return goal
  end if
end

on checkFitMiniFigHit me, pos, typ
  sh = glob.legoparts_manager.getPieceShape(typ)
  fit = 1
  goal = VOID
  repeat with i = 1 to sh.count
    t = pos + sh[i]
    if (t[1] < 1) or (t[2] < 1) or (t[1] > pf_size[1]) or (t[2] > pf_size[2]) then
      fit = 0
      goal = VOID
      exit repeat
      next repeat
    end if
    pnum = playfield[t[1]][t[2]]
    if pnum <> 0 then
      p = partslist[pnum]
      if me.minifigP(p) then
        goal = p
      else
        goal = VOID
      end if
      fit = 0
      exit repeat
    end if
  end repeat
  if not voidp(goal) then
    glob.PLAYER[#minifigHit] = goal
  end if
  return fit
end

on checkPlaceable me, pos, typ
  sh = glob.legoparts_manager.getPieceShape(typ)
  fit = 1
  edgetop = #free
  edgebottom = #free
  repeat with i = 1 to sh.count
    t = pos + sh[i]
    if (t[1] < 1) or (t[2] < 1) or (t[1] > pf_size[1]) or (t[2] > pf_size[2]) then
      fit = 0
      exit repeat
    else
      if playfield[t[1]][t[2]] <> 0 then
        fit = 0
        exit repeat
      end if
    end if
    if t[2] > 1 then
      above = playfield[t[1]][t[2] - 1]
      if above <> 0 then
        if me.brickP(partslist[above]) then
          edgetop = #brick
        else
          if me.slickBrickP(partslist[above]) then
            fit = 0
            exit repeat
          end if
        end if
      end if
    end if
    if t[2] = pf_size[2] then
      edgebottom = #bottom
      next repeat
    end if
    below = playfield[t[1]][t[2] + 1]
    if below <> 0 then
      if me.brickP(partslist[below]) then
        edgebottom = #brick
        next repeat
      end if
      if me.slickBrickP(partslist[below]) then
        fit = 0
        exit repeat
      end if
    end if
  end repeat
  if not fit then
    return #nofit
  end if
  if (edgetop = #free) and ((edgebottom = #free) or (edgebottom = #bottom)) then
    return #fit
  end if
  if (edgebottom <> #free) and (edgetop = #free) then
    return #below
  end if
  if ((edgebottom = #free) or (edgebottom = #bottom)) and (edgetop <> #free) then
    return #above
  end if
  return #nofit
end

on checkFloor me, pos, w
  n = 0
  repeat with i = 0 to w - 1
    x = pos[1] + i
    if (x > 0) and (x <= pf_size[1]) then
      if pos[2] < pf_size[2] then
        pnum = playfield[x][pos[2] + 1]
        if pnum <> 0 then
          n = n + (me.brickP(partslist[pnum]) or me.slickBrickP(partslist[pnum]))
        end if
        next repeat
      end if
      n = n + 1
    end if
  end repeat
  return n
end

on placePiece me, pos, typ, mem, col, spr
  if ilk(pos) = #propList then
    part = pos
  else
    part = [#pos: pos, #type: typ, #color: col, #member: mem, #sprite: spr]
  end if
  partmembers = glob.legoparts_manager.getPieceMemberName(part)
  if voidp(part[#sprite]) then
    part[#sprite] = []
    repeat with si = 1 to partmembers.count
      s = me.getASprite()
      part.sprite.add(s)
    end repeat
  end if
  partslist.add(part)
  partnum = partslist.count
  sh = glob.legoparts_manager.getPieceShape(part.type)
  repeat with i = 1 to sh.count
    t = part.pos + sh[i]
    playfield[t[1]][t[2]] = partnum
  end repeat
  repeat with si = 1 to part.sprite.count
    s = part.sprite[si]
    s.puppet = 1
    s.member = member(partmembers[si])
    s.width = s.member.width * pf_scale
    s.height = s.member.height * pf_scale
    s.loc = me.getLoc(part)
    s.visible = 1
    if me.brickP(part) then
      s.ink = 8
    else
      s.ink = 36
    end if
    s.locZ = me.posToLocZ(part.pos - point(0, si - 1))
    s.blend = 100
    s.scriptInstanceList.add(new(script("part click behavior"), part))
  end repeat
  if not voidp(part[#behavior]) then
    part.behavior.notify([#Start: 1])
  end if
end

on posToLocZ me, pos
  return 100000 - (1000 * pos[2]) + pos[1]
end

on placePieceGroup me, partgroup
  repeat with part in partgroup
    me.placePiece(part)
  end repeat
end

on erasePiece me, pos, keepSprite
  partnum = playfield[pos[1]][pos[2]]
  if partnum = 0 then
    return VOID
  end if
  part = partslist[partnum]
  partslist[partnum] = 0
  if ilk(part) = #propList then
    basepos = part.pos
    sh = glob.legoparts_manager.getPieceShape(part.type)
    repeat with i = 1 to sh.count
      t = basepos + sh[i]
      playfield[t[1]][t[2]] = 0
    end repeat
  end if
  if keepSprite <> 1 then
    if not voidp(part[#sprite]) then
      repeat with s in part.sprite
        s.loc = [-100, -100]
        s.visible = 0
        s.scriptInstanceList = []
        me.returnASprite(s)
      end repeat
      part[#sprite] = VOID
    end if
    if not voidp(part[#auxSprites]) then
      repeat with s in part.auxSprites
        s.loc = [-100, -100]
        s.visible = 0
        s.scriptInstanceList = []
        me.returnASprite(s)
      end repeat
      part[#auxSprites] = [:]
    end if
  end if
  if not voidp(part[#behavior]) then
    part.behavior.notify([#stop: 1])
  end if
  return part
end

on erasePieceGroup me, partgroup, keepSprites
  erasedPieces = []
  repeat with part in partgroup
    erasedPieces.add(me.erasePiece(part.pos, keepSprites))
  end repeat
  return erasedPieces
end

on releasePieceSprite me, p
  s = p.sprite
  if s <> VOID then
    s.loc = [-100, -100]
    s.visible = 0
    me.returnASprite(s)
  end if
  p[#sprite] = VOID
end

on releasePieceGroupSprites me, partgroup
  repeat with p in partgroup
    me.releasePieceSprite(p)
  end repeat
end

on eraseAll me
  repeat with part in partslist
    if part <> 0 then
      me.erasePiece(part.pos)
    end if
  end repeat
  me.hideDecals()
end

on brickP me, p
  if p = 0 then
    return 0
  end if
  return string(p.type) contains "BRICK"
end

on slickBrickP me, p
  if p = 0 then
    return 0
  end if
  return string(p.type) contains "_SLICK"
end

on supportP me, p
  if p = 0 then
    return 0
  end if
  return me.brickP(p) and (string(p.color) contains "GRAY")
end

on goalP me, p
  if p = 0 then
    return 0
  end if
  return string(p.type) contains "FLAG"
end

on minifigP me, p
  if p = 0 then
    return 0
  end if
  return string(p.type) contains "MINIFIG"
end

on partNeighbors me, p, dir, exclude
  if p = 0 then
    return []
  end if
  if voidp(exclude) then
    exclude = []
  end if
  nei = []
  sh = glob.legoparts_manager.getPieceShape(p.type)
  repeat with d in sh
    pos = p.pos + d
    if not (dir = #down) and (pos[2] > 1) then
      n = playfield[pos[1]][pos[2] - 1]
      if n <> 0 then
        n = partslist[n]
        if (n <> p) and not nei.getOne(n) and not exclude.getOne(n.type) then
          nei.add(n)
        end if
      end if
    end if
    if not (dir = #UP) and (pos[2] < pf_size[2]) then
      n = playfield[pos[1]][pos[2] + 1]
      if n <> 0 then
        n = partslist[n]
        if (n <> p) and me.brickP(n) and not nei.getOne(n) then
          nei.add(n)
        end if
      end if
    end if
  end repeat
  return nei
end

on partConnectedGroup me, p, group
  if p = 0 then
    return []
  end if
  if group = VOID then
    group = [p]
  end if
  repeat with n in me.partNeighbors(p)
    if group.getOne(n) then
      next repeat
    end if
    group.add(n)
    if me.brickP(n) then
      group = me.partConnectedGroup(n, group)
    end if
  end repeat
  return group
end

on partSupported me, p, group, ignoregroup, recurse
  if voidp(ignoregroup) then
    ignoregroup = []
  end if
  if p = 0 then
    return []
  end if
  if voidp(recurse) then
    recurse = 1
  end if
  ms = the milliSeconds
  if me.supportP(p) then
    return #supported
  else
    if not me.brickP(p) then
      return #illegal
    end if
  end if
  if group = VOID then
    group = [p]
  end if
  repeat with n in me.partNeighbors(p, VOID, [#HAZ_FLOAT])
    ms2 = the milliSeconds
    if ignoregroup.getOne(n) then
      next repeat
    end if
    if group.getOne(n) then
      next repeat
    end if
    group.add(n)
    if me.brickP(n) then
      group = me.partSupported(n, group, ignoregroup, recurse + 1)
    end if
    if (group = #supported) or (group = #illegal) then
      exit repeat
    end if
  end repeat
  if ilk(group) = #list then
    tmp = group.count
  else
    tmp = group
  end if
  repeat with i = 1 to recurse - 1
    tmp = "." & tmp
  end repeat
  return group
end

on findPieceGroup me, pos, dir
  pieceGroup = []
  newGroup = []
  firstpartnum = playfield[pos[1]][pos[2]]
  if firstpartnum = 0 then
    return []
  end if
  firstpart = partslist[firstpartnum]
  if not me.brickP(firstpart) or me.supportP(firstpart) then
    return []
  end if
  newGroup.add(firstpart)
  moreNeighbors = 1
  repeat while moreNeighbors
    moreNeighbors = 0
    neighbors = []
    repeat with p in newGroup
      newneighbors = me.partNeighbors(p, dir, [#HAZ_FLOAT])
      if newneighbors = [] then
        next repeat
        next repeat
      end if
      repeat with n in newneighbors
        if not neighbors.getOne(n) then
          neighbors.add(n)
        end if
      end repeat
      moreNeighbors = 1
    end repeat
    repeat with n in neighbors
      if not me.brickP(n) or me.supportP(n) then
        return []
      end if
    end repeat
    repeat with p in newGroup
      if not pieceGroup.getOne(p) then
        pieceGroup.add(p)
      end if
    end repeat
    newGroup = []
    repeat with n in neighbors
      if not newGroup.getOne(n) then
        newGroup.add(n)
      end if
    end repeat
  end repeat
  repeat with p in newGroup
    if not pieceGroup.getOne(p) then
      pieceGroup.add(p)
    end if
  end repeat
  unsupportedGroup = []
  case dir of
    #UP:
      oDir = #down
    #down:
      oDir = #UP
  end case
  newpiecegroup = []
  repeat with p in pieceGroup
    newneighbors = me.partNeighbors(p, oDir)
    repeat with n in newneighbors
      if pieceGroup.getOne(n) then
        next repeat
      end if
      unsupportedGroup = me.partSupported(n, VOID, pieceGroup)
      if unsupportedGroup = #supported then
        next repeat
      end if
      if unsupportedGroup = #illegal then
        return []
      end if
      repeat with U in unsupportedGroup
        if not me.brickP(U) then
          return []
        end if
        if not newpiecegroup.getOne(U) then
          newpiecegroup.add(U)
        end if
      end repeat
    end repeat
  end repeat
  repeat with np in newpiecegroup
    if not pieceGroup.getOne(np) then
      pieceGroup.add(np)
    end if
  end repeat
  return pieceGroup
end

on getPartsByType me, typelist
  plist = []
  if ilk(typelist) <> #list then
    typelist = [typelist]
  end if
  repeat with p in partslist
    if p = 0 then
      next repeat
    end if
    repeat with t in typelist
      if p.type = t then
        plist.add(p)
      end if
    end repeat
  end repeat
  return plist
end

on getPartsByLabel me, labelList
  plist = []
  if ilk(labelList) <> #list then
    labelList = [labelList]
  end if
  repeat with p in partslist
    if p = 0 then
      next repeat
    end if
    if voidp(p[#label]) then
      next repeat
    end if
    repeat with L in labelList
      if p[#label] = L then
        plist.add(p)
      end if
    end repeat
  end repeat
  return plist
end

on setBackdrop me, mem
  background.backdrop = mem
  me.refreshBackground()
end

on placeDecal me, d
  decal = d.duplicate()
  decal[#sprite] = me.getASprite()
  decal.sprite.member = decal.member
  decal.sprite.rect = decal.member.rect
  decal.sprite.loc = decal.loc
  decal.sprite.locZ = decalz
  decalz = decalz + 1
  decal.sprite.blend = 100
  decal.sprite.visible = 1
  decal.sprite.ink = 36
  background.decals.add(decal)
end

on eraseDecal me, L
  if voidp(background) then
    return 
  end if
  if voidp(background.decals) then
    return 
  end if
  repeat with d = background.decals.count down to 1
    decal = background.decals[d]
    r = rect(decal.loc - decal.member.regPoint, decal.loc - decal.member.regPoint + point(decal.member.width, decal.member.height))
    if inside(L, r) then
      if not voidp(decal.sprite) then
        decal.sprite.loc = point(-100, -100)
        decal.sprite.member = member(0)
        me.returnASprite(decal.sprite)
        decal.sprite = VOID
      end if
      background.decals.deleteOne(decal)
      return decal.duplicate()
    end if
  end repeat
end

on hideDecals me
  if voidp(background) then
    return 
  end if
  if voidp(background.decals) then
    return 
  end if
  repeat with decal in background.decals
    if not voidp(decal[#sprite]) then
      decal.sprite.loc = point(-100, -100)
      decal.sprite.member = member(0)
      me.returnASprite(decal.sprite)
      decal.sprite = VOID
    end if
  end repeat
end

on refreshBackground me
  glob.EDITOR.playfield_sprite.member = background.backdrop
  z = 10001
  repeat with decal in background.decals
    z = z + 1
    if voidp(decal[#sprite]) then
      decal[#sprite] = me.getASprite()
    end if
    decal.sprite.member = decal.member
    decal.sprite.rect = decal.member.rect
    decal.sprite.loc = decal.loc
    decal.sprite.locZ = z
    decal.sprite.blend = 100
    decal.sprite.visible = 1
    decal.sprite.ink = 36
  end repeat
  decalz = z + 1
end

on getASprite me
  if spriteBuffer.count = 0 then
    return VOID
  end if
  s = spriteBuffer[1]
  s.puppet = 1
  deleteAt(spriteBuffer, 1)
  return s
end

on returnASprite me, s
  s.scriptInstanceList = []
  spriteBuffer.add(s)
end
