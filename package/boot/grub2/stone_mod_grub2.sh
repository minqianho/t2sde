# --- T2-COPYRIGHT-NOTE-BEGIN ---
# T2 SDE: package/*/grub2/stone_mod_grub2.sh
# Copyright (C) 2004 - 2024 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# 
# This Copyright note is generated by scripts/Create-CopyPatch,
# more information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2.
# --- T2-COPYRIGHT-NOTE-END ---
#
# [MAIN] 70 grub2 GRUB2 Boot Loader Setup
# [SETUP] 90 grub2

# TODO:
# avoid efibootmgr duplicates :-/
# impl. & test direct sparc, direct i386-pc-mbr, mips-arc, ...
# unify non-crypt, and direct non-EFI BIOS install

arch=$(uname -m)
arch=${arch/i?86/i386}
arch=${arch/aarch/arm}

# detect platform once, Attn, SYNC w/ stone_mod_install!
platform2=$(grep '\(platform\|type\)' /proc/cpuinfo) platform2=${platform2##*: }
[ -e /sys/firmware/efi ] && platform=$arch-efi ||
case $arch in
	ppc*)
		arch="$arch-$platform2" ;;
esac

cmdline="console= $(< /proc/cmdline)"
cmdline=${cmdline##*console=} cmdline=${cmdline%%[ ,]*}
if [ -z "$cmdline" ]; then
	cmdline="`grep -a -H Y /sys/class/tty/*/console`"
	cmdline="${cmdline%%/console*}" cmdline=${cmdline##*/}
fi

create_kernel_list() {
	first=1
	for x in `(cd /boot/; ls vmlinux-* ) | sort -r`; do
		ver=${x/vmlinux-/}
		[[ $arch = *86* ]] && x=${x/vmlinux/vmlinuz}
		[[ $arch = *arm* ]] && x=${x/vmlinux/Image}.gz
		if [ $first = 1 ]; then
			label="Linux" first=0
		else
			label="Linux ($ver)"
		fi

		local initrd="$bootpath/initrd-${ver}"
		[ -e /boot/microcode.img ] && initrd="/boot/microcode.img $initrd"

		cat << EOT

menuentry "T2/$label" {
	linux $bootpath/$x root=$rootdev ro${swapdev:+ resume=$swapdev}${cmdline:+ console=}$cmdline
	initrd $initrd
}
EOT
	done
}

create_boot_menu() {
	mkdir -p /boot/grub/
	cat << EOT > /boot/grub/grub.cfg
set timeout=30
set default=0
set fallback=1

if [ "\$grub_platform" = "efi" ]; then
    set debug=video
    insmod efi_gop
    insmod efi_uga
    insmod font
    if loadfont \${prefix}/unicode.pf2; then
	insmod gfxterm
	set gfxmode=auto
	set gfxpayload=keep
	terminal_output gfxterm
    fi
fi

EOT

	create_kernel_list >> /boot/grub/grub.cfg

	gui_message "This is the new /boot/grub/grub.cfg file:

$(cat /boot/grub/grub.cfg)"
}

grubmods="normal boot configfile linux part_msdos part_gpt \
	  fat ext2 iso9660 reiserfs btrfs xfs jfs \
	  search search_fs_file search_label search_fs_uuid \
	  all_video sleep reboot \
	  cryptodisk lvm luks luks2 crypto"

case "$arch" in
	ppc*)	grubmods="$grubmods part_apple hfs hfsplus suspend" ;;
	sparc*)	grubmods="$grubmods part_sun" ;;
	x86*)	grubmods="$grubmods ntfs ntfscomp" ;;
esac

