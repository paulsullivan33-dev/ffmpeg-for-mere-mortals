# Probing First

Every media job starts with the same
question: *what is actually in this file?*
The file name will lie to you — a `.mp4` can
hold a dozen different video codecs, and an
`.mp3` that won't play is sometimes not an
MP3 at all. ffmpeg will usually read
anything regardless, but choosing the right
conversion starts with knowing what you
have. The tool for that is **ffprobe**, and
the habit this chapter installs is the one
the whole guide runs on:

> **Never convert blind. Probe first, probe
> after, and let the probe — not the command
> you typed — say whether the job worked.**

At its plainest, ffprobe prints the same
banner ffmpeg prints about its input:

```
$ ffprobe clip.mp4
  Duration: 00:00:12.00, start: 0.000000, bitrate: 315 kb/s
  Stream #0:0[0x1](und): Video: h264 (High) (avc1 / 0x31637661), yuv420p(progressive), 320x180 [SAR 1:1 DAR 16:9], 238 kb/s, 24 fps, 24 tbr, 12288 tbn (default)
  Stream #0:1[0x2](und): Audio: aac (LC) (mp4a / 0x6134706D), 44100 Hz, stereo, fltp, 69 kb/s
```

That is useful for a glance, but scripts and
checks want fields, not prose. The form this
guide uses everywhere asks for named fields
and prints them as plain `key=value` lines:

```
probe() { ffprobe -v error -show_entries format=duration,size,bit_rate -show_entries stream=codec_type,codec_name,width,height,avg_frame_rate -of default=noprint_wrappers=1 "$1"; }
```

(The transcripts and worked examples define
this little shell function once and then
call `probe somefile` — type it into your
own shell and it is the same tool. The Bash
guide covers functions if the shape is new.)

```
$ probe clip.mp4
codec_name=h264
codec_type=video
width=320
height=180
avg_frame_rate=24/1
codec_name=aac
codec_type=audio
avg_frame_rate=0/0
duration=12.000000
size=473168
bit_rate=315445
```

Read it top to bottom: one video stream
(H.264, 320×180, 24 frames per second), one
audio stream (AAC), the whole file 12.000
seconds, 473,168 bytes, 315,445 bits per
second overall. Every chapter from here
proves its job with exactly this report, run
on the output: the duration *is* the trim,
the dimensions *are* the resize, the bit
rate *is* the conversion.

Three more moves worth having from the
start:

**Ask for one section whole.** `-show_format`
prints everything ffprobe knows about the
file as a container — including tags
(chapter 12):

```
$ ffprobe -v error -show_format song.flac
[FORMAT]
filename=song.flac
nb_streams=1
format_name=flac
duration=6.000000
size=297302
bit_rate=396402
...
[/FORMAT]
```

**Narrow to one stream.** `-select_streams
v:0` picks the first video stream, and
`-of csv` flattens the answer for scripts:

```
$ ffprobe -v error -select_streams v:0 -show_entries stream=width,height,avg_frame_rate,r_frame_rate -of csv clip.mp4
stream,320,180,24/1,24/1
```

**Get JSON when a program is asking.**
`-of json` restructures the same facts for
other tools — pipe it to `jq` (the sibling
guide's subject) and the probe becomes
queryable:

```
$ ffprobe -v error -show_entries format=duration -of json tone.wav
{
    "format": {
        "duration": "6.000000"
    }
}
```

One caution about the numbers themselves:
duration, size, and bit rate are the
*container's* report. They are honest — the
file really is that long and that big — but
they are claims the file makes, and
occasionally a damaged or oddly-made file
misreports (a WAV with a broken header is
the classic). When a probe looks wrong,
chapter 4's stream-level view is the second
opinion. For the well-made files in the lab
and most files in the wild, the probe is
simply the truth, early.

Check: `probe song.flac` reports codec
`flac`, duration 6.000000, size 297302 — and
`probe clip.mp4` shows two streams, h264
then aac. If yours match, your inspector
works, and every later chapter's proof will
read the same way.
