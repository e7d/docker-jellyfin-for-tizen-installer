# Docker-based "Jellyfin for Tizen" installer

## Usage

1. Run TV and find its IP address.
2. Activate the "Developer mode" following the [Using SDK for Web Applications](https://developer.samsung.com/smarttv/develop/getting-started/using-sdk/tv-device.html) documentation.
3. Run the container, but replace `TV IP` with the IP found at step one:
```shell
docker run -it --rm --network=host e7db/jellyfin-for-tizen-installer TV_IP
```

## Common issues

### error: failed to connect to remote target

If you get the following error output:
```shell
* Server is not running. Start it now on port 26099 *
* Server has started successfully *
error: failed to connect to remote target '192.168.1.2'
```
That means the installer script could not establish a network connection with your TV.
Please check again the IP address of your TV.

### Could not find your TV name automatically.

If you get the following error output:
```shell
Could not find your TV name automatically.

Please provide the TV_NAME argument from the listing below:
192.168.1.2:26101	device		QE55Q7FNA
```
That means the installer script could not parse the name of your TV automatically.
In that case, check the provided list of detected TVs, and note the name of TV corresponding to the TV IP address you provided. Then, run the command again, but add the TV name on the end.
For example, with the error log sample provided above, you should try with:
```shell
docker run -it --rm --network=host e7db/jellyfin-for-tizen-installer 192.168.1.2 QE55Q7FNA
```