grub_inst() {
    if [[ $arch != ppc* ]]; then
	if [[ ! "$cryptdev" && "$instdev" != *efi ]]; then
	    if [[ "$arch" != sparc* ]]; then
		grub2-install $instdev
	    else
		grub2-install $instdev --skip-fs-probe --force
	    fi
	else
	    for efi in ${instdev}*; do
		mount -o remount,rw $efi
		mkdir -p $efi/efi/boot

		echo -n > $efi/efi/boot/grub.cfg

		if [ ! "$cryptdev" ]; then
			# if uuid, not LVM search it
			[[ "$grubdev" != \(* ]] &&
			cat << EOT >> $efi/efi/boot/grub.cfg
set uuid=$grubdev
search --set=root --no-floppy --fs-uuid \$uuid
EOT
		else
	    		cat << EOT >> $efi/efi/boot/grub.cfg
set uuid="${cryptdev##*/}"
if cryptomount -u \$uuid; then set root=(crypto0); fi
EOT
		fi

		# explicitly set root for lvm
		if [[ "$grubdev" = \(lvm* ]]; then
			echo "set root=$grubdev" >> $efi/efi/boot/grub.cfg
		fi

		echo "configfile /boot/grub/grub.cfg" >> $efi/efi/boot/grub.cfg

		local exe=boot.efi
		case $arch in
		i386)	exe=${exe/./ia32.} ;;
		ia64)	exe=${exe/./ia64.} ;;
		x86_64)	exe=${exe/./x64.} ;;
		arm64)	exe=${exe/./aa64.} ;;
		arm*)	exe=${exe/./arm.} ;;
		riscv*)	exe=${exe/./$arch.} ;;
		esac

		mkdir -p $efi/efi/boot/$arch-efi
		cp -f /usr/lib*/grub/$arch-efi/*.{mod,lst} \
			$efi/efi/boot/$arch-efi/

		grub-mkimage -O $arch-efi -o $efi/efi/boot/$exe \
			-p /efi/boot -d /usr/lib*/grub/$arch-efi/ \
			$grubmods
	    done

	    mount -t efivarfs none /sys/firmware/efi/efivars
	    efibootmgr -c -L "T2 Linux" -l "\\efi\\boot\\$exe"
	    umount /sys/firmware/efi/efivars
	fi
    else
      if [[ "$arch" = *CHRP ]]; then
	instdev=/dev/sda # TODO: fix LVM setup

	# IBM CHRP install into FW read-able RAW partition
	local bootstrap=$instdev$(disktype $instdev | grep "PReP Boot" -B 1 |
		sed -n 's/Partition \(.*\):.*/\1/p')
	if [ "$bootstrap" = "$instdev" ]; then
		echo "No CHRP PReP bootstrap partition found!"
		return
	fi

	# TODO: tempfile, built-in config script -c
	grub-mkimage --note -O powerpc-ieee1275 -p /boot/grub \
		-o /tmp/grub -d /usr/lib*/grub/powerpc-ieee1275 \
		$grubmods

	dd if=/dev/zero of=$bootstrap bs=4096
	dd if=/tmp/grub of=$bootstrap bs=4096
	rm -f /tmp/grub
      else
	# Apple PowerPC - install into FW read-able HFS partition
	local bootstrap=$instdev$(disktype $instdev | grep Apple_Bootstrap -B 1 |
		sed -n 's/Partition \(.*\):.*/\1/p')
	if [ "$bootstrap" = "$instdev" ]; then
		echo "No HFS bootstrap partition found!"
		return
	fi
	
	umount /mnt 2>/dev/null
	hformat -l bootstrap $bootstrap
	if ! mount $bootstrap /mnt; then
	    echo "Error mounting HFS bootstrap partition"
	else
	    mkdir -p /mnt/boot/grub
	    if [ -z "$cryptdev" ]; then
		cat << EOT > /mnt/boot/grub/grub.cfg
set uuid=$grubdev
search --set=root --no-floppy --fs-uuid \$uuid
configfile (\$root)/boot/grub/grub.cfg
EOT
	    else
		cat << EOT > /mnt/boot/grub/grub.cfg
