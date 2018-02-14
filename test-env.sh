#!/usr/bin/env bash
sed -i -e 's/#//' -e 's/default_ccache_name/# default_ccache_name/' /etc/krb5.conf
export HADOOP_OPTS="-Djava.net.preferIPv4Stack=true -Dsun.security.krb5.debug=true"
export HADOOP_JAAS_DEBUG=true
export HADOOP_ROOT_LOGGER=DEBUG,console
export NAMESPACE=default
export HADOOP_CONF_DIR=/opt/spark/hconf
mkdir -p /etc/krb5.conf.d
until /usr/bin/kinit -kt /var/keytabs/hdfs.keytab hdfs/nn.${NAMESPACE}.svc.cluster.local; do sleep 15; done
/opt/spark/bin/spark-submit \
      --deploy-mode cluster \
      --class org.apache.spark.examples.HdfsTest \
      --master k8s://10.96.0.1:443 \
      --kubernetes-namespace ${NAMESPACE} \
      --conf spark.executor.instances=1 \
      --conf spark.app.name=spark-hdfs \
      --conf spark.driver.extraClassPath=/opt/spark/hconf/core-site.xml:/opt/spark/hconf/hdfs-site.xml:/opt/spark/hconf/yarn-site.xml:/etc/krb5.conf \
      --conf spark.kubernetes.driver.docker.image=spark-driver:latest \
      --conf spark.kubernetes.executor.docker.image=spark-executor:latest \
      --conf spark.kubernetes.initcontainer.docker.image=spark-init:latest \
      --conf spark.kubernetes.kerberos.enabled=true \
      --conf spark.kubernetes.kerberos.keytab=/var/keytabs/hdfs.keytab \
      --conf spark.kubernetes.kerberos.principal=hdfs/nn.${NAMESPACE}.svc.cluster.local@CLUSTER.LOCAL \
      local:///opt/spark/examples/jars/spark-examples_2.11-2.2.0-k8s-0.5.0.jar \
      hdfs://nn.${NAMESPACE}.svc.cluster.local:9000/user/ifilonenko/people.txt 