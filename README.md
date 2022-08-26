A backend server built using [gRPC](https://pub.dev/packages/grpc),
configured to enable running with [Docker](https://www.docker.com/).

# Other repositories

## Go version

You can find a [Go Version](https://github.com/terence-truong/go-grpc-mongodb) on Github.

## Clients repo

[Flutter-Grpc app](https://github.com/terence-truong/flutter-grpc).

# Running the server

## Running with Docker

If you have [Docker Desktop](https://www.docker.com/get-started) installed, you
can build and run with the `docker compose` command:

```
$ docker compose up -d
```

If you want to stop and remove the containers:
```
$ docker compose down
```

To generate the protobuf files:
```
$ mkdir lib/src/generated
$ protoc -I protos/ protos/users.proto --dart_out=grpc:lib/src/generated
```