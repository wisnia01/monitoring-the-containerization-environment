# About the project

# Streaming

# Kubernetes

To fully demonstrate horizontal streaming autoscaling possibilities we decided to run our applications on minikube.

Minikube is an open-source tool for running Kubernetes clusters locally on a single machine. It supports cross-platform use and easy installation via popular package managers or direct downloads. Minikube integrates with hypervisors (e.g., VirtualBox, Hyper-V) or can run Kubernetes nodes as containers using Docker.

To start a local Kubernetes cluster with one node we run a command:
```
minikube start
```
# Infrastructure

Main streaming app is created on kubernetes as a Deployment object. Manifest we use to create it is shown below:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: streaming-server-deployment
  labels:
    name: streaming-server-deployment
  namespace: streaming-server
spec:
  replicas: 1
  selector:
    matchLabels:
      name: streaming-server-pod
  template:
    metadata:
      labels:
        name: streaming-server-pod
      namespace: streaming-server
    spec:
      restartPolicy: Always
      containers:
        - name: streaming-server-container
          image: streaming-server:latest
          imagePullPolicy: Never
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: "10m"
            limits:
              cpu: "50m"

```

It uses locally built image called `streaming-server` from 
```
apps/streaming-server/Dockerfile
```
By default (After connecting a pod autoscaler to this Deployment - it changes) only one pod is created with streaming application and it exposes container port at port :8080. 
``       
resources:
    requests:
        cpu: "10m"
    limits:
        cpu: "50m"
``
set limits at every pod created by Deployment, that he wont be able to exceed 50 milicores CPU, but it will grant at least 10 milicores CPU per pod. This limit in combination with ``web-load-simulator`` will help us achieve scalability of pods from 1 to about 5-7 pods.

To allow a communication to this pod we need to create a service, which will grant us IP and will always connect to the pods created by above Deployment. Manifest used to create appropiate service is as shown below:
```apiVersion: v1
kind: Service
metadata:
  name: streaming-server-service
  namespace: streaming-server
spec:
  type: NodePort
  ports:
    - nodePort: 30001
      port: 8080
      targetPort: 8080
  selector:
    name: streaming-server-pod
  sessionAffinity: None
```
Current configuration allow us to expose Node IP to the external world that gives us a possibility to reach a streaming app by using web browser. ``sessionAffinity: None`` allows us to demonstate that service is load-balancing the traffic between pods created by Deployment that service is connected to. After refreshing page we will reach to the different pod instances.

To create a Horizontal Pod Autoscaler we are using script with following command:
```
kubectl autoscale deployment streaming-server-deployment --cpu-percent=50 --min=1 --max=10 -n streaming-server
```
whichi creates an HPA with following configuration:
* Every 15 seconds check the status of ``deployment`` called ``streaming-server-deployment ``
* When Deployments pod will reach more than ``50%`` - scale out
* Minimum and maximum number of pods can be between 1 and 10 pods.

To enable the autoscaler getting information about current pod CPU usage we need to deploy a ``metrics-server`` as well. `Metrics Server` in Kubernetes exposes a simple HTTP API that allows users to query for real-time metrics data related to the resource utilization of nodes and pods. This API is essential for applications to make decisions regarding scaling etc.

We used only essential components stored in 
```
k8s/metric-server-manifests/components.yaml
```
 from https://github.com/kubernetes-sigs/metrics-server where you can find additional documentation.


To generate a load on our web application we use mentioned before ``web-load-generator``. It is a single pod deployed manually by the user on a kubernetes cluster. To do that you need to type ``kubectl apply -f web-load-generator.yaml`` in your terminal. Generator uses following manifest:
```apiVersion: v1
kind: Pod
metadata:
  name: load-generator
  namespace: streaming-server
spec:
  containers:
  - name: load-generator
    image: busybox:1.28
    command: ["/bin/sh", "-c"]
    args:
    - "while sleep 0.01; do wget -q -O- streaming-server-service:8080; done"
  restartPolicy: Never
  ```
This pod configuration will create a simple container with busybox image that will run a script with infinite loop trying to reach our page. Thanks to the ``service`` we dont need to know actual node IP - all we need to do is use ``streaming-server-service`` and Kubernetes will resolve its IP on its own.

Every component is stored on separate `namespace` called `streaming-server` which manifest is as simple as:
```
apiVersion: v1
kind: Namespace
metadata:
  name: streaming-server
  labels:
    name: streaming-server
```
Using this helps greatly to separate app's purpose (like streaming-server, monitoring, metric-server etc.) and manage applications faster and easier.