set uuid=$grubdev
cryptomount -u \$uuid
configfile $cryptdev/boot/grub/grub.cfg
EOT
	    fi
	    grub-mkimage -O powerpc-ieee1275 -p /boot/grub \
		-o /mnt/grub -d /usr/lib*/grub/powerpc-ieee1275 \
		$grubmods

	    cat > /mnt/boot/ofboot.b <<-EOT
<CHRP-BOOT>
<COMPATIBLE>
MacRISC MacRISC3 MacRISC4
</COMPATIBLE>
<DESCRIPTION>
T2 SDE
</DESCRIPTION>
<BOOT-SCRIPT>
" screen" output
load-base release-load-area
boot &device;:,\\grub
</BOOT-SCRIPT>
<OS-BADGE-ICONS>
1010
000000000000F8FEACF6000000000000
0000000000F5FFFFFEFEF50000000000
00000000002BFAFEFAFCF70000000000
0000000000F65D5857812B0000000000
0000000000F5350B2F88560000000000
0000000000F6335708F8FE0000000000
00000000005600F600F5FD8100000000
00000000F9F8000000F5FAFFF8000000
000000008100F5F50000F6FEFE000000
000000F8F700F500F50000FCFFF70000
00000088F70000F50000F5FCFF2B0000
0000002F582A00F5000008ADE02C0000
00090B0A35A62B0000002D3B350A0000
000A0A0B0B3BF60000505E0B0A0B0A00
002E350B0B2F87FAFCF45F0B2E090000
00000007335FF82BF72B575907000000
000000000000ACFFFF81000000000000
000000000081FFFFFFFF810000000000
0000000000FBFFFFFFFFAC0000000000
000000000081DFDFDFFFFB0000000000
000000000081DD5F83FFFD0000000000
000000000081DDDF5EACFF0000000000
0000000000FDF981F981FFFF00000000
00000000FFACF9F9F981FFFFAC000000
00000000FFF98181F9F981FFFF000000
000000ACACF981F981F9F9FFFFAC0000
000000FFACF9F981F9F981FFFFFB0000
00000083DFFBF981F9F95EFFFFFC0000
005F5F5FDDFFFBF9F9F983DDDD5F0000
005F5F5F5FDD81F9F9E7DF5F5F5F5F00
0083DD5F5F83FFFFFFFFDF5F835F0000
000000FBDDDFACFBACFBDFDFFB000000
000000000000FFFFFFFF000000000000
0000000000FFFFFFFFFFFF0000000000
0000000000FFFFFFFFFFFF0000000000
0000000000FFFFFFFFFFFF0000000000
0000000000FFFFFFFFFFFF0000000000
0000000000FFFFFFFFFFFF0000000000
0000000000FFFFFFFFFFFFFF00000000
00000000FFFFFFFFFFFFFFFFFF000000
00000000FFFFFFFFFFFFFFFFFF000000
000000FFFFFFFFFFFFFFFFFFFFFF0000
000000FFFFFFFFFFFFFFFFFFFFFF0000
000000FFFFFFFFFFFFFFFFFFFFFF0000
00FFFFFFFFFFFFFFFFFFFFFFFFFF0000
00FFFFFFFFFFFFFFFFFFFFFFFFFFFF00
00FFFFFFFFFFFFFFFFFFFFFFFFFF0000
000000FFFFFFFFFFFFFFFFFFFF000000
</OS-BADGE-ICONS>
</CHRP-BOOT>
EOT

	    umount /mnt
	    hmount $bootstrap
	    hattrib -b bootstrap:boot
	    hattrib -c UNIX -t tbxi bootstrap:boot:ofboot.b
	    humount
	fi
      fi
    fi
}

grub_install() {
	gui_cmd 'Installing GRUB2' "grub_inst"
}

get_dm_dev() {
	local dev="$1"
	local devnode=$(stat -c "%t:%T" $dev)
	for d in /dev/dm-*; do
		[ "$(stat -c "%t:%T" "$d" 2>/dev/null)" = "$devnode" ] && echo $d && return
	done
}

