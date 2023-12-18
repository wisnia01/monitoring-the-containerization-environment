# Introduction
The goal of this project is to show different conceptions regarding: 
- Monitoring and observability, especially of Kubernetes environments
- The Four Golden Signals of monitoring and The Three Pillars of observability
- Metrics - WIKTOR I OLA OPISZCIE
- Collecting and agregating logs using EFK stack - Elasticsearch, Fluentd, Kibana. 
- Instrumenting applications with OpenTelemetry, collecting traces with it and analyzing them in Jaeger


# Kubernetes - theoretical introduction

Kubernetes is a powerful open-source platform for automating the deployment, scaling, and management of containerized applications. Born out of the need to efficiently manage container-based workloads at scale, Kubernetes provides a robust framework for orchestrating and coordinating the deployment of applications encapsulated in containers. It allows us to create certain objects with different kinds like `Pods`, `Deployments`, `Services` or `Autoscalers`

`Pods` in Kubernetes are the smallest deployable units, representing one or more containers that share the same network namespace, storage, and IP address. They serve as the basic building blocks for applications, allowing for efficient deployment, scaling, and management within the Kubernetes ecosystem.

`Deployments` in Kubernetes are resources that manage the deployment and scaling of applications. They use replica sets to maintain a specified number of `pod` replicas, supporting rolling updates and rollbacks for seamless application changes. Deployments provide a declarative configuration for easy management of the application's lifecycle, including scaling and updates.

`Services` in Kubernetes provide a stable endpoint to enable communication between pods. Acting as an abstraction layer, services helps with the discovery and load balancing of pods, ensuring seamless communication within a cluster.

`Daemonset` is a resource that ensures a copy of a specific pod runs on each node within a cluster, providing a way to run a specific workload on every node. It is often used for system-level tasks, monitoring agents, or other scenarios where each node in the cluster requires a dedicated instance of the pod.

`Statefulset` is a resource used for managing stateful applications, providing stable network identities and persistent storage for each pod. It ensures that each pod in the set maintains a unique and predictable identity, making it suitable for applications that require ordered deployment, scaling, and termination.

To fully demonstrate all mentioned possibilities of collecting and showing logs, traces and metrics we decided to run our applications on `minikube`.

`Minikube` is an open-source tool for running Kubernetes clusters locally on a single machine. It supports cross-platform use and easy installation via popular package managers or direct downloads. Minikube integrates with hypervisors (e.g., VirtualBox, Hyper-V) or can run Kubernetes nodes as containers using Docker.

To start a local Kubernetes cluster with one node we run a command:
```
minikube start
```

# Monitoring - theoretical introduction

## Why do we need monitoring and observability

Monitoring, including observability, helps analyze and understand systems in real-time. It provides reports and insights for effective management, quick response to issues, and improved performance and reliability. This continuous oversight ensures a proactive approach to addressing problems, making the system more robust and efficient.

## What is monitoring?

Monitoring is the process of collecting, analyzing, and utilizing information about a system. It is often mistakenly thought that monitoring solely focuses on observing metrics, especially the so-called "four golden signals", but it is a much more complex process. Nonetheless, the four golden signals remain important components of monitoring and we will use them in our project. 

### Golden signals

The four golden signals are given:

1. Latency: The time it takes to fulfill a request.
2. Traffic: An indication of the demand on your system, usually measured as specific to your system's overall activity. For a web service, this is commonly counted as HTTP requests per second.
3. Errors: The frequency of unsuccessful requests.
4. Saturation: How occupied your service is. It gauges your system's capacity, highlighting the resources under the most strain (e.g., in a system with limited memory, it reflects memory usage; in a system constrained by I/O, it reflects I/O).

## What is observability?

Observability is the ability to understand the internal state of a system through the analysis of data it generates, such as logs, metrics, and traces. Observability helps analyze what is happening in the environment, allowing for the detection and resolution of encountered issues.

Keep in mind that observability, which is kind of a buzzword, is only an ability and can be included in the monitoring process, not the other way around. It's a common misconception popularized by companies that profit from observability solutions.

### Observability pillars

We can differentiate three main observability categories, often reffered to as the observability pillars:

1. Metrics - in this context, metrics refer to collections of measurements taken over time, and they come in various types:
- Gauge metrics: These measure a specific value at a particular moment, like the CPU utilization rate at the time of assessment.
- Delta metrics: These track variances between past and present measurements, indicating changes in metrics like throughput since the last measurement.
- Cumulative metrics: These record changes over an extended period, such as the cumulative count of errors returned by an API function call over the past hour.

