# Metapixel firmware

This is code contains firmware codes for ESP32-WROOM for the intsllation. 
Protocole used : MQTT to declare their ID (assignation) and Artnet to manage LED control. 

## upload on macos

- Install pio-cli : https://docs.platformio.org/en/stable/core/index.html

- Go to repo : metapixel _firmware and run command `pio run -t upload`

- On mac it is possible to have this error : A fatal error occurred: Failed to write to target RAM (result was 01070000: Operation timed out)

- To dodge this error you need to install CH34 DRIVER on : https://www.wch.cn/downloads/CH34XSER_MAC_ZIP.html

- then type : `ls /dev/cu*` and you will see 'yourdevice'+wchusbserial552E0075671

- Then type your upload command : `pio run -t upload --upload-port /dev/cu.wchusbserial552E0075671` (target your new port)

- Upload should succeed !
