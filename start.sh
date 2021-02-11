#!/bin/sh -e

 # create user to run app
if ! id app >/dev/null 2>&1; then
  addgroup -g "$OWNER_GID" app
  adduser -D -h /var/www/html -G app -u "$OWNER_UID" app
fi

DST_DIR="/var/www/html/dokuwiki"
SRC_REPO="https://github.com/splitbrain/dokuwiki.git"
SRC_BRANCH="stable"

if [ ! -d "$DST_DIR/.git" ]; then
  mkdir -p "$DST_DIR"
  echo "cloning dokuwiki source from $SRC_REPO to $DST_DIR ..."
  git clone -b "$SRC_BRANCH" "$SRC_REPO" "$DST_DIR" ||
    echo "error: failed to clone"
else
  echo "updating dokuwoki source from $SRC_BRANCH to $DST_DIR ..."
  cd "$DST_DIR" && \
    git config core.filemode false && \
    git config pull.rebase false && \
    git checkout "$SRC_BRANCH" && \
    git pull origin "$SRC_BRANCH" || echo "error: unable to update"
fi

# change permissions
chown -R app:app "$DST_DIR"
chmod g+w /dev/fd/? || true
chgrp app /dev/fd/? || true

cd "$DST_DIR"
su-exec app:app env php-fpm -F
