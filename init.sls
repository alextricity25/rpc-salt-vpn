##Setting Jijna variables
{%- set ipsec_running = salt['cmd.retcode']('ipsec status') -%}

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

#Installing strongswan 5.2.2 from source
Run strongswan installation script:
    cmd.script:
        - source: salt://rpc-salt-vpn/scripts/install-strongswan.sh
        - timeout: 400
        - unless: test -x /usr/bin/ipsec
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
        {% if ipsec_running == 0 %}
        - name: ipsec reload && ipsec rereadsecrets
        {% else %}
        - name: ipsec restart
        {% endif %}
        - require:
            - file: /etc/strongswan.conf
            - file: /etc/ipsec.secrets
            - file: /etc/ipsec.conf



