      terraform {
        required_version = ">= 0.14.11"
        required_providers {
          oci = {
            source = "oracle/oci"
          }
        }
      }

      #data "oci_core_subnet" "this" {
      #  subnet_id = var.subnet_ocid
      #}

      data "oci_core_images" "this" {
        #Required
        compartment_id = "${var.compartment_ocid}"
  
        #Optional
        shape = "VM.Standard.A1.Flex"
        state = "AVAILABLE"
        operating_system = "Canonical Ubuntu"
      }

      # add data source to list AD1 name in the tenancy. Should work for both single and multi Ad region 
      data "oci_identity_availability_domain" "ad" {
          compartment_id = "${var.tenancy_ocid}"
          ad_number      = 1
      }
  
      resource "oci_core_instance" "App_Instance_1" {
        # availability_domain  = data.oci_core_subnet.this.availability_domain
        availability_domain  = "${oci_core_subnet.subnet1.availability_domain != null ? oci_core_subnet.subnet1.availability_domain : data.oci_identity_availability_domain.ad.name}"
        compartment_id       = var.compartment_ocid
        display_name         = var.instance_display_name
        ipxe_script          = var.ipxe_script
        preserve_boot_volume = var.preserve_boot_volume
        shape                = var.shape
        
        shape_config {
            memory_in_gbs = "32"
            ocpus = "2"
        }
        create_vnic_details {
          assign_public_ip       = true
          display_name           = var.vnic_name
          hostname_label         = "AppInstance1"
          skip_source_dest_check = var.skip_source_dest_check
          subnet_id              = oci_core_subnet.subnet1.id
        }

        #ssh_authorized_keys = var.ssh_public_key
        metadata = {
          ssh_authorized_keys = var.ssh_public_key
          user_data           = "${base64encode(file("./app_install.sh"))}"
        }

        source_details {
          boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
          source_type = "image"
          source_id   = data.oci_core_images.this.images[0].id
        }

        timeouts {
          create = var.instance_timeout
        }
      }

      resource "oci_core_volume" "App_Volume_1" {
        availability_domain = oci_core_instance.App_Instance_1.availability_domain
        compartment_id      = var.compartment_ocid
        display_name        = "${oci_core_instance.App_Instance_1.display_name}_volume_0"
        size_in_gbs         = var.block_storage_size_in_gbs
      }

      resource "oci_core_volume_attachment" "App_Volume_Attachment_1" {
        attachment_type = var.attachment_type
        # compartment_id  = var.compartment_ocid
        instance_id     = oci_core_instance.App_Instance_1.id
        volume_id       = oci_core_volume.App_Volume_1.id
        use_chap        = var.use_chap
      }

      resource "oci_core_instance" "App_Instance_2" {
        # availability_domain  = data.oci_core_subnet.this.availability_domain
        availability_domain  = "${oci_core_subnet.subnet1.availability_domain != null ? oci_core_subnet.subnet1.availability_domain : data.oci_identity_availability_domain.ad.name}"
        compartment_id       = var.compartment_ocid
        display_name         = var.instance_display_name
        ipxe_script          = var.ipxe_script
        preserve_boot_volume = var.preserve_boot_volume
        shape                = var.shape
        
        shape_config {
            memory_in_gbs = "32"
            ocpus = "2"
        }
        create_vnic_details {
          assign_public_ip       = true
          display_name           = var.vnic_name
          hostname_label         = "AppInstance2"
          skip_source_dest_check = var.skip_source_dest_check
          subnet_id              = oci_core_subnet.subnet1.id
        }

        metadata = {
          ssh_authorized_keys = var.ssh_public_key
          user_data           = "${base64encode(file("./app_install.sh"))}"
        }

        source_details {
          boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
          source_type = "image"
          source_id   = data.oci_core_images.this.images[0].id
        }

        timeouts {
          create = var.instance_timeout
        }
      }

      resource "oci_core_volume" "App_Volume_2" {
        availability_domain = oci_core_instance.App_Instance_2.availability_domain
        compartment_id      = var.compartment_ocid
        display_name        = "${oci_core_instance.App_Instance_2.display_name}_volume_0"
        size_in_gbs         = var.block_storage_size_in_gbs
      }

      resource "oci_core_volume_attachment" "App_Volume_Attachment_2" {
        attachment_type = var.attachment_type
        # compartment_id  = var.compartment_ocid
        instance_id     = oci_core_instance.App_Instance_2.id
        volume_id       = oci_core_volume.App_Volume_2.id
        use_chap        = var.use_chap
      }
    