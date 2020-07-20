# nginx-tls-terminator

![build](https://github.com/anderseknert/nginx-tls-terminator/workflows/build/badge.svg)

Single-purpose TLS terminating nginx proxy.

Primary function is to run as a sidecar container in kubernetes pods where the app running in the main container either does not support TLS, or it's inconvenient to add it - such as for legacy apps or where the code is not under your control. Another common use case is when external traffic has TLS terminated by the ingress controller but some internal services need to reach the same services from the inside on the same URL. One example of this is the issuer URL provided in OAuth2 and OpenID Connect, where both external and internal applications will need to query the same endpoints over a secure channel.

Features:
* Small single-purpose container at ~9 MB with minimal configuration needed.
* Does not require root privileges and runs as non-root user by default. Runs with strictest `securityContext` configured on container.
* Exposed TLS port as well as target upstream port configurable through environment variables.

## Usage instructions

### Obtaining a certificate

The first step to enable TLS for your service is to obtain a certificate. This can be done in a number of ways, such as:

* Using an established certificate authority, such as [Let's Encrypt](https://letsencrypt.org/).
* Generating a self-signed certificate (for testing).

More info on obtaining a certificate for use in kubernetes can be found in the [kubernetes docs](https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/).

### Storing the certificate

Once a certificate has been obtained, you'll need to store it somewhere where the nginx-tls-terminatr can find it - normally a [kubernetes secret](https://kubernetes.io/docs/concepts/configuration/secret/). The secret consists of the certificate (`tls.crt`) and a signing key (`tls.key`) and is easily created with kubectl.

```shell
kubectl create secret tls tls-terminator-cert \
        --cert=path/to/cert/tls.crt \
        --key=path/to/cert/tls.key
```

### Adding the nginx-tls-terminator sidecar container

We'll now need to edit the deployment responsible for the pod you'll want to patch with TLS terminating capabilities. Given an example deployment like this:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-awesome-app
  labels:
    app: my-awesome-app
spec:
  selector:
    matchLabels:
      app: my-awesome-app
  template:
    metadata:
      labels:
        app: my-awesome-app
    spec:
      containers:
      - name: my-awesome-app-container
        image: my-awesome-app:1.2.3
        ports:
        - containerPort: 80
```

We will patch the pod spec to both mount the secret we created and of course inject our TLS terminating sidecar container. First, let's add the secret to our pod spec (under `spec.template.spec`):

```yaml
volumes:
- name: tls-terminator-cert
  secret:
    secretName: tls-terminator-cert
```
Then, add the nginx-tls-terminator sidecar container mounting the secret volume created above (under `spec.template.spec.containers`):

```yaml
- name: nginx-tls-terminator
  image: eknert/nginx-tls-terminator:0.2.0
  ports:
  - containerPort: 8443
  volumeMounts:
  - mountPath: "/etc/nginx/ssl"
    name: tls-terminator-cert
    readOnly: true
  securityContext:
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    runAsUser: 2000
    runAsGroup: 2000
```

### Configuring service

The TLS terminating sidecar container should now be up and running, proxying TLS encrypted requests on port 8443 to port 80 on the main container. As the pods are normally exposed through a kubernetes service, we'll need to make it route traffic to our sidecar container for TLS traffic. Given an existing service looking something like this:

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: my-awesome-app
spec:
  clusterIP: 10.108.119.63
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: my-awesome-app
```

All we'll need to do is to add handling to the port we configured for our sidecar (8443) - we'll also normally want to expose this on the regular HTTPS port, 443:

```yaml
- name: https
  port: 443
  protocol: TCP
  targetPort: 8443
```

### Kustomize

TBD
