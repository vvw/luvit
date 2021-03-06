--[[

Copyright 2012 The Luvit Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS-IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

--]]

require('helper')

local net = require('net')
local http = require('http')

local PORT = process.env.PORT or 10081
local HOST = '127.0.0.1'

local running = false

local caughtErrors = 0
local gotParseError = false

local server = net.createServer(function(client)
  client:write('test')
  client:destroy()
end)

server:listen(PORT, HOST, function()
  running = true

  local req = http.request({
    host = HOST,
    port = PORT,
    path = '/'
  }, function (res)
  end)

  req:on("error", function(err)
    msg = tostring(err)

    caughtErrors = caughtErrors + 1

    if msg:find('parse error') then
      gotParseError = true
    end

    if running then
      running = false
      req:destroy()
      server:close()
    end
  end)

  req:done()
end)

process:on('exit', function()
  assert(caughtErrors == 2)
  assert(gotParseError)
end)
