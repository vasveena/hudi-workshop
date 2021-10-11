**LAB 1 & 2 - Apache Hudi Datasource and Deltastreamer operations** <br />

1) Download pem file from s3://account_ID-hudi-workshop/keys/ <br />
Convert PEM to PPK if your desktop is windows -> https://aws.amazon.com/premiumsupport/knowledge-center/convert-pem-file-into-ppk/ <br />

2) Make sure you are able to SSH to the EMR cluster "Hudi Demo" and EC2 instance "Kafka Producer" <br />
```
EMR - ssh -i <account_ID>.pem hadoop@ec2-xx-xx-x-x.compute-1.amazonaws.com
EC2 - ssh -i <account_ID>.pem ec2-user@ec2-xx-xx-x-x.compute-1.amazonaws.com
```

3) Create SSH tunnel for the EMR cluster "Hudi Demo" using dynamic port forwarding -  https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-ssh-tunnel.html <br />
```
ssh -i ~/<account_ID>.pem -ND 8157 hadoop@ec2-xx-xx-x-x.compute-1.amazonaws.com
```

4) On EMR master node, copy workshop contents to S3. Can also be downloaded to local.

```
mkdir git
cd git
sudo yum install -y git
git clone https://github.com/vasveena/hudi-workshop.git
```

5) Edit "json-deltastreamer.properties" and "json-deltastreamer_upsert.properties" under LAB2/
```
hoodie.deltastreamer.source.dfs.root=s3://accountID-hudi-workshop/hudi-ds/inputdata/
hoodie.deltastreamer.source.dfs.root=s3://accountID-hudi-workshop/hudi-ds/updates

hoodie.deltastreamer.schemaprovider.source.schema.file=s3://accountID-hudi-workshop/artifact/hudi-workshop/LAB2/source-schema-json.avsc
hoodie.deltastreamer.schemaprovider.target.schema.file=s3://accountID-hudi-workshop/artifact/hudi-workshop/LAB2/target-schema-json.avsc

aws s3 cp ~/git/ s3://accountID-hudi-workshop/artifact/ --recursive
```

6) Open JupyterHub UI on EMR - https://ec2-xx-xx-x-x.compute-1.amazonaws.com:9443 <br />

7) Login to JupyterHub <br />
username - jovyan <br />
password - jupyter <br />

8) Download files "apache-hudi-on-amazon-emr-datasource-pyspark-demo" and "apache-hudi-on-amazon-emr-deltastreamer-python-demo" taken from LAB 1 and 2 folders in GitHub and upload these two files to Jupyter <br />

9) Follow the instructions on the notebooks <br />

**LAB 3 - Building Data Lake with Apache Hudi** <br />

Create Kafka Python client on EC2 instance "Kafka Producer" <br />

1) Download Kafka client dependencies <br />
```
sudo su
which python3
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user
which pip


sudo /root/.local/bin/pip install protobuf
sudo /root/.local/bin/pip install requests
sudo /root/.local/bin/pip install kafka-python
sudo /root/.local/bin/pip install --upgrade gtfs-realtime-bindings
sudo /root/.local/bin/pip install underground
sudo /root/.local/bin/pip install pathlib

exit

sudo yum install java-1.8.0
wget https://archive.apache.org/dist/kafka/2.2.1/kafka_2.12-2.2.1.tgz
tar -xzf kafka_2.12-2.2.1.tgz
```
2) Run the two commands in EMR master node to get the values of ZookeeperConnectString and BootstrapBrokerString <br />

```
aws kafka describe-cluster --region us-east-1 --cluster-arn arn:aws:kafka:us-east-1:620614497509:cluster/test/2dbb304e-79fe-4beb-a02d-35e0fea4524b-2 | grep ZookeeperConnectString -> copy the value of "ZookeeperConnectString"

aws kafka get-bootstrap-brokers --cluster-arn "arn:aws:kafka:us-east-1:620614497509:cluster/test/2dbb304e-79fe-4beb-a02d-35e0fea4524b-2" -> copy the bootstrap servers value
{
    "BootstrapBrokerString": "b-2.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092,b-1.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092,b-3.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092"
}
```

3) Create two Kafka topics <br />

```
/home/ec2-user/kafka_2.12-2.2.1/bin/kafka-topics.sh --create --zookeeper "z-3.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:2181,z-2.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:2181,z-1.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:2181" --replication-factor 3 --partitions 1 --topic trip_update_topic

/home/ec2-user/kafka_2.12-2.2.1/bin/kafka-topics.sh --create --zookeeper "z-3.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:2181,z-2.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:2181,z-1.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:2181" --replication-factor 3 --partitions 1 --topic trip_status_topic

```

4) Download the file "train_arrival_producer.py" from Github (LAB3) and replace the bootstrap servers value in line #15 <br />

5) Export API key <br />
```
export MTA_API_KEY=<provided key>
```

6) Run the Kafka producer client <br />
```
python3 train_arrival_producer.py
```

7) You can verify that the Kafka topics are being written to using the following commands <br />
```
/home/hadoop/kafka_2.12-2.2.1/bin/kafka-console-consumer.sh --bootstrap-server "b-3.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092,b-1.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092,b-2.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092" --topic trip_update_topic --from-beginning

/home/hadoop/kafka_2.12-2.2.1/bin/kafka-console-consumer.sh --bootstrap-server "b-3.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092,b-1.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092,b-2.test.1tklkx.c2.kafka.us-east-1.amazonaws.com:9092" --topic trip_status_topic --from-beginning
```
Configure Spark consumer on EMR master node (Hudi Demo) <br />

8)  Download Spark dependencies <br />
```
cd /usr/lib/spark/jars

sudo wget https://repo1.maven.org/maven2/org/apache/spark/spark-streaming-kafka-0-10_2.12/3.0.1/spark-streaming-kafka-0-10_2.12-3.0.1.jar
sudo wget https://repo1.maven.org/maven2/org/apache/spark/spark-sql-kafka-0-10_2.12/3.0.1/spark-sql-kafka-0-10_2.12-3.0.1.jar
sudo wget https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/2.2.1/kafka-clients-2.2.1.jar
sudo wget https://repo1.maven.org/maven2/org/apache/spark/spark-streaming-kafka-0-10-assembly_2.12/3.0.0-preview2/spark-streaming-kafka-0-10-assembly_2.12-3.0.0-preview2.jar
sudo wget https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.11.1/commons-pool2-2.11.1.jar
```
9) Download notebook "amazon-emr-spark-streaming-apache-hudi-demo" and upload to JupyterHub <br />

10) Replace bootstrap string and run notebook blocks (preferably using spark-shell) <br />

11) Once data starts getting written to Hudi table, create table and query via Athena or Redshift spectrum <br />

12) Optional - Visualize live trip updates using Quicksight <br />

BONUS TAKE HOME LAB - <br />

Hudi Bootstrap Feature (under bonus-lab) <br />

APPENDIX <br />

Pre-work (completed): <br />

1) Create Private Key for SSH
2) Create VPC, Subnet, S3 endpoint, IAM Roles required
3) Create Amazon EMR cluster
4) Create Amazon MSK cluster
5) Create Redshift cluster
6) Create EC2 Bastion Instance
