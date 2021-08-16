# document
resource "aws_ssm_document" "aws-ssm-playbook-doc" {
  name          = "${var.aws_prefix}-ssm-playbook-doc-${random_string.aws-suffix.result}"
  document_type = "Command"
  content       = <<DOC
  {
    "schemaVersion": "2.2",
    "description": "Ansible Playbooks via SSM - installs/executes Ansible properly on RHEL7",
    "parameters": {
    "SourceType": {
      "description": "(Optional) Specify the source type.",
      "type": "String",
      "allowedValues": [
      "GitHub",
      "S3"
      ]
    },
    "SourceInfo": {
      "description": "Specify 'path'. Important: If you specify S3, then the IAM instance profile on your managed instances must be configured with read access to Amazon S3.",
      "type": "StringMap",
      "displayType": "textarea",
      "default": {}
    },
    "PlaybookFile": {
      "type": "String",
      "description": "(Optional) The Playbook file to run (including relative path). If the main Playbook file is located in the ./automation directory, then specify automation/playbook.yml.",
      "default": "hello-world-playbook.yml",
      "allowedPattern": "[(a-z_A-Z0-9\\-)/]+(.yml|.yaml)$"
    },
    "ExtraVariables": {
      "type": "String",
      "description": "(Optional) Additional variables to pass to Ansible at runtime. Enter key/value pairs separated by a space. For example: color=red flavor=cherry",
      "default": "SSM=True",
      "displayType": "textarea",
      "allowedPattern": "^$|^\\w+\\=[^\\s|:();&]+(\\s\\w+\\=[^\\s|:();&]+)*$"
    },
    "Verbose": {
      "type": "String",
      "description": "(Optional) Set the verbosity level for logging Playbook executions. Specify -v for low verbosity, -vv or vvv for medium verbosity, and -vvvv for debug level.",
      "allowedValues": [
      "-v",
      "-vv",
      "-vvv",
      "-vvvv"
      ],
      "default": "-v"
    }
    },
    "mainSteps": [
    {
      "action": "aws:downloadContent",
      "name": "downloadContent",
      "inputs": {
      "SourceType": "{{ SourceType }}",
      "SourceInfo": "{{ SourceInfo }}"
      }
    },
    {
      "action": "aws:runShellScript",
      "name": "runShellScript",
      "inputs": {
      "runCommand": [
        "#!/bin/bash",
        "# Ensure ansible and unzip are installed",
        "/bin/yum -y install python2-pip unzip",
        "/bin/pip install awscli ansible boto botocore boto3 --upgrade",
        "echo \"Running Ansible in `pwd`\"",
        "for zip in $(find -iname '*.zip'); do",
        "  unzip -o $zip",
        "done",
        "PlaybookFile=\"{{PlaybookFile}}\"",
        "if [ ! -f  \"$${PlaybookFile}\" ] ; then",
        "   echo \"The specified Playbook file doesn't exist in the downloaded bundle. Please review the relative path and file name.\" >&2",
        "   exit 2",
        "fi",
        "export AWS_DEFAULT_REGION=${var.aws_region} && export AWS_REGION=${var.aws_region} && /bin/ansible-playbook -i \"localhost,\" -c local -e \"{{ExtraVariables}}\" \"{{Verbose}}\" \"$${PlaybookFile}\""
      ]
      }
    }
    ]
  }
DOC
}

# association
resource "aws_ssm_association" "aws-ssm-assoc" {
  association_name = "${var.aws_prefix}-ssm-assoc-${random_string.aws-suffix.result}"
  name             = aws_ssm_document.aws-ssm-playbook-doc.name
  targets {
    key    = "tag:eks:cluster-name"
    values = ["${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result}"]
  }
  output_location {
    s3_bucket_name = aws_s3_bucket.aws-s3-bucket.id
    s3_key_prefix  = "ssm"
  }
  parameters = {
    ExtraVariables = "SSM=True aws_prefix=${var.aws_prefix} aws_suffix=${random_string.aws-suffix.result}"
    PlaybookFile   = "eks-node.yml"
    SourceInfo     = "{\"path\":\"https://s3.${var.aws_region}.amazonaws.com/${aws_s3_bucket.aws-s3-bucket.id}/playbook/\"}"
    SourceType     = "S3"
    Verbose        = "-v"
  }
  depends_on = [aws_iam_role_policy_attachment.aws-eks-node-policy-attach-1, aws_iam_role_policy_attachment.aws-eks-node-policy-attach-2, aws_iam_role_policy_attachment.aws-eks-node-policy-attach-3, aws_iam_role_policy_attachment.aws-eks-node-policy-attach-4, aws_iam_role_policy_attachment.aws-eks-node-policy-attach-5, aws_s3_bucket_object.aws-s3-bucket-playbook-files]
}
