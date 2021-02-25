from awsglue.transforms import *
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

sc = SparkContext()
glueContext = GlueContext(sc)
job = Job(glueContext)
# Please update the values in the options to connect to your own data source
options = {
    "tableName":"all_log_streams",
    "schemaName":"/aws-glue/jobs/output",
    "connectionName" : "my-connection"
    }
datasource = glueContext.create_dynamic_frame_from_options(
    connection_type = "custom.dynamodb",
    connection_options = options,
    transformation_ctx = "datasource")
datasource.show()
job.commit()