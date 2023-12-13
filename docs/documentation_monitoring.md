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

