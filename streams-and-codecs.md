# Streams and Codecs

The most useful idea in this guide fits in
one sentence:

> **The container is the box; the codec is
> what is inside it — and they are chosen
> independently.**

`clip.mp4` is an MP4 *container* holding two
**streams**: an H.264 *video stream* and an
AAC *audio stream* (chapter 2's probe said
exactly that). The same H.264 and AAC
streams could live in a Matroska box (`.mkv`)
unchanged; the same MP4 box could hold
different codecs entirely. File extensions
name the box. Every confusion of the "the
MP4 won't play" kind is, underneath, a codec
the player didn't know, in a box it did.

Streams come in kinds — video, audio,
subtitle, plus data and attachment streams
you'll meet rarely — and a file can hold
several of each: films ship with multiple
audio languages and subtitle tracks as
separate streams in one container.

## The remux: changing the box, not the goods

If the codecs are fine and only the box is
wrong, you don't convert anything. You
**remux**: copy the streams into a new
container with `-c copy` — no decoding, no
re-encoding, no quality change, and a speed
that feels like a file copy:

```
$ ffmpeg -hide_banner -y -i clip.mp4 -c copy clip.mkv
...
$ ls -l clip.mp4 clip.mkv
-rw-rw---- 1 root nogroup 473168 clip.mp4
-rw-rw---- 1 root nogroup 469280 clip.mkv
```

Same streams, same 12 seconds (a probe
agrees), 3,888 bytes smaller — that is the
two containers' bookkeeping differing,
nothing else. This is the fastest
"conversion" in the guide and the one to
reach for first: **if a job only changes
the box, `-c copy` is the whole job.**
Chapter 9's audio extraction is the same
idea wearing a different hat.

Per-stream versions exist — `-c:v copy`
copies video while something else happens to
audio, `-c:a copy` the reverse — and
chapter 6 uses bare `-c copy` for cutting,
where its speed and its limits both matter.

## Choosing streams: -map

By default ffmpeg picks, for each kind, the
"best" stream it can see (highest-resolution
video, the audio with most channels) and
leaves the rest behind. `-map` replaces that
judgment with yours. It names streams as
`input:kind` or `input:number`:

Watch it matter. First, put a subtitle
stream into the clip — a second input, both
inputs mapped whole, subtitles re-encoded
to MP4's subtitle codec `mov_text` because
boxes have rules about what may live in
them:

```
$ cat subs.srt
1
00:00:01,000 --> 00:00:04,000
The test pattern is standing in for your footage.

2
00:00:06,000 --> 00:00:09,000
Any real clip would do; this one is free to make.

$ ffmpeg -hide_banner -y -i clip.mp4 -i subs.srt -map 0 -map 1 -c copy -c:s mov_text clip-subs.mp4
$ probe clip-subs.mp4
codec_name=h264
codec_type=video
...
codec_name=aac
codec_type=audio
...
codec_name=mov_text
codec_type=subtitle
```

Three streams now. And taking streams *out*
is the same mechanism — map only what you
want to keep:

```
$ ffmpeg -hide_banner -y -i clip-subs.mp4 -map 0:v -map 0:a -c copy clip-nosubs.mp4
$ probe clip-nosubs.mp4
```

The probe of `clip-nosubs.mp4` shows exactly
two streams — h264 and aac; the subtitle is
gone, and nothing was re-encoded on the way.
`-map 0:v` means "input 0's video", `-map
0:a` its audio; the general form is
`-map inputindex:streamindex` (`-map 1:0`
is the second input's first stream).

Two honest warnings about `-c copy`, both
of which recur:

- **Copy cannot cross every border.** The
  destination container must accept the
  codec — that's why the subtitles above
  needed `-c:s mov_text` rather than a copy
  (an `.srt` stream can't live in MP4 as-is).
  When ffmpeg refuses a copy, it says so;
  the fix is to convert just that stream.
- **Copy cannot change the goods.** No
  filters, no volume, no resize — anything
  that alters a stream means decoding and
  re-encoding it, and chapters 7, 10, and 13
  are about doing that deliberately.

Check: `probe clip.mkv` shows the same h264
+ aac pair as `probe clip.mp4` — same goods,
new box — and `probe clip-nosubs.mp4` shows
two streams where `clip-subs.mp4` shows
three. If both read that way, you hold the
idea the rest of the guide is built on.
