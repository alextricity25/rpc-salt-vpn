##Enable IPv4 forwarding
net.ipv4.ip_forward:
    sysctl.present:
        - value: 1

##Do update then install curl
curl:
    pkg.installed:
        - refresh: True

##Install packages to build strongswan 5.2.2 from source
strongswan-pkgs:
    pkg.installed:
        - names:
            - build-essential
            - libcurl4-openssl-dev
            - libldap2-dev
            - libsoup2.4-dev
            - libtspi-dev
            - libjson-c-dev
            - libmysqlclient15-dev
            - libsqlite3-dev
            - libpcsclite-dev
            - libnm-util-dev
            - libnm-glib-dev
            - libnm-glib-vpn-dev
            - network-manager-dev
            - libpam0g-dev
            - libcap-dev
            - libgmp-dev
        - require:
            - pkg: curl

##Getting strongswan 5.2.2 from source
install-strongswan-5.2.2:
    cmd.run:
        - name: | 
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
        - cwd: /tmp
        - shell: /bin/bash
        - timeout: 400
        - unless: test -x /usr/local/bin/ipsec
        - require:
            - pkg: strongswan-pkgs

##Configuring ipsec.conf
/etc/ipsec.conf:
    file.managed:
        - source: salt://rpc-salt-vpn/config/ipsec.conf 
        - group: root
        - mode: 644
        - template: jinja
        - require:
            - pkg: strongswan-pkgs
        
##Configuring strongswan.conf
/etc/strongswan.conf:
    file.managed:
        - source: salt://rpc-salt-vpn/config/strongswan.conf 
        - group: root
        - mode: 644
        - template: jinja
        - require:
            - pkg: strongswan-pkgs

##Configuring ipsec.secrets
/etc/ipsec.secrets:
    file.managed:
        - source: salt://rpc-salt-vpn/config/ipsec.secrets
        - group: root
        - mode: 644
        - template: jinja
        - require:
            - pkg: strongswan-pkgs

restart-ipsec:
    cmd.run:
        - name: ipsec restart
        - require:
            - file: /etc/strongswan.conf
            - file: /etc/ipsec.secrets
            - file: /etc/ipsec.conf



