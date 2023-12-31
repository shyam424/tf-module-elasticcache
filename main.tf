#1-create subnet group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${local.name_prefix}-subnet-group"
  subnet_ids = var.subnet_ids
  tags = merge(local.tags, {Name = "${local.name_prefix}-sg"})
}

#2-create security group

resource "aws_security_group" "main" {
  name        = "${local.name_prefix}-sg"
  description = "${local.name_prefix}-sg"
  vpc_id      = var.vpc_id
  tags = merge(local.tags, {Name = "${local.name_prefix}-sg"})

  ingress {
    description      = "ELASTICACHE"
    from_port        = var.port
    to_port          = var.port
    protocol         = "tcp"
    cidr_blocks      = var.sg_ingress_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

#3-parameter group if any input comes-
resource "aws_elasticache_parameter_group" "main" {
  name   = "${local.name_prefix}-pg"
  family = var.family
  tags   = merge(local.tags, { Name = "${local.name_prefix}-pg" })
}


#4-elasticache cluster-
resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${local.name_prefix}-cluster"
  engine               = var.engine
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = aws_elasticache_parameter_group.main.name
  engine_version       = var.engine_version
  port                 = var.port
  subnet_group_name = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.main.id]
  tags = merge(local.tags, {Name = "${local.name_prefix}-cluster"})
}


#No need to create the instance for elasticcahse as we are generating one node
#5-instance should be created in the RDS cluster which was created above
#resource "aws_rds_cluster_instance" "main" {
#  count              = var.instance_count
#  identifier         = "${local.name_prefix}-cluster-${count.index+1}"
#  cluster_identifier = aws_rds_cluster.main.id
#  instance_class     = var.instance_class
#  engine             = aws_rds_cluster.main.engine
#  engine_version     = aws_rds_cluster.main.engine_version
#}