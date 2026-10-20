# Converting Audio

The most common ffmpeg job in the world is
the plainest: this audio, as that kind of
file. A WAV from a recorder that needs to be
an MP3 for a player; a lossless FLAC that
needs to be small enough to send. The shape
never changes — input, an audio quality
setting, output — and the output's extension
chooses the format while the setting chooses
the price.

## WAV to MP3, at a stated bit rate

```
$ probe tone.wav
codec_name=pcm_s16le
codec_type=audio
duration=6.000000
size=529278
bit_rate=705704

$ ffmpeg -hide_banner -y -i tone.wav -b:a 192k tone.mp3
...
Stream mapping:
  Stream #0:0 -> #0:0 (pcm_s16le (native) -> mp3 (libmp3lame))

$ probe tone.mp3
codec_name=mp3
codec_type=audio
duration=6.000000
size=145493
bit_rate=193990
```

The stream mapping line (chapter 3) is the
job in miniature: PCM decoded, MP3 written
by `libmp3lame`. `-b:a 192k` is the audio
bit rate — the budget the encoder may spend
per second. Six seconds at ~194 kb/s is
145,493 bytes, against the WAV's 529,278:
the same tone, a quarter of the size. MP3 at
192 kb/s is generous for most material; 128k
is the traditional "fine for speech and
ordinary music" setting, and anything you
can't hear a difference in is bits you
didn't need to spend. The honest way to
choose is to convert one file at two rates
and listen — the command takes a second.

Note what the probe proves and what it
doesn't: duration unchanged (6.000000),
codec changed, size shrunk. Whether the
shrink *cost* anything audible is a
listening question, and no probe answers it.

## FLAC to MP3, at a stated quality

For variable bit rate (VBR), LAME takes a
quality dial instead of a budget: `-q:a`
from 0 (best, biggest) to 9. The lab's chord
shows why the distinction matters:

```
$ probe song.flac
codec_name=flac
duration=6.000000
size=297302
bit_rate=396402

$ ffmpeg -hide_banner -y -i song.flac -q:a 2 song.mp3

$ probe song.mp3
codec_name=mp3
duration=6.000000
size=29196
bit_rate=38928
```

`-q:a 2` is near the top of the dial — and
the result is **39 kb/s**, 29,196 bytes.
That is not an error, and it's the most
instructive number in this chapter: VBR
spends bits *where the sound needs them*,
and three perfectly steady sine waves need
almost none. Real music — transients,
noise, detail — would land far higher at
the same setting. Two lessons travel from
here:

- A bit rate is a **result** you read off
  the probe, not a property you set — with
  VBR you set a quality and accept the size
  it costs; with `-b:a` you set the size and
  accept the quality it buys. Choose which
  side of that trade you want to hold fixed.
- Never judge a conversion by the output's
  bit rate alone. Judge the source, the
  setting, and your ears.

FLAC itself, note, lost *nothing* in the
original: lossless codecs are chapter 4's
goods in a tight box, and the only loss in
this job is the one you ordered by choosing
MP3.

## Changing the shape: sample rate and channels

Sometimes the target isn't a format but a
specification — a phone system that wants
22,050 Hz mono, say. `-ar` sets the sample
rate, `-ac` the channel count:

```
$ ffmpeg -hide_banner -y -i tone.wav -ar 22050 tone-small.wav
$ ls -l tone.wav tone-small.wav
-rw-rw---- 1 root nogroup 529278 tone.wav
-rw-rw---- 1 root nogroup 264678 tone-small.wav
```

Exactly half the bytes: an uncompressed
file's size is sample rate × channels ×
time, with no encoder judgment in between,
so this arithmetic is exact — unlike the
MP3 numbers above, which were the encoder's
decisions. Downsampling throws away the top
of the frequency range permanently; do it
because a destination requires it, not as a
tidying habit.

The same pattern covers the rest of the
everyday audio shelf: `.flac` → `.wav`
(unpacking the lossless box), anything →
`.ogg` with `-c:a libopus` for the Opus
codec, `-b:a 64k` for a speech file that
will travel by email. One input, one
setting, one output — and the probe before
and after, every time.

Check: your `tone.mp3` probes at duration
6.000000 and bit rate within a whisker of
194k, and `song.mp3` is dramatically smaller
than 145,493 bytes despite the "higher
quality" setting. That second result is the
chapter in one number — if it surprises you,
the chapter did its job.
