# OCAP Web component

## Configuration
The configuration file is called `option.json`

**"title"**: Title used in the web app   
**"listen"**: Listener for the web server, change to "0.0.0.0:5000" to listen on all interfaces   
**"secret"**: Secret used for authenticate on record upload   
**"logger"**: Enables logging to "ocap.log" file

## Docker

volumes are available:
- `/etc/ocap` place here your `option.json`
- `/usr/local/ocap-web/static/data` store for all uploaded json records
- `/usr/local/ocap-web/static/images/maps` map images from ...
- `/var/lib/ocap` can be changed in the `option.json` with the `db` key

## Build from source

This Project is based on [Golang](https://golang.org/dl/)

### Windows
```bash
go build -o ocap-webserver.exe ./src/web
```

### Linux
```
go build -o ocap-webserver ./src/web
```

### Docker
```
docker build -t ocap-webserver .
```
