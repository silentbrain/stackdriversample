from google.cloud import monitoring
import subprocess
import sys
#Test5


cmd_id = ['curl','http://metadata.google.internal/computeMetadata/v1/project/project-id', '-H', 'Metadata-Flavor: Google']
proc = subprocess.Popen(cmd_id, stdout=subprocess.PIPE, shell=False)
(my_own_project, err) = proc.communicate()

client = monitoring.Client(project=my_own_project)

#Create Custom Metric

custom_metric_type = 'custom.googleapis.com/'+sys.argv[1]
descriptor = client.metric_descriptor(
            custom_metric_type,
                metric_kind=monitoring.MetricKind.GAUGE,
                    value_type=monitoring.ValueType.DOUBLE,
                        description=sys.argv[2])
descriptor.create()
