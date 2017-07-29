CELT_SOURCES = libopus/celt/bands.c \
libopus/celt/celt.c \
libopus/celt/celt_encoder.c \
libopus/celt/celt_decoder.c \
libopus/celt/cwrs.c \
libopus/celt/entcode.c \
libopus/celt/entdec.c \
libopus/celt/entenc.c \
libopus/celt/kiss_fft.c \
libopus/celt/laplace.c \
libopus/celt/mathops.c \
libopus/celt/mdct.c \
libopus/celt/modes.c \
libopus/celt/pitch.c \
libopus/celt/celt_lpc.c \
libopus/celt/quant_bands.c \
libopus/celt/rate.c \
libopus/celt/vq.c

CELT_SOURCES_SSE = \
libopus/celt/x86/x86cpu.c \
libopus/celt/x86/x86_celt_map.c \
libopus/celt/x86/pitch_sse.c

CELT_SOURCES_SSE2 = \
libopus/celt/x86/pitch_sse2.c \
libopus/celt/x86/vq_sse2.c

CELT_SOURCES_SSE4_1 = \
libopus/celt/x86/celt_lpc_sse.c \
libopus/celt/x86/pitch_sse4_1.c

CELT_SOURCES_ARM = \
libopus/celt/arm/armcpu.c \
libopus/celt/arm/arm_celt_map.c

CELT_SOURCES_ARM_ASM = \
libopus/celt/arm/celt_pitch_xcorr_arm.s

CELT_AM_SOURCES_ARM_ASM = \
libopus/celt/arm/armopts.s.in

CELT_SOURCES_ARM_NEON_INTR = \
libopus/celt/arm/celt_neon_intr.c \
libopus/celt/arm/pitch_neon_intr.c

CELT_SOURCES_ARM_NE10 = \
libopus/celt/arm/celt_ne10_fft.c \
libopus/celt/arm/celt_ne10_mdct.c
