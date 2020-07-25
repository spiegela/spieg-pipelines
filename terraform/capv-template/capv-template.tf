variable "vsphere_server" {
  type = string
}

variable "template_host" {
  type = string
}

variable "vsphere_user" {
  type = string
}

variable "vsphere_password" {
  type = string
}

variable "capv_template_name" {
  type = string
}

variable "capv_image" {
  type = string
}

variable "haproxy_template_name" {
  type = string
}

variable "haproxy_image" {
  type = string
}

provider "vsphere" {
  vsphere_server = var.vsphere_server
  user = var.vsphere_user
  password = var.vsphere_password

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "Datacenter"
}

data "vsphere_datastore" "datastore_1" {
  name = "Datastore 1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "vm_network" {
  name = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "storage_access_network" {
  name = "Storage Access"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "compute_cluster" {
  name = "Cluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "template_host" {
  name          = var.template_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_resource_pool" "resource_pool" {
  name = "ClusterAPI"
  parent_resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
}

resource "vsphere_virtual_machine" "capv-ubuntu-1804" {
  name = var.capv_template_name
  host_system_id = data.vsphere_host.template_host.id
  resource_pool_id = vsphere_resource_pool.resource_pool.id
  datastore_id = data.vsphere_datastore.datastore_1.id
  datacenter_id = data.vsphere_datacenter.dc.id
  num_cpus = 8
  memory = 32768

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout = 0

  ovf_deploy {
    remote_ovf_url = var.capv_image
    disk_provisioning = "thin"
    ovf_network_map = {
      "nic0" = data.vsphere_network.vm_network.id
    }
  }
  network_interface {
    network_id = data.vsphere_network.storage_access_network.id
  }
}

resource "vsphere_virtual_machine" "capv-haproxy" {
  name = var.haproxy_template_name
  host_system_id = data.vsphere_host.template_host.id
  resource_pool_id = vsphere_resource_pool.resource_pool.id
  datastore_id = data.vsphere_datastore.datastore_1.id
  datacenter_id = data.vsphere_datacenter.dc.id

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout = 0

  ovf_deploy {
    remote_ovf_url = var.haproxy_image
    disk_provisioning = "thin"
    ovf_network_map = {
      "nic0" = data.vsphere_network.vm_network.id
    }
  }
  network_interface {
    network_id = data.vsphere_network.storage_access_network.id
  }
}

