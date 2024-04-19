local gui = require('yue.gui')
local xinput = require('lua-xinput')
local LIP = require('third-party.LIP')

local STICK_EXTENT = 32768.0
local TRIGGER_EXTENT = 255

local theme = LIP.load('theme.ini')
local assetmap = {}

local drawstick = function(painter, stickname, xval, yval, xinput_data)
  local btns = xinput_data[2]
  local stick = assetmap[stickname]
  local settings = theme[stickname]

  local xpct = xval / STICK_EXTENT
  local ypct = yval / STICK_EXTENT

  local xmove = 0
  local ymove = 0
  local sourcerect = { x = 0, y = 0, width = stick.size.width, height = stick.size.height / 3 }

  if (math.abs(xpct) > settings.deadzone or math.abs(ypct) > settings.deadzone) then
    xmove = xpct * settings.motionx
    -- y is inverted
    ymove = -ypct * settings.motiony
    sourcerect.y = sourcerect.height
  end

  if btns[stickname] then sourcerect.y = sourcerect.height * 2 end

  painter:drawimagefromrect(stick.image,
    sourcerect,
    {
      x = settings.offsetx + xmove,
      y = settings.offsety + ymove,
      width = sourcerect.width,
      height = sourcerect.height
    }
  )
end

local drawsticks = function(painter, xinput_data)
  drawstick(painter, 'leftThumb', xinput_data[5], xinput_data[6], xinput_data)
  drawstick(painter, 'rightThumb', xinput_data[7], xinput_data[8], xinput_data)
end

local drawbuttons = function(painter, xinput_data)
  local btns = xinput_data[2]
  for k, v in pairs(theme) do
    if v.mapping ~= nil then
      local actionimagerect = {
        x = 0,
        y = 0,
        width = assetmap[k].size.width,
        height = assetmap[k].size.height / 2,
      }

      if btns[v.mapping] then actionimagerect.y = actionimagerect.height end

      painter:drawimagefromrect(assetmap[k].image,
        actionimagerect,
        {
          x = v.offsetx,
          y = v.offsety,
          width = assetmap[k].size.width,
          height = assetmap[k].size.height / 2,
        }
      )
    end
  end
end

local drawtrigger = function(painter, triggername, axis)
  local asset = assetmap[triggername]
  local pct = axis / TRIGGER_EXTENT
  local actionimagerect = {
    x = 0,
    y = asset.size.height * (1 - pct),
    width = asset.size.width,
    height = asset.size.height * pct,
  }
  painter:drawimagefromrect(assetmap[triggername].image,
    actionimagerect,
    {
      x = theme[triggername].offsetx,
      y = theme[triggername].offsety + actionimagerect.y,
      width = asset.size.width,
      height = asset.size.height * pct,
    }
  )
end

local drawtriggers = function(painter, xinput_data)
  drawtrigger(painter, 'ltfill', xinput_data[3])
  drawtrigger(painter, 'rtfill', xinput_data[4])
end

local controller = {}
controller.draw = function(painter, index)
  local xinput_data = { xinput.getState(index - 1) }
  if xinput_data[1] then
    painter:drawimage(assetmap.base.image, assetmap.base.rect)
    drawsticks(painter, xinput_data)
    drawtriggers(painter, xinput_data)
    drawbuttons(painter, xinput_data)
  else
    painter:drawimage(assetmap.error.image, assetmap.error.rect)
  end
end

controller.getsize = function()
  return assetmap.base.size
end

-- setup
(function()
  -- load assets
  for k, v in pairs(theme) do
    assetmap[k] = {
      image = gui.Image.createfrompath(v.asset)
    }
    assetmap[k].size = assetmap[k].image:getsize()

    if (k:find('button_') == 1) then
      v.mapping = k:sub(k:find('_') + 1)
    end
  end

  assetmap.base.rect = assetmap.base.size
  assetmap.base.rect.x = 0
  assetmap.base.rect.y = 0

  assetmap.error.rect = assetmap.error.size
  assetmap.error.rect.x = 0
  assetmap.error.rect.y = 0
end)()

return controller
