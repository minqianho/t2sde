dnl --- T2-COPYRIGHT-NOTE-BEGIN ---
dnl T2 SDE: architecture/share/linux-common.conf.m4
dnl Copyright (C) 2004 - 2023 The T2 SDE Project
dnl 
dnl This Copyright note is generated by scripts/Create-CopyPatch,
dnl more information can be found in the files COPYING and README.
dnl 
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License version 2.
dnl --- T2-COPYRIGHT-NOTE-END ---

dnl Default console loglevel, new since 4.10, before we patched it
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=4
dnl CONFIG_SECURITY_DMESG_RESTRICT is not
CONFIG_DEFAULT_HOSTNAME="t2"

dnl Enable experimental features, and stagging drivers
dnl
CONFIG_EXPERIMENTAL=y
CONFIG_STAGING=y
# CONFIG_STAGING_EXCLUDE_BUILD is not set
# CONFIG_IKHEADERS is not set

dnl Power management and ACPI options
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS=y
CONFIG_ACPI_PROCFS_POWER=y
CONFIG_ACPI_SYSFS_POWER=y
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=m
CONFIG_ACPI_BATTERY=m
CONFIG_ACPI_SBS=m
CONFIG_ACPI_BUTTON=m
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=m
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=m
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_THERMAL=m
CONFIG_ACPI_PCI_SLOT=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_HED=m
CONFIG_ACPI_BGRT=y
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
CONFIG_ACPI_APEI_PCIEAER=y
CONFIG_HOTPLUG_PCI_ACPI=y
CONFIG_DMA_ACPI=y


dnl On default we build SMP kernels and mods
dnl
CONFIG_SMP=y
CONFIG_SCHED_SMT=y
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_SCHED_AUTOGROUP=y
CONFIG_IRQ_ALL_CPUS=y
CONFIG_JUMP_LABEL=y
CONFIG_IRQ_TIME_ACCOUNTING=y

CONFIG_LRU_GEN=y
CONFIG_LRU_GEN_ENABLED=y

CONFIG_MMIOTRACE=y

dnl For sandboxing, e.g. Chrome
dnl
CONFIG_NAMESPACES=y
CONFIG_USER_NS=y

dnl Default kernel and initrd compression (if available)
dnl
CONFIG_KERNEL_ZSTD=y
CONFIG_RD_ZSTD=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
# CONFIG_RD_LZ4 is not set


dnl Memory
dnl
CONFIG_MEMCG=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_ZONE_DEVICE=y
CONFIG_DEVICE_PRIVATE=y
CONFIG_EDAC=y

dnl No HZ and HPET, if the arch has it ...
dnl
CONFIG_HPET=y
CONFIG_HPET_TIMER=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_NO_HZ=y
CONFIG_NO_HZ_FULL=y

dnl just the default, a arch or target might still set other defaults
# CONFIG_PREEMPT_RT is not set
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y

dnl misc nice to have features
CONFIG_KSM=y
CONFIG_KEXEC=y
CONFIG_COMPAT=y
# CONFIG_COMPAT_BRK is not set
CONFIG_VIRTUALIZATION=y
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT_GUEST=y
CONFIG_PARAVIRT=y
CONFIG_KVM=y
CONFIG_KVM_GUEST=y
CONFIG_VFIO_PCI_VGA=y
CONFIG_IRQ_REMAP=y
CONFIG_BPF_JIT=y
CONFIG_BPF_UNPRIV_DEFAULT_OFF=y

dnl Power Management
dnl
CONFIG_PM=y
CONFIG_PM_RUNTIME=y
CONFIG_PM_LEGACY=y
CONFIG_HOTPLUG_CPU=y
CONFIG_HIBERNATION=y
dnl the old "HIBERNATION" option
CONFIG_SOFTWARE_SUSPEND=y

CONFIG_POWERCAP=y

dnl CPU frequency scaling is nice to have
dnl
CONFIG_CPU_FREQ=y
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_TEO=y
CONFIG_CPU_IDLE_GOV_HALTPOLL=y
CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=m
CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL=y
CONFIG_CPU_FREQ_GOV_PERFORMANCE=m
CONFIG_ENERGY_MODEL=y

dnl Enable modules
dnl
CONFIG_MODULES=y
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
CONFIG_KMOD=y

dnl Firmware loader can always be useful
dnl
CONFIG_FW_LOADER=y
CONFIG_FW_LOADER_COMPRESS=y
# CONFIG_FW_LOADER_COMPRESS_XZ is not set
CONFIG_FW_LOADER_COMPRESS_ZSTD=y
# CONFIG_FW_CACHE is not set

dnl Plug and play
dnl
CONFIG_PNP=y

dnl Common buses
dnl
CONFIG_PCI=y
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCI_MSI=y
CONFIG_PCI_IOV=y
CONFIG_PCIEAER=y
CONFIG_I2C=m
CONFIG_SPI=y

dnl PCI name database is also quite big (another >80kB) - so let's use user-
dnl space tools like lspci to use a non-kernel database
dnl
# CONFIG_PCI_NAMES ist not set

dnl Loopback device can always be useful
dnl
CONFIG_BLK_DEV_LOOP=y

dnl We need initrd for install system and fully modular kernel early userspace
dnl
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_INITRD=y

dnl Enable PCMCIA (PC-Card) as modules
dnl
CONFIG_PCMCIA=m
CONFIG_CARDBUS=y
CONFIG_PCCARD=m
CONFIG_TCIC=y
CONFIG_I82092=y
CONFIG_I82365=y

dnl Misc stuff
CONFIG_NVRAM=m

