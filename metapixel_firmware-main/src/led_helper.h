
#define PWM_FREQ 1000
#define PWM_RES_BITS 16
#define INPUT_RES 255

#define NUM_CHANNEL 9 

const uint16_t PROGMEM gamma28_8b_16b[] = {
      0,    0,    0,    0,    1,    1,    2,    3,    4,    6,    8,   10,   13,   16,   19,   24,
      28,   33,   39,   46,   53,   60,   69,   78,   88,   98,  110,  122,  135,  149,  164,  179,
      196,  214,  232,  252,  273,  295,  317,  341,  366,  393,  420,  449,  478,  510,  542,  575,
      610,  647,  684,  723,  764,  806,  849,  894,  940,  988, 1037, 1088, 1140, 1194, 1250, 1307,
      1366, 1427, 1489, 1553, 1619, 1686, 1756, 1827, 1900, 1975, 2051, 2130, 2210, 2293, 2377, 2463,
      2552, 2642, 2734, 2829, 2925, 3024, 3124, 3227, 3332, 3439, 3548, 3660, 3774, 3890, 4008, 4128,
      4251, 4376, 4504, 4634, 4766, 4901, 5038, 5177, 5319, 5464, 5611, 5760, 5912, 6067, 6224, 6384,
      6546, 6711, 6879, 7049, 7222, 7397, 7576, 7757, 7941, 8128, 8317, 8509, 8704, 8902, 9103, 9307,
      9514, 9723, 9936,10151,10370,10591,10816,11043,11274,11507,11744,11984,12227,12473,12722,12975,
      13230,13489,13751,14017,14285,14557,14833,15111,15393,15678,15967,16259,16554,16853,17155,17461,
      17770,18083,18399,18719,19042,19369,19700,20034,20372,20713,21058,21407,21759,22115,22475,22838,
      23206,23577,23952,24330,24713,25099,25489,25884,26282,26683,27089,27499,27913,28330,28752,29178,
      29608,30041,30479,30921,31367,31818,32272,32730,33193,33660,34131,34606,35085,35569,36057,36549,
      37046,37547,38052,38561,39075,39593,40116,40643,41175,41711,42251,42796,43346,43899,44458,45021,
      45588,46161,46737,47319,47905,48495,49091,49691,50295,50905,51519,52138,52761,53390,54023,54661,
      55303,55951,56604,57261,57923,58590,59262,59939,60621,61308,62000,62697,63399,64106,64818,65535
};


uint16_t safe16bScale(uint16_t value, uint16_t new_max){
    return static_cast<uint16_t>(
        (
            static_cast<uint64_t>(value) *
            static_cast<uint64_t>(new_max)
        ) /
        static_cast<uint64_t>(65535ULL)
    );   
}

void setCalibratedChannel(uint8_t channel, uint8_t value){
    //uint16_t colormults[3] = {colormult_r, colormult_g, colormult_b};
    uint16_t output = gamma28_8b_16b[value];
    //output = safe16bScale(output, colormults[channel%3]);
    //output = safe16bScale(output, brightness);
    output = safe16bScale(output, master);
    ledcWrite(channel, output);
}

void setupLED(){  
      pinMode(PIN_A_R, OUTPUT);
      pinMode(PIN_A_G, OUTPUT);
      pinMode(PIN_A_B, OUTPUT);
      pinMode(PIN_B_R, OUTPUT);
      pinMode(PIN_B_G, OUTPUT);
      pinMode(PIN_B_B, OUTPUT);
      pinMode(PIN_C_R, OUTPUT);
      pinMode(PIN_C_G, OUTPUT);
      pinMode(PIN_C_B, OUTPUT);

      ledcSetup(0, PWM_FREQ, PWM_RES_BITS);
      ledcSetup(1, PWM_FREQ, PWM_RES_BITS);
      ledcSetup(2, PWM_FREQ, PWM_RES_BITS);
      ledcSetup(3, PWM_FREQ, PWM_RES_BITS);
      ledcSetup(4, PWM_FREQ, PWM_RES_BITS);
      ledcSetup(5, PWM_FREQ, PWM_RES_BITS);
      ledcSetup(6, PWM_FREQ, PWM_RES_BITS);
      ledcSetup(7, PWM_FREQ, PWM_RES_BITS);
      ledcSetup(8, PWM_FREQ, PWM_RES_BITS);  
      
      ledcAttachPin(PIN_A_R, 0);
      ledcAttachPin(PIN_A_G, 1);
      ledcAttachPin(PIN_A_B, 2);
      ledcAttachPin(PIN_B_R, 3);
      ledcAttachPin(PIN_B_G, 4);
      ledcAttachPin(PIN_B_B, 5);
      ledcAttachPin(PIN_C_R, 6);
      ledcAttachPin(PIN_C_G, 7);
      ledcAttachPin(PIN_C_B, 8);
}