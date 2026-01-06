Copy AWS config (after modifying account IDs) to:
```
~/.aws/config
```

Add to ~/.zshrc or ~/.bashrc:
```
# kube-starter-kit
. ~/path/to/kube-starter-kit/tools/aws/.kube-starter-kit-rc
# kube-starter-kit end
```

## Private EKS Access via Bastion

When EKS is configured with a private endpoint (`endpoint_public_access = false`), you need to access the cluster through the bastion host using a SOCKS5 proxy.

### One-time Setup

1. **Configure SSH for SSM** - Run the setup task to see the required SSH config:
   ```bash
   mise run //tools:bastion:setup-ssh-config
   ```

   Add the printed config to your `~/.ssh/config`:
   ```
   # AWS SSM Session Manager SSH proxy
   Host i-* mi-*
       User ec2-user
       ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
   ```

2. **Ensure prerequisites are installed** (mise handles this automatically):
   - AWS CLI v2
   - Session Manager plugin (`aqua:aws/session-manager-plugin`)

### Connecting to Private EKS

1. **Login to AWS SSO**:
   ```bash
   aws_sso_staging  # or aws_sso_production
   ```

2. **Get the bastion instance ID**:
   ```bash
   AWS_PROFILE=staging mise run //tools:bastion:get-instance-id staging
   # Returns: i-0abc123def456...
   ```

3. **Start the SOCKS proxy** (in a separate terminal):
   ```bash
   AWS_PROFILE=staging mise run //tools:bastion:start-proxy <instance-id>
   # Proxy runs on localhost:1080 by default
   ```

4. **Use kubectl with the proxy**:
   ```bash
   # Option A: Per-command
   HTTPS_PROXY=socks5://localhost:1080 kubectl get nodes

   # Option B: Update kubeconfig (persistent)
   kubectl config set-cluster <cluster-name> --proxy-url=socks5://localhost:1080
   ```

### Helper Functions

Add these to your shell for convenience:

```bash
# Start proxy for staging (add to .kube-starter-kit-rc)
eks_proxy_staging() {
  local instance_id
  instance_id=$(AWS_PROFILE=staging mise run //tools:bastion:get-instance-id staging)
  AWS_PROFILE=staging mise run //tools:bastion:start-proxy "$instance_id"
}
```