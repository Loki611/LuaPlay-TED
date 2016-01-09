ENEMY = {}
local id = 0

ENEMY.make = function(tab)
    tab.health = 10 -- Default health
    tab.maxHealth = 10
    tab.speed = 5
    tab.value = 10
    tab.size = Size(26, 26)
    tab.pos = Vector(0, 0)
    tab.id = id
    tab.tileTarget = 1
    tab.curTile = 0
    tab.tileObj = nil
    
    function tab.getCenter()
        return Vector(tab.pos.x + (tab.size.w/2), tab.pos.y + (tab.size.h/2))
    end
    
    function tab.render()
        graphics.DrawRect(tab.pos.x, tab.pos.y, tab.size.w, tab.size.h, Color(255, 0, 0))
        
        graphics.DrawRect(tab.pos.x, tab.pos.y + tab.size.h, (tab.health / tab.maxHealth) * tab.size.w, -5, Color(0, 255, 0))
    end

    function tab.onDeath()
        hook.Call("OnEnemyDeath", tab.id)
    end
    
    function tab.killSilent()
        tab.takeDamage(tab.health, true)
        hook.Call("SilentDeath", tab.id)
    end
    
    function tab.takeDamage(dmg, silent)
        silent = silent or false
        tab.health = tab.health - dmg
        
        if(tab.health <= 0 and not silent)then
            tab.onDeath()
        end
        
        hook.Call("OnEnemyTakeDamage", tab.id)
    end
    
    function tab.tick(delta)
        if(tab.tileTarget <= MAP.maxTile())then
            if(util.IsColliding(tab.getCenter().x, tab.getCenter().y, 1, 1, MAP.getTile(tab.tileTarget).x, MAP.getTile(tab.tileTarget).y, 50, 50))then
                tab.curTile = tab.curTile + 1
                tab.findMove()
            end
        end
    
        if(tab.tileObj == nil)then return end
        
        if(tab.getCenter().x < tab.tileObj.x + 25)then
            tab.pos.x = tab.pos.x + tab.speed * delta
        elseif(tab.getCenter().x > tab.tileObj.x + 25)then
            tab.pos.x = tab.pos.x - tab.speed * delta
        end

        if(tab.getCenter().y < tab.tileObj.y + 25)then
            tab.pos.y = tab.pos.y + tab.speed * delta
        elseif(tab.getCenter().y > tab.tileObj.y + 25)then
            tab.pos.y = tab.pos.y - tab.speed * delta
        end
    end
    
    function tab.findMove()
        tab.tileObj = MAP.getNext(tab.tileTarget)
        
        if(tab.tileObj ~= nil)then 
            tab.tileTarget = tab.curTile + 1
            
            if(tab.curTile >= MAP.maxTile())then
                tab.tileTarget = MAP.maxTile()
                tab.curTile = tab.tileTarget;
                print("MAXED")
            end
        end
        hook.Call("OnEnemyMove")
    end
    id = id +1
end

ENEMY.make(ENEMY)