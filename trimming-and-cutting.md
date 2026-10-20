# Trimming and Cutting

Cut the first five seconds off a recording.
Keep the middle minute of a clip. These are
the same job — *this piece, from here to
here* — and ffmpeg gives you two ways to
walk to the start point, which differ in
speed, in precision, and in price. The lab
clip makes the difference measurable: it is
12 seconds long, its keyframes (the frames
stored whole, that a cut can cleanly start
on — every 2 seconds in this file, a setting
of its fixture recipe) are known, and its test
pattern carries a burned-in timer, so a cut
can be checked against the truth rather
than against ffmpeg's say-so.

The three flags: `-ss` is the start,
`-to` the end position, `-t` a duration
instead of an end. All read `HH:MM:SS` or
plain seconds. What changes everything is
*where they stand* (chapter 3's grammar:
options belong to the file that follows
them).

## The accurate cut: -ss after -i

```
$ ffmpeg -hide_banner -y -i clip.mp4 -ss 5 -to 9 cut-accurate.mp4
$ probe cut-accurate.mp4
duration=4.000000
```

Standing after the input, `-ss` works on
decoded frames: ffmpeg decodes from the
start and discards until exactly 5.000,
then converts to exactly 9.000. The result
is 4.000 seconds, and the extracted first
frame's timer reads **00:00:05.000** (frame
120 of the source) while the frame at 3.9
seconds in reads 00:00:08.917 — the cut is
the seconds ordered, to the frame. The
price is the decode: for a cut near the end
of a long file, ffmpeg reads everything
before it. On a 12-second clip that price
is invisible; on a two-hour recording it is
the wait.

`-t` in the same position buys a duration
instead of an end point — `-ss 5 -t 4`
produced another 4.000-second file, byte-
identical in size to the `-to` version
here.

## The fast cut: -ss before -i

```
$ ffmpeg -hide_banner -y -ss 5 -i clip.mp4 cut-reencode.mp4
$ probe cut-reencode.mp4
duration=7.003991
```

Before the input, `-ss` is a *seek*: the
reader jumps straight to near 5 seconds —
landing on the keyframe at 4 — and decodes
the fraction from there, so the start is
still exact (the first frame's timer again
reads 00:00:05.000), but almost nothing
before the cut is read. For most jobs this
is the right default: **accurate *and*
fast**, because the re-encode repairs the
rough edge the seek lands on. The 7.004
seconds — note the trailing 4 milliseconds,
audio priming in the AAC stream — run to
the end of the file; nothing told it to
stop earlier. Add `-to 9` as an *input*
option too if the end matters, knowing it
counts from the file's start, as positions
on the input side do.

## The instant cut: seek, and copy

```
$ ffmpeg -hide_banner -y -ss 5 -i clip.mp4 -c copy cut-copy.mp4
$ probe cut-copy.mp4
duration=7.000000
size=316611
```

Add `-c copy` (chapter 4) and nothing is
decoded at all — packets are lifted from
the seek point onward, which makes the job
nearly instant and the file bigger than the
re-encoded cut (316,611 bytes against
261,827: the copy keeps *everything* from
there, including the pre-roll GOP
structure). On this fixture the visible
start still landed on frame 120 exactly —
verified against the timer — and the last
frame reads 00:00:11.917, the file's true
end. Now the honest limits, because copy
cuts are where folklore grows:

- A copy cut **cannot end mid-GOP**: the
  end, when you give one, lands where whole
  packets allow, not on your exact frame.
  If the last second must be exact,
  re-encode.
- The start's cleanliness depends on the
  source's keyframe spacing. This lab file
  keys every 2 seconds; a file keyed every
  10 can start a copy cut seconds early in
  presentation or carry visible pre-roll in
  some players. Probe, and when it matters,
  extract a frame (chapter 11) and look.
- For audio-only files, copy cuts are
  routinely exact — audio frames are small
  and frequent. Most "trim the podcast"
  jobs are this command, and they are
  right to be.

The working rule: **seek before `-i` to
arrive fast; re-encode when the edges must
be exact; copy when they're allowed to be
approximate and speed is the point** — and
probe every result, because the duration
line is the cut, stated in numbers.

Check: your four probes read 4.000,
7.004 (or a hair off), 4.000, and 7.000
seconds for the four cuts above, in the
order given. If the copy cut's duration is
the odd one out on *your* file someday, you
now know which question to ask it — where
are its keyframes?
