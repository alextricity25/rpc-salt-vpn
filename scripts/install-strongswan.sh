cd /tmp
wget http://download.strongswan.org/strongswan-5.2.2.tar.gz
tar xzf strongswan-5.2.2.tar.gz
cd strongswan-5.2.2
./configure --prefix=/usr \
--sbindir=/usr/bin \
--sysconfdir=/etc \
--libexecdir=/usr/lib \
--with-ipsecdir=/usr/lib/strongswan \
--enable-sqlite \
--enable-openssl --enable-curl \
--enable-sql --enable-attr-sql \
--enable-farp --enable-dhcp \
--enable-eap-sim --enable-eap-sim-file --enable-eap-simaka-pseudonym \
--enable-eap-simaka-reauth --enable-eap-identity --enable-eap-md5 \
--enable-eap-gtc --enable-eap-aka --enable-eap-aka-3gpp2 \
--enable-eap-mschapv2 --enable-eap-radius --enable-xauth-eap \
--enable-ha --enable-gcm --enable-ccm --enable-ctr --enable-unity \
--enable-integrity-test --enable-load-tester --enable-test-vectors \
--enable-af-alg --disable-ldap \
--with-capabilities=libcap --enable-cmd --enable-ntru \
--enable-vici --enable-swanctl --enable-ext-auth --enable-xauth-noauth
make
make install
exit 0