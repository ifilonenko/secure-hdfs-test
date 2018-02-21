### Strata 2018 San Jose Demo @Ilan Filonenko
#### 0. Make sure minikube is setup
#### 1. Build distribution from Apache-Spark-on-K8S
```
> git clone https://github.com/apache-spark-on-k8s/spark.git
> cd spark
> git checkout branch-2.2-kubernetes
> build/mvn install -Pkubernetes -pl resource-managers/kubernetes/core -am -DskipTests
> build/mvn compile -Pkubernetes -pl resource-managers/kubernetes/core -am -DskipTests
> dev/make-distribution.sh --tgz -Phadoop-2.7 -Pkubernetes
> tar -xvf spark-2.2.0-k8s-0.5.0-bin-2.7.3.tgz
> cd spark-2.2.0-k8s-0.5.0-bin-2.7.3
> docker build -t spark-base:latest -f dockerfiles/spark-base/Dockerfile .
> docker build -t spark-driver:latest -f dockerfiles/driver/Dockerfile .
> docker build -t spark-executor:latest -f dockerfiles/executor/Dockerfile .
> docker build -t spark-init:latest -f dockerfiles/init-container/Dockerfile .
```
#### 2. Launch a stable single-noded, pseudo-distributed, kerberized, hadoop cluster
Instructions for this can be found [here](https://github.com/ifilonenko/hadoop-kerberos-helm)
```
> kubectl get pods
NAME                                  READY     STATUS             RESTARTS   AGE
hdfs-data-populator-8849648c4-nx4fg   1/1       Running   		   0          1h
hdfs-dn1-67c9d89fc8-pglzm             1/1       Running            0          1h
kerberos-84c58d6968-b9scl             1/1       Running            0          1h
nn-7ccbcff78d-smghz                   1/1       Running            0          1h
```

#### 3. Build docker image 
```
> docker build -t kerberos-test:latest -f Dockerfile .
```
Push the image to your repository unless using a local cluster.

#### 4. Deploy Kubernetes for kerberos-testing
```
> kubectl create -f kerberos-test-deployment.yml
```

#### 5. Setup dashboard 
```
> kubectl proxy
Starting to serve on 127.0.0.1:8001
```

#### 6. Exec into Kerberos-test pod and run command
```
> kubectl get pods
NAME                                  READY     STATUS    RESTARTS   AGE
hdfs-data-populator-8849648c4-nx4fg   1/1       Running   0          1h
hdfs-dn1-67c9d89fc8-pglzm             1/1       Running   0          1h
kerberos-84c58d6968-b9scl             1/1       Running   0          1h
kerberos-test-544f5989f9-q48dv        1/1       Running   0          1h
nn-7ccbcff78d-smghz                   1/1       Running   0          1h
> kubectl exec -it kerberos-test-544f5989f9-q48dv -- /bin/bash
bash-4.4# /bin/bash test-env.sh
2018-02-14 05:08:53 INFO  HadoopStepsOrchestrator:54 - Hadoop Conf directory: /opt/spark/hconf
2018-02-14 05:08:53 INFO  HadoopConfBootstrapImpl:54 - HADOOP_CONF_DIR defined. Mounting Hadoop specific files
2018-02-14 05:08:53 WARN  NativeCodeLoader:62 - Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Debug is  true storeKey true useTicketCache false useKeyTab true doNotPrompt true ticketCache is null isInitiator true KeyTab is /var/keytabs/hdfs.keytab refreshKrb5Config is true principal is hdfs/nn.default.svc.cluster.local@CLUSTER.LOCAL tryFirstPass is false useFirstPass is false storePass is false clearPass is false
Refreshing Kerberos configuration
principal is hdfs/nn.default.svc.cluster.local@CLUSTER.LOCAL
...
2018-02-14 05:09:11 INFO  LoggingPodStatusWatcherImpl:54 - State changed, new state:
	 pod name: spark-hdfs-1518584932805-driver
	 namespace: default
	 labels: spark-app-selector -> spark-d64e31c79c3a440693f7746549b2776b, spark-role -> driver
	 pod uid: 2833c8a9-1145-11e8-bf5a-0800279937ac
	 creation time: 2018-02-14T05:08:55Z
	 service account name: default
	 volumes: spark-local-dir-0-spark-792e98e0-351b-4c44-a2a2-86920905a10f, hadoop-properties, hadoop-secret, default-token-qhfgr
	 node name: minikube
	 start time: 2018-02-14T05:08:55Z
	 container images: spark-driver:latest
	 phase: Succeeded
	 status: [ContainerStatus(containerID=docker://9294f0f33946758a365d007d622e44c1d1c5404c35012a1ad46c013444fd81c5, image=spark-driver:latest, imageID=docker://sha256:bc5e0d30f9cd9510dc780a6656c7e5f4ab745987d769579100e6458872113262, lastState=ContainerState(running=null, terminated=null, waiting=null, additionalProperties={}), name=spark-kubernetes-driver, ready=false, restartCount=0, state=ContainerState(running=null, terminated=ContainerStateTerminated(containerID=docker://9294f0f33946758a365d007d622e44c1d1c5404c35012a1ad46c013444fd81c5, exitCode=0, finishedAt=Time(time=2018-02-14T05:09:10Z, additionalProperties={}), message=null, reason=Completed, signal=null, startedAt=Time(time=2018-02-14T05:08:57Z, additionalProperties={}), additionalProperties={}), waiting=null, additionalProperties={}), additionalProperties={})]
2018-02-14 05:09:11 INFO  LoggingPodStatusWatcherImpl:54 - Container final statuses:


	 Container name: spark-kubernetes-driver
	 Container image: spark-driver:latest
	 Container state: Terminated
	 Exit code: 0
2018-02-14 05:09:11 INFO  Client:54 - Application spark-hdfs finished.
```
