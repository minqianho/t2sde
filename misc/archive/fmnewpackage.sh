#!/bin/bash
#
# Written by Benjamin Schieder <blindcoder@scavenger.homeip.net>
# Modified by Juergen Sawinski <jsaw@gmx.net> to create
# a package based on freshmeat info
#
# Use:
# newpackage.sh [-main] <rep>/<pkg> <freshmeat package name>
#
# will create <pkg>.desc and <pkg>.conf. .desc will contain the [D] and [COPY]
# already filled in. The other tags are mentioned with TODO.
#
# .conf will contain an empty <pkg>_main() { } and custmain="<pkg>_main"
# if -main is specified.
#
# --- ROCK-COPYRIGHT-NOTE-BEGIN ---
# 
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# Please add additional copyright information _after_ the line containing
# the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
# the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
# 
# ROCK Linux: rock-src/misc/archive/fmnewpackage.sh
# Copyright (C) 1998 - 2003 ROCK Linux Project
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version. A copy of the GNU General Public
# License can be found at Documentation/COPYING.
# 
# Many people helped and are helping developing ROCK Linux. Please
# have a look at http://www.rocklinux.org/ and the Documentation/TEAM
# file for details.
# 
# --- ROCK-COPYRIGHT-NOTE-END ---
#

extract_xml_name() {
    local tmp="`tr -d "\012" < $2 | grep $3 | sed "s,.*<$3>\([^<]*\)<.*,\1," | sed 's,,\n[T] ,g' | sed 's,^\[T\] $,,'`"
    eval "$1=\"\$tmp\""
}

get_download() {
    local location
    download_file=""
    download_url=""
    for arg; do
	if curl -s -I -f "$arg" -o "header.log"; then
	    location="`grep Location: header.log | sed 's,Location:[ ]\([.0-9A-Za-z-:/% ]*\).*,\1,'`"
	    download_file="`basename $location`"
	    download_url="`dirname $location`/"
	    rm -f header.log
	    return
	fi
    done
    rm -f header.log
}

read_fm_config() {
    local fmname=$1
    curl_options="" #--disable-epsv -#
    if curl -s -f $resume $curl_options "http://freshmeat.net/projects-xml/$fmname/$fmname.xml" -o "$fmname.xml"; then
	extract_xml_name project $fmname.xml projectname_full
	extract_xml_name title   $fmname.xml desc_short
	extract_xml_name desc    $fmname.xml desc_full
	extract_xml_name urlh    $fmname.xml url_homepage
	extract_xml_name license $fmname.xml license
	extract_xml_name version $fmname.xml latest_release_version

	extract_xml_name url_tbz $fmname.xml url_bz2
	extract_xml_name url_tgz $fmname.xml url_tgz
	extract_xml_name url_zip $fmname.xml url_zip
	extract_xml_name url_cvs $fmname.xml url_cvs

	url="$(curl -I $urlh 2>/dev/null | grep "^Location:" | sed -e 's,^Location: \(.*\)$,\1,' | tr -d '\015' )"
	get_download $url_tbz $url_tgz $url_zip #@FIXME $url_cvs 

# grep trove categories for status IDs
	for trove_id in `grep '<trove_id>' $fmname.xml | sed 's,.*<trove_id>\(.*\)</trove_id>,\1,g'` ; do
		case $trove_id in
			9) status="Alpha"
				;;
    			10) status="Beta"
				;;
			11,12) status="Stable"
				;;
			# there is no default
		esac
	done

# download package fm-page and grep for the author
	html="http://freshmeat.net/projects/$fmname/"
	curl -I -s "$html" -o "header.log"
	html_new="`grep Location: header.log | sed 's,Location:[ ]\([.0-9A-Za-z-:/%?_= ]*\).*,\1,'`"
	[ ! -z html_new ] && html="$html_new"
	unset html_new
	rm -f header.log
	curl -s "$html" -o "$fmname.html"
	dev_name="`grep 'contact developer' "$fmname.html" | sed 's,^[[:blank:]]*\(.*\)[[:blank:]]<a.*$,\1,' | sed 's, *$,,g'`"
	dev_mail="<`grep 'contact developer' "$fmname.html" | sed 's,^.*<a href=\"mailto:\(.*\)\">.*$,\1,'`>"
	echo "__at__ @" >subst
	echo "__dot__ ." >>subst
	echo "|at| @" >>subst
	echo "|dot| ." >>subst
	echo "\\[at\\] @" >>subst
	echo "\\[dot\\] ." >>subst
	echo "(at) @" >>subst
	echo "(dot) ." >>subst

	echo -n "$dev_mail" >dev_mail
