locals {
  master_user_data = <<-EOF
  #!/bin/bash
  sudo hostnamectl set-hostname master
  sudo apt update && sudo apt install -y apt-transport-https ca-certificates curl
  sudo apt install -y docker.io -y
  sudo systemctl enable docker --now

  # Disable swap
  sudo swapoff -a
  sudo sed -i '/ swap / s/^/#/' /etc/fstab

  # Load kernel modules
  sudo tee /etc/modules-load.d/k8s.conf <<EOT
  overlay
  br_netfilter
  EOT

  sudo modprobe overlay
  sudo modprobe br_netfilter

  # Configure sysctl parameters for Kubernetes networking
  sudo tee /etc/sysctl.d/k8s.conf <<EOT
  net.bridge.bridge-nf-call-iptables  = 1
  net.bridge.bridge-nf-call-ip6tables = 1
  net.ipv4.ip_forward                 = 1
  EOT

  sudo sysctl --system

  sudo mkdir -m 755 /etc/apt/keyrings

  # Install Kubernetes
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

  # This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

  sudo apt-get update
  sudo apt-get install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl

  # Ensure kubelet starts on reboot
  sudo systemctl enable kubelet
  sudo systemctl restart kubelet

  sudo cat << EOT >> /etc/crictl.yaml
  runtime-endpoint: unix:///run/containerd/containerd.sock
  image-endpoint: unix:///run/containerd/containerd.sock
  timeout: 2
  debug: true
  pull-image-on-create: false
  EOT

  # Initialize the Kubernetes cluster (Use the correct pod CIDR for your CNI)
  sudo su -c "sudo kubeadm init --pod-network-cidr=10.244.0.0/16" ubuntu > /home/ubuntu/kube.txt

  # Set up kubectl for ubuntu user
  mkdir -p /home/ubuntu/.kube
  sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
  sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

  # Install weaveworks CNI
  sudo su -c "kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml" ubuntu

  EOF
}