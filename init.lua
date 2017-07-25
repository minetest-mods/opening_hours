local opening = {
  days = {
    [0] = true, -- Sunday
    [1] = false, -- Monday
    [2] = false, -- Tuesday
    [3] = false, -- Wednsday
    [4] = false, -- Thursday
    [5] = false, -- Friday
    [6] = false, -- Saturday
  },
  hours = {
    [0] = false,
    [1] = false,
    [2] = false,
    [3] = false,
    [4] = false,
    [5] = false,
    [6] = false,
    [7] = false,
    [8] = false,
    [9] = false,
    [10] = false,
    [11] = false,
    [12] = false,
    [13] = false,
    [14] = false,
    [15] = false,
    [16] = false,
    [17] = false,
    [18] = true,
    [19] = true,
    [20] = true,
    [21] = true,
    [22] = false,
    [23] = false,
  },
}

local message = {
  closing = "We're closing!",
  closed = "We're closed!",
  countdown_pre = "Closing in",
  countdown_post = "minute.",
  countdown_post_plural = "minutes.",
}

local warning = {
  min1 = true,
  min5 = true,
  min10 = true,
  min15 = true,
}

local function super_user(name)
  if name == "singleplayer" or name == admin or minetest.check_player_privs(name, {server=true}) then
    return true
  else
    return false
  end
end

local function warnings(minutes)
  if minutes + 1 > 59 then
    if warning.min1 then
      minetest.chat_send_all(minetest.colorize("red", message.countdown_pre.." 1 "..message.countdown_post))
      warning.min1 = false
    end
  elseif minutes + 5 > 59 then
    if warning.min5 then
      minetest.chat_send_all(minetest.colorize("orange", message.countdown_pre.." 5 "..message.countdown_post_plural))
      warning.min5 = false
    end
  elseif minutes + 10 > 59 then
    if warning.min10 then
      minetest.chat_send_all(minetest.colorize("yellow", message.countdown_pre.." 10 "..message.countdown_post_plural))
      warning.min10 = false
    end
  elseif minutes + 15 > 59 then
    if warning.min15 then
      minetest.chat_send_all(minetest.colorize("blue", message.countdown_pre.." 15 "..message.countdown_post_plural))
      warning.min15 = false
    end
  end
end

minetest.register_on_prejoinplayer(function(name, ip)
  local day = tonumber(os.date("%w"))
  local hour = tonumber(os.date("%H"))
  if opening.days[day] == true and opening.hours[hour] == true or super_user(name) then
    return
	else
    return message.closed
  end
end)

local timer = 0
minetest.register_globalstep(function(dtime)
  timer = timer + dtime
  if timer > 10 then
    local day = tonumber(os.date("%w"))
    local hour = tonumber(os.date("%H"))
    local minutes = tonumber(os.date("%M"))
    if opening.days[day] == true and opening.hours[hour] == true then
      warnings(minutes)
    else
      for _,player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        if not super_user(name) then
          minetest.kick_player(name, message.closing)
        end
      end
    end
    timer = 0
  end
end)