2. Logs - Logs hold system and application details, revealing the inputs and outputs of operations and control flow. They document events like process starts, error handling, or task completions, all with a specific structure including timestamps and description of what happened. It allows logs to offer crucial insights into the system, shedding light on contributing factors and operational impact.

3. Traces - Distributed traces are the third pillar of observability, specifically designed for distributed microservices-based applications. An application may depend on multiple services, each having its own set of metrics and logs. Distributed tracing allows us to "follow" through various services that interact with each other within a request and visualize the dependencies between them.

We will 

# Architecture

To implement mentioned in the previous section observability pillars, a number of applications were deployed on the kubernetes cluster. The architecture of this solution is shown in the diagram below.

![Architecture](images/architecture.png "Architecture")

All resources are divided into 4 different namespaces. Namespaces components and functions are described below.

## streaming-server
In this namespace there are 3 deployments with their corresponding services:
- **streaming server** - contains a video streaming application. The application also contains a field for typing and calculating the fibonacci number. It sends the number to the fibonacci deployment through its service and receives the result from this service.
- **fibonacci** - receives the number to be calculated from the streaming server and sends it to the number verifier via its service and, depending on the response, calculates the given Fibonacci sequence number or returns information to the streaming server that it can’t make calculations,
- **number verifier** - checks the number sent by fibonacci and sends it back to him via his service.

## monitoring-traces

There is only one deployment named Jaeger with its service that provides 2 ports. The first port is used to communicate with applications from which traces are collected and the second port is used for user interactions.

## monitoring-logs

In this namespace there are below resources:
- **config map** - contains the configuration, which is read by the fluentd instance of systemd logs,
deamonset fluentd systemd logs - contains the fluentd application that reads the configuration from the config map and is used to read logs from the cluster node and then sends them to statefulset Elasticsearch via its service,
- **fluentd k8s logs** - is a deamonset that collects logs from the kubernetes cluster and sends them to statefulset Elasticsearch via its service,
- **Elasticsearch** - statefulset, which receives data from both fluentd instances, saves it and sends it to deployment Kibana via its service,
- **Kibana** - deployment that receives data from Elasticsearch and visualizes it.

## monitoring-metrics

This namespace contains the following components:
- **kube-state-metrics** - deployment, which collects metrics from the entire kubernetes cluster and makes them available in one place. It sends them to statefulset Prometheus via its service.
- **Prometheus** - statefulset, which receives metrics from kube-state-metrics and saves them in  the Time Series Database. The data available to the Prometheus operator and Grafana is sent through their services.
- **Prometheus operator** - deployment that is used to operate Prometheus by the user and can influence the configuration of Prometheus. It can also read the stored data.
- **Grafana** - deployment, which receives data from Prometheus and visualizes it in the form of dashboards. Its service provides a port for the user to operate Grafana.

# Metrics

Metrics are statistics about a cluster and its resources such as nodes, deployments and others. They are used to analyze the performance of a containerized environment that runs multiple containers with applications inside. They make it possible to determine the potential cause of application errors and problems with the operation and performance of the cluster or its individual nodes. In order to determine the parameters regarding the performance of this environment, it is necessary to monitor the metrics. For this purpose, there were used kube-state-metrics, Prometheus and Grafana.

## Tools

### kube-state-metrics

Kube-state-metrics (KSM) is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects. It is focused on the health of the various objects inside, such as deployments, nodes and pods. This tool talks with Kubernetes clusters using client-go. It takes a snapshot of the entire Kuberentes state, uses that in-memory state to generate metrics and then serves them as plaintext on the /metrics endpoint and default port 8080. Kube-state-metrics gets raw data directly from the Kubernetes API and does not apply any modifications to the data it exposes. 

### Prometheus

Prometheus collects and stores metrics received from kube-state-metrics as time series data. Data is identified by metric name and key/value pairs. It is possible to create a query to the database using PromQL. It can be also available via web browser.

### Grafana

Grafana is a tool, which allows preparing data visualizations based on entries received from the time series prometheus database. Metrics associated with the same topic can be grouped in one dashboard. From a wide range of possible chart types, there can be chosen the most appropriate type for a certain metric. Dashboard configuration with metrics visualizations can be converted into JSON file and then imported to another instance of Grafana.

## Measured metrics

Metrics relate to various cluster resources. Therefore, in order to make an accurate analysis of the metrics, it is necessary to distinguish them and divide them into appropriate groups, which are called layers. This makes it possible to track down problems concerning a particular group, such as a specific node, which would be unnoticeable by analyzing only metrics concerning the cluster as a whole.

### Cluster layer

