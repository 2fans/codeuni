from netmiko import ConnectHandler

# Device details
device = {
    'device_type': 'cisco_ios',
    'ip': '192.168.56.101',
    'username': 'tufan',
    'password': '123',
    'secret': '1234',  # Enable password
}

# Establish SSH connection
print("Connecting to the device...")
connection = ConnectHandler(**device)

# Enter enable mode
print("Entering enable mode...")
connection.enable()

# Step 1: Configure Access Control Lists (ACLs)
print("Configuring ACLs for inbound and outbound traffic control...")
acl_commands = [
    'ip access-list extended SECURE-TRAFFIC',
    'permit ip 192.168.56.0 0.0.0.255 any',  # Allow traffic from the internal network
    'deny ip any any log',                  # Deny all other traffic and log it
    'interface GigabitEthernet1',
    'ip access-group SECURE-TRAFFIC in',    # Apply ACL inbound
    'exit'
]
connection.send_config_set(acl_commands)

# Step 2: Configure IPSec
print("Configuring basic IPSec...")
ipsec_commands = [
    # ISAKMP Phase 1 configuration
    'crypto isakmp policy 10',
    'encryption aes',
    'hash sha256',
    'authentication pre-share',
    'group 14',
    'lifetime 86400',
    'exit',

    # Pre-shared key for authentication
    'crypto isakmp key CISCO123 address 0.0.0.0',

    # Phase 2: Configure transform set
    'crypto ipsec transform-set ESP-AES-SHA esp-aes esp-sha-hmac',
    'exit',

    # Create a crypto map and associate it with the ACL
    'crypto map IPSEC-MAP 10 ipsec-isakmp',
    'set peer 192.168.56.200',  # Replace with the remote peer IP
    'set transform-set ESP-AES-SHA',
    'match address SECURE-TRAFFIC',
    'exit',

    # Apply the crypto map to the interface
    'interface GigabitEthernet1',
    'crypto map IPSEC-MAP',
    'exit'
]
connection.send_config_set(ipsec_commands)

# Step 3: Capture and save the running configuration
print("Capturing running configuration...")
output = connection.send_command("show running-config")
with open('running_config.txt', 'w') as file:
    file.write(output)

# Close the SSH session
connection.disconnect()

# Success message
print("------------------------------------------------------")
print("Device configuration completed successfully.")
print("Tasks Achieved:")
print("1. ACL 'SECURE-TRAFFIC' configured and applied to interface.")
print("2. Basic IPSec configured with ISAKMP policy, pre-shared key, and transform set.")
print("3. Running configuration saved to 'running_config.txt'.")
print("------------------------------------------------------")
