function test_suite = test_gent
% TEST_GENT test function for gent using mtest framework

initTestSuite;

function h = setup
h.v = 1:5; % the vector in need of a time vector, t (t is in seconds)
h.fs = 10; % samples per second
h.offset = 95; % seconds

function teardown(h)
%disp('no need to "clear h"')

function testIncorrectNargs(h)
% TESTINCORRECTNARGS -- test whether proper number of arguments exception thrown
assertExceptionThrown(@()gent(h.v),'daly:common:wrongNumberOfArguments');

% Needed for possible future changes to gent input profile
assertExceptionThrown(@()gent(h.v,h.fs,h.offset,1),'MATLAB:TooManyInputs');

function testTimeVector(h)
% TESTTIMEVECTOR -- test whether output time vector is as expected with and without offset

% Get expected output with no offset using simple, dead reckoning example
dt = 1/h.fs; % time step in seconds (where fs is in samples/second)
t1 = 0; % first time value in seconds
calcTVecNoOffset = t1 + [0 1 2 3 4]*dt; % in seconds

% Get expected output with an offset
calcTVecWithOffset= calcTVecNoOffset + h.offset; % both addends are in seconds
expectedSize = size(calcTVecWithOffset);

assertEqual(calcTVecNoOffset,... Calculated values
    gent(h.v,h.fs),... Generated values
    'Compare manually calculated time vector with gent method (with no offset)'); % Message

assertEqual(calcTVecWithOffset,... Calculated values
    gent(h.v,h.fs,h.offset),... Generated values
    'Compare manually calculated time vector with gent method (including offset)'); % Message

assertEqual(expectedSize,... calculated size
    size(gent(h.v,h.fs,h.offset)),... generated size
    'Compare manually calculated time vector''s size with gent method (including offset)'); % Message