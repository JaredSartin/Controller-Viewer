local gui = require('yue.gui')
local controller = require('controller')
local LIP = require('third-party.LIP')

local settings = LIP.load('settings.ini')
settings.render = settings.render or {
  scale = 1,
  ontop = true
}
settings.windowposition = settings.windowposition or {
  x = 0,
  y = 0,
  height = 512,
  width = 512,
}

local size = controller.getsize()

-- App Setup
gui.app:setname('Controller Overlay')
local appicon = gui.Image.createfrompath('./assets/app icon.png')
local win = gui.Window.create({ frame = false, transparent = true })
win:settitle('Controller Overlay')
win:setalwaysontop(settings.render.ontop)
win:setcontentsize({ width = size.width * settings.render.scale, height = size.height * settings.render.scale })
win:setskiptaskbar(true)
win:setresizable(false)
win:setmaximizable(false)
win:setminimizable(false)
win.shouldclose = function() return false end
win.onclose = function() gui.MessageLoop.quit() end

-- Settings Helpers
local setrenderscale = function(scale)
  settings.render.scale = scale
  win:setcontentsize({ width = size.width * settings.render.scale, height = size.height * settings.render.scale })
  LIP.save('settings.ini', settings)
end

local setalwaysontop = function(ontop)
  settings.render.ontop = ontop
  win:setalwaysontop(ontop)
  LIP.save('settings.ini', settings)
end

-- Tray Options
local quitoption = gui.MenuItem.create({
  type = 'label',
  label = 'Quit',
  onclick = function()
    settings.windowposition = win:getbounds()
    LIP.save('settings.ini', settings)
    gui.MessageLoop.quit()
  end
})

local overlayoption = gui.MenuItem.create({
  type = 'checkbox',
  label = 'Show Overlay',
  checked = true,
  onclick = function(self)
    win:setvisible(self:ischecked())
  end
})

local scalemenu = {
  {
    type = 'radio',
    label = '100%',
    checked = settings.render.scale == 1,
    onclick = function(self)
      setrenderscale(1)
    end
  },
  {
    type = 'radio',
    label = '75%',
    checked = settings.render.scale == 0.75,
    onclick = function(self)
      setrenderscale(0.75)
    end
  },
  {
    type = 'radio',
    label = '50%',
    checked = settings.render.scale == 0.5,
    onclick = function(self)
      setrenderscale(0.5)
    end
  }
}

local menuitems = {
  overlayoption,
  {
    type = 'checkbox',
    label = 'Always On Top',
    checked = settings.render.ontop,
    onclick = function(self)
      setalwaysontop(self:ischecked())
    end
  },
  {
    type = 'submenu',
    label = 'Scale',
    submenu = scalemenu
  },
  {
    type = 'label',
    label = 'Center Overlay',
    onclick = function()
      win:center()
    end
  },
  {
    type = 'separator',
  },
  quitoption
}
local traymenu = gui.Menu.create(menuitems)
gui.globalshortcut:register(settings.shortcut.toggleview, function() overlayoption:click() end)

local tray = gui.Tray.createwithimage(appicon)
tray:setmenu(traymenu)

local contentview = gui.Container.create()
contentview:setmousedowncanmovewindow(true)
win:setcontentview(contentview)

contentview.ondraw = function(self, painter)
  painter:scale({ x = settings.render.scale, y = settings.render.scale })
  controller.draw(painter, 1)
end

local redraw = function()
  contentview:schedulepaint()
  return true
end

win:setbounds(settings.windowposition)
win:activate()

-- currently at 60fps
gui.MessageLoop.settimer(16, redraw)
gui.MessageLoop.run()
