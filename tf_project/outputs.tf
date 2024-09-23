
    // Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
    // Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
         
      output "public_ip_1" {
        description = "Public IPs of App Instance 1. "
        value       = [oci_core_instance.App_Instance_1.public_ip]
      }

      output "public_ip_2" {
        description = "Public IPs of App Instance 2. "
        value       = [oci_core_instance.App_Instance_2.public_ip]
      }
  
        output "load_balancer_ip" {
        description = "Public IPs of the load balancer. "
        value       = [oci_load_balancer.lb1.public_ip]
      }