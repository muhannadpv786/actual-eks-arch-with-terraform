**EKS CLUSTER MANAGEMENT USING TERRAFORM** 

This repository is to setup Custom VPC, and then provision  EKS Cluster in the Custom VPC in AWS.


Fork this repository, and inside the folder where you have tf files, execute the terraform commands.

**Check the plan and verify the resources that would be created**

```
terraform plan

```
**Apply the configuration to provision the infra using terraform**

```
terraform apply -auto-approve [in real time, do not use -auto-approve flag, instead use without it and double check if right resources are getting provisioned.]
```

**Destroying Infra after the completion of activity**

```
terraform destroy -auto-approve [in real time, do not use -auto-approve flag, instead use without it and double check if right resources are getting deleted.]

```

**VPC (vpc.tf):**

```
1. Using the file vpc.tf file , the vpc, subnets both private and public would be created.
2. It will create Internet Gateway and attach to VPC
3. It will create the NAT gateway in public subnet, which will be used by worker nodes in private subnets
4. We will then create two route tables, one for public subnet and one for private subnet. 
```

**EKS Control Plane (eks.tf):**

```
1. With the help of eks.tf, we will create the eks control plane, which includes few of the configuration details such as kubernetes version, vpc details, end point access details etc. 
2. We also create the IAM role and few policies required for EKS Control plane node
3. We will attach the IAM Role to the EKS control plane, this is provided by role_arn in eks cluster resource itself.
```

**EKS Worker Nodes (eks-private-ng.tf):**

```
1. With the help of eks-private-ng.tf , it would create a node group  and the desired size of nodes we define for the size of cluster.
2. It also creates a role and attaches 3 policies which are required for EKS worker node groups which are mandatory, and the fourth policy is related to Autoscaling, which is used by Cluster Austoscaler, as we would also autoscale the cluster as per our requirement with the help of the CA.
3. It will create a config file with your cluster configuration which got created under .kube directory which resides in your home directory. This file generation is mandatory to be present in order to authenticate to cluster and also do other tasks which would be done inside the EKS cluster. 
```

**OIDC**

```
Amazon EKS supports using OpenID Connect (OIDC) identity providers as a method to authenticate users to your cluster. OIDC identity providers can be used with, or as an alternative to AWS Identity and Access Management (IAM). 

With the help of oidc.tf, i am adding OIDC as an identity provider to AWS IAM. 

```

**EKS Addons (eks-addons.tf):**

```
 There are few addons which would be installed on eks cluster, as per your needs you can add any other addons if required.

 ALB Ingress controller (Alb-controller-iam-role-policy.tf): 

 It will install ingress controller once cluster is setup and config file is generated. This ingress controller would be helpful for Ingress resources to provision ALB. 
```

**Cluster Autoscaler IAM Role (cluster-autoscaler.tf):**

```
This tf file cluster-autoscaler.tf would create required IAM Role and policies for Cluster autoscaler to work properly.
```

**Cluster Autoscaler**

```
Before installing cluster autoscaler, please update the cluster name in the file manifests/cluster-autoscaler/cluster-autoscaler-autodiscover.yaml at line number 165, with the name you provided while provisioning the cluster.

With the help of manifest file under manifests/cluster-autoscaler/cluster-autoscaler-autodiscover.yaml, we can deploy cluster autoscaler.

Copy this file on the bastion server and execute the below command. 

kubectl apply -f cluster-autoscaler-autodiscover.yaml

```

**Bastion Server**

```
To simulate the realtime scenario, we have created Bastion server in public subnet, in order to access the EKS cluster.


By default, you would not be able to connect to the EKS Cluster through your laptops directly, you would need to connect to Bastion Host.


During the Bastion Server provisioning, i have executed the shell script, which will install aws cli, kubectl on the server, which would be used to configure aws credentials and also to connect to cluster. 

NOTE:  YOU WILL FIND A KEY PAIR DOWNLOADED LOCALLY IN YOUR FOLDER WITH NAME SOMETHING LIKE  "tf-key-pair-0a2f96df". 

you can use the above similar key which gets created to ssh to server using public ip it assigned to bastion server. 

Here we have few pre-requisites to be done.

1. First you need to configure your aws credentials with profile or without profile (usually multiple teams will have multiple profiles, such as Devops , developers, qa-team etc )

2. Next, we need to execute the below command to generate config file to authenticate to cluster. here we can again provide --profile option as well to connect. 

aws eks --region us-east-1 update-kubeconfig --name my-eks-cluster

# Replace the correct region and name of cluster in above command. 

3. Create RBAC permissions for the users you want to provide access to the cluster. Here, we have provided access to users "devops" and "eksdeveloper". 
If the users are provided proper access through role and rolebindings, then only the users can communicate with the cluster.  

3. Next, you can execute the kubectl commands.
```
