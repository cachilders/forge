TODO
- Notes are pooling behind the quantizer queue when transport is paused
- - This is one bug just because they should die if next notes is false
- - But another because the generator should always be on regardless of play state or match the play state. it's starting off but not shutting off after being started
- Add "No Crow Connected" state if crow is output
- Make additional player output devices (midi, crow volts, etc)
- Crow is raw volts 1/2 and quant volts 3/4
- Move the midi init stuff someplace better than params
- Clean up all the global space pollution with proper object returns and locals
- Fix drawing bug (lines between objects) if possible (low priority honestly because it looks good)