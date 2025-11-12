resource "aws_instance" "back" {
    ami = var.ami
    instance_type = var.instance-type
    key_name = var.key-name
    subnet_id = aws_subnet.pub1.id
    vpc_security_group_ids = [aws_security_group.bastion-host.id ]
    associate_public_ip_address = true
    tags = {
      Name= "bastion-server"
    }
}



resource "null_resource" "remote_sql_exec" {
  depends_on = [
    aws_db_instance.rds,
    aws_instance.back
  ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("C:/Users/RAJASHRI/Downloads/us-east-1.pem")       # path to your local PEM file
      host        = aws_instance.back.public_ip
      timeout     = "5m"
    }

  provisioner "file" {
    source      = "./init.sql"
    destination = "/tmp/init.sql"
  }

  provisioner "remote-exec" {
    inline = [
      #"sudo dnf install -y mariadb105",
      #"mysql -h ${aws_db_instance.rds.address} -u ${aws_db_instance.rds.username} -p${aws_db_instance.rds.password} ${aws_db_instance.rds.db_name} < /tmp/init.sql"
      "sudo dnf install -y mariadb105",
    # Log for debugging
    "echo 'Running DB initialization...' | tee /tmp/mysql_exec.log",
    # safer quoting
    "mysql -h ${aws_db_instance.rds.address} -u ${aws_db_instance.rds.username} -p'${aws_db_instance.rds.password}' ${aws_db_instance.rds.db_name} < /tmp/init.sql 2>&1 | tee -a /tmp/mysql_exec.log"
    ]
  }

  triggers = {
    run_always = timestamp()
  }
}
