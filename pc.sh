#!/bin/bash

# goreleaser calls a custom publisher for each artefact
# packagecloud expects the distro version when pushing
# this script bridges both by choosing the appropriate list of distro versions from $DEBVERS and $RPMVERS
# $REPO, $DEBVERS and $RPMVERS are expected to be set by goreleaser

REQUIRED_VARS="PACKAGECLOUD_TOKEN REPO"

usage() {
    cat <<EOF
Usage: $0 pkg_file
Required envs: ${REQUIRED_VARS[@]}
EOF
}

if [ -z $1 ]; then
    usage
    exit 1
fi

for variable in ${REQUIRED_VARS}; do
	if [[ -z "${!variable}" ]]; then
		echo "Variable: $variable - is missing"
		exit 1
	fi
done

if [[ -z "$DEBVERS" ]] && [[ -z "$RPMVERS" ]]; then
	echo "Please define at least DEBVERS or RPMVERS vars";
	exit 1
fi

pkg=$1
case $pkg in
    *PAYG*)
	echo Not uploading PAYG version $pkg
	;;
    *deb)
	vers="$DEBVERS"
	;;
    *rpm)
	vers="$RPMVERS"
    # initiate signing only if there's no sign already present. If goreleaser already did
    # the signing - there's no need to sign here. The rpm command throws an error if
    # it's already present. We're keeping this step here in case goreleaser/nfpm fails to
    # sign again as before.
    curl https://keyserver.tyk.io/tyk.io.rpm.signing.key.2020 -o tyk.pub.key && rpm --import tyk.pub.key
    if ! rpm --checksig "$pkg"
    then
        echo "No sign present in rpm package, adding sign.."
        rpm --define "%_gpg_name Team Tyk (package signing) <team@tyk.io>" \
                --define "%__gpg /usr/bin/gpg" \
                --addsign $pkg
    fi
	;;
    *)
	echo "Unknown package, not uploading"
esac

for i in $vers; do

    [[ ! -s ${pkg} ]] && echo "File is empty or does not exists" && exit 1

    # Yank packages first to enable tag re-use
    package_cloud yank $REPO/$i $(basename $pkg) || true
    package_cloud push $REPO/$i $pkg

done
