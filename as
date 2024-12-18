from netmiko import ConnectHandler

# Device details
device = {
    'device_type': 'cisco_ios',
    'ip': '192.168.56.101',
    'username': 'tufan',
    'password': '123',
    'secret': '1234',  # Enable password
    'timeout': 120     # Increase timeout to 120 seconds
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
    'crypto isakmp policy 10',
    'encryption aes',
    'hash sha256',
    'authentication pre-share',
    'group 14',
    'lifetime 86400',
    'exit',
    'crypto isakmp key CISCO123 address 0.0.0.0',
    'crypto ipsec transform-set ESP-AES-SHA esp-aes esp-sha-hmac',
    'crypto map IPSEC-MAP 10 ipsec-isakmp',
    'set peer 192.168.56.200',
    'set transform-set ESP-AES-SHA',
    'match address SECURE-TRAFFIC',
    'interface GigabitEthernet1',
    'crypto map IPSEC-MAP',
    'exit'
]
connection.send_config_set(ipsec_commands)

# Step 3: Save the running configuration
print("Saving running configuration...")
output = connection.send_command("write memory")
print("Configuration saved.")

# Capture and save the current running configuration
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
print("1. ACL 'SECURE-TRAFFIC' configured and applied.")
print("2. Basic IPSec configuration applied.")
print("3. Running configuration saved to 'running_config.txt'.")
print("------------------------------------------------------")
