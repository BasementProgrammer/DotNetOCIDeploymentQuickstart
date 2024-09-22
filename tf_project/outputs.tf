
    // Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
    // Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
    
      output "instance_id_1" {
        description = "ocid of App Instance 1. "
        value       = [oci_core_instance.App_Instance_1.id]
      }
      
      output "private_ip_1" {
        description = "Private IPs App Instance 1. "
        value       = [oci_core_instance.App_Instance_1.private_ip]
      }
      
      output "public_ip_1" {
        description = "Public IPs of App Instance 1. "
        value       = [oci_core_instance.App_Instance_1.public_ip]
      }


      output "instance_id_2" {
        description = "ocid of App Instance 2. "
        value       = [oci_core_instance.App_Instance_2.id]
      }
      
      output "private_ip_2" {
        description = "Private IPs App Instance 2. "
        value       = [oci_core_instance.App_Instance_2.private_ip]
      }
      
      output "public_ip_2" {
        description = "Public IPs of App Instance 2. "
        value       = [oci_core_instance.App_Instance_2.public_ip]
      }
  