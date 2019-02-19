#! /bin/bash
# build_rpms.sh working_dir deb_filepath rpms_dir arch
# rpms_dir can be working_dir/rpms

##  this all depends on making a .rpmmacros file in users home dir with
##   %_topdir      /home/james/.local/share/kxfed/rpmbuild    inside it.
FILE=$1
DEB_DIR=$2
FILE_NAME=${FILE}.deb
DEB_PATH=${DEB_DIR}${FILE_NAME}
BUILT_RPMS_DIR=$3
TMP_DIR=$4
ARCH=$5
INSTALL_ACTION=$6

RPM_BUILD_ROOT=${TMP_DIR}rpmbuild/BUILDROOT/
PKG_BUILD_ROOT=${RPM_BUILD_ROOT}${FILE}

if [ ! -d "${RPM_BUILD_ROOT}" ]; then
    mkdir -p "${RPM_BUILD_ROOT}"
fi

if [ ! -d "${RPM_BUILD_ROOT}" ]; then
    mkdir -p "${RPM_BUILD_ROOT}"
fi

if [ ! -d "${BUILT_RPMS_DIR}" ]; then
    mkdir -p "${BUILT_RPMS_DIR}"
fi

if [ "${ARCH}"="amd64" ]; then
    ARCH="x86_64"
fi

USER_HOME=$(echo $(getent passwd $USER )| cut -d : -f 6)
RPM_MACRO_FILE=${USER_HOME}/.rpmmacros
if [ ! -f "${RPM_MACRO_FILE}" ]; then
    touch ${RPM_MACRO_FILE}
    echo  "%_topdir      ${TMP_DIR}rpmbuild" > ${RPM_MACRO_FILE}
else
    mv ${RPM_MACRO_FILE} ${RPM_MACRO_FILE}.old
    touch ${RPM_MACRO_FILE}
    echo  "%_topdir      ${TMP_DIR}rpmbuild" > ${RPM_MACRO_FILE}
fi

cd "${RPM_BUILD_ROOT}"

tmp=$(sudo alien -r -g -k -v "${DEB_PATH}")
ALIEN_FILENAME=$(echo ${tmp} | grep -oP '(?<=mkdir\s)([^\s]+)')
ALIEN_DIR="${ALIEN_FILENAME}-1.${ARCH}/"
sudo mv ${RPM_BUILD_ROOT}${ALIEN_FILENAME} ${RPM_BUILD_ROOT}${ALIEN_DIR}
SPECFILE_PATH="${RPM_BUILD_ROOT}${ALIEN_DIR}${ALIEN_FILENAME}-1.spec"

$(sudo sed -i '/^%dir/ d' "${SPECFILE_PATH}")

rpmbuild --bb --rebuild ${SPECFILE_PATH}
mv "${RPM_BUILD_ROOT}../"*.rpm "${BUILT_RPMS_DIR}"

if [[ "${INSTALL_ACTION}" == *"install"* ]]; then
    echo $(sudo dnf install -y ${BUILT_RPMS_DIR}${ALIEN_FILENAME}-1.${ARCH}.rpm)
fi

exit 0