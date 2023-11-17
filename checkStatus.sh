#!/bin/bash

# this script automatically retrieves the summary of the job from the pod that runs the workflow
set -e

# Find the pod name starting with "fastqc" and using the same image
podName=$(kubectl get pods --field-selector=status.phase=Running -l app=fastqc --no-headers -o custom-columns=":metadata.name" | head -n 1)

# Get the job ID from the pod's logs
job_id=$(kubectl logs $podName | grep " pegasus-status -l " | cut -d' ' -f5) >/dev/null 2>&1

echo "Printing the status of the Job: "
kubectl exec $podName -- bash -c ". ~/condor-8.8.9/condor.sh && pegasus-status -l $job_id" 2>&1
echo -e "\n"

echo "Printing the statistics of the Job: "
kubectl exec $podName -- bash -c ". ~/condor-8.8.9/condor.sh && pegasus-statistics $job_id -s all" 2>&1
echo -e "\n"

echo "Printing the summary of the Job: "
summary=$(echo $job_id | cut -d'/' -f5,6) && kubectl exec $podName -- grep 'Workflow wall time' /output/$summary/statistics/summary.txt
echo -e "\n"
