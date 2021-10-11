LAB 1 & 2 - Apache Hudi Datasource and Deltastreamer operations

1) Download pem file from s3://<account-number>-hudi-demo/keypairs/
Convert PEM to PPK if your desktop is windows -> https://aws.amazon.com/premiumsupport/knowledge-center/convert-pem-file-into-ppk/

2) Make sure you are able to SSH to the EMR cluster "Hudi Demo"
ssh -i ~/keypair.pem hadoop@ec2-xx-xx-x-x.compute-1.amazonaws.com

3) Create SSH tunnel for the EMR cluster "Hudi Demo" using dynamic port forwarding -  https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-ssh-tunnel.html
ssh -i ~/keypair.pem -ND 8157 hadoop@ec2-xx-xx-x-x.compute-1.amazonaws.com

4) Open JupyterHub UI on EMR - https://ec2-xx-xx-x-x.compute-1.amazonaws.com:9443

5) Login to JupyterHub
username - jovyan
password - jupyter

6) Download files "apache-hudi-on-amazon-emr-datasource-pyspark-demo" and "apache-hudi-on-amazon-emr-deltastreamer-python-demo" taken from LAB1 and 2 folders in GitHub and upload these two files to Jupyter

7) Follow the instructions on the notebook

LAB 3 - Building Data Lake with Apache Hudi

Create Kafka Python client on EC2 instance Kafka Producer

1) Download Kafka client dependencies
sudo su
pip install protobuf
pip install requests
pip install kafka-python
pip install --upgrade gtfs-realtime-bindings
pip install underground
pip install pathlib

wget https://archive.apache.org/dist/kafka/2.2.1/kafka_2.12-2.2.1.tgz
tar -xzf kafka_2.12-2.2.1.tgz

2) Run the two commands in EMR master node to get the values of ZookeeperConnectString and BootstrapBrokerString

aws kafka describe-cluster --region us-east-1 --cluster-arn arn:aws:kafka:us-east-1:620614497509:cluster/test/2dbb304e-79fe-4beb-a02d-35e0fea4524b-2 | grep ZookeeperConnectString -> copy the value of "ZookeeperConnectString"

aws kafka get-bootstrap-brokers --cluster-arn "arn:aws:kafka:us-east-1:620614497509:cluster/test/2dbb304e-79fe-4beb-a02d-35e0fea4524b-2" -> copy the bootstrap servers value
{
    "BootstrapBrokerString": "b-2.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092,b-1.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092,b-3.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092"
}

3) Create two Kafka topics

/home/hadoop/kafka_2.12-2.2.1/bin/kafka-topics.sh --create --zookeeper "z-3.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:2181,z-2.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:2181,z-1.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:2181" --replication-factor 3 --partitions 1 --topic trip_update_topic

/home/hadoop/kafka_2.12-2.2.1/bin/kafka-topics.sh --create --zookeeper "z-3.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:2181,z-2.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:2181,z-1.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:2181" --replication-factor 3 --partitions 1 --topic trip_status_topic

4) Download the file "train_arrival_producer.py" from Github (LAB3) and replace the bootstrap servers value in line #15

5) Export API key
export MTA_API_KEY=<provided key>

6) Run the client -> python train_arrival_producer.py

7) You can verify that the Kafka topics are being written to using the following commands

/home/hadoop/kafka_2.12-2.2.1/bin/kafka-console-consumer.sh --bootstrap-server "b-3.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092,b-1.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092,b-2.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092" --topic trip_update_topic --from-beginning

/home/hadoop/kafka_2.12-2.2.1/bin/kafka-console-consumer.sh --bootstrap-server "b-3.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092,b-1.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092,b-2.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092" --topic trip_status_topic --from-beginning

Configure Spark consumer on EMR master node (Hudi Demo)

8)  Download Spark dependencies
cd /usr/lib/spark/jars

sudo wget https://repo1.maven.org/maven2/org/apache/spark/spark-streaming-kafka-0-10_2.12/3.0.1/spark-streaming-kafka-0-10_2.12-3.0.1.jar
sudo wget https://repo1.maven.org/maven2/org/apache/spark/spark-sql-kafka-0-10_2.12/3.0.1/spark-sql-kafka-0-10_2.12-3.0.1.jar
sudo wget https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/2.2.1/kafka-clients-2.2.1.jar
sudo wget https://repo1.maven.org/maven2/org/apache/spark/spark-streaming-kafka-0-10-assembly_2.12/3.0.0-preview2/spark-streaming-kafka-0-10-assembly_2.12-3.0.0-preview2.jar
sudo wget https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.11.1/commons-pool2-2.11.1.jar

9) Download notebook "amazon-emr-spark-streaming-apache-hudi-demo" and upload to JupyterHub

10) Replace bootstrap string and run notebook blocks (preferably using spark-shell)

11) Once data starts getting written to Hudi table, create table and query via Athena or Redshift spectrum

12) Optional - Visualize live trip updates using Quicksight

BONUS TAKE HOME LAB -

Hudi Bootstrap Feature

APPENDIX

Pre-work (completed):

1) Create Private Key for SSH
2) Create VPC, Subnet, S3 endpoint, IAM Roles required
3) Create Amazon EMR cluster
4) Create Amazon MSK cluster
5) Create Redshift cluster
6) Create EC2 Bastion Instance
