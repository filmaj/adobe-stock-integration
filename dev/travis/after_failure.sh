#!/usr/bin/env bash

# Copyright © Magento, Inc. All rights reserved.
# See COPYING.txt for license details.

if [ "$TEST_SUITE" == 'functional' ]; then
    cat "${HOME}/selenium.log"
    cat "${TRAVIS_BUILD_DIR}/chromedriver.log"
    cat "${TRAVIS_BUILD_DIR}/magento2/var/log/debug.log"
    cat "${TRAVIS_BUILD_DIR}/magento2/var/log/system.log"
    pushd "${TRAVIS_BUILD_DIR}/magento2/dev/tests/acceptance/tests/_output"
    set +x
    for screenshot in *.png;
    do
        echo "Converting and uploading ${screenshot}..."
        IMAGEDATA=$(base64 "$screenshot")
        echo "Base64-encoded image data size:";
        echo "$IMAGEDATA" | wc -c
        curl --location --request POST --form "image=${IMAGEDATA}" "https://api.imgbb.com/1/upload?key=${IMGBB_API_KEY}"
    done
    set -x
    popd
fi
