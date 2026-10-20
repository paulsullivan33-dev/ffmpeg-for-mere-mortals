# Scaling and Frame Rate

A screencast too big to upload, a clip that
only needs to be a thumbnail-sized preview:
shrinking video is a filter job — the
pixels themselves change, so unlike
chapter 4's copies, this always decodes
and re-encodes. Two dials do most of the
work.

## Scaling: the size of the picture

```
$ ffmpeg -hide_banner -y -i clip.mp4 -vf scale=160:90 -c:a copy clip-small.mp4

$ probe clip-small.mp4
codec_name=h264
width=160
height=90
duration=12.000000
size=239444
```

Half the width, half the height, and 239,444
bytes against the source's 473,168 — roughly
half the file for a quarter of the pixels
(encoding cost doesn't scale linearly with
area; the probe is again the authority, not
the intuition). `-vf` introduces a **video
filter**; `scale` is the filter; the audio
passes with `-c:a copy` because nothing
about it needed to change.

You rarely want to type both dimensions.
Give one and let the other follow the
aspect ratio — with `-2` rather than `-1`,
which rounds to an even number (most
codecs, H.264 included, insist on even
dimensions for the usual pixel formats):

```
$ ffmpeg -hide_banner -y -i clip.mp4 -vf 'scale=480:-2' -c:a copy clip-wide.mp4

$ probe clip-wide.mp4
width=480
height=270
size=689518
```

480 wide became 480×270, proportionally.
But look at the size: **689,518 bytes —
bigger than the 473,168-byte source.** This
chapter's free lesson in honesty: the lab
just *upscaled* a 320×180 clip to 480×270.
The encoder faithfully encoded a larger,
blurrier picture — interpolating detail
that does not exist — and charged more
bytes for it. **Scaling never adds detail.**
Down is a legitimate saving; up is a
larger file wearing a bigger frame, and
any tool or setting that promises otherwise
is selling something.

## Frame rate: how many pictures per second

```
$ ffmpeg -hide_banner -y -i clip.mp4 -vf fps=12 -c:a copy clip-12fps.mp4

$ probe clip-12fps.mp4
avg_frame_rate=12/1
duration=12.000000
size=351265
```

The `fps` filter re-times the stream to 12
frames per second — half the frames,
judged and merged/dropped by the filter —
and the probe's `avg_frame_rate` is the
proof. The saving here is modest (351,265
bytes) because this test pattern's motion
is cheap to encode at any rate; real
footage saves more. Halving the frame rate
of anything with smooth motion *shows* —
pans get steppy — so this dial belongs to
previews, surveillance-style footage, and
GIF-making (chapter 11), not to footage
people will watch for pleasure.

The two dials compose (`-vf
"scale=160:90,fps=12"`), and both belong to
the same family as chapter 7's audio
filters: a filter chain is ffmpeg's general
way of changing the goods rather than the
box. What neither dial changes: the
*duration*, the audio, or the past — a
small, soft source upscaled and re-fps'd
is still the source it was.

Check: `probe clip-small.mp4` reads
160×90 at 239,444 bytes, and
`clip-12fps.mp4` reads `avg_frame_rate=12/1`
— while `clip-wide.mp4`, the upscale, is
the *largest* file of the three. If your
intuition predicted otherwise before the
probes, keep the probes; they're cheaper
than intuition.
