# Glossary

**Bit rate** — the budget of bits per
second a stream spends. For a whole file,
size ≈ bit rate × duration. Set directly
(`-b:a`, `-b:v`) or allowed to float under
a quality setting (CRF, `-q:a`) — and in
both cases read afterwards with a probe.

**Codec** — the scheme a stream's data is
encoded in: H.264, AAC, MP3, FLAC. Short
for coder/decoder. Independent of the
**container** that carries it.

**Concat demuxer** — ffmpeg's list-driven
joiner: a text file of inputs laid end to
end, usually with `-c copy`. Requires the
pieces to match in codec and shape.

**Container** — the file format that holds
streams and metadata: MP4, MKV, WAV, MP3.
Named by the extension; not the same thing
as the codecs inside.

**CRF** — Constant Rate Factor: libx264's
quality dial (0 lossless → 51 worst, 23
default). Lower number = higher quality =
bigger file, with bit rate left floating.

**Demuxer / muxer** — the reader that
splits a container into its streams, and
the writer that packs streams into one.
**Remuxing** is demux + mux with no
re-encoding: a new box, the same goods.

**Filter** — a processing step applied to
decoded media: `volume`, `loudnorm`,
`scale`, `fps`. Filters change the goods,
so anything filtered is re-encoded.

**Frame rate** — pictures per second in a
video stream; ffprobe reports it as
`avg_frame_rate` (a fraction, like `24/1`).

**Integrated loudness** — a whole file's
loudness as one number, ear-weighted, in
**LUFS**; what loudness targets (−16 for
podcasts) refer to, and what loudnorm's
`input_i` measures.

**Keyframe** — a video frame stored whole,
from which neighbouring frames are
reconstructed as differences. Cuts land
cleanly on keyframes; their spacing is a
property of the encode.

**loudnorm** — ffmpeg's loudness
normalization filter (EBU R128): measures
integrated loudness and true peak, then
gains the file to a stated target. Best
used in two passes — measure, then apply
with the measurements fed back.

**-map** — the option that chooses streams
explicitly (`-map 0:v` = first input's
video), replacing ffmpeg's default
best-of-each-kind selection.

**Preset** — libx264's speed/efficiency
trade (`fast`, `medium`, `slow`, …): at a
given CRF, slower searches harder and
usually writes a slightly smaller file.

**Probe** — to inspect a file with ffprobe
before or after a job. This guide's
working habit: the probe, not the command,
says whether the job worked.

**Sample rate** — audio samples per second
(44,100 and 48,000 are the common pair).
For uncompressed audio, file size is
sample rate × channels × bytes × time.

**SSIM** — Structural Similarity: a
computed score (1.000 = identical) between
two videos, used here to put a measured
number on an encode's fidelity to its
source.

**Stream** — one flow of media inside a
container: one video, one audio track, one
subtitle track. A file is its streams plus
its metadata.

**Stream copy** — `-c copy`: a stream
passes through a job untouched — no decode,
no re-encode, no loss, no changes. The
fastest conversion is the one you skip.

**Transcode** — decode and re-encode: the
full conversion. Necessary to change a
codec or apply a filter; lossy whenever
either side is lossy, every generation.

**True peak** — the loudest level a signal
reaches between samples, measured in dB.
Kept under a ceiling (−1.5 dB here) so
later lossy encoding can't clip it.

**VBR** — Variable Bit Rate: the encoder
spends bits where the material needs them
under a quality setting (`-q:a` for MP3),
so bit rate becomes a result to measure,
not a setting to dictate.
