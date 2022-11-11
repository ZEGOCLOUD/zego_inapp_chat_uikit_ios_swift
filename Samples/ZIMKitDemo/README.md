# Run the sample code

## Overview

The following describes how to run the sample code of the In-app Chat UIKit.



## Prerequisites

* Go to [ZEGOCLOUD Admin Console](https://console.zegocloud.com/) and do the following:
  1. Create a project, and get the `AppID` and `AppSign` of your project.
  2. Subscribe to the **In-app Chat** service (Contact technical support if the subscript doesn’t go well).

     <img src="https://storage.zego.im/sdk-doc/Pics/InappChat/ActivateZIMinConsole2.png" width="40%">
  
* Platform-specific requirements:
  * Xcode 13.0 or later.
  * A real iOS device that is running on iOS 12.0 or later.
  * The device is connected to the internet.



## Run the sample code

1. In App Store, search and download the Xcode.

   <img src="https://storage.zego.im/sdk-doc/Pics/iOS/GoClass/appstore-xcode.png" width="40%">

2. Download and extract the sample code, in Terminal, navigate to the `../Samples/ZIMKitDemo` directory, and run the following:

   ```bash
   pod install
   ```

3. In Xcode, open the `ZIMKitDemo.xcworkspace` file.

   <img src="https://storage.zego.im/sdk-doc/Pics/ZIMKit/IOS/swift/xcode_open.png" width="80%">

4. Log in to your Apple ID account.

   a. In Xcode, select **Xcode > Preferences** in the upper left corner.  

   b. Select the **Accounts** tab, click the **+** button in the lower left, then select **App ID**, and click **Continue**.

      <img src="https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/xcode-account.png" width="80%">

   c. Enter your Apple ID and Password to log in.

      <img src="https://storage.zego.im/sdk-doc/Pics/iOS/GoClass/xcode-login-apple-id.png" width="80%">

5. Modify the Bundle Identifier and your developer certificate. 

   a. In Xcode, select the `ZIMKitDemo` project.  

      <img src="https://storage.zego.im/sdk-doc/Pics/ZIMKit/IOS/swift/demo_open_01.png" width="80%">

   b. Select the target project, click **Signing & Capabilities**, and in **Team** field, select your developer certificate. 

      <img src="https://storage.zego.im/sdk-doc/Pics/ZIMKit/IOS/swift/demo_open_02.png" width="80%">

6. Modify the `KeyCenter.swift` file under the `ZIMKitDemo/KeyCenter` folder with the AppID and AppSign you get from ZEGOCLOUD Admin Console.

   <img src="https://storage.zego.im/sdk-doc/Pics/ZIMKit/IOS/swift/demo_config_01.png" width="80%">

7. Connect the iOS device to the computer, click the **Any iOS Device** and select your iOS device in the pop-up window.

   <img src="https://storage.zego.im/sdk-doc/Pics/ZIMKit/IOS/swift/xcode_device.png" width="80%">

8. Click the **Run** button to compile and run the sample code.

   <img src="https://storage.zego.im/sdk-doc/Pics/ZIMKit/IOS/swift/xcode_run.png" width="80%">



Congratulations! So far, you have finished all the steps, and this is what you gonna see when the sample code is run successfully:



<img src="https://storage.zego.im/sdk-doc/Pics/ZIMKit/IOS/swift/demo_login.jpeg" width=200/>



## More to explore

* To get started swiftly, follow the steps in this doc: [Integrate the SDK](https://docs.zegocloud.com/article/14860)
* To explore more customizable components, check this out: [Component overview](https://docs.zegocloud.com/article/14861)



## Get support

If you have any questions regarding bugs and feature requests, visit the [ZEGOCLOUD community](https://discord.gg/EtNRATttyp).
