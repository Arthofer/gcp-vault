#cloud-config

coreos:
  etcd2:
    # Discovery is populated by Terraform
    discovery: ${etcd_discovery_url}
    # $public_ipv4 and $private_ipv4 are populated by the cloud provider
    # for vault, we only allows internal etcd clients
    advertise-client-urls: http://$private_ipv4:2379
    initial-advertise-peer-urls: http://$private_ipv4:2380
    listen-client-urls: http://0.0.0.0:2379
    listen-peer-urls: http://$private_ipv4:2380
  units:
    - name: etcd2.service
      command: start
    - name: install-vault.service
      command: start
      enable: true
      content: |
        [Unit]
        Description=Install Vault
        [Service]
        Type=oneshot
        RemainAfterExit=true
        ExecStart=/bin/bash -c "[ -x /opt/bin/vault ] || \
          (mkdir -p /opt/bin; cd /tmp;  \
          curl -s -L -O ${vault_release_url} \
          && unzip -o $(basename ${vault_release_url}) -d /opt/bin/ \
          && chmod 755 /opt/bin/vault \
          && rm $(basename ${vault_release_url}))"
    - name: vault.service
      command: start
      enable: true
      content: |
        [Unit]
        Description=vault
        Wants=install-vault.service
        After=install-vault.service
        [Service]
        ExecStart=/opt/bin/vault server -config /var/lib/apps/vault/vault.hcl
        RestartSec=5
        Restart=always