get_dm_type() {
	local dev="$1"
	dev="${dev##*/}"
	[ -e /sys/block/$dev/dm/uuid ] && cat /sys/block/$dev/dm/uuid
}

get_dm_slaves() {
	local dev="$1"
	dev="${dev##*/}"
	[ -e /sys/block/$dev/slaves ] &&
		cd /sys/block/$dev/slaves && ls | sed 's,^,/dev/,'
}

get_crypted_dm_slaves() {
	for d; do
	    [[ "$(blkid --match-tag TYPE $d)" = *crypto_LUKS* ]] &&
		  echo "$d" ||
		  get_crypted_dm_slaves $(get_dm_slaves $d)
	done
}

get_uuid() {
	local dev="$1"

	# look up uuid
	for _dev in /dev/disk/by-uuid/*; do
		local d=$(readlink $_dev)
		d="/dev/${d##*/}"
		if [ "$d" = $dev ]; then
			echo $_dev
			return
		fi
	done
}

get_realdev() {
	local dev="$1"
	dev=$(readlink $dev)
	[ "$dev" ] && echo /dev/${dev##*/} || echo $1
}

main() {
	rootdev="`grep ' / ' /etc/fstab | tail -n 1 | sed 's, .*,,'`"
	bootdev="`grep ' /boot ' /etc/fstab | tail -n 1 | sed 's, .*,,'`"
	swapdev="`grep ' swap ' /etc/fstab | head -n 1 | sed 's, .*,,'`"
	[ "$bootdev" ] || bootdev="$rootdev"
	# /boot path, relative to the boot device
	[ "$rootdev" = "$bootdev" ] && bootpath="/boot" || bootpath=""

	# any device-mapper luks encrypted backing slave device?
	cryptdev=$(get_crypted_dm_slaves $bootdev $(get_dm_dev $bootdev))

	# get uuid
	uuid=$(get_uuid $rootdev)
	[ "$uuid" ] && rootdev=$uuid
	[ "$bootdev" ] && uuid=$(get_uuid $bootdev) && [ "$uuid" ] && bootdev=$uuid
	[ "$cryptdev" ] && uuid=$(get_uuid $cryptdev) && [ "$uuid" ] && cryptdev=$uuid

	if [ -d /sys/firmware/efi ]; then
		instdev=/boot/efi
	elif [[ "$arch" = sparc* ]]; then
		instdev=$(get_realdev $bootdev)
		instdev="${instdev%%[0-9*]}1"
	else
		instdev=$(get_realdev $bootdev)
		instdev="${instdev%%[0-9*]}"
	fi

	# lvm device-mapper?
	if [[ $bootdev = *mapper* ]]; then
	        grubdev="(lvm/${bootdev##*/})"
		[ "$cryptdev" ] && rootdev="$cryptdev,$rootdev"
	else
		grubdev="${bootdev##*/}"
	fi

	if [ ! -f /boot/grub/grub.cfg ]; then
	  if gui_yesno "GRUB2 does not appear to be configured.
Automatically install GRUB2 now?"; then
	    create_boot_menu
	    if ! grub_install; then
	      gui_message "There was an error while installing GRUB2."
	    fi
	  fi
	fi

	while

	gui_menu grub 'GRUB2 Boot Loader Setup' \
		"Root device ... $rootdev" "" \
		"Boot device ... $bootdev" "" \
		"Crypt device .. $cryptdev" "" \
		"Grub device ... $grubdev" "" \
		"Inst device ... $instdev" "" \
		'' '' \
		'(Re-)Create boot menu with installed kernels' 'create_boot_menu' \
		"(Re-)Install GRUB2 in boot record ($instdev)" 'grub_install' \
		'' '' \
		"Edit /boot/grub/grub.cfg (Boot Menu)" \
			"gui_edit 'GRUB2 Boot Menu' /boot/grub/grub.cfg"
    do : ; done
}
