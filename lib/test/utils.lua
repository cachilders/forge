test = require 'test/luaunit'

include('lib/utils')

function test_calculate_cycle_to_screen_proportions()
  local frame_height, frame_height_offset = 50, 5
  local cycle_min, cycle_max = -5, 10
  -- Background: Norns draws from top (1) to bottom (64)
  
  -- Given: Default cycle range
  local lowest = calculate_cycle_to_screen_proportions(-5, frame_height, frame_height_offset, cycle_min, cycle_max)
  test.assertEquals(lowest, frame_height, 'Lowest voltage draws at highest pixel')
  local highest = calculate_cycle_to_screen_proportions(10, frame_height, frame_height_offset, cycle_min, cycle_max)
  test.assertEquals(highest, frame_height_offset, 'Highest voltage draws at lowest pixel')

  -- Given: Adjusted cycle range
  cycle_min, cycle_max = 1, 5
  local lowest = calculate_cycle_to_screen_proportions(-5, frame_height, frame_height_offset, cycle_min, cycle_max)
  test.assertEquals(lowest, frame_height, 'Lowest voltage draws at highest pixel')
  local highest = calculate_cycle_to_screen_proportions(10, frame_height, frame_height_offset, cycle_min, cycle_max)
  test.assertEquals(highest, frame_height_offset, 'Highest voltage draws at lowest pixel')
end