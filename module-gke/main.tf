terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.56.0"
    }
  }
}

provider "google" {
  project = "vast-art-304421"
  region  = var.region
}

resource "google_service_account" "service_account" {
  account_id   = "gke-${var.STUDENT_1ST_NAME}-${var.STUDENT_LAST_NAME}"
  display_name = "Service Account gke-${var.STUDENT_1ST_NAME}-${var.STUDENT_LAST_NAME}"
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = "vast-art-304421"
  name                       = "gke-${var.STUDENT_1ST_NAME}-${var.STUDENT_LAST_NAME}"
  region                     = "us-central1"
  zones                      = ["us-central1-a", "us-central1-b", "us-central1-f"]
  network                    = "default"
  subnetwork                 = "default"
  ip_range_pods              = "us-central1-01-gke-01-pods"
  ip_range_services          = "us-central1-01-gke-01-services"
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = true

  node_pools = [
    {
      name               = "gke-${var.STUDENT_1ST_NAME}"
      machine_type       = "f1-micro"
      node_locations     = "us-central1-b,us-central1-c"
      min_count          = 1
      max_count          = 3
      local_ssd_count    = 0
      disk_size_gb       = 10
      disk_type          = "pd-standard"
      image_type         = "UBUNTU"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = "gke-${var.STUDENT_1ST_NAME}-${var.STUDENT_LAST_NAME}@vast-art-304421.iam.gserviceaccount.com"
      preemptible        = false
      initial_node_count = 80
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}