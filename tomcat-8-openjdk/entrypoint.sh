#!/bin/bash

# read cgroup memory limit
CGROUP_MEM_LIMIT=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)

# only when cgroup memory limit present, calculate and set heap arguments
if [ -z "$CGROUP_MEM_LIMIT" ];then
    # part of cgroup memory limit as max heap size
    JVM_HEAP_PERCENTAGE=${JVM_HEAP_PERCENTAGE:-80}
    # calculate jvm heap
    JVM_HEAP_MB=`expr $CGROUP_MEM_LIMIT / 1024 / 1024 * $JVM_HEAP_PERCENTAGE / 100`
    # max heap size is limited as 30GB
    if (($JVM_HEAP_MB > 30720)); then
        JVM_HEAP_MB=30720
    fi
    # command-line heap arguments
    JVM_HEAP_ARGS="-Xmx${JVM_HEAP_MB}M"
fi
JVM_HEAP_ARGS=${JVM_HEAP_ARGS:-}

# CMS as garbage collector
JVM_GC_ARGS="-XX:+UseConcMarkSweepGC"

# arguments passed to tomcat server
export JAVA_OPTS="$JVM_HEAP_ARGS $JVM_GC_ARGS"
# display JAVA_OPTS
echo "JAVA_OPTS=$JAVA_OPTS"

# replace current process with tomcat startup
exec catalina.sh run

