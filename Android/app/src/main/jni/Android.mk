LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
include $(LOCAL_PATH)/libopus/celt_sources.mk
include $(LOCAL_PATH)/libopus/silk_sources.mk
include $(LOCAL_PATH)/libopus/opus_sources.mk
MY_MODULE_DIR       := libopus
LOCAL_MODULE        := $(MY_MODULE_DIR)
SILK_SOURCES += $(SILK_SOURCES_FIXED)

CELT_SOURCES += $(CELT_SOURCES_ARM)
SILK_SOURCES += $(SILK_SOURCES_ARM)
LOCAL_SRC_FILES     := OpusJni.cpp\
$(CELT_SOURCES) $(SILK_SOURCES) $(OPUS_SOURCES)
LOCAL_LDLIBS        := -lm
LOCAL_C_INCLUDES    := \
$(LOCAL_PATH)/libopus/include \
$(LOCAL_PATH)/libopus/silk \
$(LOCAL_PATH)/libopus/silk/fixed \
$(LOCAL_PATH)/libopus/celt

LOCAL_CFLAGS        := -DNULL=0 -DSOCKLEN_T=socklen_t -DLOCALE_NOT_USED -D_LARGEFILE_SOURCE=1 -D_FILE_OFFSET_BITS=64
LOCAL_CFLAGS        += -Drestrict='' -D__EMX__ -DOPUS_BUILD -DFIXED_POINT=1 -DDISABLE_FLOAT_API -DUSE_ALLOCA -DHAVE_LRINT -DHAVE_LRINTF -O3 -fno-math-errno
LOCAL_CPPFLAGS      := -DBSD=1
LOCAL_CPPFLAGS      += -ffast-math -O3 -funroll-loops
include $(BUILD_SHARED_LIBRARY)