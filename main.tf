provider "vsphere" {
  user                 = "administrator@vsphere.local"
  password             = "P@ssw0rd"
  vsphere_server       = "10.200.124.40"
  allow_unverified_ssl = true
}

# Datacenter
data "vsphere_datacenter" "dc" {
  name = "MCC-IBM3650-Datacenter"
}

# Cluster
data "vsphere_compute_cluster" "cluster" {
  name          = "MCC-IBM3650-Cluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Network
data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Datastore
data "vsphere_datastore" "ds" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Virtual Machine
resource "vsphere_virtual_machine" "vm" {
  name             = "testterraform01"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id   # ✅ ใช้ resource pool ของ cluster
  datastore_id     = data.vsphere_datastore.ds.id

  num_cpus = 2
  memory   = 2048
  guest_id = "otherGuest"

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 20
    thin_provisioned = true
  }

  cdrom {
    datastore_id = data.vsphere_datastore.ds.id
    path         = "[datastore1] ISO/rhel-9.2-x86_64-dvd.iso"
  }
}