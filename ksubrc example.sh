{
    "ProjectID": "",
    "ClusterName": "",
    "Namespace": "default",
    "InitContainerImage": "gcr.io/kbatch-images/setupexecutable/setupexecutable:latest",
    "DefaultImage": "ubuntu",
    "Volumes": {
        "fs-volume": {
            "Source": "PersistentVolumeClaim",
            "Params": {
                "claimName": "pv-claim",
                "readOnly": "false"
            }
        }
    },
    "GPUManufacturer": {
        "nvidia-tesla-k80": "nvidia.com/gpu",
        "nvidia-tesla-p100": "nvidia.com/gpu",
        "nvidia-tesla-p4": "nvidia.com/gpu",
        "nvidia-tesla-t4": "nvidia.com/gpu",
        "nvidia-tesla-v100": "nvidia.com/gpu"
    }
}
