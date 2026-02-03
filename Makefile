# Module objects
snd-hda-codec-cs8409-objs := patch_cs8409.o patch_cs8409-tables.o
obj-m += snd-hda-codec-cs8409.o

# Build flags - use ccflags-y for proper kernel module builds
# debug build flags (uncomment for debugging):
#ccflags-y := -DCONFIG_SND_DEBUG=1 -DMYSOUNDDEBUGFULL -DAPPLE_PINSENSE_FIXUP -DAPPLE_CODECS -DCONFIG_SND_HDA_RECONFIG=1 -Wno-unused-variable -Wno-unused-function
# normal build flags:
ccflags-y := -DAPPLE_PINSENSE_FIXUP -DAPPLE_CODECS -DCONFIG_SND_HDA_RECONFIG=1 -Wno-unused-variable -Wno-unused-function

ifdef KVER
KDIR := /lib/modules/$(KVER)
else
KDIR := /lib/modules/$(shell uname -r)
endif

all:
	$(MAKE) -C $(KDIR)/build M=$(shell pwd) modules
clean:
	$(MAKE) -C $(KDIR)/build M=$(shell pwd) clean

install:
	mkdir -p $(KDIR)/updates/
	cp snd-hda-codec-cs8409.ko $(KDIR)/updates/
	depmod -a
