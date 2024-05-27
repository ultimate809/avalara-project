# avalara-project

Deployment of a kubernetes service with the following details -: 

<img width="449" alt="image" src="https://github.com/ultimate809/avalara-project/assets/29774535/0e14789c-ece4-4dc7-869c-4d166e57afaf">



* NGINX Ingress: https://kubernetes.github.io/ingress-nginx/
* Primary Image: argoproj/rollouts-demo:green
* Canary Image : argoproj/rollouts-demo:blue
* Redis Image  : redis

* The kubernetes resources are automated with terraform code.

* Procedure
  ```
  Ensure the api credentials of the cloud are configures on local where the code is being run for the terraform commands to work.
  ```
  ```
  terraform init
  terraform plan
  terraform apply --auto-approve
  ```
