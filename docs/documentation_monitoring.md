# About the project
The goal of this project is to show different conceptions regarding: 
- Collecting and agregating logs using EFK stack - Elasticsearch, Fluentd, Kibana. 
- .
- .


# Kubernetes

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

# Monitoring


# Architecture


# Metrics


# Logs

Efficient log collection is paramount for gaining insights into the health, performance, and behavior of applications and infrastructure on Kubernetes. Collecting logs from various components within a cluster is essential for troubleshooting issues, monitoring system activities, and ensuring overall system reliability.

Each application generates logs that can be collected, aggregated and sent for analyzis and visualization. To achieve that we decided to use well known EFK stack - consisting of Elasticsearch, Fluend and Kibana.

## Elasticsearch
Elasticsearch excels at indexing and searching large volumes of data quickly and efficiently. In the context of log management, Elasticsearch acts as the storage and retrieval mechanism for logs. Logs from various sources are ingested into Elasticsearch, where they are indexed and made searchable. Its distributed nature ensures scalability, allowing it to handle vast amounts of log data across a cluster of nodes. Within the Elasticsearch there is a logstash underneath that ingests, processes, and forwards logs and events to various outputs. It serves as the middleware between input sources and Elasticsearch itself.

## Fluentd
Fluentd is a data collector that is used to be deployed on every node within a cluster to be able to collect logs from applications running on them. He collects all the data and sends it to the Elasticsearch. In our project we use two instances of fluentd. One is created to collect logs from Kubernetes applications specificly and the second one is used to collect logs from the Node. It uses a configuration that ingesting logs from /var/log/journal folder, place where the systemd sends all the logs about running services.

To collect logs from the minikube node it was necessary to change the config of the systemd under a /etc/systemd/journald.conf and point a location where all the logs should be stored. After that, under a /var/log/ directory 'journal' folder has been created and it was possible to catch all the logs by the fluentd.

## Kibana
When data are ingested, proceeded and properly tagged they are sent to Kibana, where we can actually discover and analyze all the logs across the apps and nodes. Kibana gives us multiple possibilites to visulize the data and explore it. It uses a KQL (Keyword Query Language) that enables us to construct complex queries and filter data, helping to narrow down and focus on specific information. It is possible to save our filters and use them after to create a dashboards.

When it comes to vizualisation Kibana provides a wide range of visualization options, allowing users to create interactive and customizable charts, graphs, tables, and maps. It supports various visualization types such as line charts, bar charts, pie charts, and heat maps, making it versatile for different data representation needs.

Users can aggregate multiple visualizations into cohesive dashboards. Dashboards in Kibana enable the comprehensive display of relevant information in a single view, facilitating the monitoring and analysis of complex data sets.

# Traces