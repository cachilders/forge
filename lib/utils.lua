musicutil = require('musicutil')

function get_musicutil_scale_names()
  local scales = {}
  for i=1, #musicutil.SCALES do
    scales[i] = musicutil.SCALES[i].name
  end

  return scales
end