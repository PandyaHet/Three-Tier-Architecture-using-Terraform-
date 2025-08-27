output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_web_subnets" {
  value = aws_subnet.public_web[*].id
}

output "private_app_subnets" {
  value = aws_subnet.private_app[*].id
}

output "private_db_subnets" {
  value = aws_subnet.private_db[*].id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.nat[*].id
}

output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}

output "private_route_table_ids" {
  value = aws_route_table.private_rt[*].id
}

output "security_group_ids" {
  value = {
    elb_sg          = aws_security_group.elb_sg.id
    web_sg          = aws_security_group.web_sg.id
    internal_elb_sg = aws_security_group.internal_elb_sg.id
    app_sg          = aws_security_group.app_sg.id
    db_sg           = aws_security_group.db_sg.id
  }
}