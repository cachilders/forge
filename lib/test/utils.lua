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

function test_scale_to_unipolar_output_range()
  local output_min, output_max = -5, 10
  -- Given: Default output range
  local lowest = scale_to_unipolar_output_range(-5, output_min, output_max)
  test.assertEquals(lowest, 0, 'Lowest voltage scales to 0')
  local highest = scale_to_unipolar_output_range(10, output_min, output_max)
  test.assertEquals(highest, output_max, 'Highest voltage scales to output max')

  -- Given: Adjusted output range
  output_min, output_max = -1, 5
  local lowest = scale_to_unipolar_output_range(-1, output_min, output_max)
  test.assertEquals(lowest, 0, 'Lowest voltage scales to 0')
  local highest = scale_to_unipolar_output_range(5, output_min, output_max)
  test.assertEquals(highest, output_max, 'Highest voltage scales to output max')

  -- Given: Positive min
  output_min, output_max = 1, 5
  local positive_min = scale_to_unipolar_output_range(2, output_min, output_max)
  test.assertEquals(positive_min, 2, 'Returns volts it is given')

  -- Given: Zero min
  output_min, output_max = 0, 5
  local positive_min = scale_to_unipolar_output_range(2, output_min, output_max)
  test.assertEquals(positive_min, 2, 'Returns volts it is given')

  -- Given: Min is positive, but a negative note ocurred
  output_min, output_max = 1, 5
  local positive_min = scale_to_unipolar_output_range(-2, output_min, output_max)
  test.assertEquals(positive_min, 0, 'Resolves to 0 as lowest volts')
end