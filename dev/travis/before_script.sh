#!/usr/bin/env bash

# Copyright © Magento, Inc. All rights reserved.
# See COPYING.txt for license details.

set -e
trap '>&2 echo Error: Command \`$BASH_COMMAND\` on line $LINENO failed with exit code $?' ERR

# prepare for test suite
pushd magento2
if [[ ${TEST_SUITE} = "unit" ]]; then
    echo "Prepare unit tests for runining"
    composer require "mustache/mustache":"~2.5"
    composer require "php-coveralls/php-coveralls":"^1.0"
fi

if [[ ${TEST_SUITE} = "functional" ]]; then
    echo "Installing Magento"
    # TODO: add secure https flags here once ready
    php bin/magento setup:install \
        --language="en_US" \
        --timezone="UTC" \
        --currency="USD" \
        --base-url="${MAGENTO_PROTOCOL}://${MAGENTO_HOST_NAME}/" \
        --admin-firstname="John" \
        --admin-lastname="Doe" \
        --backend-frontname="backend" \
        --admin-email="admin@example.com" \
        --admin-user="${MAGENTO_ADMIN_USERNAME}" \
        --use-rewrites=1 \
        --db-host=127.0.0.1 \
        --db-name=magento2 \
        --db-user=root \
        --cleanup-database \
        --admin-use-security-key=0 \
        --admin-password="${MAGENTO_ADMIN_PASSWORD}"
    echo "Enabling production mode"
    php bin/magento deploy:mode:set production
    # TODO: prepare magento instance as per getting started docs?
    # https://devdocs.magento.com/mftf/docs/getting-started.html#prepare-magento

    echo "Prepare functional tests for running"

    composer require se/selenium-server-standalone:2.53.1
    export DISPLAY=:1.0

    pushd dev/tests/acceptance

    cp ./.htaccess.sample ./.htaccess
    cp -f ${TRAVIS_BUILD_DIR}/dev/tests/acceptance/.env .env
    sed -e "s?%ADOBE_STOCK_API_KEY%?${ADOBE_STOCK_API_KEY}?g" --in-place ./.env
    sed -e "s?%ADOBE_STOCK_PRIVATE_KEY%?${ADOBE_STOCK_PRIVATE_KEY}?g" --in-place ./.env
    sed -e "s?%ADOBE_STOCK_USER_EMAIL%?${ADOBE_STOCK_USER_EMAIL}?g" --in-place ./.env
    sed -e "s?%ADOBE_STOCK_USER_PASSWORD%?${ADOBE_STOCK_USER_PASSWORD}?g" --in-place ./.env
    sed -e "s?%MAGENTO_PROTOCOL%?${MAGENTO_PROTOCOL}?g" --in-place ./.env
    sed -e "s?%MAGENTO_HOST_NAME%?${MAGENTO_HOST_NAME}?g" --in-place ./.env
    sed -e "s?%MAGENTO_ADMIN_USERNAME%?${MAGENTO_ADMIN_USERNAME}?g" --in-place ./.env
    sed -e "s?%MAGENTO_ADMIN_PASSWORD%?${MAGENTO_ADMIN_PASSWORD}?g" --in-place ./.env
    popd

    # prepare mftf test files
    mftf build:project
    mftf generate:tests

    # run selenium
    # TODO: we should find different browsers here and possibly enable in a
    # travis matrix, for example:
    # headless chrome: https://docs.travis-ci.com/user/gui-and-headless-browsers/#using-the-chrome-addon-in-the-headless-mode
    # headless firefox: https://docs.travis-ci.com/user/gui-and-headless-browsers/#using-the-firefox-addon-in-headless-mode
    sh ./vendor/se/selenium-server-standalone/bin/selenium-server-standalone -port 4444 -host 127.0.0.1 \
        -Dwebdriver.firefox.bin=$(which firefox) -trustAllSSLCertificate &> ~/selenium.log &
fi
popd
