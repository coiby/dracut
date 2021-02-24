#!/bin/bash
TEST_DESCRIPTION="kexec-tools test"

KVERSION=${KVERSION-$(uname -r)}

KEXEC_TOOLS_SRC="kexec-tools"
test_run() {
    # kexec-tools also use TESTDIR variable, recovert it for kexec-tools
    KEXEC_TOOLS_TESTDIR="$TESTDIR/$KEXEC_TOOLS_SRC/tests"
    make -C "$KEXEC_TOOLS_TESTDIR" TESTDIR="$KEXEC_TOOLS_TESTDIR" EXTRA_RPMS=$TESTDIR/*.rpm test-run V=$V || return 1
    return 0
}

test_setup() {
    # Buidling dracut rpm requires rpm-build
    dnf -y rpm-build
    make -C "$basedir" DESTDIR="$TESTDIR/" rpm V=$V || return 1
    # dnf would bail out when asked to install a source rpm package during kexec-tools testing
    rm -f "$TESTDIR"/*.src.rpm
    git clone --branch rawhide https://src.fedoraproject.org/rpms/kexec-tools.git "$TESTDIR/$KEXEC_TOOLS_SRC" || return 1
    # kexec-tools needs the following packages
    dnf -y install qemu wget qemu-img fedpkg dnf-utils || return 1
    yum-builddep kexec-tools || return 1
    return 0
}

test_cleanup() {
    rm -fr -- "$TESTDIR"/*.rpm
    return 0
}

. $testdir/test-functions
