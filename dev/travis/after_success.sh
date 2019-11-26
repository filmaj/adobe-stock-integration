#!/usr/bin/env bash

# Copyright © Magento, Inc. All rights reserved.
# See COPYING.txt for license details.

if [ $TEST_SUITE == 'unit' ]; then
    travis_retry coveralls;
fi
