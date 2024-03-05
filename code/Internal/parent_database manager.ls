property state, rank, hallOfFame, loggedin, user_name, netID, hofnetID, site, prefix, suffix
global glob

on new me
  userID = VOID
  netID = VOID
  hofnetID = VOID
  loggedin = VOID
  site = EMPTY
  prefix = "/build/junkbot/"
  suffix = ".asp"
  (the actorList).add(me)
  return me
end

on done me
  (the actorList).deleteOne(me)
end

on READY me
  return voidp(netID)
end

on getState me
  netID = getNetText(site & prefix & "getState" & suffix)
end

on setState me
  netID = postNetText(site & prefix & "setState" & suffix, state)
end

on setRecord me, info
  if loggedin <> 1 then
    return VOID
  end if
  glob[#rankdata][#serverState] = #network
  state[#total] = info[#total]
  state[#state] = info[#state]
  state[#record] = info[#record]
  state[#userName] = user_name
  timestamp = the date && the time
  checkvalue = info[#record] && user_name && info[#total] && info[#state] && timestamp
  checksum = me.checksumString(checkvalue)
  state[#time] = timestamp && checksum
  me.setState()
end

on getRecord me
  if loggedin <> 1 then
    return VOID
  end if
  glob[#rankdata][#serverState] = #network
  info = [:]
  info[#total] = state[#total]
  info[#state] = state[#state]
  info[#record] = state[#record]
  return info
end

on hofReady me
  return voidp(hofnetID)
end

on loadHallOfFame me, callbackobject, callbackhandler
  if not me.hofReady() then
    return 
  end if
  hofnetID = getNetText(site & prefix & "getTopTen" & suffix)
end

on getHallOfFame me
  return hallOfFame
end

on stepFrame me
  if not voidp(netID) then
    if netDone(netID) then
      t = netTextResult(netID)
      answer = me.decodeMulti(t)
      netID = VOID
      if not voidp(answer[#rank]) then
        rank = answer
        rank[#rank] = integer(rank[#rank])
        rank[#outof] = integer(rank[#outof])
        if not voidp(rank[#outof]) then
          glob[#rankdata][#rank] = rank.rank
          glob[#rankdata][#players] = rank.outof
          glob[#rankdata][#serverState] = #READY
        end if
        loggedin = 1
      end if
      if not voidp(answer[#userID]) then
        state = answer
        state.state = integer(state.state)
        state.total = integer(state.total)
        user_name = answer.userName
        site = "http://" & answer.domainname
        loggedin = 1
      end if
      if not voidp(answer[#notloggedin]) then
        loggedin = 0
      end if
    else
      if netError(netID) <> EMPTY then
        netID = VOID
      end if
    end if
  end if
  if not voidp(hofnetID) then
    if netDone(hofnetID) then
      t = netTextResult(hofnetID)
      hofnetID = VOID
      hallOfFame = me.decodeMulti(t)
    else
    end if
  end if
end

on decodeMulti me, s
  pairs = []
  tid = the itemDelimiter
  the itemDelimiter = "&"
  repeat with p = 1 to s.item.count
    pairs.add(s.item[p])
  end repeat
  ret = [:]
  the itemDelimiter = "="
  repeat with p in pairs
    if p.item[1] = EMPTY then
      next repeat
    end if
    k = symbol(p.item[1])
    if k = VOID then
      next repeat
    end if
    delete item 1 of p
    ret.addProp(k, p)
  end repeat
  the itemDelimiter = tid
  return ret
end

on checksumString me, s
  sum = 0
  m = (s.length mod 113) + 1
  repeat with n = 1 to s.length
    c = charToNum(s.char[n])
    a = (c * m mod 355) + 1
    m = ((m + a) mod 113) + 1
    sum = (sum + a) mod 94113
  end repeat
  return sum
end
