local M = { }
local escape_pattern
escape_pattern = require("lapis.util").escape_pattern
M.log = function(msg)
  return ngx.log(ngx.NOTICE, inspect(msg))
end
M.log_err = function(msg)
  return ngx.log(ngx.ERR, inspect(msg))
end
M.split = function(str, delim)
  str = str .. delim
  local _accum_0 = { }
  local _len_0 = 1
  for part in str:gmatch("(.-)" .. escape_pattern(delim)) do
    _accum_0[_len_0] = part
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
M.strip = function(str, pattern)
  if pattern == nil then
    pattern = '%s'
  end
  local sub = "^" .. pattern .. "*(.-)" .. pattern .. "*$"
  return string.gsub(str, sub, "%1")
end
M.trim = function(str)
  return M.strip(str, '%s')
end
M.replace = function(str, what, sub)
  what = string.gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
  sub = string.gsub(sub, "[%%]", "%%%%")
  return string.gsub(str, what, sub)
end
M.set = function(list)
  local set = { }
  for _, l in ipairs(list) do
    set[l] = true
  end
  return set
end
M.response = function(t)
  if t['redis'] then
    redis.finish(t['redis'])
  end
  local response = {
    status = 500,
    json = {
      message = "Unknown failure"
    }
  }
  if t['status'] then
    response['status'] = t['status']
  end
  if t['msg'] then
    response['json']['message'] = t['msg']
  end
  if t['data'] then
    response['json']['data'] = t['data']
  end
  if t['msg'] == nil and response['status'] < 300 then
    response['json']['message'] = "OK"
  end
  if t['msg'] == nil and response['status'] == 404 then
    response['json']['message'] = "Entry does not exist"
  end
  if response['status'] >= 300 then
    library.log_err(response)
  end
  return response
end
return M
