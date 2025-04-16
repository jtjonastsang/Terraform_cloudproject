provider "google" {
  project = "integral-berm-455706-e9"
  region  = "asia-east1"  # 改成你想要嘅region
}

resource "google_compute_network" "example" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private1" {
  name          = "private-subnet-1"
  ip_cidr_range = "10.1.1.0/24"
  region        = "asia-east1"  # 同provider嘅region一致
  network       = google_compute_network.example.id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "private2" {
  name          = "private-subnet-2"
  ip_cidr_range = "10.1.2.0/24"
  region        = "asia-east1"  # 同provider嘅region一致
  network       = google_compute_network.example.id
  private_ip_google_access = true
}

resource "google_container_cluster" "example" {
  name     = "my-cluster"
  location = "asia-east1"  # 同你嘅子網region一致
  network    = google_compute_network.example.name
  subnetwork = google_compute_subnetwork.private1.name

  # 移除預設節點池，因為GKE要求自訂節點池
  remove_default_node_pool = true
  initial_node_count       = 1

  # 私有集群設定（用私有子網）
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false  # 設false可以用公網訪問
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  cluster    = google_container_cluster.example.name
  location   = "asia-east1"
  node_count = 2  # 2個VM，滿足項目要求
  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
  node_config {
    machine_type = "e2-medium"  # 小型機器，慳成本
    disk_size_gb = 20
  }
}