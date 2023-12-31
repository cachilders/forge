musicutil = require('musicutil')

function find_line_segment_overlap (ax, ay, bx, by, cx, cy, dx, dy) -- start end start end
  -- Stack overflow answer. Refine solution.
  -- https://stackoverflow.com/questions/45478638/intersection-or-overlap-of-two-line-segments
  if ax and ay and bx and by and cx and cy and dx and dy then
      local d = (ax-bx)*(cy-dy)-(ay-by)*(cx-dx)

      if d == 0 then
          return nil  -- they are parallel
      end

      local a, b = ax*by-ay*bx, cx*dy-cy*dx
      local x = (a*(cx-dx) - b*(ax-bx))/d
      local y = (a*(cy-dy) - b*(ay-by))/d

      if x <= math.max(ax, bx) and x >= math.min(ax, bx) and
          x <= math.max(cx, dx) and x >= math.min(cx, dx) then
          -- between start and end of both lines
          return {x = x, y = y}
      end
    end

    return nil
end

function regulate_voltage(v, min, max)
  if v < min then return min end
  if v > max then return max end
  return v
end

function calculate_cycle_to_screen_proportions(v, frame_height, frame_height_offset, cycle_min, cycle_max)
  local offset = (cycle_min * -1)
  local cycle_range = cycle_max + offset
  local scale_operand = (frame_height - frame_height_offset) / cycle_range
  local regulated_voltage = regulate_voltage(v, cycle_min, cycle_max)
  local offset_volts = regulated_voltage + offset
  return (scale_operand * (cycle_range - offset_volts)) + frame_height_offset
end

function scale_to_unipolar_output_range(v, output_min, output_max)
  -- Using the crow range, may revisit with trimming, but there are too many assumptions
  -- To wit: output range is the limits of the device, not the output of the method.
  if output_min >= 0 and v >= 0 then return v end
  if v < output_min then return 0 end

  local offset = math.abs(output_min)
  local output_range = output_max + offset

  local scale_operand = output_max / output_range
  local offset_volts = v + offset
  return offset_volts * scale_operand
end

function get_musicutil_scale_names()
  local scales = {}
  for i = 1, #musicutil.SCALES do
    scales[i] = musicutil.SCALES[i].name
  end

  return scales
end

function truncate_string(s, l)
  if string.len(s) > l then
    return ''..string.sub(s, 1, l-1)..'...'
  end
  return s
end
