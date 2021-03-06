FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine as build
WORKDIR /app

COPY /samples/QueueMessages.SampleApp samples/guardians-app
COPY /src src

WORKDIR samples/guardians-app
RUN dotnet restore --runtime alpine-x64
RUN dotnet publish -c Release -o /app/publish \
  --no-restore \
  --runtime alpine-x64 \
  --self-contained true \
  /p:PublishSingleFile=true 

FROM mcr.microsoft.com/dotnet/runtime-deps:6.0-alpine AS runtime
RUN adduser --disabled-password \
  --home /app \
  --gecos '' dotnetuser && chown -R dotnetuser /app

# upgrade musl to remove potential vulnerability
RUN apk upgrade musl
USER dotnetuser

WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 5000
ENTRYPOINT ["./SampleApp.GuardiansOfTheGalaxy"]