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

function test_scale_to_unipolar_output_range(v, cycle_min, cycle_max)
  local cycle_min, cycle_max = -5, 10
  -- Given: Default cycle range
  local lowest = calculate_cycle_to_screen_proportions(-5, cycle_min, cycle_max)
  test.assertEquals(lowest, 0, 'Lowest voltage scales to 0')
  local highest = calculate_cycle_to_screen_proportions(10, cycle_min, cycle_max)
  test.assertEquals(highest, cycle_max, 'Highest voltage scales to cycle max')

  -- Given: Adjusted cycle range
  cycle_min, cycle_max = -1, 5
  local lowest = calculate_cycle_to_screen_proportions(-1, cycle_min, cycle_max)
  test.assertEquals(lowest, 0, 'Lowest voltage scales to 0')
  local highest = calculate_cycle_to_screen_proportions(5, cycle_min, cycle_max)
  test.assertEquals(highest, cycle_max, 'Highest voltage scales to cycle max')
end