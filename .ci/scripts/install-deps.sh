wget https://luarocks.org/releases/luarocks-3.9.1.tar.gz
tar zxpf luarocks-3.9.1.tar.gz

cd luarocks-3.9.1

./configure && make && sudo make install

sudo luarocks --version

sudo luarocks install luasocket
