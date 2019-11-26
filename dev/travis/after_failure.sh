#!/usr/bin/env bash

# Copyright © Magento, Inc. All rights reserved.
# See COPYING.txt for license details.

if [ $TEST_SUITE == 'functional' ]; then
    cat "${HOME}/selenium.log";
    cat "${TRAVIS_BUILD_DIR}/chromedriver.log";
    cat "${TRAVIS_BUILD_DIR}/magento2/var/log/debug.log";
    cat "${TRAVIS_BUILD_DIR}/magento2/var/log/system.log";
    pushd "${TRAVIS_BUILD_DIR}/magento2/dev/tests/acceptance/tests/_output";
    for screenshot in *.png;
    do
        IMAGEDATA=$(base64 $screenshot);
        curl --location --request POST "https://api.imgbb.com/1/upload?key=${IMGBB_API_KEY}" --form "image=${IMAGEDATA}"
    done
    popd
fi
