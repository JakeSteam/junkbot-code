property piecedata
global glob

on new me
  setPieceData(me)
  repeat with t = 1 to piecedata.count
    typ = piecedata.getPropAt(t)
    if typ = #end then
      exit repeat
    end if
    me.getPieceSize(typ)
  end repeat
  return me
end

on setPieceData me
  piecedata = [#BRICK_01: [#color: 1, #state: 0, #frame: 0, #shape: [[0, 0]]], #BRICK_02: [#color: 1, #state: 0, #frame: 0, #shape: [[0, 0], [1, 0]]], #BRICK_03: [#color: 1, #state: 0, #frame: 0, #shape: [[0, 0], [1, 0], [2, 0]]], #BRICK_04: [#color: 1, #state: 0, #frame: 0, #shape: [[0, 0], [1, 0], [2, 0], [3, 0]]], #BRICK_06: [#color: 1, #state: 0, #frame: 0, #shape: [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0]]], #BRICK_08: [#color: 1, #state: 0, #frame: 0, #shape: [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0]]], #flag: [#color: 1, #state: 0, #frame: 0, #shape: [[0, 0], [1, 0], [0, -1], [1, -1], [0, -2], [1, -2]]], #WHEEL04: [#color: 0, #state: 0, #frame: 0, #shape: [[0, 0], [1, 0], [2, 0], [3, 0], [0, -1], [1, -1], [2, -1], [3, -1], [0, -2], [1, -2], [2, -2], [3, -2]]], #MINIFIG: [#color: 0, #state: 1, #frame: 1, #shape: [[0, 0], [1, 0], [0, -1], [1, -1], [0, -2], [1, -2], [0, -3], [1, -3]]], #HAZ_FLOAT: [#color: 0, #state: 1, #frame: 1, #shape: [[0, 0], [1, 0], [0, -1], [1, -1]]], #HAZ_DUMBFLOAT: [#color: 0, #state: 1, #frame: 1, #shape: [[0, 0], [1, 0], [0, -1], [1, -1]]], #haz_walker: [#color: 0, #state: 1, #frame: 1, #shape: [[0, 0], [1, 0], [0, -1], [1, -1]]], #HAZ_CLIMBER: [#color: 0, #state: 1, #frame: 1, #shape: [[0, 0], [1, 0], [0, -1], [1, -1]]], #HAZ_SLICKFIRE: [#color: 0, #state: 1, #frame: 1, #shape: [[0, 0], [1, 0], [2, 0], [3, 0]]], #HAZ_SLICKFAN: [#color: 0, #state: 1, #frame: 1, #shape: [[0, 0], [1, 0], [2, 0], [3, 0]]], #haz_slickJump: [#color: 0, #state: 1, #frame: 1, #shape: [[0, 0], [1, 0]]], #BRICK_SLICKJUMP: [#color: 0, #state: 1, #frame: 1, #shape: [[0, 0], [1, 0]]], #HAZ_SLICKPIPE: [#color: 0, #state: 1, #frame: 1, #shape: [[0, 0], [1, 0]]], #HAZ_SLICKSWITCH: [#color: 0, #state: 1, #frame: 1, #shape: [[0, 0], [1, 0]]], #HAZ_SLICKSHIELD: [#color: 0, #state: 1, #frame: 0, #shape: [[0, 0], [1, 0]]], #end: []]
end

on getPieceShape me, typ
  return piecedata[typ].shape
end

on getPieceSize me, typ
  if voidp(piecedata[typ][#size]) then
    smin = [0, 0]
    smax = [0, 0]
    repeat with s in piecedata[typ][#shape]
      repeat with i = 1 to 2
        if s[i] < smin[i] then
          smin[i] = s[i]
        end if
        if s[i] > smax[i] then
          smax[i] = s[i]
        end if
      end repeat
    end repeat
    piecedata[typ][#size] = smax - smin + [1, 1]
    piecedata[typ][#split] = piecedata[typ][#size][2] > 1
  end if
  return piecedata[typ][#size]
end

on getPieceMemberName me, part, single
  m = EMPTY
  m = m & string(part.type)
  ret = []
  data = piecedata[part.type]
  if data.color then
    m = m & "_" & part.color
  end if
  if data.state then
    m = m & "_" & part.state
  end if
  if data.frame then
    m = m & "_" & part.frame
  end if
  if single = #single then
    return m
  end if
  if glob[#split_tall_members] <> 1 then
    return [m]
  end if
  if data.split then
    repeat with s = 1 to data.size[2]
      ret.add(m & "_s" & s)
    end repeat
    if member(ret[1]).memberNum = -1 then
      me.splitTallMember(part.type, m, ret)
    end if
  else
    ret.add(m)
  end if
  return ret
end

on splitTallMember me, typ, basename, splitnames
  stack = piecedata[typ].size[2]
  dy = 18
  mem = member(basename)
  mi = mem.image
  h = mem.regPoint[2]
  if mem.height > h then
    h = mem.height
  end if
  w = mem.width
  repeat with i = 1 to stack
    iw = w
    if i < stack then
      ih = dy
    else
      ih = h - ((stack - 1) * dy)
    end if
    img = image(iw, ih, 16)
    img.copyPixels(mi, rect(0, 0, iw, ih), rect(0, h - (dy * (i - 1)) - ih, w, h - (dy * (i - 1))))
    imem = new(#bitmap, castLib("dynamic"))
    imem.image = img
    imem.name = splitnames[i]
    if i < stack then
      imem.regPoint = mem.regPoint + point(0, (dy * i) - h)
      next repeat
    end if
    imem.regPoint = mem.regPoint
  end repeat
end
