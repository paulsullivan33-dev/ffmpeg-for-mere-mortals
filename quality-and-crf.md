# Quality and CRF

"What quality should I encode at?" is the
most-asked ffmpeg question, and it has a
secret the folklore skips: the honest
answer is a trade you *measure*, on your
own footage, between bytes and fidelity.
This chapter makes the trade once, for
real, so the dials stop being superstition.

When you re-encode video with libx264,
there are two main ways to state the
bargain:

- **A bit rate** (`-b:v 2000k`) — a budget:
   spend exactly this much per second. The
   file size becomes predictable and the
   quality floats — busy scenes starve,
   quiet scenes waste.
- **CRF** (`-crf 23`) — a *quality* dial:
   hold the perceived quality roughly
   constant and let the bit rate float. 0
   is lossless, 51 is the bottom; the
   encoder's default is 23. Lower number,
   higher quality, bigger file. Sizes become
   the floating side — which is why you
   measure them.

Chapter 5's audio had the same fork
(`-b:a` vs `-q:a`); CRF is the video side
of it.

## The trade, measured

The source is `scene.mp4`: 640×360, 30 fps,
6 seconds, 1,247,385 bytes (itself encoded
gently at CRF 12 when the fixture was
made). Re-encoded at two CRF values, same
preset, and compared — by size, and by
**SSIM**, a similarity score ffmpeg can
compute between two videos (1.000 would be
identical; it measures structure, not
beauty, but it is a number and not a vibe):

| encode | bytes | elapsed | SSIM vs source |
|---|---|---|---|
| source (CRF 12) | 1,247,385 | — | — |
| CRF 18 | 863,725 | 2.38 s | 0.9981 |
| CRF 28 | 310,271 | 1.88 s | 0.9867 |

Ten CRF points apart: the file shrinks
2.8×, and the similarity score gives up
0.011 — from "visually transparent for
nearly all material" territory (18) to
"clearly a compression, still perfectly
watchable" (28). Those characterizations
are the community's rough map of the dial;
the *sizes and scores are this lab's
measurements*, on test-pattern footage
that is harder on encoders than most real
video. Your footage will price the same
dial differently — sports vs a slideshow
is easily another factor of two — which is
the chapter whole point: ** encode the
first minute at two settings, probe, and
pick with numbers in front of you.**

## The other dial: preset

For a given CRF, `-preset` trades *your
time* for the encoder's cleverness —
slower presets search harder for savings:

| CRF 23 | bytes | elapsed |
|---|---|---|
| `-preset fast` | 584,952 | 1.40 s |
| `-preset slow` | 556,905 | 2.20 s |

Same quality target, 5% fewer bytes, 57%
longer at the keyboard — on a six-second
clip. Scale that to an hour of footage and
preset stops being a footnote; scale the
5% to a library and it may pay anyway.
There is no virtue in either direction.
There is a number, and a clock, and your
material.

## What no setting buys

Two limits that belong in every quality
conversation, both already demonstrated in
this guide:

- **You cannot encode your way above the
  source.** Chapter 9's extraction spent
  160 kb/s re-writing 71 kb/s audio and
  gained nothing but bytes; chapter 10's
  upscale charged 689,518 bytes for a
  blurrier picture. Re-encoding is a
  *copying* process with loss at every
  pass — the best possible output of any
  encode is a slightly worse source.
- **Every generation loses.** Converted
  files are distribution copies. Keep the
  original — the WAV, the camera file, the
  high-CRF master — because all future
  conversions should start from it, not
  from last year's MP4.

Check: your two CRF encodes reproduce the
table's shape — CRF 28 near a third of
CRF 18's bytes, SSIM a point or so lower —
and the slow preset's file is the smaller
of the CRF 23 pair while its `elapsed:`
line is the larger. If your numbers match
that shape, the dials behave on your
machine as they do here, and you can price
any future job with two one-minute tests.
