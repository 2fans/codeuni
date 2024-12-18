from netmiko import ConnectHandler

# Define the device details
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

# Change the hostname to '2fan'
print("Changing the hostname to '2fan'...")
config_commands = ['hostname 2fan']
connection.send_config_set(config_commands)

# Capture and save the running configuration
print("Saving the running configuration to a file...")
output = connection.send_command("show running-config")
with open('running_config.txt', 'w') as file:
    file.write(output)

# Close the connection
connection.disconnect()

# Success message
print("------------------------------------------------------")
print("SSH session established and configuration completed.")
print("Hostname successfully updated to '2fan'.")
print("Running configuration saved to 'running_config.txt'.")
print("------------------------------------------------------")
