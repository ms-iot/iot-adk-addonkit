# iot-adk-addonkit

This project contains powershell scripts for package creation and image creation process. Users are expected to have ADK and Windows 10 IoT Core OS packages installed to make use of this. To be able to create images, Users should also get the BSPs corresponding to the hardware. Target audience is OEM’s and Maker Pro’s who want to manage multiple images and updates.

This project has adopted the [Microsoft Open Source Code of Conduct](http://microsoft.github.io/codeofconduct). For more information see the [Code of Conduct FAQ](http://microsoft.github.io/codeofconduct/faq.md) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Branch Overview

### Master Branch

This branch supports the lastest Windows 10 IoT Core release available ( currently **1809**, version number **10.0.17763.x** ).
The iot-adk-addonkit is now in Powershell and supports additional features including multiple workspaces. For more details see

* [IoTCoreImaging Command Listing](./Tools/CommandListing.md)
* [IoTCoreImaging User Manual](./Tools/README.md)


### Older Versions: **Not Supported**

For older releases, please use the corresponding ADK tools and iot-adk-addonkit releases.

* [17134_v5.3 release](https://github.com/ms-iot/iot-adk-addonkit/releases/tag/17134_v5.3) for [Windows 10 IoT Core Release 1803 (version 10.0.17134.x)](https://software-download.microsoft.com/download/pr/17134.1.180410-1804.rs4_release_amd64fre_IOTCORE_PACKAGES.iso).
* [16299_v4.4 release](https://github.com/ms-iot/iot-adk-addonkit/releases/tag/v4.4) for [Windows 10 IoT Core Release 1709 (version 10.0.16299.x)](https://software-download.microsoft.com/download/pr/16299.15.170928-1534.rs3_release_amd64fre_IOTCORE_PACKAGES.iso).
* [15063_v3.2 release](https://github.com/ms-iot/iot-adk-addonkit/releases/tag/v3.2) for [Windows 10 IoT Core Release 1703 (version 10.0.15063.x)](https://www.microsoft.com/en-us/download/details.aspx?id=55031).
* [14393_v2.0 release](https://github.com/ms-iot/iot-adk-addonkit/releases/tag/v2.0) for [Windows 10 IoT Core Release 1607 (version 10.0.14393.x)](https://www.microsoft.com/en-us/download/details.aspx?id=53898).

## References

### User Guides

* [IoT Core Manufacturing Guide](https://docs.microsoft.com/windows-hardware/manufacture/iot/)
  * [Windows ADK IoT Core Add-Ons Overview](https://go.microsoft.com/fwlink/p/?LinkId=735029)
  * [IoT Core Add-Ons command-line options](https://docs.microsoft.com/windows-hardware/manufacture/iot/iot-core-adk-addons-command-line-options)
  * [IoT Core feature list](https://docs.microsoft.com/windows-hardware/manufacture/iot/iot-core-feature-list)
  * [Channel9 Video on Manufacturing Guide](https://channel9.msdn.com/events/Build/2017/B8085)
* [Learn how to build on Windows 10 IoT Core](https://docs.microsoft.com/windows/iot-core/)
  * [Windows Device Portal](https://docs.microsoft.com/windows/iot-core/manage-your-device/deviceportal)
* [SecureBoot, Bitlocker and DeviceGuard](https://docs.microsoft.com/windows/iot-core/secure-your-device/securebootandbitlocker)

### Downloads

* [Windows 10 IoT Core Packages](https://www.microsoft.com/en-us/software-download/windows10iotcore)
* [Windows Assessment and Deployment Kit](https://go.microsoft.com/fwlink/?linkid=2026036) including [Windows PE add-on for the adk](https://go.microsoft.com/fwlink/?linkid=2022233)
* [Windows Driver Kit - WDK](https://developer.microsoft.com/en-us/windows/hardware/windows-driver-kit)
* [Windows 10 IoT Core Dashboard](https://developer.microsoft.com/windows/iot/docs/iotdashboard)

### BSPs

See [Windows 10 IoT Core BSPs](https://docs.microsoft.com/windows/iot-core/build-your-image/createbsps)

### Source Links

* Appx.IoTCoreDefaultApp (SmartDisplay.appx, shows up as IoTCoreDefaultAppUnderTest)
  * Source : [Windows-iotcore-samples/samples/IoTCoreDefaultApp](https://github.com/Microsoft/Windows-iotcore-samples/tree/develop/Samples/IoTCoreDefaultApp)
  * Documentation : [IoTCoreDefaultApp](https://docs.microsoft.com/windows/iot-core/develop-your-app/iotcoredefaultapp)
* Appx.IoTCoreOnboardingTask
  * Source : [ms-iot/samples/IoTOnBoarding](https://github.com/ms-iot/samples/tree/develop/IotOnboarding)
