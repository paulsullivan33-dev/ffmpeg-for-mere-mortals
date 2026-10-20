# ffmpeg for Mere Mortals

Almost every audio or video conversion you
have ever done in a friendly graphical program
was, underneath, done by **ffmpeg**: a single
command-line tool that reads nearly any media
file ever made and writes nearly any other.
Podcast tools, video editors, streaming
sites, and phone apps lean on it. Learning to
drive it directly means the conversions stop
being favours you ask of other programs and
become small, checkable commands you own.

This guide teaches ffmpeg the way it is
actually used: **probe before you convert**,
convert audio, trim clips, fix loudness, join
pieces, pull the sound out of a video, shrink
a frame, take thumbnails, stamp metadata, and
choose quality with your eyes open. Every job
is proven the same way — a probe of the file
before, the command, and a probe of the file
after, so "it worked" is something you read,
not something you hope.

The lab is a handful of tiny media files in
`examples/`, and they are unusual lab files:
they were *made by ffmpeg itself*, from its
built-in test sources — a sine tone for a
song, a test pattern for footage, a too-quiet
tone for a voice memo. `examples/make-fixtures.sh`
rebuilds them exactly, on any machine, in
seconds, so nothing in this guide depends on
a download and every number below can be
reproduced. Real media behaves the same way;
it is just bigger and less regular, and the
chapters say where that matters.

A note on how this guide was verified. Every
command quoted was run against the lab on
ffmpeg **8.1.2** and captured, and every
result the chapters claim — durations, sizes,
bit rates, loudness readings, quality scores
— is the capture's own number, not a
manufacturer's figure or an estimate: the
cuts were checked against the test pattern's
burned-in timer, frame by frame; the quality
chapter's trade-offs are this machine's
measured bytes and SSIM scores. Two honest
surprises the lab produced — a VBR encode
that came out far smaller than its setting
suggests, and a "better" GIF that came out
bigger than the naive one — are kept in the
text as what they are: measurements that beat
folklore. `criteria.md` keeps the full
ledger.

## What this guide covers

- [**What ffmpeg is**](what-ffmpeg-is.md) —
  the converter underneath everything, its
  two companions, and why your build is not
  quite my build
- [**Probing first**](probing-first.md) —
  ffprobe as a habit: never convert blind;
  reading codecs, durations, and bit rates
- [**The command grammar**](the-command-grammar.md) —
  where options go and why position is
  meaning: inputs, outputs, and the
  in-between
- [**Streams and codecs**](streams-and-codecs.md) —
  container is not codec; the streams inside
  a file; `-map`, and `-c copy`, the fastest
  conversion there is
- [**Converting audio**](converting-audio.md) —
  WAV to MP3, FLAC to MP3, bit rates stated
  honestly, and when smaller settings are
  free
- [**Trimming and cutting**](trimming-and-cutting.md) —
  `-ss`, `-to`, `-t`; the fast seek and the
  accurate seek, measured against the timer
- [**Volume and loudness**](volume-and-loudness.md) —
  measure first: `volumedetect`, the plain
  `volume` filter, and `loudnorm` done in
  two passes
- [**Joining clips**](joining-clips.md) —
  the concat demuxer and its one rule: the
  pieces must match
- [**Extracting audio**](extracting-audio.md) —
  the sound out of a video, copied when it
  can be, converted when it must be
- [**Scaling and frame rate**](scaling-and-frame-rate.md) —
  smaller frames, fewer frames, and the
  upscale that added bytes but not detail
- [**Frames and GIFs**](frames-and-gifs.md) —
  thumbnails, a strip of stills, and the
  two-pass palette GIF
- [**Metadata**](metadata.md) — titles and
  artists: writing tags, reading them back,
  stripping them clean
- [**Quality and CRF**](quality-and-crf.md) —
  quality as a dial with a measured price:
  two CRF values, two presets, real bytes,
  real scores
- [**Batch jobs and a worked job**](batch-and-worked-jobs.md) —
  a shell loop over a folder, and the quiet
  memo taken end to end; what ffmpeg will
  not do
- [**Glossary**](glossary.md) — the terms,
  collected in one place

## What it doesn't cover

Editing in the creative sense — arranging,
mixing, colour-grading, repairing bad
recordings. ffmpeg cuts and converts; it is
not a non-linear editor, and chapter 14 says
plainly where its road ends. Streaming
(`rtmp`, ingest servers), capturing from
devices (cameras, microphones, screens) as a
subject, the filter graph beyond the filters
the jobs here need, hardware acceleration,
and building ffmpeg from source are all
outside these pages. Where a neighbouring
tool owns the subject — the Bash guide for
the loops, the jq guide for ffprobe's JSON —
the chapter points there and moves on.

## How to use this guide

Read chapters 1–3 in order; they install the
two habits everything else stands on. After
that, chapters stand alone — go to the job
you have. Work from inside `examples/`, with
the lab files around you, and run the probes
yourself before and after each command: that
reflex, more than any single flag, is the
skill this guide is teaching.
