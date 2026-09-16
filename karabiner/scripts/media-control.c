#include <CoreAudio/CoreAudio.h>
#include <AudioToolbox/AudioHardwareService.h>
#include <math.h>
#include <CoreGraphics/CoreGraphics.h>
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static AudioDeviceID device(void) {
 AudioDeviceID d=0; UInt32 n=sizeof(d);
 AudioObjectPropertyAddress a={kAudioHardwarePropertyDefaultOutputDevice,kAudioObjectPropertyScopeGlobal,kAudioObjectPropertyElementMain};
 if(AudioObjectGetPropertyData(kAudioObjectSystemObject,&a,0,NULL,&n,&d)) return 0;
 return d;
}
int main(int argc,char **argv) {
 if(argc<2) return 2;
 int readOnly=argc==2; float delta=readOnly?0:strtof(argv[2],NULL);
 if(!strcmp(argv[1],"brightness")) {
  void *h=dlopen("/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices",RTLD_LAZY);
  int(*get)(CGDirectDisplayID,float*)=h?dlsym(h,"DisplayServicesGetBrightness"):NULL;
  int(*set)(CGDirectDisplayID,float)=h?dlsym(h,"DisplayServicesSetBrightness"):NULL;
  if(!get||!set) return 1;
  CGDirectDisplayID ids[16];uint32_t count=0;CGGetActiveDisplayList(16,ids,&count);
  for(uint32_t i=0;i<count;i++) {
   if(!CGDisplayIsBuiltin(ids[i])) continue;
   float v;if(get(ids[i],&v)) return 1;
   if(readOnly){printf("%.6f\n",v);return 0;}
   v=fminf(1,fmaxf(0,v+delta));return set(ids[i],v)?1:0;
  }
  return 1;
 }
 AudioDeviceID d=device();if(!d)return 1;
 AudioObjectPropertyAddress a={kAudioHardwareServiceDeviceProperty_VirtualMainVolume,kAudioDevicePropertyScopeOutput,kAudioObjectPropertyElementMain};
 if(!strcmp(argv[1],"mute")) {
  a.mSelector=kAudioDevicePropertyMute;UInt32 v=0,n=sizeof(v);
  if(AudioObjectGetPropertyData(d,&a,0,NULL,&n,&v))return 1;
  if(readOnly){printf("%u\n",v);return 0;}v=!v;
  return AudioObjectSetPropertyData(d,&a,0,NULL,n,&v)?1:0;
 }
 if(strcmp(argv[1],"volume"))return 2;
 float v;UInt32 n=sizeof(v);
 if(AudioObjectGetPropertyData(d,&a,0,NULL,&n,&v)) return 1;
 if(readOnly){printf("%.6f\n",v);return 0;}
 v=fminf(1,fmaxf(0,v+delta));
 if(AudioObjectSetPropertyData(d,&a,0,NULL,n,&v))return 1;
 a.mSelector=kAudioDevicePropertyMute;UInt32 mute=0;
 AudioObjectSetPropertyData(d,&a,0,NULL,sizeof(mute),&mute);
 return 0;
}
