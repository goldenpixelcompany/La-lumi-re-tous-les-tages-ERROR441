
#define WIFI_TIMEOUT_FOULE 30000
#define WIFI_TIMEOUT_ENSAD 30000

#define HEARTBEAT_LOW 1000
#define HEARTBEAT_HIGH 5000

#define SSID_FOULE "FOULE_LED"
#define PSK_FOULE  "Bijahouix"

#define SSID_ENSAD "ENSAD-LED"
#define PSK_ENSAD  "Lmdpdeensadled"

#define DEFAULT_UNIVERSE 1
#define START_ADDR 1

#include <Arduino.h>
#include <esp_task_wdt.h>
#include <Preferences.h>
Preferences preferences;

#define BAUDRATE 115200
#define LOOP_INTERVAL 1  // global loop interval in ticks

// Network stack
#include <WiFi.h>
#include <ESPmDNS.h>
#include <ArduinoOTA.h>
#define OTA_PASS "Bijahouix"

char host[22];

// App
#include <ArtnetWifi.h>
ArtnetWifi artnet;

uint16_t frame_count = 0;

uint16_t univ_a = 1;
uint16_t univ_b = 1;
uint16_t univ_c = 1;

uint16_t addr_a = 0;
uint16_t addr_b = 0;
uint16_t addr_c = 0;

uint32_t colormult_r = 65535;
uint32_t colormult_g = 65535;
uint32_t colormult_b = 65535;

uint32_t brightness = 32768;

uint32_t master = 65535;

uint8_t framerate = 25;

uint8_t do_save = false;

#include "backend.h"
#include "led_helper.h"

bool running = true;
uint8_t mode = MODE_ARTNET;



uint8_t buffer [NUM_CHANNEL];
uint32_t next_out = 0;

void loop_out(void * _){
    while(true){
        if(millis() >= next_out){
            next_out = millis() + 1000/framerate;
            for (int i = 0; i < NUM_CHANNEL; ++i){
                setCalibratedChannel(i, buffer[i]);
            }
        }
        vTaskDelay(1);
    }
    vTaskDelete(NULL);
}

void out_sync(){
    next_out = 0;
}

void testMode(){
    for (int i = 0; i < NUM_CHANNEL; ++i){
        ledcWrite(i, gamma28_8b_16b[(millis()/10)%200]);
    }
}

void whiteMode(){
    for (int i = 0; i < NUM_CHANNEL; ++i){
        setCalibratedChannel(i, 255);
    }
}

void blackMode(){
    for (int i = 0; i < NUM_CHANNEL; ++i){
        setCalibratedChannel(i, 0);
    }
}

void idleMode(){
    for (int i = 0; i < NUM_CHANNEL; ++i){
        setCalibratedChannel(i, 10);
    }
}

void fill_in(uint8_t channel, uint8_t value){
    buffer[channel] = value;
}

void on_artnet(uint16_t universe, uint16_t length, uint8_t sequence, uint8_t* data){

    if(mode == MODE_ARTNET){
        uint16_t starts[3] =  {addr_a, addr_b, addr_c};
        uint16_t univs[3] =  {univ_a, univ_b, univ_c};

        for (int px = 0; px < 3; ++px){
            if(universe == univs[px]){
                for (int i = 0; i < 3; ++i){
                    fill_in(
                        (px*3)+i,
                        data[starts[px]+i]
                    );
                }
            }
        }   
    }

    ledcWrite(9, gamma28_8b_16b[frame_count*10]);
    frame_count ++;
    frame_count = frame_count % 25;
}

// front end loop
void loop_metapixel(void * _){

    ledcAttachPin(LED_BUILTIN, 9);
    ledcSetup(9, PWM_FREQ, PWM_RES_BITS);

    artnet.setArtDmxCallback(on_artnet);
    artnet.begin();

	delay(10);

	while(running){
		if(artnet.read() == ART_SYNC){
            Serial.println("sync");
        }
        switch(mode){
            case MODE_IDLE:
                idleMode();
            break;
            case MODE_WHITE:
                whiteMode();
            break;
            case MODE_BLACK:
                blackMode();
            break;
            case MODE_ARTNET:
                // handled elsewhere
            break;
            default:
            break;
        }
        vTaskDelay(1);
        /*taskYIELD();
        esp_task_wdt_reset();*/
	}
    vTaskDelete(NULL);
}

