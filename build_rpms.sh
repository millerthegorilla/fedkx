#    This file is part of rpm_maker.

#    rpm_maker is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    rpm_maker is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with rpm_maker.  If not, see <https://www.gnu.org/licenses/>.
#    (c) 2018 - James Stewart Miller
#!/bin/bash
# build_rpms.sh working_dir deb_filepath rpms_dir arch
# rpms_dir can be working_dir/rpms
RPM_ROOT=$1
DEB_DIR_PATH=$RPM_ROOT
RPM_BUILD_ROOT=$DEB_DIR_PATH/root/rpmbuild/BUILD/
RPM_LOG=$RPM_BUILD_ROOT/kxfed_rpm_log
DEB_PATH=$2
BUILT_RPMS_DIR=$3
ARCH=$4

if [ ! -d "$RPM_BUILD_ROOT" ]; then
  mkdir -p "$RPM_BUILD_ROOT"
fi

if [ ! -d "$BUILT_RPMS_DIR" ]; then
  mkdir -p "$BUILT_RPMS_DIR"
fi

cd "$RPM_BUILD_ROOT"
echo $(pwd)
log+=(echo alien says $(alien -r -g -v "$DEB_PATH" 2>&1))

aliendir=$(find . -maxdepth 1 -type d -name '[^.]?*' -printf %f -quit)
echo 'aliendir is '"$aliendir"

specfilename=$(find "$RPM_BUILD_ROOT$aliendir" -type f -name \*.spec)
specfilename=$(basename "$specfilename")
echo 'specfilename is '"$specfilename"

if [ "$ARCH"=='amd64' ]; then
    adir=$(echo "$specfilename" | sed 's/spec/x86_64\//')
    else
    adir=$(echo "$specfilename" | sed 's/spec/x386\//')
    fi
echo 'adir is '"$adir"

mv "$RPM_BUILD_ROOT$aliendir" "$RPM_BUILD_ROOT$adir"
mv "$RPM_BUILD_ROOT$adir/usr" "$RPM_BUILD_ROOT"

specfilepath="$RPM_BUILD_ROOT$adir$specfilename"

# edit spec file to remove unnecessary prefixes
sed -i '/^%dir/ d' "$specfilepath"

cd "$adir"
log+=$(echo rpm says $(rpmbuild -bb --rebuild --noclean --buildroot "$RPM_BUILD_ROOT" "$specfilepath" 2>&1))
# fn=$(echo "$adir" | sed 's/\///' | sed 's/\.x/-x/' | awk '{print $1".rpm"}')
mv "$RPM_BUILD_ROOT"*.rpm "$BUILT_RPMS_DIR" # $fn"
rm -rf $RPM_BUILD_ROOT
echo $log
exit 0