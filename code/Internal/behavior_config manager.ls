on parseParams me, t, defaultList
  ret = [:]
  section = ret
  the itemDelimiter = ","
  t = me.fixReturns(t)
  repeat with ln = 1 to t.line.count
    L = me.trim(t.line[ln])
    if L.length = 0 then
      next repeat
    end if
    if (L.char[1] = "[") and (L.char[L.char.count] = "]") then
      section_name = L.char[2..L.char.count - 1]
      if section_name = "Master" then
        section = ret
      else
        if section_name.word.count > 1 then
          section_num = integer(section_name.word[2])
          section_sym = symbol(section_name.word[1])
          if ilk(ret[section_sym]) <> #list then
            ret[section_sym] = []
          end if
          ret[section_sym][section_num] = [:]
          section = ret[section_sym][section_num]
        else
          section_sym = symbol(section_name)
          if ilk(ret[section_sym]) <> #propList then
            ret[section_sym] = [:]
          end if
          section = ret[section_sym]
        end if
      end if
      next repeat
    end if
    if L.char[1..2] = "--" then
      next repeat
    end if
    pkey = VOID
    repeat with pn = 1 to L.item.count
      p = L.item[pn]
      d = offset("=", p)
      if d = 0 then
        if ilk(pkey) = #void then
          next repeat
        end if
        pval = p
      else
        pkey = p.char[1..d - 1]
        pval = p.char[d + 1..p.char.count]
      end if
      pval_val = float(pval)
      if integer(pval_val) = pval_val then
        pval_val = integer(pval_val)
      end if
      pkey_sym = symbol(pkey)
      if ilk(section[pkey_sym]) <> #void then
        if ilk(section[pkey_sym]) = #list then
          section[pkey_sym].add(pval_val)
        else
          section[pkey_sym] = [section[pkey_sym], pval_val]
        end if
        next repeat
      end if
      section[pkey_sym] = pval_val
    end repeat
  end repeat
  if ilk(defaultList) = #propList then
    repeat with i = 1 to defaultList.count
      if ret[defaultList.getPropAt(i)] = VOID then
        ret[defaultList.getPropAt(i)] = defaultList[i]
      end if
    end repeat
  end if
  return ret
end

on toString me
  stringval = EMPTY
  repeat with pn = 2 to the paramCount
    pl = param(pn)
    repeat with bn = 1 to pl.count
      bracketname = pl.getPropAt(bn)
      stringval = stringval & "[" & bracketname & "]" & RETURN
      bracket = pl[bn]
      repeat with kn = 1 to bracket.count
        keyname = bracket.getPropAt(kn)
        keyval = bracket[kn]
        if ilk(keyval) = #list then
          t = keyname & "="
          repeat with v = 1 to keyval.count
            t = t & keyval[v]
            if v < keyval.count then
              if length(t) > 60 then
                stringval = stringval & t & RETURN
                t = keyname & "="
                next repeat
              end if
              t = t & ","
            end if
          end repeat
          stringval = stringval & t & RETURN
          next repeat
        end if
        stringval = stringval & keyname & "=" & keyval & RETURN
      end repeat
      stringval = stringval & RETURN & RETURN
    end repeat
  end repeat
  return stringval
end

on restoreCommas me, t
  if ilk(t) <> #list then
    return t
  end if
  r = EMPTY
  repeat with i = 1 to t.count
    r = r & t[i]
    if i <> t.count then
      r = r & ","
    end if
  end repeat
  return r
end

on cleanWhitespace me, t
  repeat while offset(numToChar(10), t) > 0
    delete char offset(numToChar(10), t) of t
  end repeat
  repeat while offset(numToChar(13), t) > 0
    delete char offset(numToChar(13), t) of t
  end repeat
  return t
end

on fixReturns me, t
  repeat while offset(numToChar(10), t) > 0
    put RETURN into me.char[offset(numToChar(10), t)]
  end repeat
  return t
end

on trim me, t
  whitespace = " " & RETURN & TAB & numToChar(10)
  repeat while (whitespace contains char 1 of t) and (t.length > 0)
    delete char 1 of t
  end repeat
  repeat while (whitespace contains the last char in t) and (t.length > 0)
    delete char -30000 of t
  end repeat
  return t
end
