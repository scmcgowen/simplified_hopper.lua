-- Copyright umnikos (Alex Stefanov) 2023
-- Licensed under MIT license
-- Version 1.0

local args = {...}

local verbose=false
local function print_if_verbose(...)
    if verbose then
        print(table.unpack(arg))
    end
end

local help_message = [[
hopper script v1.0, made by umnikos, modified by Herr Katze

usage: hopper {from} {to} [{item name}/{flag}]*
example: hopper *chest* *barrel* *:pink_wool

To negate a filter, place a ! in front of it
flags:
  -o : Run the script only once instead of in a loop
  -v : Verbose mode (enables Debug prints)]]
if #args < 2 then
    print(help_message)
    return
end
local from = args[1]
local to = args[2]
local sources = {}
local destinations = {}
function glob(p, s)
  local p = "^"..string.gsub(p,"*",".*").."$"
  local res = string.match(s,p)
  
  return res ~= nil
end
for i,per in ipairs(peripheral.getNames()) do
  if glob(from,per) then
    sources[#sources+1] = per
  end
  if glob(to,per) then
    destinations[#destinations+1] = per
  end
end
print_if_verbose("hoppering from "..from)
if #sources == 0 then
  print_if_verbose("except there's nothing matching that description!")
  return
end
print_if_verbose("to "..to)
if #destinations == 0 then
  print_if_verbose("except there's nothing matching that description!")
  return
end
local filters = {}
local negative_filters = {}
local once = false
for i=3,#args do
    print_if_verbose(args[i]:match("^!"))
  if glob("-*",args[i]) then
    if args[i] == "-v" then
        print("Verbose Mode")
        verbose=true
    elseif args[i] == "-o" then
      print_if_verbose("(only once!)")
      once = true
    end
  elseif args[i]:match("^!") then
    print_if_verbose("Added negative filter",args[i])
    negative_filters[#negative_filters+1] = args[i]:gsub("^!","")
  else
    
    filters[#filters+1] = args[i]
  end
end
if #filters == 1 then
  print_if_verbose("only the items matching the filter "..filters[1])
elseif #filters > 1 then
  print_if_verbose("only the items matching any of the filters")
else
  filters[1] = "*"
end
while true do
  for _,source_name in ipairs(sources) do
    if not glob(to,source_name) then
      local source = peripheral.wrap(source_name)
      for _,dest_name in ipairs(destinations) do
        source_list = source.list()
        for i,item in pairs(source_list) do
        local negated = false
          
          for _,n_filter in ipairs(negative_filters) do
          
            if glob(n_filter,item.name) then
                negated = true
            end
          end
          
          for _,filter in ipairs(filters) do
            if glob(filter,item.name) and not negated then
              --print_if_verbose("pushing items")
              source.pushItems(dest_name,i)
            end
          end
        end
      end
    end
  end
  if once then
    break
  end
  sleep(1)
end