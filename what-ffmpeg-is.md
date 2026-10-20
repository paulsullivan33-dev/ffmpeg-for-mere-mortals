# What ffmpeg Is

Somewhere on your machine there is a video
that won't play in the program you opened it
with, a voice memo too quiet to hear, a clip
six seconds too long. The graphical tools
that fix these things are mostly wrappers:
underneath, a very large share of them call
one program to do the actual work. That
program is **ffmpeg** — a command-line
converter that has been reading and writing
media formats since 2000, and has quietly
become the plumbing of digital audio and
video. Streaming sites transcode with it.
Editors render with it. This guide teaches
you to drive it yourself.

It travels with two companions:

- **ffmpeg** — the converter. Reads inputs,
  writes outputs, applies filters on the way.
- **ffprobe** — the inspector. Reads a file
  and reports what is actually inside it:
  which codecs, how long, how big, how fast.
  Chapter 2 is devoted to it, because the
  first habit of working with media is
  *look before you convert*.
- **ffplay** — a minimal player, useful for
  a quick listen; this guide mentions it and
  otherwise leaves it alone.

## Checking your install

```
$ ffmpeg -version
ffmpeg version 8.1.2 Copyright (c) 2000-2026 the FFmpeg developers
built with gcc 13 (Ubuntu 13.3.0-6ubuntu2~24.04.1)
configuration: --prefix=/usr --extra-version= --toolchain=hardened ...
```

```
$ ffprobe -version | head -1
ffprobe version 8.1.2 Copyright (c) 2007-2026 the FFmpeg developers
```

If you don't have it: `apt install ffmpeg`
on Debian/Ubuntu, `brew install ffmpeg` on a
Mac, or the builds linked from ffmpeg.org on
Windows. Version numbers differ by platform
and year; everything in this guide was run
on **8.1.2**, and nothing here needs a newer
feature than that.

That `configuration:` line in the version
banner matters more than it looks. ffmpeg is
one program, but it is *compiled* with a
choice of outside libraries — and the choice
decides which encoders your copy has. The
encoders this guide uses are visible in
yours the same way:

```
$ ffmpeg -hide_banner -encoders | grep -E "libx264 |libmp3lame|aac |libopus"
 V....D libx264              libx264 H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10 (codec h264)
 V....D libx264rgb           libx264rgb H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10 RGB (codec h264)
 A....D aac                  AAC (Advanced Audio Coding)
 A....D libmp3lame           libmp3lame MP3 (MPEG audio layer 3) (codec mp3)
 A....D libopus              libopus Opus (codec opus)
```

The one-line version of a long licensing
story: some codecs are patent-encumbered or
library-licensed, so different builds of
ffmpeg bundle different sets. The practical
rule is in the capture above — before you
follow any recipe from anywhere, check that
the encoder it names exists in *your* build
with `-encoders`, and the full inventory
with `-codecs`. A recipe that fails with
"Unknown encoder" is usually this, not a
typo.

## The lab

The `examples/` directory ships the files
every chapter uses:

- `tone.wav` — a 440 Hz tone, 6 seconds:
  the simple audio file
- `voice.wav` — a too-quiet tone, 8 seconds,
  peaking at −42.5 dB: the voice memo that
  needs help (chapter 7)
- `song.flac` — a three-note chord in FLAC,
  6 seconds: the lossless song
- `clip.mp4` — a test-pattern clip with a
  tone, 12 seconds, 320×180: the footage
- `part1.mp4`, `part2.mp4` — two 3-second
  clips with identical settings, for joining
  (chapter 8)
- `scene.mp4` — a busier 640×360 clip, 6
  seconds: the quality chapter's source
- `subs.srt` — two subtitles, to be muxed
  into the clip in chapter 4

None of them were recorded or downloaded.
`make-fixtures.sh` generates all of them
with ffmpeg's own test sources (`sine`,
`testsrc2`, `smptebars`), so the lab rebuilds
identically anywhere:

```
$ ls -l
-rw-rw---- 1 root nogroup  473168 clip.mp4
-rw-rw---- 1 root nogroup  115187 part1.mp4
-rw-rw---- 1 root nogroup   32140 part2.mp4
-rw-rw---- 1 root nogroup 1247385 scene.mp4
-rw-rw---- 1 root nogroup  297302 song.flac
-rw-rw---- 1 root nogroup  529278 tone.wav
-rw-rw---- 1 root nogroup  705678 voice.wav
```

The test pattern is a deliberate choice, not
a shortcut: it burns a running timer and a
frame counter into every frame, which makes
it a measuring instrument. When chapter 6
claims a cut starts at exactly 5.000
seconds, the claim is that timer, read off
the extracted frame — not ffmpeg's word for
it.

Check: `ffmpeg -version` prints a version
banner, and `ffmpeg -hide_banner -encoders |
grep libmp3lame` finds the MP3 encoder. If
both behave, your install and the lab agree,
and the rest of the guide will reproduce.
