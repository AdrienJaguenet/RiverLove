settings = {
	ITEM_SPEED = 200,
}

function filter_inplace(arr, func)
    local new_index = 1
    local size_orig = #arr
    for old_index, v in ipairs(arr) do
        if func(v, old_index) then
            arr[new_index] = v
            new_index = new_index + 1
        end
    end
    for i = new_index, size_orig do arr[i] = nil end
end

function newItem()
	return {
		x = math.random(settings.MIN_SPAWNX, settings.MAX_SPAWNX),
		y = 0,
	}
end

function drawItem(item)
	love.graphics.circle('fill', item.x, item.y, 10)
end

function love.load()
	items = {}
	settings.MIN_SPAWNX = love.graphics.getWidth() / 10
	settings.MAX_SPAWNX = 9 * love.graphics.getWidth() / 10
end

function love.update(dt)
	if math.random(0, 10) == 0 then
		table.insert(items, newItem())
	end

	for k, v in pairs(items) do
		v.y = v.y + settings.ITEM_SPEED * dt
	end
end

function love.draw()
	for k, v in pairs(items) do
		drawItem(v)
	end
end