The cluster metrics layer provides general information about the cluster, its nodes, applications running on it and available resources of the entire cluster. The examined metrics are:
- `kube_node_status_condition` - metric determining nodes availability in the cluster,
- `kube_deployment_status_replicas_unavailable` and `kube_statefulset_status_replicas_unavailable` - metrics specifying the number of unavailable replicas for deployed deployments and statefulsets,
- `kube_deployment_spec_replicas` - number of pods running for specific deployments,
- `kube_node_status_allocatable` - determines resources such as the number of CPU cores, RAM and ephemeral memory for each node. These results are then aggregated to get a view for the resources of the entire cluster.

### Control plane layer

This layer provides information about the cluster's control plane and requests handling time directed to it. The state of the master node is checked through the `kube_node_status_condition` metric, while the requests handling time is presented as a combination of several metrics. The `GET`, `POST` and `PUT` operations for both deployments and statefulsets are distinguished here. An operation that determines the average handling time of requests sent by deployments was implemented using the following PromQL query:
```
sum by(verb) (apiserver_request_duration_seconds_sum{resource="deployments", verb!="LIST", verb!="WATCH", verb!="DELETE"}) /
sum by(verb) (apiserver_request_duration_seconds_count{resource="deployments", verb!="WATCH", verb!="LIST", verb!="DELETE"})
```
For statefulsets, the query looks like this:
```
sum by(verb) (apiserver_request_duration_seconds_sum{resource="statefulsets", verb!="LIST", verb!="WATCH", verb!="DELETE"}) /
sum by(verb) (apiserver_request_duration_seconds_count{resource="statefulsets", verb!="WATCH", verb!="LIST", verb!="DELETE"})
```

### Node layer

Node layer contains metrics, which describe individual cluster nodes. They allow obtaining information about the availability and consumption of node resources, delays in operations on them, reads and writes to the disk and network traffic load on a node. The examined metrics are:
- `kube_node_status_allocatable` - determines resources such as the number of CPU cores, RAM and ephemeral memory for the node,
- `kubelet_running_containers` - the number of running containers on a given node. It allows determining whether the containers are more or less evenly distributed among the nodes,
- `node_disk_io_time_seconds_total` - describes the number of I/O operations on the disk, transformed into the expression `rate (node_disk_io_time_seconds_total{instance="$internal_ip:9100"}[1m])`,
- `kubelet_runtime_operations_duration_seconds_sum` and `kubelet_runtime_operations_duration_seconds_count` - allow calculating the average duration of the tasks: `container_status`, `create_container`, `list_containers`, `remove_container`, `start_container`. For this purpose, the following PromQL query was performed:
```
kubelet_runtime_operations_duration_seconds_sum{node="$node", operation_type!="image_status", operation_type!="list_images", operation_type!="list_podsandbox",
operation_type!="podsandbox_status", operation_type!="port_forward", operation_type!="pull_image" , operation_type!="remove_podsandbox",
operation_type!="run_podsandbox", operation_type!="status", operation_type!="stop_podsandbox", operation_type!="update_runtime_config", operation_type!="version"}
/ kubelet_runtime_operations_duration_seconds_count{node="$ node", operation_type!="image_status", operation_type!="list_images",
operation_type!="list_podsandbox", operation_type!="podsandbox_status", operation_type!="port_forward", operation_type!="pull_image",
operation_type!="remove_podsandbox ", operation_type!="run_podsandbox", operation_type!="status", operation_type!="stop_podsandbox",
operation_type!="update_runtime_config", operation_type!="version"}
```
- `node_disk_reads_completed_total` - node disk read counter, represented as average number of operations over time using the query `rate (node_disk_reads_completed_total{instance="$internal_ip:9100"}[1m])`,
- `node_disk_writes_completed_total` - writes to the node's disk counter, represented as the average number of operations over time using the query `rate (node_disk_writes_completed_total{instance="$internal_ip:9100"}[1m])`,
- `node_network_receive_bytes_total` - counter of bytes received for a given node, presented as the average number of bytes received over time using the query `rate (node_network_receive_bytes_total{instance="$internal_ip:9100"}[1m])`,
- `node_network_transmit_bytes_total` - counter of bytes sent for a given node, presented as the average number of bytes sent over time using the query `rate (node_network_transmit_bytes_total{instance="$internal_ip:9100"}[1m])`,
- `node_disk_read_bytes_total` - counter of bytes read from the node's disk presented as the average number of bytes read from the disk of a given node using the query `rate(node_disk_read_bytes_total{instance="$internal_ip:9100"}[1m])`,
- `node_disk_written_bytes_total` - counter of bytes written to the node's disk presented as the average number of bytes written to the disk of a given node using the query `rate(node_disk_written_bytes_total{instance="$internal_ip:9100"}[1m])`