write_files:
  - path: /var/lib/apps/vault/vault.hcl
    permissions: 0644
    owner: root
    content: |
      backend "etcd" {
        address = "http://127.0.0.1:2379"
        advertise_addr = "http://127.0.0.1:2379"
        path = "vault"
        sync = "yes"
      }
      listener "tcp" {
        address = "127.0.0.1:8200"
        tls_disable = 0
        tls_cert_file = "/var/lib/apps/certs/vault.crt"
        tls_key_file = "/var/lib/apps/certs/vault.key"
      }
      /* Need to install statesite for this to work 
      telemetry {
        statsite_address = "127.0.0.1:8125"
        disable_hostname = true
      }
      */
  - path: /var/lib/apps/certs/vault.crt
    permissions: 0644
    owner: root
    content: |
      -----BEGIN CERTIFICATE-----
      MIIDlDCCAnygAwIBAgIJALhWq59GXtSiMA0GCSqGSIb3DQEBBQUAMIGuMQswCQYD
      VQQGEwJVUzELMAkGA1UECAwCQ0ExFjAUBgNVBAcMDUhhbGYgTW9vbiBCYXkxDjAM
      BgNVBBEMBTk0MDE5MRIwEAYDVQQKDAlEb2NrZXJhZ2UxFjAUBgNVBAsMDUlUIERl
      cGFydG1lbnQxGDAWBgNVBAMMD2NhLmRvY2tlci5sb2NhbDEkMCIGCSqGSIb3DQEJ
      ARYVYWRtaW5AY2EuZG9ja2VyLmxvY2FsMB4XDTE2MDMwMTA2NDM1NloXDTQzMDcx
      NzA2NDM1NlowHTEbMBkGA1UEAwwSdmF1bHQuZG9ja2VyLmxvY2FsMIIBIjANBgkq
      hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtSzeYF/PZFXjLOwQpBy5DgbJs8vOmcQR
      Jh3uVXGnUZr1FdZzivhn6QmJcICHVUrVLGsI/IjPaMvX5gZWmdFGYbBuewtECMaV
      zvA880KsJEO4A8FQqCHYOIDAwqbk4lO0fqQE2COQzTLMOP8Q+X9idIY50+tfFSoh
      qKzJ7JukAkurkGlT4M8WI7pJmCqXOUQG97awrKXITvQwiFqYU9k/I1OJqNnGdpfN
      ODTSCcxm+0yhH0gChA752mrINyPyd4vXr346TWjD4rZZqgIddSq6UJA+fSj1bvfN
      1df2E1R2D+UzTrMNY+8mLOBPoMR8zKMBLeOeG9GlL4GAujP4LxA59wIDAQABo0Uw
      QzALBgNVHQ8EBAMCBLAwEwYDVR0lBAwwCgYIKwYBBQUHAwEwHwYDVR0RBBgwFoIO
      Ki5kb2NrZXIubG9jYWyHBH8AAAEwDQYJKoZIhvcNAQEFBQADggEBADh+D1+uJjrk
      Co3kvIDME+HuvYnTGTVxsI7QVKOeSSkuYl5O4gEv3737M5h50NPwHev/UUmqd8BY
      kEFTt/UE/jtZX/dJDsn9gN3m6B1U1SDOKoH1gYPj+71CkXp0/Q+JsvXfRI6VgHXj
      Av8CWMfJ5raTn21/Zc01bhyvOzkebjlJgEX3cJSt1ODHMPAZ051QmCNzDi7r7yFp
      qB1h9AVwSE/+clWAsY9iqHbN7/lCSzILmpXX7aYXq0JHJRtp4vC4N0enaxa8hGcy
      68EDRoreaGoRJTl76WrnPH2DAwHcJbY1xvtRA4ISG1CHpSckDPS6dR0n4deKaF4+
      mmLxwAQXtDI=
      -----END CERTIFICATE-----
  - path: /var/lib/apps/certs/vault.key
    permissions: 0600
    owner: root
    content: |
      -----BEGIN RSA PRIVATE KEY-----
      MIIEpAIBAAKCAQEAtSzeYF/PZFXjLOwQpBy5DgbJs8vOmcQRJh3uVXGnUZr1FdZz
      ivhn6QmJcICHVUrVLGsI/IjPaMvX5gZWmdFGYbBuewtECMaVzvA880KsJEO4A8FQ
      qCHYOIDAwqbk4lO0fqQE2COQzTLMOP8Q+X9idIY50+tfFSohqKzJ7JukAkurkGlT
      4M8WI7pJmCqXOUQG97awrKXITvQwiFqYU9k/I1OJqNnGdpfNODTSCcxm+0yhH0gC
      hA752mrINyPyd4vXr346TWjD4rZZqgIddSq6UJA+fSj1bvfN1df2E1R2D+UzTrMN
      Y+8mLOBPoMR8zKMBLeOeG9GlL4GAujP4LxA59wIDAQABAoIBAQCFa/iMEqLBajq1
      j1cl9H0XZkpOHS4VsP1MC8jDpcIpZ6tLnLVUR2EGjd5oOk7vsf9RCbYBe6L6svtY
      y5wlBKgHMw35kS9WIyCZ1/Oa1aO9xR0Trt5+IwZ/fdn2vz9ZqXkHtjRXE8IES394
      DebrRjM0StD1TqWkCXXmKPE/TNM4WFJZIJy/XQRgjMJwqz/O3pQX88pyoM9b9eXA
      Bib44hq76axpKzpTn9Nw1n9hui0aYlwOuhc7obCtYWATSpSz0R1qUz8iAZVdqioN
      fx7VR5VbiSpxTHTsxYuLYjuvbrIEz89xW8LGE1Rk+PRYRqpjm/ubre5w+vfqVeUw
      h97xSZ1hAoGBANhLQle9nR4N7GNzyb0KnwKLNLWcWDrlLXmY8e5a27y2Gc+IQnQn
      76bzzPI+SKUwGg3SyhI9blaxvctHJiOe8XCAnh9WQg+TSpaEwcUyiEM+jNPs0QW1
      Kxns6uzGIO+dqr/evC9ksspWjdhYmGiu1yxhpnyPIgXpxqVOOK0OJBDxAoGBANZv
      NGp+Mk38HW/DsZi+J6arBkRgiLHwilvcfTEGQtqvL+8EW78iwKkA2zAYWsxfbv0a
      RTRN/CPBV8yNvgTUsz3huKZVc7cOeP95CAhrFTFvbeu7INb8RopJonKDd50b0T6j
      RCI/eE4brylkjiaonht2jP3TZSPgpb5LNiWrQ/lnAoGBAIhXEE+8f3C1eB/Mmgsm
      ycrRsv0Tu24MjpjKtx33efG/nA98pd8QWXmUzsiYSDSQWKwEBkpvHMFbMvcTN1BW
      3Xx8JrA8MFIfF3I/5uEGFGzG3gCsk6mUZMHn3MI5tgM1EK/3mAoL4MO4wZrxZcj/
      BTW9rDNyChFOJmCHKSS0+DkRAoGAJApmzetN+yt/qxRCGkEDmxCtqfprnzSlnJDv
      fbjmrai6LrsVzIdDyGP7cxb009rKZcHvlb3xvfS2FAxSvq8dPS5eAZ7lJwRIs++c
      uQV+d2OaHv/BokCefomnwwVzqjVNsvBv+C2gw8gFZbif58F5aXZAdjz8h84vLU+o
      1yX088sCgYATBclNqYNdFrvxb3W1TgvtfQOLdIwu/NvU+vi3AOCWPHoy0AuG9cBK
      W5a7Uq5UEws0XHJOY9I6GVQHpVVi3u9dgfF+iQzCrd/OYeVzhQ3WkvO/eay83HGl
      zZbd6aNu+FEkQMBvnvNRDLEGISbFBuq4/TMcATVroOyStzjnYQa1iQ==
      -----END RSA PRIVATE KEY-----
  - path: /var/lib/apps/certs/ca.pem
    permissions: 0644
    owner: root
    content: |
      -----BEGIN CERTIFICATE-----
      MIID2jCCAsICCQDFuc3c4hwfyjANBgkqhkiG9w0BAQ0FADCBrjELMAkGA1UEBhMC
      VVMxCzAJBgNVBAgMAkNBMRYwFAYDVQQHDA1IYWxmIE1vb24gQmF5MQ4wDAYDVQQR
      DAU5NDAxOTESMBAGA1UECgwJRG9ja2VyYWdlMRYwFAYDVQQLDA1JVCBEZXBhcnRt
      ZW50MRgwFgYDVQQDDA9jYS5kb2NrZXIubG9jYWwxJDAiBgkqhkiG9w0BCQEWFWFk
      bWluQGNhLmRvY2tlci5sb2NhbDAeFw0xNjAzMDEwNjQzNTVaFw00MzA3MTcwNjQz
      NTVaMIGuMQswCQYDVQQGEwJVUzELMAkGA1UECAwCQ0ExFjAUBgNVBAcMDUhhbGYg
      TW9vbiBCYXkxDjAMBgNVBBEMBTk0MDE5MRIwEAYDVQQKDAlEb2NrZXJhZ2UxFjAU
      BgNVBAsMDUlUIERlcGFydG1lbnQxGDAWBgNVBAMMD2NhLmRvY2tlci5sb2NhbDEk
      MCIGCSqGSIb3DQEJARYVYWRtaW5AY2EuZG9ja2VyLmxvY2FsMIIBIjANBgkqhkiG
      9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnBnvGi9GoysVZHhbHh1aEQbO8g7EqkiElDQz
      RmLT7UZh3FaoSgdWKYdu1C8779trwzjPltjthxmrGuFIjPXZ3gBe3k6s/etf9na+
      QFa0lXmKmUX3LJAnwupmfC+fDFnVVN3beol8lW35eV/KGh8SXrbHrHpadcNdQURy
      /MnavNQXSFxcW8vyUUlkoaI8qIeKu/70wv98Nfb0I8HMDmuaJjqBaOXevD4CBUFr
      vrEQKWCF2DHomjDsCaQjxyoXAd85Ow8ZLxi6j4JmL2bFhR2bCfO0O8cpCHoU/W5g
      dZhgjbld/TdcMagOd409krolG69ReR4uibju1/xlsMtvdCnaFQIDAQABMA0GCSqG
      SIb3DQEBDQUAA4IBAQA6nkGIotTMZVZNiL3I9ZqGpSvN9AzENRt2ZvvJ9T2CGNX6
      e8H8H8lD/AAfGdiitYxSgTL47dYhQ3MgECSRqX7jEeW3wHxhTTxVuFUu2PNXUCio
      vbIm9kKqxspKSTN//BKDCAwHFUqYGiS8cw15HobpCnav9zmT7edRvdOEptM4VRJd
      2hIBkPEAW4OAF2D59Y6sZxHuUorkLhTRqOutl6h7sPbdUQeIfOqHMaX6T2xl6VtJ
      3I+Yza5TkVCPck88Q2PCECaXRSDN8UR5xTtXVBL1ikwdMsyEv7aD2ZzsET+djyZc
      jsZnSW1rVS7qOLwmOmOH2LMxknD0AOobvGkugZTA
      -----END CERTIFICATE-----
  - path: /etc/profile.d/path.sh
    content: |
        export VAULT_CACERT=/var/lib/apps/certs/ca.pem
        #export VAULT_ADDR=<vault-service-endpoint-ip>
        #export VAULT_CLIENT_CERT=/var/lib/apps/certs/client.crt
        #export VAULT_CLIENT_KEY=/var/lib/apps/certs/client.key
  - path: /etc/profile.d/alias.sh
    content: |
        alias lal="ls -al"
        alias ll="ls -l"
        alias sd="sudo systemctl"
        alias sdl="sd list-units"
        alias sds="sd status"
        alias sdcat="sd cat"\
        alias j="journalctl"
        alias jfu="journalctl -f -u"
        alias e="etcdctl"
        alias els="e ls --recursive"
        alias eget="e get"
        alias eset="e set"
# end of files
        




