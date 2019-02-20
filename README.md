## Quick start
1. Download dockrouter.gns3a from the repository.
1. In GNS3, go in File, Import appliance and select the file you just downloaded.
1. Go through the Wizard using the default values.
1. Right click the device and select Configure template. Type your timezone in the Env. variables field (ex: TZ=EST5EDT)
1. Add the device on the network diagram, GNS3 will pull the Docker image.
1. You can now edit the network configuration using right click, edit config; on the device.

## Usage
The dockrouter item can be added to your network diagram like any other device.  It will start with no service running and no interface setup.  The easiest way to setup interfaces is to use GNS3 network configuration menu (right click, edit config) which will bring up a Debian ifupdown network configuration file.

Simply connecting eth0 to a NAT cloud and uncommenting `auto eth0` and `iface eth0 inet dhcp` will setup a DHCP on eth0 on boot.  You have to use full paths in pre-up/up/down/post-down stanzas, otherwise, busybox internal commands will be used first.

To start a service, right click on the dock router, select Show in file manager, navigate to etc/network/disabled, edit a configuration file then paste it in the parent folder.  The service will start and show logs on the main console.

If you need to stop the logging and get a shell, you can press ENTER on the console. If you need another terminal, right click on the dockrouter and select Auxiliary console.

## Basic commands
The service manager in this Docker is runsvdir/runsv/sv, to start/stop/get status of running services, use the sv command. Services are listed in /etc/service/.  Example usage: sv start bird4
Since this is a Ubuntu system, most other commands will be the same.
