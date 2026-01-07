# PANORAMICA - AWS 3-Tier Infrastructure with Terraform

Questo repository contiene una configurazione Terraform per creare un’infrastruttura AWS completa per un’applicazione web: VPC, subnet pubbliche e private, NAT Gateway, Internet Gateway, Application Load Balancer (ALB), Auto Scaling Group (ASG) con Launch Template, istanze Amazon Linux che servono contenuti web, e un database RDS PostgreSQL in subnet private. Lo scopo è fornire un ambiente multi-AZ sicuro e scalabile per un sito web semplice.

## File principali e loro scopo

* **network.tf** — definisce VPC, subnet pubbliche e private, IGW, route table e associazioni.

* **nat-gateway.tf** — EIP, NAT Gateway, route table per subnet private e associazioni.

* **providers.tf** — blocco terraform e provider aws (versione ~> 5.0) e regione di default.

* **variables.tf** — variabili usate dal progetto (es. my_ip, aws_region, db_password).

* **security_groups.tf** — security group per ALB, web server e RDS con regole ingress/egress.

* **compute.tf** — data source AMI e (commentata) risorsa EC2 di esempio.

* **launch-template.tf** — launch template usato dall’ASG (user_data codificato in base64).

* **alb.tf** — ALB, target group, listener e (commentata) attachment.

* **asg.tf** — Auto Scaling Group che usa il Launch Template e si collega al Target Group.

* **rds.tf** — subnet group e risorsa aws_db_instance per PostgreSQL.

* **outputs.tf** — output Terraform definiti: alb_dns_name, rds_endpoint (e commento per IP server).

## Caratteristiche dell'Infrastruttura

L'ambiente viene distribuito nella VPC `VPC-Progetto-Sicurezza` e si sviluppa su due Zone di Disponibilità (AZ) per garantire l'alta affidabilità (High Availability).

* **Livello di Bilanciamento**: Un Application Load Balancer (`alb-web-server`) gestisce il traffico in entrata nelle subnet pubbliche.
* **Livello Applicativo**: Un Auto Scaling Group gestisce istanze EC2 in subnet private. La connettività in uscita per l'aggiornamento dei pacchetti è garantita tramite il `NAT-Gateway-Principal`.
* **Livello Dati**: Database PostgreSQL (`progetto-postgres-db`) configurato in Multi-AZ per il failover automatico, segregato in subnet private.

## Sicurezza e Controllo degli Accessi

L'isolamento delle risorse è gestito attraverso il concatenamento dei Security Group (SG). Ogni livello comunica con il successivo utilizzando i riferimenti degli ID dei Security Group invece di range IP statici:

| Security Group | Sorgente Autorizzata | Porta | Descrizione |
| :--- | :--- | :--- | :--- |
| **ALB SG** | `0.0.0.0/0` | 80 (HTTP) | Ingresso pubblico |
| **Web SG** | `Security Group ALB` | 80 (HTTP) | Traffico inoltrato dal bilanciatore |
| **Web SG** | `Il tuo IP Pubblico` | 22 (SSH) | Accesso per manutenzione |
| **RDS SG** | `Security Group Web` | 5432 (DB) | Accesso al database limitato al layer web |

### Gestione delle Password
In un contesto di produzione reale, la gestione della password del database dovrebbe avvenire tramite servizi dedicati come **AWS Secrets Manager** o **AWS SSM Parameter Store**. 

In questa implementazione, per mantenere il setup semplice e focalizzato sull'architettura, è stata utilizzata una variabile Terraform. Per garantire comunque un livello di sicurezza adeguato, il valore della password deve essere definito in un file `terraform.tfvars` locale, il quale è escluso dal controllo di versione tramite `.gitignore`.

## Utilizzo

### Prerequisiti
* Terraform v1.0 o superiore.
* AWS CLI configurato con profilo amministrativo.
* Una Key Pair SSH denominata `progetto-chiave` già presente nella console AWS della regione scelta.

### Deployment
1.  Inizializzare il progetto:
    ```bash
    terraform init
    ```

2.  Configurare le variabili d'ingresso creando un file `terraform.tfvars`:
    ```hcl
    db_password = "password_sicura_scelta_da_te"
    my_ip       = "tuo_ip_pubblico/32"
    ```

3.  Pianificare e applicare la configurazione:
    ```bash
    terraform plan
    terraform apply
    ```
### Connessione al DB
L'RDS è creato con `publicly_accessible = false` per motivi di sicurezza. Per connettersi in ambiente reale è necessario usare una macchina nella stessa VPC (es. bastion) o AWS Session Manager.

Se vuoi testare la connessione localmente, puoi recuperare l'endpoint con:
  terraform output -raw rds_endpoint

Per demo controllate si può aprire un tunnel SSH tramite un bastion (non incluso qui) o usare SSM; non inclusi comandi che richiedono chiavi o password nel repo.

### Pulizia Risorse
Per rimuovere tutti i componenti creati ed evitare costi non necessari (in particolare per il NAT Gateway e l'istanza RDS Multi-AZ):

```bash
terraform destroy
```
## Note di sicurezza e best practice
* **RDS**

   * `multi_az = true` garantisce alta disponibilità; `publicly_accessible = false` mantiene il DB non esposto pubblicamente.

   * In produzione impostare `skip_final_snapshot = false` per preservare dati prima della distruzione.

* **Security Groups**

    * Il web server accetta HTTP solo dall’ALB; SSH è limitato a `my_ip`.

    * Evitare `0.0.0.0/0` su porte sensibili.

* **Segreti**

    * Spostare `db_password` in Secrets Manager o SSM e referenziarlo tramite data source.

* **ASG e subnet**

    * Le istanze dell’ASG sono lanciate in subnet private; per debug creare un bastion host o abilitare temporaneamente accesso controllato.

* **Costi**

    * NAT Gateway, RDS Multi-AZ e ASG generano costi. Verificare limiti e budget prima di eseguire `apply`.
  
## Outputs e debug
* **Output principali**
  * `alb_dns_name` — DNS pubblico dell’ALB (URL per accedere al sito).
  * `rds_endpoint` — endpoint del database PostgreSQL.
  
* **Debug comuni**
  * *Errore IAM/permessi*: assicurati che le credenziali abbiano permessi per creare VPC, EC2, RDS, ELB, NAT, EIP, ecc.
  * *Key pair mancante*: crea la key pair `progetto-chiave`