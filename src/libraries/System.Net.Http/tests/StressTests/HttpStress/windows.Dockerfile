# escape=`
ARG SDK_BASE_IMAGE=mcr.microsoft.com/dotnet/nightly/sdk:6.0-nanoserver-1809
FROM $SDK_BASE_IMAGE

# Use powershell as the default shell
SHELL ["pwsh", "-Command"]

WORKDIR /app
COPY . .

ARG VERSION=8.0
ARG CONFIGURATION=Release

RUN dotnet build -c $env:CONFIGURATION `
    -p:TargetingPacksTargetsLocation=C:/live-runtime-artifacts/targetingpacks.targets `
    -p:MicrosoftNetCoreAppRefPackDir=C:/live-runtime-artifacts/microsoft.netcore.app.ref/ `
    -p:MicrosoftNetCoreAppRuntimePackDir=C:/live-runtime-artifacts/microsoft.netcore.app.runtime.win-x64/$env:CONFIGURATION/

# Enable dump collection
ENV COMPlus_DbgEnableMiniDump=1
ENV COMPlus_DbgMiniDumpType=MiniDumpWithFullMemory
ENV COMPlus_DbgMiniDumpName="C:/dumps-share/coredump.%p"

EXPOSE 5001

ENV VERSION=$VERSION
ENV CONFIGURATION=$CONFIGURATION
ENV HTTPSTRESS_ARGS=""

CMD & C:/live-runtime-artifacts/testhost/net$env:VERSION-windows-$env:CONFIGURATION-x64/dotnet.exe exec --roll-forward Major `
    ./bin/$env:CONFIGURATION/net$env:VERSION/HttpStress.dll $env:HTTPSTRESS_ARGS.Split()