# Metadata

Every media file carries a card of facts
about itself — title, artist, album, date —
that players display and libraries sort by.
Those facts are **metadata**: not streams
(chapter 4), but text fields in the
container's header. Chapter 2's
`-show_format` is where they live; this
chapter writes them, reads them back, and
takes them off again.

The lab's `tone.mp3` starts nearly blank —
the only tag on it is the one the muxer
stamped itself when the file was written:

```
$ ffprobe -v error -show_format tone.mp3
...
TAG:encoder=Lavf62.12.102
```

## Writing tags

`-metadata key=value`, once per field, and
`-c copy` because tagging must never
re-encode the audio — the goods stay
identical; only the card changes:

```
$ ffmpeg -hide_banner -y -i tone.mp3 -metadata title='Specimen Tone' -metadata artist='The Lab' -metadata album='Fixtures' -c copy tone-tagged.mp3

$ ffprobe -v error -show_format tone-tagged.mp3
...
TAG:album=Fixtures
TAG:title=Specimen Tone
TAG:artist=The Lab
TAG:encoder=Lavf62.12.102
```

Read-back is the proof, as always: three
tags you wrote, present, spelled as given —
and the `encoder` line still there beside
them, because that's the *muxer's* stamp,
re-applied on every write, not part of your
metadata. (MP3 stores these as ID3 tags;
other containers call the same fields by
the same names in ffmpeg's vocabulary —
`title`, `artist`, `album`, `date`,
`track`, `genre`, `comment` — and ffmpeg
translates. A container that has no home
for a field will quietly drop it, which is
one more reason to read back after writing
instead of trusting the command.)

Two habits worth forming: quote the values
(the shell, not ffmpeg, eats unquoted
spaces), and tag with `-c copy` unless the
same command is already converting the file
for another reason — metadata rides free on
any conversion, as chapter 14's worked job
shows when it stamps the title while
encoding.

## Stripping tags

The reverse — a file that arrived with
someone else's tags, or tags that disclose
more than you want to pass on (a recorder's
serial numbers and locations live in this
neighbourhood, on photos and videos alike):

```
$ ffmpeg -hide_banner -y -i tone-tagged.mp3 -map_metadata -1 -c copy tone-clean.mp3

$ ffprobe -v error -show_format tone-clean.mp3
...
TAG:encoder=Lavf62.12.102
```

`-map_metadata -1` means "copy metadata
from *nowhere*" — the three written tags
are gone. What remains is, again, the
muxer's fresh encoder stamp: `-map_metadata`
governs the metadata you *carry over*, and
no setting stops the writing tool signing
its own work. Know the difference before
you promise anyone a file with "no metadata
at all" — that claim needs a read-back,
like every other claim in this guide.

Check: `ffprobe -show_format` on your
tagged file lists title, artist, and album
exactly as typed, and the same probe on the
cleaned file shows none of the three. If a
tag you wrote is missing on read-back, the
container had no home for it — the write
didn't fail loudly, which is precisely why
the read-back is the check.
