#!/bin/bash
cat >/etc/teleport.d/conf <<EOF
TELEPORT_ROLE=agent
EC2_REGION=${region}
# Global settings
TELEPORT_AGENT_NAME=${teleport_agent_name}
TELEPORT_JOIN_TOKEN=${teleport_join_token}
TELEPORT_PROXY_SERVER_LB=${teleport_proxy_hostname}
# DB
TELEPORT_AGENT_DB_ENABLED=${teleport_agent_db_enabled}
TELEPORT_AGENT_DB_DESCRIPTION="${teleport_agent_db_description}"
TELEPORT_AGENT_DB_LABELS="${teleport_agent_db_labels}"
TELEPORT_AGENT_DB_NAME=${teleport_agent_db_name}
TELEPORT_AGENT_DB_REGION=${teleport_agent_db_region}
TELEPORT_AGENT_DB_REDSHIFT_CLUSTER_ID=${teleport_agent_db_redshift_cluster_id}
TELEPORT_AGENT_DB_PROTOCOL=${teleport_agent_db_protocol}
TELEPORT_AGENT_DB_URI=${teleport_agent_db_uri}
# Application
TELEPORT_AGENT_APP_ENABLED=${teleport_agent_app_enabled}
TELEPORT_AGENT_APP_DESCRIPTION="${teleport_agent_app_description}"
TELEPORT_AGENT_APP_LABELS="${teleport_agent_app_labels}"
TELEPORT_AGENT_APP_INSECURE_SKIP_VERIFY=${teleport_agent_app_insecure_skip_verify}
TELEPORT_AGENT_APP_NAME=${teleport_agent_app_name}
TELEPORT_AGENT_APP_PUBLIC_ADDR="${teleport_agent_app_public_addr}"
TELEPORT_AGENT_APP_URI=${teleport_agent_app_uri}
# SSH
TELEPORT_AGENT_SSH_ENABLED=${teleport_agent_ssh_enabled}
TELEPORT_AGENT_SSH_LABELS="${teleport_agent_ssh_labels}"
EOF