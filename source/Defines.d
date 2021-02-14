/// @file Defines.d
/// 
/// @brief n_flasher version and other defines
///
/// @license LGPLv3 (see LICENSE file)
/// @author KonstantIMP
/// @date 2021
module Defines;

import std.conv;

immutable ubyte major_ver = 2;
immutable ubyte minor_ver = 0;
immutable ubyte build_ver = 1;

immutable string str_ver = to!string(major_ver) ~ '.' ~
                           to!string(minor_ver) ~ '.' ~
                           to!string(build_ver);