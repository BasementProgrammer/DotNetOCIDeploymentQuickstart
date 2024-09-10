# Create a new compartment
resource "oci_identity_compartment" "my_compartment" {
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaaqxhfhppmshnaq3qaqgyr53g3ndijh7tqtuwkh34rauywbk4svlyq" # Replace with the OCID of the tenancy
  description    = "My Compartment"
  name           = "aspnet-core-demo"
}

# Create a new VCN
resource "oci_core_vcn" "my_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = oci_identity_compartment.my_compartment.id
  display_name   = "ASPNET Core VCN"
}

# Create a new subnet
resource "oci_core_subnet" "my_subnet" {
  cidr_block                 = "10.0.0.0/24"
  compartment_id             = oci_identity_compartment.my_compartment.id
  vcn_id                     = oci_core_vcn.my_vcn.id
  display_name               = "My Subnet"
  prohibit_public_ip_on_vnic = false
}

# Create a new route table
resource "oci_core_route_table" "my_route_table" {
  compartment_id = oci_identity_compartment.my_compartment.id
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "My Route Table"
}

# Associate the route table with the subnet
resource "oci_core_route_table_attachment" "my_route_table_attachment" {
  subnet_id      = oci_core_subnet.my_subnet.id
  route_table_id = oci_core_route_table.my_route_table.id
}

# Create a new security list
resource "oci_core_security_list" "my_security_list" {
  compartment_id = oci_identity_compartment.my_compartment.id
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "My Security List"
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
}

ingress_security_rules {
    tcp_options {
      max = "22"
      min = "22"
    }
    protocol = "6"
    source    = "0.0.0.0/0"
}

ingress_security_rules {
    tcp_options {
      max = "80"
      min = "80"
    }
    protocol = "6"
    source    = "0.0.0.0/0"
  }
}

# Create a new instance
resource "oci_core_instance" "my_instance" {
  availability_domain = "WMYd:US-ASHBURN-AD-1"
  compartment_id      = "ocid1.compartment.oc1..aaaaaaaayyogmrj3ji365uhokskoffcezkxtmrjvnli55fqyi7utehpqumfq"
  shape               = "VM.Standard.E5.Flex"
  display_name        = "My Oracle Linux Instance"
  shape_config {
    ocpus = 1
    memory_in_gbs = 12
  }
  create_vnic_details {
    #subnet_id         = oci_core_subnet.my_subnet.id
    subnet_id = "ocid1.securitylist.oc1.iad.aaaaaaaap4do2ysyhybmx7bgc5mvgi4ccswiaiyugd6lrvzzen52etplyi7a"
    assign_public_ip = true
  }
  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.iad.aaaaaaaaiopfwqfdynconqifpbev477nkprewaynhsixjjvj2wwc2trzlxnq" # Replace with the OCID of the Oracle Linux image
  }
  #metadata = {
  #  ssh_authorized_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDl4+rHyTNfOfT8qYRfssJnbUonHnZTzb1eZE8x2UmyzCgHbHGX/N2IFLCmyoJ1EtLo6nnAA108cKh1z3ccRwqhQCOQz60hPctED0yeg4gjYLG5O1ce5OJ3O9xHE8tl35wrkR2SG/vCSpwSU8dmp31ZwZjsZisUJsQjRBpfPh4sEwI2Wm3yxoVOsOOnSHQmRhrmC0j3zMpCjPt3y1s9IQE6rFJyXTtx0KrDGfd/mu7Ja0DqnVgm/2+aJ0fDLeK+ZvB1Q1P2WjzoET7gmNG4JX4DI+CV0Eqw8i3lnf62O//TP31tUMFz1t61fT929XfPB4vI8etKIptBcTAmbIIFAREjo3zT7uGY50I6d0X07GeIAg0dDqlGuqZns/tQyhlDR5bR/Z5jw/N9ECJqZcL0g6muZxemmhoguyAtAmjUtyX+zRvQMd0HmUYKBNwNi3v13JLo9/rfvXZcf/FyTsojsugdCmYISJPw9WKhgtRdVd2ZIX287juFoyJE5wLoAJAnSk8= tom moore@thomamoo-2MQ4200HR4"
  #}
}

# Output the instance details
#output "instance_details" {
#  value = oci_core_instance.my_instance
#}