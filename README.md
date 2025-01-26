# BLE iPhone App / BLE iPhoneアプリ

**Version:** 1.0  
**Author:** Souta Takada  
**Date:** 2024年1月31日  

---

## Overview / 概要
This project demonstrates a SwiftUI-based iPhone application for interacting with a Bluetooth Low Energy (BLE) device. The app supports scanning for peripherals, connecting to a target device, and sending/receiving data via BLE characteristics.  
このプロジェクトは、Bluetooth Low Energy（BLE）デバイスと連携するSwiftUIベースのiPhoneアプリケーションを示しています。周辺機器のスキャン、ターゲットデバイスへの接続、およびBLE特性を介したデータの送受信をサポートしています。

---

## Features / 特徴
- **BLE Device Scanning / BLEデバイスのスキャン:** Search for nearby BLE peripherals advertising specific services.  
  特定のサービスをアドバタイズする周辺機器を検索します。
- **Connection Management / 接続管理:** Connect to and disconnect from a BLE device.  
  BLEデバイスとの接続および切断を行います。
- **Data Transmission / データ送信:** Toggle the state of a peripheral's key lock via write operations.  
  書き込み操作を介して周辺機器のキーロック状態を切り替えます。
- **Log Display / ログ表示:** Display connection and communication logs in the app UI.  
  接続および通信ログをアプリのUIに表示します。
- **SwiftUI Interface / SwiftUIインターフェース:** Modern and intuitive UI built using SwiftUI.  
  SwiftUIを使用して構築されたモダンで直感的なUI。

---

## Requirements / 要件
- **iOS:** 14.0以上
- **Development Environment / 開発環境:** Xcode 12以上
- **Device / デバイス:** BLEをサポートするiPhone

---

## Installation / インストール方法
1. Clone this repository.  
   このリポジトリをクローンします。
2. Open the `.xcodeproj` file in Xcode.  
   Xcodeで`.xcodeproj`ファイルを開きます。
3. Set your development team in the Signing & Capabilities section to run the app on a physical device.  
   実機でアプリを実行するために、Signing & Capabilitiesセクションで開発チームを設定します。
4. Build and run the app on an iPhone.  
   アプリをビルドしてiPhoneで実行します。

---

## Usage / 使用方法
### Connecting to a BLE Device / BLEデバイスへの接続
1. Launch the app on your iPhone.  
   iPhoneでアプリを起動します。
2. Tap the **Connect** button to scan for peripherals.  
   **Connect**ボタンをタップして周辺機器をスキャンします。
3. The app will automatically connect to a peripheral named `esp-test-device` with the specified service UUID.  
   アプリは、指定されたサービスUUIDを持つ`esp-test-device`という名前の周辺機器に自動的に接続します。

### Controlling the Key Lock / キーロックの制御
1. Once connected, tap the **Switch** button to toggle the key lock state between `ON` and `OFF`.  
   接続後、**Switch**ボタンをタップしてキーロック状態を`ON`と`OFF`の間で切り替えます。
2. The app sends a string (`"ON"` or `"OFF"`) to the BLE peripheral's write characteristic.  
   アプリは文字列（`"ON"`または`"OFF"`）をBLE周辺機器の書き込み特性に送信します。

### Disconnecting / 切断
- Tap the **Disconnect** button to terminate the connection with the peripheral.  
  **Disconnect**ボタンをタップして周辺機器との接続を終了します。

---

## Code Structure / コード構造
### BLEManager
This class handles all BLE-related operations, including scanning, connecting, and communicating with peripherals.  
このクラスは、スキャン、接続、周辺機器との通信を含むすべてのBLE関連操作を処理します。

#### Key Properties / 主なプロパティ:
- `centralManager`: The `CBCentralManager` instance responsible for managing BLE operations.  
  BLE操作を管理する`CBCentralManager`インスタンス。
- `isConnected`: Tracks the connection status.  
  接続状態を追跡します。
- `logText`: Displays logs for debugging and monitoring.  
  デバッグと監視用のログを表示します。

#### Key Methods / 主なメソッド:
- `scan()`: Starts scanning for peripherals.  
  周辺機器のスキャンを開始します。
- `writeDataToBLEDevice()`: Sends data to the write characteristic of the connected peripheral.  
  接続された周辺機器の書き込み特性にデータを送信します。
- `disconnectPeripheral()`: Disconnects from the current peripheral.  
  現在の周辺機器との接続を切断します。

#### Delegate Methods / デリゲートメソッド:
- `centralManagerDidUpdateState`: Handles updates to the BLE state.  
  BLE状態の更新を処理します。
- `didDiscover`: Processes discovered peripherals.  
  発見された周辺機器を処理します。
- `didConnect`: Handles successful connections.  
  接続成功時の処理を行います。
- `didDisconnectPeripheral`: Handles disconnections.  
  切断時の処理を行います。
- `didDiscoverCharacteristicsFor`: Discovers and configures characteristics.  
  特性を発見して設定します。
- `didWriteValue`: Confirms successful write operations.  
  書き込み操作の成功を確認します。
- `didUpdateValue`: Handles received notifications.  
  受信した通知を処理します。

### ContentView
The main SwiftUI view of the app that:  
アプリのメインSwiftUIビュー:
- Displays logs and connection state.  
  ログと接続状態を表示します。
- Provides buttons for scanning, connecting, and toggling the key lock state.  
  スキャン、接続、キーロック状態の切り替えボタンを提供します。

---

## BLE Configuration / BLE構成
### Target Peripheral / ターゲット周辺機器
- **Name / 名前:** `esp-test-device`
- **Service UUID:** `3c3996e0-4d2c-11ed-bdc3-0242ac120002`
- **Write Characteristic UUID / 書き込み特性UUID:** `3C399A64-4D2C-11ED-BDC3-0242AC120002`
- **Notify Characteristic UUID / 通知特性UUID:** `3C399C44-4D2C-11ED-BDC3-0242AC120002`

---

## Example Usage / 使用例
```swift
let bleManager = BLEManager()
bleManager.scan()
bleManager.writeDataToBLEDevice()
bleManager.disconnectPeripheral()
```

---

## Notes / 注意事項
- Ensure the target BLE device is powered on and advertising before starting the scan.  
  スキャンを開始する前に、ターゲットBLEデバイスが電源オンおよびアドバタイズされていることを確認してください。
- Logs can be used to debug and verify successful communication.  
  ログはデバッグや通信成功の確認に使用できます。
- Modify the UUIDs in `BLEManager` if using a different BLE device.  
  別のBLEデバイスを使用する場合は、`BLEManager`内のUUIDを変更してください。

---

## License / ライセンス
This project is open-source and available under the MIT License.  
このプロジェクトはオープンソースであり、MITライセンスの下で利用可能です。

---

## Contact / 連絡先
- **Author / 著者:** Souta Takada  
- **Email / メール:** [takada@ah.iit.tsukuba.ac.jp]
