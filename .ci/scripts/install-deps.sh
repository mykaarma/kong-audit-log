#!/bin/bash

wget https://luarocks.org/releases/luarocks-3.9.1.tar.gz
tar zxpf luarocks-3.9.1.tar.gz

cd luarocks-3.9.1

echo "Running configure"
export PATH=/usr/bin/lua:$PATH

./configure

echo "configured"

make

echo "ran make"

sudo make install

echo "ran make install"

sudo luarocks --version

sudo luarocks install luasocket
