# Modular AWS EKS Infrastructure with Terraform & MiniStack

![Terraform](https://img.shields.io/badge/Terraform-1.7+-623CE4?logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-326CE5?logo=kubernetes&logoColor=white)
![MiniStack](https://img.shields.io/badge/MiniStack-Zero--Cost%20Cloud-FF6C37)
![CI/CD](https://img.shields.io/badge/GitHub%20Actions-Automated%20CI-2088FF?logo=github-actions&logoColor=white)

Infraestrutura como Código (IaC) corporativa e modular para provisionamento de clusters **AWS EKS** e redes **VPC**, preparada para testes locais de custo zero via **MiniStack** e pronta para deploy em produção na AWS.

---

## 🏛️ Arquitetura

```mermaid
graph TD
    subgraph VPC ["AWS VPC (10.0.0.0/16)"]
        subgraph PublicSubnets ["Public Subnets (us-east-1a / us-east-1b)"]
            IGW[Internet Gateway]
            ALB[Application Load Balancer]
        end

        subgraph PrivateSubnets ["Private Subnets (us-east-1a / us-east-1b)"]
            EKS_CP[EKS Control Plane]
            NG[Managed Node Groups]
            EKS_CP --- NG
        end
    end