# for some strange reason, this doesn't work:
# cat subst | while read from to ; do 
#         export dev_mail="${dev_mail// $from /$to}"
# done
# dev_mail will have the same value as before
	cat subst | while read from to ; do 
		dev_mail="`cat dev_mail`"
		dev_mail="${dev_mail// $from /$to}"
		echo -n "$dev_mail" >dev_mail
	done
	dev_mail="`cat dev_mail`"
	rm -f subst $fmname.html dev_mail

	if [ -z "$dev_mail" -o -z "$dev_name" ] ; then
		dev_name="TODO: "
		dev_mail="Author"
	fi

	#cleanup license
	case "$license" in
	*GPL*Library*)
	    license=LGPL
	    ;;
	*GPL*Documentation*)
	    license=FDL
	    ;;
	*GPL*)
	    license=GPL
	    ;;
	*Mozilla*Public*)
	    license=MPL
	    ;;
	*MIT*)
	    license=MIT
	    ;;
	*BSD*)
	    license=BSD
	    ;;
	esac
	rm -f $fmname.xml
    else
	return 1
    fi
}

if [ "$1" == "-main" ] ; then
	create_main=1
	shift
fi

if [ $# -lt 2 -o $# -gt 2 ] ; then
	cat <<-EEE
Usage:
$0 <option> package/repository/packagename freshmeat-package-name

Where <option> may be:
	-main		Create a package.conf file with main-function

	EEE
	exit 1
fi


dir=${1#package/} ; shift
package=${dir##*/}
if [ "$package" = "$dir" ]; then
	echo "failed"
	echo -e "\t$dir must be <rep>/<pkg>!\n"
	exit
fi

rep="$( echo package/*/$package | cut -d'/' -f 2 )"
if [ "$rep" != "*" ]; then
	echo "failed"
	echo -e "\tpackage $package belongs to $rep!\n"
	exit
fi

rep=${dir/\/$package/}
maintainer="$( grep -h -m 1 "\[M\]" package/$rep/*/*.desc | head -n 1 | cut -d' ' -f2- )"

echo -n "Creating package/$dir ... "
if [ -e package/$dir ] ; then
	echo "failed"
	echo -e "\tpackage/$dir already exists!\n"
	exit
fi
if mkdir -p package/$dir ; then
	echo "ok"
else
	echo "failed"
	exit
fi

cd package/$dir
rc="ROCK-COPYRIGHT"

if ! read_fm_config $1; then
    echo "Error or wrong freshmeat package name"
    exit 1
fi

echo -n "Creating $package.desc ... "
echo "[I] ${title:-TODO: Title}" >$package.desc

# [T] ${desc:-TODO: Description}
while read l; do
    echo "[T] $l" >>$package.desc
done < <(echo ${desc:-TODO: Description} | fmt --width 70)

cat >>$package.desc <<EOF

[U] ${url:-TODO: URL}

[A] $dev_name $dev_mail
[M] ${maintainer:-TODO: Maintainer}

[C] TODO: Category

[L] ${license:-TODO: License}
[S] ${status:-TODO: Status}
[V] ${version:-TODO: Version}
[P] X -----5---9 800.000

[D] 0 $download_file $download_url
EOF

echo "ok"
echo -n "Creating $package.conf ... "

if [ "$create_main" == "1" ] ; then
	cat >>$package.conf <<-EOF
${package}_main() { 
    : TODO
}

custmain="${package}_main"
EOF
fi

echo "ok"
echo "Remember to fill in the TODO's:"
cd -
grep TODO package/$dir/$package.*
echo
