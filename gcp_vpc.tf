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