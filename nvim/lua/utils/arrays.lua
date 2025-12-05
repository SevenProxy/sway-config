local M = {}

--- Checks whether array includes value.
---
--- @generic T
--- @param array T[]
--- @param value T
--- @return boolean
function M.arr_includes(array, value)
	assert(type(array) == "table", "Expected array table")

	for i = 1, #array do
		if array[i] == value then
			return true
		end
	end

	return false
end

--- Inserts value into array
---
--- @generic T
--- @param array T[]
--- @param value T
--- @return nil
function M.insert(array, value)
	assert(type(array) == "table", "Expected array table")

	array[#array+1] = value
end

--- Removes all the elements from array
--- that return false when passed into predicate.
---
--- @generic T
--- @param array T[]
--- @param predicate fun(T): boolean
--- @return nil
function M.keep(array, predicate)
	assert(type(array) == "table", "Expected array table")
	assert(type(predicate) == "function", "Expected predicate function")

	local write = 1

	for read = 1, #array do
		if predicate(array[read]) then
			array[write] = array[read]
			write = write + 1
		end
	end

	for i = write, #array do
		array[i] = nil
	end
end

--- Removes first occurrence of value from array.
---
--- @generic T
--- @param array T[]
--- @param value T
--- @return boolean removed
function M.remove(array, value)
	assert(type(array) == "table", "Expected array table")

	for i = #array, 1, -1 do
		if array[i] == value then
			table.remove(array, i)
			return true
		end
	end

	return false
end

return M
