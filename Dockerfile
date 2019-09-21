#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

FROM mcr.microsoft.com/dotnet/core/aspnet:2.1-nanoserver-1903 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:2.1-nanoserver-1903 AS build
WORKDIR /src
COPY ["windowsContainerSample/windowsContainerSample.csproj", "windowsContainerSample/"]
RUN dotnet restore "windowsContainerSample/windowsContainerSample.csproj"
COPY . .
WORKDIR "/src/windowsContainerSample"
RUN dotnet build "windowsContainerSample.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "windowsContainerSample.csproj" -c Release -o /app
COPY setup.ps1 setup.ps1
RUN powershell .\setup.ps1
RUN powershell "rm -r setup.ps1"


FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "windowsContainerSample.dll"]