### Pod layer

This layer presents information about the pods running on the cluster, such as lifetime of that pod, resource consumption, requests and limits imposed on the pod. The following metrics are used here:
- `kube_pod_status_ready` - describes the status of a given pod,
- `kube_pod_status_container_ready_time` - the running time of the pod calculated using the `time() - kube_pod_status_container_ready_time{pod="$pod"}` expression,
- `container_cpu_usage_seconds_total` - describes the cumulative measure of CPU usage time since pod startup. This quantity was converted to average CPU core usage over time using the expression `rate(container_cpu_usage_seconds_total{pod="$pod"}[1m])`,
- `kube_pod_container_resource_requests` - describes the resources requested by pod: RAM and number of CPU cores,
- `kube_pod_container_resource_limits` - describes the imposed limits on the pod's use of resources: RAM and the node's CPU cores.


### Application layer

The lowest layer shows the operation of the application (container) inside the pod, resources it requests and the number of application restarts. The metrics in this layer are:
- `kube_pod_container_status_running` - specifies the status of the container,
- `kube_pod_container_status_restarts_total` - counter of container restarts,
- `kube_pod_container_resource_requests` - specifies the RAM and CPU cores requested by the container.

## Test scenarios

### Checking on cluster resources

To check whether a cluster or any node is running out of resources, such as RAM memory, ephemeral memory or CPU cores there is a need to look into two layers: cluster and node. In cluster node the total available resource of the entire cluster should be inspected. In the node layer, on the other hand, for each node there should be verified the available number of resources. If it turns out that any node begins to run out of resources, appropriate actions should be taken.

### Pod and application resources usage

To see whether the managed and assigned to the corresponding pod resources have gone to the containers running in it there should be checked the sizes of the requested  resources by the pod and then the sizes of the requested resources by all the containers in that pod should be added up.

# Logs

Efficient log collection is paramount for gaining insights into the health, performance, and behavior of applications and infrastructure on Kubernetes. Collecting logs from various components within a cluster is essential for troubleshooting issues, monitoring system activities, and ensuring overall system reliability.

Each application generates logs that can be collected, aggregated and sent for analyzis and visualization. To achieve that we decided to use well known EFK stack - consisting of Elasticsearch, Fluend and Kibana.

## Elasticsearch
Elasticsearch excels at indexing and searching large volumes of data quickly and efficiently. In the context of log management, Elasticsearch acts as the storage and retrieval mechanism for logs. Logs from various sources are ingested into Elasticsearch, where they are indexed and made searchable. Its distributed nature ensures scalability, allowing it to handle vast amounts of log data across a cluster of nodes. Within the Elasticsearch there is a logstash underneath that ingests, processes and forwards logs and events to various outputs. It serves as the middleware between input sources and Elasticsearch itself.

## Fluentd
Fluentd is a data collector that is used to be deployed on every node within a cluster to be able to collect logs from applications running on them. He collects all the data and sends it to the Elasticsearch. In our project we use two instances of fluentd. One is created to collect logs from Kubernetes applications specificly and the second one is used to collect logs from the Node. It uses a configuration that ingesting logs from /var/log/journal folder, place where the systemd sends all the logs about running services.

To collect logs from the minikube node it was necessary to change the config of the systemd under a /etc/systemd/journald.conf and point a location where all the logs should be stored. After that, under a /var/log/ directory 'journal' folder has been created and it was possible to catch all the logs by the fluentd.

## Kibana
When data are ingested, proceeded and properly tagged they are sent to Kibana, where we can actually discover and analyze all the logs across the apps and nodes. Kibana gives us multiple possibilites to visulize the data and explore it. It uses a KQL (Keyword Query Language) that enables us to construct complex queries and filter data, helping to narrow down and focus on specific information. It is possible to save our filters and use them after to create a dashboards.

When it comes to vizualisation Kibana provides a wide range of visualization options, allowing users to create interactive and customizable charts, graphs, tables, and maps. It supports various visualization types such as line charts, bar charts, pie charts, and heat maps, making it versatile for different data representation needs.

Users can aggregate multiple visualizations into cohesive dashboards. Dashboards in Kibana enable the comprehensive display of relevant information in a single view, facilitating the monitoring and analysis of complex data sets.

# Traces



# Bibliography
https://sre.google/sre-book/monitoring-distributed-systems/
https://www.dynatrace.com/news/blog/observability-vs-monitoring/
