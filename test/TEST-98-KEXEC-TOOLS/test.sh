#!/bin/bash
TEST_DESCRIPTION="kexec-tools test"

KVERSION=${KVERSION-$(uname -r)}

KEXEC_TOOLS_SRC="kexec-tools"
test_run() {
    # kexec-tools also use TESTDIR variable, recovert it for kexec-tools
    KEXEC_TOOLS_TESTDIR="$TESTDIR/$KEXEC_TOOLS_SRC/tests"
    make -C "$KEXEC_TOOLS_TESTDIR" TESTDIR="$KEXEC_TOOLS_TESTDIR" DRACUT_RPMs=$TESTDIR/*.rpm test-run || return 1
    return 0
}

test_setup() {
    echo $TESTDIR > /root/ab
    make -C "$basedir" DESTDIR="$TESTDIR/" rpm || return 1
    # dnf would bail out when asked to install a source rpm package during kexec-tools testing
    rm -f "$TESTDIR"/*.src.rpm
    git clone --branch rawhide https://src.fedoraproject.org/rpms/kexec-tools.git "$TESTDIR/$KEXEC_TOOLS_SRC" || return 1
    return 0
}


test_cleanup() {
    rm -fr -- "$TESTDIR"/*.rpm
    return 0
}

. $testdir/test-functions
