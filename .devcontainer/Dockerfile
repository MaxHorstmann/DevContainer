# Use the Microsoft dev containers .NET image as base
FROM mcr.microsoft.com/devcontainers/dotnet:1-8.0-jammy

# Install additional tools or customize the environment
RUN apt-get update && apt-get install -y \
    tree \
    htop \
    && rm -rf /var/lib/apt/lists/*

# You can add custom tools, configurations, or global packages here
# For example, install global .NET tools:
RUN dotnet tool install -g dotnet-ef

# Set any custom environment variables
# ENV CUSTOM_VAR=value

# Verify the setup
RUN dotnet --version
