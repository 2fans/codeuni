import pexpect

ip_address = '192.168.56.101'
username = 'tufan'
password = '123'
password_enable = '1234'

# Start SSH session
session = pexpect.spawn('ssh ' + username + '@' + ip_address, encoding='utf-8', timeout=20)
session.expect('Password:')
session.sendline(password)
session.expect('>')

# Enter enable mode
session.sendline('enable')
session.expect('Password:')
session.sendline(password_enable)
session.expect('#')

# Enter configuration mode and change hostname to 2fan
session.sendline('configure terminal')
session.expect(r'\(config\)#')
session.sendline('hostname 2fan')
session.expect(r'2fan\(config\)#')
session.sendline('exit')
session.expect('#')

# Capture and save running configuration
session.sendline('show running-config')
session.expect('#', timeout=30)
running_config = session.before  # Capture the command output

with open('running_config.txt', 'w') as file:
    file.write(running_config)

# Exit the session
session.sendline('exit')
session.close()

# Success message
print("------------------------------------------------------")
print("SSH session established and device configuration completed.")
print(f"Device IP: {ip_address}")
print(f"Username: {username}")
print("Hostname successfully updated to '2fan'.")
print("Running configuration saved to 'running_config.txt'.")
print("------------------------------------------------------")

