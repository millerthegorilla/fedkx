#! /bin/bash
# build_rpms.sh working_dir deb_filepath rpms_dir arch
# rpms_dir can be working_dir/rpms

##  this all depends on making a .rpmmacros file in users home dir with
##   %_topdir      /home/james/.local/share/kxfed/rpmbuild    inside it.
DEB_DIR=$1
FILE=$2
FILE_NAME=${FILE}.deb
DEB_PATH=${DEB_DIR}${FILE_NAME}
BUILT_RPMS_DIR=$3
ARCH=$4
#RPM_BUILD_ROOT=${DEB_PATH}/root/rpmbuild/BUILDROOT/
RPM_BUILD_ROOT=/home/james/.local/share/kxfed/rpmbuild/BUILDROOT/
PKG_BUILD_ROOT=${RPM_BUILD_ROOT}${FILE}
SPECFILE_PATH=${RPM_BUILD_ROOT}${FILE}
#
#echo deb dir is ${DEB_DIR}
#echo Deb path is ${DEB_PATH}
#echo rpm_build_root is ${RPM_BUILD_ROOT}
#echo filename is ${FILE_NAME}
#echo BUILT_RPMS_DIR is ${BUILT_RPMS_DIR}
#echo pkg_build_Root is ${PKG_BUILD_ROOT}
#
if [ ! -d "${RPM_BUILD_ROOT}" ]; then
  mkdir -p "${RPM_BUILD_ROOT}"
fi

if [ ! -d "${RPM_BUILD_ROOT}" ]; then
  mkdir -p "${RPM_BUILD_ROOT}"
fi

if [ ! -d "${BUILT_RPMS_DIR}" ]; then
  mkdir -p "${BUILT_RPMS_DIR}"
fi

cd "${RPM_BUILD_ROOT}"

tmp=$(sudo alien -r -g -k -v "${DEB_PATH}")
ALIEN_FILENAME=$(echo ${tmp} | grep -oP '(?<=mkdir\s).*')
echo tmp is ${tmp}
echo alien_filename is ${ALIEN_FILENAME}
ALIEN_DIR="${ALIEN_FILENAME}-1.x86_64/"
sudo mv ${RPM_BUILD_ROOT}${ALIEN_FILENAME} ${RPM_BUILD_ROOT}${ALIEN_DIR}
specfilepath="${RPM_BUILD_ROOT}${ALIEN_DIR}${ALIEN_FILENAME}-1.spec"

$(sudo sed -i '/^%dir/ d' "${specfilepath}")

echo rpmbuild is "\n"$(rpmbuild --bb --rebuild ${specfilepath})
mv "${RPM_BUILD_ROOT}../"*.rpm "${BUILT_RPMS_DIR}"
#echo ${log}
exit 0
