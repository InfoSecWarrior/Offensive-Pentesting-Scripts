<h1 align=center>VPN Tunneling Bash Script </h1>

<p align="center">
  <a href="#description">Description</a> •
  <a href="#prerequisites">Prerequisites</a> •
  <a href="#example">Example</a>
</p>

## Description
This script automates the process of setting up a VPN connection between a local machine and a remote server, which can be useful for various purposes such as accessing private networks securely, connecting to remote servers securely, or bypassing network restrictions.

## Prerequisites

-   The sshpass command must be installed on your local machine.
-   The remote server must allow root login.
-   The remote server must have either rpm or dpkg package manager installed.

## Example

*To use this script,* first, save it in a file with the extension **.sh**. *For example,* you can save it as **vpn_tunnel.sh.**

- **Next,** open a terminal window and navigate to the directory where the script is saved. Make sure the script has execute permissions by running the following command:

  ```
  chmod +x vpn_tunnel.sh
  ```

- *Now you can run the script using the following command:*

  ```
  ./vpn_tunnel.sh
  ```

- **The script will prompt you to enter:**

  ```bash
  Target SSH username:     
  Target SSH IP address: 
  Target SSH IP port number: 
  Target SSH root user password: 
  ```
*Once you've provided the required information, the script will SSH into the server and set up a VPN tunnel between your local machine and the server.*

***After the script completes successfully, you should see the following information on your terminal:***

- **Target IP Address:** The IP address of the server you connected to
- **Target IP Address With GW :** The IP address of the server with the gateway
- **Target IP Interface Name:** The name of the server's interface
- **Target IP Range:** The range of the server's IP address

*You can now use the VPN tunnel to communicate with the server.*
