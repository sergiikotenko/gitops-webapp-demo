0. Before start
0.1 - login via saml into dev account
0.1.2 - Connect to the VPN
0.2 - select k8s context (kubectx)
0.3 - forward ports: kubectl port-forward svc/argocd-server -n argocd 8083:80
0.4 - log in as a admin user:  argocd login localhost:8083 --username admin --password <P@ssw0rd>



ArgoCD: https://argocd.dev.central.sixt-leasing.com/applications/web-app-dev
GH  Actions: https://github.com/sergiikotenko/gitops-webapp-demo/actions

gitops-webapp-demo (main)$:
	k apply -f argocd.yaml (expected result - new projects are created)
	check GH Action (expected result: build and deploy are OK)
	Check ArgoCD (expected result: new image are delivered to the k8s)


Open question:
 - [/] divide application into 2 parts - application and gitops (k8s config files, kustomize etc)
  - [/] git@github.com:sergiikotenko/gitops-infra-demo.git k8s base files
  - 
 - How to promote image to another environment - via pull request?
 - similar ENV_VARS with different values

--- 
UserManagement
 ```
 ArgoCD has no built-in user management and relies on Signle Sign-On to be configured. With Single-Sign On configured, ArgoCD roles can be applied to OIDC groups. By default, ArgoCD has two built-in roles: role:readonly and role:admin.
 ```
 There are two ways that SSO can be configured:

* Bundled Dex OIDC provider - use this option if your current provider does not support OIDC (e.g. SAML, LDAP) or if you wish to leverage any of Dex's connector features (e.g. the ability to map GitHub organizations and teams to OIDC groups claims).

* Existing OIDC provider - use this if you already have an OIDC provider which you are using (e.g. Okta, OneLogin, Auth0, Microsoft, Keycloak, Google (G Suite)), where you manage your users, groups, and memberships.

We will use the **Bundled Dex OIDC provider**
1. Register the application in the identity provider¶
In GitHub, register a new application. The callback address should be the /api/dex/callback endpoint of your Argo CD URL (e.g. https://argocd.example.com/api/dex/callback).

1. Create/add new user via argocd-cm:
sergio@laptop:~/work/git/tools $ argocd account list
NAME   ENABLED  CAPABILITIES
admin  true     login
sergio@laptop:~/work/git/tools $ k get cm -n argocd
NAME                        DATA   AGE
argocd-cm                   1      28d
argocd-gpg-keys-cm          0      28d
argocd-rbac-cm              0      28d
argocd-ssh-known-hosts-cm   1      28d
argocd-tls-certs-cm         0      28d
istio-ca-root-cert          1      28d
sergio@laptop:~/work/git/tools $ k edit cm/argocd-cm -n argocd
configmap/argocd-cm edited
sergio@laptop:~/work/git/tools $ 
sergio@laptop:~/work/git/tools $ 
sergio@laptop:~/work/git/tools $ argocd account list
NAME       ENABLED  CAPABILITIES
admin      true     login
developer  true     apiKey, login
sergio@laptop:~/work/git/tools $ 

sergio@laptop:~/work/git/tools $ k get cm/argocd-cm -n argocd -o yaml    
apiVersion: v1
data:
  accounts.developer: apiKey, login
  accounts.developer.enabled: "true"
  ...
  skipped
  ...

1.1  Change password for the new user (current password is admins password):
	argocd account update-password --account developer --new-password <P@ssw0rd>


ArgoCD ConfigMap argocd-rbac-cm Example:
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.default: role:readonly
  policy.csv: |
  	p, role:demo-developers, applications, create, web-app-dev/*, allow
	  p, role:demo-developers, applications, delete, web-app-dev/*, allow
	  p, role:demo-developers, applications, get, web-app-dev/*, allow
	  p, role:demo-developers, applications, override, web-app-dev/*, allow
	  p, role:demo-developers, applications, sync, web-app-dev/*, allow
	  p, role:demo-developers, applications, update, web-app-dev/*, allow
	  p, role:demo-developers, projects, get, web-app-dev, allow
	  g, developer, role:demo-developers

---
# SSO via DEX
1. Register new application in the GitHub https://github.com/settings/applications
2. Configure argocd for SSO:
	```
	k edit cm/argocd-cm -nargocd

	apiVersion: v1
	data:
  	url: https://argocd.dev.central.sixt-leasing.com
  	dex.config: |
	    connectors:
      	# GitHub example
      	- type: github
	        id: github
        	name: GitHub
        	config:
          	clientID: 317227e2954d65921b0f
          	clientSecret: 85d47c900d2bfad829ff66d2b9ecabe10e9d2a8c
          	orgs:
          	- name: SLSE-IT
	```
3. 
