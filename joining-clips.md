# Joining Clips

Two clips, one file, end to end. ffmpeg has
several ways to join media, and the one to
learn first — the **concat demuxer** — is
also the fastest, because it can work at
chapter 4's copy level: no re-encoding, the
pieces are simply laid end to end inside a
new container. Its price is one strict
rule:

> **Every piece must match** — same codecs,
> same dimensions, same frame rate, same
> audio shape. The demuxer does not check
> your homework; mismatched pieces produce
> a broken or lurching file, not an error.

The lab's `part1.mp4` and `part2.mp4` were
built to the same recipe for exactly this
(chapter 2's probe reads them as twins:
h264 + aac, 320×180, 24 fps, 3.000 seconds
each). The join itself is a list file plus
one command:

```
$ cat parts.txt
file 'part1.mp4'
file 'part2.mp4'

$ ffmpeg -hide_banner -y -f concat -safe 0 -i parts.txt -c copy joined.mp4

$ probe joined.mp4
codec_name=h264
codec_type=video
width=320
height=180
avg_frame_rate=24/1
codec_name=aac
codec_type=audio
duration=6.023220
size=146018
```

Two 3-second clips, one 6.02-second file:
the extra 23 milliseconds are the audio
stream's padding at the seam (AAC works in
frames of samples, and the join lands on a
frame boundary). Worth knowing it exists —
and worth more knowing it's the *audio*,
not your list, doing it. `-f concat` names
the demuxer, `-safe 0` permits paths beyond
bare filenames in the list (keep the list
itself trustworthy — it is, in effect, a
little script, and ffmpeg will open
whatever it names).

The probes before the join are not
ceremony. They are the rule being checked:
on real footage — clips from two phones,
say — compare codec, dimensions, and rates
across every piece first. Where they
differ, you have three honest options:
re-encode the odd ones to match (chapters
10 and 13 are the tools), use the **concat
filter** instead — which decodes
everything, joins at the filter level, and
re-encodes, at the usual price and with
more syntax than this chapter's beginner
shape — or fix the mismatch at the source
next time you record. The demuxer's way is
the best way *when its rule holds*, and the
probe is how you know it holds.

The same list joins audio files identically
(`-c copy` on matching MP3s is the classic
"album sides into one file"), and a list
can repeat a file — the demuxer reads it
as written.

Check: `probe joined.mp4` shows duration
6.02 seconds (not 6.000 — the seam's audio
padding, accounted for above), and the
file at 146,018 bytes sits close to the
parts' sum (115,187 + 32,140) minus their
container bookkeeping. Join a third part
of your own making and the duration should
grow by its length, plus another seam's
few milliseconds.
