# dynamodb_table_backup_and_restore

## About

This project automates the workflow of backing up a DynamoDB table and restoring the backup to a target table. It uses the built-in AWS features for the backup and restore operations. The goal is only to automate the workflow and let you set different capacity units to the target table (this is currently not possible with the AWS APIs).

The worklow has been implemented in a Step Functions state machine that calls Lambda functions. Those AWS resources can be directly created with Terraform as shown below.

## Use case

My use case was the followig : backing up a production table and then restoring it in a devlopment environment with less capacity.

## The worflow

The Step Functions worklow is the following :

1. backup the origin table
1. if the target table already exists, delete it
1. restore the backup to the target table

You can of course tune it to your needs.

**Warning : the target table will be deleted if already exists**

## Usage

1. Create the AWS ressource with Terraform
This will create the Lambda functions and the Step Functions state machine
```
cd terraform
vim terraform.tfvars #Change that file with your values !
terraform init
terraform apply
```
2. Run the state machine with such an input
```
{
  "originTableName": "clients",
  "backupName": "clients_backup",
  "targetTableName": "clients_restored",
  "desiredReadCapacityUnits": 3,
  "desiredWriteCapacityUnits": 3
}
```
3. Automate the state machine execution with a Clouwatch event rule ?

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.