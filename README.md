# nginx-tls-terminator

Single-purpose TLS terminating nginx proxy

Primary use case is to run as a sidecar container in kubernetes pods where the main container does not support TLS or where it's inconvenient to add it, such as for legacy apps or where the code is not under your control.

Features:
* Small single-purpose container at ~9 MB.
* Does not require to be run as root.
* Exposed TLS port as well as target upstream port configurable through environment variables.