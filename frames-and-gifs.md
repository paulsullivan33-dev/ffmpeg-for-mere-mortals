# Frames and GIFs

Sometimes the job is not a movie at all but
a still: a thumbnail for a listing, one
frame to attach to a bug report ("*this*
is what it does at seven seconds"), proof
of what's in a file you can't play here.

## One frame

Chapter 6's fast seek, cashed in: land at
7 seconds, take a single frame, stop:

```
$ ffmpeg -hide_banner -y -ss 7 -i clip.mp4 -frames:v 1 thumb.png

$ probe thumb.png
codec_name=png
codec_type=video
width=320
height=180
$ ls -l thumb.png
-rw-rw---- 1 root nogroup 23981 thumb.png
```

`-frames:v 1` is the whole trick — one
video frame, written as an image. The PNG
really is the 7.000-second frame: this is
the same extraction the trimming chapter
used to audit its cuts (the burned-in timer
read 00:00:07 there, as it does in the
thumbnail). JPG works the same way
(`thumb.jpg`, with `-q:v` as its quality
dial); PNG is the safer default for
screenshots because it loses nothing.

A strip of stills — one per second, for a
contact sheet or a quick skim — is the
`fps` filter from chapter 10 pointed at
image outputs:

```
$ ffmpeg -hide_banner -y -i clip.mp4 -vf fps=1 -t 3 frames-%02d.png
$ ls frames-*.png
frames-01.png  frames-02.png  frames-03.png
```

`%02d` in the name is a numbered pattern —
ffmpeg fills in 01, 02, 03 — and `-t 3`
kept the strip to the first three seconds
rather than all twelve.

## A short GIF, done properly

GIF is a 1987 image format moonlighting as
the web's short-video format: no audio, at
most 256 colours per frame, and compression
that punishes noise. The two decisions that
decide a GIF's size are its dimensions and
frame rate — shrink both first (chapter
10's dials), *then* worry about colour.
Colour is where the two-pass method earns
its keep: GIF's 256 colours should be
chosen *from this clip*, not from a
generic palette.

```
$ ffmpeg -hide_banner -y -ss 2 -t 3 -i clip.mp4 -vf 'fps=10,scale=240:-1:flags=lanczos,palettegen' palette.png
$ ffmpeg -hide_banner -y -ss 2 -t 3 -i clip.mp4 -i palette.png -filter_complex 'fps=10,scale=240:-1:flags=lanczos[x];[x][1:v]paletteuse' clip.gif

$ probe clip.gif
codec_name=gif
duration=3.000000
$ ls -l clip.gif
-rw-rw---- 1 root nogroup 265235 clip.gif
```

Pass one (`palettegen`) analyses the clip
segment and writes its ideal 256 colours as
a one-image palette file (894 bytes here).
Pass two (`paletteuse`) takes the clip
*and* the palette as its two inputs —
chapter 3's multi-input grammar — and maps
every pixel to that palette. Three seconds,
240 wide, 10 fps: 265,235 bytes.

And now the measurement that keeps this
guide honest. The one-pass shortcut — same
clip, same size, ffmpeg's default palette,
no ceremony:

```
$ ffmpeg -hide_banner -y -ss 2 -t 3 -i clip.mp4 -vf 'fps=10,scale=240:-1:flags=lanczos' clip-naive.gif
$ ls -l clip-naive.gif
-rw-rw---- 1 root nogroup 170940 clip-naive.gif
```

**The naive GIF is smaller** — 170,940
against 265,235. On *this* fixture the
two-pass method lost, and the chapter is
keeping the loss in print on purpose. The
test pattern is nearly worst-case GIF
material: hard colour edges and animated
noise-like detail, where a tailored palette
spends its colours on the pattern's rainbow
and the frame-to-frame differences stay
large either way. On ordinary photographic
footage the tailored palette usually wins
— in quality at a given size, most visibly
in smooth gradients — but "usually" is a
claim about footage this lab doesn't
contain, and the guide won't print it as a
measurement. What the lab does establish is
the working method: **make both, probe
both, keep the one your eyes and the byte
count agree on.** The commands differ by
seconds of your time; folklore is not a
faster route than measurement.

Check: your `thumb.png` probes as a
320×180 PNG, and your two GIFs bracket
the sizes above — palette near 265 KB,
naive near 171 KB — with the naive one
ahead on this fixture. If your real-world
clip reverses them, you've reproduced the
rest of the lesson.
