resource "aws_instance" "bastion" {
  ami           = "ami-0e04bcbe83a83792e"
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_id
  security_groups = [var.bastion_sg_id]
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install mysql-client -y
  EOF

  tags = {
    Name = "Bastion"
  }
}

# Створюємо DB Parameter Group для MariaDB
resource "aws_db_parameter_group" "mariadb_params" {
  name   = "mariadb-utf8-parameter-group"
  family = "mariadb10.11"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "collation_server"
    value = "utf8_unicode_ci"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8"
  }

  tags = {
    Name = "mariadb-utf8"
  }
}

resource "aws_db_instance" "rds" {
  allocated_storage    = 20
  engine               = "mariadb"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  vpc_security_group_ids = [var.db_sg_id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  parameter_group_name = aws_db_parameter_group.mariadb_params.name
  
  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "RDS Subnet Group"
  }
}

resource "null_resource" "import_sql" {
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = aws_instance.bastion.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)
    }
    source      = "/home/yura/terraform/data.sql"
    destination = "/home/ubuntu/data.sql"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.bastion.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)
    }
    inline = [
      "mysql -h ${replace(aws_db_instance.rds.endpoint, ":3306", "")} -u ${var.db_username} -p${var.db_password} < /home/ubuntu/data.sql"
    ]
  }

  depends_on = [aws_instance.bastion, aws_db_instance.rds]
}

# Генеруємо YAML файл із ConfigMap
resource "local_file" "config_map_output" {
  content  = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-config
data:
  jdbc_url: "jdbc:mariadb://${replace(aws_db_instance.rds.endpoint, ":3306", "")}:3306/teachua?useUnicode=true&characterEncoding=utf8"
EOF

  filename = "/home/yura/terraform/ter/k8s-manifests/db-configMap.yaml"
}

output "db_endpoint" {
  value = aws_db_instance.rds.endpoint
}