void setupOSC(){

    preferences.begin("MPX", false); 

    univ_a = preferences.getUInt("univ_a", univ_a);
    univ_b = preferences.getUInt("univ_b", univ_b);
    univ_c = preferences.getUInt("univ_c", univ_c);

    addr_a = preferences.getUInt("addr_a", addr_a);
    addr_b = preferences.getUInt("addr_b", addr_b);
    addr_c = preferences.getUInt("addr_c", addr_c);

    colormult_r = (uint32_t)preferences.getUInt("colormult_r", colormult_r);
    colormult_g = (uint32_t)preferences.getUInt("colormult_g", colormult_g);
    colormult_b = (uint32_t)preferences.getUInt("colormult_b", colormult_b);

    brightness = (uint32_t)preferences.getUInt("brightness", brightness);
    framerate = (uint8_t)preferences.getUInt("framerate", framerate);

    OscWiFi.subscribe(OSC_IN_PORT, "/addresses", addr_a, addr_b, addr_c);
    OscWiFi.subscribe(OSC_IN_PORT, "/universes", univ_a, univ_b, univ_c);
    OscWiFi.subscribe(OSC_IN_PORT, "/calibration", colormult_r, colormult_g, colormult_b);
    OscWiFi.subscribe(OSC_IN_PORT, "/brightness", brightness);
    OscWiFi.subscribe(OSC_IN_PORT, "/mode", mode);
    OscWiFi.subscribe(OSC_IN_PORT, "/master", master);

    OscWiFi.subscribe(OSC_IN_PORT, "/save", do_save);

    OscWiFi.subscribe(OSC_IN_PORT, "/framerate", framerate);

    OscWiFi.subscribe(OSC_IN_PORT, "/sync", [](){
        out_sync();
    });

    OscWiFi.subscribe(OSC_IN_PORT, "/restart", [](){
        ESP.restart();
    });

}

void setup() {
	pinMode(LED_BUILTIN, OUTPUT);
    digitalWrite(LED_BUILTIN, HIGH);
	pinMode(PIN_BTN, INPUT);

	// build and set hostname
	uint64_t mac = ESP.getEfuseMac();
    uint64_t reversed_mac = 0;

    for (int i = 0; i < 6; i++) {
        reversed_mac |= ((mac >> (8 * i)) & 0xFF) << (8 * (5 - i));
    }

    snprintf(host, 22, "MPX-%llX", reversed_mac);

    delay(100);
    Serial.begin(BAUDRATE);
    delay(400);
    Serial.println(host);
    Serial.println(VERSION_STRING);

    setupWiFi();
    setupOTA();
    setupLED();

    setupOSC();

    xTaskCreatePinnedToCore(
        loop_metapixel,   // Function that should be called
        "Metapixel",      // Name of the task (for debugging)
        20000,            // Stack size (bytes)
        NULL,             // Parameter to pass
        1,                // Task priority
        NULL,             // Task handle
        !xPortGetCoreID() // pin to not the one running this
    );

    xTaskCreatePinnedToCore(
        loop_out,         // Function that should be called
        "Out",            // Name of the task (for debugging)
        20000,            // Stack size (bytes)
        NULL,             // Parameter to pass
        10,               // Task priority
        NULL,             // Task handle
        !xPortGetCoreID() // pin to not the one running this
    );

    delay(10);

    digitalWrite(LED_BUILTIN, LOW);

    Serial.println(broadcastAddress);
}

void save_prefs(){
    preferences.putUInt("univ_a", univ_a);
    preferences.putUInt("univ_b", univ_b);
    preferences.putUInt("univ_c", univ_c);

    preferences.putUInt("addr_a", addr_a);
    preferences.putUInt("addr_b", addr_b);
    preferences.putUInt("addr_c", addr_c);

    preferences.putUInt("colormult_r", (uint16_t)colormult_r);
    preferences.putUInt("colormult_g", (uint16_t)colormult_g);
    preferences.putUInt("colormult_b", (uint16_t)colormult_b);

    preferences.putUInt("brightness", (uint16_t)brightness);

    preferences.putUInt("framerate", (uint16_t)framerate);
}

// backend loop
void loop(){
  // wifi
  if(WiFi.status() != WL_CONNECTED){
    ledcWrite(9, gamma28_8b_16b[255]);
    setupWiFi();
    broadcastAddress = (WiFi.localIP() | ~WiFi.subnetMask());
  }

  // OSC
  handle_osc();

  // OTA
  ArduinoOTA.handle();
  vTaskDelay(LOOP_INTERVAL);

  if(do_save > 0){
    do_save = 0;
    save_prefs();
  }
}

