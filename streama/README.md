# Streama

[Streama](https://docs.streama-project.com) is a self-hosted streaming media server which provides a modern UI, authentication and many functionalities such as subtitles and trailers just like Netflix.

## About Streama

This chart installs the full Streama application on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

It includes the [Bitnami MySQL chart](https://artifacthub.io/packages/helm/bitnami/mysql) which is required to bootstrap a MySQL deployment for the database requirements of the Streama application.


## Prerequisites

* Kubernetes [1.22+](https://kubernetes.io/releases/)
* [Persistant Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) provisioner support in the underlying infrastructure


## Usage

This chart expects to be managed as a standard [Helm chart](https://helm.sh/docs/topics/charts/). All the commands from the [Helm CLI](https://helm.sh/docs/helm/) apply.

See [the official Helm CLI documentation](https://helm.sh/docs/helm/) for commands description.


## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments:

```bash
helm show values .
```

Values definition are also available in the [values.schema.json](./values.schema.json) file.

### Database

The `mysql` parameters maps to [MySQL sub-chart](https://artifacthub.io/packages/helm/bitnami/mysql) parameters. For more information please refer to the [MySQL parameters](https://artifacthub.io/packages/helm/bitnami/mysql#parameters) documentation.

If you wish to use an external database instead of the one that is automatically install in the sub-chart, set the `mysql.enabled` value to `false` and link Streama with your database by defining the `externalDatabase` value.

### Persistence

The Streama application needs persistent storage to store media data. You can create a [Persistent Volume Claim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims) with this chart or use an already existing PVC by configuring the `persistence` value.

Although it is possible to disable persistence by setting the `persistence.enabled` value to `false`, it is not recommended to do this in production.

### Ingress

This chart provides support for ingress resources. You may enable it by setting the `ingress.enabled` value to `true`. In that case you must set the `ingress.host` value and make a corresponding DNS record point to the Ingress load balancing IP.

It is recommended to use [nginx-ingress](https://artifacthub.io/packages/helm/nginx/nginx-ingress) as Ingress Controller to serve your Streama application given that it provides cookie-session-affinity which is essential to make Streama work with several replicas.
