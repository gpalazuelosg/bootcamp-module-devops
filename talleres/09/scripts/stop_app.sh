#!/bin/bash
APP_ID=$(ps -C gunicorn --no-header --format 'pid' | head -1)
if [ -n "${APP_ID}" ]; then
    killall gunicorn
fi