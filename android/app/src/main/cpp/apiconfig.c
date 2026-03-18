#include <stdint.h>

#ifndef APICONFIG_BASE_URL
#define APICONFIG_BASE_URL ""
#endif

#ifndef APICONFIG_API_KEY
#define APICONFIG_API_KEY ""
#endif

// Returns a UTF-8, null-terminated string.
const char *apiconfig_base_url(void) {
  return APICONFIG_BASE_URL;
}

// Returns a UTF-8, null-terminated string.
const char *apiconfig_api_key(void) {
  return APICONFIG_API_KEY;
}

