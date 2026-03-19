#include <stdint.h>

#ifndef APICONFIG_BASE_URL
#define APICONFIG_BASE_URL ""
#endif

#ifndef APICONFIG_API_KEY
#define APICONFIG_API_KEY ""
#endif

const char *apiconfig_base_url(void) {
  return "https://api.apilayer.com/exchangerates_data";
}

const char *apiconfig_api_key(void) {
  return "uij8N3ZlsoFstTpLTHOCu1Jxr498MYNt";
}

