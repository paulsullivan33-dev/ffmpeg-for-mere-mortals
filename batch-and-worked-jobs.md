# Batch Jobs and a Worked Job

One file is a command. Forty files are a
loop. ffmpeg doesn't batch on its own —
your shell does, and the pattern is small
enough to be this chapter's first half.
(The Bash guide owns loops in depth; here
is the shape in working form.)

## The loop

Every WAV and FLAC in the lab, converted
to 160 kb/s MP3 in a new folder, each output
named after its source:

```
$ mkdir -p mp3s
$ for f in *.wav *.flac; do ffmpeg -hide_banner -v error -y -i "$f" -b:a 160k "mp3s/$(basename "$f" | sed 's/\.[^.]*$//').mp3"; done
$ ls -l mp3s
-rw-rw---- 1 root nogroup 121253 song.mp3
-rw-rw---- 1 root nogroup 121253 tone.mp3
-rw-rw---- 1 root nogroup 161481 voice.mp3
```

Three details carry the pattern:

- **`"$f"`, quoted, always.** The day a
  filename contains a space, the unquoted
  version converts two wrong files instead
  of one right one.
- **`-v error` in batch.** Interactively,
  ffmpeg's narration is information; in a
  loop it is forty screens of it. Errors
  still print — silence plus an eyeball on
  the directory listing is the batch
  equivalent of the probe habit.
  (Verify one output by hand afterward.
  Batch converts trust; trust but probe.)
- **The sizes audit the loop.** At a fixed
  bit rate, an MP3's size is nearly pure
  duration arithmetic — and the listing
  proves the loop behaved: both 6-second
  files at exactly 121,253 bytes, the
  8-second file at 161,481. A wrong duration
  in that list would be the loop confessing.

Add `-n` instead of `-y` (chapter 3) and
re-running the loop becomes safe and
idempotent: finished files are skipped,
not redone.

## The worked job: the quiet memo, end to end

Everything the guide taught, in the order
a real job uses it. The memo from chapter
7 — 8 seconds, integrated loudness −46.55
LUFS — needs to become a presentable MP3:
normalized to the podcast target, tagged,
converted. The loudnorm step uses the
measurements chapter 7 already took (on a
fresh file you would run the analysis pass
first; the numbers below are the memo's
own):

```
$ probe voice.wav
codec_name=pcm_s16le
duration=8.000000

$ ffmpeg -hide_banner -y -i voice.wav -af loudnorm=I=-16:TP=-1.5:LRA=11:measured_I=-46.55:measured_TP=-42.49:measured_LRA=0.00:measured_thresh=-56.55:offset=-0.04:linear=true -ar 48000 -b:a 160k -metadata title='Voice memo, normalised' memo-final.mp3

$ probe memo-final.mp3
codec_name=mp3
duration=8.000000

$ ffprobe -v error -show_entries format_tags=title memo-final.mp3
    title           : Voice memo, normalised
```

And the closing verification — measure the
*deliverable*, not the intermediate:

```
$ ffmpeg -hide_banner -i memo-final.mp3 -af loudnorm=print_format=json -f null -
	"input_i" : "-16.45",
```

Chapter 7's WAV measured −16.02; the
finished MP3 measures **−16.45**. The
lossy encode itself shifted the loudness
by four-tenths of a dB — inaudible, and
exactly the sort of thing you only know if
the last step of the job is a measurement.
Probe, process, probe: the guide's whole
method is those three words, and this job
is what they look like assembled.

## What ffmpeg will not do

A plain list, because knowing a tool's edge
is most of knowing the tool:

- **It will not edit like an editor.**
  No timeline, no transitions, no mixing
  board, no undo. It cuts where you say,
  once, in numbers. Arrangement belongs to
  a non-linear editor (several of which are
  ffmpeg underneath — with a user interface
  on top, which is the point of them).
- **It will not repair recordings.**
  Chapter 7's loudnorm levels what exists;
  nothing here un-clips a shout, un-echoes
  a room, or recovers the word the truck
  drove over. Level is fixable. Content
  isn't.
- **It will not create quality.** Chapters
  9, 10, and 13 each watched a job spend
  bytes trying: nothing converts up.
- **It will not choose for you.** Every
  default in this guide was a decision
  somebody made generically. The settings
  that matter — bit rate, CRF, loudness
  target, where to cut — are yours, and
  the guide's position is that a person
  with a probe and ninety seconds of tests
  chooses better than a preset chooses
  blindly.
- **It is not the whole shelf.** Capturing
  from devices, streaming to servers,
  authoring discs and broadcast packages
  are neighbouring trades with their own
  guides and their own tools, several of
  them built on this one.

Check: your `mp3s` listing shows the two
6-second MP3s the same size and the
8-second one a third larger, and your
`memo-final.mp3` re-measures within half
a dB of −16 LUFS with its title tag
reading back. When a folder of real memos
is the input, this chapter — loop, levels,
tag, verify — is the whole job, forty
times over.
