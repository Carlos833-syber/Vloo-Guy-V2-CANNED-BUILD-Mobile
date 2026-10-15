-- Android equivalent of performance/stages/performance.hx.
function onCreatePost()
    makeLuaSprite('performanceBackground', 'bgs/b', 0, 0)
    addLuaSprite('performanceBackground', false)
    setObjectOrder('performanceBackground', getObjectOrder('gfGroup'))
    makeLuaSprite('performanceCurtains', 'bgs/b1', 0, 0)
    addLuaSprite('performanceCurtains', true)
    callMethod('swapStrums', {})
    setProperty('camOffset', 5)
end
