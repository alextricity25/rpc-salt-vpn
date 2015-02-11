##Enable IPv4 forwarding
net.ipv4.ip_forward:
    sysctl.present:
        - value: 1

##Install packages 
strongswan-pkgs:
    pkg.installed:
        - names:
            - strongswan
            - strongswan-plugin-xauth-generic
            - strongswan-plugin-unity



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

strongswan-stop:
    service:
        - name: strongwan
        - dead

strongswan:
    service.running:
        - enable: True
        - reload: True


