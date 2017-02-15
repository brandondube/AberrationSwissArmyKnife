# Contents

This code contains a few files.  `wgenerator.m` and `wfromzernikecoef.m` can be largely ignored - they are repository of W functions (W020, W040, etc) and zernike functions that describe pupils.

The machinery is contained in `AberrationSwissArmyKnife.m,` which requires `PupilPerscription.m.`  The latter, as you may guess, describes the pupil of an optical system mathematically.

A pupil prescription is defined as having a notation ("S," aka Seidel, or "Z," Fringe Zernike).

The fringe zernike polynomials used are not a normalized set, so using e.g. Z8 with magnitude 1 does not produce anything like 1 wave of spherical (either 0 to peak or RMS).  The zernike terms can be traced back to combinations of W polynomial expressions and this used to compute appropriate normalizations.
