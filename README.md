# iot-adk-addonkit
This project contains command line scripts for package creation and image creation process. Users are expected to have ADK and Windows 10 IoT Core OS packages installed to make use of this. To be able to create images, Users should also get the BSPs corresponding to the hardware. Target audience is OEM’s and Maker Pro’s who want to manage multiple images and updates.

This project has adopted the [Microsoft Open Source Code of Conduct](http://microsoft.github.io/codeofconduct). For more information see the [Code of Conduct FAQ](http://microsoft.github.io/codeofconduct/faq.md) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

# References

## User Guides
* [IoT Core Manufacturing Guide](https://msdn.microsoft.com/windows/hardware/commercialize/manufacture/iot/iot-core-manufacturing-guide)
    * [Windows ADK IoT Core Add-Ons Overview](https://go.microsoft.com/fwlink/p/?LinkId=735029)
    * [IoT Core Add-Ons command-line options](https://msdn.microsoft.com/windows/hardware/commercialize/manufacture/iot/iot-core-adk-addons-command-line-options)
    * [IoT Core feature list](https://msdn.microsoft.com/windows/hardware/commercialize/manufacture/iot/iot-core-feature-list)
* [Learn how to build on Windows 10 IoT Core](https://developer.microsoft.com/windows/iot/Docs)
    * [Windows Device Portal](https://developer.microsoft.com/windows/iot/docs/deviceportal)

## Downloads

* [IoT Core OS Packages](https://www.microsoft.com/en-us/download/details.aspx?id=55031)
* [Windows Assessment and Deployment Kit](https://developer.microsoft.com/windows/hardware/windows-assessment-deployment-kit#winADK)
* [Windows Driver Kit - WDK](https://developer.microsoft.com/en-us/windows/hardware/windows-driver-kit)
* [Windows 10 IoT Core Dashboard](https://developer.microsoft.com/windows/iot/docs/iotdashboard)

## BSPs

See [Windows 10 IoT Core BSPs](https://developer.microsoft.com/en-us/windows/iot/docs/bsp)

## Source Links

* Security.Bitlocker, Security.SecureBoot and Security.DeviceGuard
    * Source : [ms-iot/security/TurnkeySecurity](https://github.com/ms-iot/security/tree/master/TurnkeySecurity)
    * Documentation : [SecureBoot, Bitlocker and DeviceGuard](https://developer.microsoft.com/en-us/windows/iot/docs/turnkeysecurity)
* Appx.IoTCoreDefaultApp
    * Source : [ms-iot/samples/IoTCoreDefaultApp](https://github.com/ms-iot/samples/tree/develop/IoTCoreDefaultApp)
    * Documentation : [IoTCoreDefaultApp](https://developer.microsoft.com/en-us/windows/iot/samples/iotdefaultapp)
* Appx.IoTCoreOnboardingTask
    * Source : [ms-iot/samples/IoTOnBoarding](https://github.com/ms-iot/samples/tree/develop/IotOnboarding)
    * Documentation : [IoTOnBoarding](https://developer.microsoft.com/en-us/windows/iot/samples/iotonboarding)


# Branch Overview

## Master Branch
This branch supports the lastest Windows 10 IoT Core release available ( currently 1703, version number 10.0.15063.x )

## Develop Branch
This branch contains the active development contents, mostly addressing the upcoming release features.

## Older Versions

* [14393_v2.0 release](https://github.com/ms-iot/iot-adk-addonkit/releases/tag/v2.0) for [Windows 10 IoT Core Release 1607 (version 10.0.14393.x)](https://www.microsoft.com/en-us/download/details.aspx?id=53898).
* [10586_v1.0 release](https://github.com/ms-iot/iot-adk-addonkit/releases/tag/v1.0) for Windows 10 IoT Core Release 1511 (version 10.0.10586.x).

