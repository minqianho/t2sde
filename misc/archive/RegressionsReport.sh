#!/bin/bash
config=default
TARGET=regressions
revision=`svn info | sed -n 's,^Revision: \(.*\),\1,p'` 

if [ "$1" == "-cfg" ]; then
	config="$2"; shift 2
fi

eval `grep '^export ROCKCFG_ID=' config/$config/config`

if [ -z "$ROCKCFG_ID" ]; then
	echo "Invalid config '$cfg'."
	exit 1
fi

mkdir -p $TARGET

echo "[$( date +%T )] Auditing '$config' to '$TARGET/' ..."
sh misc/archive/AuditBuild.sh -w $TARGET -cfg $config --no-enabled-too -repository package/* \
	| grep '\(CHANGED\|UPDATED\|ADDED\|FAILED\|PENDING\|NOQUEUED\)' > $TARGET/regressions.$config.$$
echo "[$( date +%T )] Auditing completed."

if [ ! -d $TARGET/$config ]; then
	echo "Something weird happened running AuditBuild.sh. $TARGET/$config was not created."
	exit 1
fi

echo "[$( date +%T )] Rendering report..."

{
cat <<EOT
<html>
	<head><title>T2 r$revision - $( date )</title></head>
<body>
<table border="0">
<tr><th colspan="2">$ROCKCFG_ID ($revision)</th></tr>
<tr><td valign="top">
	<table border="1" cellspacing="0" width="100%">
	<tr><td>revision</td><td>:</td><td>$revision</td></tr>
	<tr><td>config</td><td>:</td><td>
EOT

mkdir -p $TARGET/$config/config
for x in config/$config/*; do
	cp $x $TARGET/$config/config/${x##config/$config/}
	echo -e "\t\t<a href=\"config/${x##config/$config/}\">${x##config/$config/}</a><br />"
done

pkgenabled=$( grep '^X' config/$config/packages | wc -l )
pkgdisabled=$( grep '^O' config/$config/packages | wc -l )
pkgtotal=$( ls -1 package/*/*/*.desc | wc -l )
cat <<EOT
	</td></tr>
	<tr><td>Enabled</td><td>:</td><td>$pkgenabled</td></tr>
	<tr><td>Disabled</td><td>:</td><td>$pkgdisabled</td></tr>
	<tr><td>Hidden</td><td>:</td><td>$( expr $pkgtotal - $pkgenabled - $pkgdisabled )</td></tr>
	<tr><td>Total</td><td>:</td><td>$pkgtotal</td></tr>
</table>
<br />
<table border="1" cellspacing="0" width="100%">
<tr><th colspan="2">Failed Builds</th></tr>
EOT

pattern="^X "
pkgtotal=0 pkgerr=0 pkgok=0
for stagelevel in 0 1 2 3 4 5 6 7 8 9; do
	while read x x x repo pkg x; do
		(( pkgtotal++ ))
		if [ -f build/$ROCKCFG_ID/var/adm/logs/$stagelevel-$pkg.err ]; then
			(( pkgerr++ ))
cat <<EOT
	<tr><td>$stagelevel</td><td><a href="log/$stagelevel-$pkg.err">$repo/$pkg</a></td></tr>
EOT
		elif [ -f build/$ROCKCFG_ID/var/adm/logs/$stagelevel-$pkg.log ]; then
			(( pkgok++ ))
		fi
	done < <( grep -e "$pattern$stagelevel.*" config/$config/packages )
	pattern="$pattern."
done

cat <<EOT
</table>
<br />
<table border="1" cellspacing="0" width="100%">
	<tr><td>Total</td><td>:</td><td align="right">$pkgtotal</td></tr>
	<tr><td>Built Fine</td><td>:</td><td align="right">$pkgok</td></tr>
	<tr><td>Broken Builds</td><td>:</td><td align="right">$pkgerr</td></tr>
	<tr><td>Pending Builds</td><td>:</td><td align="right">$( expr $pkgtotal - $pkgok - $pkgerr )</td></tr>
</table>
</td><td>
<table>
	<tr><th>Package</th><th>SVN Status</th><th>Version</th><th>Audit</th><th>Status</th></tr>
EOT

grep -v NOQUEUED $TARGET/regressions.$config.$$

cat <<EOT
</table><hr><table>
	<tr><th>Package</th><th>SVN Status</th><th>Version</th><th>Audit</th><th>Status</th></tr>
EOT

grep NOQUEUED $TARGET/regressions.$config.$$

cat <<EOT
</table></td></tr>
</table></body>
</html>
EOT
}  > $TARGET/regressions.$config.html

echo "[$( date +%T )] Rendering finished."

rm -f $TARGET/regressions.$config.$$
mv -f $TARGET/regressions.$config.html $TARGET/$config/regressions.html

