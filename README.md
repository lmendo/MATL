# MATL
A programming language based on MATLAB/Octave and suitable for code golfing

The compiler works in MATLAB R2015b. Probably in older versions too, except for some specific functions. It is also compatible with Octave 4.0.0. The compiler tries to ensure consistent behaviour  in both platforms.

Installation: unpack the compressed file to a folder, and make that folder part of MATLAB's or Octave's search path.

Test: running `matl 10:t!*` from the command window should produce a decimal multiplication table.

Usage: see [specification document](https://github.com/lmendo/MATL/blob/master/doc/MATL_spec.pdf).

