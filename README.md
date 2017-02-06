# Contents

This code contains a few files.  `wgenerator.m` and `wfromzernikecoef.m` can be largely ignored - they are repository of W functions (W020, W040, etc) and zernike functions that describe pupils.

The machinery is contained in `AberrationSwissArmyKnife.m,` which requires `PupilPerscription.m.`  The latter, as you may guess, describes the pupil of an optical system mathematically.

A pupil prescription is defined as having a notation ("S," aka Seidel, or "Z," Fringe Zernike).  There are also seidel term and zernike term, as well as coefficient properties.  These describe the aberrations and must have the same length.  For example, if `zernikeTerms = [0, 1, 2]` and `zernikeCoefficients = [1, 1, 1]`, the pupil prescription describes a pupil which has zernike piston, x tilt, and y tilt; all of magnitude 1.

The fringe zernike polynomials used are not a normalized set, so using e.g. Z8 with magnitude 1 does not produce anything like 1 wave of spherical (either 0 to peak or RMS).  The zernike terms can be traced back to combinations of W polynomial expressions and this used to compute appropriate normalizations.

# Usage

To use this code, first build a pupil, then make a new `AberrationSwissArmyKnife` object.  The swiss army knife constructor does not perform any computation, member methods must be used to compute the pupil, point spread function, and MTF.  The PSF cannot be computed without the pupil, and the MTF cannot be computed without the PSF.

```matlab
myPupil = PupilPrescription('notation','Z','zernikeTerms',[0, 1, 2],'zernikeCoefficients',[1, 1, 1]);
mySAK = AberrationSwissArmyKnife('pupil',myPupil);

WPlotter.plot3D(mySAK);
PSFPlotter.plot3D(mySAK);
figure;
hold on;
MTFPlotter.plotTan(mySAK);
MTFPlotter.plotSag(mySAK);
hold off;

% plots of the wavefront, point spread function, and MTF appear
```
