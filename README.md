# Sailarr
This is a guide and compilation of docker-compose file's and setup alongside goals I need the help of the community to accomplish
## The Contents
This guide will show a full setup of Sonarr, Radarr, Lidarr, Bazarr, Prowlarr, Jdownloader, qBittorrent & SLSKD all ran through Private Internet Access VPN (more vpn's if I ever get the time or money to do so) and port forwarded to allow full connectability for anything that requires it be port forwarded. (Only qbittorrent or slskd can be port forwarded not both and the port is randomized as per Private Internet Accesses port forwarding abilities.
## What I need help with 
- Combining Beets (https://www.beets.io) and lidarr into one big organized family as I prefer beets due to its customizability and plugins allowing useful features such as the fetchart and missing plugins for Beets. This looks promising but I cannot get it working on my end (https://r.nf/r/Lidarr/comments/c1enh9/beets_lidarr/)
- Combining SLSKD into lidarr and having it show up in the search results for lidarr as I really like Soulseek's ability to find Music due to it's massive collection but there is no official way to combine it into Lidarr and the ability to do that would be a godsend. I believe I should be able to integrate a manual importation where you do manual searches on slsk and it imports and goes through beets but as of now I don't know.
- Usenet. I don't have the money right now to be shelling out for a provider and indexer but if I get money or someone else pitches in with usenet information and such that would be wonderful.
## Thanks to the people below for stuff that has helped with this early version
https://github.com/telyn for the automagic flac splitter for certain areas that prefer music distribution in a single flac/cue format instead of multi track with the original names and such as I like.
u/SpongederpSquarefap on reddit for the original script which I have since modified from the original: Their script is here (https://gitlab.com/-/snippets/1878730/raw/master/docker-compose.yml) and the reddit post is here (https://r.nf/r/Piracy/comments/cuzmro/guide_how_to_set_up_docker_containers_to/).
https://linuxserver.io for their fantastic docker images and documentation.
and
Everyone involved in developing all the fantastic software here from radarr to qbittorrent to slskd I thank you all for the amazing software.
# Guide
Now on with the guide
```
version: '2'

# Last updated
# 10/08/21

services:
  # VPN container
  # All containers force their network traffic through this container
  pia:
    container_name: pia
    image: qmcgaw/gluetun
    restart: always
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
    network_mode: bridge
    volumes:
```
Nothing up until this point should be changed (unless you know what you're doing/why you're doing it) as all it is doing is showing the version when it was last updated, the devices, network_mode, etc etc
```
      - /path/to/pia/docker/forwardedport:/gluetun
    ports:
     # Host:Container/tcp|udp
     # If not specified it will be TCP
     # PIA
     - 6881:6881
     # PIA
     - 6881:6881/udp
     # Radarr
     - 7878:7878
     # qBittorrent
     - 8080:8080
     # Sonarr
     - 8989:8989
     # Lidarr
     - 8686:8686
     # Beets
     - 8337:8337
     # Prowlarr
     - 9696:9696
     # Bazarr
     - 6767:6767
     # Slskd
     - 5000:5000
     - 5001:5001
     # Add more ports here as needed
```
Some of the things in this area should be changed such as the first variable of 
```
       - /path/to/pia/docker/forwardedport:/gluetun
```
Which should be at a place you can easily access it such as the path to your gluetun/pia docker image configuration as it will be where the port you have to forward will be put in a document.
The other configuration to be done here is mostly done for you as all of these numbers and such are the ports normally used by these programs, you will only ever have to add new stuff this when you add new programs to the scripts if you ever choose too (if you do please submit a pr and I will consider adding it to the script) and it is the ports usually described by the same variable of ports: xxxx:xxxx near the end of a script.
```
    environment:
      # Change these variables to your own
      # PIA username and password
      - USER=user
      - PASSWORD=pass
      # Your PIA region
      - REGION=AU Sydney
      # Your subnet (type ipconfig to find yours)
      - EXTRA_SUBNETS=192.168.232.1/24
      # Port Forwarding
      - PORT_FORWARDING=on
      - PORT_FORWARDING_STATUS_FILE=/gluetun/forwarded_port
      # Don't change anything below here
      - ENCRYPTION=strong
      - PROTOCOL=udp
      - NONROOT=no
      - DOT=on
      - BLOCK_MALICIOUS=on
      - BLOCK_NSA=off
      - UNBLOCK=
      - FIREWALL=on
      - PROXY=on
      - PROXY_LOG_LEVEL=Critical
      - PROXY_USER=
      - PROXY_PASSWORD=
```
Change the USER & PASSWORD variables to your own username && password for pia and the region can either stay static as AU Sydney if you want the Australian Sydney server or be changed to something of your choosing like the netherlands.
EXTRA_SUBNETS Should be changed to your own subnet which will be the first bit of your ip (e.g if you type ifconfig or ip a and you get a response like 192.168.232.230/24 or 192.168.1.3/24 etc it is the first 3 numbers (192.168.1) plus the one given to your router which will usually be either 1 or 0. This is a local ip which is different from a external ip which will never start with 192.xxx 10.xxx or 172.xxx like a local one will and will be likely be subject to change unlike a local one (the local subnet atleast local ip's usually change unless you set them in stone which I would recommend but can't help you with as it changes based on your connection method sometimes router, isp, etc.
PORT_FORWARDING should be left on as it will allow port forwarding which gives many benefits such as more seeds, recommended/required on private torrent trackers, etc, etc.
PORT_FORWARDING_STATUS_FILE should stay static unless you feel like changing the volume above where it is bound to an area of your choosing on your local machine for some reason and follow the guide and don't change anything past where it says to
```
  # JDownloader
  # For downloading anything
  # Make sure to enter the container and run the below command
  # configure EMAIL PASSWORD
  jdownloader:
    container_name: jdownloader
    image: jaymoulin/jdownloader
    restart: always
    network_mode: service:pia
    volumes:
     - /path/to/downloads:/downloads
     - /path/to/config:/opt/JDownloader/cfg
  # Sonarr
  # For downloading TV shows
  # Runs on port 8989
  sonarr:
    container_name: sonarr
    image: linuxserver/sonarr 
    restart: always
    network_mode: service:pia
    environment:
     - PUID=1000
     - PGID=1000
     - TZ=Australia/Sydney
     - UMASK_SET=022
    volumes:
     - /path/to/config:/config
     - /path/to/data:/data
  # Radarr
  # For downloading movies
  # Runs on port 7878
  radarr:
    container_name: radarr
    image: linuxserver/radarr
    restart: always
    network_mode: service:pia
    environment:
     - PUID=1000
     - PGID=1000
     - TZ=Australia/Sydney
     - UMASK_SET=022
    volumes:
     - /path/to/config:/config
     - /path/to/data:/data
  qbittorrent:
    container_name: qbittorrent
    image: linuxserver/qbittorrent
    restart: always
    network_mode: service:pia
    environment:
     - PUID=1000
     - PGID=1000
     - TZ=Australia/Sydney
     - UMASK_SET=022
     - WEBUI_PORT=8080
    volumes:
     - /path/to/config:/config
     - /path/to/data:/data
  prowlarr:
    image: linuxserver/prowlarr:develop
    container_name: prowlarr
    network_mode: service:pia
    environment:
     - PUID=1000
     - PGID=1000
     - TZ=Australia/Sydney
    volumes:
     - /path/to/config:/config
    restart: always
  bazarr:
    image: linuxserver/bazarr
    container_name: bazarr
    network_mode: service:pia
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Australia/Sydney
    volumes:
      - /path/to/config:/config
      - /path/to/data:/data
    restart: always
  lidarr:
    image: ghcr.io/linuxserver/lidarr
    container_name: lidarr
    network_mode: service:pia
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Australia/Sydney
    volumes:
      - /path/to/config:/config
      - /path/to/data:/data
      - /docker/containers/configs/lidarr/90-config:/etc/cont-init.d/90-config
      - /var/run/docker.sock:/var/run/docker.sock
    restart: always
  beets:
    image: ghcr.io/linuxserver/beets
    container_name: beets
    network_mode: service:pia
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Australia/Sydney
    volumes:
      - /path/to/config:/config
      - /path/to/data:/data
    restart: always
  slskd:
    image: slskd/slskd
    container_name: slskd
    network_mode: service:pia
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Australia/Sydney
      - SLSKD_USERNAME=<slskd username>
      - SLSKD_PASSWORD=<slskd password>
      - SLSKD_SLSK_USERNAME=<Soulseek username>
      - SLSKD_SLSK_PASSWORD=<Soulseek password>
    volumes:
      - /path/to/downloaded:/var/slskd/downloads
      - /path/to/incoming:/var/slskd/incoming
      - /path/to/shared:/var/slskd/shared
    restart: always
    ```
    I would recommend having your /config's an a centralised area such as /docker/(SERVICE_NAME)/Config and the /data folder in an area with a tonne of space as that is where everything is going, in instances such as slskd the downloads directory should always be within the Data folder with the data folder's directory tree looking something like this to make hard links, organization and other such things far easier:

```
- Data
  - Downloads
    - Soulseek
      - Incoming
      - Downloaded
  - Movies
  - TV
  - Anime
  - Photos
  - Other
```
For slskd your soulseek username & password are not registered anywhere and you can make it anything provided no one else is using it so feel free to input whatever you like here.
