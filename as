import pexpect

ip_address = '192.168.56.101'
username = 'tufan'
password = '123'
password_enable = '1234'

session = pexpect.spawn('ssh ' + username + '@' + ip_address, encoding='utf-8', timeout=20)
result = session.expect(['Password:', pexpect.TIMEOUT, pexpect.EOF])

if result != 0:
    print(f"Error: Unable to initiate an SSH session to {ip_address}. Please verify the network connection and credentials.")
    exit()

session.sendline(password)
result = session.expect(['>', pexpect.TIMEOUT, pexpect.EOF])

if result != 0:
    print("Error: Authentication failed. Verify the password and try again.")
    exit()

session.sendline('enable')
result = session.expect(['Password:', pexpect.TIMEOUT, pexpect.EOF])

if result != 0:
    print("Error: Failed to enter privileged EXEC mode. Check the enable mode settings.")
    exit()

session.sendline(password_enable)
result = session.expect(['#', pexpect.TIMEOUT, pexpect.EOF])

if result != 0:
    print("Error: Enable mode authentication failed. Verify the enable password.")
    exit()

session.sendline('configure terminal')
result = session.expect([r'.\(config\)#', pexpect.TIMEOUT, pexpect.EOF])

if result != 0:
    print("Error: Unable to enter configuration mode. Please check the device configuration.")
    exit()

session.sendline('hostname R1')
result = session.expect([r'R1\(config\)#', pexpect.TIMEOUT, pexpect.EOF])

if result != 0:
    print("Error: Failed to set the hostname. Verify the command and device response.")
    exit()

session.sendline('exit')
session.sendline('exit')

print("------------------------------------------------------")
print("SSH session established and device configuration completed.")
print(f"Device IP: {ip_address}")
print(f"Username: {username}")
print("Hostname successfully updated to 'R1'.")
print("------------------------------------------------------")

session.close()
