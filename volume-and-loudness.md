# Volume and Loudness

The lab's `voice.wav` stands in for every
voice memo and call recording that arrives
too quiet to use. How quiet is it, exactly?
Don't guess — measure. `volumedetect` is a
filter that plays the file to nowhere
(`-f null -`) and reports what it heard:

```
$ ffmpeg -hide_banner -i voice.wav -af volumedetect -f null - 2>&1 | grep -E 'mean_volume|max_volume'
[Parsed_volumedetect_0 @ 0x...] mean_volume: -45.5 dB
[Parsed_volumedetect_0 @ 0x...] max_volume: -42.5 dB
```

Two numbers, two meanings: **max_volume** is
the loudest instant in the file (−42.5 dB —
a recording whose peaks barely reach a
twentieth of full scale has enormous wasted
headroom), and **mean_volume** is its
average level (−45.5 dB). A healthy voice
recording peaks within a few dB of 0. This
one needs roughly forty decibels of help,
which is why the second half of this chapter
is not the `volume` filter.

## The plain fix: volume

`volume` multiplies the sound by a gain —
stated in decibels, or as a factor
(`volume=2` is +6 dB):

```
$ ffmpeg -hide_banner -y -i voice.wav -af volume=12dB voice-louder.wav
$ ffmpeg -hide_banner -i voice-louder.wav -af volumedetect -f null - 2>&1 | grep -E 'mean_volume|max_volume'
[Parsed_volumedetect_0 @ 0x...] mean_volume: -33.5 dB
[Parsed_volumedetect_0 @ 0x...] max_volume: -30.5 dB
```

Asked for 12 dB, got exactly 12 dB (mean
−45.5 → −33.5, peak −42.5 → −30.5): the
filter is honest arithmetic. It is also,
for this file, nowhere near enough — and
cranking it to +42 dB would raise a second
problem the averages hide: gain amplifies
everything, including the hiss between
words, by the same factor. `volume` is the
right tool for *a few dB of trim* on a
decent recording. A rescue is a different
job — the job loudness normalization was
built for.

## loudnorm: aim at a standard, not a guess

Broadcast and podcast loudness is measured
in **LUFS** — an integrated loudness over
the whole file, weighted the way ears
weight frequencies — against published
targets: −16 LUFS is the common podcast
figure, with true peak kept at or below
−1.5 dB so lossy encoding can't push a peak
into clipping. ffmpeg's `loudnorm` filter
normalizes to such a target, and used
properly it is a **two-pass** tool:

**Pass one — measure, change nothing.**
The filter analyses the file and prints
its findings as JSON:

```
$ ffmpeg -hide_banner -i voice.wav -af loudnorm=print_format=json -f null -
...
{
	"input_i" : "-46.55",
	"input_tp" : "-42.49",
	"input_lra" : "0.00",
	"input_thresh" : "-56.55",
	"output_i" : "-23.96",
	...
	"normalization_type" : "dynamic",
	"target_offset" : "-0.04"
}
```

`input_i` is the file's integrated loudness
(−46.55 LUFS — the LUFS cousin of the mean
you already met), `input_tp` its true peak,
`input_lra` its loudness range (0.00 here:
a steady tone has no dynamics; real speech
has several dB of range, and that range is
what normalization treats gently or
firmly). The `output_*` lines describe the
analysis pass's own default aim; the values
you carry into pass two are the `input_*`
ones.

**Pass two — apply, with the measurements
fed back** so the filter can work *linearly*
— one honest gain, not moment-by-moment
riding:

```
$ ffmpeg -hide_banner -y -i voice.wav -af loudnorm=I=-16:TP=-1.5:LRA=11:measured_I=-46.55:measured_TP=-42.49:measured_LRA=0.00:measured_thresh=-56.55:offset=-0.04:linear=true -ar 48000 voice-norm.wav
```

(loudnorm works internally at 48 kHz, hence
the `-ar 48000` on the output.) Verify with
the same instrument, on the finished file:

```
$ ffmpeg -hide_banner -i voice-norm.wav -af loudnorm=print_format=json -f null -
	"input_i" : "-16.02",
	"input_tp" : "-11.98"
```

**−16.02 LUFS against a −16 target.** And
its true peak is −11.98, *below* the −1.5
ceiling — read that correctly: the peak
figure is a **ceiling, not a goal**. The
gain needed to lift this steady tone to
−16 integrated (+30.5 dB) put its peaks at
−12, comfortably under the ceiling, so
nothing more was done to them. A peakier
recording — speech with transients — is
where the ceiling starts to bind and
loudnorm switches from linear gain to
dynamic treatment; the two-pass numbers are
what let it choose.

One cross-check that confuses everyone
once: `volumedetect` on `voice-norm.wav`
reports mean −15.0 / max −12.0 dB. Those
don't match the LUFS figures because they
aren't LUFS — volumedetect is a plain
level meter, loudnorm an ear-weighted
loudness meter. Two instruments, two
dialects, both honest; chapter 14's worked
job shows the small extra shift a lossy
encode adds (the finished MP3 measures
−16.45).

What loudnorm will not do: repair. It
cannot un-clip a recording made too hot,
un-muffle a bad microphone, or remove the
room. It levels what is there — which for
the merely-*quiet*, like this memo, is
exactly the rescue needed.

Check: your pass-one JSON shows
`input_i` ≈ −46.6 and `input_tp` ≈ −42.5
for the untouched memo, and your
`voice-norm.wav` re-measures at
`input_i` within a few hundredths of −16.
When both instruments agree the file moved
thirty decibels and landed on target, the
rescue is a measurement, not a hope.
