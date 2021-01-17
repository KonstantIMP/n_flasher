module Defines;

import std.conv;

immutable ubyte major_ver = 1;
immutable ubyte minor_ver = 2;
immutable ubyte build_ver = 0;

immutable string str_ver = to!string(major_ver) ~ '.' ~
                           to!string(minor_ver) ~ '.' ~
                           to!string(build_ver);