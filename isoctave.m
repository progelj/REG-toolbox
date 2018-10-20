% Author: Peter Rogelj <peter.rogelj@upr.si>

function isOctave = isoctave()

    isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
