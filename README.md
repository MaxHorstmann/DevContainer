# DevContainer
Experimenting with a dev container

## HelloWorldApi

A simple C# Web API built with .NET 8 that provides basic Hello World endpoints.

### Endpoints

- `GET /` - Returns "Hello World!"
- `GET /hello/{name}` - Returns "Hello, {name}!"
- `GET /health` - Returns health status with timestamp
- `GET /swagger` - Swagger UI for API documentation

### Running the API

```bash
cd HelloWorldApi
dotnet run
```

The API will be available at `http://localhost:5130`

### Building with Docker

```bash
cd HelloWorldApi
docker build -t helloworldapi .
docker run -p 8080:8080 helloworldapi
```

### Testing the API

```bash
# Test Hello World endpoint
curl http://localhost:5130/

# Test personalized greeting
curl http://localhost:5130/hello/YourName

# Test health check
curl http://localhost:5130/health
```
