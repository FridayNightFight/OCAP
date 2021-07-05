#ifndef OCAP_REPLAY_SAVER_2_H
#define OCAP_REPLAY_SAVER_2_H

#ifdef _WIN32
#define OCAP_EXPORT extern "C" __declspec (dllexport)
#else
#define OCAP_EXPORT extern "C" 
#define __stdcall
#endif

OCAP_EXPORT void __stdcall RVExtensionVersion(char* output, int outputSize);
OCAP_EXPORT void __stdcall RVExtension(char* output, int outputSize, const char* function);
OCAP_EXPORT int __stdcall RVExtensionArgs(char* output, int outputSize, const char* function, const char** argv, int argc);

#endif //OCAP_REPLAY_SAVER_2_H