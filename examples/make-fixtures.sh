#!/bin/sh
# Build the ffmpeg guide's fixtures from nothing but ffmpeg itself.
# Every input is a generated test source (lavfi), so the lab is
# deterministic: same commands, same fixtures, on any machine.
set -e
cd "$(dirname "$0")/fixtures"

# A plain 440 Hz tone, 6 seconds, mono WAV (the "simple audio file").
ffmpeg -hide_banner -v error -y -f lavfi -i sine=frequency=440:duration=6 \
  -ar 44100 -ac 1 tone.wav

# A too-quiet "voice memo": a low tone at 6% volume, 8 seconds.
ffmpeg -hide_banner -v error -y -f lavfi -i sine=frequency=196:duration=8 \
  -af volume=0.06 -ar 44100 -ac 1 voice.wav

# A "song": an A-major chord (440 + 554.37 + 659.25 Hz), 6 seconds, FLAC.
ffmpeg -hide_banner -v error -y \
  -f lavfi -i sine=frequency=440:duration=6 \
  -f lavfi -i sine=frequency=554.37:duration=6 \
  -f lavfi -i sine=frequency=659.25:duration=6 \
  -filter_complex amix=inputs=3:duration=first -ar 44100 -ac 2 song.flac

# The video clip: test pattern + tone, 12 s, 320x180, 24 fps,
# keyframe every 48 frames (2 s) so the seeking chapter can show
# what a keyframe snap looks like in the durations.
ffmpeg -hide_banner -v error -y \
  -f lavfi -i testsrc2=duration=12:size=320x180:rate=24 \
  -f lavfi -i sine=frequency=660:duration=12 \
  -c:v libx264 -g 48 -pix_fmt yuv420p -c:a aac -shortest clip.mp4

# Two 3-second clips with identical settings, for the concat chapter.
ffmpeg -hide_banner -v error -y \
  -f lavfi -i testsrc2=duration=3:size=320x180:rate=24 \
  -f lavfi -i sine=frequency=660:duration=3 \
  -c:v libx264 -pix_fmt yuv420p -c:a aac -shortest part1.mp4
ffmpeg -hide_banner -v error -y \
  -f lavfi -i smptebars=duration=3:size=320x180:rate=24 \
  -f lavfi -i sine=frequency=880:duration=3 \
  -c:v libx264 -pix_fmt yuv420p -c:a aac -shortest part2.mp4

# A bigger, busier clip, 6 s, 640x360, 30 fps, encoded gently (CRF 12)
# to serve as the "source" the quality chapter re-encodes.
ffmpeg -hide_banner -v error -y \
  -f lavfi -i testsrc2=duration=6:size=640x360:rate=30 \
  -c:v libx264 -crf 12 -pix_fmt yuv420p scene.mp4