CONFIG_BINFMT_SCRIPT=y
CONFIG_BINFMT_AOUT=m
CONFIG_BINFMT_MISC=m

CONFIG_SYSVIPC=y
CONFIG_SUNRPC=y

dnl Sound system
dnl (module support is enought - default is y ...)
dnl
CONFIG_SOUND=m

dnl for 2.5/6 we do want the ALSA OSS emulation ...
dnl
CONFIG_SND_OSSEMUL=m
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_HDA_HWDEP=y

dnl Basic Input devices
dnl Good old standard ports, classic serial, PS/2, should just work.
dnl
CONFIG_INPUT=y
CONFIG_INPUT_EVDEV=m
CONFIG_INPUT_MOUSEDEV=m
CONFIG_INPUT_JOYDEV=m
CONFIG_INPUT_KEYBOARD=y
CONFIG_INPUT_MOUSE=y
CONFIG_INPUT_JOYSTICK=y
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_INPUT_TABLET=y
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_EVBUG is not set
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_PCIPS2=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_MOUSE_SERIAL=m
CONFIG_MOUSE_PS2=m

dnl LED devices & trigger
dnl
CONFIG_LEDS=y
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_IDE_DISK=y

dnl GPIO & stuff
dnl
CONFIG_GPIO=y

dnl USB drivers
dnl
CONFIG_USB=m
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_DEVICEFS=y
CONFIG_USB_SUSPEND=y
CONFIG_USB_EHCI_HCD=m
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_UHCI=m
CONFIG_USB_UHCI_ALT=m
CONFIG_USB_UHCI_HCD=m
CONFIG_USB_OHCI=m
CONFIG_USB_OHCI_HCD=m
CONFIG_USB_XHCI_PCI=m
CONFIG_USB_XHCI_PLATFORM=y
CONFIG_USB_HID=m
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_USB_HIDINPUT=m
CONFIG_USB_HIDDEV=y
CONFIG_HIDRAW=y
CONFIG_USB_SERIAL=m
dnl allows manual vendor/product ID override
CONFIG_USB_SERIAL_GENERIC=y

dnl USB - some others should be modular ...
dnl
CONFIG_USB_PRINTER=m
CONFIG_USB_STORAGE=m

dnl IEEE1394 - Firewire / iLink drivers
dnl
CONFIG_IEEE1394=m
CONFIG_IEEE1394_SBP2=m

dnl Crypto API
dnl
CONFIG_CRYPTO=y
dnl Fix btrfs in initrd, as no explicit dependency
CONFIG_CRYPTO_CRC32C=y

dnl Console (FB) Options
dnl
CONFIG_VT=y
CONFIG_VGA_CONSOLE=y
CONFIG_VIDEO_SELECT=y
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_FB=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
CONFIG_FB_SIMPLE=y
CONFIG_FB_EFI=y
CONFIG_LOGO=y
CONFIG_MEDIA_SUPPORT=m
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_USB_SUPPORT=y
CONFIG_MEDIA_PCI_SUPPORT=y

dnl Console (Serial) Options
dnl
CONFIG_SERIAL=y
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CONSOLE=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_SERIAL_OF_PLATFORM=y

dnl Printer (Parallel) Options
dnl
CONFIG_PRINTER=y
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=y
CONFIG_PARPORT_1284=y

CONFIG_PWM=y
CONFIG_WATCHDOG=y

dnl Video for Linux
dnl
CONFIG_VIDEO_DEV=m
CONFIG_VIDEO_PROC_FS=y

dnl DVB - Digital Video Broadcasting support
CONFIG_DVB=y

dnl On architectures with OpenFirmware we want the framebuffer
dnl
CONFIG_FB_OF=y

dnl The AGP support can be modular
dnl
CONFIG_AGP=m

dnl DRM drivers for hardware 3D
dnl
CONFIG_DRM=m
CONFIG_DRM_I915=m
CONFIG_DRM_I915_KMS=y
CONFIG_DRM_I915_GVT=y
CONFIG_DRM_AMDGPU_SI=y
CONFIG_DRM_AMDGPU_CIK=y
CONFIG_DRM_AMDGPU_USERPTR=y
CONFIG_DRM_AMD_DC=y
CONFIG_DRM_AMD_DC_DCN1_0=y
CONFIG_DRM_AMD_ACP=y

dnl The 2.6 kernel has several debugging options enabled
dnl
# CONFIG_FRAME_POINTER is not set

dnl Enable kernel profiling support (oprofile)
dnl
CONFIG_PROFILING=y
CONFIG_OPROFILE=m

dnl Other stuff normally needed
dnl
CONFIG_POSIX_MQUEUE=y
CONFIG_SYSCTL=y

dnl Language stuff, code pages, ... (needed for vfat mounts)
dnl
CONFIG_NLS=m

dnl Some commonly useful debugging
dnl
# CONFIG_DEBUG_KERNEL is not set
# CONFIG_RUNTIME_TESTING_MENU is not set
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_MAPLE_TREE is no set

dnl Intel PowerTop
CONFIG_TIMER_STATS=y

dnl some Binary-only kmod compatibility
dnl CONFIG_DEBUG_LIST=y
dnl CONFIG_FUNCTION_TRACER=y

dnl RTC time keeping
dnl
CONFIG_RTC_CLASS=y

dnl Other nice to have
dnl
CONFIG_MAGIC_SYSRQ=y
CONFIG_PANIC_TIMEOUT=60

dnl No unit test stuff
dnl
# CONFIG_SLUB_DEBUG is not set
# CONFIG_KUNIT is not set
