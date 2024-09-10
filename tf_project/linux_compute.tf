resource "oci_core_instance" "instance1" {
    display_name        = "be-instance1"
    shape               = var.instance_shape
    compartment_id = var.compartment_id

    # Refer cloud-init in https://docs.cloud.oracle.com/iaas/api/#/en/iaas/20160918/datatypes/LaunchInstanceDetails
    metadata = {
        # Base64 encoded YAML based user_data to be passed to cloud-init
        user_data = ""
    }
}