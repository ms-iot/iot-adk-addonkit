# iot-adk-addonkit
This project contains command line scripts for package creation and image creation process. Users are expected to have ADK and Windows 10 IoT Core OS packages installed to make use of this. To be able to create images, Users should also get the BSPs corresponding to the hardware. Target audience is OEM’s and Maker Pro’s who want to manage multiple images and updates.

This project has adopted the [Microsoft Open Source Code of Conduct](http://microsoft.github.io/codeofconduct). For more information see the [Code of Conduct FAQ](http://microsoft.github.io/codeofconduct/faq.md) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

# References

## User Guides
* [IoT Core Manufacturing Guide](https://docs.microsoft.com/windows-hardware/manufacture/iot/)
    * [Windows ADK IoT Core Add-Ons Overview](https://go.microsoft.com/fwlink/p/?LinkId=735029)
    * [IoT Core Add-Ons command-line options](https://docs.microsoft.com/windows-hardware/manufacture/iot/iot-core-adk-addons-command-line-options)
    * [IoT Core feature list](https://docs.microsoft.com/windows-hardware/manufacture/iot/iot-core-feature-list)
    * [Channel9 Video on Manufacturing Guide](https://channel9.msdn.com/events/Build/2017/B8085)
* [Learn how to build on Windows 10 IoT Core](https://docs.microsoft.com/windows/iot-core/)
    * [Windows Device Portal](https://docs.microsoft.com/windows/iot-core/manage-your-device/deviceportal)

## Downloads

* [IoT Core OS Packages](https://www.microsoft.com/en-us/download/details.aspx?id=55031)
* [Windows Assessment and Deployment Kit](https://developer.microsoft.com/windows/hardware/windows-assessment-deployment-kit)
* [Windows Driver Kit - WDK](https://developer.microsoft.com/en-us/windows/hardware/windows-driver-kit)
* [Windows 10 IoT Core Dashboard](https://developer.microsoft.com/windows/iot/docs/iotdashboard)

## BSPs

See [Windows 10 IoT Core BSPs](https://docs.microsoft.com/windows/iot-core/build-your-image/createbsps)

## Source Links

* Security.Bitlocker, Security.SecureBoot and Security.DeviceGuard
    * Source : [ms-iot/security/TurnkeySecurity](https://github.com/ms-iot/security/tree/master/TurnkeySecurity)
    * Documentation : [SecureBoot, Bitlocker and DeviceGuard](https://docs.microsoft.com/windows/iot-core/secure-your-device/securebootandbitlocker)
* Appx.IoTCoreDefaultApp
    * Source : [ms-iot/samples/IoTCoreDefaultApp](https://github.com/ms-iot/samples/tree/develop/IoTCoreDefaultApp)
    * Documentation : [IoTCoreDefaultApp](https://developer.microsoft.com/windows/iot/samples/iotdefaultapp)
* Appx.DigitalSign
    * Source : [ms-iot/samples/IoTOnBoarding](https://github.com/ms-iot/samples/tree/develop/DigitalSign)
    * Documentation : [DigitalSign](https://developer.microsoft.com/windows/iot/samples/digitalsign)
* Appx.IoTCoreOnboardingTask
    * Source : [ms-iot/samples/IoTOnBoarding](https://github.com/ms-iot/samples/tree/develop/IotOnboarding)
    * Documentation : [IoTOnBoarding](https://developer.microsoft.com/windows/iot/samples/iotonboarding)

# Branch Overview

## Master Branch
This branch supports the lastest Windows 10 IoT Core release available ( currently 1709, version number 10.0.16299.x ). Note that this release now supports wm.xml and requires latest ADK. See [Create Windows Universal OEM Packages](https://docs.microsoft.com/windows-hardware/manufacture/iot/create-packages) for more details.

## Develop Branch
This branch contains the active development contents, mostly addressing the upcoming release features.

## Older Versions

* [15063_v3.2 release](https://github.com/ms-iot/iot-adk-addonkit/releases/tag/v3.2) for [Windows 10 IoT Core Release 1607 (version 10.0.15063.x)](https://www.microsoft.com/en-us/download/details.aspx?id=55031).
* [14393_v2.0 release](https://github.com/ms-iot/iot-adk-addonkit/releases/tag/v2.0) for [Windows 10 IoT Core Release 1607 (version 10.0.14393.x)](https://www.microsoft.com/en-us/download/details.aspx?id=53898).
* [10586_v1.0 release](https://github.com/ms-iot/iot-adk-addonkit/releases/tag/v1.0) for Windows 10 IoT Core Release 1511 (version 10.0.10586.x).

