# Extracting Audio

The meeting was recorded as video, but what
you need is the sound — for a podcast feed,
a transcription service, or just a file a
tenth the size. Extraction is chapter 4
wearing work clothes: drop the video stream,
keep the audio, and decide whether the
audio itself may simply be *copied*.

## Copy when you can

The clip's audio is AAC, and `.m4a` is the
container that holds bare AAC. `-vn` says
"no video in the output"; `-c:a copy` says
the audio passes through untouched:

```
$ ffmpeg -hide_banner -y -i clip.mp4 -vn -c:a copy clip-audio.m4a

$ probe clip-audio.m4a
codec_name=aac
codec_type=audio
duration=12.000000
size=106973
```

12.000 seconds, 106,973 bytes out of the
clip's 473,168 — the sound, bit for bit the
same encoded audio that was in the video
(the stream mapping line in the log says
`copy`, and no encoder is named, because
none ran). No quality was lost because no
conversion happened. This is the right
default whenever the destination accepts
the codec the video already carries — and
probing the *video* first (chapter 2) is
how you know what that is.

## Convert when you must

An MP3 player, an editor, a transcription
tool that wants MP3: then the audio must
actually change codec, and the job becomes
chapter 5 with a `-vn` on it:

```
$ ffmpeg -hide_banner -y -i clip.mp4 -vn -b:a 160k clip-audio.mp3

$ probe clip-audio.mp3
codec_name=mp3
duration=12.004717
size=241519
```

Two honest details in that probe. The file
is *bigger* than the copied AAC (241,519
against 106,973) — you ordered 160 kb/s,
and the source audio was only ~71 kb/s to
begin with, so the "conversion" mostly
inflated it; bits spent re-encoding cannot
buy back detail that was never recorded
(chapter 13 returns to this). And the
duration reads 12.004717 — MP3 frames pad
the end by a few milliseconds, as the
concat seam did in chapter 8. Both are the
kind of thing you only learn by probing
the output, which is why the guide keeps
insisting on it.

The shape generalizes: `-vn` plus any
audio setting from chapter 5 gives you the
soundtrack as WAV (for editing), FLAC (for
archiving the extraction losslessly), or
Opus — and `-map 0:a:1` (chapter 4) picks
the *second* audio stream instead, when
the video carries more than one language.

Check: your `clip-audio.m4a` probes at
exactly 12.000 seconds with codec `aac`,
and its size is within a few hundred bytes
of 106,973. If a "copy" of yours ever
probes as a *different* codec than the
source's audio, an encoder ran that you
didn't order — read the log's stream
mapping line to find where.
