# The Command Grammar

An ffmpeg command looks like a junk drawer
of flags, but it has a strict grammar, and
once you see it, commands from the internet
stop being incantations and become
sentences you can read. The shape:

```
ffmpeg [global options] [input options] -i input [output options] output
```

Three facts carry the whole chapter:

**Options belong to the file that follows
them.** Anything written before `-i` shapes
how the input is *read*; anything after the
input and before the output name shapes how
the output is *written*. The same flag can
mean two different things in the two places
— chapter 6 lives on this: `-ss 5` before
`-i` discards five seconds while *seeking*;
after `-i` it discards five seconds while
*converting*, frame by frame. Position is
not punctuation. It is meaning.

**There can be several inputs and several
outputs.** Each `-i` adds an input; each
bare filename at the end of an option group
is an output. Chapter 4 uses two inputs
(the clip and its subtitles); chapter 11
uses two for a GIF (the clip and its
palette). Most everyday commands have one of
each, and this guide flags the ones that
don't.

**The output is the filename with no flag.**
Whatever ends the sentence is where the
media goes — and the *extension* of that
name is how ffmpeg chooses the container to
write, when you don't say otherwise
(`-f`). Name it `.mp3` and you get an MP3
file; the codec is chosen separately
(chapter 4), defaulting to the container's
usual partner if you don't name one.

The global options worth adopting today:

- `-hide_banner` — suppresses the build
  banner. Every command in this guide uses
  it; the banner is version information
  (chapter 1), not job information.
- `-y` — overwrite the output if it exists.
  Without it, ffmpeg *asks* — and in a
  script, a question at a terminal nobody is
  watching means a job that never finishes.
  With it, stale outputs are replaced
  silently, which is why this guide's
  commands say `-y` and mean it. Know which
  behaviour your command has before you
  walk away from it.
- `-n` — the opposite: never overwrite, and
  fail if the output exists. The batch
  chapter's friend.
- `-v error` — quiet the log down to errors
  only. The batch loop uses it; interactively
  you usually want the full report below.

## Reading the report

When a conversion runs, ffmpeg narrates.
Learn to read the narration once and every
job in this guide becomes self-checking
(chapter 5's first conversion):

```
Input #0, wav, from 'tone.wav':
  Duration: 00:00:06.00, bitrate: 705 kb/s
  Stream #0:0: Audio: pcm_s16le ([1][0][0][0] / 0x0001), 44100 Hz, mono, s16, 705 kb/s
Stream mapping:
  Stream #0:0 -> #0:0 (pcm_s16le (native) -> mp3 (libmp3lame))
Output #0, mp3, to 'tone.mp3':
  Stream #0:0: Audio: mp3, 44100 Hz, mono, s16p, 192 kb/s
size=     142KiB time=00:00:06.00 bitrate= 194.0kbits/s speed= 117x
```

- **Input** — what ffmpeg found, in its own
  reading. Compare it with your probe
  (chapter 2): they should agree.
- **Stream mapping** — the plan: which input
  streams become which output streams, and
  what each is decoded *from* and encoded
  *to*. `(native)` is ffmpeg's built-in
  decoder; `libmp3lame` is the encoder this
  build chose for MP3. When a conversion
  surprises you, this line is where the
  surprise was announced.
- **Output** — what will be written, with
  the settings your output options produced.
- **The final line** — the size written,
  the media time processed, and `speed=` how
  much faster than real time it ran. A job
  whose `time=` stops short of the input's
  duration did not finish the file, whatever
  its exit status — and on that subject:
  ffmpeg exits 0 on success and non-zero on
  failure, and its error messages name the
  problem in plain words ("Unknown encoder",
  "No such file or directory"). Trust the
  exit code in scripts; trust the probe over
  both when it matters.

Check: run chapter 5's first command with
and without `-hide_banner` and watch the
banner come and go — and re-run it without
`-y` to meet the overwrite question on a
file you can afford to be asked about. Both
behaviours are now yours on purpose.
