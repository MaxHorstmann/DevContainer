# Use the .NET 8 SDK for building
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["HelloWorldApi.csproj", "./"]
RUN dotnet restore "HelloWorldApi.csproj"
COPY . .
RUN dotnet build "HelloWorldApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "HelloWorldApi.csproj" -c Release -o /app/publish

# Final stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "HelloWorldApi.dll"]
