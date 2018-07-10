#-*-coding: utf-8
from google.cloud import monitoring
import time
import subprocess
import sys

cmd_id = ['curl','http://metadata.google.internal/computeMetadata/v1/instance/id', '-H', 'Metadata-Flavor: Google']
proc = subprocess.Popen(cmd_id, stdout=subprocess.PIPE, shell=False)
(instance_id, err) = proc.communicate()

cmd_id = ['curl','http://metadata.google.internal/computeMetadata/v1/instance/zone', '-H', 'Metadata-Flavor: Google']
proc = subprocess.Popen(cmd_id, stdout=subprocess.PIPE, shell=False)
(instance_zone, err) = proc.communicate()
instance_zone_parsed = instance_zone.split('/')

cmd_id = ['curl','http://metadata.google.internal/computeMetadata/v1/project/project-id', '-H', 'Metadata-Flavor: Google']
proc = subprocess.Popen(cmd_id, stdout=subprocess.PIPE, shell=False)
(my_own_project, err) = proc.communicate()




client = monitoring.Client(project=my_own_project)

custom_metric_type = 'custom.googleapis.com/'+sys.argv[1]

resource = client.resource('gce_instance',labels={'instance_id': instance_id,'zone': instance_zone_parsed[3],})
metric = client.metric(type_= custom_metric_type,labels={'location': sys.argv[2]})


cmd_id = ['ping','-c', '1', sys.argv[3]]
while 1:
    proc = subprocess.Popen(cmd_id, stdout=subprocess.PIPE, shell=False)
    (ping_result, err) = proc.communicate()

    start_point = ping_result.find('time=')
    if start_point == -1:
        print "Timeout"
    else:
        print ping_result
        ping_result = ping_result[(start_point+5):]
        latency = ping_result[:ping_result.find(' ms')]
        client.write_point(metric, resource, float(latency))
        print sys.argv[1], sys.argv[2], sys.argv[3], latency + 'ms' 
    time.sleep(1)

