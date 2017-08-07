local opening = {
  days = {
    [0] = true, -- Sunday
    [1] = false, -- Monday
    [2] = true, -- Tuesday
    [3] = false, -- Wednsday
    [4] = true, -- Thursday
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

local message = {}

message.closing = minetest.settings:get("opening_hours_closing") or "We're closing!"
message.closed = minetest.settings:get("opening_hours_closed") or "We're closed!"
message.countdown_pre = minetest.settings:get("opening_hours_countdown_pre") or "Closing in"
message.countdown_post = minetest.settings:get("opening_hours_countdown_post") or "minute."
message.countdown_post_plural = minetest.settings:get("opening_hours_countdown_post_plural") or "minutes."
message.open = minetest.settings:get("opening_hours_open") or "We're open!"

message.status = {
  open = true,
  closing = false,
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

local function send_message(hour, minute)
  if message.status.open then
    if minetest.get_modpath("matrix") ~= nil and matrix.connected then
      matrix.say(message.open)
    end
    if minetest.get_modpath("irc") ~= nil and irc.connected then
  		irc.say(message.open)
    end
    minetest.chat_send_all(message.open)
    message.status.open = false
  end
  if opening.hours[hour+1] ~= true then
    if minute + 1 > 59 then
      if message.status.min1 then
        minetest.chat_send_all(minetest.colorize("orangered", message.countdown_pre.." 1 "..message.countdown_post))
        message.status.min1 = false
      end
    elseif minute + 5 > 59 then
      if message.status.min5 then
        minetest.chat_send_all(minetest.colorize("orange", message.countdown_pre.." 5 "..message.countdown_post_plural))
        message.status.min5 = false
      end
    elseif minute + 10 > 59 then
      if message.status.min10 then
        minetest.chat_send_all(minetest.colorize("greenyellow", message.countdown_pre.." 10 "..message.countdown_post_plural))
        message.status.min10 = false
      end
    elseif minute + 15 > 59 then
      if message.status.min15 then
        minetest.chat_send_all(minetest.colorize("lightblue", message.countdown_pre.." 15 "..message.countdown_post_plural))
        message.status.min15 = false
      end
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
    local minute = tonumber(os.date("%M"))
    if opening.days[day] == true and opening.hours[hour] == true then
      send_message(hour, minute)
      message.status.closing = true
    else
      for _,player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        if not super_user(name) then
          minetest.kick_player(name, message.closing)
        end
      end
      if message.status.closing then
        if minetest.get_modpath("matrix") ~= nil and matrix.connected then
          matrix.say(message.closing)
        end
        if minetest.get_modpath("irc") ~= nil and irc.connected then
      		irc.say(message.open)
        end
        minetest.chat_send_all(message.closing)
        message.status.closing = false
      end
      message.status.open = true
      message.status.min1 = true
      message.status.min5 = true
      message.status.min10 = true
      message.status.min15 = true
    end
    timer = 0
  end
end)
