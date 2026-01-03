locals {
  worker_user_data2 = <<-EOF
  #!/bin/bash
  sudo hostnamectl set-hostname worker2
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

  # Wait for kubeadm join token (Manual step if not automated)
  # echo "Run the following command on the master node to get the join command:"
  # echo "sudo kubeadm token create --print-join-command"

  EOF
}