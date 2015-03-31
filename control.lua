require "defines"

-- myevent = game.generateeventname()
-- the name and tick are filled for the event automatically
-- this event is raised with extra parameter foo with value "bar"
--game.raiseevent(myevent, {foo="bar"})
local events = {}
events["onvehicleenter"] = game.generateeventname()
events["onvehicleleave"] = game.generateeventname()
events["onguiopen"] = game.generateeventname()
events["onguiclose"] = game.generateeventname()


local function initGlob()
  glob.playerEntered = glob.playerEntered or {}
  glob.playerOpened = glob.playerOpened or {}
end

local function oninit()
  initGlob()
end

local function onload()
  initGlob()
end

local function onTick(event)
  for pi, player in pairs(game.players) do
    if event.tick % 10 == 0  then
      if (player.vehicle ~= nil and not glob.playerEntered[player.name]) then
        game.raiseevent(events["onvehicleenter"], {entity=player.vehicle, playerindex=pi})
        glob.playerEntered[player.name] = player.vehicle
      end
      if glob.playerEntered[player.name] and player.vehicle == nil then
        game.raiseevent(events["onvehicleleave"], {entity=glob.playerEntered[player.name], playerindex=pi})
        glob.playerEntered[player.name] = nil
      end
    end
    if player.opened ~= nil and not glob.playerOpened[player.name] then
      game.raiseevent(events["onguiopen"], {entity=player.opened, playerindex=pi})
      glob.playerOpened[player.name] = player.opened
    end
    if glob.playerOpened[player.name] and player.opened == nil then
      game.raiseevent(events["onguiclose"], {entity=glob.playerOpened[player.name], playerindex=pi})
      glob.playerOpened[player.name] = nil
    end
  end
end

game.oninit(oninit)
game.onload(onload)
game.onevent(defines.events.ontick, onTick)

remote.addinterface("gui",
  {
    getEvents = function()
      return events
    end,
    
    registerGUI = function(modname, position)
      if not glob.registeredGUIs[modname] then
        glob.registeredGUIs[modname] = {}
      end
      if not glob.registeredGUIs[modname][position] then
        glob.registeredGUIs[modname][position] = true
      end
    end,
    
    getRoot = function(playerindex, modname, position)
      local r = game.players[playerindex][position].guiFramework[modname]
      if r ~= nil then
        return r
      else
        return false
      end
    end
  })
