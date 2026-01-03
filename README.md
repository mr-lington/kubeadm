# Kubernetes Cluster Deployment Using kubeadm

This project demonstrates how I built a Kubernetes cluster manually using **kubeadm**. The goal is to replicate a real-world production-style cluster setup by provisioning a control-plane node and multiple worker nodes — then securely joining them together.

This README documents the exact workflow I followed, including the kubeadm bootstrap commands and the process of joining worker nodes to the cluster.

---

##  Cluster Overview

| Component | Description |
|----------|------------|
| Bootstrap Tool | kubeadm |
| Container Runtime | containerd |
| Control Plane Nodes | 1 |
| Worker Nodes | 2 |
| OS | Linux (Ubuntu Server) |
| Pod Network CIDR | `10.244.0.0/16`  |
| CNI Plugin | Calico / Flannel |

---

##  Prepare All Servers

Run the following on **ALL NODES (master + workers)**:

### Update & install dependencies all inside bash scripts found in the master.tf and worker1&1.tf files
- You can set up the Cluster using the following commands
- I will be skipping the usual Terraform init, plan, and apply commands
- Note: after you run the Terraform command, you already have the master node running
## confirm that the master node is ready
```
kubectl get node
```
## add worker nodes to the cluster
- run the add command on each worker node's server to the cluster
- to make it easier, I save the kudeadm init key as a text file in /home/ubuntu/kube.txt inside the master node. So just run cat kube.txt inside the master server and go back to each worker node and run the commands below
```
sudo and paste the join key copied here and hit enter
```
## confirm that the workers nodes are ready
```
kubectl get node
```
##  Outcome

By the end of this setup, I successfully built a Kubernetes cluster from scratch using **kubeadm**, demonstrating real hands-on experience with:

 **Cluster bootstrapping** — initializing a secure Kubernetes control plane  
 **Secure node registration** — joining worker nodes using kubeadm tokens  
 **Container runtime configuration** — setting up containerd correctly  
 **Pod networking setup** — deploying a CNI plugin for inter-pod communication  
 **Real-world DevOps operations** — troubleshooting, validation, and lifecycle management  

This project reflects my ability to design, deploy, and operate Kubernetes at the infrastructure layer  the same concepts used in production.

## About This Project

This repository is part of my **DevOps & Cloud Engineering portfolio**, showcasing my ability to deploy, manage, and troubleshoot Kubernetes infrastructure manually using **kubeadm**. 

The project demonstrates practical, real-world skills in:

 - Cluster provisioning and bootstrap  
 - Secure node enrollment  
 - Networking and runtime configuration  
 - Observability and validation  
 - Problem-solving and troubleshooting  

By building the cluster from the ground up, I gained deep hands-on experience with the same concepts used in **production and hybrid-cloud Kubernetes environments**.

