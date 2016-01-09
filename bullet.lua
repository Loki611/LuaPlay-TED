BULLET = {}

BULLET.make = function(id, tab)
    tab.angle = 0
    tab.pos = Vector(100, 0)
    tab.size = Size(10, 10)
    tab.speed = 80
    
    tab.render = function()
        graphics.DrawRect(tab.pos.x, tab.pos.y, tab.size.w, tab.size.h, Color(0, 255, 0))
    end
    
    tab.tick = function(delta)
        tab.pos.x = tab.pos.x + math.cos(math.rad(tab.angle)) * delta * tab.speed
        tab.pos.y = tab.pos.y + math.sin(math.rad(tab.angle)) * delta * tab.speed
    end
end