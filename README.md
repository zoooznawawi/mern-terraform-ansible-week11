# MERN-Terraform-Ansible-Week11

This repository contains the infrastructure-as-code and provisioning setup for the Week 11 assignment:
- **Terraform** code to provision an EC2 backend server and two S3 buckets (frontend & media), plus IAM roles for secure uploads.
- **Ansible** playbook and inventory to configure the EC2 instance as a MERN app server.

## Repo Structure

```
.
├── ansible
│   ├── hosts.ini         # Inventory with `ansible_ssh_private_key_file`
│   └── playbook.yml      # Tasks to install Node, Git, clone the app, and run it on port 3000
├── terraform
│   ├── main.tf           # AWS provider, VPC, SG, EC2 instance, S3 buckets, IAM, outputs
│   ├── variables.tf      # Input variable declarations
│   ├── terraform.tfvars  # Your values: key_pair_name, ami_id, frontend_bucket, media_bucket
│   ├── user-data.sh      # User data script for bootstrapping Python (pre-Ansible)
│   ├── .terraform.lock.hcl
│   └── terraform.tfstate*
├── aziz.pem              # EC2 key-pair (secure, with tightened permissions)
└── README.md             # This file
```

## Getting Started

1. **Clone repo**  
   ```bash
   git clone https://github.com/<your-username>/mern-terraform-ansible-week11.git
   cd mern-terraform-ansible-week11
   ```

2. **Terraform init & apply**  
   - Edit `terraform/terraform.tfvars` with your AWS key-pair name, AMI, and bucket names.  
   - Initialize and apply:
     ```bash
     cd terraform
     terraform init
     terraform apply -auto-approve
     ```
   - Note the EC2 public IP, S3 bucket names, and generated IAM upload keys from the Terraform outputs.

3. **SSH into EC2**  
   ```bash
   ssh -i aziz.pem ubuntu@<EC2_PUBLIC_IP>
   ```

4. **Run Ansible playbook**  
   On your local machine (where ansible is installed):
   ```bash
   cd ansible
   ansible-playbook -i hosts.ini playbook.yml
   ```
   This installs Node.js, pulls your MERN app, installs dependencies, and starts it on port 3000.

5. **Verify**  
   - Frontend bucket website: `http://<your-frontend-bucket>.s3-website-<region>.amazonaws.com`
   - Backend API: `http://<EC2_PUBLIC_IP>:3000`

## Cleanup

To avoid AWS charges:
```bash
cd terraform
terraform destroy -auto-approve
```
Optionally delete the S3 buckets via the AWS Console if any files remain.

---

*Screenshots of each step are in the `screenshots/` folder for reference.*
